import { useState, type FormEvent } from 'react'
import { useNavigate } from 'react-router'
import { Aviso, Boton, Campo, MarcoAcceso } from '../componentes/ui'
import { mensajeAuth } from '../lib/errores'
import { useSesion } from '../lib/sesion'
import { supabase } from '../lib/supabase'

const LARGO_MINIMO = 8

export default function NuevaClave() {
  const navegar = useNavigate()
  const { terminarRecuperacion } = useSesion()
  const [error, setError] = useState<string | null>(null)
  const [enviando, setEnviando] = useState(false)

  async function enviar(e: FormEvent<HTMLFormElement>) {
    e.preventDefault()
    const datos = new FormData(e.currentTarget)
    const password = String(datos.get('password'))
    if (password.length < LARGO_MINIMO) return setError(`La contraseña debe tener al menos ${LARGO_MINIMO} caracteres.`)
    if (password !== String(datos.get('confirmacion'))) return setError('Las contraseñas no coinciden.')
    setEnviando(true)
    setError(null)
    const { error } = await supabase.auth.updateUser({ password })
    setEnviando(false)
    if (error) return setError(mensajeAuth(error))
    terminarRecuperacion()
    navegar('/', { replace: true })
  }

  return (
    <MarcoAcceso titulo="Crea tu contraseña nueva">
      <form onSubmit={enviar} className="space-y-4" noValidate>
        <Campo
          etiqueta="Contraseña nueva"
          name="password"
          type="password"
          autoComplete="new-password"
          required
          autoFocus
          ayuda={`Al menos ${LARGO_MINIMO} caracteres.`}
        />
        <Campo etiqueta="Repite la contraseña" name="confirmacion" type="password" autoComplete="new-password" required />
        {error && <Aviso tono="error">{error}</Aviso>}
        <Boton type="submit" cargando={enviando} className="w-full">
          Guardar contraseña
        </Boton>
      </form>
    </MarcoAcceso>
  )
}
