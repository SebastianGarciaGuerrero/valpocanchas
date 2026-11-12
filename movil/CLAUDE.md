# App móvil de ValpoCanchas

Parte del repo ValpoCanchas: las reglas del proyecto están en `../CLAUDE.md` y valen también aquí.

- Variables en `movil/.env` (valores públicos, están en el repo): `EXPO_PUBLIC_SUPABASE_URL` y `EXPO_PUBLIC_SUPABASE_PUBLISHABLE_KEY`. Para otro proyecto, `movil/.env.local`.
- Cliente Supabase en `src/lib/supabase.ts`: la sesión se guarda con `expo-sqlite/localStorage` (recomendación de Expo SDK 58).
- Rutas en `src/app/`: el inicio es público (catastro); `ingresar`, `registro` y `recuperar` solo sin sesión; `perfil` solo con sesión (`Stack.Protected` en `_layout.tsx`).
- Colores en `src/tema.ts` (claro y oscuro según el sistema). Áreas táctiles de al menos `TACTIL` px.
- Recuperar contraseña manda el enlace al panel web (Site URL de Supabase); ahí se crea la contraseña nueva.
- Mapa en `src/componentes/MapaRecintos.tsx`: `react-native-maps` con Google en Android, agrupación con `supercluster`, pines como imágenes (`assets/pines/`, relleno = recibe reservas, hueco = catastro) y estilo oscuro local (`estiloMapaOscuro.ts`). No usar Map ID.
- `src/lib/recintos.ts`: una sola consulta (`useRecintos`) alimenta el mapa, la lista y la ficha; ahí están los filtros y los nombres de tipos y superficies.
- Ficha en `src/componentes/PanelRecinto.tsx`: panel inferior dibujado dentro de la pantalla del mapa, sin navegación. El recinto elegido es estado de `src/app/index.tsx`; el botón atrás de Android y tocar el mapa lo cierran. No volver a `presentation: 'formSheet'`: esa versión falló en el teléfono de prueba (aparecía un menú extraño y la app quedaba pegada).
- Íconos con `Icono` y estados con `Punto` (`src/componentes/Icono.tsx`, sobre `expo-symbols`). No usar símbolos de texto (☰, ✕, ●…) como íconos: cambian según la fuente del teléfono.
- Para revisar el diseño sin teléfono: `npx expo export --platform web` y servir la carpeta `dist`. En web el mapa es un esquema de puntos (`MapaRecintos.web.tsx`); el resto de la pantalla es igual.
- APK: `app.config.js` toma `GOOGLE_MAPS_API_KEY` del entorno. Pasos, desde `movil/`:
  1. `npx eas-cli@latest login` y `npx eas-cli@latest init` (una vez).
  2. `npx eas-cli@latest env:set --name GOOGLE_MAPS_API_KEY --value <clave> --environment preview --visibility sensitive`
  3. `npx eas-cli@latest build -p android --profile preview` (entrega un enlace para descargar el APK).
  4. En Google Cloud, restringir la clave a "Apps para Android" con el paquete `cl.valpocanchas.app` y la huella SHA-1 que muestra `npx eas-cli@latest credentials`.
- Antes de dar algo por terminado: `npx tsc --noEmit`, `npx expo lint` y `npx expo export --platform android`.

---

This is an Expo/React Native mobile application. Prioritize mobile-first patterns, performance, and cross-platform compatibility.

## Expo has changed — do not trust your training data

Expo ships breaking changes every SDK release. APIs you remember are likely renamed, moved, or removed. Before writing any code that touches an Expo, EAS, or React Native API:

1. Read the major version of the `expo` package in `package.json`.
2. Fetch the matching versioned docs: `https://docs.expo.dev/versions/v<major>.0.0/`
3. For anything else, fetch https://docs.expo.dev/llms.txt — an index of all Expo docs with corrections to common LLM misconceptions. Follow its links to the specific page you need; never answer from memory.

## Commands

Use `bunx` instead of `npx` if the project uses bun (`bun.lock` present).

```bash
npx expo install <package>  # ALWAYS use instead of npm/yarn/pnpm/bun add — resolves SDK-compatible versions
npx expo start              # start the dev server
npx expo lint               # lint
npx tsc --noEmit            # typecheck
npx expo-doctor             # diagnose dependency and config issues
npx expo install --fix      # fix incompatible package versions
```

Run lint and typecheck before declaring any task done.

## Navigation & Routing

- Use **Expo Router** for all navigation. Routes live in `src/app/` — every file there is a screen, `_layout.tsx` files define navigators. Keep non-route code (components, hooks, utils) outside `src/app/`.
- Import `Link`, `router`, and `useLocalSearchParams` from `expo-router`.
- Docs: https://docs.expo.dev/router/introduction.md

## Building with EAS

Use EAS to build, sign, and submit the app in the cloud (`eas build`, `eas submit`) and to ship over-the-air updates (`eas update`) — no local Xcode or Android Studio required. Run EAS CLI as `bunx eas-cli <command>` in Bun projects, or `npx eas-cli@latest <command>` otherwise; substitute that for bare `eas` in docs examples.
Docs: https://docs.expo.dev/eas/index.md

## Rules

- If `ios/` and `android/` directories do not exist, they are generated (Continuous Native Generation). Never create or edit them by hand — configure native behavior in `app.json` and config plugins.
- Expo Go only includes its bundled native modules. After adding a library with native code, the app needs a development build: `npx expo run:ios|android` locally, or `eas build --profile development`.
- Prefer recommended Expo modules over third-party libraries, and check your available skills before adding dependencies. Docs: https://docs.expo.dev/versions/latest/index.md
