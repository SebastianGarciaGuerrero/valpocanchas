import { FlatList, Pressable, StyleSheet, Text } from 'react-native'
import { resumenCanchas, type Recinto } from '../lib/recintos'
import { useTema } from '../tema'

export default function ListaRecintos({ recintos, onAbrir }: { recintos: Recinto[]; onAbrir: (id: number) => void }) {
  const c = useTema()
  return (
    <FlatList
      data={recintos}
      keyExtractor={(r) => String(r.id)}
      contentContainerStyle={{ padding: 16, gap: 10 }}
      ListEmptyComponent={
        <Text style={{ color: c.textoSuave, textAlign: 'center', marginTop: 32, fontSize: 16 }}>
          Ningún recinto cumple con esos filtros.
        </Text>
      }
      renderItem={({ item }) => {
        const activo = item.estado === 'activo'
        return (
          <Pressable
            accessibilityRole="button"
            onPress={() => onAbrir(item.id)}
            style={({ pressed }) => [
              estilos.tarjeta,
              { backgroundColor: c.superficie, borderColor: c.borde },
              pressed && { opacity: 0.7 },
            ]}
          >
            <Text style={[estilos.nombre, { color: c.texto }]}>{item.nombre}</Text>
            <Text style={{ color: c.textoSuave }}>{[item.sector, resumenCanchas(item)].filter(Boolean).join(' · ')}</Text>
            <Text style={{ color: activo ? c.primario : c.textoSuave, fontWeight: '600', marginTop: 4 }}>
              {activo ? '● Reserva en la app' : '○ Solo información y contacto'}
            </Text>
          </Pressable>
        )
      }}
    />
  )
}

const estilos = StyleSheet.create({
  tarjeta: { borderWidth: 1, borderRadius: 12, padding: 14, gap: 2 },
  nombre: { fontSize: 16, fontWeight: '600' },
})
