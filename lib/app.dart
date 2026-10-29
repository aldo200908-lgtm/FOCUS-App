import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/app_state.dart';
import 'screens/home.dart';
import 'screens/tasks.dart';
import 'screens/concentration.dart';
import 'screens/progress.dart';
import 'screens/settings.dart';
import 'ui/design.dart';

class FocusApp extends StatelessWidget {
  const FocusApp({super.key, required this.state, this.textScaler});
  final AppState state;
  final TextScaler? textScaler;
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'FOCUS',
    locale: const Locale('es'),
    supportedLocales: const [Locale('es')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    debugShowCheckedModeBanner: false,
    theme: focusTheme(),
    themeMode: ThemeMode.dark,
    builder: (context, child) => ListenableBuilder(
      listenable: state,
      child: child,
      builder: (context, child) {
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(
            disableAnimations: media.disableAnimations || state.reduceMotion,
            textScaler: textScaler ?? media.textScaler,
          ),
          child: child!,
        );
      },
    ),
    home: FocusShell(state: state),
  );
}

class FocusShell extends StatefulWidget {
  const FocusShell({super.key, required this.state});
  final AppState state;
  @override
  State<FocusShell> createState() => _FocusShellState();
}

class _FocusShellState extends State<FocusShell> with WidgetsBindingObserver {
  int selected = 0;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState value) {
    if (value == AppLifecycleState.resumed) widget.state.tick();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: widget.state,
    builder: (context, _) {
      final pages = [
        HomeScreen(
          key: const PageStorageKey('home'),
          state: widget.state,
          navigate: (i) => setState(() => selected = i),
        ),
        TasksScreen(
          key: const PageStorageKey('tasks'),
          state: widget.state,
          navigate: (i) => setState(() => selected = i),
        ),
        ConcentrationScreen(
          key: const PageStorageKey('concentration'),
          state: widget.state,
        ),
        ProgressScreen(
          key: const PageStorageKey('progress'),
          state: widget.state,
        ),
        SettingsScreen(
          key: const PageStorageKey('settings'),
          state: widget.state,
        ),
      ];
      return Scaffold(
        backgroundColor: ink,
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(1, -.8),
              radius: 1.5,
              colors: [Color(0xFF1C1815), ink],
              stops: [0, .7],
            ),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(26, 12, 26, 4),
                      child: Row(
                        children: [
                          Text(
                            '${widget.state.today.year}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 23,
                              letterSpacing: -.8,
                            ),
                          ),
                          const Icon(Icons.keyboard_arrow_down_rounded,
                              size: 20, color: muted),
                          const Spacer(),
                          const Text('FOCUS',
                              style: TextStyle(color: muted, fontSize: 9,
                                  letterSpacing: 3, fontWeight: FontWeight.w600)),
                          const Spacer(),
                          IconButton(
                            tooltip: 'Ir a mi agenda',
                            onPressed: () => setState(() => selected = 1),
                            icon: const Icon(Icons.calendar_month_outlined,
                                size: 22, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    if (widget.state.storageError != null)
                      Container(
                        margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF342216),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.state.storageError!,
                                style: const TextStyle(fontSize: 11),
                              ),
                            ),
                            TextButton(
                              onPressed: widget.state.retrySave,
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      ),
                    Expanded(
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: AnimatedSwitcher(
                              duration: motion(context),
                              switchInCurve: Curves.easeOut,
                              switchOutCurve: Curves.easeOut,
                              child: KeyedSubtree(
                                key: ValueKey(selected),
                                child: pages[selected],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 12,
                            right: 12,
                            bottom: 14 + MediaQuery.paddingOf(context).bottom,
                            child: Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 364),
                                child: _Navigation(
                                  selected: selected,
                                  onSelected: (i) => setState(() => selected = i),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );

}

class _Navigation extends StatelessWidget {
  const _Navigation({required this.selected, required this.onSelected});
  final int selected;
  final ValueChanged<int> onSelected;
  @override
  Widget build(BuildContext context) {
    const labels = ['Inicio', 'Tareas', 'Concentración', 'Progreso', 'Ajustes'];
    const icons = [
      Icons.home_outlined,
      Icons.checklist_rounded,
      Icons.center_focus_strong_rounded,
      Icons.bar_chart_rounded,
      Icons.tune_rounded,
    ];
    return GlassCard(
      blur: true,
      radius: 48,
      padding: const EdgeInsets.all(6),
      child: Row(
        children: [
          for (var i = 0; i < 5; i++)
            Expanded(
              child: Semantics(
                button: true,
                selected: i == selected,
                label: labels[i],
                onTap: () => onSelected(i),
                excludeSemantics: true,
                child: Tooltip(
                  message: labels[i],
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      key: ValueKey('nav-$i'),
                      borderRadius: BorderRadius.circular(40),
                      onTap: () => onSelected(i),
                      child: AnimatedContainer(
                        duration: motion(context),
                        curve: Curves.easeOut,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 2,
                          vertical: 11,
                        ),
                        decoration: BoxDecoration(
                          color: i == selected
                              ? Colors.white.withValues(alpha: .20)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              icons[i],
                              color: i == selected ? Colors.white : muted,
                              size: 21,
                            ),
                            const SizedBox(height: 6),
                            FittedBox(
                              child: Text(
                                labels[i],
                                style: TextStyle(
                                  color: i == selected ? Colors.white : muted,
                                  fontSize: 9,
                                  fontWeight: i == selected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
