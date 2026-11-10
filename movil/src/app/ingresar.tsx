import { router } from 'expo-router'
import { useState } from 'react'
import { Aviso, Boton, Campo, Enlace, Formulario, Titulo } from '../componentes/ui'
import { mensajeAuth } from '../lib/errores'
import { supabase } from '../lib/supabase'

export default function Ingresar() {
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState<string | null>(null)
  const [enviando, setEnviando] = useState(false)

  async function ingresar() {
    setEnviando(true)
    setError(null)
    const { error } = await supabase.auth.signInWithPassword({ email: email.trim(), password })
    setEnviando(false)
    if (error) return setError(mensajeAuth(error))
    // Al haber sesión, la pantalla deja de estar disponible y el router vuelve al inicio.
  }

  return (
    <Formulario>
      <Titulo>Ingresa para reservar</Titulo>
      <Campo
        etiqueta="Correo"
        value={email}
        onChangeText={setEmail}
        autoCapitalize="none"
        autoComplete="email"
        keyboardType="email-address"
        textContentType="emailAddress"
      />
      <Campo
        etiqueta="Contraseña"
        value={password}
        onChangeText={setPassword}
        secureTextEntry
        autoComplete="current-password"
        textContentType="password"
        onSubmitEditing={ingresar}
      />
      {error && <Aviso tono="error">{error}</Aviso>}
      <Boton texto="Ingresar" onPress={ingresar} cargando={enviando} />
      <Enlace texto="Olvidé mi contraseña" onPress={() => router.push('/recuperar')} />
      <Enlace texto="No tengo cuenta: registrarme" onPress={() => router.replace('/registro')} />
    </Formulario>
  )
}
