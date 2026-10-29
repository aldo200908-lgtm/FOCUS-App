import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:focus/app.dart';
import 'package:focus/core/app_state.dart';
import 'app_state_test.dart' show MemoryRepository;

void main() {
  for (final width in [360.0, 390.0]) {
    testWidgets('navigation and task form work at $width px', (tester) async {
      tester.view.physicalSize = Size(width, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final state = await AppState.load(MemoryRepository(), autoTick: false);
      await tester.pumpWidget(FocusApp(state: state));
      await tester.pumpAndSettle();
      expect(find.text('Haz espacio para\nlo importante.'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('nav-1')));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Nueva tarea'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Guardar tarea'));
      await tester.tap(find.text('Guardar tarea'));
      await tester.pumpAndSettle();
      expect(find.text('Escribe un título para tu tarea'), findsOneWidget);
      await tester.enterText(
        find.byKey(const ValueKey('task-title')),
        'Leer 10 páginas',
      );
      await tester.ensureVisible(find.text('Guardar tarea'));
      await tester.tap(find.text('Guardar tarea'));
      await tester.pumpAndSettle();
      expect(find.text('Leer 10 páginas'), findsOneWidget);
      await tester.tap(find.byTooltip('Completar Leer 10 páginas'));
      await tester.pumpAndSettle();
      expect(state.xp, 20);
      await tester.tap(find.byKey(const ValueKey('nav-2')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Iniciar sesión'));
      await tester.pump();
      expect(state.running, isTrue);
      await tester.tap(find.byKey(const ValueKey('nav-3')));
      await tester.pumpAndSettle();
      expect(find.text('Tu esfuerzo cuenta.'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('nav-4')));
      await tester.pumpAndSettle();
      expect(find.text('A tu manera.'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      state.dispose();
    });
  }

  testWidgets('large text and reduced motion stay usable', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final state = await AppState.load(MemoryRepository(), autoTick: false);
    state.updateSettings(reduceMotion: true);
    await tester.pumpWidget(
      FocusApp(state: state, textScaler: const TextScaler.linear(1.6)),
    );
    await tester.pumpAndSettle();
    for (var i = 0; i < 5; i++) {
      await tester.tap(find.byKey(ValueKey('nav-$i')));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
    await tester.pumpWidget(const SizedBox());
    state.dispose();
  });
  testWidgets('bottom navigation exposes a screen reader tap action', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final state = await AppState.load(MemoryRepository(), autoTick: false);
    await tester.pumpWidget(FocusApp(state: state));
    await tester.pumpAndSettle();
    final node = tester.getSemantics(find.byKey(const ValueKey('nav-3')));
    expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
    tester.binding.renderViews.single.owner!.semanticsOwner!.performAction(
      node.id,
      SemanticsAction.tap,
    );
    await tester.pumpAndSettle();
    expect(find.text('Tu esfuerzo cuenta.'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    semantics.dispose();
    state.dispose();
  });
  testWidgets('task helper opens microsteps and launches two-minute focus', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final state = await AppState.load(MemoryRepository(), autoTick: false);
    await tester.pumpWidget(FocusApp(state: state));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('nav-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Nueva tarea'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('task-title')),
      'Estudiar historia',
    );
    await tester.tap(find.text('Guardar tarea'));
    await tester.pumpAndSettle();
    final starter = find.text('Ayúdame a empezar');
    await tester.ensureVisible(starter);
    await tester.tap(starter);
    await tester.pumpAndSettle();
    expect(find.text('Solo el primer paso.'), findsOneWidget);
    expect(state.tasks.single.microSteps, hasLength(3));
    await tester.tap(find.text('Empezar solo 2 minutos'));
    await tester.pumpAndSettle();
    expect(state.running, isTrue);
    expect(state.sessionMinutes, 2);
    await tester.pumpWidget(const SizedBox());
    state.dispose();
  });

}
