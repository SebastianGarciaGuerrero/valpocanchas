import type { Session } from '@supabase/supabase-js'
import { useQuery, useQueryClient } from '@tanstack/react-query'
import { createContext, useContext, useEffect, useState, type ReactNode } from 'react'
import { supabase, type Perfil } from './supabase'

interface EstadoSesion {
  sesion: Session | null
  perfil: Perfil | null
  /** true mientras se lee la sesión guardada en el teléfono */
  cargando: boolean
  cerrarSesion: () => Promise<void>
}

const ContextoSesion = createContext<EstadoSesion | null>(null)

export function ProveedorSesion({ children }: { children: ReactNode }) {
  const [sesion, setSesion] = useState<Session | null>(null)
  const [sesionLista, setSesionLista] = useState(false)
  const queryClient = useQueryClient()

  useEffect(() => {
    supabase.auth.getSession().then(({ data }) => {
      setSesion(data.session)
      setSesionLista(true)
    })
    // No llamar a otros métodos de supabase dentro de este callback: solo actualizar estado.
    const { data } = supabase.auth.onAuthStateChange((evento, nueva) => {
      setSesion(nueva)
      if (evento === 'SIGNED_OUT') queryClient.clear()
    })
    return () => data.subscription.unsubscribe()
  }, [queryClient])

  const idUsuario = sesion?.user.id
  const perfil = useQuery({
    queryKey: ['perfil', idUsuario],
    enabled: Boolean(idUsuario),
    queryFn: async () => {
      const { data, error } = await supabase
        .from('perfiles')
        .select('id, nombre_completo, telefono, rol')
        .eq('id', idUsuario!)
        .single()
      if (error) throw error
      return data as Perfil
    },
  })

  const valor: EstadoSesion = {
    sesion,
    perfil: perfil.data ?? null,
    cargando: !sesionLista,
    cerrarSesion: async () => {
      await supabase.auth.signOut()
    },
  }
  return <ContextoSesion.Provider value={valor}>{children}</ContextoSesion.Provider>
}

export function useSesion(): EstadoSesion {
  const ctx = useContext(ContextoSesion)
  if (!ctx) throw new Error('useSesion debe usarse dentro de ProveedorSesion')
  return ctx
}
