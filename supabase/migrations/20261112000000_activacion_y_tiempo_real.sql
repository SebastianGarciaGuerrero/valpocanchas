-- Semana 3: activar recintos por correo, cambiar su estado y tiempo real para las reservas.

-- El administrador general activa un recinto indicando el correo de la cuenta del dueño
-- (el panel no conoce los id de usuario ni puede leer auth.users).
create function activar_recinto_por_correo(p_recinto bigint, p_correo text)
returns recintos
language plpgsql security definer set search_path = public, privado as $$
declare
  v_admin uuid;
begin
  if not es_superadmin() then
    raise exception 'Solo el administrador general puede activar recintos' using hint = 'SIN_PERMISO';
  end if;

  select id into v_admin from auth.users where lower(email) = lower(trim(p_correo));

  if v_admin is null then
    raise exception 'No existe una cuenta con el correo %. Pídele que se registre primero.', trim(p_correo)
      using hint = 'NO_ENCONTRADA';
  end if;

  return activar_recinto(p_recinto, v_admin);
end $$;

-- El administrador general devuelve un recinto al catastro (deja de recibir reservas), lo oculta
-- o lo vuelve a activar si ya tiene dueño. Las reservas existentes no se tocan.
create function cambiar_estado_recinto(p_recinto bigint, p_estado estado_recinto)
returns recintos
language plpgsql security definer set search_path = public, privado as $$
declare
  v_recinto recintos;
begin
  if not es_superadmin() then
    raise exception 'Solo el administrador general puede cambiar el estado de un recinto' using hint = 'SIN_PERMISO';
  end if;

  select * into v_recinto from recintos where id = p_recinto for update;

  if v_recinto.id is null then
    raise exception 'Recinto no encontrado' using hint = 'NO_ENCONTRADA';
  end if;

  if p_estado = 'activo' and (v_recinto.admin_id is null or v_recinto.latitud is null) then
    raise exception 'Para activar un recinto primero asígnale un dueño y su ubicación' using hint = 'TRANSICION_INVALIDA';
  end if;

  update recintos set estado = p_estado where id = p_recinto returning * into v_recinto;
  return v_recinto;
end $$;

revoke execute on function activar_recinto_por_correo(bigint, text), cambiar_estado_recinto(bigint, estado_recinto)
  from public, anon;
grant execute on function activar_recinto_por_correo(bigint, text), cambiar_estado_recinto(bigint, estado_recinto)
  to authenticated;

-- Tiempo real.
-- ocupacion: con la fila completa en los eventos de borrado, la app puede filtrar por cancha
-- también cuando una hora se libera.
alter table ocupacion replica identity full;

-- reservas: el panel del dueño y "Mis reservas" se actualizan solos. Realtime respeta RLS:
-- cada quien recibe solo las filas que puede leer.
do $$
begin
  if exists (select 1 from pg_publication where pubname = 'supabase_realtime') then
    alter publication supabase_realtime add table reservas;
  end if;
end $$;
