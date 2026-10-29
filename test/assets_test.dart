import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const photos = [
    'focus_hero_today.webp',
    'focus_planner_schedule.webp',
    'focus_deep_work.webp',
    'focus_break_reset.webp',
    'focus_progress_journey.webp',
  ];

  for (final filename in photos) {
    test('ships $filename as an offline WebP asset', () async {
      final bytes = await rootBundle.load('assets/images/$filename');
      expect(bytes.lengthInBytes, greaterThan(10000));
      expect(String.fromCharCodes(bytes.buffer.asUint8List(0, 4)), 'RIFF');
      expect(String.fromCharCodes(bytes.buffer.asUint8List(8, 4)), 'WEBP');
    });
  }
}
