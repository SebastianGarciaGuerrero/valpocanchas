import { useState, type FormEvent } from 'react'
import { Link, useLocation, useNavigate } from 'react-router'
import { Aviso, Boton, Campo, MarcoAcceso } from '../componentes/ui'
import { mensajeAuth } from '../lib/errores'
import { supabase } from '../lib/supabase'

export default function Ingresar() {
  const navegar = useNavigate()
  const ubicacion = useLocation()
  const [error, setError] = useState<string | null>(null)
  const [enviando, setEnviando] = useState(false)
  const avisoInicial = (ubicacion.state as { aviso?: string } | null)?.aviso

  async function enviar(e: FormEvent<HTMLFormElement>) {
    e.preventDefault()
    const datos = new FormData(e.currentTarget)
    setEnviando(true)
    setError(null)
    const { error } = await supabase.auth.signInWithPassword({
      email: String(datos.get('email')).trim(),
      password: String(datos.get('password')),
    })
    setEnviando(false)
    if (error) return setError(mensajeAuth(error))
    navegar('/', { replace: true })
  }

  return (
    <MarcoAcceso
      titulo="Ingresar"
      pie={
        <>
          ¿No tienes cuenta?{' '}
          <Link to="/registro" className="font-medium text-teal-700 hover:underline dark:text-teal-400">
            Regístrate
          </Link>
        </>
      }
    >
      <form onSubmit={enviar} className="space-y-4" noValidate>
        {avisoInicial && <Aviso tono="exito">{avisoInicial}</Aviso>}
        <Campo etiqueta="Correo" name="email" type="email" autoComplete="email" required autoFocus />
        <Campo etiqueta="Contraseña" name="password" type="password" autoComplete="current-password" required />
        {error && <Aviso tono="error">{error}</Aviso>}
        <Boton type="submit" cargando={enviando} className="w-full">
          Ingresar
        </Boton>
        <p className="text-center text-sm">
          <Link to="/recuperar" className="text-slate-600 hover:underline dark:text-slate-400">
            Olvidé mi contraseña
          </Link>
        </p>
      </form>
    </MarcoAcceso>
  )
}
