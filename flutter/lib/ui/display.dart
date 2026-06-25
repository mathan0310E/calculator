import 'package:flutter/material.dart';

class CalcDisplay extends StatelessWidget {
  final String expression;
  final String result;
  final bool hasMemory;

  const CalcDisplay({
    super.key,
    required this.expression,
    required this.result,
    this.hasMemory = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final displayBg = isDark ? const Color(0xFF0F3460) : const Color(0xFFF5F5FF);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: displayBg,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (hasMemory)
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                'M',
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          Text(
            expression,
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
              fontSize: 15,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            result,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: result.length > 14 ? 32 : 42,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
