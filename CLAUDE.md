# CLAUDE.md

Guía para Claude Code en este repositorio.

## Proyecto

ValpoCanchas: proyecto de título (IACC, Técnico Superior en Informática). Catastro georreferenciado de los recintos deportivos de Valparaíso, con reservas en los recintos que su dueño activa. Se presenta con demo el 7 de diciembre de 2026. El informe ya está aprobado: el código tiene que cumplir lo que el informe promete (RF-01 a RF-05, RNF-01 a RNF-03, casos CP-001 y CP-002). Plan y alcance en `docs/PLAN.md`.

## Estructura

- `movil/`: app de jugadores. Expo (React Native) + TypeScript + Expo Router + react-native-maps (Google en Android) + TanStack Query + supabase-js. Se entrega como APK (EAS Build).
  Cuenta Expo: `zvztn`. Proyecto Supabase: `valpocanchas`.
- `admin/`: panel web para dueños y administración general. Vite + React + TypeScript + Tailwind + TanStack Query + react-leaflet (OpenStreetMap) para ubicar recintos. Se publica en Vercel.
- `supabase/migrations/`: esquema SQL escrito a mano, una migración por cambio (`AAAAMMDDHHMMSS_descripcion.sql`).
- `supabase/tests/`: pruebas de las reglas en la base. Corren en GitHub Actions (`.github/workflows/pruebas-bd.yml`).
- `datos/`: scripts de importación (catastro IND, OpenStreetMap, planilla manual) y los archivos fuente.
- `docs/`: plan y decisiones.

## Comandos

```bash
cd admin && npm install && npm run dev                     # panel web en :5173 (lee admin/.env)
cd admin && npm run build && npm run lint                  # revisar el panel
cd movil && npm install && npx expo start                  # app: escanear el QR con Expo Go (lee movil/.env)
cd movil && npx tsc --noEmit && npx expo lint              # revisar la app
python datos/importar_catastro.py                          # regenera supabase/datos/catastro_ind.sql
python datos/importar_osm.py [--descargar]                 # regenera supabase/datos/catastro_osm.sql
```

Pruebas de la base: ver `.github/workflows/pruebas-bd.yml` (Postgres 16 + `supabase/tests/`).
Orden para una base nueva: `supabase/migrations/*.sql` en orden y después `supabase/datos/catastro_ind.sql` y `catastro_osm.sql`.

## Reglas (no negociables)

- **La base es la fuente de verdad.** Toda escritura en `reservas` pasa por funciones RPC: `solicitar_reserva`, `cancelar_reserva`, `responder_reserva`, `bloquear_horario`, `crear_horario_fijo`, `terminar_horario_fijo`. Los recintos se activan con `activar_recinto`. Nunca insertar ni actualizar `reservas` desde el cliente.
- **Sin traslapes**: la restricción `reservas_sin_traslape` (exclusión por rango de tiempo) es la que impide la doble reserva. No confiar en validaciones del frontend.
- **Errores**: cada RPC levanta un `hint` estable (`HORARIO_OCUPADO`, `NO_DISPONIBLE`, `FUERA_DE_PLAZO`, `LIMITE_RESERVAS`, `NO_ENCONTRADA`, `SIN_PERMISO`, `SIN_UBICACION`, `TRANSICION_INVALIDA`, `SIN_SESION`). El frontend decide por el `hint`, no por el texto.
- **Sin DELETE**: un recinto se oculta (`estado = 'oculto'`), una cancha se desactiva (`activa = false`). Solo `horarios_atencion` admite borrar filas.
- **Tabla nueva** → RLS activado, `revoke` + `grant` explícitos (Supabase da todo a `anon`/`authenticated` por defecto) y pruebas en `supabase/tests/reglas_reserva.test.sql`.
- **Fechas** en `timestamptz`; los bloques se arman y se muestran en `America/Santiago`. Nunca usar `toISOString()` para mostrar fechas.
- **Montos**: `precio_hora` es un entero en pesos chilenos (sin decimales). Se muestra como `$25.000`.
- **Datos personales**: los datos de un jugador solo los ven él mismo y el dueño del recinto donde reservó. La disponibilidad pública (`disponibilidad()` y la tabla `ocupacion`) nunca dice quién reservó. Los datos de prueba van anonimizados.
- **Roles**: `jugador`, `admin_recinto`, `superadmin`. El rol nunca viene del cliente; el superadmin se asigna a mano en SQL.
- **Estados de recinto**: `catastro` (visible con su contacto, sin reservas), `activo` (recibe reservas; exige dueño y ubicación), `oculto`.
- **Tiempo real**: la app escucha los cambios de `ocupacion` filtrados por `cancha_id` y vuelve a pedir `disponibilidad`.

## UI

- Español de Chile, tuteo.
- Móvil: Mobile First y modo oscuro según el sistema (RNF-02). El mapa abre centrado en Valparaíso sin esperar el GPS (RNF-01: carga en menos de 3 s en 4G).
- Los estados nunca se distinguen solo por color: pines y calendario llevan además forma, ícono o texto (rojo/verde no basta).
- Áreas táctiles de 44 px o más.
- Google Maps se usa **sin Map ID**: así la carga del mapa en Android no tiene costo. El modo oscuro va con `customMapStyle` (JSON local), nunca con estilos en la nube. Sin Street View.

## Fuentes de datos

- Catastro IND (transparencia BA002T0007721): recintos fiscales. En la comuna son 5 recintos y 7 sectores. Cada sector, que trae su propio enlace de Google Maps, se importa como un recinto aparte.
- Organizaciones deportivas de Valparaíso (transparencia OODD): 456 organizaciones sin dirección. Sirven como lista de clubes para horas fijas y como argumento de demanda.
- OpenStreetMap (`leisure=pitch`): mostrar la atribución "© OpenStreetMap contributors" donde aparezcan esos datos (licencia ODbL).
- Planilla manual de complejos privados.
