import { useColorScheme } from 'react-native'

const claro = {
  fondo: '#F8FAFC',
  superficie: '#FFFFFF',
  borde: '#E2E8F0',
  texto: '#0F172A',
  textoSuave: '#64748B',
  primario: '#0F766E',
  primarioTexto: '#FFFFFF',
  error: '#B91C1C',
  errorFondo: '#FEF2F2',
  exito: '#0F766E',
  exitoFondo: '#F0FDFA',
}

const oscuro: typeof claro = {
  fondo: '#020617',
  superficie: '#0F172A',
  borde: '#1E293B',
  texto: '#F1F5F9',
  textoSuave: '#94A3B8',
  primario: '#14B8A6',
  primarioTexto: '#042F2E',
  error: '#FCA5A5',
  errorFondo: '#450A0A',
  exito: '#5EEAD4',
  exitoFondo: '#042F2E',
}

export type Colores = typeof claro

/** Colores según el modo del sistema (RNF-02: modo oscuro). */
export function useTema(): Colores {
  return useColorScheme() === 'dark' ? oscuro : claro
}

/** Alto mínimo de un área táctil (44 px). */
export const TACTIL = 48
