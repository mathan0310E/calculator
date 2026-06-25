import 'package:flutter/material.dart';

class AppTheme {
  static const _darkSeed = Color(0xFF1A1A2E);
  static const _lightSeed = Color(0xFFF0F0F5);

  static ThemeData dark() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0F0F1A),
      colorScheme: const ColorScheme.dark(
        surface: Color(0xFF16213E),
        primary: Color(0xFFE94560),
        secondary: Color(0xFF533483),
        onSurface: Colors.white,
        onPrimary: Colors.white,
      ),
    );
  }

  static ThemeData light() {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF0F0F5),
      colorScheme: const ColorScheme.light(
        surface: Colors.white,
        primary: Color(0xFFE94560),
        secondary: Color(0xFF7C4DFF),
        onSurface: Color(0xFF1A1A2E),
        onPrimary: Colors.white,
      ),
    );
  }

  static const Map<String, Color> darkColors = {
    'bg': Color(0xFF0F0F1A),
    'surface': Color(0xFF16213E),
    'display': Color(0xFF0F3460),
    'primary': Color(0xFFE94560),
    'secondary': Color(0xFF533483),
    'btnNum': Color(0xFF1A1A3E),
    'btnOp': Color(0xFF2A2A5E),
    'btnEq': Color(0xFFE94560),
    'btnClear': Color(0xFF533483),
    'text': Color(0xFFFFFFFF),
    'textSecondary': Color(0xFFA0A0B8),
    'memIndicator': Color(0xFFE94560),
    'tabBg': Color(0xFF2A2A5E),
    'historyBg': Color(0xFF1A1A2E),
    'scrollbar': Color(0xFF2A2A5E),
  };

  static const Map<String, Color> lightColors = {
    'bg': Color(0xFFF0F0F5),
    'surface': Color(0xFFFFFFFF),
    'display': Color(0xFFF5F5FF),
    'primary': Color(0xFFE94560),
    'secondary': Color(0xFF7C4DFF),
    'btnNum': Color(0xFFF5F5F5),
    'btnOp': Color(0xFFE8E8F5),
    'btnEq': Color(0xFFE94560),
    'btnClear': Color(0xFF7C4DFF),
    'text': Color(0xFF1A1A2E),
    'textSecondary': Color(0xFF666666),
    'memIndicator': Color(0xFFE94560),
    'tabBg': Color(0xFFE8E8F5),
    'historyBg': Color(0xFFF5F5FF),
    'scrollbar': Color(0xFFCCCCCC),
  };
}
