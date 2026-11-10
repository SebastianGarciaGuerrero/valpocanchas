import { useQuery } from '@tanstack/react-query'
import { router, Stack } from 'expo-router'
import { ActivityIndicator, FlatList, Pressable, StyleSheet, Text, View } from 'react-native'
import { useSesion } from '../lib/sesion'
import { supabase, supabaseConfigurado } from '../lib/supabase'
import { TACTIL, useTema } from '../tema'

interface RecintoLista {
  id: number
  nombre: string
  sector: string | null
  estado: 'catastro' | 'activo'
  canchas: { count: number }[]
}

function BotonEncabezado() {
  const { sesion } = useSesion()
  const c = useTema()
  return (
    <Pressable
      accessibilityRole="button"
      hitSlop={10}
      onPress={() => router.push(sesion ? '/perfil' : '/ingresar')}
      style={{ minHeight: TACTIL, justifyContent: 'center', paddingHorizontal: 4 }}
    >
      <Text style={{ color: c.primario, fontSize: 16, fontWeight: '600' }}>{sesion ? 'Mi perfil' : 'Ingresar'}</Text>
    </Pressable>
  )
}

export default function Inicio() {
  const c = useTema()
  const recintos = useQuery({
    queryKey: ['recintos-lista'],
    enabled: supabaseConfigurado,
    queryFn: async () => {
      const { data, error } = await supabase
        .from('recintos')
        .select('id, nombre, sector, estado, canchas(count)')
        .order('estado')
        .order('nombre')
      if (error) throw error
      return data as RecintoLista[]
    },
  })

  return (
    <View style={{ flex: 1 }}>
      <Stack.Screen options={{ headerRight: () => <BotonEncabezado /> }} />
      {!supabaseConfigurado ? (
        <Text style={[estilos.mensaje, { color: c.error }]}>
          Falta configurar Supabase: crea movil/.env.local a partir de .env.example y reinicia la app.
        </Text>
      ) : recintos.isPending ? (
        <ActivityIndicator style={{ marginTop: 40 }} color={c.primario} />
      ) : recintos.isError ? (
        <Text style={[estilos.mensaje, { color: c.error }]}>No pudimos cargar las canchas. Revisa tu conexión.</Text>
      ) : (
        <FlatList
          data={recintos.data}
          keyExtractor={(r) => String(r.id)}
          contentContainerStyle={{ padding: 16, gap: 10 }}
          ListHeaderComponent={
            <Text style={[estilos.resumen, { color: c.textoSuave }]}>
              {recintos.data.length} recintos en el catastro de Valparaíso. El mapa llega en la próxima versión.
            </Text>
          }
          renderItem={({ item }) => {
            const canchas = item.canchas[0]?.count ?? 0
            const activo = item.estado === 'activo'
            return (
              <View style={[estilos.tarjeta, { backgroundColor: c.superficie, borderColor: c.borde }]}>
                <Text style={[estilos.nombre, { color: c.texto }]}>{item.nombre}</Text>
                <Text style={{ color: c.textoSuave }}>
                  {[item.sector, `${canchas} ${canchas === 1 ? 'cancha' : 'canchas'}`].filter(Boolean).join(' · ')}
                </Text>
                {/* El estado va con texto, no solo con color. */}
                <Text style={{ color: activo ? c.primario : c.textoSuave, fontWeight: '600', marginTop: 4 }}>
                  {activo ? '● Reserva en la app' : '○ Solo información y contacto'}
                </Text>
              </View>
            )
          }}
        />
      )}
    </View>
  )
}

const estilos = StyleSheet.create({
  mensaje: { padding: 24, fontSize: 16, textAlign: 'center' },
  resumen: { fontSize: 14, marginBottom: 6 },
  tarjeta: { borderWidth: 1, borderRadius: 12, padding: 14, gap: 2 },
  nombre: { fontSize: 16, fontWeight: '600' },
})
