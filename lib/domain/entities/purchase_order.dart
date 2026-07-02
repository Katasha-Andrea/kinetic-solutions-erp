enum POStatus { draft, pendingApproval, approved, sent, delivered, cancelled }

class PurchaseOrder {
  final String id;
  final String poNumber;
  final String supplierId;
  final String supplierName;
  final DateTime orderDate;
  final double total;
  final POStatus status;
  final List<Map<String, dynamic>> items; // [{description, quantity, unitPrice, total}]
  final String requestedBy;
  final DateTime createdAt;

  PurchaseOrder({
    required this.id,
    required this.poNumber,
    required this.supplierId,
    required this.supplierName,
    required this.orderDate,
    this.total = 0.0,
    this.status = POStatus.draft,
    this.items = const [],
    required this.requestedBy,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'poNumber': poNumber,
        'supplierId': supplierId,
        'supplierName': supplierName,
        'orderDate': orderDate.toIso8601String(),
        'total': total,
        'status': status.name,
        'items': items,
        'requestedBy': requestedBy,
        'createdAt': createdAt.toIso8601String(),
      };

  factory PurchaseOrder.fromMap(Map<String, dynamic> map) => PurchaseOrder(
        id: map['id'] as String,
        poNumber: map['poNumber'] as String,
        supplierId: map['supplierId'] as String,
        supplierName: map['supplierName'] as String,
        orderDate: DateTime.parse(map['orderDate'] as String),
        total: map['total'] as double? ?? 0.0,
        status: POStatus.values.firstWhere(
            (e) => e.name == map['status'],
            orElse: () => POStatus.draft),
        items: (map['items'] as List?)?.cast<Map<String, dynamic>>() ?? [],
        requestedBy: map['requestedBy'] as String,
        createdAt: DateTime.parse(map['createdAt'] as String),
      );
}