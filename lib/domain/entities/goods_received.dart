enum GRNStatus { received, accepted }

class GoodsReceived {
  final String id;
  final String grnNumber;
  final String poId;
  final String poNumber;
  final String supplierId;
  final String supplierName;
  final DateTime receivedDate;
  final List<Map<String, dynamic>> items; // [{itemId, name, quantity, unit, condition?}]
  final String receivedBy;
  final GRNStatus status;

  GoodsReceived({
    required this.id,
    required this.grnNumber,
    required this.poId,
    required this.poNumber,
    required this.supplierId,
    required this.supplierName,
    required this.receivedDate,
    this.items = const [],
    required this.receivedBy,
    this.status = GRNStatus.received,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'grnNumber': grnNumber,
        'poId': poId,
        'poNumber': poNumber,
        'supplierId': supplierId,
        'supplierName': supplierName,
        'receivedDate': receivedDate.toIso8601String(),
        'items': items,
        'receivedBy': receivedBy,
        'status': status.name,
      };

  factory GoodsReceived.fromMap(Map<String, dynamic> map) => GoodsReceived(
        id: map['id'] as String,
        grnNumber: map['grnNumber'] as String,
        poId: map['poId'] as String,
        poNumber: map['poNumber'] as String,
        supplierId: map['supplierId'] as String,
        supplierName: map['supplierName'] as String,
        receivedDate: DateTime.parse(map['receivedDate'] as String),
        items: (map['items'] as List?)?.cast<Map<String, dynamic>>() ?? [],
        receivedBy: map['receivedBy'] as String,
        status: GRNStatus.values.firstWhere(
            (e) => e.name == map['status'],
            orElse: () => GRNStatus.received),
      );
}