import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:calc_pro/core/utils/haptic.dart';

enum ButtonType { number, operation, function, clear, equals, memory }

class CalcButton extends StatefulWidget {
  final String label;
  final String action;
  final ButtonType type;
  final VoidCallback onPressed;
  final double flex;

  const CalcButton({
    super.key,
    required this.label,
    required this.action,
    required this.onPressed,
    this.type = ButtonType.number,
    this.flex = 1,
  });

  @override
  State<CalcButton> createState() => _CalcButtonState();
}

class _CalcButtonState extends State<CalcButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticUtil.light();
    _controller.forward().then((_) => _controller.reverse());
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = Theme.of(context).colorScheme;

    Color bgColor;
    Color textColor;
    double fontSize;

    switch (widget.type) {
      case ButtonType.number:
        bgColor = isDark ? const Color(0xFF2A2A4A) : const Color(0xFFF0F0F5);
        textColor = isDark ? Colors.white : const Color(0xFF1A1A2E);
        fontSize = 22;
      case ButtonType.operation:
        bgColor = isDark ? const Color(0xFF3A3A5C) : const Color(0xFFE8E8F5);
        textColor = colors.secondary;
        fontSize = 22;
      case ButtonType.function:
        bgColor = isDark ? const Color(0xFF1E1E3A) : const Color(0xFFF5F5FF);
        textColor = isDark ? Colors.white70 : const Color(0xFF666666);
        fontSize = 14;
      case ButtonType.clear:
        bgColor = isDark ? const Color(0xFF4A2A3A) : const Color(0xFFFFE8E8);
        textColor = colors.error;
        fontSize = 18;
      case ButtonType.equals:
        bgColor = colors.primary;
        textColor = colors.onPrimary;
        fontSize = 26;
      case ButtonType.memory:
        bgColor = isDark ? const Color(0xFF2A2A4A) : const Color(0xFFF0F0F5);
        textColor = colors.secondary;
        fontSize = 14;
    }

    return AnimatedBuilder(
      animation: _scaleAnim,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnim.value,
          child: child,
        );
      },
      child: Padding(
        padding: EdgeInsets.all(widget.type == ButtonType.equals ? 3 : 2.5),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Material(
            color: bgColor,
            surfaceTintColor: Colors.transparent,
            child: InkWell(
              onTap: _handleTap,
              splashColor: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
              highlightColor: Colors.transparent,
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Text(
                  widget.label,
                  style: TextStyle(
                    color: textColor,
                    fontSize: fontSize,
                    fontWeight: widget.type == ButtonType.equals
                        ? FontWeight.w700
                        : FontWeight.w500,
                    letterSpacing: 0.5,
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
