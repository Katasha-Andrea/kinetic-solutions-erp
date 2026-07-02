enum PaymentMethod { cash, bankTransfer, mobileMoney, cheque, other }

class Payment {
  final String id;
  final String invoiceId;
  final double amount;
  final PaymentMethod method;
  final DateTime paymentDate;

  Payment({
    required this.id,
    required this.invoiceId,
    required this.amount,
    required this.method,
    required this.paymentDate,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'invoiceId': invoiceId,
        'amount': amount,
        'method': method.name,
        'paymentDate': paymentDate.toIso8601String(),
      };

  factory Payment.fromMap(Map<String, dynamic> map) => Payment(
        id: map['id'] as String,
        invoiceId: map['invoiceId'] as String,
        amount: map['amount'] as double,
        method: PaymentMethod.values.firstWhere(
            (e) => e.name == map['method'],
            orElse: () => PaymentMethod.cash),
        paymentDate: DateTime.parse(map['paymentDate'] as String),
      );
}
