import { useState, type FormEvent } from 'react'
import { Link } from 'react-router'
import { Aviso, Boton, Campo, MarcoAcceso } from '../componentes/ui'
import { mensajeAuth } from '../lib/errores'
import { supabase } from '../lib/supabase'

export default function Recuperar() {
  const [error, setError] = useState<string | null>(null)
  const [enviado, setEnviado] = useState(false)
  const [enviando, setEnviando] = useState(false)

  async function enviar(e: FormEvent<HTMLFormElement>) {
    e.preventDefault()
    const email = String(new FormData(e.currentTarget).get('email')).trim()
    setEnviando(true)
    setError(null)
    const { error } = await supabase.auth.resetPasswordForEmail(email, {
      redirectTo: `${window.location.origin}/nueva-clave`,
    })
    setEnviando(false)
    if (error) return setError(mensajeAuth(error))
    setEnviado(true)
  }

  return (
    <MarcoAcceso
      titulo="Recuperar contraseña"
      pie={
        <Link to="/ingresar" className="text-teal-700 hover:underline dark:text-teal-400">
          Volver a ingresar
        </Link>
      }
    >
      {enviado ? (
        <Aviso tono="exito">
          Si el correo está registrado, te llegará un enlace para crear una contraseña nueva. Revisa también la carpeta de spam.
        </Aviso>
      ) : (
        <form onSubmit={enviar} className="space-y-4" noValidate>
          <p className="text-sm text-slate-600 dark:text-slate-400">
            Escribe tu correo y te enviaremos un enlace para crear una contraseña nueva.
          </p>
          <Campo etiqueta="Correo" name="email" type="email" autoComplete="email" required autoFocus />
          {error && <Aviso tono="error">{error}</Aviso>}
          <Boton type="submit" cargando={enviando} className="w-full">
            Enviar enlace
          </Boton>
        </form>
      )}
    </MarcoAcceso>
  )
}
