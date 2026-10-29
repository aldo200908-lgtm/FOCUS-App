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
  });
  final String id;
  String title;
  Priority priority;
  String category;
  DateTime? completedAt;
  bool get completed => completedAt != null;
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'priority': priority.index,
    'category': category,
    'completedAt': completedAt?.toIso8601String(),
  };
  factory FocusTask.fromJson(Map<String, dynamic> j) => FocusTask(
    id: j['id'] as String,
    title: j['title'] as String,
    priority: Priority.values[j['priority'] as int],
    category: j['category'] as String,
    completedAt: j['completedAt'] == null
        ? null
        : DateTime.parse(j['completedAt'] as String),
  );
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
