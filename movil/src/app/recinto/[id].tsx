import { router, useLocalSearchParams } from 'expo-router'
import { ActivityIndicator, Linking, Pressable, ScrollView, StyleSheet, Text, View } from 'react-native'
import { Boton } from '../../componentes/ui'
import {
  formatoPrecio,
  NOMBRE_CONSERVACION,
  NOMBRE_SUPERFICIE,
  NOMBRE_TIPO,
  useRecintos,
  type Cancha,
  type Recinto,
} from '../../lib/recintos'
import { TACTIL, useTema } from '../../tema'

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
        <Text style={{ color: c.texto, fontSize: 16, fontWeight: '600', flex: 1 }}>{cancha.nombre}</Text>
        {cancha.precio_hora !== null && (
          <Text style={{ color: c.primario, fontSize: 16, fontWeight: '700' }}>{formatoPrecio(cancha.precio_hora)} / hora</Text>
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

export default function FichaRecinto() {
  const c = useTema()
  const { id } = useLocalSearchParams<{ id: string }>()
  const recintos = useRecintos()
  const r = recintos.data?.find((x) => String(x.id) === id)

  if (!r) {
    return (
      <View style={[estilos.vacio, { backgroundColor: c.superficie }]}>
        {recintos.isPending ? (
          <ActivityIndicator color={c.primario} />
        ) : (
          <Text style={{ color: c.textoSuave, fontSize: 16 }}>No encontramos este recinto.</Text>
        )}
      </View>
    )
  }

  const activo = r.estado === 'activo'
  const telefono = r.telefono_contacto
  const comoLlegar = `https://www.google.com/maps/dir/?api=1&destination=${r.latitud},${r.longitud}`

  return (
    <ScrollView
      style={{ backgroundColor: c.superficie }}
      contentContainerStyle={estilos.contenido}
      nestedScrollEnabled
    >
      {/* En Android el panel inferior no muestra encabezado nativo: el título y el cierre van en el contenido. */}
      <View style={estilos.encabezado}>
        <View style={{ flex: 1, gap: 2 }}>
          <Text style={{ color: c.texto, fontSize: 21, fontWeight: '700' }}>{r.nombre}</Text>
          {(r.sector || r.direccion) && (
            <Text style={{ color: c.textoSuave, fontSize: 14 }}>{[r.sector, r.direccion].filter(Boolean).join(' · ')}</Text>
          )}
        </View>
        <Pressable
          accessibilityRole="button"
          accessibilityLabel="Cerrar"
          onPress={() => router.back()}
          hitSlop={8}
          style={[estilos.cerrar, { backgroundColor: c.fondo }]}
        >
          <Text style={{ color: c.texto, fontSize: 18 }}>✕</Text>
        </Pressable>
      </View>

      <View style={[estilos.estado, { backgroundColor: activo ? c.exitoFondo : c.fondo, borderColor: c.borde }]}>
        <Text style={{ color: activo ? c.exito : c.texto, fontWeight: '700', fontSize: 15 }}>
          {activo ? '● Recibe reservas en la app' : '○ Solo información'}
        </Text>
        <Text style={{ color: c.textoSuave, fontSize: 14, lineHeight: 20 }}>
          {activo
            ? 'Pronto podrás elegir tu horario y reservar desde aquí.'
            : telefono
              ? 'Este recinto todavía no recibe reservas por la app. Coordina directamente con quien lo administra.'
              : 'Este recinto todavía no recibe reservas por la app y aún no tenemos su contacto.'}
        </Text>
      </View>

      <View style={estilos.acciones}>
        <View style={{ flex: 1 }}>
          <Boton texto="Cómo llegar" onPress={() => abrir(comoLlegar)} />
        </View>
        {telefono && (
          <>
            <View style={{ flex: 1 }}>
              <Boton texto="Llamar" variante="secundario" onPress={() => abrir(`tel:${telefono}`)} />
            </View>
            <View style={{ flex: 1 }}>
              <Boton texto="WhatsApp" variante="secundario" onPress={() => abrir(`https://wa.me/${soloDigitos(telefono)}`)} />
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

      {(r.institucion_administradora || r.tipo_administracion || r.estado_conservacion) && (
        <>
          <Text style={[estilos.seccion, { color: c.texto }]}>Administración</Text>
          <View style={{ gap: 12 }}>
            {r.institucion_administradora && <Dato etiqueta="Administra" valor={r.institucion_administradora} />}
            {r.tipo_administracion && <Dato etiqueta="Tipo de administración" valor={r.tipo_administracion} />}
            {r.estado_conservacion && (
              <Dato etiqueta="Estado de conservación (según catastro)" valor={NOMBRE_CONSERVACION[r.estado_conservacion]} />
            )}
          </View>
        </>
      )}

      {r.descripcion && r.fuente !== 'osm' && <Text style={{ color: c.textoSuave, fontSize: 14, lineHeight: 20 }}>{r.descripcion}</Text>}
      <Text style={{ color: c.textoSuave, fontSize: 12, lineHeight: 17 }}>{FUENTE[r.fuente]}</Text>
    </ScrollView>
  )
}

const estilos = StyleSheet.create({
  vacio: { flex: 1, minHeight: 200, alignItems: 'center', justifyContent: 'center' },
  contenido: { padding: 20, paddingTop: 24, gap: 14, paddingBottom: 40 },
  encabezado: { flexDirection: 'row', alignItems: 'flex-start', gap: 12 },
  cerrar: { width: TACTIL - 4, height: TACTIL - 4, borderRadius: (TACTIL - 4) / 2, alignItems: 'center', justifyContent: 'center' },
  estado: { borderWidth: 1, borderRadius: 12, padding: 12, gap: 4 },
  acciones: { flexDirection: 'row', gap: 8 },
  seccion: { fontSize: 16, fontWeight: '700', marginTop: 6 },
  cancha: { borderWidth: 1, borderRadius: 12, padding: 12, gap: 8 },
  canchaTitulo: { flexDirection: 'row', alignItems: 'center', gap: 8 },
  etiquetas: { flexDirection: 'row', flexWrap: 'wrap', gap: 6 },
  etiqueta: { borderWidth: 1, borderRadius: 8, paddingHorizontal: 8, paddingVertical: 3 },
})
