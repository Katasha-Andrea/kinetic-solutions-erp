enum ProjectStatus { planning, inProgress, onHold, completed, cancelled }
enum RiskLevel { low, medium, high, critical }

extension ProjectStatusExt on ProjectStatus {
  String get label {
    switch (this) {
      case ProjectStatus.planning:    return 'Planning';
      case ProjectStatus.inProgress:  return 'In Progress';
      case ProjectStatus.onHold:      return 'On Hold';
      case ProjectStatus.completed:   return 'Completed';
      case ProjectStatus.cancelled:   return 'Cancelled';
    }
  }
}

extension RiskLevelExt on RiskLevel {
  String get label {
    switch (this) {
      case RiskLevel.low:      return 'Low';
      case RiskLevel.medium:   return 'Medium';
      case RiskLevel.high:     return 'High';
      case RiskLevel.critical: return 'Critical';
    }
  }
}

class Project {
  final String id;
  final String name;
  final String description;
  final String clientName;
  final String projectManager;
  final String location;
  final String category;
  final DateTime startDate;
  final DateTime endDate;
  final double budget;
  final double spent;
  final ProjectStatus status;
  final int teamSize;
  final RiskLevel riskLevel;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Project({
    required this.id,
    required this.name,
    this.description = '',
    required this.clientName,
    required this.projectManager,
    this.location = '',
    required this.category,
    required this.startDate,
    required this.endDate,
    required this.budget,
    this.spent = 0,
    this.status = ProjectStatus.planning,
    this.teamSize = 1,
    this.riskLevel = RiskLevel.low,
    this.notes = '',
    required this.createdAt,
    required this.updatedAt,
  });

  double get budgetUtilization => budget > 0 ? (spent / budget) * 100 : 0;
  bool get isAtRisk => riskLevel == RiskLevel.high || riskLevel == RiskLevel.critical;
  bool get isOverdue => endDate.isBefore(DateTime.now()) && status != ProjectStatus.completed;
  double get daysRemaining => endDate.difference(DateTime.now()).inDays.toDouble();

  Map<String, dynamic> toMap() => {
    'id': id, 'name': name, 'description': description, 'clientName': clientName,
    'projectManager': projectManager, 'location': location, 'category': category,
    'startDate': startDate.toIso8601String(), 'endDate': endDate.toIso8601String(),
    'budget': budget, 'spent': spent, 'status': status.name, 'teamSize': teamSize,
    'riskLevel': riskLevel.name, 'notes': notes,
    'createdAt': createdAt.toIso8601String(), 'updatedAt': updatedAt.toIso8601String(),
  };

  factory Project.fromMap(Map<String, dynamic> m) => Project(
    id: m['id'], name: m['name'], description: m['description'] ?? '',
    clientName: m['clientName'], projectManager: m['projectManager'],
    location: m['location'] ?? '', category: m['category'],
    startDate: DateTime.parse(m['startDate']), endDate: DateTime.parse(m['endDate']),
    budget: (m['budget'] as num).toDouble(), spent: (m['spent'] as num? ?? 0).toDouble(),
    status: ProjectStatus.values.firstWhere((s) => s.name == m['status'], orElse: () => ProjectStatus.planning),
    teamSize: m['teamSize'] as int? ?? 1,
    riskLevel: RiskLevel.values.firstWhere((r) => r.name == m['riskLevel'], orElse: () => RiskLevel.low),
    notes: m['notes'] ?? '',
    createdAt: DateTime.parse(m['createdAt']), updatedAt: DateTime.parse(m['updatedAt']),
  );
}
