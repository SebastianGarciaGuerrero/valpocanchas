-- ValpoCanchas: esquema inicial
-- Catastro de recintos (con o sin reservas), canchas, horarios y reservas.
-- Reglas que impone la base (no solo el frontend):
--   * Sin traslapes: restricción de exclusión por rango de tiempo (ignora rechazadas y canceladas).
--   * Toda escritura en reservas pasa por funciones (RPC) que validan las reglas de negocio.
--   * Sin DELETE para los usuarios: se desactiva (activa = false / estado = 'oculto').
--   * Fechas en timestamptz; los bloques se arman en hora de Chile (America/Santiago).

create extension if not exists btree_gist;

-- ---------------------------------------------------------------------------
-- Tipos
-- ---------------------------------------------------------------------------
create type rol_usuario as enum ('jugador', 'admin_recinto', 'superadmin');
-- catastro: aparece en el mapa con su contacto, pero no recibe reservas
-- activo:   su dueño lo activó y recibe reservas por la app
-- oculto:   no aparece (equivale a borrado)
create type estado_recinto as enum ('catastro', 'activo', 'oculto');
create type tipo_cancha as enum ('futbol_11', 'futbol_7', 'baby_futbol', 'futsal', 'multicancha');
create type superficie_cancha as enum ('pasto_sintetico', 'pasto_natural', 'tierra', 'baldosa', 'madera', 'cemento', 'otra');
create type tipo_reserva as enum ('normal', 'fija', 'bloqueo');
create type estado_reserva as enum ('pendiente', 'confirmada', 'rechazada', 'cancelada');

-- ---------------------------------------------------------------------------
-- Tablas
-- ---------------------------------------------------------------------------
create table perfiles (
  id uuid primary key references auth.users (id) on delete cascade,
  nombre_completo text not null default '',
  telefono text,
  rol rol_usuario not null default 'jugador',
  created_at timestamptz not null default now()
);

create table recintos (
  id bigint generated always as identity primary key,
  nombre text not null,
  direccion text,
  sector text,                                   -- cerro o barrio: "Playa Ancha", "Cerro Los Placeres"
  comuna text not null default 'Valparaíso',
  latitud double precision check (latitud between -90 and 90),
  longitud double precision check (longitud between -180 and 180),
  estado estado_recinto not null default 'catastro',
  admin_id uuid references perfiles (id),
  telefono_contacto text,
  email_contacto text,
  sitio_web text,
  descripcion text,
  imagen_url text,
  -- origen del dato y campos del catastro
  fuente text not null default 'manual' check (fuente in ('ind', 'osm', 'municipal', 'manual')),
  fuente_ref text,                               -- id o enlace en la fuente original
  tipo_administracion text,
  institucion_administradora text,
  superficie_m2 integer check (superficie_m2 > 0),
  estado_conservacion char(1) check (estado_conservacion in ('B', 'R', 'M')),
  -- reglas de reserva del recinto
  horas_min_cancelacion integer not null default 48 check (horas_min_cancelacion >= 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint coordenadas_completas check ((latitud is null) = (longitud is null)),
  constraint activo_con_dueno_y_ubicacion
    check (estado <> 'activo' or (admin_id is not null and latitud is not null))
);

create index recintos_admin_idx on recintos (admin_id);

-- Una franja por día (0 = domingo ... 6 = sábado, como extract(dow)). Sin fila = cerrado.
create table horarios_atencion (
  recinto_id bigint not null references recintos (id),
  dia_semana smallint not null check (dia_semana between 0 and 6),
  abre time not null,
  cierra time not null,                          -- '24:00' = medianoche
  primary key (recinto_id, dia_semana),
  check (cierra > abre)
);

create table canchas (
  id bigint generated always as identity primary key,
  recinto_id bigint not null references recintos (id),
  nombre text not null,
  tipo tipo_cancha not null,
  superficie superficie_cancha,
  techada boolean not null default false,
  iluminacion boolean not null default false,
  precio_hora integer check (precio_hora >= 0),  -- pesos chilenos, sin decimales
  duracion_bloque_min smallint not null default 60 check (duracion_bloque_min in (60, 90, 120)),
  activa boolean not null default true,
  created_at timestamptz not null default now(),
  unique (recinto_id, nombre)
);

create table horarios_fijos (
  id bigint generated always as identity primary key,
  cancha_id bigint not null references canchas (id),
  titular text not null,                         -- equipo o persona que tiene la hora fija
  jugador_id uuid references perfiles (id) on delete set null,
  dia_semana smallint not null check (dia_semana between 0 and 6),
  hora_inicio time not null,
  vigente_desde date not null,
  vigente_hasta date not null,
  activo boolean not null default true,
  creado_por uuid references perfiles (id) on delete set null,
  created_at timestamptz not null default now(),
  check (vigente_hasta >= vigente_desde and vigente_hasta <= vigente_desde + 366)
);

create table reservas (
  id bigint generated always as identity primary key,
  cancha_id bigint not null references canchas (id),
  jugador_id uuid references perfiles (id) on delete set null,
  tipo tipo_reserva not null default 'normal',
  horario_fijo_id bigint references horarios_fijos (id),
  inicio timestamptz not null,
  fin timestamptz not null,
  estado estado_reserva not null default 'pendiente',
  nota text,                                     -- motivo de bloqueo, rechazo o cancelación
  creada_por uuid references perfiles (id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (fin > inicio),
  check (tipo <> 'fija' or horario_fijo_id is not null),
  -- Corazón del sistema: dos reservas vivas de la misma cancha no pueden traslaparse.
  -- Una cancelada o rechazada libera el bloque.
  constraint reservas_sin_traslape exclude using gist (
    cancha_id with =,
    tstzrange(inicio, fin, '[)') with &&
  ) where (estado in ('pendiente', 'confirmada'))
);

create index reservas_jugador_idx on reservas (jugador_id, inicio);
create index reservas_cancha_inicio_idx on reservas (cancha_id, inicio);

-- Vista pública de la ocupación (sin datos personales). La mantiene un trigger
-- y existe para que la app escuche los cambios en tiempo real con Supabase Realtime.
create table ocupacion (
  reserva_id bigint primary key references reservas (id),
  cancha_id bigint not null references canchas (id),
  inicio timestamptz not null,
  fin timestamptz not null
);

create index ocupacion_cancha_idx on ocupacion (cancha_id, inicio);

-- ---------------------------------------------------------------------------
-- Funciones de apoyo
-- ---------------------------------------------------------------------------
create function es_superadmin() returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from perfiles where id = auth.uid() and rol = 'superadmin')
$$;

create function administra_recinto(p_recinto bigint) returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from recintos where id = p_recinto and admin_id = auth.uid())
      or es_superadmin()
$$;

create function administra_cancha(p_cancha bigint) returns boolean
language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from canchas c join recintos r on r.id = c.recinto_id
    where c.id = p_cancha and r.admin_id = auth.uid()
  ) or es_superadmin()
$$;

create function tocar_updated_at() returns trigger
language plpgsql as $$
begin
  new.updated_at := now();
  return new;
end $$;

create trigger recintos_updated_at before update on recintos
  for each row execute function tocar_updated_at();
create trigger reservas_updated_at before update on reservas
  for each row execute function tocar_updated_at();

-- Perfil automático al registrarse. El rol nunca se toma de los metadatos del cliente.
create function crear_perfil_nuevo_usuario() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  insert into perfiles (id, nombre_completo, telefono)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'nombre_completo', ''),
    new.raw_user_meta_data ->> 'telefono'
  );
  return new;
end $$;

create trigger al_crear_usuario after insert on auth.users
  for each row execute function crear_perfil_nuevo_usuario();

create function sincronizar_ocupacion() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  if new.estado in ('pendiente', 'confirmada') then
    insert into ocupacion (reserva_id, cancha_id, inicio, fin)
    values (new.id, new.cancha_id, new.inicio, new.fin)
    on conflict (reserva_id) do update
      set cancha_id = excluded.cancha_id, inicio = excluded.inicio, fin = excluded.fin;
  else
    delete from ocupacion where reserva_id = new.id;
  end if;
  return null;
end $$;

create trigger reservas_ocupacion after insert or update on reservas
  for each row execute function sincronizar_ocupacion();

-- ---------------------------------------------------------------------------
-- Disponibilidad y reservas (RPC)
-- ---------------------------------------------------------------------------

-- Bloques de un día para una cancha, en hora de Chile. Solo entrega horarios, nunca quién reservó.
create function disponibilidad(p_cancha bigint, p_fecha date)
returns table (inicio timestamptz, fin timestamptz, libre boolean)
language sql stable security definer set search_path = public as $$
  with conf as (
    select c.duracion_bloque_min as dur, h.abre, h.cierra
    from canchas c
    join recintos r on r.id = c.recinto_id
    join horarios_atencion h on h.recinto_id = r.id and h.dia_semana = extract(dow from p_fecha)
    where c.id = p_cancha and c.activa and r.estado = 'activo'
  ),
  bloques as (
    select
      ((p_fecha + conf.abre + make_interval(mins => g.n * conf.dur)) at time zone 'America/Santiago') as inicio,
      ((p_fecha + conf.abre + make_interval(mins => (g.n + 1) * conf.dur)) at time zone 'America/Santiago') as fin
    from conf,
      generate_series(0, floor(extract(epoch from (conf.cierra - conf.abre)) / 60 / conf.dur)::int - 1) as g (n)
  )
  select b.inicio, b.fin,
    b.inicio > now() and not exists (
      select 1 from reservas r
      where r.cancha_id = p_cancha
        and r.estado in ('pendiente', 'confirmada')
        and tstzrange(r.inicio, r.fin, '[)') && tstzrange(b.inicio, b.fin, '[)')
    ) as libre
  from bloques b
  order by b.inicio
$$;

-- El jugador pide un bloque. Queda 'pendiente' hasta que el administrador responda.
create function solicitar_reserva(p_cancha bigint, p_inicio timestamptz)
returns reservas
language plpgsql security definer set search_path = public as $$
declare
  v_fin timestamptz;
  v_activas integer;
  v_reserva reservas;
begin
  if auth.uid() is null then
    raise exception 'Debes iniciar sesión para reservar' using hint = 'SIN_SESION';
  end if;

  if p_inicio > now() + interval '30 days' then
    raise exception 'Solo puedes reservar hasta 30 días hacia adelante' using hint = 'FUERA_DE_PLAZO';
  end if;

  select d.fin into v_fin
  from disponibilidad(p_cancha, (p_inicio at time zone 'America/Santiago')::date) d
  where d.inicio = p_inicio and d.libre;

  if v_fin is null then
    raise exception 'Ese horario no está disponible' using hint = 'NO_DISPONIBLE';
  end if;

  select count(*) into v_activas
  from reservas
  where jugador_id = auth.uid() and tipo = 'normal'
    and estado in ('pendiente', 'confirmada') and inicio > now();

  if v_activas >= 3 then
    raise exception 'Tienes 3 reservas activas; espera a jugarlas o cancela una' using hint = 'LIMITE_RESERVAS';
  end if;

  insert into reservas (cancha_id, jugador_id, tipo, inicio, fin, estado, creada_por)
  values (p_cancha, auth.uid(), 'normal', p_inicio, v_fin, 'pendiente', auth.uid())
  returning * into v_reserva;

  return v_reserva;
exception
  when exclusion_violation then
    raise exception 'Lo sentimos, alguien ganó esta hora' using hint = 'HORARIO_OCUPADO';
end $$;

-- El jugador cancela con la anticipación que fije el recinto (48 h por defecto).
create function cancelar_reserva(p_reserva bigint, p_nota text default null)
returns reservas
language plpgsql security definer set search_path = public as $$
declare
  v_reserva reservas;
  v_horas integer;
begin
  select r.* into v_reserva from reservas r where r.id = p_reserva for update;

  if v_reserva.id is null or v_reserva.jugador_id is distinct from auth.uid() then
    raise exception 'Reserva no encontrada' using hint = 'NO_ENCONTRADA';
  end if;

  if v_reserva.estado not in ('pendiente', 'confirmada') then
    raise exception 'La reserva ya no está vigente' using hint = 'NO_VIGENTE';
  end if;

  select re.horas_min_cancelacion into v_horas
  from canchas c join recintos re on re.id = c.recinto_id
  where c.id = v_reserva.cancha_id;

  if v_reserva.inicio - now() < make_interval(hours => v_horas) then
    raise exception 'Solo puedes cancelar con % horas de anticipación', v_horas using hint = 'FUERA_DE_PLAZO';
  end if;

  update reservas set estado = 'cancelada', nota = p_nota
  where id = p_reserva
  returning * into v_reserva;

  return v_reserva;
end $$;

-- El administrador confirma o rechaza una solicitud, o anula una reserva confirmada.
create function responder_reserva(p_reserva bigint, p_estado estado_reserva, p_nota text default null)
returns reservas
language plpgsql security definer set search_path = public as $$
declare
  v_reserva reservas;
begin
  select r.* into v_reserva from reservas r where r.id = p_reserva for update;

  if v_reserva.id is null or not administra_cancha(v_reserva.cancha_id) then
    raise exception 'Reserva no encontrada' using hint = 'NO_ENCONTRADA';
  end if;

  if not (
    (v_reserva.estado = 'pendiente' and p_estado in ('confirmada', 'rechazada'))
    or (v_reserva.estado = 'confirmada' and p_estado = 'cancelada')
  ) then
    raise exception 'No se puede pasar de % a %', v_reserva.estado, p_estado using hint = 'TRANSICION_INVALIDA';
  end if;

  update reservas set estado = p_estado, nota = coalesce(p_nota, nota)
  where id = p_reserva
  returning * into v_reserva;

  return v_reserva;
end $$;

-- El administrador bloquea un rango (mantención, evento). Usa la misma regla de no traslape.
create function bloquear_horario(p_cancha bigint, p_inicio timestamptz, p_fin timestamptz, p_nota text default null)
returns reservas
language plpgsql security definer set search_path = public as $$
declare
  v_reserva reservas;
begin
  if not administra_cancha(p_cancha) then
    raise exception 'Cancha no encontrada' using hint = 'NO_ENCONTRADA';
  end if;

  insert into reservas (cancha_id, tipo, inicio, fin, estado, nota, creada_por)
  values (p_cancha, 'bloqueo', p_inicio, p_fin, 'confirmada', p_nota, auth.uid())
  returning * into v_reserva;

  return v_reserva;
exception
  when exclusion_violation then
    raise exception 'Ya hay reservas en ese rango; cancélalas o rechaza antes de bloquear' using hint = 'HORARIO_OCUPADO';
end $$;

-- Hora fija semanal: crea una reserva confirmada por cada semana de la vigencia.
-- Si alguna semana choca con otra reserva, no se crea nada y se informa la fecha.
create function crear_horario_fijo(
  p_cancha bigint, p_titular text, p_dia_semana smallint, p_hora_inicio time,
  p_desde date, p_hasta date, p_jugador uuid default null
)
returns horarios_fijos
language plpgsql security definer set search_path = public as $$
declare
  v_fijo horarios_fijos;
  v_dur smallint;
  v_fecha date;
  v_inicio timestamptz;
begin
  if not administra_cancha(p_cancha) then
    raise exception 'Cancha no encontrada' using hint = 'NO_ENCONTRADA';
  end if;

  select duracion_bloque_min into v_dur from canchas where id = p_cancha;

  insert into horarios_fijos (cancha_id, titular, jugador_id, dia_semana, hora_inicio, vigente_desde, vigente_hasta, creado_por)
  values (p_cancha, p_titular, p_jugador, p_dia_semana, p_hora_inicio, p_desde, p_hasta, auth.uid())
  returning * into v_fijo;

  -- primer día de la vigencia que cae en el día de la semana pedido
  v_fecha := p_desde + ((p_dia_semana - extract(dow from p_desde)::int + 7) % 7);

  while v_fecha <= p_hasta loop
    v_inicio := (v_fecha + p_hora_inicio) at time zone 'America/Santiago';
    begin
      insert into reservas (cancha_id, jugador_id, tipo, horario_fijo_id, inicio, fin, estado, nota, creada_por)
      values (p_cancha, p_jugador, 'fija', v_fijo.id, v_inicio,
              v_inicio + make_interval(mins => v_dur), 'confirmada', p_titular, auth.uid());
    exception
      when exclusion_violation then
        raise exception 'El % a las % ya está ocupado', to_char(v_fecha, 'DD-MM-YYYY'), to_char(p_hora_inicio, 'HH24:MI')
          using hint = 'HORARIO_OCUPADO';
    end;
    v_fecha := v_fecha + 7;
  end loop;

  return v_fijo;
end $$;

-- Termina una hora fija: deja de generar y libera las semanas que aún no se juegan.
create function terminar_horario_fijo(p_fijo bigint)
returns horarios_fijos
language plpgsql security definer set search_path = public as $$
declare
  v_fijo horarios_fijos;
begin
  select * into v_fijo from horarios_fijos where id = p_fijo for update;

  if v_fijo.id is null or not administra_cancha(v_fijo.cancha_id) then
    raise exception 'Hora fija no encontrada' using hint = 'NO_ENCONTRADA';
  end if;

  update reservas set estado = 'cancelada', nota = 'Hora fija terminada'
  where horario_fijo_id = p_fijo and inicio > now() and estado in ('pendiente', 'confirmada');

  update horarios_fijos set activo = false where id = p_fijo returning * into v_fijo;
  return v_fijo;
end $$;

-- El superadministrador activa un recinto del catastro y le asigna su dueño.
create function activar_recinto(p_recinto bigint, p_admin uuid)
returns recintos
language plpgsql security definer set search_path = public as $$
declare
  v_recinto recintos;
begin
  if not es_superadmin() then
    raise exception 'Solo el administrador general puede activar recintos' using hint = 'SIN_PERMISO';
  end if;

  if exists (select 1 from recintos where id = p_recinto and latitud is null) then
    raise exception 'El recinto necesita su ubicación en el mapa antes de activarse' using hint = 'SIN_UBICACION';
  end if;

  update perfiles set rol = 'admin_recinto' where id = p_admin and rol = 'jugador';

  update recintos set estado = 'activo', admin_id = p_admin
  where id = p_recinto
  returning * into v_recinto;

  if v_recinto.id is null then
    raise exception 'Recinto no encontrado' using hint = 'NO_ENCONTRADA';
  end if;

  return v_recinto;
end $$;

-- ---------------------------------------------------------------------------
-- Permisos: nadie borra; las columnas sensibles solo cambian por funciones
-- ---------------------------------------------------------------------------
revoke all on perfiles, recintos, horarios_atencion, canchas, horarios_fijos, reservas, ocupacion
  from anon, authenticated;

grant select on recintos, canchas, horarios_atencion, ocupacion to anon, authenticated;
grant select on perfiles, horarios_fijos, reservas to authenticated;

grant update (nombre_completo, telefono) on perfiles to authenticated;
grant insert on recintos to authenticated;
grant update (nombre, direccion, sector, latitud, longitud, telefono_contacto, email_contacto,
              sitio_web, descripcion, imagen_url, horas_min_cancelacion)
  on recintos to authenticated;
grant insert, update on canchas to authenticated;
grant insert, update, delete on horarios_atencion to authenticated;

revoke execute on function activar_recinto, bloquear_horario, cancelar_reserva, crear_horario_fijo,
  responder_reserva, solicitar_reserva, terminar_horario_fijo from public, anon;
grant execute on function activar_recinto, bloquear_horario, cancelar_reserva, crear_horario_fijo,
  responder_reserva, solicitar_reserva, terminar_horario_fijo to authenticated;
grant execute on function disponibilidad to anon, authenticated;

-- ---------------------------------------------------------------------------
-- RLS
-- ---------------------------------------------------------------------------
alter table perfiles enable row level security;
alter table recintos enable row level security;
alter table horarios_atencion enable row level security;
alter table canchas enable row level security;
alter table horarios_fijos enable row level security;
alter table reservas enable row level security;
alter table ocupacion enable row level security;

create policy perfiles_ver on perfiles for select
  using (id = auth.uid() or es_superadmin()
         or exists (select 1 from reservas r join canchas c on c.id = r.cancha_id
                    join recintos re on re.id = c.recinto_id
                    where r.jugador_id = perfiles.id and re.admin_id = auth.uid()));
create policy perfiles_editar_propio on perfiles for update
  using (id = auth.uid()) with check (id = auth.uid());

create policy recintos_ver on recintos for select
  using (estado <> 'oculto' or admin_id = auth.uid() or es_superadmin());
create policy recintos_crear on recintos for insert
  with check (es_superadmin());
create policy recintos_editar on recintos for update
  using (administra_recinto(id)) with check (administra_recinto(id));

create policy horarios_ver on horarios_atencion for select using (true);
create policy horarios_escribir on horarios_atencion for all
  using (administra_recinto(recinto_id)) with check (administra_recinto(recinto_id));

create policy canchas_ver on canchas for select using (true);
create policy canchas_crear on canchas for insert with check (administra_recinto(recinto_id));
create policy canchas_editar on canchas for update
  using (administra_recinto(recinto_id)) with check (administra_recinto(recinto_id));

create policy fijos_ver on horarios_fijos for select
  using (administra_cancha(cancha_id) or jugador_id = auth.uid());

create policy reservas_ver on reservas for select
  using (jugador_id = auth.uid() or administra_cancha(cancha_id));

create policy ocupacion_ver on ocupacion for select using (true);

-- Tiempo real: la app escucha 'ocupacion' (en Supabase existe la publicación supabase_realtime).
do $$
begin
  if exists (select 1 from pg_publication where pubname = 'supabase_realtime') then
    alter publication supabase_realtime add table ocupacion;
  end if;
end $$;
