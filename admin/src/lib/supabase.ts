import { createClient } from '@supabase/supabase-js'

const url = import.meta.env.VITE_SUPABASE_URL
const clave = import.meta.env.VITE_SUPABASE_PUBLISHABLE_KEY

/** false si faltan las variables de entorno: la app muestra cómo configurarlas en vez de romperse. */
export const supabaseConfigurado = Boolean(url && clave)

export const supabase = createClient(url ?? 'http://localhost', clave ?? 'sin-configurar', {
  auth: { persistSession: true, autoRefreshToken: true, detectSessionInUrl: true },
})

export type Rol = 'jugador' | 'admin_recinto' | 'superadmin'

export interface Perfil {
  id: string
  nombre_completo: string
  telefono: string | null
  rol: Rol
}

export const NOMBRE_ROL: Record<Rol, string> = {
  jugador: 'Jugador',
  admin_recinto: 'Administrador de recinto',
  superadmin: 'Administración general',
}
