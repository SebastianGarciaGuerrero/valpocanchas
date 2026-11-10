import { Text, View } from 'react-native'
import type { Recinto } from '../lib/recintos'
import { useTema } from '../tema'

interface Props {
  recintos: Recinto[]
  onAbrir: (id: number) => void
  margenSuperior: number
}

/** En el navegador no hay mapa nativo: la app está pensada para Android. Se usa la vista de lista. */
export default function MapaRecintos({ margenSuperior }: Props) {
  const c = useTema()
  return (
    <View style={{ flex: 1, paddingTop: margenSuperior + 24, paddingHorizontal: 24 }}>
      <Text style={{ color: c.textoSuave, fontSize: 16, textAlign: 'center' }}>
        El mapa está disponible en la app para Android. Aquí puedes usar la vista de lista.
      </Text>
    </View>
  )
}
