import type { ReactNode } from 'react'
import {
  ActivityIndicator,
  KeyboardAvoidingView,
  Platform,
  Pressable,
  ScrollView,
  StyleSheet,
  Text,
  TextInput,
  View,
  type TextInputProps,
} from 'react-native'
import { TACTIL, useTema } from '../tema'
import { Icono, type NombreIcono } from './Icono'

/** Pantalla con scroll que no queda tapada por el teclado. */
export function Formulario({ children }: { children: ReactNode }) {
  const c = useTema()
  return (
    <KeyboardAvoidingView style={{ flex: 1, backgroundColor: c.fondo }} behavior={Platform.OS === 'ios' ? 'padding' : undefined}>
      <ScrollView contentContainerStyle={estilos.formulario} keyboardShouldPersistTaps="handled">
        {children}
      </ScrollView>
    </KeyboardAvoidingView>
  )
}

export function Titulo({ children }: { children: ReactNode }) {
  const c = useTema()
  return <Text style={[estilos.titulo, { color: c.texto }]}>{children}</Text>
}

export function Parrafo({ children }: { children: ReactNode }) {
  const c = useTema()
  return <Text style={[estilos.parrafo, { color: c.textoSuave }]}>{children}</Text>
}

interface CampoProps extends TextInputProps {
  etiqueta: string
}

export function Campo({ etiqueta, ...props }: CampoProps) {
  const c = useTema()
  return (
    <View style={estilos.campo}>
      <Text style={[estilos.etiqueta, { color: c.texto }]}>{etiqueta}</Text>
      <TextInput
        accessibilityLabel={etiqueta}
        placeholderTextColor={c.textoSuave}
        style={[estilos.input, { color: c.texto, backgroundColor: c.superficie, borderColor: c.borde }]}
        {...props}
      />
    </View>
  )
}

interface BotonProps {
  texto: string
  onPress: () => void
  cargando?: boolean
  variante?: 'primario' | 'secundario'
  icono?: NombreIcono
}

export function Boton({ texto, onPress, cargando, variante = 'primario', icono }: BotonProps) {
  const c = useTema()
  const primario = variante === 'primario'
  return (
    <Pressable
      accessibilityRole="button"
      accessibilityState={{ disabled: cargando, busy: cargando }}
      disabled={cargando}
      onPress={onPress}
      style={({ pressed }) => [
        estilos.boton,
        primario ? { backgroundColor: c.primario } : { borderWidth: 1, borderColor: c.borde, backgroundColor: c.superficie },
        (pressed || cargando) && { opacity: 0.7 },
      ]}
    >
      {cargando ? (
        <ActivityIndicator color={primario ? c.primarioTexto : c.texto} />
      ) : (
        <>
          {icono && <Icono nombre={icono} color={primario ? c.primarioTexto : c.texto} tam={20} />}
          <Text style={[estilos.botonTexto, { color: primario ? c.primarioTexto : c.texto }]} numberOfLines={1}>
            {texto}
          </Text>
        </>
      )}
    </Pressable>
  )
}

export function Aviso({ tono, children }: { tono: 'error' | 'exito'; children: ReactNode }) {
  const c = useTema()
  return (
    <View
      accessibilityLiveRegion="polite"
      style={[estilos.aviso, { backgroundColor: tono === 'error' ? c.errorFondo : c.exitoFondo }]}
    >
      <Text style={{ color: tono === 'error' ? c.error : c.exito, fontSize: 15 }}>{children}</Text>
    </View>
  )
}

export function Enlace({ texto, onPress }: { texto: string; onPress: () => void }) {
  const c = useTema()
  return (
    <Pressable accessibilityRole="link" onPress={onPress} style={estilos.enlace} hitSlop={8}>
      <Text style={{ color: c.primario, fontSize: 15, fontWeight: '600' }}>{texto}</Text>
    </Pressable>
  )
}

const estilos = StyleSheet.create({
  formulario: { padding: 24, gap: 16, flexGrow: 1 },
  titulo: { fontSize: 26, fontWeight: '700' },
  parrafo: { fontSize: 15, lineHeight: 21 },
  campo: { gap: 6 },
  etiqueta: { fontSize: 14, fontWeight: '600' },
  input: { minHeight: TACTIL, borderWidth: 1, borderRadius: 10, paddingHorizontal: 14, fontSize: 16 },
  boton: { minHeight: TACTIL, borderRadius: 10, flexDirection: 'row', gap: 8, alignItems: 'center', justifyContent: 'center', paddingHorizontal: 16 },
  botonTexto: { fontSize: 16, fontWeight: '600' },
  aviso: { borderRadius: 10, padding: 12 },
  enlace: { minHeight: TACTIL, alignItems: 'center', justifyContent: 'center' },
})
