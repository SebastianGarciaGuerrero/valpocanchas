import { StyleSheet, Text, View } from 'react-native'
import { Boton, Formulario, Titulo } from '../componentes/ui'
import { useSesion } from '../lib/sesion'
import { useTema } from '../tema'

const NOMBRE_ROL = { jugador: 'Jugador', admin_recinto: 'Administrador de recinto', superadmin: 'Administración general' }

function Dato({ etiqueta, valor }: { etiqueta: string; valor: string }) {
  const c = useTema()
  return (
    <View style={estilos.dato}>
      <Text style={{ color: c.textoSuave, fontSize: 13 }}>{etiqueta}</Text>
      <Text style={{ color: c.texto, fontSize: 16 }}>{valor}</Text>
    </View>
  )
}

export default function Perfil() {
  const { sesion, perfil, cerrarSesion } = useSesion()
  const c = useTema()
  return (
    <Formulario>
      <Titulo>{perfil?.nombre_completo || 'Mi perfil'}</Titulo>
      <View style={[estilos.tarjeta, { backgroundColor: c.superficie, borderColor: c.borde }]}>
        <Dato etiqueta="Correo" valor={sesion?.user.email ?? '—'} />
        <Dato etiqueta="Teléfono" valor={perfil?.telefono || '—'} />
        <Dato etiqueta="Tipo de cuenta" valor={perfil ? NOMBRE_ROL[perfil.rol] : '—'} />
      </View>
      <Boton texto="Cerrar sesión" variante="secundario" onPress={cerrarSesion} />
    </Formulario>
  )
}

const estilos = StyleSheet.create({
  tarjeta: { borderWidth: 1, borderRadius: 12, padding: 16, gap: 14 },
  dato: { gap: 2 },
})
