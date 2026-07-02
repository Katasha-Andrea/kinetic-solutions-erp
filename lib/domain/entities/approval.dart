enum ApprovalType {
  leave,
  purchaseOrder,
  expense,
  tender,
  contract,
  stockAdjustment,
  vehicleRequest,
  assetDisposal,
  materialIssue,
  overtime,
  travel
}

enum ApprovalStatus { pending, approved, rejected, cancelled }

class ApprovalStep {
  final int level;
  final String approver; // role or user ID
  final String? actualApprover;
  final String? comment;
  final DateTime? timestamp;
  final ApprovalStatus status;

  ApprovalStep({
    required this.level,
    required this.approver,
    this.actualApprover,
    this.comment,
    this.timestamp,
    this.status = ApprovalStatus.pending,
  });

  Map<String, dynamic> toMap() => {
        'level': level,
        'approver': approver,
        'actualApprover': actualApprover,
        'comment': comment,
        'timestamp': timestamp?.toIso8601String(),
        'status': status.name,
      };

  factory ApprovalStep.fromMap(Map<String, dynamic> map) => ApprovalStep(
        level: map['level'] as int,
        approver: map['approver'] as String,
        actualApprover: map['actualApprover'] as String?,
        comment: map['comment'] as String?,
        timestamp: map['timestamp'] != null
            ? DateTime.parse(map['timestamp'] as String)
            : null,
        status: ApprovalStatus.values.firstWhere(
            (e) => e.name == map['status'],
            orElse: () => ApprovalStatus.pending),
      );
}

class Approval {
  final String id;
  final ApprovalType type;
  final String referenceId; // ID of the underlying request
  final String title;
  final String details;
  final String requestedBy; // user ID
  final ApprovalStatus status;
  final int currentLevel;
  final int totalLevels;
  final List<ApprovalStep> steps;
  final DateTime requestedAt;

  Approval({
    required this.id,
    required this.type,
    required this.referenceId,
    required this.title,
    required this.details,
    required this.requestedBy,
    this.status = ApprovalStatus.pending,
    this.currentLevel = 0,
    this.totalLevels = 0,
    this.steps = const [],
    DateTime? requestedAt,
  }) : requestedAt = requestedAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'type': type.name,
        'referenceId': referenceId,
        'title': title,
        'details': details,
        'requestedBy': requestedBy,
        'status': status.name,
        'currentLevel': currentLevel,
        'totalLevels': totalLevels,
        'steps': steps.map((s) => s.toMap()).toList(),
        'requestedAt': requestedAt.toIso8601String(),
      };

  factory Approval.fromMap(Map<String, dynamic> map) => Approval(
        id: map['id'] as String,
        type: ApprovalType.values.firstWhere(
            (e) => e.name == map['type'],
            orElse: () => ApprovalType.leave),
        referenceId: map['referenceId'] as String,
        title: map['title'] as String,
        details: map['details'] as String,
        requestedBy: map['requestedBy'] as String,
        status: ApprovalStatus.values.firstWhere(
            (e) => e.name == map['status'],
            orElse: () => ApprovalStatus.pending),
        currentLevel: map['currentLevel'] as int? ?? 0,
        totalLevels: map['totalLevels'] as int? ?? 0,
        steps: (map['steps'] as List?)
                ?.map((e) => ApprovalStep.fromMap(e as Map<String, dynamic>))
                .toList() ??
            [],
        requestedAt: DateTime.parse(map['requestedAt'] as String),
      );
}