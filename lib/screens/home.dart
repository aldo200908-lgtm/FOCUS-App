import 'package:flutter/material.dart';
import '../core/app_state.dart';
import '../ui/design.dart';
import 'tasks.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.state, required this.navigate});
  final AppState state;
  final ValueChanged<int> navigate;
  @override
  Widget build(BuildContext context) {
    final task = state.priorityTask;
    final completed = state.completedToday;
    final total = completed + state.pendingCount;
    return ListView(
      padding: const EdgeInsets.only(bottom: 128),
      children: [
        Stack(
          children: [
            const Positioned.fill(child: Landscape()),
            Padding(
              padding: const EdgeInsets.fromLTRB(26, 22, 26, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          state.name.isEmpty
                              ? 'Hola. Este momento es tuyo.'
                              : 'Hola, ${state.name}.',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xDDFFFFFF),
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Abrir ajustes',
                        onPressed: () => navigate(4),
                        icon: const Icon(Icons.tune_rounded, size: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 70),
                  const Eyebrow(
                    'RESPIRA. ELIGE. EMPIEZA.',
                    color: Color(0xDDFFFFFF),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Haz espacio para\nlo importante.',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontSize: 40,
                      letterSpacing: -1.8,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Un poco de enfoque.\nUn gran paso hacia tus objetivos.',
                    style: TextStyle(
                      color: Color(0xBBFFFFFF),
                      height: 1.65,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 26),
                  PressButton(
                    label: 'Empezar a concentrarme',
                    onPressed: () {
                      if (!state.running) state.selectTask(task?.id);
                      navigate(2);
                    },
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ],
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
                        const Expanded(child: Eyebrow('TU PROGRESO DE HOY')),
                        Text(
                          total == 0
                              ? 'Comienza hoy'
                              : '${(completed / total * 100).round()}%',
                          style: const TextStyle(
                            color: accent,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: _Metric(
                            value: '${state.focusedToday}',
                            label: 'min de enfoque',
                          ),
                        ),
                        Container(height: 38, width: 1, color: Colors.white12),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 24),
                            child: _Metric(
                              value:
                                  '$completed${total > 0 ? ' / $total' : ''}',
                              label: 'tareas completadas',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: total == 0 ? 0 : completed / total,
                        minHeight: 4,
                        backgroundColor: Colors.white.withValues(alpha: .08),
                        color: accent,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      state.pendingCount == 0
                          ? 'Todo empieza con un pequeño paso.'
                          : 'Te esperan ${state.pendingCount} tareas. Una a la vez.',
                      style: const TextStyle(color: muted, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Tu siguiente paso',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  TextButton(
                    onPressed: () => navigate(1),
                    child: const Text(
                      'Ver tareas  ↗',
                      style: TextStyle(color: muted, fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (task != null)
                TaskCard(
                  task: task,
                  state: state,
                  onFocus: () {
                    if (!state.running) state.selectTask(task.id);
                    navigate(2);
                  },
                )
              else
                EmptyState(
                  title: state.tasks.isEmpty
                      ? 'Dale intención a tu día.'
                      : 'Has hecho espacio.',
                  message: state.tasks.isEmpty
                      ? 'Crea tu primera tarea y convierte lo pendiente en un pequeño siguiente paso.'
                      : 'Todas tus tareas están completas. Disfruta el momento o elige un nuevo objetivo.',
                  action: TextButton(
                    onPressed: () => showTaskEditor(context, state),
                    child: const Text('Añadir una tarea  +'),
                  ),
                ),
              const SizedBox(height: 30),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.spa_outlined, color: muted, size: 14),
                  SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'El progreso empieza por estar presente.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: muted, fontSize: 10),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.value, required this.label});
  final String value, label;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        value,
        style: const TextStyle(
          fontSize: 28,
          letterSpacing: -1,
          fontWeight: FontWeight.w500,
        ),
      ),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(fontSize: 10, color: muted)),
    ],
  );
}
