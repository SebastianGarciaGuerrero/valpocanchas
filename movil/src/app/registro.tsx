import { router } from 'expo-router'
import { useState } from 'react'
import { Aviso, Boton, Campo, Enlace, Formulario, Parrafo, Titulo } from '../componentes/ui'
import { mensajeAuth } from '../lib/errores'
import { supabase } from '../lib/supabase'

const LARGO_MINIMO = 8

export default function Registro() {
  const [nombre, setNombre] = useState('')
  const [telefono, setTelefono] = useState('')
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState<string | null>(null)
  const [listo, setListo] = useState(false)
  const [enviando, setEnviando] = useState(false)

  async function registrar() {
    if (!nombre.trim()) return setError('Escribe tu nombre.')
    if (password.length < LARGO_MINIMO) return setError(`La contraseña debe tener al menos ${LARGO_MINIMO} caracteres.`)
    setEnviando(true)
    setError(null)
    const { data, error } = await supabase.auth.signUp({
      email: email.trim(),
      password,
      // El rol NO se manda: la base siempre crea la cuenta como jugador.
      options: { data: { nombre_completo: nombre.trim(), telefono: telefono.trim() || null } },
    })
    setEnviando(false)
    if (error) return setError(mensajeAuth(error))
    if (!data.session) setListo(true)
  }

  if (listo) {
    return (
      <Formulario>
        <Titulo>Revisa tu correo</Titulo>
        <Parrafo>
          Te enviamos un enlace a {email.trim()} para confirmar tu cuenta. Ábrelo y después vuelve aquí a ingresar.
        </Parrafo>
        <Boton texto="Ir a ingresar" onPress={() => router.replace('/ingresar')} />
      </Formulario>
    )
  }

  return (
    <Formulario>
      <Titulo>Crea tu cuenta</Titulo>
      <Campo etiqueta="Nombre completo" value={nombre} onChangeText={setNombre} autoComplete="name" textContentType="name" />
      <Campo
        etiqueta="Teléfono (opcional)"
        value={telefono}
        onChangeText={setTelefono}
        keyboardType="phone-pad"
        autoComplete="tel"
        placeholder="+56 9 1234 5678"
      />
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
        etiqueta={`Contraseña (mínimo ${LARGO_MINIMO} caracteres)`}
        value={password}
        onChangeText={setPassword}
        secureTextEntry
        autoComplete="new-password"
        textContentType="newPassword"
      />
      {error && <Aviso tono="error">{error}</Aviso>}
      <Boton texto="Crear cuenta" onPress={registrar} cargando={enviando} />
      <Enlace texto="Ya tengo cuenta: ingresar" onPress={() => router.replace('/ingresar')} />
    </Formulario>
  )
}
