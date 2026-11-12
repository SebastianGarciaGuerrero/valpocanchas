import * as Location from 'expo-location'
import { useMemo, useRef, useState } from 'react'
import { Platform, Pressable, StyleSheet, Text, useColorScheme, View } from 'react-native'
import MapView, { Marker, PROVIDER_GOOGLE, type Region } from 'react-native-maps'
import Supercluster from 'supercluster'
import type { Recinto } from '../lib/recintos'
import { TACTIL, useTema } from '../tema'
import { ESTILO_MAPA_OSCURO } from './estiloMapaOscuro'
import { Icono, Punto } from './Icono'

// Centro de Valparaíso: el mapa abre aquí al instante, sin esperar el GPS (RNF-01).
const VALPARAISO: Region = { latitude: -33.0472, longitude: -71.6127, latitudeDelta: 0.09, longitudeDelta: 0.09 }

const PIN_ACTIVO = require('../../assets/pines/pin-activo.png')
const PIN_CATASTRO = require('../../assets/pines/pin-catastro.png')
const PIN_ACTIVO_SEL = require('../../assets/pines/pin-activo-sel.png')
const PIN_CATASTRO_SEL = require('../../assets/pines/pin-catastro-sel.png')

const zoomDe = (region: Region) => Math.max(0, Math.min(20, Math.round(Math.log2(360 / region.longitudeDelta))))

interface Props {
  recintos: Recinto[]
  /** Recinto con la ficha abierta: su pin se dibuja más grande. */
  seleccionado: number | null
  onAbrir: (id: number) => void
  /** Se tocó el mapa fuera de un pin. */
  onTocarMapa: () => void
}

export default function MapaRecintos({ recintos, seleccionado, onAbrir, onTocarMapa }: Props) {
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

  function abrirRecinto(r: Recinto) {
    onAbrir(r.id)
    // Deja el pin en el tercio superior, para que la ficha no lo tape.
    mapa.current?.animateToRegion(
      {
        latitude: r.latitud - region.latitudeDelta * 0.22,
        longitude: r.longitud,
        latitudeDelta: region.latitudeDelta,
        longitudeDelta: region.longitudeDelta,
      },
      300,
    )
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
        onPress={(e) => {
          // En iOS tocar un pin también dispara este evento; en ese caso no se cierra la ficha.
          if (e.nativeEvent.action !== 'marker-press') onTocarMapa()
        }}
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
          const elegido = r.id === seleccionado
          const activo = r.estado === 'activo'
          return (
            <Marker
              // La clave cambia al seleccionar para que Android vuelva a dibujar el pin con la imagen nueva.
              key={`recinto-${r.id}-${elegido ? 'sel' : 'normal'}`}
              coordinate={{ latitude: latitud, longitude: longitud }}
              image={elegido ? (activo ? PIN_ACTIVO_SEL : PIN_CATASTRO_SEL) : activo ? PIN_ACTIVO : PIN_CATASTRO}
              zIndex={elegido ? 10 : 1}
              tracksViewChanges={false}
              onPress={() => abrirRecinto(r)}
              accessibilityLabel={`${r.nombre}. ${activo ? 'Recibe reservas' : 'Solo información'}.`}
            />
          )
        })}
      </MapView>

      {aviso && (
        <View style={[estilos.aviso, { backgroundColor: c.superficie, borderColor: c.borde }]}>
          <Text style={{ color: c.texto, fontSize: 14 }}>{aviso}</Text>
        </View>
      )}

      {/* Leyenda: los estados se distinguen por forma (relleno / hueco) y por texto, no solo por color. */}
      <View style={[estilos.leyenda, { backgroundColor: c.superficie, borderColor: c.borde }]}>
        <View style={estilos.leyendaFila}>
          <Punto relleno color={c.primario} />
          <Text style={{ color: c.texto, fontSize: 12 }}>Reserva en la app</Text>
        </View>
        <View style={estilos.leyendaFila}>
          <Punto relleno={false} color={c.primario} />
          <Text style={{ color: c.texto, fontSize: 12 }}>Solo información</Text>
        </View>
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
        <Icono nombre="ubicacion" color={c.primario} tam={24} />
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
  aviso: { position: 'absolute', top: 12, left: 16, right: 16, borderWidth: 1, borderRadius: 10, padding: 12 },
  leyenda: { position: 'absolute', left: 12, bottom: 24, borderWidth: 1, borderRadius: 10, paddingVertical: 8, paddingHorizontal: 10, gap: 4 },
  leyendaFila: { flexDirection: 'row', alignItems: 'center', gap: 8 },
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
