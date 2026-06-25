import 'package:flutter/material.dart';
import 'package:calc_pro/core/constants/constants.dart';

class CalcDisplay extends StatelessWidget {
  final String expression;
  final String result;
  final String error;
  final bool hasMemory;

  const CalcDisplay({
    super.key,
    required this.expression,
    required this.result,
    this.error = '',
    this.hasMemory = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;

        return Container(
          margin: EdgeInsets.symmetric(
            horizontal: AppConstants.buttonSpacing,
            vertical: AppConstants.buttonSpacing,
          ),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF16213E).withOpacity(0.6)
                : Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: (isDark ? Colors.white : Colors.black).withOpacity(0.06),
            ),
          ),
          padding: EdgeInsets.fromLTRB(
            availableWidth * 0.04,
            availableWidth * 0.03,
            availableWidth * 0.04,
            availableWidth * 0.03,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (hasMemory)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Icon(Icons.memory, size: 12, color: colors.secondary),
                      const SizedBox(width: 4),
                      Text(
                        'MEM',
                        style: TextStyle(
                          color: colors.secondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: SingleChildScrollView(
                  key: ValueKey('expr_$expression'),
                  scrollDirection: Axis.horizontal,
                  reverse: true,
                  child: Text(
                    expression,
                    style: TextStyle(
                      color: colors.onSurface.withOpacity(0.5),
                      fontSize: availableWidth * 0.04,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'monospace',
                    ),
                    maxLines: 1,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                switchInCurve: Curves.easeInOut,
                switchOutCurve: Curves.easeInOut,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.15),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: Text(
                  error.isNotEmpty ? error : result,
                  key: ValueKey('${error.isNotEmpty ? 'err' : 'res'}_$result'),
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: error.isNotEmpty
                        ? colors.error
                        : colors.onSurface,
                    fontSize: error.isNotEmpty
                        ? availableWidth * 0.06
                        : result.length > 12
                            ? availableWidth * 0.08
                            : availableWidth * 0.1,
                    fontWeight: FontWeight.w300,
                    fontFamily: 'monospace',
                    letterSpacing: 1,
                  ),
                  maxLines: 1,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
