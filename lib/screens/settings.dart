import 'package:flutter/material.dart';
import '../core/app_state.dart';
import '../ui/design.dart';
import '../ui/cinematic.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.state});
  final AppState state;
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController name = TextEditingController(
    text: widget.state.name,
  );
  late double focus = widget.state.focusMinutes.toDouble();
  late double rest = widget.state.breakMinutes.toDouble();
  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.only(bottom: 140),
    children: [
      const PageHeading(
        kicker: 'TU ESPACIO. TUS REGLAS.',
        title: 'A tu manera.',
        subtitle: 'Encuentra el ritmo que funciona para ti.',
      ),
      const Padding(
        padding: EdgeInsets.fromLTRB(24, 0, 24, 22),
        child: CinematicCard(
          imageAsset: 'assets/images/focus_break_reset.webp',
          title: 'Calma',
          subtitle: 'Tu espacio, a tu manera.',
          label: 'PERSONALIZA FOCUS',
          height: 172,
          tint: Color(0xFF4C7786),
          alignment: Alignment.centerLeft,
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Eyebrow('UN SALUDO PARA TI'),
                  const SizedBox(height: 18),
                  TextField(
                    controller: name,
                    maxLength: 30,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: '¿Cómo te llamas?',
                      hintText: 'Tu nombre (opcional)',
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () async {
                        widget.state.updateSettings(name: name.text);
                        await widget.state.flush();
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              widget.state.storageError == null
                                  ? 'Tu nombre se ha guardado.'
                                  : 'No se pudo guardar. Reintenta.',
                            ),
                          ),
                        );
                      },
                      child: const Text('Guardar nombre'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Eyebrow('TU RITMO DE CONCENTRACIÓN'),
                  const SizedBox(height: 22),
                  _DurationSlider(
                    label: 'Concentración',
                    value: focus,
                    max: 90,
                    onChanged: (v) => setState(() => focus = v),
                    onChangeEnd: (v) =>
                        widget.state.updateSettings(focusMinutes: v.round()),
                  ),
                  const SizedBox(height: 16),
                  _DurationSlider(
                    label: 'Descanso',
                    value: rest,
                    max: 30,
                    onChanged: (v) => setState(() => rest = v),
                    onChangeEnd: (v) =>
                        widget.state.updateSettings(breakMinutes: v.round()),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Los cambios se aplican a la siguiente sesión. Tu sesión en curso conserva su duración.',
                    style: TextStyle(color: muted, height: 1.6, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GlassCard(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              child: SwitchListTile.adaptive(
                title: const Text(
                  'Reducir movimiento',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                subtitle: const Text(
                  'Transiciones sin animación. También respetamos la preferencia del sistema.',
                  style: TextStyle(color: muted, fontSize: 11, height: 1.6),
                ),
                value: widget.state.reduceMotion,
                activeTrackColor: accent,
                onChanged: (v) => widget.state.updateSettings(reduceMotion: v),
              ),
            ),
            const SizedBox(height: 16),
            const GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.notifications_none_rounded, color: muted),
                  SizedBox(height: 14),
                  Text(
                    'Sin interrupciones',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Esta versión no envía notificaciones. Al volver a la app, el temporizador recupera tu sesión. Android puede suspender la app en segundo plano.',
                    style: TextStyle(color: muted, height: 1.7, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            const Center(
              child: Icon(Icons.lock_outline_rounded, size: 18, color: muted),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'Tu enfoque es privado.',
                style: TextStyle(fontSize: 12),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Tus tareas y sesiones se guardan en este dispositivo. Sin cuentas, sin anuncios, sin suscripciones.',
              textAlign: TextAlign.center,
              style: TextStyle(color: muted, height: 1.7, fontSize: 11),
            ),
            const SizedBox(height: 22),
            Center(
              child: TextButton(
                onPressed: () => showLicensePage(
                  context: context,
                  applicationName: 'FOCUS',
                  applicationVersion: '1.0.0',
                  applicationLegalese:
                      'Paisajes FOCUS: imágenes facilitadas por el usuario, generadas con OpenAI.\nFotografía original adicional: Unsplash · Licencia Unsplash\nInter: Rasmus Andersson · SIL OFL 1.1\nIconos Material: Apache 2.0',
                ),
                child: const Text(
                  'FOCUS 1.0 · Créditos y licencias',
                  style: TextStyle(color: muted, fontSize: 10),
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class _DurationSlider extends StatelessWidget {
  const _DurationSlider({
    required this.label,
    required this.value,
    required this.max,
    required this.onChanged,
    required this.onChangeEnd,
  });
  final String label;
  final double value, max;
  final ValueChanged<double> onChanged, onChangeEnd;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
          Text(
            '${value.round()} min',
            style: const TextStyle(color: accent, fontSize: 14),
          ),
        ],
      ),
      Slider(
        value: value,
        min: 1,
        max: max,
        divisions: max.toInt() - 1,
        label: '${value.round()} minutos',
        semanticFormatterCallback: (v) => '${v.round()} minutos',
        onChanged: onChanged,
        onChangeEnd: onChangeEnd,
      ),
    ],
  );
}
