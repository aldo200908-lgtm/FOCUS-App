import 'package:flutter/material.dart';
import '../core/app_state.dart';
import '../ui/design.dart';
import '../ui/cinematic.dart';
import 'tasks.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.state, required this.navigate});
  final AppState state;
  final ValueChanged<int> navigate;

  void focusOn(FocusTask? task) {
    if (!state.running) state.selectTask(task?.id);
    navigate(2);
  }

  @override
  Widget build(BuildContext context) {
    final task = state.todayPlan.firstOrNull ?? state.priorityTask;
    final completed = state.completedToday;
    final total = completed + state.pendingCount;
    return ListView(
      padding: const EdgeInsets.only(bottom: 150),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 23),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.circle, color: accent, size: 7),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      state.name.isEmpty
                          ? 'TU ESPACIO PERSONAL'
                          : 'HOLA, ${state.name.toUpperCase()}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10, color: muted, letterSpacing: 2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Abrir ajustes',
                    onPressed: () => navigate(4),
                    icon: const Icon(Icons.more_horiz_rounded, size: 23),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Haz espacio para\nlo importante.',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontSize: 39,
                  letterSpacing: -2.2,
                  height: 1.08,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Un día a la vez. Sin ruido, sin presión.',
                style: TextStyle(color: muted, fontSize: 13),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: CinematicCard(
            key: const ValueKey('hero-today'),
            title: 'Hoy',
            subtitle: state.todayPlan.isEmpty
                ? 'Todo empieza con una pequeña acción.'
                : '${state.todayPlan.length} tareas esperan tu atención.',
            label: '${state.pendingCount} PENDIENTES',
            height: 290,
            tint: const Color(0xFF087FA8),
            alignment: const Alignment(.45, -.3),
            onTap: () => navigate(1),
          ),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: PressButton(
            label: task == null ? 'Crear mi primera tarea' : 'Empezar a concentrarme',
            icon: task == null ? Icons.add_rounded : Icons.arrow_forward_rounded,
            onPressed: () => task == null
                ? showTaskEditor(context, state)
                : focusOn(task),
          ),
        ),
        const SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: EditorialSectionTitle(
            title: 'Tu panorama',
            trailing: Text(
              '${state.focusedToday} MIN DE ENFOQUE',
              style: const TextStyle(color: muted, fontSize: 9, letterSpacing: 1),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Expanded(
                child: CinematicCard(
                  title: 'Plan',
                  subtitle: '${state.upcomingPlan.length} próximas',
                  label: 'CALENDARIO',
                  height: 184,
                  tint: const Color(0xFF759F6D),
                  alignment: Alignment.bottomCenter,
                  onTap: () => navigate(1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CinematicCard(
                  title: 'Ritmo',
                  subtitle: '${state.streak} días de racha',
                  label: 'PROGRESO',
                  height: 184,
                  tint: const Color(0xFFAD6644),
                  alignment: Alignment.topLeft,
                  onTap: () => navigate(3),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 23),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: GlassCard(
            blur: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(child: Eyebrow('HOY ESTÁS AVANZANDO')),
                    Text(
                      total == 0 ? 'Tu primer día' :
                          '${(completed / total * 100).round()}%',
                      style: const TextStyle(color: accent, fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 17),
                Row(
                  children: [
                    Expanded(child: _Metric(value: '${state.focusedToday}',
                        label: 'minutos de enfoque')),
                    Container(width: 1, height: 40, color: Colors.white12),
                    const SizedBox(width: 20),
                    Expanded(child: _Metric(value: '$completed / $total',
                        label: 'tareas completadas')),
                  ],
                ),
                const SizedBox(height: 18),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: total == 0 ? 0 : completed / total,
                    color: accent,
                    backgroundColor: Colors.white12,
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 26),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: EditorialSectionTitle(
            title: 'Tu siguiente paso',
            trailing: TextButton(
              onPressed: () => navigate(1),
              child: const Text('Todas las tareas ↗',
                  style: TextStyle(fontSize: 11, color: muted)),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: task == null
              ? EmptyState(
                  title: 'Un comienzo sencillo.',
                  message: 'Anota una tarea. Nosotros te ayudamos a dividirla.',
                  action: TextButton(
                    onPressed: () => showTaskEditor(context, state),
                    child: const Text('Crear una tarea +'),
                  ),
                )
              : TaskCard(
                  task: task,
                  state: state,
                  onFocus: () => focusOn(task),
                  onQuickStart: () {
                    state.startQuickStart(task.id);
                    navigate(2);
                  },
                ),
        ),
        const SizedBox(height: 26),
        const Center(
          child: Text(
            'MENOS PRISA. MÁS PRESENCIA.',
            style: TextStyle(fontSize: 9, color: muted, letterSpacing: 2),
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
      Text(value, style: const TextStyle(
        fontSize: 28, fontWeight: FontWeight.w600, letterSpacing: -1.4,
      )),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(fontSize: 10, color: muted)),
    ],
  );
}
