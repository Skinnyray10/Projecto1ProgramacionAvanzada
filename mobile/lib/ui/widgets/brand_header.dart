import 'package:flutter/material.dart';

import '../theme.dart';

class BrandHeader extends StatelessWidget {
  const BrandHeader({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AzColors.black,
      padding: EdgeInsets.fromLTRB(
          24, MediaQuery.paddingOf(context).top + 28, 24, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: const TextSpan(
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: 1),
              children: [
                TextSpan(text: 'HMDP ', style: TextStyle(color: Colors.white)),
                TextSpan(text: 'ZONE', style: TextStyle(color: AzColors.orange)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(title.toUpperCase(),
              style: const TextStyle(
                  color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
          Container(
              margin: const EdgeInsets.only(top: 6, bottom: 8),
              width: 48,
              height: 4,
              color: AzColors.orange),
          Text(subtitle, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}
