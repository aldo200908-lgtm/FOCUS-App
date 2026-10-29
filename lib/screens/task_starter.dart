import 'package:flutter/material.dart';
import '../core/app_state.dart';
import '../ui/design.dart';

/// Offline, deterministic assistance: no account, network, or fake AI calls.
Future<void> showStarterSheet(
  BuildContext context,
  AppState state,
  FocusTask task, {
  VoidCallback? onFocus,
}) async {
  state.prepareTask(task.id);
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: const Color(0xFF17181C),
    builder: (sheetContext) => ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final current = state.tasks.where((t) => t.id == task.id).firstOrNull;
        if (current == null) return const SizedBox.shrink();
        final done = current.stepsDone;
        return Padding(
          padding: EdgeInsets.fromLTRB(
            24, 14, 24, MediaQuery.viewInsetsOf(context).bottom + 28,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Eyebrow('MENOS PENSAR. MÁS HACER.', color: accent),
                const SizedBox(height: 12),
                Text(
                  'Solo el primer paso.',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 9),
                Text(current.title,
                    style: const TextStyle(fontSize: 14, color: muted)),
                const SizedBox(height: 24),
                GlassCard(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.auto_awesome_rounded,
                              color: accent, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '$done de ${current.microSteps.length} pasos',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      for (var i = 0; i < current.microSteps.length; i++)
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          activeColor: accent,
                          title: Text(
                            current.microSteps[i],
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.45,
                              decoration: current.completedMicroSteps.contains(i)
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: current.completedMicroSteps.contains(i)
                                  ? muted : Colors.white,
                            ),
                          ),
                          value: current.completedMicroSteps.contains(i),
                          onChanged: (_) => state.toggleMicroStep(current.id, i),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'No necesitas terminar todo ahora. Empieza por dos minutos.',
                  style: TextStyle(color: muted, fontSize: 12, height: 1.5),
                ),
                if (onFocus != null) ...[
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: PressButton(
                      label: 'Concentrarme en esta tarea',
                      icon: Icons.arrow_forward_rounded,
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        onFocus();
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    ),
  );
}
