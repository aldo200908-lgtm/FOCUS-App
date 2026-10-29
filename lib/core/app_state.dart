import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:characters/characters.dart';
import 'package:flutter/foundation.dart';
import 'models.dart';
import 'repository.dart';
export 'models.dart';

class AppState extends ChangeNotifier {
  AppState._(this.repository, this.clock);
  final FocusRepository repository;
  final DateTime Function() clock;
  final List<FocusTask> _tasks = [];
  final List<FocusSession> _sessions = [];
  final Map<String, DateTime> _awards = {};
  List<FocusTask> get tasks => List.unmodifiable(_tasks);
  List<FocusSession> get sessions => List.unmodifiable(_sessions);
  String name = '';
  int focusMinutes = 25;
  int breakMinutes = 5;
  bool reduceMotion = false;
  String? selectedTaskId;
  bool isBreak = false;
  bool timerFinished = false;
  int _remaining = 25 * 60;
  int _sessionMinutes = 25;
  DateTime? _deadline;
  DateTime? _lastObservedDay;
  String? _activeTaskId;
  Timer? _ticker;
  Future<void> _writes = Future.value();
  bool _disposed = false;
  String? storageError;
  int _idCounter = 0;

  static Future<AppState> load(
    FocusRepository repository, {
    DateTime Function()? clock,
    bool autoTick = true,
  }) async {
    final app = AppState._(repository, clock ?? DateTime.now);
    final raw = await repository.read();
    if (raw != null) {
      try {
        final j = jsonDecode(raw) as Map<String, dynamic>;
        if (j['version'] != 1) {
          throw const FormatException('Versión no compatible');
        }
        app._tasks.addAll(
          (j['tasks'] as List).map((e) => FocusTask.fromJson(e)),
        );
        app._sessions.addAll(
          (j['sessions'] as List).map((e) => FocusSession.fromJson(e)),
        );
        app._awards.addAll(
          (j['awards'] as Map<String, dynamic>).map(
            (k, v) => MapEntry(k, DateTime.parse(v as String)),
          ),
        );
        app.name = j['name'] as String;
        app.focusMinutes = (j['focusMinutes'] as int).clamp(1, 90);
        app.breakMinutes = (j['breakMinutes'] as int).clamp(1, 30);
        app.reduceMotion = j['reduceMotion'] as bool;
        app.selectedTaskId = j['selectedTaskId'] as String?;
        app._activeTaskId = j['activeTaskId'] as String? ?? app.selectedTaskId;
        app.isBreak = j['isBreak'] as bool;
        app.timerFinished = j['timerFinished'] as bool;
        app._remaining = (j['remaining'] as int).clamp(0, 5400);
        app._sessionMinutes = (j['sessionMinutes'] as int).clamp(1, 90);
        app._deadline = j['deadline'] == null
            ? null
            : DateTime.parse(j['deadline'] as String);
      } catch (error) {
        throw FormatException(
          'No se pudieron leer tus datos. Se conservan sin modificar.',
          error,
        );
      }
    }
    app.tick();
    if (autoTick) {
      app._ticker = Timer.periodic(
        const Duration(seconds: 1),
        (_) => app.tick(),
      );
    }
    return app;
  }

  bool get running => _deadline != null;
  int get remainingSeconds => _remaining;
  int get sessionMinutes => _sessionMinutes;
  double get timerProgress =>
      (1 - _remaining / (_sessionMinutes * 60)).clamp(0, 1);
  DateTime get today => day(clock());
  static DateTime day(DateTime d) =>
      DateTime(d.toLocal().year, d.toLocal().month, d.toLocal().day);
  int get completedToday => _tasks
      .where((t) => t.completedAt != null && day(t.completedAt!) == today)
      .length;
  int get pendingCount => _tasks.where((t) => !t.completed).length;
  int get focusedToday => minutesOn(today);
  int minutesOn(DateTime d) => _sessions
      .where((s) => day(s.endedAt) == day(d))
      .fold(0, (a, s) => a + s.minutes);
  int get totalMinutes => _sessions.fold(0, (a, s) => a + s.minutes);
  int get earnedTasks => _awards.length;
  bool get hasActiveSession =>
      running || (!timerFinished && _remaining < _sessionMinutes * 60);
  int get bestStreak {
    final days = {
      ..._sessions.map((s) => day(s.endedAt)),
      ..._awards.values.map(day),
    }.toList()..sort();
    var best = 0;
    var current = 0;
    DateTime? previous;
    for (final date in days) {
      current =
          previous != null &&
              DateTime(previous.year, previous.month, previous.day + 1) == date
          ? current + 1
          : 1;
      best = max(best, current);
      previous = date;
    }
    return best;
  }

  int get xp => _awards.length * 20 + _sessions.length * 50;
  int get level => 1 + xp ~/ 200;
  double get levelProgress => (xp % 200) / 200;
  int get streak {
    final days = {
      ..._sessions.map((s) => day(s.endedAt)),
      ..._awards.values.map(day),
    };
    var date = today;
    if (!days.contains(date)) {
      date = DateTime(date.year, date.month, date.day - 1);
    }
    var count = 0;
    while (days.contains(date)) {
      count++;
      date = DateTime(date.year, date.month, date.day - 1);
    }
    return count;
  }

  FocusTask? get priorityTask {
    final pending = _tasks.where((t) => !t.completed).toList()
      ..sort((a, b) => a.priority.index.compareTo(b.priority.index));
    return pending.firstOrNull;
  }

  FocusTask? get selectedTask =>
      _tasks.where((t) => t.id == selectedTaskId).firstOrNull;

  FocusTask addTask(
    String title, {
    Priority priority = Priority.medium,
    String category = 'Personal',
  }) {
    final task = FocusTask(
      id: '${clock().microsecondsSinceEpoch}-${_idCounter++}-${Random().nextInt(1 << 30)}',
      title: _validTitle(title),
      priority: priority,
      category: category,
    );
    _tasks.add(task);
    _changed();
    return task;
  }

  String _validTitle(String title) {
    if (title.trim().isEmpty || title.trim().characters.length > 120) {
      throw ArgumentError('Título inválido');
    }
    return title.trim();
  }

  void updateTask(String id, String title, Priority priority, String category) {
    final task = _tasks.firstWhere((t) => t.id == id);
    task.title = _validTitle(title);
    task.priority = priority;
    task.category = category;
    _changed();
  }

  void toggleTask(String id) {
    final task = _tasks.firstWhere((t) => t.id == id);
    task.completedAt = task.completed ? null : clock();
    if (task.completed) _awards.putIfAbsent(id, clock);
    _changed();
  }

  void deleteTask(String id) {
    _tasks.removeWhere((t) => t.id == id);
    if (selectedTaskId == id) selectedTaskId = null;
    _changed();
  }

  void selectTask(String? id) {
    if (hasActiveSession) return;
    selectedTaskId = id;
    _changed();
  }

  void updateSettings({
    String? name,
    int? focusMinutes,
    int? breakMinutes,
    bool? reduceMotion,
  }) {
    if (name != null) this.name = name.trim();
    if (focusMinutes != null) this.focusMinutes = focusMinutes.clamp(1, 90);
    if (breakMinutes != null) this.breakMinutes = breakMinutes.clamp(1, 30);
    if (reduceMotion != null) this.reduceMotion = reduceMotion;
    if (!running && (_remaining == _sessionMinutes * 60 || timerFinished)) {
      resetTimer();
    }
    _changed();
  }

  void selectBreak(bool value) {
    if (isBreak == value) return;
    isBreak = value;
    resetTimer();
  }

  void startTimer() {
    if (running) return;
    if (timerFinished || _remaining <= 0) resetTimer();
    if (_remaining == _sessionMinutes * 60) _activeTaskId = selectedTaskId;
    _deadline = clock().add(Duration(seconds: _remaining));
    _changed();
  }

  void pauseTimer() {
    tick();
    _deadline = null;
    _changed();
  }

  void resetTimer() {
    _deadline = null;
    _activeTaskId = null;
    _sessionMinutes = isBreak ? breakMinutes : focusMinutes;
    _remaining = _sessionMinutes * 60;
    timerFinished = false;
    _changed();
  }

  void tick() {
    final currentDay = today;
    final dayChanged = _lastObservedDay != currentDay;
    _lastObservedDay = currentDay;
    if (_deadline == null) {
      if (dayChanged && !_disposed) notifyListeners();
      return;
    }
    final end = _deadline!;
    _remaining = max(0, (end.difference(clock()).inMilliseconds / 1000).ceil());
    if (_remaining == 0) {
      _deadline = null;
      timerFinished = true;
      if (!isBreak) {
        _sessions.add(
          FocusSession(
            endedAt: end,
            minutes: _sessionMinutes,
            taskId: _activeTaskId,
          ),
        );
      }
      _save();
    }
    if (!_disposed) notifyListeners();
  }

  Map<String, dynamic> _json() => {
    'version': 1,
    'tasks': _tasks.map((t) => t.toJson()).toList(),
    'sessions': _sessions.map((s) => s.toJson()).toList(),
    'awards': _awards.map((k, v) => MapEntry(k, v.toIso8601String())),
    'name': name,
    'focusMinutes': focusMinutes,
    'breakMinutes': breakMinutes,
    'reduceMotion': reduceMotion,
    'selectedTaskId': selectedTaskId,
    'activeTaskId': _activeTaskId,
    'isBreak': isBreak,
    'timerFinished': timerFinished,
    'remaining': _remaining,
    'sessionMinutes': _sessionMinutes,
    'deadline': _deadline?.toIso8601String(),
  };
  void _changed() {
    _save();
    if (!_disposed) notifyListeners();
  }

  void _save() {
    final snapshot = jsonEncode(_json());
    _writes = _writes.then((_) async {
      try {
        await repository.write(snapshot);
        storageError = null;
      } catch (_) {
        storageError =
            'No se guardaron los últimos cambios. Reintenta antes de cerrar.';
      }
      if (!_disposed) notifyListeners();
    });
  }

  Future<void> flush() => _writes;
  Future<void> retrySave() {
    _save();
    return flush();
  }

  @override
  void dispose() {
    _disposed = true;
    _ticker?.cancel();
    super.dispose();
  }
}
