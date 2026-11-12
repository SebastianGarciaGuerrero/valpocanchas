import { Pressable, Text } from 'react-native'
import type { Recinto } from '../lib/recintos'
import { useTema } from '../tema'

interface Props {
  recintos: Recinto[]
  seleccionado: number | null
  onAbrir: (id: number) => void
  onTocarMapa: () => void
}

// Marco aproximado de la comuna, para ubicar los puntos en el esquema.
const NORTE = -33.0, SUR = -33.18, OESTE = -71.72, ESTE = -71.5

/**
 * En el navegador no hay mapa nativo: la app está pensada para Android. Este esquema ubica los
 * recintos como puntos sobre un fondo liso y sirve para revisar el diseño del resto de la pantalla.
 */
export default function MapaRecintos({ recintos, seleccionado, onAbrir, onTocarMapa }: Props) {
  const c = useTema()
  return (
    <Pressable onPress={onTocarMapa} style={{ flex: 1, backgroundColor: c.borde }} accessibilityLabel="Esquema del mapa">
      <Text style={{ color: c.textoSuave, fontSize: 13, textAlign: 'center', marginTop: 8 }}>
        Esquema: el mapa real se ve en la app para Android
      </Text>
      {recintos.map((r) => {
        const elegido = r.id === seleccionado
        const tam = elegido ? 22 : 14
        return (
          <Pressable
            key={r.id}
            accessibilityLabel={r.nombre}
            onPress={() => onAbrir(r.id)}
            style={{
              position: 'absolute',
              left: `${((r.longitud - OESTE) / (ESTE - OESTE)) * 100}%`,
              top: `${((NORTE - r.latitud) / (NORTE - SUR)) * 100}%`,
              width: tam,
              height: tam,
              marginLeft: -tam / 2,
              marginTop: -tam / 2,
              borderRadius: tam / 2,
              borderWidth: 2,
              borderColor: elegido ? '#0f172a' : c.primario,
              backgroundColor: elegido ? '#f59e0b' : r.estado === 'activo' ? c.primario : c.superficie,
            }}
          />
        )
      })}
    </Pressable>
  )
}
