-- Generado automáticamente por un script de datos/. No editar a mano: corregir el script y volver a generar.
-- Fuente: OpenStreetMap (© OpenStreetMap contributors, licencia ODbL).
-- Copia del 2026-11-10T01:20:48Z. Comuna de Valparaíso.
-- Idempotente: se puede aplicar varias veces.
begin;

-- Auditorio Benito Parraguez
insert into recintos (nombre, direccion, sector, latitud, longitud, estado, fuente, fuente_ref,
  tipo_administracion, institucion_administradora, superficie_m2, estado_conservacion, descripcion)
values ('Auditorio Benito Parraguez', null, 'María Eislers', -33.043578, -71.583631,
  'catastro', 'osm', 'way/173081196', null,
  null, null, null,
  'Datos de OpenStreetMap (© OpenStreetMap contributors). Tipo de cancha estimado por su tamaño en el mapa.')
on conflict (fuente, fuente_ref) do update set
  direccion = excluded.direccion, sector = coalesce(recintos.sector, excluded.sector),
  latitud = excluded.latitud, longitud = excluded.longitud,
  tipo_administracion = excluded.tipo_administracion,
  institucion_administradora = excluded.institucion_administradora,
  superficie_m2 = excluded.superficie_m2, estado_conservacion = excluded.estado_conservacion;
insert into canchas (recinto_id, nombre, tipo, superficie, techada, iluminacion)
select id, 'Cancha de fútbol', 'futbol_11', 'tierra', false, false
from recintos where fuente = 'osm' and fuente_ref = 'way/173081196'
on conflict (recinto_id, nombre) do nothing;

-- Auditorio Osmán Pérez Freire
insert into recintos (nombre, direccion, sector, latitud, longitud, estado, fuente, fuente_ref,
  tipo_administracion, institucion_administradora, superficie_m2, estado_conservacion, descripcion)
values ('Auditorio Osmán Pérez Freire', null, 'Villa Adolfo Ibáñez', -33.055314, -71.620415,
  'catastro', 'osm', 'way/274036804', null,
  null, null, null,
  'Datos de OpenStreetMap (© OpenStreetMap contributors). Tipo de cancha estimado por su tamaño en el mapa.')
on conflict (fuente, fuente_ref) do update set
  direccion = excluded.direccion, sector = coalesce(recintos.sector, excluded.sector),
  latitud = excluded.latitud, longitud = excluded.longitud,
  tipo_administracion = excluded.tipo_administracion,
  institucion_administradora = excluded.institucion_administradora,
  superficie_m2 = excluded.superficie_m2, estado_conservacion = excluded.estado_conservacion;
insert into canchas (recinto_id, nombre, tipo, superficie, techada, iluminacion)
select id, 'Cancha de fútbol', 'futbol_11', 'tierra', false, false
from recintos where fuente = 'osm' and fuente_ref = 'way/274036804'
on conflict (recinto_id, nombre) do nothing;

-- Cancha La Campana
insert into recintos (nombre, direccion, sector, latitud, longitud, estado, fuente, fuente_ref,
  tipo_administracion, institucion_administradora, superficie_m2, estado_conservacion, descripcion)
values ('Cancha La Campana', null, 'Cerro Toro', -33.037946, -71.635273,
  'catastro', 'osm', 'way/201658909', null,
  null, null, null,
  'Datos de OpenStreetMap (© OpenStreetMap contributors). Tipo de cancha estimado por su tamaño en el mapa.')
on conflict (fuente, fuente_ref) do update set
  direccion = excluded.direccion, sector = coalesce(recintos.sector, excluded.sector),
  latitud = excluded.latitud, longitud = excluded.longitud,
  tipo_administracion = excluded.tipo_administracion,
  institucion_administradora = excluded.institucion_administradora,
  superficie_m2 = excluded.superficie_m2, estado_conservacion = excluded.estado_conservacion;
insert into canchas (recinto_id, nombre, tipo, superficie, techada, iluminacion)
select id, 'Cancha de fútbol 7', 'futbol_7', null, false, false
from recintos where fuente = 'osm' and fuente_ref = 'way/201658909'
on conflict (recinto_id, nombre) do nothing;
insert into canchas (recinto_id, nombre, tipo, superficie, techada, iluminacion)
select id, 'Cancha de baby fútbol', 'baby_futbol', null, false, false
from recintos where fuente = 'osm' and fuente_ref = 'way/201658909'
on conflict (recinto_id, nombre) do nothing;

-- Cancha La Laguna
insert into recintos (nombre, direccion, sector, latitud, longitud, estado, fuente, fuente_ref,
  tipo_administracion, institucion_administradora, superficie_m2, estado_conservacion, descripcion)
values ('Cancha La Laguna', null, 'Cerro Larraín', -33.044466, -71.598615,
  'catastro', 'osm', 'way/172349676', null,
  null, null, null,
  'Datos de OpenStreetMap (© OpenStreetMap contributors). Tipo de cancha estimado por su tamaño en el mapa.')
on conflict (fuente, fuente_ref) do update set
  direccion = excluded.direccion, sector = coalesce(recintos.sector, excluded.sector),
  latitud = excluded.latitud, longitud = excluded.longitud,
  tipo_administracion = excluded.tipo_administracion,
  institucion_administradora = excluded.institucion_administradora,
  superficie_m2 = excluded.superficie_m2, estado_conservacion = excluded.estado_conservacion;
insert into canchas (recinto_id, nombre, tipo, superficie, techada, iluminacion)
select id, 'Cancha de fútbol', 'futbol_11', 'tierra', false, false
from recintos where fuente = 'osm' and fuente_ref = 'way/172349676'
on conflict (recinto_id, nombre) do nothing;

-- Cancha de baby fútbol – Blanco Encalada
insert into recintos (nombre, direccion, sector, latitud, longitud, estado, fuente, fuente_ref,
  tipo_administracion, institucion_administradora, superficie_m2, estado_conservacion, descripcion)
values ('Cancha de baby fútbol – Blanco Encalada', null, 'Blanco Encalada', -33.05395, -71.595123,
  'catastro', 'osm', 'way/274651437', null,
  null, null, null,
  'Datos de OpenStreetMap (© OpenStreetMap contributors). Tipo de cancha estimado por su tamaño en el mapa.')
on conflict (fuente, fuente_ref) do update set
  direccion = excluded.direccion, sector = coalesce(recintos.sector, excluded.sector),
  latitud = excluded.latitud, longitud = excluded.longitud,
  tipo_administracion = excluded.tipo_administracion,
  institucion_administradora = excluded.institucion_administradora,
  superficie_m2 = excluded.superficie_m2, estado_conservacion = excluded.estado_conservacion;
insert into canchas (recinto_id, nombre, tipo, superficie, techada, iluminacion)
select id, 'Cancha de baby fútbol', 'baby_futbol', 'cemento', false, true
from recintos where fuente = 'osm' and fuente_ref = 'way/274651437'
on conflict (recinto_id, nombre) do nothing;

-- Cancha de baby fútbol – Cerro Florida
insert into recintos (nombre, direccion, sector, latitud, longitud, estado, fuente, fuente_ref,
  tipo_administracion, institucion_administradora, superficie_m2, estado_conservacion, descripcion)
values ('Cancha de baby fútbol – Cerro Florida', null, 'Cerro Florida', -33.058329, -71.625157,
  'catastro', 'osm', 'way/274241621', null,
  null, null, null,
  'Datos de OpenStreetMap (© OpenStreetMap contributors). Tipo de cancha estimado por su tamaño en el mapa.')
on conflict (fuente, fuente_ref) do update set
  direccion = excluded.direccion, sector = coalesce(recintos.sector, excluded.sector),
  latitud = excluded.latitud, longitud = excluded.longitud,
  tipo_administracion = excluded.tipo_administracion,
  institucion_administradora = excluded.institucion_administradora,
  superficie_m2 = excluded.superficie_m2, estado_conservacion = excluded.estado_conservacion;
insert into canchas (recinto_id, nombre, tipo, superficie, techada, iluminacion)
select id, 'Cancha de baby fútbol', 'baby_futbol', null, false, false
from recintos where fuente = 'osm' and fuente_ref = 'way/274241621'
on conflict (recinto_id, nombre) do nothing;

-- Cancha de baby fútbol – Cerro Lecheros
insert into recintos (nombre, direccion, sector, latitud, longitud, estado, fuente, fuente_ref,
  tipo_administracion, institucion_administradora, superficie_m2, estado_conservacion, descripcion)
values ('Cancha de baby fútbol – Cerro Lecheros', null, 'Cerro Lecheros', -33.04615, -71.602959,
  'catastro', 'osm', 'way/443674348', null,
  null, null, null,
  'Datos de OpenStreetMap (© OpenStreetMap contributors). Tipo de cancha estimado por su tamaño en el mapa.')
on conflict (fuente, fuente_ref) do update set
  direccion = excluded.direccion, sector = coalesce(recintos.sector, excluded.sector),
  latitud = excluded.latitud, longitud = excluded.longitud,
  tipo_administracion = excluded.tipo_administracion,
  institucion_administradora = excluded.institucion_administradora,
  superficie_m2 = excluded.superficie_m2, estado_conservacion = excluded.estado_conservacion;
insert into canchas (recinto_id, nombre, tipo, superficie, techada, iluminacion)
select id, 'Cancha de baby fútbol', 'baby_futbol', null, false, true
from recintos where fuente = 'osm' and fuente_ref = 'way/443674348'
on conflict (recinto_id, nombre) do nothing;

-- Cancha de baby fútbol – Cerro San Juan de Dios
insert into recintos (nombre, direccion, sector, latitud, longitud, estado, fuente, fuente_ref,
  tipo_administracion, institucion_administradora, superficie_m2, estado_conservacion, descripcion)
values ('Cancha de baby fútbol – Cerro San Juan de Dios', null, 'Cerro San Juan de Dios', -33.049473, -71.626935,
  'catastro', 'osm', 'way/561842808', null,
  null, null, null,
  'Datos de OpenStreetMap (© OpenStreetMap contributors). Tipo de cancha estimado por su tamaño en el mapa.')
on conflict (fuente, fuente_ref) do update set
  direccion = excluded.direccion, sector = coalesce(recintos.sector, excluded.sector),
  latitud = excluded.latitud, longitud = excluded.longitud,
  tipo_administracion = excluded.tipo_administracion,
  institucion_administradora = excluded.institucion_administradora,
  superficie_m2 = excluded.superficie_m2, estado_conservacion = excluded.estado_conservacion;
insert into canchas (recinto_id, nombre, tipo, superficie, techada, iluminacion)
select id, 'Cancha de baby fútbol', 'baby_futbol', null, false, false
from recintos where fuente = 'osm' and fuente_ref = 'way/561842808'
on conflict (recinto_id, nombre) do nothing;

-- Cancha de baby fútbol – Cincel
insert into recintos (nombre, direccion, sector, latitud, longitud, estado, fuente, fuente_ref,
  tipo_administracion, institucion_administradora, superficie_m2, estado_conservacion, descripcion)
values ('Cancha de baby fútbol – Cincel', null, 'Cincel', -33.04753, -71.580476,
  'catastro', 'osm', 'way/550771730', null,
  null, null, null,
  'Datos de OpenStreetMap (© OpenStreetMap contributors). Tipo de cancha estimado por su tamaño en el mapa.')
on conflict (fuente, fuente_ref) do update set
  direccion = excluded.direccion, sector = coalesce(recintos.sector, excluded.sector),
  latitud = excluded.latitud, longitud = excluded.longitud,
  tipo_administracion = excluded.tipo_administracion,
  institucion_administradora = excluded.institucion_administradora,
  superficie_m2 = excluded.superficie_m2, estado_conservacion = excluded.estado_conservacion;
insert into canchas (recinto_id, nombre, tipo, superficie, techada, iluminacion)
select id, 'Cancha de baby fútbol', 'baby_futbol', null, false, true
from recintos where fuente = 'osm' and fuente_ref = 'way/550771730'
on conflict (recinto_id, nombre) do nothing;

-- Cancha de baby fútbol – El Esfuerzo
insert into recintos (nombre, direccion, sector, latitud, longitud, estado, fuente, fuente_ref,
  tipo_administracion, institucion_administradora, superficie_m2, estado_conservacion, descripcion)
values ('Cancha de baby fútbol – El Esfuerzo', null, 'El Esfuerzo', -33.051889, -71.569566,
  'catastro', 'osm', 'way/1068564549', null,
  null, null, null,
  'Datos de OpenStreetMap (© OpenStreetMap contributors). Tipo de cancha estimado por su tamaño en el mapa.')
on conflict (fuente, fuente_ref) do update set
  direccion = excluded.direccion, sector = coalesce(recintos.sector, excluded.sector),
  latitud = excluded.latitud, longitud = excluded.longitud,
  tipo_administracion = excluded.tipo_administracion,
  institucion_administradora = excluded.institucion_administradora,
  superficie_m2 = excluded.superficie_m2, estado_conservacion = excluded.estado_conservacion;
insert into canchas (recinto_id, nombre, tipo, superficie, techada, iluminacion)
select id, 'Cancha de baby fútbol', 'baby_futbol', null, false, false
from recintos where fuente = 'osm' and fuente_ref = 'way/1068564549'
on conflict (recinto_id, nombre) do nothing;

-- Cancha de baby fútbol – La Planchada
insert into recintos (nombre, direccion, sector, latitud, longitud, estado, fuente, fuente_ref,
  tipo_administracion, institucion_administradora, superficie_m2, estado_conservacion, descripcion)
values ('Cancha de baby fútbol – La Planchada', null, 'La Planchada', -33.055211, -71.581108,
  'catastro', 'osm', 'way/554311520', null,
  null, null, null,
  'Datos de OpenStreetMap (© OpenStreetMap contributors). Tipo de cancha estimado por su tamaño en el mapa.')
on conflict (fuente, fuente_ref) do update set
  direccion = excluded.direccion, sector = coalesce(recintos.sector, excluded.sector),
  latitud = excluded.latitud, longitud = excluded.longitud,
  tipo_administracion = excluded.tipo_administracion,
  institucion_administradora = excluded.institucion_administradora,
  superficie_m2 = excluded.superficie_m2, estado_conservacion = excluded.estado_conservacion;
insert into canchas (recinto_id, nombre, tipo, superficie, techada, iluminacion)
select id, 'Cancha de baby fútbol', 'baby_futbol', null, false, false
from recintos where fuente = 'osm' and fuente_ref = 'way/554311520'
on conflict (recinto_id, nombre) do nothing;

-- Cancha de baby fútbol – Las Torres
insert into recintos (nombre, direccion, sector, latitud, longitud, estado, fuente, fuente_ref,
  tipo_administracion, institucion_administradora, superficie_m2, estado_conservacion, descripcion)
values ('Cancha de baby fútbol – Las Torres', null, 'Las Torres', -33.071872, -71.59586,
  'catastro', 'osm', 'way/274631621', null,
  null, null, null,
  'Datos de OpenStreetMap (© OpenStreetMap contributors). Tipo de cancha estimado por su tamaño en el mapa.')
on conflict (fuente, fuente_ref) do update set
  direccion = excluded.direccion, sector = coalesce(recintos.sector, excluded.sector),
  latitud = excluded.latitud, longitud = excluded.longitud,
  tipo_administracion = excluded.tipo_administracion,
  institucion_administradora = excluded.institucion_administradora,
  superficie_m2 = excluded.superficie_m2, estado_conservacion = excluded.estado_conservacion;
insert into canchas (recinto_id, nombre, tipo, superficie, techada, iluminacion)
select id, 'Cancha de baby fútbol', 'baby_futbol', null, false, false
from recintos where fuente = 'osm' and fuente_ref = 'way/274631621'
on conflict (recinto_id, nombre) do nothing;

-- Cancha de baby fútbol – Lomas de Curauma
insert into recintos (nombre, direccion, sector, latitud, longitud, estado, fuente, fuente_ref,
  tipo_administracion, institucion_administradora, superficie_m2, estado_conservacion, descripcion)
values ('Cancha de baby fútbol – Lomas de Curauma', null, 'Lomas de Curauma', -33.147115, -71.567882,
  'catastro', 'osm', 'way/819578487', null,
  null, null, null,
  'Datos de OpenStreetMap (© OpenStreetMap contributors). Tipo de cancha estimado por su tamaño en el mapa.')
on conflict (fuente, fuente_ref) do update set
  direccion = excluded.direccion, sector = coalesce(recintos.sector, excluded.sector),
  latitud = excluded.latitud, longitud = excluded.longitud,
  tipo_administracion = excluded.tipo_administracion,
  institucion_administradora = excluded.institucion_administradora,
  superficie_m2 = excluded.superficie_m2, estado_conservacion = excluded.estado_conservacion;
insert into canchas (recinto_id, nombre, tipo, superficie, techada, iluminacion)
select id, 'Cancha de baby fútbol', 'baby_futbol', null, false, false
from recintos where fuente = 'osm' and fuente_ref = 'way/819578487'
on conflict (recinto_id, nombre) do nothing;

-- Cancha de baby fútbol – Otaegui
insert into recintos (nombre, direccion, sector, latitud, longitud, estado, fuente, fuente_ref,
  tipo_administracion, institucion_administradora, superficie_m2, estado_conservacion, descripcion)
values ('Cancha de baby fútbol – Otaegui', null, 'Otaegui', -33.10012, -71.66281,
  'catastro', 'osm', 'way/55291935', null,
  null, null, null,
  'Datos de OpenStreetMap (© OpenStreetMap contributors). Tipo de cancha estimado por su tamaño en el mapa.')
on conflict (fuente, fuente_ref) do update set
  direccion = excluded.direccion, sector = coalesce(recintos.sector, excluded.sector),
  latitud = excluded.latitud, longitud = excluded.longitud,
  tipo_administracion = excluded.tipo_administracion,
  institucion_administradora = excluded.institucion_administradora,
  superficie_m2 = excluded.superficie_m2, estado_conservacion = excluded.estado_conservacion;
insert into canchas (recinto_id, nombre, tipo, superficie, techada, iluminacion)
select id, 'Cancha de baby fútbol', 'baby_futbol', null, false, false
from recintos where fuente = 'osm' and fuente_ref = 'way/55291935'
on conflict (recinto_id, nombre) do nothing;

-- Cancha de baby fútbol – Poblacion Miramar
insert into recintos (nombre, direccion, sector, latitud, longitud, estado, fuente, fuente_ref,
  tipo_administracion, institucion_administradora, superficie_m2, estado_conservacion, descripcion)
values ('Cancha de baby fútbol – Poblacion Miramar', null, 'Poblacion Miramar', -33.030021, -71.648669,
  'catastro', 'osm', 'way/998765428', null,
  null, null, null,
  'Datos de OpenStreetMap (© OpenStreetMap contributors). Tipo de cancha estimado por su tamaño en el mapa.')
on conflict (fuente, fuente_ref) do update set
  direccion = excluded.direccion, sector = coalesce(recintos.sector, excluded.sector),
  latitud = excluded.latitud, longitud = excluded.longitud,
  tipo_administracion = excluded.tipo_administracion,
  institucion_administradora = excluded.institucion_administradora,
  superficie_m2 = excluded.superficie_m2, estado_conservacion = excluded.estado_conservacion;
insert into canchas (recinto_id, nombre, tipo, superficie, techada, iluminacion)
select id, 'Cancha de baby fútbol 1', 'baby_futbol', null, false, false
from recintos where fuente = 'osm' and fuente_ref = 'way/998765428'
on conflict (recinto_id, nombre) do nothing;
insert into canchas (recinto_id, nombre, tipo, superficie, techada, iluminacion)
select id, 'Cancha de baby fútbol 2', 'baby_futbol', null, false, false
from recintos where fuente = 'osm' and fuente_ref = 'way/998765428'
on conflict (recinto_id, nombre) do nothing;

-- Cancha de baby fútbol – Población Cuatro Luces
insert into recintos (nombre, direccion, sector, latitud, longitud, estado, fuente, fuente_ref,
  tipo_administracion, institucion_administradora, superficie_m2, estado_conservacion, descripcion)
values ('Cancha de baby fútbol – Población Cuatro Luces', null, 'Población Cuatro Luces', -33.035505, -71.592807,
  'catastro', 'osm', 'way/288716359', null,
  null, null, null,
  'Datos de OpenStreetMap (© OpenStreetMap contributors). Tipo de cancha estimado por su tamaño en el mapa.')
on conflict (fuente, fuente_ref) do update set
  direccion = excluded.direccion, sector = coalesce(recintos.sector, excluded.sector),
  latitud = excluded.latitud, longitud = excluded.longitud,
  tipo_administracion = excluded.tipo_administracion,
  institucion_administradora = excluded.institucion_administradora,
  superficie_m2 = excluded.superficie_m2, estado_conservacion = excluded.estado_conservacion;
insert into canchas (recinto_id, nombre, tipo, superficie, techada, iluminacion)
select id, 'Cancha de baby fútbol', 'baby_futbol', 'cemento', false, false
from recintos where fuente = 'osm' and fuente_ref = 'way/288716359'
on conflict (recinto_id, nombre) do nothing;

-- Cancha de baby fútbol – Población Juan Pablo II
insert into recintos (nombre, direccion, sector, latitud, longitud, estado, fuente, fuente_ref,
  tipo_administracion, institucion_administradora, superficie_m2, estado_conservacion, descripcion)
values ('Cancha de baby fútbol – Población Juan Pablo II', null, 'Población Juan Pablo II', -33.060345, -71.559179,
  'catastro', 'osm', 'way/200648875', null,
  null, null, null,
  'Datos de OpenStreetMap (© OpenStreetMap contributors). Tipo de cancha estimado por su tamaño en el mapa.')
on conflict (fuente, fuente_ref) do update set
  direccion = excluded.direccion, sector = coalesce(recintos.sector, excluded.sector),
  latitud = excluded.latitud, longitud = excluded.longitud,
  tipo_administracion = excluded.tipo_administracion,
  institucion_administradora = excluded.institucion_administradora,
  superficie_m2 = excluded.superficie_m2, estado_conservacion = excluded.estado_conservacion;
insert into canchas (recinto_id, nombre, tipo, superficie, techada, iluminacion)
select id, 'Cancha de baby fútbol', 'baby_futbol', null, false, false
from recintos where fuente = 'osm' and fuente_ref = 'way/200648875'
on conflict (recinto_id, nombre) do nothing;

-- Cancha de baby fútbol – Población La Laguna
insert into recintos (nombre, direccion, sector, latitud, longitud, estado, fuente, fuente_ref,
  tipo_administracion, institucion_administradora, superficie_m2, estado_conservacion, descripcion)
values ('Cancha de baby fútbol – Población La Laguna', null, 'Población La Laguna', -33.056696, -71.566465,
  'catastro', 'osm', 'way/678746675', null,
  null, null, null,
  'Datos de OpenStreetMap (© OpenStreetMap contributors). Tipo de cancha estimado por su tamaño en el mapa.')
on conflict (fuente, fuente_ref) do update set
  direccion = excluded.direccion, sector = coalesce(recintos.sector, excluded.sector),
  latitud = excluded.latitud, longitud = excluded.longitud,
  tipo_administracion = excluded.tipo_administracion,
  institucion_administradora = excluded.institucion_administradora,
  superficie_m2 = excluded.superficie_m2, estado_conservacion = excluded.estado_conservacion;
insert into canchas (recinto_id, nombre, tipo, superficie, techada, iluminacion)
select id, 'Cancha de baby fútbol', 'baby_futbol', null, false, false
from recintos where fuente = 'osm' and fuente_ref = 'way/678746675'
on conflict (recinto_id, nombre) do nothing;

-- Cancha de baby fútbol – Quebrada Verde
insert into recintos (nombre, direccion, sector, latitud, longitud, estado, fuente, fuente_ref,
  tipo_administracion, institucion_administradora, superficie_m2, estado_conservacion, descripcion)
values ('Cancha de baby fútbol – Quebrada Verde', null, 'Quebrada Verde', -33.084345, -71.650254,
  'catastro', 'osm', 'way/531275394', null,
  null, null, null,
  'Datos de OpenStreetMap (© OpenStreetMap contributors). Tipo de cancha estimado por su tamaño en el mapa.')
on conflict (fuente, fuente_ref) do update set
  direccion = excluded.direccion, sector = coalesce(recintos.sector, excluded.sector),
  latitud = excluded.latitud, longitud = excluded.longitud,
  tipo_administracion = excluded.tipo_administracion,
  institucion_administradora = excluded.institucion_administradora,
  superficie_m2 = excluded.superficie_m2, estado_conservacion = excluded.estado_conservacion;
insert into canchas (recinto_id, nombre, tipo, superficie, techada, iluminacion)
select id, 'Cancha de baby fútbol', 'baby_futbol', null, false, false
from recintos where fuente = 'osm' and fuente_ref = 'way/531275394'
on conflict (recinto_id, nombre) do nothing;

-- Cancha de baby fútbol – Quinto Sector
insert into recintos (nombre, direccion, sector, latitud, longitud, estado, fuente, fuente_ref,
  tipo_administracion, institucion_administradora, superficie_m2, estado_conservacion, descripcion)
values ('Cancha de baby fútbol – Quinto Sector', null, 'Quinto Sector', -33.047989, -71.65403,
  'catastro', 'osm', 'way/1395824103', null,
  null, null, null,
  'Datos de OpenStreetMap (© OpenStreetMap contributors). Tipo de cancha estimado por su tamaño en el mapa.')
on conflict (fuente, fuente_ref) do update set
  direccion = excluded.direccion, sector = coalesce(recintos.sector, excluded.sector),
  latitud = excluded.latitud, longitud = excluded.longitud,
  tipo_administracion = excluded.tipo_administracion,
  institucion_administradora = excluded.institucion_administradora,
  superficie_m2 = excluded.superficie_m2, estado_conservacion = excluded.estado_conservacion;
insert into canchas (recinto_id, nombre, tipo, superficie, techada, iluminacion)
select id, 'Cancha de baby fútbol', 'baby_futbol', 'tierra', false, true
from recintos where fuente = 'osm' and fuente_ref = 'way/1395824103'
on conflict (recinto_id, nombre) do nothing;

-- Cancha de baby fútbol – Villa Cardenal Samoré
insert into recintos (nombre, direccion, sector, latitud, longitud, estado, fuente, fuente_ref,
  tipo_administracion, institucion_administradora, superficie_m2, estado_conservacion, descripcion)
values ('Cancha de baby fútbol – Villa Cardenal Samoré', null, 'Villa Cardenal Samoré', -33.114253, -71.578016,
  'catastro', 'osm', 'way/1543347521', null,
  null, null, null,
  'Datos de OpenStreetMap (© OpenStreetMap contributors). Tipo de cancha estimado por su tamaño en el mapa.')
on conflict (fuente, fuente_ref) do update set
  direccion = excluded.direccion, sector = coalesce(recintos.sector, excluded.sector),
  latitud = excluded.latitud, longitud = excluded.longitud,
  tipo_administracion = excluded.tipo_administracion,
  institucion_administradora = excluded.institucion_administradora,
  superficie_m2 = excluded.superficie_m2, estado_conservacion = excluded.estado_conservacion;
insert into canchas (recinto_id, nombre, tipo, superficie, techada, iluminacion)
select id, 'Cancha de baby fútbol 1', 'baby_futbol', null, false, false
from recintos where fuente = 'osm' and fuente_ref = 'way/1543347521'
on conflict (recinto_id, nombre) do nothing;
insert into canchas (recinto_id, nombre, tipo, superficie, techada, iluminacion)
select id, 'Cancha de baby fútbol 2', 'baby_futbol', null, false, false
from recintos where fuente = 'osm' and fuente_ref = 'way/1543347521'
on conflict (recinto_id, nombre) do nothing;

-- Cancha de baby fútbol – Villa Fundadores
insert into recintos (nombre, direccion, sector, latitud, longitud, estado, fuente, fuente_ref,
  tipo_administracion, institucion_administradora, superficie_m2, estado_conservacion, descripcion)
values ('Cancha de baby fútbol – Villa Fundadores', null, 'Villa Fundadores', -33.120938, -71.571393,
  'catastro', 'osm', 'way/448964072', null,
  null, null, null,
  'Datos de OpenStreetMap (© OpenStreetMap contributors). Tipo de cancha estimado por su tamaño en el mapa.')
on conflict (fuente, fuente_ref) do update set
  direccion = excluded.direccion, sector = coalesce(recintos.sector, excluded.sector),
  latitud = excluded.latitud, longitud = excluded.longitud,
  tipo_administracion = excluded.tipo_administracion,
  institucion_administradora = excluded.institucion_administradora,
  superficie_m2 = excluded.superficie_m2, estado_conservacion = excluded.estado_conservacion;
insert into canchas (recinto_id, nombre, tipo, superficie, techada, iluminacion)
select id, 'Cancha de baby fútbol', 'baby_futbol', null, false, false
from recintos where fuente = 'osm' and fuente_ref = 'way/448964072'
on conflict (recinto_id, nombre) do nothing;

-- Cancha de baby fútbol – Villa Mauricio Rugendas
insert into recintos (nombre, direccion, sector, latitud, longitud, estado, fuente, fuente_ref,
  tipo_administracion, institucion_administradora, superficie_m2, estado_conservacion, descripcion)
values ('Cancha de baby fútbol – Villa Mauricio Rugendas', null, 'Villa Mauricio Rugendas', -33.115897, -71.576984,
  'catastro', 'osm', 'way/1309531568', null,
  null, null, null,
  'Datos de OpenStreetMap (© OpenStreetMap contributors). Tipo de cancha estimado por su tamaño en el mapa.')
on conflict (fuente, fuente_ref) do update set
  direccion = excluded.direccion, sector = coalesce(recintos.sector, excluded.sector),
  latitud = excluded.latitud, longitud = excluded.longitud,
  tipo_administracion = excluded.tipo_administracion,
  institucion_administradora = excluded.institucion_administradora,
  superficie_m2 = excluded.superficie_m2, estado_conservacion = excluded.estado_conservacion;
insert into canchas (recinto_id, nombre, tipo, superficie, techada, iluminacion)
select id, 'Cancha de baby fútbol', 'baby_futbol', null, false, false
from recintos where fuente = 'osm' and fuente_ref = 'way/1309531568'
on conflict (recinto_id, nombre) do nothing;

-- Cancha de baby fútbol – Villa Rapa Nui
insert into recintos (nombre, direccion, sector, latitud, longitud, estado, fuente, fuente_ref,
  tipo_administracion, institucion_administradora, superficie_m2, estado_conservacion, descripcion)
values ('Cancha de baby fútbol – Villa Rapa Nui', null, 'Villa Rapa Nui', -33.064313, -71.577393,
  'catastro', 'osm', 'way/91832891', null,
  null, null, null,
  'Datos de OpenStreetMap (© OpenStreetMap contributors). Tipo de cancha estimado por su tamaño en el mapa.')
on conflict (fuente, fuente_ref) do update set
  direccion = excluded.direccion, sector = coalesce(recintos.sector, excluded.sector),
  latitud = excluded.latitud, longitud = excluded.longitud,
  tipo_administracion = excluded.tipo_administracion,
  institucion_administradora = excluded.institucion_administradora,
  superficie_m2 = excluded.superficie_m2, estado_conservacion = excluded.estado_conservacion;
insert into canchas (recinto_id, nombre, tipo, superficie, techada, iluminacion)
select id, 'Cancha de baby fútbol', 'baby_futbol', null, false, false
from recintos where fuente = 'osm' and fuente_ref = 'way/91832891'
on conflict (recinto_id, nombre) do nothing;

-- Cancha de baby fútbol – Villa Spencer
insert into recintos (nombre, direccion, sector, latitud, longitud, estado, fuente, fuente_ref,
  tipo_administracion, institucion_administradora, superficie_m2, estado_conservacion, descripcion)
values ('Cancha de baby fútbol – Villa Spencer', null, 'Villa Spencer', -33.064069, -71.598121,
  'catastro', 'osm', 'way/274419419', null,
  null, null, null,
  'Datos de OpenStreetMap (© OpenStreetMap contributors). Tipo de cancha estimado por su tamaño en el mapa.')
on conflict (fuente, fuente_ref) do update set
  direccion = excluded.direccion, sector = coalesce(recintos.sector, excluded.sector),
  latitud = excluded.latitud, longitud = excluded.longitud,
  tipo_administracion = excluded.tipo_administracion,
  institucion_administradora = excluded.institucion_administradora,
  superficie_m2 = excluded.superficie_m2, estado_conservacion = excluded.estado_conservacion;
insert into canchas (recinto_id, nombre, tipo, superficie, techada, iluminacion)
select id, 'Cancha de baby fútbol', 'baby_futbol', null, false, false
from recintos where fuente = 'osm' and fuente_ref = 'way/274419419'
on conflict (recinto_id, nombre) do nothing;

-- Cancha de fútbol
insert into recintos (nombre, direccion, sector, latitud, longitud, estado, fuente, fuente_ref,
  tipo_administracion, institucion_administradora, superficie_m2, estado_conservacion, descripcion)
values ('Cancha de fútbol', null, 'Llanos de Curauma', -33.126658, -71.573018,
  'catastro', 'osm', 'way/220341639', null,
  null, null, null,
  'Datos de OpenStreetMap (© OpenStreetMap contributors). Tipo de cancha estimado por su tamaño en el mapa.')
on conflict (fuente, fuente_ref) do update set
  direccion = excluded.direccion, sector = coalesce(recintos.sector, excluded.sector),
  latitud = excluded.latitud, longitud = excluded.longitud,
  tipo_administracion = excluded.tipo_administracion,
  institucion_administradora = excluded.institucion_administradora,
  superficie_m2 = excluded.superficie_m2, estado_conservacion = excluded.estado_conservacion;
insert into canchas (recinto_id, nombre, tipo, superficie, techada, iluminacion)
select id, 'Cancha de baby fútbol', 'baby_futbol', null, false, false
from recintos where fuente = 'osm' and fuente_ref = 'way/220341639'
on conflict (recinto_id, nombre) do nothing;

-- Cancha de fútbol 7 – Alto del Puerto
insert into recintos (nombre, direccion, sector, latitud, longitud, estado, fuente, fuente_ref,
  tipo_administracion, institucion_administradora, superficie_m2, estado_conservacion, descripcion)
values ('Cancha de fútbol 7 – Alto del Puerto', null, 'Alto del Puerto', -33.100891, -71.582362,
  'catastro', 'osm', 'way/274847373', null,
  null, null, null,
  'Datos de OpenStreetMap (© OpenStreetMap contributors). Tipo de cancha estimado por su tamaño en el mapa.')
on conflict (fuente, fuente_ref) do update set
  direccion = excluded.direccion, sector = coalesce(recintos.sector, excluded.sector),
  latitud = excluded.latitud, longitud = excluded.longitud,
  tipo_administracion = excluded.tipo_administracion,
  institucion_administradora = excluded.institucion_administradora,
  superficie_m2 = excluded.superficie_m2, estado_conservacion = excluded.estado_conservacion;
insert into canchas (recinto_id, nombre, tipo, superficie, techada, iluminacion)
select id, 'Cancha de fútbol 7 1', 'futbol_7', null, false, false
from recintos where fuente = 'osm' and fuente_ref = 'way/274847373'
on conflict (recinto_id, nombre) do nothing;
insert into canchas (recinto_id, nombre, tipo, superficie, techada, iluminacion)
select id, 'Cancha de fútbol 7 2', 'futbol_7', null, false, false
from recintos where fuente = 'osm' and fuente_ref = 'way/274847373'
on conflict (recinto_id, nombre) do nothing;

-- Cancha de fútbol 7 – Pinares de Curauma
insert into recintos (nombre, direccion, sector, latitud, longitud, estado, fuente, fuente_ref,
  tipo_administracion, institucion_administradora, superficie_m2, estado_conservacion, descripcion)
values ('Cancha de fútbol 7 – Pinares de Curauma', null, 'Pinares de Curauma', -33.13729, -71.564371,
  'catastro', 'osm', 'way/448963906', null,
  null, null, null,
  'Datos de OpenStreetMap (© OpenStreetMap contributors). Tipo de cancha estimado por su tamaño en el mapa.')
on conflict (fuente, fuente_ref) do update set
  direccion = excluded.direccion, sector = coalesce(recintos.sector, excluded.sector),
  latitud = excluded.latitud, longitud = excluded.longitud,
  tipo_administracion = excluded.tipo_administracion,
  institucion_administradora = excluded.institucion_administradora,
  superficie_m2 = excluded.superficie_m2, estado_conservacion = excluded.estado_conservacion;
insert into canchas (recinto_id, nombre, tipo, superficie, techada, iluminacion)
select id, 'Cancha de fútbol 7', 'futbol_7', null, false, false
from recintos where fuente = 'osm' and fuente_ref = 'way/448963906'
on conflict (recinto_id, nombre) do nothing;

-- Cancha de fútbol 7 – Población Bueras
insert into recintos (nombre, direccion, sector, latitud, longitud, estado, fuente, fuente_ref,
  tipo_administracion, institucion_administradora, superficie_m2, estado_conservacion, descripcion)
values ('Cancha de fútbol 7 – Población Bueras', null, 'Población Bueras', -33.026402, -71.634391,
  'catastro', 'osm', 'way/428800762', null,
  null, null, null,
  'Datos de OpenStreetMap (© OpenStreetMap contributors). Tipo de cancha estimado por su tamaño en el mapa.')
on conflict (fuente, fuente_ref) do update set
  direccion = excluded.direccion, sector = coalesce(recintos.sector, excluded.sector),
  latitud = excluded.latitud, longitud = excluded.longitud,
  tipo_administracion = excluded.tipo_administracion,
  institucion_administradora = excluded.institucion_administradora,
  superficie_m2 = excluded.superficie_m2, estado_conservacion = excluded.estado_conservacion;
insert into canchas (recinto_id, nombre, tipo, superficie, techada, iluminacion)
select id, 'Cancha de fútbol 7', 'futbol_7', null, false, false
from recintos where fuente = 'osm' and fuente_ref = 'way/428800762'
on conflict (recinto_id, nombre) do nothing;

-- Cancha de fútbol – Cerro La Cruz
insert into recintos (nombre, direccion, sector, latitud, longitud, estado, fuente, fuente_ref,
  tipo_administracion, institucion_administradora, superficie_m2, estado_conservacion, descripcion)
values ('Cancha de fútbol – Cerro La Cruz', null, 'Cerro La Cruz', -33.059941, -71.612165,
  'catastro', 'osm', 'way/273899026', null,
  null, null, null,
  'Datos de OpenStreetMap (© OpenStreetMap contributors). Tipo de cancha estimado por su tamaño en el mapa.')
on conflict (fuente, fuente_ref) do update set
  direccion = excluded.direccion, sector = coalesce(recintos.sector, excluded.sector),
  latitud = excluded.latitud, longitud = excluded.longitud,
  tipo_administracion = excluded.tipo_administracion,
  institucion_administradora = excluded.institucion_administradora,
  superficie_m2 = excluded.superficie_m2, estado_conservacion = excluded.estado_conservacion;
insert into canchas (recinto_id, nombre, tipo, superficie, techada, iluminacion)
select id, 'Cancha de fútbol', 'futbol_11', null, false, false
from recintos where fuente = 'osm' and fuente_ref = 'way/273899026'
on conflict (recinto_id, nombre) do nothing;

-- Cancha de fútbol – Lomas de Curauma
insert into recintos (nombre, direccion, sector, latitud, longitud, estado, fuente, fuente_ref,
  tipo_administracion, institucion_administradora, superficie_m2, estado_conservacion, descripcion)
values ('Cancha de fútbol – Lomas de Curauma', null, 'Lomas de Curauma', -33.148253, -71.565613,
  'catastro', 'osm', 'way/1384790972', null,
  null, null, null,
  'Datos de OpenStreetMap (© OpenStreetMap contributors). Tipo de cancha estimado por su tamaño en el mapa.')
on conflict (fuente, fuente_ref) do update set
  direccion = excluded.direccion, sector = coalesce(recintos.sector, excluded.sector),
  latitud = excluded.latitud, longitud = excluded.longitud,
  tipo_administracion = excluded.tipo_administracion,
  institucion_administradora = excluded.institucion_administradora,
  superficie_m2 = excluded.superficie_m2, estado_conservacion = excluded.estado_conservacion;
insert into canchas (recinto_id, nombre, tipo, superficie, techada, iluminacion)
select id, 'Cancha de fútbol', 'futbol_11', null, false, false
from recintos where fuente = 'osm' and fuente_ref = 'way/1384790972'
on conflict (recinto_id, nombre) do nothing;

-- Cancha de fútbol – Lomas de Curauma (2)
insert into recintos (nombre, direccion, sector, latitud, longitud, estado, fuente, fuente_ref,
  tipo_administracion, institucion_administradora, superficie_m2, estado_conservacion, descripcion)
values ('Cancha de fútbol – Lomas de Curauma (2)', null, 'Lomas de Curauma', -33.148855, -71.557395,
  'catastro', 'osm', 'way/312811541', null,
  null, null, null,
  'Datos de OpenStreetMap (© OpenStreetMap contributors). Tipo de cancha estimado por su tamaño en el mapa.')
on conflict (fuente, fuente_ref) do update set
  direccion = excluded.direccion, sector = coalesce(recintos.sector, excluded.sector),
  latitud = excluded.latitud, longitud = excluded.longitud,
  tipo_administracion = excluded.tipo_administracion,
  institucion_administradora = excluded.institucion_administradora,
  superficie_m2 = excluded.superficie_m2, estado_conservacion = excluded.estado_conservacion;
insert into canchas (recinto_id, nombre, tipo, superficie, techada, iluminacion)
select id, 'Cancha de fútbol', 'futbol_11', null, false, false
from recintos where fuente = 'osm' and fuente_ref = 'way/312811541'
on conflict (recinto_id, nombre) do nothing;

-- Cancha de fútbol – Villa Mauricio Rugendas
insert into recintos (nombre, direccion, sector, latitud, longitud, estado, fuente, fuente_ref,
  tipo_administracion, institucion_administradora, superficie_m2, estado_conservacion, descripcion)
values ('Cancha de fútbol – Villa Mauricio Rugendas', null, 'Villa Mauricio Rugendas', -33.116778, -71.571614,
  'catastro', 'osm', 'way/490516533', null,
  null, null, null,
  'Datos de OpenStreetMap (© OpenStreetMap contributors). Tipo de cancha estimado por su tamaño en el mapa.')
on conflict (fuente, fuente_ref) do update set
  direccion = excluded.direccion, sector = coalesce(recintos.sector, excluded.sector),
  latitud = excluded.latitud, longitud = excluded.longitud,
  tipo_administracion = excluded.tipo_administracion,
  institucion_administradora = excluded.institucion_administradora,
  superficie_m2 = excluded.superficie_m2, estado_conservacion = excluded.estado_conservacion;
insert into canchas (recinto_id, nombre, tipo, superficie, techada, iluminacion)
select id, 'Cancha de fútbol', 'futbol_11', 'pasto_sintetico', false, true
from recintos where fuente = 'osm' and fuente_ref = 'way/490516533'
on conflict (recinto_id, nombre) do nothing;

-- Cancha techada del Orompollo
insert into recintos (nombre, direccion, sector, latitud, longitud, estado, fuente, fuente_ref,
  tipo_administracion, institucion_administradora, superficie_m2, estado_conservacion, descripcion)
values ('Cancha techada del Orompollo', null, 'Población Cuatro Luces', -33.03186, -71.586346,
  'catastro', 'osm', 'way/1557358979', null,
  null, null, null,
  'Datos de OpenStreetMap (© OpenStreetMap contributors). Tipo de cancha estimado por su tamaño en el mapa.')
on conflict (fuente, fuente_ref) do update set
  direccion = excluded.direccion, sector = coalesce(recintos.sector, excluded.sector),
  latitud = excluded.latitud, longitud = excluded.longitud,
  tipo_administracion = excluded.tipo_administracion,
  institucion_administradora = excluded.institucion_administradora,
  superficie_m2 = excluded.superficie_m2, estado_conservacion = excluded.estado_conservacion;
insert into canchas (recinto_id, nombre, tipo, superficie, techada, iluminacion)
select id, 'Multicancha', 'multicancha', null, true, false
from recintos where fuente = 'osm' and fuente_ref = 'way/1557358979'
on conflict (recinto_id, nombre) do nothing;

-- Canchas Santos Ossa
insert into recintos (nombre, direccion, sector, latitud, longitud, estado, fuente, fuente_ref,
  tipo_administracion, institucion_administradora, superficie_m2, estado_conservacion, descripcion)
values ('Canchas Santos Ossa', null, 'Bosque Inglés', -33.057517, -71.585073,
  'catastro', 'osm', 'node/11004966870', null,
  null, null, null,
  'Datos de OpenStreetMap (© OpenStreetMap contributors). Tipo de cancha estimado por su tamaño en el mapa.')
on conflict (fuente, fuente_ref) do update set
  direccion = excluded.direccion, sector = coalesce(recintos.sector, excluded.sector),
  latitud = excluded.latitud, longitud = excluded.longitud,
  tipo_administracion = excluded.tipo_administracion,
  institucion_administradora = excluded.institucion_administradora,
  superficie_m2 = excluded.superficie_m2, estado_conservacion = excluded.estado_conservacion;
insert into canchas (recinto_id, nombre, tipo, superficie, techada, iluminacion)
select id, 'Cancha de baby fútbol 1', 'baby_futbol', null, false, false
from recintos where fuente = 'osm' and fuente_ref = 'node/11004966870'
on conflict (recinto_id, nombre) do nothing;
insert into canchas (recinto_id, nombre, tipo, superficie, techada, iluminacion)
select id, 'Cancha de baby fútbol 2', 'baby_futbol', null, false, false
from recintos where fuente = 'osm' and fuente_ref = 'node/11004966870'
on conflict (recinto_id, nombre) do nothing;
insert into canchas (recinto_id, nombre, tipo, superficie, techada, iluminacion)
select id, 'Cancha de baby fútbol 3', 'baby_futbol', null, false, false
from recintos where fuente = 'osm' and fuente_ref = 'node/11004966870'
on conflict (recinto_id, nombre) do nothing;

-- Centro Deportivo Bosque Chacarilla
insert into recintos (nombre, direccion, sector, latitud, longitud, estado, fuente, fuente_ref,
  tipo_administracion, institucion_administradora, superficie_m2, estado_conservacion, descripcion)
values ('Centro Deportivo Bosque Chacarilla', null, 'Las Tablas', -33.161445, -71.552589,
  'catastro', 'osm', 'way/1534728297', null,
  null, null, null,
  'Datos de OpenStreetMap (© OpenStreetMap contributors). Tipo de cancha estimado por su tamaño en el mapa.')
on conflict (fuente, fuente_ref) do update set
  direccion = excluded.direccion, sector = coalesce(recintos.sector, excluded.sector),
  latitud = excluded.latitud, longitud = excluded.longitud,
  tipo_administracion = excluded.tipo_administracion,
  institucion_administradora = excluded.institucion_administradora,
  superficie_m2 = excluded.superficie_m2, estado_conservacion = excluded.estado_conservacion;
insert into canchas (recinto_id, nombre, tipo, superficie, techada, iluminacion)
select id, 'Cancha de fútbol', 'futbol_11', null, false, false
from recintos where fuente = 'osm' and fuente_ref = 'way/1534728297'
on conflict (recinto_id, nombre) do nothing;

-- Club de Campo Don Elías Figueroa
insert into recintos (nombre, direccion, sector, latitud, longitud, estado, fuente, fuente_ref,
  tipo_administracion, institucion_administradora, superficie_m2, estado_conservacion, descripcion)
values ('Club de Campo Don Elías Figueroa', null, 'San Roque', -33.06365, -71.583654,
  'catastro', 'osm', 'way/242991020', null,
  null, null, null,
  'Datos de OpenStreetMap (© OpenStreetMap contributors). Tipo de cancha estimado por su tamaño en el mapa.')
on conflict (fuente, fuente_ref) do update set
  direccion = excluded.direccion, sector = coalesce(recintos.sector, excluded.sector),
  latitud = excluded.latitud, longitud = excluded.longitud,
  tipo_administracion = excluded.tipo_administracion,
  institucion_administradora = excluded.institucion_administradora,
  superficie_m2 = excluded.superficie_m2, estado_conservacion = excluded.estado_conservacion;
insert into canchas (recinto_id, nombre, tipo, superficie, techada, iluminacion)
select id, 'Cancha de baby fútbol 1', 'baby_futbol', null, false, false
from recintos where fuente = 'osm' and fuente_ref = 'way/242991020'
on conflict (recinto_id, nombre) do nothing;
insert into canchas (recinto_id, nombre, tipo, superficie, techada, iluminacion)
select id, 'Cancha de baby fútbol 2', 'baby_futbol', null, false, false
from recintos where fuente = 'osm' and fuente_ref = 'way/242991020'
on conflict (recinto_id, nombre) do nothing;

-- Complejo Deportivo Santa Laura
insert into recintos (nombre, direccion, sector, latitud, longitud, estado, fuente, fuente_ref,
  tipo_administracion, institucion_administradora, superficie_m2, estado_conservacion, descripcion)
values ('Complejo Deportivo Santa Laura', null, 'Pinares de Curauma', -33.139276, -71.564651,
  'catastro', 'osm', 'way/806930944', null,
  null, null, null,
  'Datos de OpenStreetMap (© OpenStreetMap contributors). Tipo de cancha estimado por su tamaño en el mapa.')
on conflict (fuente, fuente_ref) do update set
  direccion = excluded.direccion, sector = coalesce(recintos.sector, excluded.sector),
  latitud = excluded.latitud, longitud = excluded.longitud,
  tipo_administracion = excluded.tipo_administracion,
  institucion_administradora = excluded.institucion_administradora,
  superficie_m2 = excluded.superficie_m2, estado_conservacion = excluded.estado_conservacion;
insert into canchas (recinto_id, nombre, tipo, superficie, techada, iluminacion)
select id, 'Cancha de baby fútbol 1', 'baby_futbol', null, false, false
from recintos where fuente = 'osm' and fuente_ref = 'way/806930944'
on conflict (recinto_id, nombre) do nothing;
insert into canchas (recinto_id, nombre, tipo, superficie, techada, iluminacion)
select id, 'Cancha de baby fútbol 2', 'baby_futbol', null, false, false
from recintos where fuente = 'osm' and fuente_ref = 'way/806930944'
on conflict (recinto_id, nombre) do nothing;
insert into canchas (recinto_id, nombre, tipo, superficie, techada, iluminacion)
select id, 'Cancha de baby fútbol 3', 'baby_futbol', null, false, false
from recintos where fuente = 'osm' and fuente_ref = 'way/806930944'
on conflict (recinto_id, nombre) do nothing;
insert into canchas (recinto_id, nombre, tipo, superficie, techada, iluminacion)
select id, 'Cancha de baby fútbol 4', 'baby_futbol', null, false, false
from recintos where fuente = 'osm' and fuente_ref = 'way/806930944'
on conflict (recinto_id, nombre) do nothing;

-- Guillermo Bravo
insert into recintos (nombre, direccion, sector, latitud, longitud, estado, fuente, fuente_ref,
  tipo_administracion, institucion_administradora, superficie_m2, estado_conservacion, descripcion)
values ('Guillermo Bravo', null, 'Cerro Chaparro', -33.045091, -71.637175,
  'catastro', 'osm', 'way/196347396', null,
  null, null, null,
  'Datos de OpenStreetMap (© OpenStreetMap contributors). Tipo de cancha estimado por su tamaño en el mapa.')
on conflict (fuente, fuente_ref) do update set
  direccion = excluded.direccion, sector = coalesce(recintos.sector, excluded.sector),
  latitud = excluded.latitud, longitud = excluded.longitud,
  tipo_administracion = excluded.tipo_administracion,
  institucion_administradora = excluded.institucion_administradora,
  superficie_m2 = excluded.superficie_m2, estado_conservacion = excluded.estado_conservacion;
insert into canchas (recinto_id, nombre, tipo, superficie, techada, iluminacion)
select id, 'Cancha de fútbol', 'futbol_11', null, false, false
from recintos where fuente = 'osm' and fuente_ref = 'way/196347396'
on conflict (recinto_id, nombre) do nothing;

-- Habivalp
insert into recintos (nombre, direccion, sector, latitud, longitud, estado, fuente, fuente_ref,
  tipo_administracion, institucion_administradora, superficie_m2, estado_conservacion, descripcion)
values ('Habivalp', null, 'Cerro Artillería', -33.031388, -71.632359,
  'catastro', 'osm', 'way/27126304', null,
  null, null, null,
  'Datos de OpenStreetMap (© OpenStreetMap contributors). Tipo de cancha estimado por su tamaño en el mapa.')
on conflict (fuente, fuente_ref) do update set
  direccion = excluded.direccion, sector = coalesce(recintos.sector, excluded.sector),
  latitud = excluded.latitud, longitud = excluded.longitud,
  tipo_administracion = excluded.tipo_administracion,
  institucion_administradora = excluded.institucion_administradora,
  superficie_m2 = excluded.superficie_m2, estado_conservacion = excluded.estado_conservacion;
insert into canchas (recinto_id, nombre, tipo, superficie, techada, iluminacion)
select id, 'Cancha de fútbol', 'futbol_11', null, false, false
from recintos where fuente = 'osm' and fuente_ref = 'way/27126304'
on conflict (recinto_id, nombre) do nothing;

-- La Cancha
insert into recintos (nombre, direccion, sector, latitud, longitud, estado, fuente, fuente_ref,
  tipo_administracion, institucion_administradora, superficie_m2, estado_conservacion, descripcion)
values ('La Cancha', null, 'Pacífico', -33.029485, -71.643094,
  'catastro', 'osm', 'way/96300612', null,
  null, null, null,
  'Datos de OpenStreetMap (© OpenStreetMap contributors). Tipo de cancha estimado por su tamaño en el mapa.')
on conflict (fuente, fuente_ref) do update set
  direccion = excluded.direccion, sector = coalesce(recintos.sector, excluded.sector),
  latitud = excluded.latitud, longitud = excluded.longitud,
  tipo_administracion = excluded.tipo_administracion,
  institucion_administradora = excluded.institucion_administradora,
  superficie_m2 = excluded.superficie_m2, estado_conservacion = excluded.estado_conservacion;
insert into canchas (recinto_id, nombre, tipo, superficie, techada, iluminacion)
select id, 'Multicancha', 'multicancha', null, false, false
from recintos where fuente = 'osm' and fuente_ref = 'way/96300612'
on conflict (recinto_id, nombre) do nothing;

-- Multicancha Plaza La Conquista
insert into recintos (nombre, direccion, sector, latitud, longitud, estado, fuente, fuente_ref,
  tipo_administracion, institucion_administradora, superficie_m2, estado_conservacion, descripcion)
values ('Multicancha Plaza La Conquista', null, 'Placeres Bajo', -33.040007, -71.590386,
  'catastro', 'osm', 'way/605638545', null,
  null, null, null,
  'Datos de OpenStreetMap (© OpenStreetMap contributors). Tipo de cancha estimado por su tamaño en el mapa.')
on conflict (fuente, fuente_ref) do update set
  direccion = excluded.direccion, sector = coalesce(recintos.sector, excluded.sector),
  latitud = excluded.latitud, longitud = excluded.longitud,
  tipo_administracion = excluded.tipo_administracion,
  institucion_administradora = excluded.institucion_administradora,
  superficie_m2 = excluded.superficie_m2, estado_conservacion = excluded.estado_conservacion;
insert into canchas (recinto_id, nombre, tipo, superficie, techada, iluminacion)
select id, 'Multicancha', 'multicancha', null, false, false
from recintos where fuente = 'osm' and fuente_ref = 'way/605638545'
on conflict (recinto_id, nombre) do nothing;

-- Nueva Plaza Las Torres
insert into recintos (nombre, direccion, sector, latitud, longitud, estado, fuente, fuente_ref,
  tipo_administracion, institucion_administradora, superficie_m2, estado_conservacion, descripcion)
values ('Nueva Plaza Las Torres', null, 'Las Torres', -33.073741, -71.593485,
  'catastro', 'osm', 'way/441999329', null,
  null, null, null,
  'Datos de OpenStreetMap (© OpenStreetMap contributors). Tipo de cancha estimado por su tamaño en el mapa.')
on conflict (fuente, fuente_ref) do update set
  direccion = excluded.direccion, sector = coalesce(recintos.sector, excluded.sector),
  latitud = excluded.latitud, longitud = excluded.longitud,
  tipo_administracion = excluded.tipo_administracion,
  institucion_administradora = excluded.institucion_administradora,
  superficie_m2 = excluded.superficie_m2, estado_conservacion = excluded.estado_conservacion;
insert into canchas (recinto_id, nombre, tipo, superficie, techada, iluminacion)
select id, 'Cancha de baby fútbol', 'baby_futbol', 'baldosa', false, false
from recintos where fuente = 'osm' and fuente_ref = 'way/441999329'
on conflict (recinto_id, nombre) do nothing;

-- Parque Jack Davis
insert into recintos (nombre, direccion, sector, latitud, longitud, estado, fuente, fuente_ref,
  tipo_administracion, institucion_administradora, superficie_m2, estado_conservacion, descripcion)
values ('Parque Jack Davis', null, 'Barrio O''Higgins', -33.058423, -71.592608,
  'catastro', 'osm', 'way/165671864', null,
  null, null, null,
  'Datos de OpenStreetMap (© OpenStreetMap contributors). Tipo de cancha estimado por su tamaño en el mapa.')
on conflict (fuente, fuente_ref) do update set
  direccion = excluded.direccion, sector = coalesce(recintos.sector, excluded.sector),
  latitud = excluded.latitud, longitud = excluded.longitud,
  tipo_administracion = excluded.tipo_administracion,
  institucion_administradora = excluded.institucion_administradora,
  superficie_m2 = excluded.superficie_m2, estado_conservacion = excluded.estado_conservacion;
insert into canchas (recinto_id, nombre, tipo, superficie, techada, iluminacion)
select id, 'Cancha de fútbol', 'futbol_11', null, false, false
from recintos where fuente = 'osm' and fuente_ref = 'way/165671864'
on conflict (recinto_id, nombre) do nothing;

-- Stadio Italiano
insert into recintos (nombre, direccion, sector, latitud, longitud, estado, fuente, fuente_ref,
  tipo_administracion, institucion_administradora, superficie_m2, estado_conservacion, descripcion)
values ('Stadio Italiano', null, 'Cerro Esperanza', -33.032283, -71.583459,
  'catastro', 'osm', 'node/384844829', null,
  null, null, null,
  'Datos de OpenStreetMap (© OpenStreetMap contributors). Tipo de cancha estimado por su tamaño en el mapa.')
on conflict (fuente, fuente_ref) do update set
  direccion = excluded.direccion, sector = coalesce(recintos.sector, excluded.sector),
  latitud = excluded.latitud, longitud = excluded.longitud,
  tipo_administracion = excluded.tipo_administracion,
  institucion_administradora = excluded.institucion_administradora,
  superficie_m2 = excluded.superficie_m2, estado_conservacion = excluded.estado_conservacion;
insert into canchas (recinto_id, nombre, tipo, superficie, techada, iluminacion)
select id, 'Cancha de fútbol', 'futbol_11', null, false, false
from recintos where fuente = 'osm' and fuente_ref = 'node/384844829'
on conflict (recinto_id, nombre) do nothing;

commit;
