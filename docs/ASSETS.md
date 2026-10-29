# Recursos incluidos

Todos los recursos se empaquetan localmente: no se solicitan fotografías ni fuentes al usar la aplicación.

## Fotografías FOCUS aportadas por el usuario

El paquete `focus-images.zip` proporcionado por el usuario describe estos recursos como imágenes generadas con OpenAI para el proyecto FOCUS. Se incluyeron versiones optimizadas WebP de 900 × 1600 píxeles (calidad 84) a partir de originales de 1080 × 1920. Se mantienen locales para que la aplicación funcione sin conexión.

| Archivo | Uso |
| --- | --- |
| `focus_hero_today.webp` | Portada «Hoy» en Inicio |
| `focus_planner_schedule.webp` | Tarjetas de agenda y planificación |
| `focus_deep_work.webp` | Fondo del temporizador de concentración |
| `focus_break_reset.webp` | Fondo de descanso y tarjeta de Ajustes |
| `focus_progress_journey.webp` | Tarjetas de Progreso y rachas |

No se modificaron ni se incrustaron textos sobre las imágenes originales; toda la tipografía y los controles se dibujan en Flutter. Antes de publicar la aplicación, verificar las condiciones aplicables al uso y distribución de los recursos generados.

## Otros recursos

- `assets/images/mountain.jpg`: fotografía de montaña de Unsplash, identificador `photo-1464822759023-fed622ff2c3b`. Fuente exacta: https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=1200&q=85&fit=crop . Licencia Unsplash: https://unsplash.com/license (permite descarga, modificación y uso comercial; no se redistribuye como biblioteca de imágenes). Se usa como fondo decorativo con superposición oscura.
- `assets/fonts/Inter.ttf`: Inter, proyecto de Rasmus Andersson. Fuente: https://github.com/google/fonts/tree/main/ofl/inter . SIL Open Font License 1.1, copia completa en `assets/fonts/OFL.txt`.
- Iconos: Material Icons incluidos con Flutter, Apache 2.0, https://github.com/google/material-design-icons/blob/master/LICENSE .

No se incluyen imágenes de personas ni avatares.

- `assets/brand/focus.svg`: símbolo geométrico original creado para FOCUS; se utiliza también para los iconos Android y web.
- Cupertino Icons: dependencia auxiliar de los controles adaptativos de Flutter, licencia MIT incluida en el registro de licencias de Flutter.
