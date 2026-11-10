import { router, Stack } from 'expo-router'
import { useState } from 'react'
import { ActivityIndicator, Pressable, StyleSheet, Text, View } from 'react-native'
import BarraFiltros from '../componentes/BarraFiltros'
import ListaRecintos from '../componentes/ListaRecintos'
import MapaRecintos from '../componentes/MapaRecintos'
import { Boton } from '../componentes/ui'
import { filtrar, SIN_FILTROS, useRecintos, type Filtros } from '../lib/recintos'
import { useSesion } from '../lib/sesion'
import { supabaseConfigurado } from '../lib/supabase'
import { TACTIL, useTema } from '../tema'

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
  const recintos = useRecintos()
  const [filtros, setFiltros] = useState<Filtros>(SIN_FILTROS)
  const [vista, setVista] = useState<'mapa' | 'lista'>('mapa')

  const abrir = (id: number) => router.push({ pathname: '/recinto/[id]', params: { id: String(id) } })

  let contenido
  if (!supabaseConfigurado) {
    contenido = <Text style={[estilos.mensaje, { color: c.error }]}>Falta configurar Supabase: revisa movil/.env y reinicia la app.</Text>
  } else if (recintos.isPending) {
    contenido = <ActivityIndicator style={{ marginTop: 40 }} color={c.primario} size="large" />
  } else if (recintos.isError) {
    contenido = (
      <View style={{ padding: 24, gap: 16 }}>
        <Text style={[estilos.mensaje, { color: c.error, padding: 0 }]}>No pudimos cargar las canchas. Revisa tu conexión.</Text>
        <Boton texto="Reintentar" onPress={() => recintos.refetch()} cargando={recintos.isRefetching} />
      </View>
    )
  } else {
    const visibles = filtrar(recintos.data, filtros)
    contenido = (
      <>
        <BarraFiltros
          recintos={recintos.data}
          filtros={filtros}
          onCambiar={setFiltros}
          vista={vista}
          onCambiarVista={() => setVista(vista === 'mapa' ? 'lista' : 'mapa')}
        />
        <View style={{ flex: 1 }}>
          {vista === 'mapa' ? (
            <MapaRecintos recintos={visibles} onAbrir={abrir} margenSuperior={36} />
          ) : (
            <ListaRecintos recintos={visibles} onAbrir={abrir} />
          )}
          {/* Cuántos recintos se ven con los filtros actuales. */}
          {vista === 'mapa' && (
            <View pointerEvents="none" style={estilos.contadorCaja}>
              <Text style={[estilos.contador, { backgroundColor: c.superficie, color: c.texto, borderColor: c.borde }]}>
                {visibles.length === recintos.data.length
                  ? `${visibles.length} recintos`
                  : `${visibles.length} de ${recintos.data.length} recintos`}
              </Text>
            </View>
          )}
        </View>
      </>
    )
  }

  return (
    <View style={{ flex: 1, backgroundColor: c.fondo }}>
      <Stack.Screen options={{ headerRight: () => <BotonEncabezado /> }} />
      {contenido}
    </View>
  )
}

const estilos = StyleSheet.create({
  mensaje: { padding: 24, fontSize: 16, textAlign: 'center' },
  contadorCaja: { position: 'absolute', top: 8, left: 0, right: 0, alignItems: 'center' },
  contador: { fontSize: 13, fontWeight: '600', borderWidth: 1, borderRadius: 14, paddingHorizontal: 12, paddingVertical: 4, overflow: 'hidden' },
})
