// Extiende app.json con lo que depende del entorno.
// La clave de Google Maps NO va en el repo: se guarda en Expo (eas env:set) y llega aquí al
// generar el APK. En Expo Go no hace falta: el mapa usa la clave de Expo Go.
export default ({ config }) => ({
  ...config,
  plugins: [
    ...(config.plugins ?? []),
    [
      'expo-location',
      { locationWhenInUsePermission: 'ValpoCanchas usa tu ubicación para mostrarte las canchas más cercanas.' },
    ],
    ['react-native-maps', { androidGoogleMapsApiKey: process.env.GOOGLE_MAPS_API_KEY }],
  ],
})
