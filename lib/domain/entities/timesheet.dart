class Timesheet {
  final String id;
  final String employeeId;
  final String projectId;
  final DateTime date;
  final double hours;
  final String task;

  Timesheet({
    required this.id,
    required this.employeeId,
    required this.projectId,
    required this.date,
    required this.hours,
    required this.task,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'employeeId': employeeId,
        'projectId': projectId,
        'date': date.toIso8601String(),
        'hours': hours,
        'task': task,
      };

  factory Timesheet.fromMap(Map<String, dynamic> map) => Timesheet(
        id: map['id'] as String,
        employeeId: map['employeeId'] as String,
        projectId: map['projectId'] as String,
        date: DateTime.parse(map['date'] as String),
        hours: map['hours'] as double,
        task: map['task'] as String,
      );
}