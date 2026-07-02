enum AssetStatus { active, maintenance, disposed, transferred }

class Asset {
  final String id;
  final String name;
  final String category;
  final String serialNumber;
  final double purchaseCost;
  final double currentValue;
  final DateTime purchaseDate;
  final DateTime warrantyExpiry;
  final String? assignedToEmployee; // employee ID
  final AssetStatus status;
  final double depreciationRate; // annual percentage

  Asset({
    required this.id,
    required this.name,
    required this.category,
    required this.serialNumber,
    required this.purchaseCost,
    required this.currentValue,
    required this.purchaseDate,
    required this.warrantyExpiry,
    this.assignedToEmployee,
    this.status = AssetStatus.active,
    this.depreciationRate = 10.0,
  });

  double get depreciatedValue {
    final months = DateTime.now().difference(purchaseDate).inDays / 30.0;
    final annualDepreciation = purchaseCost * (depreciationRate / 100);
    final totalDepreciation = annualDepreciation * (months / 12);
    return (purchaseCost - totalDepreciation).clamp(0, purchaseCost);
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'category': category,
        'serialNumber': serialNumber,
        'purchaseCost': purchaseCost,
        'currentValue': currentValue,
        'purchaseDate': purchaseDate.toIso8601String(),
        'warrantyExpiry': warrantyExpiry.toIso8601String(),
        'assignedToEmployee': assignedToEmployee,
        'status': status.name,
        'depreciationRate': depreciationRate,
      };

  factory Asset.fromMap(Map<String, dynamic> map) => Asset(
        id: map['id'] as String,
        name: map['name'] as String,
        category: map['category'] as String,
        serialNumber: map['serialNumber'] as String,
        purchaseCost: map['purchaseCost'] as double,
        currentValue: map['currentValue'] as double,
        purchaseDate: DateTime.parse(map['purchaseDate'] as String),
        warrantyExpiry: DateTime.parse(map['warrantyExpiry'] as String),
        assignedToEmployee: map['assignedToEmployee'] as String?,
        status: AssetStatus.values.firstWhere(
            (e) => e.name == map['status'],
            orElse: () => AssetStatus.active),
        depreciationRate: map['depreciationRate'] as double? ?? 10.0,
      );
}