import * as Location from 'expo-location'
import { useMemo, useRef, useState } from 'react'
import { Platform, Pressable, StyleSheet, Text, useColorScheme, View } from 'react-native'
import MapView, { Marker, PROVIDER_GOOGLE, type Region } from 'react-native-maps'
import Supercluster from 'supercluster'
import type { Recinto } from '../lib/recintos'
import { TACTIL, useTema } from '../tema'
import { ESTILO_MAPA_OSCURO } from './estiloMapaOscuro'

// Centro de Valparaíso: el mapa abre aquí al instante, sin esperar el GPS (RNF-01).
const VALPARAISO: Region = { latitude: -33.0472, longitude: -71.6127, latitudeDelta: 0.09, longitudeDelta: 0.09 }

const PIN_ACTIVO = require('../../assets/pines/pin-activo.png')
const PIN_CATASTRO = require('../../assets/pines/pin-catastro.png')

const zoomDe = (region: Region) => Math.max(0, Math.min(20, Math.round(Math.log2(360 / region.longitudeDelta))))

interface Props {
  recintos: Recinto[]
  onAbrir: (id: number) => void
  /** Espacio que tapan los filtros arriba, para no esconder controles del mapa. */
  margenSuperior: number
}

export default function MapaRecintos({ recintos, onAbrir, margenSuperior }: Props) {
  const c = useTema()
  const oscuro = useColorScheme() === 'dark'
  const mapa = useRef<MapView>(null)
  const [region, setRegion] = useState(VALPARAISO)
  const [conUbicacion, setConUbicacion] = useState(false)
  const [aviso, setAviso] = useState<string | null>(null)

  // Agrupa los pines cercanos según el zoom (RF-02: clustering).
  const indice = useMemo(() => {
    const sc = new Supercluster<{ recinto: Recinto }>({ radius: 46, maxZoom: 15 })
    sc.load(
      recintos.map((r) => ({
        type: 'Feature' as const,
        properties: { recinto: r },
        geometry: { type: 'Point' as const, coordinates: [r.longitud, r.latitud] },
      })),
    )
    return sc
  }, [recintos])

  const grupos = useMemo(() => {
    const { latitude, longitude, latitudeDelta, longitudeDelta } = region
    return indice.getClusters(
      [longitude - longitudeDelta, latitude - latitudeDelta, longitude + longitudeDelta, latitude + latitudeDelta],
      zoomDe(region),
    )
  }, [indice, region])

  function acercar(idGrupo: number, longitud: number, latitud: number) {
    const zoom = Math.min(indice.getClusterExpansionZoom(idGrupo) + 0.5, 17)
    const delta = 360 / 2 ** zoom
    mapa.current?.animateToRegion({ latitude: latitud, longitude: longitud, latitudeDelta: delta, longitudeDelta: delta }, 350)
  }

  async function irAMiUbicacion() {
    setAviso(null)
    const permiso = await Location.requestForegroundPermissionsAsync()
    if (!permiso.granted) {
      setAviso('Para centrarte en el mapa, permite el acceso a tu ubicación en los ajustes del teléfono.')
      return
    }
    setConUbicacion(true)
    try {
      const pos =
        (await Location.getLastKnownPositionAsync()) ??
        (await Location.getCurrentPositionAsync({ accuracy: Location.Accuracy.Balanced }))
      mapa.current?.animateToRegion(
        { latitude: pos.coords.latitude, longitude: pos.coords.longitude, latitudeDelta: 0.02, longitudeDelta: 0.02 },
        500,
      )
    } catch {
      setAviso('No pudimos obtener tu ubicación. Revisa que el GPS esté encendido.')
    }
  }

  return (
    <View style={{ flex: 1 }}>
      <MapView
        ref={mapa}
        style={StyleSheet.absoluteFill}
        provider={Platform.OS === 'android' ? PROVIDER_GOOGLE : undefined}
        initialRegion={VALPARAISO}
        onRegionChangeComplete={setRegion}
        customMapStyle={oscuro ? ESTILO_MAPA_OSCURO : []}
        userInterfaceStyle={oscuro ? 'dark' : 'light'}
        showsUserLocation={conUbicacion}
        showsMyLocationButton={false}
        toolbarEnabled={false}
        moveOnMarkerPress={false}
        mapPadding={{ top: margenSuperior, right: 0, bottom: 0, left: 0 }}
      >
        {grupos.map((g) => {
          const [longitud, latitud] = g.geometry.coordinates
          if ('cluster' in g.properties && g.properties.cluster) {
            const { cluster_id, point_count } = g.properties
            return (
              <Marker
                key={`grupo-${cluster_id}`}
                coordinate={{ latitude: latitud, longitude: longitud }}
                anchor={{ x: 0.5, y: 0.5 }}
                onPress={() => acercar(cluster_id, longitud, latitud)}
                accessibilityLabel={`${point_count} recintos en esta zona. Toca para acercar.`}
              >
                <View style={[estilos.grupo, { backgroundColor: c.primario, borderColor: c.superficie }]}>
                  <Text style={[estilos.grupoTexto, { color: c.primarioTexto }]}>{point_count}</Text>
                </View>
              </Marker>
            )
          }
          const r = (g.properties as { recinto: Recinto }).recinto
          return (
            <Marker
              key={`recinto-${r.id}`}
              coordinate={{ latitude: latitud, longitude: longitud }}
              image={r.estado === 'activo' ? PIN_ACTIVO : PIN_CATASTRO}
              tracksViewChanges={false}
              onPress={() => onAbrir(r.id)}
              accessibilityLabel={`${r.nombre}. ${r.estado === 'activo' ? 'Recibe reservas' : 'Solo información'}.`}
            />
          )
        })}
      </MapView>

      {aviso && (
        <View style={[estilos.aviso, { backgroundColor: c.superficie, borderColor: c.borde, top: margenSuperior + 8 }]}>
          <Text style={{ color: c.texto, fontSize: 14 }}>{aviso}</Text>
        </View>
      )}

      {/* Leyenda: los estados se distinguen por forma (relleno / hueco) y por texto, no solo por color. */}
      <View style={[estilos.leyenda, { backgroundColor: c.superficie, borderColor: c.borde }]}>
        <Text style={{ color: c.texto, fontSize: 12 }}>● Reserva en la app</Text>
        <Text style={{ color: c.textoSuave, fontSize: 12 }}>○ Solo información</Text>
      </View>

      <Pressable
        accessibilityRole="button"
        accessibilityLabel="Ir a mi ubicación"
        onPress={irAMiUbicacion}
        style={({ pressed }) => [
          estilos.botonUbicacion,
          { backgroundColor: c.superficie, borderColor: c.borde },
          pressed && { opacity: 0.7 },
        ]}
      >
        <Text style={{ fontSize: 22, color: c.primario }}>◎</Text>
      </Pressable>
    </View>
  )
}

const estilos = StyleSheet.create({
  grupo: {
    minWidth: 40,
    height: 40,
    borderRadius: 20,
    borderWidth: 3,
    alignItems: 'center',
    justifyContent: 'center',
    paddingHorizontal: 8,
  },
  grupoTexto: { fontSize: 15, fontWeight: '700' },
  aviso: { position: 'absolute', left: 16, right: 16, borderWidth: 1, borderRadius: 10, padding: 12 },
  leyenda: { position: 'absolute', left: 12, bottom: 24, borderWidth: 1, borderRadius: 10, paddingVertical: 6, paddingHorizontal: 10, gap: 2 },
  botonUbicacion: {
    position: 'absolute',
    right: 16,
    bottom: 24,
    width: TACTIL + 4,
    height: TACTIL + 4,
    borderRadius: (TACTIL + 4) / 2,
    borderWidth: 1,
    alignItems: 'center',
    justifyContent: 'center',
    elevation: 4,
  },
})
