class Car {
  const Car({
    required this.id,
    required this.brand,
    required this.model,
    required this.year,
    this.color,
    this.plates,
    this.vin,
    this.ownerName,
    this.notes,
    required this.isActive,
  });

  final String id;
  final String brand;
  final String model;
  final int year;
  final String? color;

  /// Solo llegan para el personal; el API los omite para clientes.
  final String? plates;
  final String? vin;
  final String? ownerName;
  final String? notes;

  final bool isActive;

  String get title => '$brand $model';

  factory Car.fromApi(Map<String, dynamic> json) => Car(
        id: json['id'] as String,
        brand: json['brand'] as String,
        model: json['model'] as String,
        year: num.tryParse('${json['year']}')?.toInt() ?? 0,
        color: _blankToNull(json['color']),
        plates: _blankToNull(json['plates']),
        vin: _blankToNull(json['vin']),
        ownerName: _blankToNull(json['owner_name']),
        notes: _blankToNull(json['notes']),
        isActive: json['is_active'] != false,
      );

  factory Car.fromDb(Map<String, Object?> row) => Car(
        id: row['id'] as String,
        brand: row['brand'] as String,
        model: row['model'] as String,
        year: row['year'] as int,
        color: row['color'] as String?,
        plates: row['plates'] as String?,
        vin: row['vin'] as String?,
        ownerName: row['owner_name'] as String?,
        notes: row['notes'] as String?,
        isActive: row['is_active'] == 1,
      );

  Map<String, Object?> toDb() => {
        'id': id,
        'brand': brand,
        'model': model,
        'year': year,
        'color': color,
        'plates': plates,
        'vin': vin,
        'owner_name': ownerName,
        'notes': notes,
        'is_active': isActive ? 1 : 0,
      };

  static String? _blankToNull(Object? value) {
    final text = value?.toString().trim();
    return (text == null || text.isEmpty) ? null : text;
  }
}
