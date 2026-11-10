"""Importa el catastro de recintos del IND (respuesta de transparencia BA002T0007721).

Lee la hoja de la comuna de Valparaíso, resuelve cada enlace de Google Maps a
coordenadas y genera un SQL idempotente con los recintos y sus canchas en estado
'catastro'. Cada sector con enlace propio queda como un recinto aparte.

Uso (desde la raíz del repo):
    pip install openpyxl
    python datos/importar_catastro.py

Salidas:
    supabase/datos/catastro_ind.sql   (se aplica en el SQL Editor de Supabase o con psql)
    datos/generado/catastro_ind.json  (lo usa importar_osm.py para no duplicar recintos)

Las canchas se deducen del texto "Superficie de Juego" del catastro:
  - "multicancha" -> multicancha; "fútbol" o "cancha de tierra" -> fútbol 11
    (son recintos de más de 4.000 m2; el formato exacto se confirma con el administrador).
  - Superficie por palabra clave (madera, tierra, pasto natural, sintético, baldosa, cemento).
  - Techada si es de madera o si el sector es un polideportivo o gimnasio.
"""
from __future__ import annotations

import json
import re
import sys
import urllib.error
import urllib.request
from pathlib import Path

import openpyxl

from comun import NOMBRE_TIPO, generar_sql, limpio, nombres_unicos, sin_tildes, slug

RAIZ = Path(__file__).resolve().parent.parent
FUENTE = RAIZ / "datos" / "fuentes" / "ind_catastro_recintos_BA002T0007721.xlsx"
SALIDA_SQL = RAIZ / "supabase" / "datos" / "catastro_ind.sql"
SALIDA_JSON = RAIZ / "datos" / "generado" / "catastro_ind.json"
SOLICITUD = "BA002T0007721"
COMUNA = "Valparaíso"

# Columnas de la hoja "Valparaíso" (base 0)
C_NUM, C_NOMBRE, C_SECTOR, C_M2, C_DIR, C_COMUNA = 1, 2, 4, 5, 6, 8
C_TIPO_ADMIN, C_SUPERFICIE, C_EST_SUP, C_MAPS = 9, 12, 13, 28
# Hoja "con Avaluo fiscal": columna con la institución que administra
C_INSTITUCION = 24

SECTORES_EN_DIRECCION = ("Playa Ancha", "Quebrada Verde", "Cerro Los Placeres")


class _SinRedireccion(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, *args, **kwargs):
        return None


def coordenadas(enlace: str) -> tuple[float, float]:
    """Sigue el enlace corto de Google Maps y lee las coordenadas de la URL final."""
    req = urllib.request.Request(enlace, method="HEAD", headers={"User-Agent": "Mozilla/5.0"})
    try:
        destino = urllib.request.build_opener(_SinRedireccion).open(req, timeout=20).geturl()
    except urllib.error.HTTPError as e:
        if e.code not in (301, 302, 303, 307, 308):
            raise
        destino = e.headers["Location"]
    for patron in (r"!3d(-?\d+\.\d+)!4d(-?\d+\.\d+)", r"/search/(-?\d+\.\d+),\+?(-?\d+\.\d+)", r"@(-?\d+\.\d+),(-?\d+\.\d+)"):
        m = re.search(patron, destino)
        if m:
            return float(m.group(1)), float(m.group(2))
    raise ValueError(f"No encontré coordenadas en {destino}")


def canchas_desde_texto(superficie: str, sector: str) -> list[dict]:
    canchas = []
    techado_sector = any(p in sin_tildes(sector) for p in ("polideportivo", "gimnasio"))
    for parte in re.split(r",| y ", superficie):
        p = sin_tildes(parte)
        if not p.strip() or any(x in p for x in ("pista", "piscina", "sala")):
            continue
        if "multicancha" in p:
            tipo = "multicancha"
        elif "futbol" in p or "cancha" in p:
            tipo = "futbol_11"
        else:
            continue
        sup = None
        for clave, valor in (("madera", "madera"), ("tierra", "tierra"), ("pasto natural", "pasto_natural"),
                             ("sintetic", "pasto_sintetico"), ("baldosa", "baldosa"), ("cemento", "cemento")):
            if clave in p:
                sup = valor
        canchas.append({"nombre": NOMBRE_TIPO[tipo], "tipo": tipo, "superficie": sup,
                        "techada": sup == "madera" or techado_sector})
    nombres_unicos(canchas)
    return canchas


def sector_desde_direccion(direccion: str | None) -> str | None:
    for s in SECTORES_EN_DIRECCION:
        if direccion and sin_tildes(s) in sin_tildes(direccion):
            return s
    return None


def leer_recintos() -> list[dict]:
    libro = openpyxl.load_workbook(FUENTE, read_only=True, data_only=True)
    instituciones = {}
    for fila in libro["con Avaluo fiscal"].iter_rows(values_only=True):
        if limpio(fila[C_COMUNA]) == COMUNA and isinstance(fila[C_NUM], int):
            instituciones[fila[C_NUM]] = limpio(fila[C_INSTITUCION])

    filas = [f for f in libro[COMUNA].iter_rows(values_only=True) if limpio(f[C_COMUNA]) == COMUNA]
    sectores_por_recinto: dict[int, int] = {}
    numero = None
    for f in filas:  # las filas de continuación de un recinto traen el número pero no el nombre
        numero = f[C_NUM] or numero
        sectores_por_recinto[numero] = sectores_por_recinto.get(numero, 0) + 1

    recintos = []
    numero, nombre_recinto = None, None
    for f in filas:
        numero = f[C_NUM] or numero
        nombre_recinto = limpio(f[C_NOMBRE]) or nombre_recinto
        sector = limpio(f[C_SECTOR]) or nombre_recinto
        superficie = limpio(f[C_SUPERFICIE])
        if not superficie or superficie.upper() == "NO":
            print(f"  omitido (sin superficie de juego): {nombre_recinto}")
            continue
        nombre = nombre_recinto if sectores_por_recinto[numero] == 1 else f"{nombre_recinto} – {sector}"
        lat, lng = coordenadas(limpio(f[C_MAPS]))
        direccion = limpio(f[C_DIR])
        recinto = {
            "nombre": nombre,
            "direccion": direccion,
            "sector": sector_desde_direccion(direccion),
            "latitud": lat,
            "longitud": lng,
            "fuente_ref": f"{SOLICITUD}-{numero}-{slug(sector)}",
            "tipo_administracion": limpio(f[C_TIPO_ADMIN]),
            "institucion_administradora": instituciones.get(numero),
            "superficie_m2": f[C_M2] if isinstance(f[C_M2], int) else None,
            "estado_conservacion": limpio(f[C_EST_SUP]) if limpio(f[C_EST_SUP]) in ("B", "R", "M") else None,
            "descripcion": f"Superficie según catastro IND: {superficie}.",
            "canchas": canchas_desde_texto(superficie, sector),
        }
        recintos.append(recinto)
        print(f"  {nombre}: {lat}, {lng} · {len(recinto['canchas'])} cancha(s)")
    return recintos


def main() -> int:
    print(f"Leyendo {FUENTE.relative_to(RAIZ)}")
    recintos = leer_recintos()
    SALIDA_SQL.parent.mkdir(parents=True, exist_ok=True)
    SALIDA_JSON.parent.mkdir(parents=True, exist_ok=True)
    SALIDA_SQL.write_text(
        generar_sql(recintos, "ind", [f"Fuente: IND, solicitud de transparencia {SOLICITUD}. Comuna de {COMUNA}."]),
        encoding="utf-8",
    )
    SALIDA_JSON.write_text(json.dumps(recintos, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"{len(recintos)} recintos y {sum(len(r['canchas']) for r in recintos)} canchas -> {SALIDA_SQL.relative_to(RAIZ)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
