import 'package:flutter/material.dart';

class AzColors {
  static const red = Color(0xFFD52B1E);
  static const orange = Color(0xFFFF6A00);
  static const black = Color(0xFF111111);
  static const gray = Color(0xFFF2F2F2);
  static const green = Color(0xFF2E7D32);
}

ThemeData buildTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final scheme = ColorScheme.fromSeed(
    seedColor: AzColors.red,
    brightness: brightness,
    primary: AzColors.red,
    secondary: AzColors.orange,
    surface: dark ? const Color(0xFF18181B) : Colors.white,
  );
  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(4),
    borderSide: BorderSide(color: dark ? Colors.white24 : Colors.black26),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: dark ? const Color(0xFF09090B) : AzColors.gray,
    appBarTheme: const AppBarTheme(
      backgroundColor: AzColors.black,
      foregroundColor: Colors.white,
      centerTitle: false,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: dark ? const Color(0xFF18181B) : Colors.white,
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(
          borderSide: const BorderSide(color: AzColors.orange, width: 2)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AzColors.red,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        textStyle: const TextStyle(
            fontWeight: FontWeight.w800, letterSpacing: 1.2, fontSize: 15),
      ),
    ),
    chipTheme: ChipThemeData(
      selectedColor: AzColors.orange,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
  );
}

String formatPrice(double value) {
  final fixed = value.toStringAsFixed(2);
  final parts = fixed.split('.');
  final digits = parts[0];
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return '\$$buffer.${parts[1]}';
}

String formatRelative(DateTime time) {
  final diff = DateTime.now().difference(time);
  if (diff.inMinutes < 1) return 'hace un momento';
  if (diff.inMinutes < 60) return 'hace ${diff.inMinutes} min';
  if (diff.inHours < 24) return 'hace ${diff.inHours} h';
  return 'hace ${diff.inDays} d';
}
