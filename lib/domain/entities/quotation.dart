class Quotation {
  final String id;
  final String quotationNumber;
  final String clientName;
  final String? tenderReference;
  final List<Map<String, dynamic>> lineItems;
  final double subtotal;
  final double vatAmount;
  final double total;
  final bool isVatable;
  final DateTime createdAt;

  Quotation({
    required this.id,
    required this.quotationNumber,
    required this.clientName,
    this.tenderReference,
    this.lineItems = const [],
    this.subtotal = 0.0,
    this.vatAmount = 0.0,
    this.total = 0.0,
    this.isVatable = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'quotationNumber': quotationNumber,
        'clientName': clientName,
        'tenderReference': tenderReference,
        'lineItems': lineItems,
        'subtotal': subtotal,
        'vatAmount': vatAmount,
        'total': total,
        'isVatable': isVatable,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Quotation.fromMap(Map<String, dynamic> map) => Quotation(
        id: map['id'] as String,
        quotationNumber: map['quotationNumber'] as String,
        clientName: map['clientName'] as String,
        tenderReference: map['tenderReference'] as String?,
        lineItems: (map['lineItems'] as List?)?.cast<Map<String, dynamic>>() ?? [],
        subtotal: map['subtotal'] as double? ?? 0.0,
        vatAmount: map['vatAmount'] as double? ?? 0.0,
        total: map['total'] as double? ?? 0.0,
        isVatable: map['isVatable'] as bool? ?? true,
        createdAt: DateTime.parse(map['createdAt'] as String),
      );
}