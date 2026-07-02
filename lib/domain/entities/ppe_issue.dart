class PPEIssue {
  final String id;
  final String employeeId;
  final String ppeType; // e.g., 'Helmet', 'Boots', 'Vest'
  final int quantity;
  final DateTime issueDate;
  final DateTime? returnDate;

  PPEIssue({
    required this.id,
    required this.employeeId,
    required this.ppeType,
    required this.quantity,
    required this.issueDate,
    this.returnDate,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'employeeId': employeeId,
        'ppeType': ppeType,
        'quantity': quantity,
        'issueDate': issueDate.toIso8601String(),
        'returnDate': returnDate?.toIso8601String(),
      };

  factory PPEIssue.fromMap(Map<String, dynamic> map) => PPEIssue(
        id: map['id'] as String,
        employeeId: map['employeeId'] as String,
        ppeType: map['ppeType'] as String,
        quantity: map['quantity'] as int,
        issueDate: DateTime.parse(map['issueDate'] as String),
        returnDate: map['returnDate'] != null
            ? DateTime.parse(map['returnDate'] as String)
            : null,
      );
}