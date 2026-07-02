class SiteDiary {
  final String id;
  final String projectId;
  final String woNumber; // work order number
  final DateTime date;
  final String weather;
  final String temperature;
  final List<String> workersPresent; // employee IDs
  final List<Map<String, dynamic>> equipmentUsed; // [{name, hours}]
  final List<Map<String, dynamic>> materialsUsed; // [{name, quantity, unit}]
  final String workCompleted;
  final String issuesEncountered;
  final String safetyIncidents;
  final String visitors;
  final String supervisorName;
  final bool isSubmitted;

  SiteDiary({
    required this.id,
    required this.projectId,
    required this.woNumber,
    required this.date,
    this.weather = '',
    this.temperature = '',
    this.workersPresent = const [],
    this.equipmentUsed = const [],
    this.materialsUsed = const [],
    this.workCompleted = '',
    this.issuesEncountered = '',
    this.safetyIncidents = '',
    this.visitors = '',
    required this.supervisorName,
    this.isSubmitted = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'projectId': projectId,
        'woNumber': woNumber,
        'date': date.toIso8601String(),
        'weather': weather,
        'temperature': temperature,
        'workersPresent': workersPresent,
        'equipmentUsed': equipmentUsed,
        'materialsUsed': materialsUsed,
        'workCompleted': workCompleted,
        'issuesEncountered': issuesEncountered,
        'safetyIncidents': safetyIncidents,
        'visitors': visitors,
        'supervisorName': supervisorName,
        'isSubmitted': isSubmitted,
      };

  factory SiteDiary.fromMap(Map<String, dynamic> map) => SiteDiary(
        id: map['id'] as String,
        projectId: map['projectId'] as String,
        woNumber: map['woNumber'] as String,
        date: DateTime.parse(map['date'] as String),
        weather: map['weather'] as String? ?? '',
        temperature: map['temperature'] as String? ?? '',
        workersPresent: (map['workersPresent'] as List?)?.cast<String>() ?? [],
        equipmentUsed: (map['equipmentUsed'] as List?)?.cast<Map<String, dynamic>>() ?? [],
        materialsUsed: (map['materialsUsed'] as List?)?.cast<Map<String, dynamic>>() ?? [],
        workCompleted: map['workCompleted'] as String? ?? '',
        issuesEncountered: map['issuesEncountered'] as String? ?? '',
        safetyIncidents: map['safetyIncidents'] as String? ?? '',
        visitors: map['visitors'] as String? ?? '',
        supervisorName: map['supervisorName'] as String,
        isSubmitted: map['isSubmitted'] as bool? ?? false,
      );
}