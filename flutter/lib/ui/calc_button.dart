import 'package:flutter/material.dart';

class CalcButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? color;
  final Color? textColor;
  final double fontSize;
  final double? width;

  const CalcButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color,
    this.textColor,
    this.fontSize = 20,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = color ?? const Color(0xFF1A1A3E);
    final fgColor = textColor ?? Colors.white;
    final isWide = width != null;

    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Material(
            color: bgColor,
            child: InkWell(
              onTap: onPressed,
              splashColor: fgColor.withValues(alpha: 0.15),
              highlightColor: fgColor.withValues(alpha: 0.08),
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Text(
                  text,
                  style: TextStyle(
                    color: fgColor,
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
