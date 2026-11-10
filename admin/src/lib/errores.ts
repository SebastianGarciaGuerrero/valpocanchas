import type { AuthError } from '@supabase/supabase-js'

const MENSAJES_AUTH: Record<string, string> = {
  invalid_credentials: 'Correo o contraseña incorrectos.',
  email_not_confirmed: 'Todavía no confirmas tu correo. Revisa tu bandeja de entrada (y la carpeta de spam).',
  user_already_exists: 'Ya existe una cuenta con ese correo.',
  email_exists: 'Ya existe una cuenta con ese correo.',
  weak_password: 'La contraseña es muy débil. Usa al menos 8 caracteres y mezcla letras y números.',
  same_password: 'La nueva contraseña tiene que ser distinta de la anterior.',
  over_email_send_rate_limit: 'Enviamos demasiados correos seguidos. Espera unos minutos y vuelve a intentarlo.',
  over_request_rate_limit: 'Demasiados intentos. Espera un momento y vuelve a intentarlo.',
  validation_failed: 'Revisa los datos ingresados.',
}

/** Traduce un error de Supabase Auth a un mensaje para la persona. Decide por el código, no por el texto. */
export function mensajeAuth(error: AuthError | null | undefined): string | null {
  if (!error) return null
  if (error.code && MENSAJES_AUTH[error.code]) return MENSAJES_AUTH[error.code]
  if (error.name === 'AuthRetryableFetchError') return 'No hay conexión con el servidor. Revisa tu internet.'
  return 'No pudimos completar la operación. Inténtalo de nuevo.'
}
