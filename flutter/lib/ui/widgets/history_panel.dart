import 'package:flutter/material.dart';
import 'package:calc_pro/models/history_entry.dart';

class HistoryPanel extends StatelessWidget {
  final List<HistoryEntry> entries;
  final void Function(HistoryEntry) onTap;
  final VoidCallback onClear;
  final VoidCallback onClose;

  const HistoryPanel({
    super.key,
    required this.entries,
    required this.onTap,
    required this.onClear,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            (isDark ? const Color(0xFF0F0F1A) : const Color(0xFFF0F0F5)).withOpacity(0.98),
            (isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF8F9FF)).withOpacity(0.98),
          ],
        ),
      ),
      child: Column(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 48, 16, 8),
              child: Row(
                children: [
                  Text(
                    'History',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: colors.onSurface,
                    ),
                  ),
                  const Spacer(),
                  if (entries.isNotEmpty)
                    TextButton(
                      onPressed: onClear,
                      child: Text(
                        'Clear All',
                        style: TextStyle(color: colors.error, fontWeight: FontWeight.w500),
                      ),
                    ),
                  IconButton(
                    icon: Icon(Icons.close, color: colors.onSurface),
                    onPressed: onClose,
                  ),
                ],
              ),
            ),
          ),
          Divider(color: colors.onSurface.withOpacity(0.1), height: 1),
          Expanded(
            child: entries.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calculate_outlined,
                          size: 48,
                          color: colors.onSurface.withOpacity(0.2),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No calculations yet',
                          style: TextStyle(
                            color: colors.onSurface.withOpacity(0.4),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: entries.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      return GlassHistoryCard(
                        entry: entry,
                        onTap: () => onTap(entry),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class GlassHistoryCard extends StatelessWidget {
  final HistoryEntry entry;
  final VoidCallback onTap;

  const GlassHistoryCard({super.key, required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Material(
        color: (isDark ? Colors.white : Colors.black).withOpacity(0.04),
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: (isDark ? Colors.white : Colors.black).withOpacity(0.06),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.expression,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  entry.result,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w300,
                    color: Theme.of(context).colorScheme.onSurface,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
