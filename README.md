# ValpoCanchas

Plataforma web y móvil para la gestión administrativa y la geolocalización de la infraestructura deportiva de la comuna de Valparaíso. Proyecto de título, Técnico Superior en Informática (IACC).

- `movil/`: app de jugadores (Expo / React Native).
- `admin/`: panel web de dueños y de la administración general (React).
- `supabase/`: esquema de la base, reglas y pruebas.
- `docs/PLAN.md`: plan de trabajo y alcance.

Las reglas de reserva (sin doble reserva, aprobación del dueño, cancelación con 48 h, horas fijas) viven en la base y se prueban en cada push (`.github/workflows/pruebas-bd.yml`).
