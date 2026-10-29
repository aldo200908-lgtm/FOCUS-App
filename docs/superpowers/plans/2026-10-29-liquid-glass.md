# Liquid Glass Implementation Plan

**Goal:** implementar el MVP Flutter offline con la dirección visual solicitada.

**Architecture:** estado central observable con repositorio local inyectable; modelos serializables y pantallas modulares. Los widgets visuales no calculan estadísticas ni gestionan persistencia.

**Tech Stack:** Flutter stable, Dart, shared_preferences, Inter local.

**Spec:** docs/PRODUCT_SPEC.md y docs/design/LIQUID_GLASS.md; solicitud del usuario prevalece para el acento naranja.

## Global Constraints

- Español, Android primero, datos offline, sin servicios de pago ni permisos intrusivos.
- Rama feat/liquid-glass y PR hacia main.
- Blur limitado a superficies acotadas; accesibilidad y movimiento reducido.

## Review Focus

- Reinicio durante sesión: recuperar deadline y registrar una vez.
- Pausa/reanudación y navegación: conservar tiempo restante.
- Doble toque y edición: identidad estable y sin XP duplicado.
- Datos corruptos/escritura fallida: mensaje recuperable, sin sobrescribir silenciosamente.
- Móvil pequeño/texto ampliado: formularios y navegación sin overflow.

## Tareas

- [x] 1. Generar proyecto Android/web y configuración CI. Escribir pruebas del contrato AppState: CRUD persistente, temporizador y estadísticas. Ejecutar en rojo, implementar modelos/repositorio/controlador y ejecutar en verde.
- [x] 2. Implementar tema, GlassCard, botones, navegación y cinco pantallas. Estado consumido: AppState; operaciones addTask/updateTask/toggleTask/deleteTask/startTimer/pauseTimer/resetTimer/updateSettings. Pruebas de widgets para formularios, navegación y anchuras móviles.
- [x] 3. Añadir fotografía y tipografía locales con licencia, documentar límites, ejecutar format/analyze/test/build web y revisar capturas móviles.
- [x] 4. Revisar diff completo, compilar APK si hay SDK o documentar límite local y delegar compilación al workflow. Commit, push de la rama y crear PR con evidencia real.

## Registro de ejecución

- La base del repositorio solo contenía documentación; se generó un proyecto Flutter Android/web en la rama solicitada.
- Estado: ciclo rojo/verde para CRUD, persistencia, temporizador y errores. Suite final ampliada a 18 pruebas, todas aprobadas.
- UI: captura de las cinco pantallas a 390×844; widgets verificados a 360/390 px y texto al 160 %. Se corrigió la cabecera de altura fija tras reproducir un overflow.
- Revisión independiente: se corrigieron los seis hallazgos (acción semántica de navegación, intención de sesión pausada, cambio de día en reposo, logro de primera tarea, logro de racha permanente y límite de títulos Unicode). Las regresiones se observaron en rojo y luego en verde.
- Se incluyó la licencia completa de Inter en la app y se localizó Material a español. No se añadieron servicios remotos ni notificaciones.
- El entorno local necesitó instalar Flutter, SDK/NDK Android y JDK completo; Gradle usa el proxy y truststore del entorno, sin añadir esa configuración al repositorio.

- Entrega: build web y APK Android debug generados; rama publicada y PR #1 abierto. Véase `docs/VALIDATION.md`.
