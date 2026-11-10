-- Generado automáticamente por un script de datos/. No editar a mano: corregir el script y volver a generar.
-- Fuente: IND, solicitud de transparencia BA002T0007721. Comuna de Valparaíso.
-- Idempotente: se puede aplicar varias veces.
begin;

-- Estadio O'Higgins
insert into recintos (nombre, direccion, sector, latitud, longitud, estado, fuente, fuente_ref,
  tipo_administracion, institucion_administradora, superficie_m2, estado_conservacion, descripcion)
values ('Estadio O''Higgins', 'Av. Washington 1472 y S / N°', null, -33.057757, -71.594996,
  'catastro', 'ind', 'BA002T0007721-19-estadio-o-higgins-2-partes', 'Convenio de Administración',
  'I. Municipalidad de Valparaiso', 22689, 'R',
  'Superficie según catastro IND: Multicancha madera, cancha futbol tierra, pista atletismo tierra.')
on conflict (fuente, fuente_ref) do update set
  direccion = excluded.direccion, sector = coalesce(recintos.sector, excluded.sector),
  latitud = excluded.latitud, longitud = excluded.longitud,
  tipo_administracion = excluded.tipo_administracion,
  institucion_administradora = excluded.institucion_administradora,
  superficie_m2 = excluded.superficie_m2, estado_conservacion = excluded.estado_conservacion;
insert into canchas (recinto_id, nombre, tipo, superficie, techada, iluminacion)
select id, 'Multicancha', 'multicancha', 'madera', true, false
from recintos where fuente = 'ind' and fuente_ref = 'BA002T0007721-19-estadio-o-higgins-2-partes'
on conflict (recinto_id, nombre) do nothing;
insert into canchas (recinto_id, nombre, tipo, superficie, techada, iluminacion)
select id, 'Cancha de fútbol', 'futbol_11', 'tierra', false, false
from recintos where fuente = 'ind' and fuente_ref = 'BA002T0007721-19-estadio-o-higgins-2-partes'
on conflict (recinto_id, nombre) do nothing;

-- Cancha Luis Emilio Recabarren
insert into recintos (nombre, direccion, sector, latitud, longitud, estado, fuente, fuente_ref,
  tipo_administracion, institucion_administradora, superficie_m2, estado_conservacion, descripcion)
values ('Cancha Luis Emilio Recabarren', 'Luis E. Recabarren s/n Quebrada Verde', 'Quebrada Verde', -33.051945, -71.65109,
  'catastro', 'ind', 'BA002T0007721-21-cancha-luis-club-emilio-recabarren', 'Convenio de Administración',
  'I. Municipalidad de Valparaiso', 6590, 'R',
  'Superficie según catastro IND: CANCHA DE TIERRA.')
on conflict (fuente, fuente_ref) do update set
  direccion = excluded.direccion, sector = coalesce(recintos.sector, excluded.sector),
  latitud = excluded.latitud, longitud = excluded.longitud,
  tipo_administracion = excluded.tipo_administracion,
  institucion_administradora = excluded.institucion_administradora,
  superficie_m2 = excluded.superficie_m2, estado_conservacion = excluded.estado_conservacion;
insert into canchas (recinto_id, nombre, tipo, superficie, techada, iluminacion)
select id, 'Cancha de fútbol', 'futbol_11', 'tierra', false, false
from recintos where fuente = 'ind' and fuente_ref = 'BA002T0007721-21-cancha-luis-club-emilio-recabarren'
on conflict (recinto_id, nombre) do nothing;

-- Pobl. Héroes del Mar
insert into recintos (nombre, direccion, sector, latitud, longitud, estado, fuente, fuente_ref,
  tipo_administracion, institucion_administradora, superficie_m2, estado_conservacion, descripcion)
values ('Pobl. Héroes del Mar', 'San Fco./Avda. Matta (calle Prado s/n, Población Héroes del Mar, cerro Los Placeres)', 'Cerro Los Placeres', -33.052573, -71.560003,
  'catastro', 'ind', 'BA002T0007721-22-pobl-heroes-del-mar', 'Convenio de Administración',
  'Junta de Vecinos 143-A, Buque Escuela Esmeralda', 14552, 'M',
  'Superficie según catastro IND: Cancha de Tierra.')
on conflict (fuente, fuente_ref) do update set
  direccion = excluded.direccion, sector = coalesce(recintos.sector, excluded.sector),
  latitud = excluded.latitud, longitud = excluded.longitud,
  tipo_administracion = excluded.tipo_administracion,
  institucion_administradora = excluded.institucion_administradora,
  superficie_m2 = excluded.superficie_m2, estado_conservacion = excluded.estado_conservacion;
insert into canchas (recinto_id, nombre, tipo, superficie, techada, iluminacion)
select id, 'Cancha de fútbol', 'futbol_11', 'tierra', false, false
from recintos where fuente = 'ind' and fuente_ref = 'BA002T0007721-22-pobl-heroes-del-mar'
on conflict (recinto_id, nombre) do nothing;

-- Complejo Deportivo Alejo Barrios – Estadio Elias Figueroa
insert into recintos (nombre, direccion, sector, latitud, longitud, estado, fuente, fuente_ref,
  tipo_administracion, institucion_administradora, superficie_m2, estado_conservacion, descripcion)
values ('Complejo Deportivo Alejo Barrios – Estadio Elias Figueroa', 'Qavda Hontaneda y subida Carvallo Playa Ancha', 'Playa Ancha', -33.022099, -71.639801,
  'catastro', 'ind', 'BA002T0007721-23-estadio-elias-figueroa', 'Administración Directa IND',
  'IND', 104000, 'B',
  'Superficie según catastro IND: Cancha de Futbol pasto natural y Pista Atletica sintética.')
on conflict (fuente, fuente_ref) do update set
  direccion = excluded.direccion, sector = coalesce(recintos.sector, excluded.sector),
  latitud = excluded.latitud, longitud = excluded.longitud,
  tipo_administracion = excluded.tipo_administracion,
  institucion_administradora = excluded.institucion_administradora,
  superficie_m2 = excluded.superficie_m2, estado_conservacion = excluded.estado_conservacion;
insert into canchas (recinto_id, nombre, tipo, superficie, techada, iluminacion)
select id, 'Cancha de fútbol', 'futbol_11', 'pasto_natural', false, false
from recintos where fuente = 'ind' and fuente_ref = 'BA002T0007721-23-estadio-elias-figueroa'
on conflict (recinto_id, nombre) do nothing;

-- Complejo Deportivo Alejo Barrios – Polideportivo
insert into recintos (nombre, direccion, sector, latitud, longitud, estado, fuente, fuente_ref,
  tipo_administracion, institucion_administradora, superficie_m2, estado_conservacion, descripcion)
values ('Complejo Deportivo Alejo Barrios – Polideportivo', 'Qavda Hontaneda y subida Carvallo Playa Ancha', 'Playa Ancha', -33.020571, -71.640344,
  'catastro', 'ind', 'BA002T0007721-23-polideportivo', 'Administración Directa IND',
  'IND', 13584, 'B',
  'Superficie según catastro IND: Multicancha y piscina, salas multiuso.')
on conflict (fuente, fuente_ref) do update set
  direccion = excluded.direccion, sector = coalesce(recintos.sector, excluded.sector),
  latitud = excluded.latitud, longitud = excluded.longitud,
  tipo_administracion = excluded.tipo_administracion,
  institucion_administradora = excluded.institucion_administradora,
  superficie_m2 = excluded.superficie_m2, estado_conservacion = excluded.estado_conservacion;
insert into canchas (recinto_id, nombre, tipo, superficie, techada, iluminacion)
select id, 'Multicancha', 'multicancha', null, true, false
from recintos where fuente = 'ind' and fuente_ref = 'BA002T0007721-23-polideportivo'
on conflict (recinto_id, nombre) do nothing;

-- Complejo Deportivo Alejo Barrios – Parque Alejo Barrios
insert into recintos (nombre, direccion, sector, latitud, longitud, estado, fuente, fuente_ref,
  tipo_administracion, institucion_administradora, superficie_m2, estado_conservacion, descripcion)
values ('Complejo Deportivo Alejo Barrios – Parque Alejo Barrios', 'Av. Del Parque', null, -33.02343, -71.639198,
  'catastro', 'ind', 'BA002T0007721-23-parque-alejo-barrios', 'Administración Directa IND',
  'IND', null, 'R',
  'Superficie según catastro IND: CANCHA DE TIERRA.')
on conflict (fuente, fuente_ref) do update set
  direccion = excluded.direccion, sector = coalesce(recintos.sector, excluded.sector),
  latitud = excluded.latitud, longitud = excluded.longitud,
  tipo_administracion = excluded.tipo_administracion,
  institucion_administradora = excluded.institucion_administradora,
  superficie_m2 = excluded.superficie_m2, estado_conservacion = excluded.estado_conservacion;
insert into canchas (recinto_id, nombre, tipo, superficie, techada, iluminacion)
select id, 'Cancha de fútbol', 'futbol_11', 'tierra', false, false
from recintos where fuente = 'ind' and fuente_ref = 'BA002T0007721-23-parque-alejo-barrios'
on conflict (recinto_id, nombre) do nothing;

commit;
