import 'package:flutter/material.dart';

import '../../models/part.dart';
import '../theme.dart';
import '../widgets/stock_badge.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key, required this.part});

  final Part part;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7);
    return Scaffold(
      appBar: AppBar(title: Text(part.sku)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (part.category != null)
            Text(part.category!.toUpperCase(),
                style: const TextStyle(
                    color: AzColors.orange, fontWeight: FontWeight.w800, letterSpacing: 1)),
          const SizedBox(height: 6),
          Text(part.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          if (part.brand != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('Marca: ${part.brand}', style: TextStyle(color: muted)),
            ),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(formatPrice(part.unitPrice),
                  style: const TextStyle(
                      fontSize: 30, fontWeight: FontWeight.w900, color: AzColors.red)),
              const SizedBox(width: 6),
              Text('MXN', style: TextStyle(color: muted)),
              const Spacer(),
              StockBadge(stock: part.stock),
            ],
          ),
          const Divider(height: 40),
          _Row(label: 'SKU', value: part.sku),
          _Row(label: 'Existencias', value: '${part.stock} pzas'),
          if (part.description != null) ...[
            const SizedBox(height: 16),
            const Text('Descripción', style: TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(part.description!),
          ],
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
              width: 110,
              child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
