enum MIVStatus { issued, returned }

class MaterialIssue {
  final String id;
  final String issueNumber;
  final String projectId;
  final String projectName;
  final String requestedBy;
  final String issuedBy;
  final List<Map<String, dynamic>> items; // [{itemId, name, quantity, unit}]
  final MIVStatus status;
  final DateTime createdAt;

  MaterialIssue({
    required this.id,
    required this.issueNumber,
    required this.projectId,
    required this.projectName,
    required this.requestedBy,
    required this.issuedBy,
    this.items = const [],
    this.status = MIVStatus.issued,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'issueNumber': issueNumber,
        'projectId': projectId,
        'projectName': projectName,
        'requestedBy': requestedBy,
        'issuedBy': issuedBy,
        'items': items,
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
      };

  factory MaterialIssue.fromMap(Map<String, dynamic> map) => MaterialIssue(
        id: map['id'] as String,
        issueNumber: map['issueNumber'] as String,
        projectId: map['projectId'] as String,
        projectName: map['projectName'] as String,
        requestedBy: map['requestedBy'] as String,
        issuedBy: map['issuedBy'] as String,
        items: (map['items'] as List?)?.cast<Map<String, dynamic>>() ?? [],
        status: MIVStatus.values.firstWhere(
            (e) => e.name == map['status'],
            orElse: () => MIVStatus.issued),
        createdAt: DateTime.parse(map['createdAt'] as String),
      );
}