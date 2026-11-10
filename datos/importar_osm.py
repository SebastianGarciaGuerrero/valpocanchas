"""Importa las canchas de fútbol y multicanchas de OpenStreetMap en la comuna de Valparaíso.

Descarga (o lee la copia guardada) de OpenStreetMap, agrupa las canchas vecinas en un
recinto, estima el tipo por el tamaño de la cancha y genera un SQL idempotente en estado
'catastro'. Omite lo que ya viene del catastro del IND (corre antes importar_catastro.py).

Uso (desde la raíz del repo):
    python datos/importar_osm.py              # usa la copia en datos/fuentes/ si existe
    python datos/importar_osm.py --descargar  # vuelve a consultar OpenStreetMap

Salida: supabase/datos/catastro_osm.sql

Datos © OpenStreetMap contributors, licencia ODbL: la app debe mostrar esa atribución.

Reglas:
  - Solo leisure=pitch con sport soccer, futsal o multi, y sin acceso privado.
  - Canchas a menos de 100 m entre sí forman un recinto. Si caen dentro de un centro
    deportivo o estadio de OSM, el recinto toma su nombre.
  - Tipo por tamaño: < 1.200 m2 baby fútbol, < 3.500 m2 fútbol 7, si no fútbol 11.
  - Sector: el barrio o cerro de OSM más cercano (a menos de 2 km).
  - Se omite todo recinto a menos de 200 m de uno del catastro IND.
"""
from __future__ import annotations

import argparse
import json
import math
import sys
import time
import urllib.parse
import urllib.request
from pathlib import Path

from comun import NOMBRE_TIPO, distancia_m, generar_sql, limpio, nombres_unicos

RAIZ = Path(__file__).resolve().parent.parent
COPIA = RAIZ / "datos" / "fuentes" / "osm_valparaiso.json"
IND_JSON = RAIZ / "datos" / "generado" / "catastro_ind.json"
SALIDA_SQL = RAIZ / "supabase" / "datos" / "catastro_osm.sql"

# Comuna de Valparaíso (admin_level 8), limitada a la zona de Chile: en OSM hay municipios
# de Brasil con el mismo nombre.
CAJA = "(-33.35,-71.90,-32.90,-71.30)"
CONSULTA = (
    '[out:json][timeout:240];area["name"="Valparaíso"]["admin_level"="8"]->.a;('
    f'nwr["leisure"="pitch"](area.a){CAJA};'
    f'nwr["leisure"~"^(sports_centre|stadium)$"](area.a){CAJA};'
    f'node["place"~"^(neighbourhood|suburb|quarter|hamlet|village|locality)$"](area.a){CAJA};'
    ");out geom tags;"
)
SERVIDORES = (
    "https://overpass-api.de/api/interpreter",
    "https://maps.mail.ru/osm/tools/overpass/api/interpreter",
    "https://overpass.kumi.systems/api/interpreter",
)

DEPORTES = {"soccer", "futsal", "multi"}
SUPERFICIES = {
    "grass": "pasto_natural", "artificial_turf": "pasto_sintetico", "dirt": "tierra", "ground": "tierra",
    "earth": "tierra", "sand": "tierra", "gravel": "tierra", "compacted": "tierra", "concrete": "cemento",
    "asphalt": "cemento", "paved": "cemento", "paving_stones": "baldosa", "wood": "madera",
}
RADIO_GRUPO_M = 100
RADIO_IND_M = 200
RADIO_SECTOR_M = 2000


def descargar() -> dict:
    datos = urllib.parse.urlencode({"data": CONSULTA}).encode()
    for url in SERVIDORES:
        try:
            print(f"Consultando {url} …")
            req = urllib.request.Request(url, data=datos, headers={"User-Agent": "valpocanchas-catastro/0.1"})
            with urllib.request.urlopen(req, timeout=300) as r:
                return json.loads(r.read())
        except Exception as e:  # noqa: BLE001 — se prueba el siguiente servidor
            print(f"  falló: {e}")
            time.sleep(5)
    raise SystemExit("Ningún servidor de OpenStreetMap respondió. Inténtalo más tarde.")


def centro(el: dict) -> tuple[float, float]:
    if "lat" in el:
        return el["lat"], el["lon"]
    if "center" in el:
        return el["center"]["lat"], el["center"]["lon"]
    puntos = el.get("geometry") or []
    if puntos:
        return sum(p["lat"] for p in puntos) / len(puntos), sum(p["lon"] for p in puntos) / len(puntos)
    b = el["bounds"]
    return (b["minlat"] + b["maxlat"]) / 2, (b["minlon"] + b["maxlon"]) / 2


def area_m2(el: dict) -> float | None:
    puntos = el.get("geometry") or []
    if len(puntos) < 4:
        return None
    lat0 = math.radians(puntos[0]["lat"])
    xy = [(p["lon"] * 111_320 * math.cos(lat0), p["lat"] * 111_320) for p in puntos]
    return abs(sum(x1 * y2 - x2 * y1 for (x1, y1), (x2, y2) in zip(xy, xy[1:] + xy[:1]))) / 2


def dentro(punto: tuple[float, float], el: dict) -> bool:
    """Punto dentro de un polígono cerrado de OSM (ray casting)."""
    puntos = el.get("geometry") or []
    if len(puntos) < 4:
        return False
    lat, lng = punto
    adentro = False
    for a, b in zip(puntos, puntos[1:] + puntos[:1]):
        if (a["lat"] > lat) != (b["lat"] > lat):
            x = a["lon"] + (lat - a["lat"]) * (b["lon"] - a["lon"]) / (b["lat"] - a["lat"])
            if lng < x:
                adentro = not adentro
    return adentro


def es_cancha_de_futbol(tags: dict) -> bool:
    deportes = set((tags.get("sport") or "").split(";"))
    return bool(deportes & DEPORTES) and tags.get("access") not in ("private", "no")


def cancha_desde_osm(el: dict) -> dict:
    t = el["tags"]
    deportes = set((t.get("sport") or "").split(";"))
    area = area_m2(el)
    nombre_osm = limpio(t.get("name")) or ""
    if "multi" in deportes or len(deportes - {""}) > 1 or "multicancha" in nombre_osm.lower():
        tipo = "multicancha"
    elif "futsal" in deportes:
        tipo = "futsal"
    elif area is None or area < 1200:
        tipo = "baby_futbol"
    elif area < 3500:
        tipo = "futbol_7"
    else:
        tipo = "futbol_11"
    return {
        "nombre": NOMBRE_TIPO[tipo],
        "tipo": tipo,
        "superficie": SUPERFICIES.get(t.get("surface", "")),
        "techada": t.get("covered") == "yes" or "techad" in nombre_osm.lower(),
        "iluminacion": t.get("lit") == "yes",
        "area": area,
        "nombre_osm": nombre_osm,
        "ref": f'{el["type"]}/{el["id"]}',
        "punto": centro(el),
    }


def agrupar(canchas: list[dict]) -> list[list[dict]]:
    padre = list(range(len(canchas)))

    def raiz(i: int) -> int:
        while padre[i] != i:
            padre[i] = padre[padre[i]]
            i = padre[i]
        return i

    for i in range(len(canchas)):
        for j in range(i + 1, len(canchas)):
            if distancia_m(canchas[i]["punto"], canchas[j]["punto"]) <= RADIO_GRUPO_M:
                padre[raiz(i)] = raiz(j)
    grupos: dict[int, list[dict]] = {}
    for i, c in enumerate(canchas):
        grupos.setdefault(raiz(i), []).append(c)
    return list(grupos.values())


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--descargar", action="store_true", help="vuelve a consultar OpenStreetMap")
    args = parser.parse_args()

    if args.descargar or not COPIA.exists():
        datos = descargar()
        COPIA.parent.mkdir(parents=True, exist_ok=True)
        COPIA.write_text(json.dumps(datos, ensure_ascii=False), encoding="utf-8")
    datos = json.loads(COPIA.read_text(encoding="utf-8"))
    print(f"OpenStreetMap: copia del {datos.get('osm3s', {}).get('timestamp_osm_base', '?')}")

    elementos = datos["elements"]
    centros = [e for e in elementos if e["tags"].get("leisure") in ("sports_centre", "stadium") and limpio(e["tags"].get("name"))]
    lugares = [e for e in elementos if "place" in e["tags"] and limpio(e["tags"].get("name"))]
    canchas = [cancha_desde_osm(e) for e in elementos if e["tags"].get("leisure") == "pitch" and es_cancha_de_futbol(e["tags"])]
    ind = json.loads(IND_JSON.read_text(encoding="utf-8")) if IND_JSON.exists() else []
    if not ind:
        print("Aviso: no encontré datos/generado/catastro_ind.json; corre antes importar_catastro.py para no duplicar.")
    print(f"{len(canchas)} canchas de fútbol o multicanchas")

    recintos, omitidas = [], 0
    for grupo in agrupar(canchas):
        lat = sum(c["punto"][0] for c in grupo) / len(grupo)
        lng = sum(c["punto"][1] for c in grupo) / len(grupo)
        if any(distancia_m((lat, lng), (r["latitud"], r["longitud"])) <= RADIO_IND_M for r in ind):
            omitidas += len(grupo)
            continue
        contenedor = next((e for e in centros if any(dentro(c["punto"], e) for c in grupo)), None) or next(
            (e for e in centros if "lat" in e and distancia_m((lat, lng), (e["lat"], e["lon"])) <= 150), None
        )
        cercano = min(lugares, key=lambda e: distancia_m((lat, lng), (e["lat"], e["lon"])), default=None)
        sector = (
            limpio(cercano["tags"]["name"])
            if cercano and distancia_m((lat, lng), (cercano["lat"], cercano["lon"])) <= RADIO_SECTOR_M
            else None
        )
        con_nombre = next((c["nombre_osm"] for c in grupo if c["nombre_osm"]), None)
        if contenedor:
            nombre, ref = limpio(contenedor["tags"]["name"]), f'{contenedor["type"]}/{contenedor["id"]}'
        else:
            nombre = con_nombre or (f"{grupo[0]['nombre']} – {sector}" if sector else grupo[0]["nombre"])
            ref = min(c["ref"] for c in grupo)
        lista = [{k: c[k] for k in ("nombre", "tipo", "superficie", "techada", "iluminacion")} for c in grupo]
        nombres_unicos(lista)
        recintos.append({
            "nombre": nombre,
            "sector": sector,
            "latitud": round(lat, 6),
            "longitud": round(lng, 6),
            "fuente_ref": ref,
            "descripcion": "Datos de OpenStreetMap (© OpenStreetMap contributors). Tipo de cancha estimado por su tamaño en el mapa.",
            "canchas": lista,
        })

    # Mismo nombre en distintos lugares (p. ej. "Cancha de baby fútbol – Cerro Barón"): se numeran.
    vistos: dict[str, int] = {}
    for r in sorted(recintos, key=lambda r: r["fuente_ref"]):
        vistos[r["nombre"]] = vistos.get(r["nombre"], 0) + 1
        if vistos[r["nombre"]] > 1:
            r["nombre"] = f'{r["nombre"]} ({vistos[r["nombre"]]})'

    recintos.sort(key=lambda r: r["nombre"])
    SALIDA_SQL.parent.mkdir(parents=True, exist_ok=True)
    SALIDA_SQL.write_text(
        generar_sql(recintos, "osm", [
            "Fuente: OpenStreetMap (© OpenStreetMap contributors, licencia ODbL).",
            f"Copia del {datos.get('osm3s', {}).get('timestamp_osm_base', '?')}. Comuna de Valparaíso.",
        ]),
        encoding="utf-8",
    )
    total = sum(len(r["canchas"]) for r in recintos)
    print(f"{len(recintos)} recintos y {total} canchas -> {SALIDA_SQL.relative_to(RAIZ)} ({omitidas} canchas ya estaban en el catastro IND)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
