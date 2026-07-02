enum AttendanceStatus { present, late, absent, onLeave }

class Attendance {
  final String id;
  final String employeeId;
  final String employeeName;
  final DateTime date;
  final DateTime? clockIn;
  final DateTime? clockOut;
  final double hoursWorked;
  final bool isLate;
  final AttendanceStatus status;

  Attendance({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.date,
    this.clockIn,
    this.clockOut,
    this.hoursWorked = 0,
    this.isLate = false,
    this.status = AttendanceStatus.present,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'employeeId': employeeId,
        'employeeName': employeeName,
        'date': date.toIso8601String(),
        'clockIn': clockIn?.toIso8601String(),
        'clockOut': clockOut?.toIso8601String(),
        'hoursWorked': hoursWorked,
        'isLate': isLate,
        'status': status.name,
      };

  factory Attendance.fromMap(Map<String, dynamic> map) => Attendance(
        id: map['id'] as String,
        employeeId: map['employeeId'] as String,
        employeeName: map['employeeName'] as String,
        date: DateTime.parse(map['date'] as String),
        clockIn: map['clockIn'] != null
            ? DateTime.parse(map['clockIn'] as String)
            : null,
        clockOut: map['clockOut'] != null
            ? DateTime.parse(map['clockOut'] as String)
            : null,
        hoursWorked: map['hoursWorked'] as double? ?? 0,
        isLate: map['isLate'] as bool? ?? false,
        status: AttendanceStatus.values.firstWhere(
            (e) => e.name == map['status'],
            orElse: () => AttendanceStatus.present),
      );
}