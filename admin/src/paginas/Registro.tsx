import { useState, type FormEvent } from 'react'
import { Link, useNavigate } from 'react-router'
import { Aviso, Boton, Campo, MarcoAcceso } from '../componentes/ui'
import { mensajeAuth } from '../lib/errores'
import { supabase } from '../lib/supabase'

const LARGO_MINIMO = 8

export default function Registro() {
  const navegar = useNavigate()
  const [error, setError] = useState<string | null>(null)
  const [enviando, setEnviando] = useState(false)

  async function enviar(e: FormEvent<HTMLFormElement>) {
    e.preventDefault()
    const datos = new FormData(e.currentTarget)
    const nombre = String(datos.get('nombre')).trim()
    const password = String(datos.get('password'))
    if (!nombre) return setError('Escribe tu nombre.')
    if (password.length < LARGO_MINIMO) return setError(`La contraseña debe tener al menos ${LARGO_MINIMO} caracteres.`)
    if (password !== String(datos.get('confirmacion'))) return setError('Las contraseñas no coinciden.')

    setEnviando(true)
    setError(null)
    const { data, error } = await supabase.auth.signUp({
      email: String(datos.get('email')).trim(),
      password,
      options: {
        // El rol NO se manda: la base siempre crea la cuenta como jugador.
        data: { nombre_completo: nombre, telefono: String(datos.get('telefono')).trim() || null },
        emailRedirectTo: window.location.origin,
      },
    })
    setEnviando(false)
    if (error) return setError(mensajeAuth(error))
    if (data.session) return navegar('/', { replace: true })
    navegar('/ingresar', {
      replace: true,
      state: { aviso: 'Te enviamos un correo para confirmar tu cuenta. Ábrelo y después ingresa aquí.' },
    })
  }

  return (
    <MarcoAcceso
      titulo="Crear cuenta"
      pie={
        <>
          ¿Ya tienes cuenta?{' '}
          <Link to="/ingresar" className="font-medium text-teal-700 hover:underline dark:text-teal-400">
            Ingresa
          </Link>
        </>
      }
    >
      <form onSubmit={enviar} className="space-y-4" noValidate>
        <Campo etiqueta="Nombre completo" name="nombre" autoComplete="name" required autoFocus />
        <Campo etiqueta="Teléfono (opcional)" name="telefono" type="tel" autoComplete="tel" placeholder="+56 9 1234 5678" />
        <Campo etiqueta="Correo" name="email" type="email" autoComplete="email" required />
        <Campo
          etiqueta="Contraseña"
          name="password"
          type="password"
          autoComplete="new-password"
          required
          minLength={LARGO_MINIMO}
          ayuda={`Al menos ${LARGO_MINIMO} caracteres.`}
        />
        <Campo etiqueta="Repite la contraseña" name="confirmacion" type="password" autoComplete="new-password" required />
        {error && <Aviso tono="error">{error}</Aviso>}
        <Boton type="submit" cargando={enviando} className="w-full">
          Crear cuenta
        </Boton>
      </form>
    </MarcoAcceso>
  )
}
