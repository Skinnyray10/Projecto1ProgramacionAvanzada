import 'package:flutter/material.dart';

import '../theme.dart';

class StockBadge extends StatelessWidget {
  const StockBadge({super.key, required this.stock});

  final int stock;

  @override
  Widget build(BuildContext context) {
    final (color, text) = switch (stock) {
      0 => (AzColors.red, 'AGOTADO'),
      <= 5 => (AzColors.orange, 'ÚLTIMAS $stock'),
      _ => (AzColors.green, 'EN STOCK'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
      child: Text(text,
          style: const TextStyle(
              color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
    );
  }
}
