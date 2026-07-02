enum LeaveType { annual, sick, maternity, paternity, study, unpaid }
enum LeaveStatus { pending, approved, rejected, cancelled }

class LeaveRequest {
  final String id;
  final String employeeId;
  final LeaveType type;
  final DateTime startDate;
  final DateTime endDate;
  final int days;
  final String reason;
  final LeaveStatus status;
  final String? approvedBy;
  final DateTime? approvedAt;

  LeaveRequest({
    required this.id,
    required this.employeeId,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.days,
    required this.reason,
    this.status = LeaveStatus.pending,
    this.approvedBy,
    this.approvedAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'employeeId': employeeId,
        'type': type.name,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'days': days,
        'reason': reason,
        'status': status.name,
        'approvedBy': approvedBy,
        'approvedAt': approvedAt?.toIso8601String(),
      };

  factory LeaveRequest.fromMap(Map<String, dynamic> map) => LeaveRequest(
        id: map['id'] as String,
        employeeId: map['employeeId'] as String,
        type: LeaveType.values.firstWhere(
            (e) => e.name == map['type'],
            orElse: () => LeaveType.annual),
        startDate: DateTime.parse(map['startDate'] as String),
        endDate: DateTime.parse(map['endDate'] as String),
        days: map['days'] as int,
        reason: map['reason'] as String,
        status: LeaveStatus.values.firstWhere(
            (e) => e.name == map['status'],
            orElse: () => LeaveStatus.pending),
        approvedBy: map['approvedBy'] as String?,
        approvedAt: map['approvedAt'] != null
            ? DateTime.parse(map['approvedAt'] as String)
            : null,
      );
}