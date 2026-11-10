import type { ButtonHTMLAttributes, InputHTMLAttributes, ReactNode } from 'react'

export function Logo({ grande = false }: { grande?: boolean }) {
  return (
    <span className={`inline-flex items-center gap-2 font-semibold tracking-tight ${grande ? 'text-2xl' : 'text-lg'}`}>
      <img src="/favicon.svg" alt="" className={grande ? 'h-9 w-9' : 'h-7 w-7'} />
      ValpoCanchas
    </span>
  )
}

interface CampoProps extends InputHTMLAttributes<HTMLInputElement> {
  etiqueta: string
  ayuda?: string
}

export function Campo({ etiqueta, ayuda, id, ...props }: CampoProps) {
  const idCampo = id ?? props.name
  return (
    <label htmlFor={idCampo} className="block">
      <span className="mb-1 block text-sm font-medium">{etiqueta}</span>
      <input
        id={idCampo}
        className="h-11 w-full rounded-lg border border-slate-300 bg-white px-3 text-base outline-none transition focus:border-teal-600 focus:ring-2 focus:ring-teal-600/30 dark:border-slate-700 dark:bg-slate-900"
        {...props}
      />
      {ayuda && <span className="mt-1 block text-xs text-slate-500 dark:text-slate-400">{ayuda}</span>}
    </label>
  )
}

interface BotonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  cargando?: boolean
  variante?: 'primario' | 'secundario'
}

export function Boton({ cargando, variante = 'primario', children, disabled, className = '', ...props }: BotonProps) {
  const estilos =
    variante === 'primario'
      ? 'bg-teal-700 text-white hover:bg-teal-800 disabled:bg-teal-700/60'
      : 'border border-slate-300 bg-white text-slate-800 hover:bg-slate-100 dark:border-slate-700 dark:bg-slate-900 dark:text-slate-100 dark:hover:bg-slate-800'
  return (
    <button
      className={`inline-flex h-11 items-center justify-center gap-2 rounded-lg px-4 font-medium transition disabled:cursor-not-allowed ${estilos} ${className}`}
      disabled={disabled || cargando}
      {...props}
    >
      {cargando && <span className="h-4 w-4 animate-spin rounded-full border-2 border-current border-t-transparent" aria-hidden />}
      {children}
    </button>
  )
}

const TONOS = {
  error: 'border-red-300 bg-red-50 text-red-900 dark:border-red-900 dark:bg-red-950/50 dark:text-red-200',
  exito: 'border-teal-300 bg-teal-50 text-teal-900 dark:border-teal-900 dark:bg-teal-950/50 dark:text-teal-100',
  info: 'border-slate-300 bg-white text-slate-700 dark:border-slate-700 dark:bg-slate-900 dark:text-slate-300',
}

export function Aviso({ tono = 'info', children }: { tono?: keyof typeof TONOS; children: ReactNode }) {
  return (
    <div role={tono === 'error' ? 'alert' : 'status'} className={`rounded-lg border px-3 py-2 text-sm ${TONOS[tono]}`}>
      {children}
    </div>
  )
}

/** Marco común de las pantallas de acceso (ingresar, registro, recuperar). */
export function MarcoAcceso({ titulo, children, pie }: { titulo: string; children: ReactNode; pie?: ReactNode }) {
  return (
    <main className="flex min-h-svh items-center justify-center px-4 py-10">
      <div className="w-full max-w-sm">
        <div className="mb-8 text-center">
          <Logo grande />
          <p className="mt-1 text-sm text-slate-500 dark:text-slate-400">Panel de recintos · Valparaíso</p>
        </div>
        <section className="rounded-2xl border border-slate-200 bg-white p-6 shadow-sm dark:border-slate-800 dark:bg-slate-900">
          <h1 className="mb-5 text-xl font-semibold">{titulo}</h1>
          {children}
        </section>
        {pie && <div className="mt-5 text-center text-sm text-slate-600 dark:text-slate-400">{pie}</div>}
      </div>
    </main>
  )
}

export function Cargando() {
  return (
    <div className="flex min-h-svh items-center justify-center" role="status" aria-label="Cargando">
      <span className="h-8 w-8 animate-spin rounded-full border-4 border-teal-700 border-t-transparent" />
    </div>
  )
}
