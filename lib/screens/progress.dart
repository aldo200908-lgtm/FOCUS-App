import 'dart:math';
import 'package:flutter/material.dart';
import '../core/app_state.dart';
import '../ui/design.dart';
import '../ui/cinematic.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key, required this.state});
  final AppState state;
  @override
  Widget build(BuildContext context) {
    final days = List.generate(
      7,
      (i) => DateTime(
        state.today.year,
        state.today.month,
        state.today.day - 6 + i,
      ),
    );
    final values = days.map(state.minutesOn).toList();
    final maxValue = max(25, values.reduce(max));
    final weekTotal = values.fold<int>(0, (a, b) => a + b);
    return ListView(
      padding: const EdgeInsets.only(bottom: 140),
      children: [
        const PageHeading(
          kicker: 'CADA PEQUEÑO PASO SUMA',
          title: 'Tu esfuerzo cuenta.',
          subtitle: 'No necesitas hacerlo perfecto.\nSolo seguir avanzando.',
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 22),
          child: CinematicCard(
            title: 'Racha',
            subtitle: '${state.streak} días de constancia · ${state.xp} XP',
            label: 'TU HISTORIA',
            height: 188,
            tint: const Color(0xFF9A6447),
            alignment: Alignment.bottomRight,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlassCard(
                blur: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.local_fire_department_outlined,
                          color: accent,
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '${state.streak} ${state.streak == 1 ? 'día' : 'días'} de constancia',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Una tarea o una sesión al día mantiene tu racha.',
                      style: TextStyle(color: muted, fontSize: 12, height: 1.6),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _Stat(
                      icon: Icons.timelapse_rounded,
                      value: '${state.totalMinutes}',
                      label: 'minutos de enfoque',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _Stat(
                      icon: Icons.task_alt_rounded,
                      value: '${state.tasks.where((t) => t.completed).length}',
                      label: 'tareas completadas',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Eyebrow('TU RITMO · ÚLTIMOS 7 DÍAS'),
                    const SizedBox(height: 12),
                    Text(
                      '$weekTotal min',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w500,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Tiempo que te has dedicado.',
                      style: TextStyle(color: muted, fontSize: 12),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: days.indexed.map((entry) {
                        final i = entry.$1;
                        final d = entry.$2;
                        final selected = i == 6;
                        return Expanded(
                          child: Semantics(
                            label:
                                '${d.day}/${d.month}: ${values[i]} minutos de enfoque',
                            excludeSemantics: true,
                            child: Column(
                              children: [
                                Text(
                                  '${values[i]}',
                                  style: TextStyle(
                                    color: selected ? accent : muted,
                                    fontSize: 9,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  height: 92,
                                  child: Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Container(
                                      width: 20,
                                      height: max(4, values[i] / maxValue * 92),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(6),
                                        color: selected
                                            ? accent
                                            : Colors.white.withValues(
                                                alpha: values[i] == 0
                                                    ? .08
                                                    : .26,
                                              ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  [
                                    'L',
                                    'M',
                                    'X',
                                    'J',
                                    'V',
                                    'S',
                                    'D',
                                  ][d.weekday - 1],
                                  style: TextStyle(
                                    color: selected ? Colors.white : muted,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    if (weekTotal == 0) ...[
                      const SizedBox(height: 20),
                      const Text(
                        'Tu primera sesión dará vida a este gráfico.',
                        style: TextStyle(color: muted, fontSize: 11),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: accent.withValues(alpha: .12),
                          ),
                          child: const Icon(
                            Icons.auto_awesome_outlined,
                            color: accent,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Eyebrow('CRECIENDO CONTIGO'),
                              const SizedBox(height: 5),
                              Text(
                                'Nivel ${state.level} · ${state.level == 1 ? 'El comienzo' : 'En movimiento'}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 17,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: state.levelProgress,
                        minHeight: 5,
                        color: accent,
                        backgroundColor: Colors.white10,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${state.xp} XP en total · ${200 - state.xp % 200} XP para el siguiente nivel',
                      style: const TextStyle(color: muted, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Pequeñas grandes victorias',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              for (final achievement in [
                (
                  Icons.bolt_rounded,
                  'El primer paso',
                  'Completa tu primera tarea',
                  state.earnedTasks > 0,
                ),
                (
                  Icons.center_focus_strong_rounded,
                  'En tu zona',
                  'Completa una sesión de enfoque',
                  state.sessions.isNotEmpty,
                ),
                (
                  Icons.local_fire_department_outlined,
                  'Con constancia',
                  'Mantén una racha de 3 días',
                  state.bestStreak >= 3,
                ),
              ])
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GlassCard(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        Icon(
                          achievement.$1,
                          color: achievement.$4 ? accent : muted,
                          size: 25,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                achievement.$2,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                achievement.$3,
                                style: const TextStyle(
                                  color: muted,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          achievement.$4
                              ? Icons.check_circle_outline_rounded
                              : Icons.lock_outline_rounded,
                          color: achievement.$4 ? accent : muted,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.value, required this.label});
  final IconData icon;
  final String value, label;
  @override
  Widget build(BuildContext context) => GlassCard(
    padding: const EdgeInsets.all(18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: muted, size: 22),
        const SizedBox(height: 18),
        Text(
          value,
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w500,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: muted, fontSize: 11)),
      ],
    ),
  );
}
