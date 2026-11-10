import type { ReactNode } from 'react'
import { Navigate, Route, Routes } from 'react-router'
import Layout from './componentes/Layout'
import { Aviso, Cargando, MarcoAcceso } from './componentes/ui'
import { useSesion } from './lib/sesion'
import { supabaseConfigurado } from './lib/supabase'
import Ingresar from './paginas/Ingresar'
import Inicio from './paginas/Inicio'
import NuevaClave from './paginas/NuevaClave'
import Recuperar from './paginas/Recuperar'
import Registro from './paginas/Registro'

/** Solo con sesión. */
function Privada({ children }: { children: ReactNode }) {
  const { sesion, cargando, recuperandoClave } = useSesion()
  if (cargando) return <Cargando />
  if (!sesion) return <Navigate to="/ingresar" replace />
  if (recuperandoClave) return <Navigate to="/nueva-clave" replace />
  return children
}

/** Solo sin sesión (si ya entró, va al inicio). */
function Publica({ children }: { children: ReactNode }) {
  const { sesion, cargando } = useSesion()
  if (cargando) return <Cargando />
  if (sesion) return <Navigate to="/" replace />
  return children
}

export default function App() {
  if (!supabaseConfigurado) {
    return (
      <MarcoAcceso titulo="Falta configurar Supabase">
        <Aviso tono="error">
          Faltan <code>VITE_SUPABASE_URL</code> y <code>VITE_SUPABASE_PUBLISHABLE_KEY</code> en{' '}
          <code>admin/.env</code>. Revisa ese archivo y reinicia <code>npm run dev</code>.
        </Aviso>
      </MarcoAcceso>
    )
  }

  return (
    <Routes>
      <Route path="/ingresar" element={<Publica><Ingresar /></Publica>} />
      <Route path="/registro" element={<Publica><Registro /></Publica>} />
      <Route path="/recuperar" element={<Publica><Recuperar /></Publica>} />
      <Route path="/nueva-clave" element={<NuevaClave />} />
      <Route element={<Privada><Layout /></Privada>}>
        <Route index element={<Inicio />} />
      </Route>
      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  )
}
