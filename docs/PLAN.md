# Plan ValpoCanchas: 9 de noviembre al 7 de diciembre de 2026

Tiempo disponible: unas 2 horas diarias, cerca de 56 horas en total. Las funcionalidades se congelan el **jueves 3 de diciembre**; después solo se corrigen errores.

## Alcance

**Dentro:**
- RF-01: registro e inicio de sesión (correo y contraseña) en web y móvil.
- RF-02: mapa con todo el catastro; los pines se agrupan si hay muchos.
- RF-03: reserva por bloques. La solicitud queda pendiente hasta que el dueño la aprueba. El jugador cancela con 48 h o más de anticipación. Incluye horas fijas semanales y bloqueos manuales.
- RF-04: el dueño edita su recinto, canchas, precios y horario. El administrador general crea recintos del catastro y los activa.
- RF-05: "Mis reservas", futuras y pasadas.
- Disponibilidad en tiempo real.
- APK Android instalable y panel web publicado en Vercel.

**Fuera por ahora:** pagos, notificaciones push, encuesta automática después del partido (la encuesta se hace con Google Forms), modo sin conexión, iOS, ligas y torneos.

## Semana 1 (9 al 15 de noviembre): cimientos y datos

- [x] Repo en GitHub, proyecto Supabase (quedó en us-west-2), cuenta Expo y clave de Google Maps para Android.
- [x] Migraciones aplicadas en Supabase; las pruebas de la base corren en GitHub Actions.
- [x] Catastro cargado: 6 recintos del IND (coordenadas leídas de sus enlaces de Google Maps) y 45 de OpenStreetMap, 62 canchas.
- [ ] Planilla de complejos privados (nombre, dirección, teléfono, Instagram, canchas y precios).
- [x] `movil/` (Expo SDK 58, Expo Router, TS) y `admin/` (Vite, React, TS, Tailwind) con registro, inicio de sesión y recuperar contraseña, probados contra Supabase.
- [ ] Probar en tu celular con Expo Go y en el navegador; registrarte y quedar como administrador general.
- **Entregable:** inicio de sesión en web y móvil, y recintos reales en la base.

## Semana 2 (16 al 22 de noviembre): mapa y ficha en el móvil

- [ ] Mapa centrado en Valparaíso sin esperar el GPS; pines distintos para recintos activos y de catastro; agrupación de pines.
- [ ] Ficha en un panel inferior: foto, canchas (tipo, superficie, techada, precio), horario y contacto (llamar o WhatsApp) si el recinto no está activo.
- [ ] Filtros: tipo de cancha, superficie, solo reservables.
- [ ] Primer APK instalado en el Xiaomi 11T.
- **Entregable:** APK n.º 1 con el mapa real.

## Semana 3 (23 al 29 de noviembre): reservas de punta a punta

- [ ] Móvil: cancha → día → bloques libres → solicitar. "Mis reservas" y cancelar.
- [ ] Tiempo real con la tabla `ocupacion`.
- [ ] Panel del dueño: calendario semanal por cancha, aprobar o rechazar, bloquear horas, horas fijas, editar recinto, canchas, precios y horario.
- [ ] Panel del administrador general: catastro, crear y editar recintos, activar recinto y asignar dueño.
- **Entregable:** flujo jugador → dueño completo en dispositivos reales.

## Semana 4 (30 de noviembre al 6 de diciembre): pruebas reales y presentación

- [ ] Lunes 30 a miércoles 2: prueba con el administrador real y 10 jugadores (encuesta en Google Forms); CP-001 y CP-002 con dos celulares; corrección de errores.
- [ ] Jueves 3: congelar funcionalidades; proyecto Supabase de producción; publicar en Vercel; APK final.
- [ ] Viernes 4 y sábado 5: actualizar la presentación con capturas y cifras reales; grabar un video de respaldo de la demo; ensayar.
- [ ] Domingo 6: holgura.

## Si vamos atrasados, se recorta en este orden

1. Filtros del mapa.
2. Pantalla de horas fijas (se cargan por SQL).
3. Tiempo real (se refresca al volver a la pantalla).
4. Edición del horario de atención (se carga por SQL).

## Riesgos

| Riesgo | Qué hacemos |
|---|---|
| Supabase gratis pausa los proyectos que pasan una semana sin uso | Usarlo a diario y abrirlo el día antes de la defensa |
| EAS Build gratis tiene cola de espera | No dejar el APK para el último día |
| El catastro IND trae pocos recintos | Complementar con OpenStreetMap y la planilla manual |
| La transparencia municipal demora hasta 20 días hábiles | Pedirla esta semana |
| Mala señal 4G en la sala | Video de respaldo de la demo |
| El correo gratis de Supabase solo envía a tu cuenta y 2 por hora | Confirmación de correo desactivada en el prototipo. Antes de las pruebas con jugadores, configurar un SMTP propio (Brevo o Resend) para recuperar contraseñas y tener los correos en español |

## Pantallas

**App móvil (jugador)**
1. Mapa (inicio): pines, búsqueda y filtros.
2. Ficha del recinto (panel inferior que se expande).
3. Elegir cancha, día y bloque.
4. Confirmar la solicitud.
5. Mis reservas (próximas y pasadas), con opción de cancelar.
6. Inicio de sesión, registro y recuperar contraseña.
7. Perfil: nombre, teléfono, cerrar sesión.

**Panel web (dueño)**
1. Inicio de sesión.
2. Calendario semanal por cancha, con las solicitudes pendientes destacadas.
3. Solicitudes pendientes (lista para aprobar rápido).
4. Horas fijas.
5. Mi recinto: datos, foto, canchas, precios y horario.

**Panel web (administración general)**
1. Catastro: tabla y mapa, con filtro por estado y fuente.
2. Crear o editar un recinto (ubicándolo en el mapa).
3. Activar un recinto y asignar a su dueño.

## Decisiones tomadas (se pueden cambiar)

- Una solicitud pendiente ya ocupa el bloque: gana quien pide primero. Si el dueño la rechaza, el bloque se libera.
- Un jugador puede tener como máximo 3 reservas futuras activas.
- Se reserva como máximo 30 días hacia adelante.
- Los bloques parten a la hora de apertura y duran lo que diga la cancha (60, 90 o 120 minutos).
- Supabase quedó en la región us-west-2 (Oregón): unos 100 a 150 ms más por consulta que São Paulo. Aceptable para el prototipo.
- La URL y la clave *publishable* de Supabase están en `admin/.env` y `movil/.env`, dentro del repo: son públicas por diseño (van dentro de la app) y la seguridad la dan las políticas RLS. La clave secreta nunca va al repo.
- El asesor de seguridad de Supabase deja 9 advertencias: son las funciones que la app llama a propósito (reservar, cancelar, responder, bloquear, horas fijas, activar recinto y disponibilidad). Cada una valida por dentro quién la llama. Las funciones internas están en el esquema `privado`, que la API no publica.
- Mapa: Google Maps en la app y OpenStreetMap en el panel web. En Android el mapa sin Map ID no se cobra por carga; Google solo pide una cuenta de facturación. El catastro es independiente del proveedor de mapas, así que más adelante se puede pasar a MapLibre + OpenStreetMap sin tocar los datos.
