import 'package:flutter/material.dart';
import 'package:calc_pro/models/calculator_state.dart';
import 'package:calc_pro/core/utils/haptic.dart';

class ModeToggle extends StatelessWidget {
  final CalculatorMode currentMode;
  final ValueChanged<CalculatorMode> onChanged;
  final bool isRadian;
  final VoidCallback onAngleToggle;
  final VoidCallback? onHistoryTap;

  const ModeToggle({
    super.key,
    required this.currentMode,
    required this.onChanged,
    required this.isRadian,
    required this.onAngleToggle,
    this.onHistoryTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticUtil.selection();
                        onChanged(CalculatorMode.basic);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: currentMode == CalculatorMode.basic
                              ? colors.primary.withOpacity(0.2)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                          border: currentMode == CalculatorMode.basic
                              ? Border.all(color: colors.primary.withOpacity(0.3), width: 0.5)
                              : null,
                        ),
                        child: Text(
                          'Basic',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: currentMode == CalculatorMode.basic
                                ? colors.primary
                                : colors.onSurface.withOpacity(0.5),
                            fontWeight: currentMode == CalculatorMode.basic
                                ? FontWeight.w600
                                : FontWeight.w400,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticUtil.selection();
                        onChanged(CalculatorMode.scientific);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: currentMode == CalculatorMode.scientific
                              ? colors.primary.withOpacity(0.2)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                          border: currentMode == CalculatorMode.scientific
                              ? Border.all(color: colors.primary.withOpacity(0.3), width: 0.5)
                              : null,
                        ),
                        child: Text(
                          'Scientific',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: currentMode == CalculatorMode.scientific
                                ? colors.primary
                                : colors.onSurface.withOpacity(0.5),
                            fontWeight: currentMode == CalculatorMode.scientific
                                ? FontWeight.w600
                                : FontWeight.w400,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          _pillButton(
            context,
            isRadian ? 'RAD' : 'DEG',
            onAngleToggle,
          ),
          const SizedBox(width: 6),
          _iconButton(context, Icons.history, () => onHistoryTap?.call()),
        ],
      ),
    );
  }

  Widget _pillButton(BuildContext context, String label, VoidCallback onTap) {
    final colors = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: colors.secondary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colors.secondary.withOpacity(0.2)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: colors.secondary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _iconButton(BuildContext context, IconData icon, VoidCallback onTap) {
    final colors = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: colors.primary),
      ),
    );
  }
}
