enum WOStatus { pending, assigned, inProgress, completed, onHold, cancelled }
enum WOPriority { critical, high, medium, low }

class WorkOrder {
  final String id;
  final String woNumber;
  final String projectId;
  final String title;
  final String description;
  final String location;
  final double? gpsLat;
  final double? gpsLon;
  final String supervisorName;
  final String assignedTeamMembers; // comma-separated names or IDs
  final String? vehicleId;
  final WOStatus status;
  final WOPriority priority;
  final DateTime startDate;
  final double estimatedHours;
  final double actualHours;
  final int completionPercent;
  final List<String> materialUsed; // inventory item IDs
  final List<String> photosBefore;
  final List<String> photosAfter;
  final List<Map<String, dynamic>> activityLog;
  final String? clientSignature;
  final DateTime createdAt;
  final DateTime updatedAt;

  WorkOrder({
    required this.id,
    required this.woNumber,
    required this.projectId,
    required this.title,
    required this.description,
    required this.location,
    this.gpsLat,
    this.gpsLon,
    required this.supervisorName,
    this.assignedTeamMembers = '',
    this.vehicleId,
    this.status = WOStatus.pending,
    this.priority = WOPriority.medium,
    required this.startDate,
    this.estimatedHours = 0,
    this.actualHours = 0,
    this.completionPercent = 0,
    this.materialUsed = const [],
    this.photosBefore = const [],
    this.photosAfter = const [],
    this.activityLog = const [],
    this.clientSignature,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'woNumber': woNumber,
        'projectId': projectId,
        'title': title,
        'description': description,
        'location': location,
        'gpsLat': gpsLat,
        'gpsLon': gpsLon,
        'supervisorName': supervisorName,
        'assignedTeamMembers': assignedTeamMembers,
        'vehicleId': vehicleId,
        'status': status.name,
        'priority': priority.name,
        'startDate': startDate.toIso8601String(),
        'estimatedHours': estimatedHours,
        'actualHours': actualHours,
        'completionPercent': completionPercent,
        'materialUsed': materialUsed,
        'photosBefore': photosBefore,
        'photosAfter': photosAfter,
        'activityLog': activityLog,
        'clientSignature': clientSignature,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory WorkOrder.fromMap(Map<String, dynamic> map) => WorkOrder(
        id: map['id'] as String,
        woNumber: map['woNumber'] as String,
        projectId: map['projectId'] as String,
        title: map['title'] as String,
        description: map['description'] as String,
        location: map['location'] as String,
        gpsLat: map['gpsLat'] as double?,
        gpsLon: map['gpsLon'] as double?,
        supervisorName: map['supervisorName'] as String,
        assignedTeamMembers: map['assignedTeamMembers'] as String? ?? '',
        vehicleId: map['vehicleId'] as String?,
        status: WOStatus.values.firstWhere(
            (e) => e.name == map['status'],
            orElse: () => WOStatus.pending),
        priority: WOPriority.values.firstWhere(
            (e) => e.name == map['priority'],
            orElse: () => WOPriority.medium),
        startDate: DateTime.parse(map['startDate'] as String),
        estimatedHours: map['estimatedHours'] as double? ?? 0,
        actualHours: map['actualHours'] as double? ?? 0,
        completionPercent: map['completionPercent'] as int? ?? 0,
        materialUsed: (map['materialUsed'] as List?)?.cast<String>() ?? [],
        photosBefore: (map['photosBefore'] as List?)?.cast<String>() ?? [],
        photosAfter: (map['photosAfter'] as List?)?.cast<String>() ?? [],
        activityLog: (map['activityLog'] as List?)?.cast<Map<String, dynamic>>() ?? [],
        clientSignature: map['clientSignature'] as String?,
        createdAt: DateTime.parse(map['createdAt'] as String),
        updatedAt: DateTime.parse(map['updatedAt'] as String),
      );
}