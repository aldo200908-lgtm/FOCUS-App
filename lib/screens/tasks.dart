import 'package:flutter/material.dart';
import '../core/app_state.dart';
import '../ui/design.dart';

Future<void> showTaskEditor(
  BuildContext context,
  AppState state, {
  FocusTask? task,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => TaskEditor(state: state, task: task),
  );
}

class TaskEditor extends StatefulWidget {
  const TaskEditor({super.key, required this.state, this.task});
  final AppState state;
  final FocusTask? task;
  @override
  State<TaskEditor> createState() => _TaskEditorState();
}

class _TaskEditorState extends State<TaskEditor> {
  final form = GlobalKey<FormState>();
  late final TextEditingController title = TextEditingController(
    text: widget.task?.title,
  );
  late Priority priority = widget.task?.priority ?? Priority.medium;
  late String category = widget.task?.category ?? 'Personal';
  @override
  void dispose() {
    title.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(
      left: 24,
      right: 24,
      bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
    ),
    child: SingleChildScrollView(
      child: Form(
        key: form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Eyebrow('UN PASO MÁS CERCA', color: accent),
            const SizedBox(height: 12),
            Text(
              widget.task == null ? '¿Qué quieres lograr?' : 'Edita tu tarea',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            TextFormField(
              key: const ValueKey('task-title'),
              controller: title,
              autofocus: true,
              maxLength: 120,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Título de la tarea',
                hintText: 'Un objetivo pequeño y concreto',
              ),
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'Escribe un título para tu tarea'
                  : null,
            ),
            const SizedBox(height: 16),
            const Text('Prioridad', style: TextStyle(color: muted)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: Priority.values
                  .map(
                    (p) => ChoiceChip(
                      label: Text(p.label),
                      selected: p == priority,
                      onSelected: (_) => setState(() => priority = p),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              initialValue: category,
              decoration: const InputDecoration(labelText: 'Categoría'),
              items: [
                'Personal',
                'Trabajo',
                'Estudio',
              ].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => category = v!),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: PressButton(
                label: 'Guardar tarea',
                icon: Icons.check_rounded,
                onPressed: () {
                  if (!form.currentState!.validate()) return;
                  if (widget.task == null) {
                    widget.state.addTask(
                      title.text,
                      priority: priority,
                      category: category,
                    );
                  } else {
                    widget.state.updateTask(
                      widget.task!.id,
                      title.text,
                      priority,
                      category,
                    );
                  }
                  Navigator.pop(context);
                },
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar', style: TextStyle(color: muted)),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key, required this.state});
  final AppState state;
  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  int filter = 0;
  @override
  Widget build(BuildContext context) {
    final tasks =
        widget.state.tasks
            .where(
              (t) => filter == 0 || (filter == 1 ? !t.completed : t.completed),
            )
            .toList()
          ..sort((a, b) {
            final done = (a.completed ? 1 : 0).compareTo(b.completed ? 1 : 0);
            return done != 0
                ? done
                : a.priority.index.compareTo(b.priority.index);
          });
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.only(bottom: 200),
          children: [
            PageHeading(
              kicker: 'MENOS RUIDO. MÁS CLARIDAD.',
              title: 'Un paso a la vez.',
              subtitle:
                  '${widget.state.pendingCount} tareas pendientes · Tú marcas el ritmo.',
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['Todas', 'Pendientes', 'Completadas'].indexed
                    .map(
                      (e) => ChoiceChip(
                        label: Text(e.$2),
                        selected: filter == e.$1,
                        onSelected: (_) => setState(() => filter = e.$1),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 24),
            if (tasks.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: EmptyState(
                  title: filter == 2
                      ? 'Lo bueno está por llegar.'
                      : 'Espacio para un nuevo objetivo.',
                  message: filter == 2
                      ? 'Cada tarea que completes aparecerá aquí. Empieza con algo pequeño.'
                      : 'Anota lo que tienes en mente. Dar el primer paso también es avanzar.',
                  action: TextButton(
                    onPressed: () => showTaskEditor(context, widget.state),
                    child: const Text('Crear mi primera tarea'),
                  ),
                ),
              ),
            ...tasks.map(
              (t) => Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                child: TaskCard(task: t, state: widget.state),
              ),
            ),
          ],
        ),
        Positioned(
          right: 24,
          bottom: 112 + MediaQuery.paddingOf(context).bottom,
          child: FloatingActionButton.extended(
            tooltip: 'Nueva tarea',
            onPressed: () => showTaskEditor(context, widget.state),
            backgroundColor: accent,
            foregroundColor: ink,
            shape: const StadiumBorder(),
            icon: const Icon(Icons.add_rounded),
            label: const Text(
              'Nueva tarea',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.state,
    this.onFocus,
  });
  final FocusTask task;
  final AppState state;
  final VoidCallback? onFocus;
  @override
  Widget build(BuildContext context) => GlassCard(
    padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          checked: task.completed,
          child: IconButton(
            tooltip:
                '${task.completed ? 'Reabrir' : 'Completar'} ${task.title}',
            onPressed: () => state.toggleTask(task.id),
            icon: AnimatedSwitcher(
              duration: motion(context),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeOut,
              child: Icon(
                task.completed
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                key: ValueKey(task.completed),
                color: task.completed ? accent : muted,
                size: 25,
              ),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedDefaultTextStyle(
                  duration: motion(context),
                  curve: Curves.easeOut,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: task.completed ? muted : Colors.white,
                    fontSize: 14,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                    decoration: task.completed
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                  child: Text(task.title),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      task.category,
                      style: const TextStyle(color: muted, fontSize: 11),
                    ),
                    Text(
                      '● ${task.priority.label}',
                      style: TextStyle(
                        color: task.priority == Priority.high ? accent : muted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                if (onFocus != null)
                  TextButton(
                    onPressed: onFocus,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      alignment: Alignment.centerLeft,
                    ),
                    child: const Text(
                      'Concentrarme en esta tarea  ↗',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),
        ),
        PopupMenuButton<String>(
          tooltip: 'Opciones de ${task.title}',
          icon: const Icon(Icons.more_horiz_rounded, color: muted, size: 20),
          onSelected: (action) async {
            if (action == 'edit') {
              await showTaskEditor(context, state, task: task);
              return;
            }
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (c) => AlertDialog(
                title: const Text('¿Eliminar esta tarea?'),
                content: Text(
                  'Se eliminará «${task.title}». Esta acción no se puede deshacer.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(c, false),
                    child: const Text('Cancelar'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(c, true),
                    child: const Text('Eliminar'),
                  ),
                ],
              ),
            );
            if (confirmed == true) state.deleteTask(task.id);
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'edit', child: Text('Editar')),
            PopupMenuItem(value: 'delete', child: Text('Eliminar')),
          ],
        ),
      ],
    ),
  );
}
