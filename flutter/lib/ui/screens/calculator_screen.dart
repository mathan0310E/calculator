import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calc_pro/core/constants/constants.dart';
import 'package:calc_pro/core/utils/clipboard.dart';
import 'package:calc_pro/core/utils/haptic.dart';
import 'package:calc_pro/models/calculator_state.dart';
import 'package:calc_pro/models/history_entry.dart';
import 'package:calc_pro/providers/calculator_provider.dart';
import 'package:calc_pro/providers/history_provider.dart';
import 'package:calc_pro/providers/theme_provider.dart';
import 'package:calc_pro/ui/widgets/calc_display.dart';
import 'package:calc_pro/ui/widgets/basic_grid.dart';
import 'package:calc_pro/ui/widgets/scientific_grid.dart';
import 'package:calc_pro/ui/widgets/mode_toggle.dart';
import 'package:calc_pro/ui/widgets/history_panel.dart';
import 'package:calc_pro/ui/widgets/memory_menu.dart';

class CalculatorScreen extends ConsumerStatefulWidget {
  const CalculatorScreen({super.key});

  @override
  ConsumerState<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends ConsumerState<CalculatorScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _onButtonPressed(String action) {
    HapticUtil.light();
    ref.read(calculatorProvider.notifier).inputFunction(action);
  }

  void _showMemoryMenu() {
    final state = ref.read(calculatorProvider);
    final notifier = ref.read(calculatorProvider.notifier);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => MemoryMenu(
        currentValue: state.currentInput,
        hasMemory: state.hasMemory,
        onMC: () { notifier.memoryClear(); Navigator.pop(context); },
        onMR: () { notifier.memoryRecall(); Navigator.pop(context); },
        onMPlus: () { notifier.memoryAdd(); Navigator.pop(context); },
        onMMinus: () { notifier.memorySubtract(); Navigator.pop(context); },
        onMS: () { notifier.memoryStore(); Navigator.pop(context); },
      ),
    );
  }

  Future<void> _copyResult() async {
    final result = ref.read(calculatorProvider).result;
    if (result.isNotEmpty) {
      await ClipboardUtil.copy(result);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Result copied'),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(bottom: 100, left: 40, right: 40),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final calcState = ref.watch(calculatorProvider);
    final history = ref.watch(historyProvider);

    return OrientationBuilder(
      builder: (context, orientation) {
        return Scaffold(
          body: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    _buildHeader(calcState),
                    Expanded(
                      flex: orientation == Orientation.portrait ? 28 : 40,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return CalcDisplay(
                            expression: calcState.expression,
                            result: calcState.currentInput,
                            error: calcState.error,
                            hasMemory: calcState.hasMemory,
                          );
                        },
                      ),
                    ),
                    ModeToggle(
                      currentMode: calcState.mode,
                      onChanged: (mode) {
                        ref.read(calculatorProvider.notifier).setMode(mode);
                      },
                      isRadian: calcState.angleMode == AngleMode.rad,
                      onAngleToggle: () {
                        ref.read(calculatorProvider.notifier).toggleAngleMode();
                      },
                    ),
                    Expanded(
                      flex: orientation == Orientation.portrait ? 62 : 50,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: calcState.mode == CalculatorMode.basic
                            ? BasicGrid(key: const ValueKey('basic'), onButtonPressed: _onButtonPressed)
                            : ScientificGrid(key: const ValueKey('sci'), onButtonPressed: _onButtonPressed),
                      ),
                    ),
                  ],
                ),
                if (calcState.showHistory)
                  HistoryPanel(
                    entries: history,
                    onTap: (entry) {
                      ref.read(calculatorProvider.notifier).restoreFromHistory(entry);
                    },
                    onClear: () {
                      ref.read(historyProvider.notifier).clear();
                    },
                    onClose: () {
                      ref.read(calculatorProvider.notifier).toggleHistory();
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(CalculatorState calcState) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Text(
            AppConstants.appName,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colors.onSurface,
              letterSpacing: 1,
            ),
          ),
          const Spacer(),
          _iconBtn(Icons.memory, 'Memory', _showMemoryMenu),
          const SizedBox(width: 4),
          _iconBtn(Icons.copy, 'Copy', _copyResult),
          const SizedBox(width: 4),
          _iconBtn(
            isDark ? Icons.light_mode : Icons.dark_mode,
            'Theme',
            () {
              ref.read(themeModeProvider.notifier).state =
                  isDark ? ThemeMode.light : ThemeMode.dark;
            },
          ),
          const SizedBox(width: 4),
          _iconBtn(Icons.history, 'History', () {
            ref.read(calculatorProvider.notifier).toggleHistory();
          }),
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon, String tooltip, VoidCallback onTap) {
    final colors = Theme.of(context).colorScheme;
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colors.onSurface.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: colors.onSurface.withOpacity(0.7)),
        ),
      ),
    );
  }
}
