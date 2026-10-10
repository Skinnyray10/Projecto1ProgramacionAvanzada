import 'package:flutter_test/flutter_test.dart';
import 'package:hmdp_refaccionaria/models/part.dart';
import 'package:hmdp_refaccionaria/ui/theme.dart';

void main() {
  group('Part', () {
    test('parsea la respuesta del API con precio numérico o texto', () {
      final part = Part.fromApi({
        'id': 'a1',
        'sku': 'BAL-001',
        'name': 'Balata delantera',
        'brand': '  ',
        'category': 'Frenos',
        'stock': 3,
        'unit_price': '459.90',
        'is_active': true,
      });

      expect(part.unitPrice, 459.90);
      expect(part.brand, isNull);
      expect(part.inStock, isTrue);
    });

    test('sobrevive al viaje a SQLite', () {
      final original = Part.fromApi({
        'id': 'a2',
        'sku': 'FIL-010',
        'name': 'Filtro de aceite',
        'stock': 0,
        'unit_price': 120,
        'is_active': false,
      });

      final restored = Part.fromDb(original.toDb());

      expect(restored.sku, 'FIL-010');
      expect(restored.isActive, isFalse);
      expect(restored.inStock, isFalse);
    });
  });

  test('formatPrice agrega separador de miles', () {
    expect(formatPrice(1234567.5), r'$1,234,567.50');
    expect(formatPrice(99), r'$99.00');
  });
}
