import 'dart:math';
import 'package:flutter/material.dart';
import '../core/app_state.dart';
import '../ui/design.dart';

class ConcentrationScreen extends StatelessWidget {
  const ConcentrationScreen({super.key, required this.state});
  final AppState state;
  Future<bool> _confirm(BuildContext context, String title) async {
    if (!state.running && state.remainingSeconds == state.sessionMinutes * 60) {
      return true;
    }
    return await showDialog<bool>(
          context: context,
          builder: (c) => AlertDialog(
            title: Text(title),
            content: const Text(
              'El tiempo de la sesión actual no se registrará. Las sesiones ya completadas se conservan.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(c, false),
                child: const Text('Continuar sesión'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(c, true),
                child: const Text('Confirmar'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final seconds = state.remainingSeconds;
    final time =
        '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';
    final fresh = seconds == state.sessionMinutes * 60;
    return ListView(
      padding: const EdgeInsets.only(bottom: 130),
      children: [
        Stack(
          children: [
            const Positioned.fill(child: Landscape(opacity: .65)),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
              child: Column(
                children: [
                  const Eyebrow(
                    'ESTÁS EXACTAMENTE DONDE DEBES ESTAR',
                    color: Color(0xCCFFFFFF),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Solo este momento.',
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  GlassCard(
                    radius: 50,
                    padding: const EdgeInsets.all(5),
                    child: Row(
                      children: [
                        for (final item in [
                          (false, 'Concentración'),
                          (true, 'Descanso'),
                        ])
                          Expanded(
                            child: Semantics(
                              selected: state.isBreak == item.$1,
                              child: AnimatedContainer(
                                duration: motion(context),
                                curve: Curves.easeOut,
                                decoration: BoxDecoration(
                                  color: state.isBreak == item.$1
                                      ? Colors.white.withValues(alpha: .14)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(40),
                                ),
                                child: TextButton(
                                  onPressed: () async {
                                    if (state.isBreak != item.$1 &&
                                        await _confirm(
                                          context,
                                          '¿Cambiar de modo?',
                                        )) {
                                      state.selectBreak(item.$1);
                                    }
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: state.isBreak == item.$1
                                        ? Colors.white
                                        : muted,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                  ),
                                  child: Text(
                                    item.$2,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 34),
                  SizedBox(
                    width: 278,
                    height: 278,
                    child: CustomPaint(
                      painter: _TimerRing(state.timerProgress),
                      child: Padding(
                        padding: const EdgeInsets.all(28),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Eyebrow(
                              state.timerFinished
                                  ? 'BIEN HECHO'
                                  : state.running
                                  ? 'EN TU ZONA'
                                  : fresh
                                  ? 'SIN DISTRACCIONES'
                                  : 'EN PAUSA',
                              color: accent,
                            ),
                            const SizedBox(height: 12),
                            Semantics(
                              label:
                                  '${seconds ~/ 60} minutos y ${seconds % 60} segundos restantes',
                              excludeSemantics: true,
                              child: FittedBox(
                                child: Text(
                                  time,
                                  style: const TextStyle(
                                    fontSize: 66,
                                    height: 1.2,
                                    fontWeight: FontWeight.w300,
                                    letterSpacing: -4,
                                    fontFeatures: [
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              state.isBreak
                                  ? 'Respira y recarga.'
                                  : 'Una cosa a la vez.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: muted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    state.timerFinished
                        ? (state.isBreak
                              ? 'Descanso completado. Vuelve con calma.'
                              : 'Sesión completada · +${min(50, state.sessionMinutes * 2)} XP')
                        : '${state.isBreak ? 'Descanso' : 'Sesión ${(state.sessions.where((s) => AppState.day(s.endedAt) == state.today).length + 1).toString().padLeft(2, '0')}'} · ${state.sessionMinutes} minutos',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: muted, fontSize: 12),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              GlassCard(
                blur: true,
                child: Column(
                  children: [
                    PressButton(
                      label: state.running
                          ? 'Pausar sesión'
                          : state.timerFinished
                          ? 'Empezar otra sesión'
                          : fresh
                          ? 'Iniciar sesión'
                          : 'Reanudar sesión',
                      icon: state.running
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      onPressed: state.running
                          ? state.pauseTimer
                          : state.startTimer,
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () async {
                        if (state.timerFinished ||
                            await _confirm(
                              context,
                              '¿Reiniciar el temporizador?',
                            )) {
                          state.resetTimer();
                        }
                      },
                      icon: const Icon(Icons.restart_alt_rounded, size: 18),
                      label: const Text(
                        'Reiniciar',
                        style: TextStyle(fontSize: 12),
                      ),
                      style: TextButton.styleFrom(foregroundColor: muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              DropdownButtonFormField<String>(
                key: ValueKey(
                  '${state.selectedTaskId}-${state.tasks.length}-${state.running}',
                ),
                initialValue: state.selectedTask?.id ?? '',
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Tu intención para esta sesión',
                  prefixIcon: Icon(Icons.flag_outlined, size: 19),
                ),
                items: [
                  const DropdownMenuItem(
                    value: '',
                    child: Text('Concentración libre'),
                  ),
                  ...state.tasks
                      .where(
                        (t) => !t.completed || t.id == state.selectedTaskId,
                      )
                      .map(
                        (t) => DropdownMenuItem(
                          value: t.id,
                          child: Text(
                            t.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                ],
                onChanged: state.hasActiveSession
                    ? null
                    : (id) => state.selectTask(id == '' ? null : id),
              ),
              const SizedBox(height: 22),
              const Text(
                'Deja lo demás para después.\nAhora, estás aquí.',
                textAlign: TextAlign.center,
                style: TextStyle(color: muted, height: 1.8, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TimerRing extends CustomPainter {
  const _TimerRing(this.progress);
  final double progress;
  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(4);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      rect,
      0,
      2 * pi,
      false,
      paint..color = Colors.white.withValues(alpha: .14),
    );
    canvas.drawArc(
      rect,
      -pi / 2,
      2 * pi * progress,
      false,
      paint..color = accent,
    );
    final angle = -pi / 2 + 2 * pi * progress;
    canvas.drawCircle(
      Offset(
        size.width / 2 + rect.width / 2 * cos(angle),
        size.height / 2 + rect.height / 2 * sin(angle),
      ),
      4,
      Paint()..color = accent,
    );
  }

  @override
  bool shouldRepaint(_TimerRing oldDelegate) =>
      oldDelegate.progress != progress;
}
