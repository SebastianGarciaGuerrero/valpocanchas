import { useEffect, useState } from 'react'
import { Animated, BackHandler, Linking, Pressable, ScrollView, StyleSheet, Text, useWindowDimensions, View } from 'react-native'
import { useSafeAreaInsets } from 'react-native-safe-area-context'
import {
  formatoPrecio,
  NOMBRE_CONSERVACION,
  NOMBRE_SUPERFICIE,
  NOMBRE_TIPO,
  type Cancha,
  type Recinto,
} from '../lib/recintos'
import { TACTIL, useTema } from '../tema'
import { Icono, Punto } from './Icono'
import { Boton } from './ui'

const FUENTE: Record<Recinto['fuente'], string> = {
  ind: 'Fuente: catastro del Instituto Nacional de Deportes (IND).',
  osm: 'Fuente: © OpenStreetMap contributors. El tipo de cancha está estimado por su tamaño en el mapa.',
  municipal: 'Fuente: Municipalidad de Valparaíso.',
  manual: 'Información ingresada por el equipo de ValpoCanchas.',
}

const abrir = (url: string) => Linking.openURL(url).catch(() => {})
const soloDigitos = (telefono: string) => telefono.replace(/\D/g, '')

function Etiqueta({ texto }: { texto: string }) {
  const c = useTema()
  return (
    <View style={[estilos.etiqueta, { borderColor: c.borde, backgroundColor: c.fondo }]}>
      <Text style={{ color: c.texto, fontSize: 13 }}>{texto}</Text>
    </View>
  )
}

function FilaCancha({ cancha }: { cancha: Cancha }) {
  const c = useTema()
  return (
    <View style={[estilos.cancha, { borderColor: c.borde }]}>
      <View style={estilos.canchaTitulo}>
        <Text style={{ color: c.texto, fontSize: 15, fontWeight: '600', flex: 1 }}>{cancha.nombre}</Text>
        {cancha.precio_hora !== null && (
          <Text style={{ color: c.primario, fontSize: 15, fontWeight: '700' }}>{formatoPrecio(cancha.precio_hora)} / hora</Text>
        )}
      </View>
      <View style={estilos.etiquetas}>
        <Etiqueta texto={NOMBRE_TIPO[cancha.tipo]} />
        {cancha.superficie && <Etiqueta texto={NOMBRE_SUPERFICIE[cancha.superficie]} />}
        {cancha.techada && <Etiqueta texto="Techada" />}
        {cancha.iluminacion && <Etiqueta texto="Con iluminación" />}
      </View>
    </View>
  )
}

function Dato({ etiqueta, valor }: { etiqueta: string; valor: string }) {
  const c = useTema()
  return (
    <View style={{ gap: 2 }}>
      <Text style={{ color: c.textoSuave, fontSize: 13 }}>{etiqueta}</Text>
      <Text style={{ color: c.texto, fontSize: 15 }}>{valor}</Text>
    </View>
  )
}

/**
 * Ficha del recinto como panel inferior dibujado en la misma pantalla (sin navegación ni
 * panel nativo). El mapa sigue usable detrás; el botón atrás de Android lo cierra.
 */
export default function PanelRecinto({ recinto: r, onCerrar }: { recinto: Recinto; onCerrar: () => void }) {
  const c = useTema()
  const { height } = useWindowDimensions()
  const margen = useSafeAreaInsets()
  const [entrada] = useState(() => new Animated.Value(0))

  useEffect(() => {
    entrada.setValue(0)
    Animated.timing(entrada, { toValue: 1, duration: 180, useNativeDriver: true }).start()
  }, [entrada, r.id])

  useEffect(() => {
    const sub = BackHandler.addEventListener('hardwareBackPress', () => {
      onCerrar()
      return true
    })
    return () => sub.remove()
  }, [onCerrar])

  const activo = r.estado === 'activo'
  const telefono = r.telefono_contacto
  const comoLlegar = `https://www.google.com/maps/dir/?api=1&destination=${r.latitud},${r.longitud}`
  const hayAdministracion = r.institucion_administradora || r.tipo_administracion || r.estado_conservacion

  return (
    <Animated.View
      accessibilityViewIsModal
      style={[
        estilos.panel,
        {
          backgroundColor: c.superficie,
          borderColor: c.borde,
          maxHeight: height * 0.58,
          paddingBottom: margen.bottom,
          opacity: entrada,
          transform: [{ translateY: entrada.interpolate({ inputRange: [0, 1], outputRange: [32, 0] }) }],
        },
      ]}
    >
      <View style={[estilos.tirador, { backgroundColor: c.borde }]} />

      <View style={estilos.encabezado}>
        <View style={{ flex: 1, gap: 2 }}>
          <Text style={{ color: c.texto, fontSize: 19, fontWeight: '700' }} numberOfLines={2}>
            {r.nombre}
          </Text>
          {(r.sector || r.direccion) && (
            <Text style={{ color: c.textoSuave, fontSize: 14 }} numberOfLines={2}>
              {[r.sector, r.direccion].filter(Boolean).join(' · ')}
            </Text>
          )}
        </View>
        <Pressable
          accessibilityRole="button"
          accessibilityLabel="Cerrar ficha"
          onPress={onCerrar}
          hitSlop={8}
          style={({ pressed }) => [estilos.cerrar, { backgroundColor: c.fondo }, pressed && { opacity: 0.6 }]}
        >
          <Icono nombre="cerrar" color={c.texto} tam={20} />
        </Pressable>
      </View>

      <ScrollView style={{ flexGrow: 0 }} contentContainerStyle={estilos.contenido} showsVerticalScrollIndicator={false}>
        <View style={[estilos.estado, { backgroundColor: activo ? c.exitoFondo : c.fondo }]}>
          <View style={estilos.estadoTitulo}>
            <Punto relleno={activo} color={activo ? c.exito : c.textoSuave} />
            <Text style={{ color: activo ? c.exito : c.texto, fontWeight: '700', fontSize: 14 }}>
              {activo ? 'Recibe reservas en la app' : 'Solo información'}
            </Text>
          </View>
          <Text style={{ color: c.textoSuave, fontSize: 13, lineHeight: 18 }}>
            {activo
              ? 'Pronto podrás elegir tu horario y reservar desde aquí.'
              : telefono
                ? 'Todavía no recibe reservas por la app. Coordina directamente con quien lo administra.'
                : 'Todavía no recibe reservas por la app y aún no tenemos su contacto.'}
          </Text>
        </View>

        <View style={estilos.acciones}>
          <View style={{ flex: 1 }}>
            <Boton texto="Cómo llegar" icono="ruta" onPress={() => abrir(comoLlegar)} />
          </View>
          {telefono && (
            <>
              <View style={{ flex: 1 }}>
                <Boton texto="Llamar" icono="telefono" variante="secundario" onPress={() => abrir(`tel:${telefono}`)} />
              </View>
              <View style={{ flex: 1 }}>
                <Boton texto="WhatsApp" icono="mensaje" variante="secundario" onPress={() => abrir(`https://wa.me/${soloDigitos(telefono)}`)} />
              </View>
            </>
          )}
        </View>

        <Text style={[estilos.seccion, { color: c.texto }]}>
          {r.canchas.length === 1 ? 'Cancha' : `Canchas (${r.canchas.length})`}
        </Text>
        {r.canchas.length === 0 ? (
          <Text style={{ color: c.textoSuave }}>Todavía no hay canchas registradas en este recinto.</Text>
        ) : (
          r.canchas.map((cancha) => <FilaCancha key={cancha.id} cancha={cancha} />)
        )}

        {hayAdministracion && (
          <>
            <Text style={[estilos.seccion, { color: c.texto }]}>Administración</Text>
            <View style={{ gap: 10 }}>
              {r.institucion_administradora && <Dato etiqueta="Administra" valor={r.institucion_administradora} />}
              {r.tipo_administracion && <Dato etiqueta="Tipo de administración" valor={r.tipo_administracion} />}
              {r.estado_conservacion && (
                <Dato etiqueta="Estado de conservación (según catastro)" valor={NOMBRE_CONSERVACION[r.estado_conservacion]} />
              )}
            </View>
          </>
        )}

        {r.descripcion && r.fuente !== 'osm' && (
          <Text style={{ color: c.textoSuave, fontSize: 13, lineHeight: 18 }}>{r.descripcion}</Text>
        )}
        <Text style={{ color: c.textoSuave, fontSize: 12, lineHeight: 17 }}>{FUENTE[r.fuente]}</Text>
      </ScrollView>
    </Animated.View>
  )
}

const estilos = StyleSheet.create({
  panel: {
    position: 'absolute',
    left: 0,
    right: 0,
    bottom: 0,
    borderTopLeftRadius: 20,
    borderTopRightRadius: 20,
    borderWidth: StyleSheet.hairlineWidth,
    elevation: 16,
    shadowColor: '#000',
    shadowOpacity: 0.2,
    shadowRadius: 12,
    shadowOffset: { width: 0, height: -4 },
  },
  tirador: { alignSelf: 'center', width: 40, height: 4, borderRadius: 2, marginTop: 8 },
  encabezado: { flexDirection: 'row', alignItems: 'flex-start', gap: 12, paddingHorizontal: 20, paddingTop: 12, paddingBottom: 10 },
  cerrar: { width: TACTIL - 4, height: TACTIL - 4, borderRadius: (TACTIL - 4) / 2, alignItems: 'center', justifyContent: 'center' },
  contenido: { paddingHorizontal: 20, paddingBottom: 20, gap: 12 },
  estado: { borderRadius: 12, padding: 12, gap: 4 },
  estadoTitulo: { flexDirection: 'row', alignItems: 'center', gap: 8 },
  acciones: { flexDirection: 'row', gap: 8 },
  seccion: { fontSize: 15, fontWeight: '700', marginTop: 4 },
  cancha: { borderWidth: 1, borderRadius: 12, padding: 12, gap: 8 },
  canchaTitulo: { flexDirection: 'row', alignItems: 'center', gap: 8 },
  etiquetas: { flexDirection: 'row', flexWrap: 'wrap', gap: 6 },
  etiqueta: { borderWidth: 1, borderRadius: 8, paddingHorizontal: 8, paddingVertical: 3 },
})
