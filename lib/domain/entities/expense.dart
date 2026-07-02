enum ExpenseStatus { paid, pending, approved }

class Expense {
  final String id;
  final String category; // e.g., 'Fuel', 'Travel', 'Office Supplies'
  final String description;
  final double amount;
  final DateTime date;
  final ExpenseStatus status;
  final String? projectId; // optional link
  final String? receiptImage; // path or URL

  Expense({
    required this.id,
    required this.category,
    required this.description,
    required this.amount,
    required this.date,
    this.status = ExpenseStatus.pending,
    this.projectId,
    this.receiptImage,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'category': category,
        'description': description,
        'amount': amount,
        'date': date.toIso8601String(),
        'status': status.name,
        'projectId': projectId,
        'receiptImage': receiptImage,
      };

  factory Expense.fromMap(Map<String, dynamic> map) => Expense(
        id: map['id'] as String,
        category: map['category'] as String,
        description: map['description'] as String,
        amount: map['amount'] as double,
        date: DateTime.parse(map['date'] as String),
        status: ExpenseStatus.values.firstWhere(
            (e) => e.name == map['status'],
            orElse: () => ExpenseStatus.pending),
        projectId: map['projectId'] as String?,
        receiptImage: map['receiptImage'] as String?,
      );
}