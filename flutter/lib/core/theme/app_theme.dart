import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  static const _primary = Color(0xFF6C63FF);
  static const _secondary = Color(0xFF00D9FF);
  static const _error = Color(0xFFFF4757);
  static const _surfaceDark = Color(0xFF1A1A2E);
  static const _bgDark = Color(0xFF0F0F1A);
  static const _surfaceLight = Color(0xFFF8F9FF);
  static const _bgLight = Color(0xFFF0F0F5);

  static ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: _primary,
      secondary: _secondary,
      surface: _surfaceDark,
      error: _error,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Colors.white,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: _bgDark,
    textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
  );

  static ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: _primary,
      secondary: _secondary,
      surface: _surfaceLight,
      error: _error,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: const Color(0xFF1A1A2E),
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: _bgLight,
    textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
  );
}

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadiusGeometry? borderRadius;
  final Color? color;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = color ?? (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03));

    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        border: Border.all(
          color: (isDark ? Colors.white : Colors.black).withOpacity(0.08),
          width: 0.5,
        ),
      ),
      child: child,
    );
  }
}
