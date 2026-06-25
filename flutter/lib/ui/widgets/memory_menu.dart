import 'package:flutter/material.dart';

class MemoryMenu extends StatelessWidget {
  final String currentValue;
  final bool hasMemory;
  final VoidCallback onMC;
  final VoidCallback onMR;
  final VoidCallback onMPlus;
  final VoidCallback onMMinus;
  final VoidCallback onMS;

  const MemoryMenu({
    super.key,
    required this.currentValue,
    required this.hasMemory,
    required this.onMC,
    required this.onMR,
    required this.onMPlus,
    required this.onMMinus,
    required this.onMS,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colors.onSurface.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Memory',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: colors.surface.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.onSurface.withOpacity(0.1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '= ',
                  style: TextStyle(
                    fontSize: 16,
                    color: colors.onSurface.withOpacity(0.5),
                  ),
                ),
                Text(
                  hasMemory ? currentValue : '(empty)',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: colors.onSurface,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _memButton(context, 'MC', onMC),
              const SizedBox(width: 8),
              _memButton(context, 'MR', onMR),
              const SizedBox(width: 8),
              _memButton(context, 'M+', onMPlus),
              const SizedBox(width: 8),
              _memButton(context, 'M−', onMMinus),
              const SizedBox(width: 8),
              _memButton(context, 'MS', onMS),
            ],
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(color: colors.onSurface.withOpacity(0.5)),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _memButton(BuildContext context, String label, VoidCallback onTap) {
    final colors = Theme.of(context).colorScheme;
    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Material(
          color: colors.primary.withOpacity(0.1),
          child: InkWell(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              alignment: Alignment.center,
              child: Text(
                label,
                style: TextStyle(
                  color: colors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
