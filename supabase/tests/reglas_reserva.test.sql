-- Pruebas de las reglas de negocio en la base (se corren con psql sobre una base
-- con 00_simula_supabase.sql + la migración). Cada línea "OK:" es una verificación superada.
\set ON_ERROR_STOP on
\set QUIET on
set client_min_messages = notice;
\o /dev/null

create function pg_temp.afirma(p_cond boolean, p_msg text) returns void language plpgsql as $$
begin
  if p_cond is not true then
    raise exception 'FALLA: %', p_msg;
  end if;
  raise notice 'OK: %', p_msg;
end $$;

create function pg_temp.espera_error(p_sql text, p_contiene text, p_msg text) returns void language plpgsql as $$
begin
  execute p_sql;
  raise exception 'FALLA: % (se esperaba un error y no lo hubo)', p_msg;
exception when others then
  if sqlerrm like 'FALLA:%' then
    raise;
  end if;
  if position(p_contiene in sqlerrm) = 0 then
    raise exception 'FALLA: % (error distinto: "%")', p_msg, sqlerrm;
  end if;
  raise notice 'OK: % -> "%"', p_msg, sqlerrm;
end $$;

-- Usuarios de prueba
\set super  '00000000-0000-0000-0000-000000000001'
\set dueno1 '00000000-0000-0000-0000-000000000002'
\set dueno2 '00000000-0000-0000-0000-000000000003'
\set jugA   '00000000-0000-0000-0000-00000000000a'
\set jugB   '00000000-0000-0000-0000-00000000000b'

insert into auth.users (id, email, raw_user_meta_data) values
  (:'super',  'super@valpo.test',  '{"nombre_completo": "Administración general"}'),
  (:'dueno1', 'dueno1@valpo.test', '{"nombre_completo": "Dueño Uno", "rol": "superadmin"}'),
  (:'dueno2', 'dueno2@valpo.test', '{"nombre_completo": "Dueño Dos"}'),
  (:'jugA',   'a@valpo.test',      '{"nombre_completo": "Jugador A"}'),
  (:'jugB',   'b@valpo.test',      '{"nombre_completo": "Jugador B"}');

select pg_temp.afirma((select count(*) from perfiles) = 5, 'registrarse crea el perfil automáticamente');
select pg_temp.afirma((select rol from perfiles where id = :'dueno1') = 'jugador',
  'el rol nunca se toma de los metadatos que manda el cliente');

update perfiles set rol = 'superadmin' where id = :'super';

-- Fechas de prueba en hora de Chile
select ((now() at time zone 'America/Santiago')::date + 1) as manana \gset
select ((now() at time zone 'America/Santiago')::date + 5) as en5dias \gset
select (:'manana'::date + time '19:00') at time zone 'America/Santiago' as m19,
       (:'manana'::date + time '19:30') at time zone 'America/Santiago' as m1930,
       (:'manana'::date + time '20:00') at time zone 'America/Santiago' as m20,
       (:'manana'::date + time '21:00') at time zone 'America/Santiago' as m21,
       (:'manana'::date + time '23:00') at time zone 'America/Santiago' as m23,
       (:'manana'::date + time '08:00') at time zone 'America/Santiago' as m08,
       (:'manana'::date - 2 + time '19:00') at time zone 'America/Santiago' as ayer19,
       (:'en5dias'::date + time '19:00') at time zone 'America/Santiago' as d5_19,
       (:'manana'::date + 40 + time '19:00') at time zone 'America/Santiago' as d40 \gset

-- ---------------------------------------------------------------- superadmin
set role authenticated;
select set_config('request.jwt.claim.sub', :'super', false) \g /dev/null

insert into recintos (nombre, sector, latitud, longitud, estado, fuente)
values ('Recinto Piloto', 'Playa Ancha', -33.03, -71.64, 'catastro', 'manual'),
       ('Otro Recinto', 'Cerro Alegre', -33.04, -71.62, 'catastro', 'manual'),
       ('Sin Ubicación', null, null, null, 'catastro', 'ind'),
       ('Recinto Oculto', null, -33.05, -71.60, 'oculto', 'manual');
select id as r1 from recintos where nombre = 'Recinto Piloto' \gset
select id as r2 from recintos where nombre = 'Otro Recinto' \gset
select id as r3 from recintos where nombre = 'Sin Ubicación' \gset

select pg_temp.espera_error(format('select activar_recinto(%s, %L)', :r3, :'dueno1'),
  'necesita su ubicación', 'no se activa un recinto sin ubicación en el mapa');
select activar_recinto(:r1, :'dueno1') \g /dev/null
select activar_recinto(:r2, :'dueno2') \g /dev/null
select pg_temp.afirma((select rol from perfiles where id = :'dueno1') = 'admin_recinto',
  'activar un recinto convierte al dueño en admin_recinto');

-- ---------------------------------------------------------------- dueño 1 configura
select set_config('request.jwt.claim.sub', :'dueno1', false) \g /dev/null

insert into horarios_atencion (recinto_id, dia_semana, abre, cierra)
select :r1, d, '09:00', '23:00' from generate_series(0, 6) d;
insert into canchas (recinto_id, nombre, tipo, superficie, precio_hora)
values (:r1, 'Cancha 1', 'baby_futbol', 'pasto_sintetico', 25000),
       (:r1, 'Cancha 2', 'futbol_7', 'pasto_sintetico', 40000);
select id as c1 from canchas where nombre = 'Cancha 1' \gset
select id as c2 from canchas where nombre = 'Cancha 2' \gset

select pg_temp.afirma((select count(*) from canchas where recinto_id = :r1) = 2,
  'un recinto puede tener varias canchas');
select pg_temp.espera_error(format('insert into canchas (recinto_id, nombre, tipo) values (%s, ''X'', ''futsal'')', :r2),
  'row-level security', 'un dueño no puede crear canchas en un recinto ajeno');
select pg_temp.espera_error(format('update recintos set estado = ''oculto'' where id = %s', :r1),
  'permission denied', 'un dueño no puede cambiar el estado de su recinto (solo el administrador general)');
select pg_temp.espera_error(format('delete from canchas where id = %s', :c1),
  'permission denied', 'nadie borra canchas: se desactivan');

select pg_temp.afirma((select count(*) from disponibilidad(:c1, :'manana'::date)) = 14,
  'de 09:00 a 23:00 salen 14 bloques de una hora');
select pg_temp.afirma(
  (select to_char(min(inicio) at time zone 'America/Santiago', 'HH24:MI') from disponibilidad(:c1, :'manana'::date)) = '09:00',
  'el primer bloque es a las 09:00 hora de Chile');

-- ---------------------------------------------------------------- CP-001: reserva exitosa
select set_config('request.jwt.claim.sub', :'jugA', false) \g /dev/null
select pg_temp.afirma((select estado from solicitar_reserva(:c1, :'m19')) = 'pendiente',
  'CP-001: el jugador A pide mañana 19:00 y queda pendiente de aprobación');
select pg_temp.afirma((select count(*) from ocupacion where cancha_id = :c1) = 1,
  'la ocupación pública se actualiza al instante (para el tiempo real)');

-- ---------------------------------------------------------------- jugador B
select set_config('request.jwt.claim.sub', :'jugB', false) \g /dev/null
select pg_temp.espera_error(format('select solicitar_reserva(%s, %L)', :c1, :'m19'),
  'no está disponible', 'B no puede tomar el mismo bloque');
select pg_temp.espera_error(format('select solicitar_reserva(%s, %L)', :c1, :'m1930'),
  'no está disponible', 'no se puede reservar fuera de los bloques (19:30)');
select pg_temp.espera_error(format('select solicitar_reserva(%s, %L)', :c1, :'m23'),
  'no está disponible', 'no se puede reservar después del cierre');
select pg_temp.espera_error(format('select solicitar_reserva(%s, %L)', :c1, :'m08'),
  'no está disponible', 'no se puede reservar antes de abrir');
select pg_temp.espera_error(format('select solicitar_reserva(%s, %L)', :c1, :'ayer19'),
  'no está disponible', 'no se puede reservar en el pasado');
select pg_temp.espera_error(format('select solicitar_reserva(%s, %L)', :c1, :'d40'),
  '30 días', 'no se puede reservar a más de 30 días');
select pg_temp.afirma((select count(*) from reservas) = 0,
  'B no ve las reservas de otros (privacidad)');
select pg_temp.afirma(
  (select libre from disponibilidad(:c1, :'manana'::date) where inicio = :'m19') = false
  and (select libre from disponibilidad(:c1, :'manana'::date) where inicio = :'m20') = true,
  'pero sí ve qué bloques están ocupados y cuáles libres');
select pg_temp.espera_error(
  format('insert into reservas (cancha_id, jugador_id, inicio, fin) values (%s, %L, %L, %L)', :c1, :'jugB', :'m20', :'m21'),
  'permission denied', 'nadie inserta reservas directo: solo por la función que valida');
select pg_temp.espera_error(format('update perfiles set rol = ''superadmin'' where id = %L', :'jugB'),
  'permission denied', 'un jugador no puede subirse de rol');
update perfiles set telefono = '+56 9 1234 5678' where id = :'jugB';
select pg_temp.afirma((select telefono from perfiles where id = :'jugB') is not null,
  'un jugador sí puede editar su teléfono');
select pg_temp.espera_error(format('select activar_recinto(%s, %L)', :r1, :'jugB'),
  'Solo el administrador general', 'un jugador no puede activar recintos');

-- ---------------------------------------------------------------- límite y cancelación
select set_config('request.jwt.claim.sub', :'jugA', false) \g /dev/null
select solicitar_reserva(:c1, :'m20') \g /dev/null
select solicitar_reserva(:c1, :'d5_19') \g /dev/null
select pg_temp.espera_error(format('select solicitar_reserva(%s, %L)', :c2, :'m21'),
  '3 reservas activas', 'un jugador tiene como máximo 3 reservas futuras');
select pg_temp.espera_error(format('select cancelar_reserva(id) from reservas where inicio = %L and cancha_id = %s', :'m19', :c1),
  '48 horas', 'no se puede cancelar con menos de 48 horas');
select pg_temp.afirma(
  (select r.estado from reservas x, cancelar_reserva(x.id) r where x.inicio = :'d5_19' and x.cancha_id = :c1) = 'cancelada',
  'sí se puede cancelar con más de 48 horas');

select set_config('request.jwt.claim.sub', :'jugB', false) \g /dev/null
select pg_temp.afirma((select estado from solicitar_reserva(:c1, :'d5_19')) = 'pendiente',
  'una hora cancelada vuelve a quedar libre para otro jugador');
select pg_temp.espera_error(
  format('select cancelar_reserva(%s)', (select max(reserva_id) from ocupacion o where o.inicio = :'m19')),
  'Reserva no encontrada', 'B no puede cancelar la reserva de A');
select pg_temp.afirma((select count(*) from ocupacion where cancha_id = :c1) = 3,
  'la ocupación pública refleja solo reservas vivas');

-- ---------------------------------------------------------------- administración
select set_config('request.jwt.claim.sub', :'dueno2', false) \g /dev/null
select pg_temp.espera_error(
  format('select responder_reserva(%s, ''confirmada'')', (select reserva_id from ocupacion o where o.inicio = :'m19')),
  'Reserva no encontrada', 'el dueño de otro recinto no puede tocar estas reservas');
select pg_temp.afirma((select count(*) from perfiles where id = :'jugA') = 0,
  'el dueño de otro recinto no ve los datos de los jugadores');

select set_config('request.jwt.claim.sub', :'dueno1', false) \g /dev/null
select id as res_a19 from reservas where cancha_id = :c1 and inicio = :'m19' \gset
select pg_temp.afirma((select estado from responder_reserva(:res_a19, 'confirmada')) = 'confirmada',
  'el dueño confirma la solicitud');
select pg_temp.espera_error(format('select responder_reserva(%s, ''rechazada'')', :res_a19),
  'No se puede pasar', 'una confirmada no se puede rechazar');
select pg_temp.afirma((select nombre_completo from perfiles where id = :'jugA') = 'Jugador A',
  'el dueño ve el nombre de quien le reservó');
select pg_temp.espera_error(format('select bloquear_horario(%s, %L, %L, ''Mantención'')', :c1, :'m19', :'m21'),
  'Ya hay reservas', 'no se puede bloquear encima de reservas');
select pg_temp.afirma(
  (select estado from bloquear_horario(:c1, :'m21', :'m23', 'Mantención')) = 'confirmada',
  'el dueño bloquea de 21:00 a 23:00');
select pg_temp.afirma((select count(*) from disponibilidad(:c1, :'manana'::date) where libre) = 14 - 4,
  'quedan libres 10 de 14 bloques (19, 20 reservados; 21 y 22 bloqueados)');

-- ---------------------------------------------------------------- horas fijas
select extract(dow from :'manana'::date)::smallint as dow_manana \gset
select id as fijo1 from crear_horario_fijo(:c2, 'Los Galácticos', :dow_manana::smallint, '21:00',
  :'manana'::date, :'manana'::date + 27) \gset
select pg_temp.afirma(
  (select count(*) from reservas where horario_fijo_id = :fijo1 and estado = 'confirmada') = 4,
  'una hora fija de 4 semanas crea 4 reservas confirmadas');
select pg_temp.espera_error(
  format('select crear_horario_fijo(%s, %L, %s::smallint, %L, %L, %L)', :c2, 'Otro equipo', :dow_manana, '21:00',
         :'manana', (:'manana'::date + 27)::text),
  'ya está ocupado', 'una hora fija que choca no se crea');
select pg_temp.afirma((select count(*) from horarios_fijos) = 1,
  'y no deja una hora fija a medio crear');
select terminar_horario_fijo(:fijo1) \g /dev/null
select pg_temp.afirma(
  (select count(*) from reservas where horario_fijo_id = :fijo1 and estado = 'cancelada') = 4,
  'terminar la hora fija libera las semanas que no se han jugado');

-- ---------------------------------------------------------------- visitante sin sesión
reset role;
select set_config('request.jwt.claim.sub', '', false) \g /dev/null
set role anon;
select pg_temp.afirma((select count(*) from recintos) = 3,
  'sin sesión se ve el catastro (activos y no activos) pero no los ocultos');
select pg_temp.afirma((select count(*) from disponibilidad(:c1, :'manana'::date)) = 14,
  'sin sesión se ve la disponibilidad');
select pg_temp.espera_error('select count(*) from reservas', 'permission denied',
  'sin sesión no se leen reservas');
select pg_temp.espera_error(format('select solicitar_reserva(%s, %L)', :c1, :'m20'),
  'permission denied', 'sin sesión no se reserva');
reset role;

\echo 'Todas las pruebas pasaron.'
