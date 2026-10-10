class Part {
  const Part({
    required this.id,
    required this.sku,
    required this.name,
    this.brand,
    this.category,
    required this.stock,
    required this.unitPrice,
    this.description,
    required this.isActive,
    this.updatedAt,
  });

  final String id;
  final String sku;
  final String name;
  final String? brand;
  final String? category;
  final int stock;
  final double unitPrice;
  final String? description;
  final bool isActive;
  final String? updatedAt;

  bool get inStock => stock > 0;

  factory Part.fromApi(Map<String, dynamic> json) => Part(
        id: json['id'] as String,
        sku: json['sku'] as String,
        name: json['name'] as String,
        brand: _blankToNull(json['brand']),
        category: _blankToNull(json['category']),
        stock: num.tryParse('${json['stock'] ?? 0}')?.toInt() ?? 0,
        unitPrice: num.tryParse('${json['unit_price'] ?? 0}')?.toDouble() ?? 0,
        description: _blankToNull(json['description']),
        isActive: json['is_active'] != false,
        updatedAt: json['updated_at'] as String?,
      );

  factory Part.fromDb(Map<String, Object?> row) => Part(
        id: row['id'] as String,
        sku: row['sku'] as String,
        name: row['name'] as String,
        brand: row['brand'] as String?,
        category: row['category'] as String?,
        stock: row['stock'] as int,
        unitPrice: (row['unit_price'] as num).toDouble(),
        description: row['description'] as String?,
        isActive: row['is_active'] == 1,
        updatedAt: row['updated_at'] as String?,
      );

  Map<String, Object?> toDb() => {
        'id': id,
        'sku': sku,
        'name': name,
        'brand': brand,
        'category': category,
        'stock': stock,
        'unit_price': unitPrice,
        'description': description,
        'is_active': isActive ? 1 : 0,
        'updated_at': updatedAt,
      };

  static String? _blankToNull(Object? value) {
    final text = value?.toString().trim();
    return (text == null || text.isEmpty) ? null : text;
  }
}
