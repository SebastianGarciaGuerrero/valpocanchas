#!/usr/bin/env bash
# CP-002: dos jugadores confirman el mismo bloque al mismo tiempo, desde dos conexiones.
# A toma el bloque y demora 3 s en confirmar; B intenta 1 s después.
# Esperado: B queda esperando a que A termine y recibe "Lo sentimos, alguien ganó esta hora".
# Uso: PSQL="psql -h host -p puerto -U postgres -d base" ./cp002_concurrencia.sh <cancha_id>
set -euo pipefail
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
CANCHA=${1:?falta el id de la cancha}
PSQL=${PSQL:-psql}
JUG_A=00000000-0000-0000-0000-00000000000a
JUG_B=00000000-0000-0000-0000-00000000000b
INICIO=$($PSQL -X -At -c "select ((now() at time zone 'America/Santiago')::date + 6 + time '20:00') at time zone 'America/Santiago'")

$PSQL -X -q -At <<SQL > "$TMP/a.txt" 2>&1 &
begin;
set role authenticated;
select set_config('request.jwt.claim.sub', '$JUG_A', true) is not null;
select 'A ' || estado || ' ' || clock_timestamp()::time(0) from solicitar_reserva($CANCHA, '$INICIO');
select pg_sleep(3) is not null;
commit;
SQL
PID_A=$!

sleep 1
T0=$(date +%s.%N)
$PSQL -X -q -At <<SQL > "$TMP/b.txt" 2>&1 || true
set role authenticated;
select set_config('request.jwt.claim.sub', '$JUG_B', false) is not null;
select 'B ' || estado from solicitar_reserva($CANCHA, '$INICIO');
SQL
T1=$(date +%s.%N)
wait $PID_A

VIVAS=$($PSQL -X -At -c "select count(*) from reservas where cancha_id = $CANCHA and inicio = '$INICIO' and estado in ('pendiente','confirmada')")
ESPERA=$(awk "BEGIN { printf \"%.1f\", $T1 - $T0 }")

echo "--- sesión A"; grep -v '^t$' "$TMP/a.txt"
echo "--- sesión B (esperó $ESPERA s)"; grep -v '^t$' "$TMP/b.txt"
echo "--- reservas vivas en ese bloque: $VIVAS"

if [ "$VIVAS" != "1" ] || ! grep -q "alguien ganó esta hora" "$TMP/b.txt"; then
  echo "CP-002 FALLÓ: se permitió una doble reserva o B no recibió el aviso"
  exit 1
fi
echo "CP-002 OK: la base impidió la doble reserva"
