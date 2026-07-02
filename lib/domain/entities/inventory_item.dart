import '../../core/constants/app_constants.dart';

class InventoryItem {
  final String id;
  final String sku;
  final String name;
  final String description;
  final String category;
  final double unitPrice;
  final double costPrice;
  final int quantity;
  final int reorderLevel;
  final String supplierName;
  final bool isVatable;
  final String? imageUrl;
  final String? barcode;
  final DateTime createdAt;
  final DateTime? updatedAt;

  InventoryItem({
    required this.id,
    required this.sku,
    required this.name,
    this.description = '',
    required this.category,
    required this.unitPrice,
    required this.costPrice,
    required this.quantity,
    required this.reorderLevel,
    this.supplierName = '',
    this.isVatable = true,
    this.imageUrl,
    this.barcode,
    required this.createdAt,
    this.updatedAt,
  });

  bool get needsReorder => quantity <= reorderLevel;
  double get vatAmount  => isVatable ? unitPrice * AppConstants.vatRate : 0;
  double get priceWithVat => unitPrice + vatAmount;
  double get profitMargin => unitPrice > 0 ? ((unitPrice - costPrice) / unitPrice) * 100 : 0;
  double get stockValue   => unitPrice * quantity;

  Map<String, dynamic> toMap() => {
    'id': id, 'sku': sku, 'name': name, 'description': description,
    'category': category, 'unitPrice': unitPrice, 'costPrice': costPrice,
    'quantity': quantity, 'reorderLevel': reorderLevel,
    'supplierName': supplierName, 'isVatable': isVatable,
    'imageUrl': imageUrl, 'barcode': barcode,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  factory InventoryItem.fromMap(Map<String, dynamic> m) => InventoryItem(
    id: m['id'], sku: m['sku'], name: m['name'],
    description: m['description'] ?? '',
    category: m['category'],
    unitPrice: (m['unitPrice'] as num).toDouble(),
    costPrice: (m['costPrice'] as num).toDouble(),
    quantity: m['quantity'] as int,
    reorderLevel: m['reorderLevel'] as int,
    supplierName: m['supplierName'] ?? '',
    isVatable: m['isVatable'] ?? true,
    imageUrl: m['imageUrl'],
    barcode: m['barcode'],
    createdAt: DateTime.parse(m['createdAt']),
    updatedAt: m['updatedAt'] != null ? DateTime.parse(m['updatedAt']) : null,
  );

  InventoryItem copyWith({int? quantity, double? unitPrice, double? costPrice, String? imageUrl, String? barcode}) => InventoryItem(
    id: id, sku: sku, name: name, description: description, category: category,
    unitPrice: unitPrice ?? this.unitPrice, costPrice: costPrice ?? this.costPrice,
    quantity: quantity ?? this.quantity, reorderLevel: reorderLevel,
    supplierName: supplierName, isVatable: isVatable,
    imageUrl: imageUrl ?? this.imageUrl, barcode: barcode ?? this.barcode,
    createdAt: createdAt, updatedAt: DateTime.now(),
  );
}
