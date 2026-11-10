import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { Stack } from 'expo-router'
import * as SplashScreen from 'expo-splash-screen'
import { StatusBar } from 'expo-status-bar'
import { useEffect } from 'react'
import { ProveedorSesion, useSesion } from '../lib/sesion'
import { useTema } from '../tema'

SplashScreen.preventAutoHideAsync()

const queryClient = new QueryClient({
  defaultOptions: { queries: { staleTime: 30_000, retry: 1 } },
})

function Navegacion() {
  const { sesion, cargando } = useSesion()
  const c = useTema()

  useEffect(() => {
    if (!cargando) SplashScreen.hideAsync()
  }, [cargando])

  if (cargando) return null

  return (
    <Stack
      screenOptions={{
        headerStyle: { backgroundColor: c.superficie },
        headerTintColor: c.texto,
        contentStyle: { backgroundColor: c.fondo },
      }}
    >
      {/* El mapa (inicio) es público: cualquiera ve el catastro. Reservar exige sesión. */}
      <Stack.Screen name="index" options={{ title: 'ValpoCanchas' }} />
      <Stack.Protected guard={!sesion}>
        <Stack.Screen name="ingresar" options={{ title: 'Ingresar' }} />
        <Stack.Screen name="registro" options={{ title: 'Crear cuenta' }} />
        <Stack.Screen name="recuperar" options={{ title: 'Recuperar contraseña' }} />
      </Stack.Protected>
      <Stack.Protected guard={Boolean(sesion)} redirectTo="/ingresar">
        <Stack.Screen name="perfil" options={{ title: 'Mi perfil' }} />
      </Stack.Protected>
    </Stack>
  )
}

export default function Layout() {
  return (
    <QueryClientProvider client={queryClient}>
      <ProveedorSesion>
        <StatusBar style="auto" />
        <Navegacion />
      </ProveedorSesion>
    </QueryClientProvider>
  )
}
