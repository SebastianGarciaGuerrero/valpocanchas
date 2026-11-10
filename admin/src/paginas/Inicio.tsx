import { useQuery } from '@tanstack/react-query'
import { Aviso } from '../componentes/ui'
import { useSesion } from '../lib/sesion'
import { supabase } from '../lib/supabase'

type EstadoRecinto = 'catastro' | 'activo' | 'oculto'

interface RecintoResumen {
  id: number
  nombre: string
  sector: string | null
  estado: EstadoRecinto
  fuente: string
  canchas: { count: number }[]
}

const ETIQUETA_ESTADO: Record<EstadoRecinto, string> = {
  catastro: 'En catastro',
  activo: 'Recibe reservas',
  oculto: 'Oculto',
}

const ESTILO_ESTADO: Record<EstadoRecinto, string> = {
  catastro: 'bg-slate-100 text-slate-700 dark:bg-slate-800 dark:text-slate-300',
  activo: 'bg-teal-100 text-teal-800 dark:bg-teal-900/60 dark:text-teal-200',
  oculto: 'bg-amber-100 text-amber-900 dark:bg-amber-900/50 dark:text-amber-200',
}

function useRecintos(soloMios: boolean, idUsuario?: string) {
  return useQuery({
    queryKey: ['recintos', soloMios ? idUsuario : 'todos'],
    queryFn: async () => {
      let consulta = supabase
        .from('recintos')
        .select('id, nombre, sector, estado, fuente, canchas(count)')
        .order('nombre')
      if (soloMios && idUsuario) consulta = consulta.eq('admin_id', idUsuario)
      const { data, error } = await consulta
      if (error) throw error
      return data as RecintoResumen[]
    },
  })
}

function TablaRecintos({ recintos }: { recintos: RecintoResumen[] }) {
  return (
    <div className="overflow-hidden rounded-xl border border-slate-200 bg-white dark:border-slate-800 dark:bg-slate-900">
      <table className="w-full text-left text-sm">
        <thead className="bg-slate-50 text-slate-500 dark:bg-slate-800/60 dark:text-slate-400">
          <tr>
            <th className="px-4 py-3 font-medium">Recinto</th>
            <th className="px-4 py-3 font-medium">Sector</th>
            <th className="px-4 py-3 font-medium">Canchas</th>
            <th className="px-4 py-3 font-medium">Estado</th>
            <th className="px-4 py-3 font-medium">Fuente</th>
          </tr>
        </thead>
        <tbody className="divide-y divide-slate-100 dark:divide-slate-800">
          {recintos.map((r) => (
            <tr key={r.id}>
              <td className="px-4 py-3 font-medium">{r.nombre}</td>
              <td className="px-4 py-3 text-slate-600 dark:text-slate-400">{r.sector ?? '—'}</td>
              <td className="px-4 py-3">{r.canchas[0]?.count ?? 0}</td>
              <td className="px-4 py-3">
                <span className={`rounded-full px-2.5 py-1 text-xs font-medium ${ESTILO_ESTADO[r.estado]}`}>
                  {ETIQUETA_ESTADO[r.estado]}
                </span>
              </td>
              <td className="px-4 py-3 uppercase text-slate-500 dark:text-slate-400">{r.fuente}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  )
}

function Cifra({ valor, etiqueta }: { valor: number; etiqueta: string }) {
  return (
    <div className="rounded-xl border border-slate-200 bg-white p-4 dark:border-slate-800 dark:bg-slate-900">
      <div className="text-3xl font-semibold tabular-nums">{valor}</div>
      <div className="text-sm text-slate-500 dark:text-slate-400">{etiqueta}</div>
    </div>
  )
}

export default function Inicio() {
  const { perfil } = useSesion()
  const esSuper = perfil?.rol === 'superadmin'
  const esDueno = perfil?.rol === 'admin_recinto'
  const recintos = useRecintos(!esSuper, perfil?.id)

  if (perfil?.rol === 'jugador') {
    return (
      <div className="max-w-xl space-y-4">
        <h1 className="text-2xl font-semibold">Hola, {perfil.nombre_completo.split(' ')[0] || 'jugador'}</h1>
        <Aviso>
          Tu cuenta es de jugador: las canchas se buscan y se reservan desde la app ValpoCanchas. Si administras un recinto,
          pide a la administración que lo active y te lo asigne; después verás aquí su calendario.
        </Aviso>
      </div>
    )
  }

  const lista = recintos.data ?? []
  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-semibold">{esSuper ? 'Catastro de recintos' : 'Mis recintos'}</h1>
      {esSuper && (
        <div className="grid grid-cols-2 gap-4 md:grid-cols-4">
          <Cifra valor={lista.length} etiqueta="Recintos" />
          <Cifra valor={lista.filter((r) => r.estado === 'activo').length} etiqueta="Reciben reservas" />
          <Cifra valor={lista.reduce((s, r) => s + (r.canchas[0]?.count ?? 0), 0)} etiqueta="Canchas" />
          <Cifra valor={lista.filter((r) => r.estado === 'catastro').length} etiqueta="Por activar" />
        </div>
      )}
      {recintos.isPending && <p className="text-slate-500">Cargando recintos…</p>}
      {recintos.isError && <Aviso tono="error">No pudimos cargar los recintos. Revisa tu conexión.</Aviso>}
      {recintos.isSuccess && lista.length === 0 && (
        <Aviso>{esDueno ? 'Todavía no tienes recintos asignados.' : 'El catastro está vacío.'}</Aviso>
      )}
      {lista.length > 0 && <TablaRecintos recintos={lista} />}
    </div>
  )
}
