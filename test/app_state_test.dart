import 'package:flutter_test/flutter_test.dart';
import 'package:focus/core/app_state.dart';
import 'package:focus/core/repository.dart';

class MemoryRepository implements FocusRepository {
  String? value;
  bool fail = false;
  @override
  Future<String?> read() async => value;
  @override
  Future<void> write(String data) async {
    if (fail) throw StateError('Disk unavailable');
    value = data;
  }
}

void main() {
  late MemoryRepository repo;
  late AppState app;
  var now = DateTime(2026, 10, 29, 10);
  setUp(() async {
    now = DateTime(2026, 10, 29, 10);
    repo = MemoryRepository();
    app = await AppState.load(repo, clock: () => now, autoTick: false);
  });
  tearDown(() => app.dispose());

  test('CRUD, priorities and preferences survive restart', () async {
    final task = app.addTask('  Preparar propuesta  ', priority: Priority.high);
    app.updateTask(task.id, 'Revisar propuesta', Priority.low, 'Trabajo');
    app.updateSettings(name: 'Ana', focusMinutes: 40, breakMinutes: 10);
    await app.flush();
    final restored = await AppState.load(repo, autoTick: false);
    expect(restored.tasks.single.title, 'Revisar propuesta');
    expect(restored.tasks.single.priority, Priority.low);
    expect(restored.name, 'Ana');
    expect(restored.focusMinutes, 40);
    restored.deleteTask(task.id);
    await restored.flush();
    expect(restored.tasks, isEmpty);
    restored.dispose();
  });

  test('empty titles rejected and XP cannot be farmed with toggles', () async {
    expect(() => app.addTask('  '), throwsArgumentError);
    final task = app.addTask('Leer');
    app.toggleTask(task.id);
    expect(app.xp, 20);
    app.toggleTask(task.id);
    app.toggleTask(task.id);
    expect(app.xp, 20);
    expect(app.completedToday, 1);
    await app.flush();
  });

  test('pause freezes time, resume and reset preserve session accounting', () {
    app.startTimer();
    now = now.add(const Duration(minutes: 5));
    app.tick();
    expect(app.remainingSeconds, 20 * 60);
    app.pauseTimer();
    now = now.add(const Duration(hours: 1));
    app.tick();
    expect(app.remainingSeconds, 20 * 60);
    app.startTimer();
    now = now.add(const Duration(minutes: 20));
    app.tick();
    expect(app.sessions.length, 1);
    expect(app.sessions.single.minutes, 25);
    app.tick();
    expect(app.sessions.length, 1);
    app.resetTimer();
    expect(app.remainingSeconds, 25 * 60);
  });

  test('expired persisted timer records exactly once after restart', () async {
    app.startTimer();
    await app.flush();
    now = now.add(const Duration(minutes: 26));
    final restored = await AppState.load(
      repo,
      clock: () => now,
      autoTick: false,
    );
    await restored.flush();
    expect(restored.sessions.length, 1);
    expect(restored.focusedToday, 25);
    expect(restored.xp, 50);
    final again = await AppState.load(repo, clock: () => now, autoTick: false);
    expect(again.sessions.length, 1);
    again.dispose();
    restored.dispose();
  });

  test('break completion gives no focus XP or session', () {
    app.selectBreak(true);
    app.startTimer();
    now = now.add(const Duration(minutes: 5));
    app.tick();
    expect(app.sessions, isEmpty);
    expect(app.xp, 0);
    expect(app.timerFinished, isTrue);
  });

  test('streak handles yesterday and resets after missed days', () {
    app.startTimer();
    now = now.add(const Duration(minutes: 25));
    app.tick();
    expect(app.streak, 1);
    now = now.add(const Duration(days: 1));
    expect(app.streak, 1);
    now = now.add(const Duration(days: 1));
    expect(app.streak, 0);
  });

  test('failed writes surface and retry saves latest state', () async {
    repo.fail = true;
    app.addTask('No perder');
    await app.flush();
    expect(app.storageError, isNotNull);
    repo.fail = false;
    await app.retrySave();
    expect(app.storageError, isNull);
    final restored = await AppState.load(repo, autoTick: false);
    expect(restored.tasks.single.title, 'No perder');
    restored.dispose();
  });

  test('corrupt state is never silently replaced', () async {
    repo.value = '{broken';
    await expectLater(
      AppState.load(repo, autoTick: false),
      throwsFormatException,
    );
    expect(repo.value, '{broken');
  });
  test('idle day rollover notifies once without running timer', () {
    var notifications = 0;
    app.addListener(() => notifications++);
    app.tick();
    expect(notifications, 0);
    now = now.add(const Duration(days: 1));
    app.tick();
    expect(notifications, 1);
    app.tick();
    expect(notifications, 1);
  });

  test('session XP does not unlock first task and longest streak persists', () {
    app.startTimer();
    now = now.add(const Duration(minutes: 25));
    app.tick();
    expect(app.earnedTasks, 0);
    for (var i = 0; i < 3; i++) {
      final task = app.addTask('Día $i');
      app.toggleTask(task.id);
      if (i < 2) now = now.add(const Duration(days: 1));
    }
    expect(app.bestStreak, 3);
    expect(app.earnedTasks, 3);
    now = now.add(const Duration(days: 5));
    expect(app.streak, 0);
    expect(app.bestStreak, 3);
  });

  test('paused session keeps intention even if task is deleted', () async {
    final first = app.addTask('Primera');
    final second = app.addTask('Segunda');
    app.selectTask(first.id);
    app.startTimer();
    now = now.add(const Duration(minutes: 5));
    app.pauseTimer();
    app.selectTask(second.id);
    expect(app.selectedTaskId, first.id);
    app.deleteTask(first.id);
    await app.flush();
    final restored = await AppState.load(
      repo,
      clock: () => now,
      autoTick: false,
    );
    restored.startTimer();
    now = now.add(const Duration(minutes: 20));
    restored.tick();
    expect(restored.sessions.single.taskId, first.id);
    restored.dispose();
  });

  test('title limit counts visible characters including emoji', () {
    final title = '${'a' * 100}${'🧠' * 20}';
    expect(app.addTask(title).title, title);
    expect(() => app.addTask('${title}a'), throwsArgumentError);
  });
  test('schedules and deadlines persist and populate today/upcoming views', () async {
    final today = DateTime(2026, 10, 29);
    final tomorrow = DateTime(2026, 10, 30);
    final current = app.addTask('Hoy', scheduledFor: today, dueAt: today);
    final future = app.addTask('Mañana', scheduledFor: tomorrow);
    expect(app.todayPlan.map((t) => t.id), contains(current.id));
    expect(app.upcomingPlan.map((t) => t.id), contains(future.id));
    expect(app.dueTodayCount, 1);
    app.scheduleTask(future.id, today);
    expect(app.todayPlan.map((t) => t.id), contains(future.id));
    await app.flush();
    final restored = await AppState.load(repo, clock: () => now, autoTick: false);
    expect(restored.tasks.firstWhere((t) => t.id == current.id).dueAt, today);
    expect(restored.todayPlan.length, 2);
    restored.dispose();
  });

  test('offline starter breaks down tasks and persists completed microsteps', () async {
    final task = app.addTask('Estudiar biología');
    app.prepareTask(task.id);
    expect(task.microSteps, hasLength(3));
    expect(task.microSteps.first, contains('Estudiar biología'));
    app.toggleMicroStep(task.id, 0);
    expect(task.stepsDone, 1);
    expect(app.xp, 0);
    await app.flush();
    final restored = await AppState.load(repo, autoTick: false);
    expect(restored.tasks.single.microSteps, hasLength(3));
    expect(restored.tasks.single.completedMicroSteps, {0});
    restored.dispose();
  });

  test('old task JSON loads with optional plan fields absent', () async {
    final task = app.addTask('Anterior');
    await app.flush();
    final oldJson = repo.value!;
    repo.value = oldJson.replaceAll(
      ',"scheduledFor":null,"dueAt":null,"microSteps":[],"completedMicroSteps":[]',
      '',
    );
    final restored = await AppState.load(repo, autoTick: false);
    expect(restored.tasks.single.id, task.id);
    expect(restored.tasks.single.scheduledFor, isNull);
    expect(restored.tasks.single.microSteps, isEmpty);
    restored.dispose();
  });

  test('two-minute kickoff records 2 minutes and proportional XP', () {
    final task = app.addTask('Comenzar');
    expect(app.startQuickStart(task.id), isTrue);
    expect(app.sessionMinutes, 2);
    expect(app.remainingSeconds, 120);
    expect(app.startQuickStart(task.id), isFalse);
    now = now.add(const Duration(minutes: 2));
    app.tick();
    expect(app.sessions.single.taskId, task.id);
    expect(app.sessions.single.minutes, 2);
    expect(app.xp, 4);
    app.resetTimer();
    expect(app.sessionMinutes, 25);
  });

}
