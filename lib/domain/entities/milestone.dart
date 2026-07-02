class Milestone {
  final String id;
  final String projectId;
  final String title;
  final DateTime targetDate;
  final bool isCompleted;
  final double weight; // percentage contribution to project progress

  Milestone({
    required this.id,
    required this.projectId,
    required this.title,
    required this.targetDate,
    this.isCompleted = false,
    this.weight = 0.0,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'projectId': projectId,
        'title': title,
        'targetDate': targetDate.toIso8601String(),
        'isCompleted': isCompleted,
        'weight': weight,
      };

  factory Milestone.fromMap(Map<String, dynamic> map) => Milestone(
        id: map['id'] as String,
        projectId: map['projectId'] as String,
        title: map['title'] as String,
        targetDate: DateTime.parse(map['targetDate'] as String),
        isCompleted: map['isCompleted'] as bool? ?? false,
        weight: map['weight'] as double? ?? 0.0,
      );
}