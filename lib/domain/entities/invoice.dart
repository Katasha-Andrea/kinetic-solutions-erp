enum InvoiceStatus { paid, sent, overdue, draft, cancelled }

class Invoice {
  final String id;
  final String invoiceNumber;
  final String customerId;
  final double total;
  final InvoiceStatus status;
  final DateTime dueDate;
  final DateTime createdAt;

  Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.customerId,
    required this.total,
    this.status = InvoiceStatus.sent,
    required this.dueDate,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isOverdue => dueDate.isBefore(DateTime.now()) && status != InvoiceStatus.paid;

  Map<String, dynamic> toMap() => {
        'id': id,
        'invoiceNumber': invoiceNumber,
        'customerId': customerId,
        'total': total,
        'status': status.name,
        'dueDate': dueDate.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory Invoice.fromMap(Map<String, dynamic> map) => Invoice(
        id: map['id'] as String,
        invoiceNumber: map['invoiceNumber'] as String,
        customerId: map['customerId'] as String,
        total: map['total'] as double,
        status: InvoiceStatus.values.firstWhere(
            (e) => e.name == map['status'],
            orElse: () => InvoiceStatus.sent),
        dueDate: DateTime.parse(map['dueDate'] as String),
        createdAt: DateTime.parse(map['createdAt'] as String),
      );
}