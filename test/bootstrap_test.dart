import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:focus/core/app_state.dart';
import 'package:focus/core/repository.dart';
import 'package:focus/main.dart';

void main() {
  test(
    'local repository saves and reloads real preferences document',
    () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final state = await AppState.load(
        LocalRepository(preferences),
        autoTick: false,
      );
      state.addTask('Escribir sin conexión');
      await state.flush();
      await preferences.reload();
      final restored = await AppState.load(
        LocalRepository(preferences),
        autoTick: false,
      );
      expect(restored.tasks.single.title, 'Escribir sin conexión');
      state.dispose();
      restored.dispose();
    },
  );

  testWidgets('bootstrap preserves corrupt storage and offers retry', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({LocalRepository.key: '{corrupt'});
    await tester.pumpWidget(const Bootstrap());
    await tester.pumpAndSettle();
    expect(find.text('Tus datos se conservan.'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString(LocalRepository.key), '{corrupt');
    await tester.pumpWidget(const SizedBox());
  });
}
