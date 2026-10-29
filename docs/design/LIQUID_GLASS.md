# FOCUS · Liquid Glass

La solicitud del 29-10-2026 actualiza la dirección visual inicial: fondo #0B0B0D y acento único #FF8A3D. Flutter, Android primero, español y núcleo offline se mantienen.

## Diseño e implementación

Inicio editorial con paisaje oscuro, saludo editable en Ajustes, progreso real y tarea prioritaria. Tareas con filtros, edición, eliminación confirmada y prioridades. Concentración con fotografía, anillo Pomodoro, pausa/reanudación/reinicio y descanso configurable. Progreso deriva minutos, tareas, XP, niveles, rachas y logros de datos locales. Ajustes permite nombre, duraciones y movimiento reducido.

Se elige Flutter Material con componentes de vidrio propios, ChangeNotifier y SharedPreferences, sin servicios remotos. Frente a incorporar un paquete de UI o motor de estado adicional, esta opción reduce dependencias y permite controlar el coste de blur. Persistir un único documento versionado evita escrituras parciales entre entidades; las escrituras se serializan.

ClipRRect limita BackdropFilter a tarjetas destacadas y la navegación. Las tarjetas de listas usan transparencia sin filtro para limitar capas. Blur 24 px, superficie blanca 8%, borde 18%, radios 28. Inter local, recursos incluidos con licencias documentadas. Animaciones ease-out de 300 ms; movimiento reducido del sistema o de Ajustes las desactiva.

## Límites

No hay notificaciones de sistema ni servicio en primer plano. El temporizador usa fecha de finalización persistida: sigue al navegar y se reconcilia al volver o abrir la app. Android puede suspender la ejecución; el sonido y las notificaciones no están garantizados con la app cerrada. No se simula que exista permiso de notificaciones.

## Validación

Pruebas de persistencia, CRUD, finalización exactamente una vez, pausa, recuperación tras reinicio, fechas y estadísticas. Pruebas de navegación y formularios a 360 y 390 px y texto ampliado. Análisis estático, compilación web para inspección visual, CI con APK Android debug (sin firma de distribución).
