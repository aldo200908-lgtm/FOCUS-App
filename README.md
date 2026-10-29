# FOCUS

Tu espacio para concentrarte. Aplicación Flutter en español, Android primero, con interfaz Liquid Glass oscura y funcionamiento local.

## Ejecutar

Flutter **3.47.8** (Dart 3.13.7), JDK 17 o 21 y Android SDK 35/36 (NDK 28.2.13676358) para Android.

```sh
flutter pub get
flutter run
```

Para revisar la interfaz en navegador:

```sh
flutter run -d chrome
```

## Funciones

- Inicio con saludo personalizable, paisaje decorativo, progreso diario y tarea prioritaria.
- Tareas: crear, editar, completar, reabrir, filtrar y eliminar con confirmación; categorías y prioridades.
- Pomodoro: enfoque y descanso configurables, pausa, reanudación, reinicio y tarea seleccionada.
- Progreso: minutos persistidos, gráfico de 7 días, tareas completadas, XP, niveles, rachas y tres logros.
- Ajustes: nombre, duraciones y movimiento reducido; se respeta también la preferencia del sistema.
- Persistencia offline sin cuentas, anuncios, servicios de pago ni permisos de notificaciones.

## Datos y temporizador

`lib/core` contiene modelos, repositorio y controlador observable; `lib/screens` las cinco pantallas; `lib/ui` los componentes reutilizables. SharedPreferences guarda un documento JSON versionado con escrituras serializadas. Un error de lectura conserva los datos y ofrece reintentar; un error de escritura muestra un aviso persistente con reintento. No borres datos ni desinstales la app para resolver errores: eso elimina el almacenamiento local. No hay sincronización ni copia de seguridad remota; el backup automático de Android está desactivado.

El temporizador persiste una fecha de finalización y se reconcilia al volver a primer plano o abrir la app. Una sesión de enfoque completada se registra una sola vez; las sesiones parciales no otorgan minutos/XP. No se inician automáticamente nuevas sesiones. El descanso no suma minutos de enfoque.

**Android:** el sistema puede suspender o terminar el proceso en segundo plano. Esta versión no incluye servicio en primer plano, alarma, sonido ni notificaciones del sistema; no garantiza avisos con la aplicación cerrada. Recupera y registra una sesión vencida al abrir. Un cierre forzado inmediatamente después de tocar un control podría interrumpir una escritura pendiente; SharedPreferences es almacenamiento local para el MVP, no una base de datos con garantía transaccional.

**XP:** 20 por la primera finalización de cada tarea y 50 por sesión de enfoque. Reabrir/completar una tarea no duplica XP. El historial de XP se conserva aunque se elimine la tarea; el contador de tareas completadas refleja las tareas actuales. Cada nivel necesita 200 XP. La racha cuenta días locales consecutivos con una sesión o una primera finalización y se mantiene durante el día siguiente hasta que exista un día sin actividad. El gráfico asigna cada sesión al día local en que terminó.

## Diseño y accesibilidad

Fondo `#0B0B0D`, acento `#FF8A3D`, Inter local, radios de 28 px. `GlassCard` recorta el blur de 24 px mediante ClipRRect; solo navegación y paneles destacados usan BackdropFilter. Las listas usan translucidez sin blur por tarjeta. La fotografía está aislada con RepaintBoundary y excluida de semántica. Las transiciones usan ease-out de 300 ms o duración cero con movimiento reducido. Navegación con etiquetas y acciones semánticas, tooltips, texto adaptable y formularios desplazables con teclado.

La dirección naranja solicitada sustituye al verde menta de la especificación inicial. Consulta [diseño](docs/design/LIQUID_GLASS.md) y [fuentes y licencias de recursos](docs/ASSETS.md).

## Verificación

```sh
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build web --release
flutter build apk --debug
```

GitHub Actions ejecuta formato, análisis, pruebas y compilación Android. Publica `focus-android-debug` como artefacto. El APK es de desarrollo; la publicación en Play Store requiere firma de distribución propia. No se incluyen claves.

Las 18 pruebas cubren CRUD/persistencia, sesiones recuperadas sin duplicados, pausa, descansos, rachas, errores de guardado, cambio de día, atribución de sesiones pausadas, límites Unicode, acciones de lector de pantalla, navegación/formularios a 360 y 390 px y texto ampliado al 160 %. Las capturas web móviles sirven para revisar composición; no sustituyen mediciones de rendimiento en un Android físico.

## Capturas móviles

[Inicio](docs/screenshots/01-inicio.png) · [Tareas](docs/screenshots/02-tareas.png) · [Concentración](docs/screenshots/03-concentración.png) · [Progreso](docs/screenshots/04-progreso.png) · [Ajustes](docs/screenshots/05-ajustes.png)
