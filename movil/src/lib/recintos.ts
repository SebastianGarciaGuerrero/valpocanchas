import { useQuery } from '@tanstack/react-query'
import { supabase, supabaseConfigurado } from './supabase'

export type TipoCancha = 'futbol_11' | 'futbol_7' | 'baby_futbol' | 'futsal' | 'multicancha'
export type Superficie = 'pasto_sintetico' | 'pasto_natural' | 'tierra' | 'baldosa' | 'madera' | 'cemento' | 'otra'

export interface Cancha {
  id: number
  nombre: string
  tipo: TipoCancha
  superficie: Superficie | null
  techada: boolean
  iluminacion: boolean
  precio_hora: number | null
  activa: boolean
}

export interface Recinto {
  id: number
  nombre: string
  direccion: string | null
  sector: string | null
  latitud: number
  longitud: number
  estado: 'catastro' | 'activo'
  telefono_contacto: string | null
  email_contacto: string | null
  sitio_web: string | null
  descripcion: string | null
  fuente: 'ind' | 'osm' | 'municipal' | 'manual'
  tipo_administracion: string | null
  institucion_administradora: string | null
  estado_conservacion: 'B' | 'R' | 'M' | null
  canchas: Cancha[]
}

export const NOMBRE_TIPO: Record<TipoCancha, string> = {
  baby_futbol: 'Baby fútbol',
  futbol_7: 'Fútbol 7',
  futbol_11: 'Fútbol 11',
  futsal: 'Futsal',
  multicancha: 'Multicancha',
}

export const NOMBRE_SUPERFICIE: Record<Superficie, string> = {
  pasto_sintetico: 'Pasto sintético',
  pasto_natural: 'Pasto natural',
  tierra: 'Tierra',
  baldosa: 'Baldosa',
  madera: 'Madera',
  cemento: 'Cemento',
  otra: 'Otra',
}

export const NOMBRE_CONSERVACION = { B: 'Bueno', R: 'Regular', M: 'Malo' } as const

/** $25.000: pesos chilenos, sin decimales. */
export function formatoPrecio(pesos: number): string {
  return '$' + String(Math.round(pesos)).replace(/\B(?=(\d{3})+(?!\d))/g, '.')
}

/** Todo el catastro visible, con sus canchas activas. Una sola consulta sirve al mapa, la lista y la ficha. */
export function useRecintos() {
  return useQuery({
    queryKey: ['recintos'],
    enabled: supabaseConfigurado,
    staleTime: 5 * 60_000,
    queryFn: async () => {
      const { data, error } = await supabase
        .from('recintos')
        .select(
          'id, nombre, direccion, sector, latitud, longitud, estado, telefono_contacto, email_contacto, sitio_web, descripcion, fuente, tipo_administracion, institucion_administradora, estado_conservacion, canchas(id, nombre, tipo, superficie, techada, iluminacion, precio_hora, activa)',
        )
        .not('latitud', 'is', null)
        .order('nombre')
      if (error) throw error
      return (data as Recinto[]).map((r) => ({ ...r, canchas: r.canchas.filter((c) => c.activa) }))
    },
  })
}

// ---------------------------------------------------------------- filtros

export interface Filtros {
  soloReservables: boolean
  tipos: TipoCancha[]
  superficies: Superficie[]
  techada: boolean
  iluminada: boolean
}

export const SIN_FILTROS: Filtros = { soloReservables: false, tipos: [], superficies: [], techada: false, iluminada: false }

export function hayFiltros(f: Filtros): boolean {
  return f.soloReservables || f.techada || f.iluminada || f.tipos.length > 0 || f.superficies.length > 0
}

/** Un recinto pasa si alguna de sus canchas cumple a la vez todos los filtros de cancha. */
export function filtrar(recintos: Recinto[], f: Filtros): Recinto[] {
  const filtraCanchas = f.techada || f.iluminada || f.tipos.length > 0 || f.superficies.length > 0
  return recintos.filter((r) => {
    if (f.soloReservables && r.estado !== 'activo') return false
    if (!filtraCanchas) return true
    return r.canchas.some(
      (c) =>
        (f.tipos.length === 0 || f.tipos.includes(c.tipo)) &&
        (f.superficies.length === 0 || (c.superficie !== null && f.superficies.includes(c.superficie))) &&
        (!f.techada || c.techada) &&
        (!f.iluminada || c.iluminacion),
    )
  })
}

/** Resumen de una línea: "2 canchas · Baby fútbol, Fútbol 7". */
export function resumenCanchas(r: Recinto): string {
  const n = r.canchas.length
  if (n === 0) return 'Sin canchas registradas'
  const tipos = [...new Set(r.canchas.map((c) => NOMBRE_TIPO[c.tipo]))].join(', ')
  return `${n} ${n === 1 ? 'cancha' : 'canchas'} · ${tipos}`
}
