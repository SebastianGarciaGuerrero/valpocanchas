"""Utilidades compartidas por los importadores de datos/: texto, geometría y generación de SQL."""
from __future__ import annotations

import math
import re
import unicodedata

NOMBRE_TIPO = {
    "futbol_11": "Cancha de fútbol",
    "futbol_7": "Cancha de fútbol 7",
    "baby_futbol": "Cancha de baby fútbol",
    "futsal": "Cancha de futsal",
    "multicancha": "Multicancha",
}


def limpio(texto) -> str | None:
    if texto is None:
        return None
    t = re.sub(r"\s+", " ", str(texto)).strip()
    return t or None


def sin_tildes(texto: str) -> str:
    return "".join(c for c in unicodedata.normalize("NFD", texto.lower()) if unicodedata.category(c) != "Mn")


def slug(texto: str) -> str:
    return re.sub(r"[^a-z0-9]+", "-", sin_tildes(texto)).strip("-")


def distancia_m(a: tuple[float, float], b: tuple[float, float]) -> float:
    """Distancia aproximada en metros entre dos puntos (lat, lng). Suficiente para distancias cortas."""
    lat = math.radians((a[0] + b[0]) / 2)
    dy = (a[0] - b[0]) * 111_320
    dx = (a[1] - b[1]) * 111_320 * math.cos(lat)
    return math.hypot(dx, dy)


def nombres_unicos(canchas: list[dict]) -> None:
    """Si un recinto tiene varias canchas con el mismo nombre, las numera."""
    totales: dict[str, int] = {}
    for c in canchas:
        totales[c["nombre"]] = totales.get(c["nombre"], 0) + 1
    vistos: dict[str, int] = {}
    for c in canchas:
        if totales[c["nombre"]] > 1:
            vistos[c["nombre"]] = vistos.get(c["nombre"], 0) + 1
            c["nombre"] = f'{c["nombre"]} {vistos[c["nombre"]]}'


def lit(valor) -> str:
    if valor is None:
        return "null"
    if isinstance(valor, bool):
        return "true" if valor else "false"
    if isinstance(valor, (int, float)):
        return repr(valor)
    return "'" + str(valor).replace("'", "''") + "'"


def generar_sql(recintos: list[dict], fuente: str, encabezado: list[str]) -> str:
    """SQL idempotente: inserta o actualiza cada recinto (por fuente + fuente_ref) y agrega sus canchas.

    En una nueva importación solo se actualizan los datos de origen (ubicación, dirección, administración);
    lo que el equipo haya editado a mano (nombre, contacto, estado) no se pisa.
    """
    lineas = [
        "-- Generado automáticamente por un script de datos/. No editar a mano: corregir el script y volver a generar.",
        *[f"-- {linea}" for linea in encabezado],
        "-- Idempotente: se puede aplicar varias veces.",
        "begin;",
    ]
    for r in recintos:
        lineas.append(f"""
-- {r['nombre']}
insert into recintos (nombre, direccion, sector, latitud, longitud, estado, fuente, fuente_ref,
  tipo_administracion, institucion_administradora, superficie_m2, estado_conservacion, descripcion)
values ({lit(r['nombre'])}, {lit(r.get('direccion'))}, {lit(r.get('sector'))}, {lit(r['latitud'])}, {lit(r['longitud'])},
  'catastro', {lit(fuente)}, {lit(r['fuente_ref'])}, {lit(r.get('tipo_administracion'))},
  {lit(r.get('institucion_administradora'))}, {lit(r.get('superficie_m2'))}, {lit(r.get('estado_conservacion'))},
  {lit(r.get('descripcion'))})
on conflict (fuente, fuente_ref) do update set
  direccion = excluded.direccion, sector = coalesce(recintos.sector, excluded.sector),
  latitud = excluded.latitud, longitud = excluded.longitud,
  tipo_administracion = excluded.tipo_administracion,
  institucion_administradora = excluded.institucion_administradora,
  superficie_m2 = excluded.superficie_m2, estado_conservacion = excluded.estado_conservacion;""")
        for c in r["canchas"]:
            lineas.append(f"""insert into canchas (recinto_id, nombre, tipo, superficie, techada, iluminacion)
select id, {lit(c['nombre'])}, {lit(c['tipo'])}, {lit(c.get('superficie'))}, {lit(bool(c.get('techada')))}, {lit(bool(c.get('iluminacion')))}
from recintos where fuente = {lit(fuente)} and fuente_ref = {lit(r['fuente_ref'])}
on conflict (recinto_id, nombre) do nothing;""")
    lineas.append("\ncommit;\n")
    return "\n".join(lineas)
