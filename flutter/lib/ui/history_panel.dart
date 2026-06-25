import 'package:flutter/material.dart';
import '../logic/history.dart';

class HistoryPanel extends StatelessWidget {
  final CalculatorHistory history;
  final ValueChanged<HistoryEntry> onTapEntry;
  final VoidCallback onClear;
  final VoidCallback onClose;

  const HistoryPanel({
    super.key,
    required this.history,
    required this.onTapEntry,
    required this.onClear,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: isDark
          ? const Color(0xFF1A1A2E).withOpacity( 0.95)
          : const Color(0xFFF5F5FF).withOpacity( 0.95),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 8),
            child: Row(
              children: [
                Text(
                  'History',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: onClear,
                  child: Text(
                    'Clear',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: history.entries.isEmpty
                ? Center(
                    child: Text(
                      'No calculations yet',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface
                            .withOpacity( 0.5),
                        fontSize: 15,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: history.entries.length,
                    itemBuilder: (context, index) {
                      final entry = history.entries[index];
                      return Card(
                        color: isDark
                            ? const Color(0xFF1A1A3E)
                            : const Color(0xFFF5F5F5),
                        margin: const EdgeInsets.symmetric(vertical: 3),
                        child: InkWell(
                          onTap: () => onTapEntry(entry),
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.expression,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: theme.colorScheme.onSurface
                                        .withOpacity( 0.6),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  entry.result,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onClose,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Close', style: TextStyle(fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
