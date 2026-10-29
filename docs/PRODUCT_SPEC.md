# FOCUS — especificación inicial

**Objetivo:** ayudar a las personas a empezar tareas, concentrarse y mantener hábitos con una experiencia rápida y motivadora.

**Tecnología:** Flutter y Dart, Android primero, funcionamiento offline en el núcleo.

**Diseño:** oscuro, elegante, verde menta, tarjetas limpias y navegación sencilla.

## Pantallas
1. Inicio: tarea prioritaria, progreso diario y acción rápida.
2. Tareas: lista, creación, edición, prioridad y finalización.
3. Concentración: temporizador Pomodoro con sesiones registradas.
4. Progreso: estadísticas, XP y rachas.
5. Ajustes: duración de sesiones, notificaciones y preferencias.

## Criterios de aceptación MVP
- Las tareas sobreviven al reinicio de la app.
- El temporizador funciona al navegar entre pantallas; documentar límites en segundo plano.
- No se pierde una sesión guardada tras cerrar y reabrir.
- Las estadísticas se calculan desde datos persistidos.
- Se incluyen pruebas y workflow de compilación Android mediante GitHub Actions.

## Fase posterior
Asistente de IA para descomponer tareas y sugerir planes; evaluar privacidad, costo y conectividad antes de implementarlo.
