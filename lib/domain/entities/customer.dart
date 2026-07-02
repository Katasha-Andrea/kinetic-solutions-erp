enum CustomerType { retail, wholesale, government, ngo }

extension CustomerTypeExt on CustomerType {
  String get label {
    switch (this) {
      case CustomerType.retail:      return 'Retail';
      case CustomerType.wholesale:   return 'Wholesale';
      case CustomerType.government:  return 'Government';
      case CustomerType.ngo:         return 'NGO';
    }
  }
}

class Customer {
  final String id;
  final String companyName;
  final String contactPerson;
  final String phoneNumber;
  final String email;
  final String address;
  final String taxId; // TPIN
  final CustomerType type;
  final double creditLimit;
  final double currentBalance;
  final DateTime createdAt;

  Customer({
    required this.id,
    required this.companyName,
    required this.contactPerson,
    required this.phoneNumber,
    this.email = '',
    this.address = '',
    this.taxId = '',
    this.type = CustomerType.retail,
    this.creditLimit = 0,
    this.currentBalance = 0,
    required this.createdAt,
  });

  String get initials {
    final parts = companyName.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return companyName.substring(0, companyName.length >= 2 ? 2 : 1).toUpperCase();
  }

  Map<String, dynamic> toMap() => {
    'id': id, 'companyName': companyName, 'contactPerson': contactPerson,
    'phoneNumber': phoneNumber, 'email': email, 'address': address,
    'taxId': taxId, 'type': type.name, 'creditLimit': creditLimit,
    'currentBalance': currentBalance, 'createdAt': createdAt.toIso8601String(),
  };

  factory Customer.fromMap(Map<String, dynamic> m) => Customer(
    id: m['id'], companyName: m['companyName'], contactPerson: m['contactPerson'],
    phoneNumber: m['phoneNumber'], email: m['email'] ?? '', address: m['address'] ?? '',
    taxId: m['taxId'] ?? '',
    type: CustomerType.values.firstWhere((t) => t.name == m['type'], orElse: () => CustomerType.retail),
    creditLimit: (m['creditLimit'] as num? ?? 0).toDouble(),
    currentBalance: (m['currentBalance'] as num? ?? 0).toDouble(),
    createdAt: DateTime.parse(m['createdAt']),
  );
}
