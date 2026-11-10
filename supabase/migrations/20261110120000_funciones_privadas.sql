-- Las funciones internas (las de los triggers y las que usan las políticas RLS) pasan a un
-- esquema que la API de Supabase no publica: así no se pueden llamar por /rest/v1/rpc.
-- Responde a las advertencias del asesor de seguridad de Supabase.
-- Las políticas y los triggers guardan la función por su id, así que siguen funcionando.
create schema if not exists privado;
grant usage on schema privado to anon, authenticated;

alter function es_superadmin() set schema privado;
alter function administra_recinto(bigint) set schema privado;
alter function administra_cancha(bigint) set schema privado;
alter function tocar_updated_at() set schema privado;
alter function crear_perfil_nuevo_usuario() set schema privado;
alter function sincronizar_ocupacion() set schema privado;

-- search_path fijo en todas (las de ayuda se llaman entre sí, por eso incluyen privado).
alter function privado.administra_recinto(bigint) set search_path = public, privado;
alter function privado.administra_cancha(bigint) set search_path = public, privado;
alter function privado.tocar_updated_at() set search_path = '';

-- Las funciones públicas que usan las ayudas ahora también miran en privado.
alter function activar_recinto(bigint, uuid) set search_path = public, privado;
alter function bloquear_horario(bigint, timestamptz, timestamptz, text) set search_path = public, privado;
alter function crear_horario_fijo(bigint, text, smallint, time, date, date, uuid) set search_path = public, privado;
alter function responder_reserva(bigint, estado_reserva, text) set search_path = public, privado;
alter function terminar_horario_fijo(bigint) set search_path = public, privado;

-- Las de los triggers no se llaman a mano.
revoke execute on function privado.tocar_updated_at(), privado.crear_perfil_nuevo_usuario(),
  privado.sincronizar_ocupacion() from public, anon, authenticated;
