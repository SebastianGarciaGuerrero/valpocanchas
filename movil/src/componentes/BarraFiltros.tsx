import { Pressable, ScrollView, StyleSheet, Text, View } from 'react-native'
import {
  hayFiltros,
  NOMBRE_SUPERFICIE,
  NOMBRE_TIPO,
  SIN_FILTROS,
  type Filtros,
  type Recinto,
  type Superficie,
  type TipoCancha,
} from '../lib/recintos'
import { useTema } from '../tema'

const ALTO_FILTROS = 60

interface Props {
  recintos: Recinto[]
  filtros: Filtros
  onCambiar: (f: Filtros) => void
  vista: 'mapa' | 'lista'
  onCambiarVista: () => void
}

function alternar<T>(lista: T[], valor: T): T[] {
  return lista.includes(valor) ? lista.filter((v) => v !== valor) : [...lista, valor]
}

function Chip({ texto, activo, onPress, fijo }: { texto: string; activo: boolean; onPress: () => void; fijo?: boolean }) {
  const c = useTema()
  return (
    <Pressable
      accessibilityRole={fijo ? 'button' : 'checkbox'}
      accessibilityState={fijo ? undefined : { checked: activo }}
      onPress={onPress}
      hitSlop={{ top: 6, bottom: 6 }}
      style={({ pressed }) => [
        estilos.chip,
        { backgroundColor: activo ? c.primario : c.superficie, borderColor: activo ? c.primario : c.borde },
        pressed && { opacity: 0.7 },
      ]}
    >
      {/* La marca ✓ acompaña al color para indicar que el filtro está activo. */}
      <Text style={{ color: activo ? c.primarioTexto : c.texto, fontSize: 14, fontWeight: '600' }}>
        {activo && !fijo ? '✓ ' : ''}
        {texto}
      </Text>
    </Pressable>
  )
}

export default function BarraFiltros({ recintos, filtros, onCambiar, vista, onCambiarVista }: Props) {
  const c = useTema()
  // Solo se ofrecen los tipos y superficies que existen en el catastro.
  const canchas = recintos.flatMap((r) => r.canchas)
  const tipos = (Object.keys(NOMBRE_TIPO) as TipoCancha[]).filter((t) => canchas.some((x) => x.tipo === t))
  const superficies = (Object.keys(NOMBRE_SUPERFICIE) as Superficie[]).filter((s) => canchas.some((x) => x.superficie === s))

  return (
    <View style={[estilos.barra, { backgroundColor: c.fondo, borderBottomColor: c.borde }]}>
      <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={estilos.contenido} keyboardShouldPersistTaps="handled">
        <Chip texto={vista === 'mapa' ? '☰ Lista' : '⌖ Mapa'} activo fijo onPress={onCambiarVista} />
        {hayFiltros(filtros) && <Chip texto="✕ Limpiar" activo={false} fijo onPress={() => onCambiar(SIN_FILTROS)} />}
        <Chip
          texto="Reserva en la app"
          activo={filtros.soloReservables}
          onPress={() => onCambiar({ ...filtros, soloReservables: !filtros.soloReservables })}
        />
        {tipos.map((t) => (
          <Chip
            key={t}
            texto={NOMBRE_TIPO[t]}
            activo={filtros.tipos.includes(t)}
            onPress={() => onCambiar({ ...filtros, tipos: alternar(filtros.tipos, t) })}
          />
        ))}
        {superficies.map((s) => (
          <Chip
            key={s}
            texto={NOMBRE_SUPERFICIE[s]}
            activo={filtros.superficies.includes(s)}
            onPress={() => onCambiar({ ...filtros, superficies: alternar(filtros.superficies, s) })}
          />
        ))}
        <Chip texto="Techada" activo={filtros.techada} onPress={() => onCambiar({ ...filtros, techada: !filtros.techada })} />
        <Chip texto="Con iluminación" activo={filtros.iluminada} onPress={() => onCambiar({ ...filtros, iluminada: !filtros.iluminada })} />
      </ScrollView>
    </View>
  )
}

const estilos = StyleSheet.create({
  barra: { height: ALTO_FILTROS, borderBottomWidth: StyleSheet.hairlineWidth },
  contenido: { paddingHorizontal: 12, gap: 8, alignItems: 'center' },
  chip: { minHeight: 40, borderWidth: 1, borderRadius: 20, paddingHorizontal: 14, justifyContent: 'center' },
})
