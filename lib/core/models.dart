enum Priority {
  high('Alta'),
  medium('Media'),
  low('Baja');

  const Priority(this.label);
  final String label;
}

class FocusTask {
  FocusTask({
    required this.id,
    required this.title,
    this.priority = Priority.medium,
    this.category = 'Personal',
    this.completedAt,
    this.scheduledFor,
    this.dueAt,
    List<String>? microSteps,
    Set<int>? completedMicroSteps,
  }) : microSteps = microSteps ?? [],
       completedMicroSteps = completedMicroSteps ?? {};

  final String id;
  String title;
  Priority priority;
  String category;
  DateTime? completedAt;
  DateTime? scheduledFor;
  DateTime? dueAt;
  List<String> microSteps;
  Set<int> completedMicroSteps;

  bool get completed => completedAt != null;
  int get stepsDone => completedMicroSteps.length;
  bool get hasPlan => microSteps.isNotEmpty;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'priority': priority.index,
    'category': category,
    'completedAt': completedAt?.toIso8601String(),
    'scheduledFor': scheduledFor?.toIso8601String(),
    'dueAt': dueAt?.toIso8601String(),
    'microSteps': microSteps,
    'completedMicroSteps': completedMicroSteps.toList()..sort(),
  };

  factory FocusTask.fromJson(Map<String, dynamic> j) {
    final steps = (j['microSteps'] as List<dynamic>? ?? const [])
        .map((s) => s as String)
        .toList();
    return FocusTask(
      id: j['id'] as String,
      title: j['title'] as String,
      priority: Priority.values[j['priority'] as int],
      category: j['category'] as String,
      completedAt: j['completedAt'] == null
          ? null
          : DateTime.parse(j['completedAt'] as String),
      scheduledFor: j['scheduledFor'] == null
          ? null
          : DateTime.parse(j['scheduledFor'] as String),
      dueAt: j['dueAt'] == null
          ? null
          : DateTime.parse(j['dueAt'] as String),
      microSteps: steps,
      completedMicroSteps: ((j['completedMicroSteps'] as List<dynamic>?) ?? const [])
          .map((v) => v as int)
          .where((i) => i >= 0 && i < steps.length)
          .toSet(),
    );
  }
}

class FocusSession {
  const FocusSession({
    required this.endedAt,
    required this.minutes,
    this.taskId,
  });
  final DateTime endedAt;
  final int minutes;
  final String? taskId;
  Map<String, dynamic> toJson() => {
    'endedAt': endedAt.toIso8601String(),
    'minutes': minutes,
    'taskId': taskId,
  };
  factory FocusSession.fromJson(Map<String, dynamic> j) => FocusSession(
    endedAt: DateTime.parse(j['endedAt'] as String),
    minutes: j['minutes'] as int,
    taskId: j['taskId'] as String?,
  );
}
