class Supplier {
  final String id;
  final String companyName;
  final String contactPerson;
  final String phoneNumber;
  final String email;
  final String address;
  final String taxId; // TPIN
  final String category; // e.g., 'Materials', 'Services'
  final double? rating; // 1–5
  final int totalOrders;
  final double totalPurchases;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Supplier({
    required this.id,
    required this.companyName,
    required this.contactPerson,
    required this.phoneNumber,
    required this.email,
    required this.address,
    required this.taxId,
    required this.category,
    this.rating,
    this.totalOrders = 0,
    this.totalPurchases = 0.0,
    this.isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'id': id,
        'companyName': companyName,
        'contactPerson': contactPerson,
        'phoneNumber': phoneNumber,
        'email': email,
        'address': address,
        'taxId': taxId,
        'category': category,
        'rating': rating,
        'totalOrders': totalOrders,
        'totalPurchases': totalPurchases,
        'isActive': isActive,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Supplier.fromMap(Map<String, dynamic> map) => Supplier(
        id: map['id'] as String,
        companyName: map['companyName'] as String,
        contactPerson: map['contactPerson'] as String,
        phoneNumber: map['phoneNumber'] as String,
        email: map['email'] as String,
        address: map['address'] as String,
        taxId: map['taxId'] as String,
        category: map['category'] as String,
        rating: map['rating'] as double?,
        totalOrders: map['totalOrders'] as int? ?? 0,
        totalPurchases: map['totalPurchases'] as double? ?? 0.0,
        isActive: map['isActive'] as bool? ?? true,
        createdAt: DateTime.parse(map['createdAt'] as String),
        updatedAt: DateTime.parse(map['updatedAt'] as String),
      );
}