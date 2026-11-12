import { SymbolView } from 'expo-symbols'
import { View } from 'react-native'

// Íconos nativos: Material Symbols en Android y web, SF Symbols en iOS.
// Se usan en vez de símbolos de texto (☰, ✕, ◎…), que cambian según la fuente del teléfono.
const NOMBRES = {
  lista: { ios: 'list.bullet', android: 'list', web: 'list' },
  mapa: { ios: 'map', android: 'map', web: 'map' },
  ubicacion: { ios: 'location.fill', android: 'my_location', web: 'my_location' },
  cerrar: { ios: 'xmark', android: 'close', web: 'close' },
  listo: { ios: 'checkmark', android: 'check', web: 'check' },
  ruta: { ios: 'arrow.triangle.turn.up.right.diamond.fill', android: 'directions', web: 'directions' },
  telefono: { ios: 'phone.fill', android: 'call', web: 'call' },
  mensaje: { ios: 'message.fill', android: 'chat', web: 'chat' },
} as const

export type NombreIcono = keyof typeof NOMBRES

export function Icono({ nombre, color, tam = 20 }: { nombre: NombreIcono; color: string; tam?: number }) {
  return <SymbolView name={NOMBRES[nombre]} tintColor={color} size={tam} />
}

/**
 * Marca del estado de un recinto, dibujada (no depende de la fuente): círculo relleno si
 * recibe reservas, hueco si es solo información. Siempre va acompañada de texto.
 */
export function Punto({ relleno, color, tam = 10 }: { relleno: boolean; color: string; tam?: number }) {
  return (
    <View
      style={{
        width: tam,
        height: tam,
        borderRadius: tam / 2,
        borderWidth: 2,
        borderColor: color,
        backgroundColor: relleno ? color : 'transparent',
      }}
    />
  )
}
