import { Outlet } from 'react-router'
import { useSesion } from '../lib/sesion'
import { NOMBRE_ROL } from '../lib/supabase'
import { Boton, Logo } from './ui'

export default function Layout() {
  const { perfil, sesion, cerrarSesion } = useSesion()
  return (
    <div className="min-h-svh">
      <header className="border-b border-slate-200 bg-white dark:border-slate-800 dark:bg-slate-900">
        <div className="mx-auto flex max-w-6xl items-center justify-between gap-4 px-6 py-3">
          <Logo />
          <div className="flex items-center gap-4">
            <div className="text-right text-sm leading-tight">
              <div className="font-medium">{perfil?.nombre_completo || sesion?.user.email}</div>
              {perfil && <div className="text-slate-500 dark:text-slate-400">{NOMBRE_ROL[perfil.rol]}</div>}
            </div>
            <Boton variante="secundario" onClick={cerrarSesion}>
              Cerrar sesión
            </Boton>
          </div>
        </div>
      </header>
      <main className="mx-auto max-w-6xl px-6 py-8">
        <Outlet />
      </main>
    </div>
  )
}
