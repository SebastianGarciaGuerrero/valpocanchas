import { router, Stack } from 'expo-router'
import { useState } from 'react'
import { ActivityIndicator, Pressable, StyleSheet, Text, View } from 'react-native'
import BarraFiltros from '../componentes/BarraFiltros'
import { Icono } from '../componentes/Icono'
import ListaRecintos from '../componentes/ListaRecintos'
import MapaRecintos from '../componentes/MapaRecintos'
import PanelRecinto from '../componentes/PanelRecinto'
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
  const [seleccionado, setSeleccionado] = useState<number | null>(null)

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
    // Si un filtro esconde el recinto abierto, su ficha se cierra sola.
    const abierto = visibles.find((r) => r.id === seleccionado) ?? null
    contenido = (
      <>
        <BarraFiltros recintos={recintos.data} filtros={filtros} onCambiar={setFiltros} />

        <View style={[estilos.franja, { borderBottomColor: c.borde }]}>
          <Text style={{ color: c.textoSuave, fontSize: 14 }} accessibilityLiveRegion="polite">
            {visibles.length === recintos.data.length
              ? `${visibles.length} recintos`
              : `${visibles.length} de ${recintos.data.length} recintos`}
          </Text>
          <Pressable
            accessibilityRole="button"
            onPress={() => setVista(vista === 'mapa' ? 'lista' : 'mapa')}
            hitSlop={8}
            style={({ pressed }) => [estilos.cambiarVista, { borderColor: c.borde, backgroundColor: c.superficie }, pressed && { opacity: 0.7 }]}
          >
            <Icono nombre={vista === 'mapa' ? 'lista' : 'mapa'} color={c.texto} tam={18} />
            <Text style={{ color: c.texto, fontSize: 14, fontWeight: '600' }}>{vista === 'mapa' ? 'Ver lista' : 'Ver mapa'}</Text>
          </Pressable>
        </View>

        <View style={{ flex: 1 }}>
          {vista === 'mapa' ? (
            <MapaRecintos
              recintos={visibles}
              seleccionado={abierto?.id ?? null}
              onAbrir={setSeleccionado}
              onTocarMapa={() => setSeleccionado(null)}
            />
          ) : (
            <ListaRecintos recintos={visibles} onAbrir={setSeleccionado} />
          )}
          {abierto && <PanelRecinto recinto={abierto} onCerrar={() => setSeleccionado(null)} />}
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
  franja: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: 16,
    paddingVertical: 8,
    borderBottomWidth: StyleSheet.hairlineWidth,
  },
  cambiarVista: { minHeight: 36, borderWidth: 1, borderRadius: 18, paddingHorizontal: 14, flexDirection: 'row', gap: 6, alignItems: 'center', justifyContent: 'center' },
})
