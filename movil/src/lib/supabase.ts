import 'expo-sqlite/localStorage/install'
import { createClient } from '@supabase/supabase-js'
import { AppState } from 'react-native'

const url = process.env.EXPO_PUBLIC_SUPABASE_URL
const clave = process.env.EXPO_PUBLIC_SUPABASE_PUBLISHABLE_KEY

/** false si faltan las variables de entorno: la app lo avisa en vez de romperse. */
export const supabaseConfigurado = Boolean(url && clave)

export const supabase = createClient(url ?? 'http://localhost', clave ?? 'sin-configurar', {
  auth: {
    // expo-sqlite entrega un localStorage que guarda la sesión en el teléfono.
    storage: localStorage,
    autoRefreshToken: true,
    persistSession: true,
    detectSessionInUrl: false,
  },
})

// La renovación del token solo corre con la app en primer plano (recomendación de Supabase y Expo).
AppState.addEventListener('change', (estado) => {
  if (estado === 'active') supabase.auth.startAutoRefresh()
  else supabase.auth.stopAutoRefresh()
})

export type Rol = 'jugador' | 'admin_recinto' | 'superadmin'

export interface Perfil {
  id: string
  nombre_completo: string
  telefono: string | null
  rol: Rol
}
