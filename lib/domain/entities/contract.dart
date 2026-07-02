enum ContractStatus { active, expiring, expired, completed, terminated }
enum ContractType { framework, fixed, callOff, maintenance, supply }

class Contract {
  final String id;
  final String contractNumber;
  final String title;
  final String clientName;
  final DateTime startDate;
  final DateTime endDate;
  final double maximumValue;
  final double usedValue;
  final ContractStatus status;
  final ContractType type;
  final double? performanceBond;
  final List<String> variationOrders;
  final List<String> linkedProjects; // project IDs
  final DateTime createdAt;
  final DateTime updatedAt;

  Contract({
    required this.id,
    required this.contractNumber,
    required this.title,
    required this.clientName,
    required this.startDate,
    required this.endDate,
    required this.maximumValue,
    this.usedValue = 0.0,
    this.status = ContractStatus.active,
    required this.type,
    this.performanceBond,
    this.variationOrders = const [],
    this.linkedProjects = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  double get remaining => maximumValue - usedValue;
  double get utilization => maximumValue > 0 ? (usedValue / maximumValue * 100) : 0;

  Map<String, dynamic> toMap() => {
        'id': id,
        'contractNumber': contractNumber,
        'title': title,
        'clientName': clientName,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'maximumValue': maximumValue,
        'usedValue': usedValue,
        'status': status.name,
        'type': type.name,
        'performanceBond': performanceBond,
        'variationOrders': variationOrders,
        'linkedProjects': linkedProjects,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Contract.fromMap(Map<String, dynamic> map) => Contract(
        id: map['id'] as String,
        contractNumber: map['contractNumber'] as String,
        title: map['title'] as String,
        clientName: map['clientName'] as String,
        startDate: DateTime.parse(map['startDate'] as String),
        endDate: DateTime.parse(map['endDate'] as String),
        maximumValue: map['maximumValue'] as double,
        usedValue: map['usedValue'] as double? ?? 0.0,
        status: ContractStatus.values.firstWhere(
            (e) => e.name == map['status'],
            orElse: () => ContractStatus.active),
        type: ContractType.values.firstWhere(
            (e) => e.name == map['type'],
            orElse: () => ContractType.framework),
        performanceBond: map['performanceBond'] as double?,
        variationOrders: (map['variationOrders'] as List?)?.cast<String>() ?? [],
        linkedProjects: (map['linkedProjects'] as List?)?.cast<String>() ?? [],
        createdAt: DateTime.parse(map['createdAt'] as String),
        updatedAt: DateTime.parse(map['updatedAt'] as String),
      );
}