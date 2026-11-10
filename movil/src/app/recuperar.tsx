import { useState } from 'react'
import { Aviso, Boton, Campo, Formulario, Parrafo, Titulo } from '../componentes/ui'
import { mensajeAuth } from '../lib/errores'
import { supabase } from '../lib/supabase'

export default function Recuperar() {
  const [email, setEmail] = useState('')
  const [error, setError] = useState<string | null>(null)
  const [enviado, setEnviado] = useState(false)
  const [enviando, setEnviando] = useState(false)

  async function enviar() {
    setEnviando(true)
    setError(null)
    // Sin redirectTo: el enlace abre el panel web (Site URL de Supabase), donde se crea la contraseña nueva.
    const { error } = await supabase.auth.resetPasswordForEmail(email.trim())
    setEnviando(false)
    if (error) return setError(mensajeAuth(error))
    setEnviado(true)
  }

  return (
    <Formulario>
      <Titulo>Recuperar contraseña</Titulo>
      {enviado ? (
        <Aviso tono="exito">
          Si el correo está registrado, te llegará un enlace para crear una contraseña nueva. Después vuelve a la app e ingresa.
        </Aviso>
      ) : (
        <>
          <Parrafo>Escribe tu correo y te enviaremos un enlace para crear una contraseña nueva.</Parrafo>
          <Campo
            etiqueta="Correo"
            value={email}
            onChangeText={setEmail}
            autoCapitalize="none"
            autoComplete="email"
            keyboardType="email-address"
          />
          {error && <Aviso tono="error">{error}</Aviso>}
          <Boton texto="Enviar enlace" onPress={enviar} cargando={enviando} />
        </>
      )}
    </Formulario>
  )
}
