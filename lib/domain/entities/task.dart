enum TaskPriority { low, medium, high, critical }
enum TaskStatus  { todo, inProgress, review, done, blocked }

extension TaskPriorityExt on TaskPriority {
  String get label {
    switch (this) {
      case TaskPriority.low:      return 'Low';
      case TaskPriority.medium:   return 'Medium';
      case TaskPriority.high:     return 'High';
      case TaskPriority.critical: return 'Critical';
    }
  }
}

extension TaskStatusExt on TaskStatus {
  String get label {
    switch (this) {
      case TaskStatus.todo:       return 'To Do';
      case TaskStatus.inProgress: return 'In Progress';
      case TaskStatus.review:     return 'Review';
      case TaskStatus.done:       return 'Done';
      case TaskStatus.blocked:    return 'Blocked';
    }
  }
}

class Task {
  final String id;
  final String projectId;
  final String title;
  final String description;
  final String assignedTo;
  final TaskPriority priority;
  final TaskStatus status;
  final DateTime startDate;
  final DateTime dueDate;
  final DateTime? completedAt;
  final double estimatedHours;
  final double actualHours;
  final int completionPercentage;

  Task({
    required this.id,
    required this.projectId,
    required this.title,
    this.description = '',
    this.assignedTo = '',
    this.priority = TaskPriority.medium,
    this.status = TaskStatus.todo,
    required this.startDate,
    required this.dueDate,
    this.completedAt,
    this.estimatedHours = 0,
    this.actualHours = 0,
    this.completionPercentage = 0,
  });

  bool get isOverdue => dueDate.isBefore(DateTime.now()) && status != TaskStatus.done;

  Map<String, dynamic> toMap() => {
    'id': id, 'projectId': projectId, 'title': title, 'description': description,
    'assignedTo': assignedTo, 'priority': priority.name, 'status': status.name,
    'startDate': startDate.toIso8601String(), 'dueDate': dueDate.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
    'estimatedHours': estimatedHours, 'actualHours': actualHours,
    'completionPercentage': completionPercentage,
  };

  factory Task.fromMap(Map<String, dynamic> m) => Task(
    id: m['id'], projectId: m['projectId'], title: m['title'],
    description: m['description'] ?? '', assignedTo: m['assignedTo'] ?? '',
    priority: TaskPriority.values.firstWhere((p) => p.name == m['priority'], orElse: () => TaskPriority.medium),
    status: TaskStatus.values.firstWhere((s) => s.name == m['status'], orElse: () => TaskStatus.todo),
    startDate: DateTime.parse(m['startDate']), dueDate: DateTime.parse(m['dueDate']),
    completedAt: m['completedAt'] != null ? DateTime.parse(m['completedAt']) : null,
    estimatedHours: (m['estimatedHours'] as num? ?? 0).toDouble(),
    actualHours: (m['actualHours'] as num? ?? 0).toDouble(),
    completionPercentage: m['completionPercentage'] as int? ?? 0,
  );
}
