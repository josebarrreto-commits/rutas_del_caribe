# Rutas del Caribe — Flutter

Proyecto base de aplicación móvil para gestión de cooperativa de transporte.

## Requisitos
- Flutter SDK instalado
- Android Studio o emulador / dispositivo Android
- Visual Studio Code con extensiones Flutter y Dart

## Ejecutar
Desde la carpeta del proyecto:

```bash
flutter pub get
flutter run
```

## Estructura
- `lib/config`: colores y tema visual.
- `lib/routes`: navegación de la aplicación.
- `lib/models`: modelos de datos.
- `lib/screens/auth`: splash, acceso y recuperación de contraseña.
- `lib/screens/dashboard`: panel principal.
- `lib/screens/modules`: módulos de gestión.
- `lib/services`: conexión HTTP, autenticación y sesión.
- `lib/widgets`: componentes reutilizables.
- `assets`: imágenes, iconos y fuentes.

## Nota importante sobre la API
La pantalla de acceso y los módulos están preparados visualmente. El inicio de sesión todavía navega al panel como demostración. Antes de integrar la API real, se deben confirmar con el profesor los endpoints, campos JSON, tipo de autenticación y respuestas. Los endpoints de autenticación incluidos son los que se habían definido previamente como referencia y deben verificarse con la API real.
