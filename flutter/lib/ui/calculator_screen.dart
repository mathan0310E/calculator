import 'package:flutter/material.dart';
import '../logic/calculator.dart';
import '../logic/history.dart';
import 'calc_button.dart';
import 'display.dart';
import 'history_panel.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final _calc = CalculatorState();
  final _history = CalculatorHistory();
  bool _showHistory = false;
  bool _showSci = false;
  bool _isDark = true;

  @override
  void initState() {
    super.initState();
    _history.load();
  }

  void _onBtnPress(String action, [String? value]) {
    setState(() {
      if (value != null) {
        _handleAction(value);
      } else {
        _handleAction(action);
      }
    });
  }

  void _handleAction(String action) {
    switch (action) {
      case '0':
      case '1':
      case '2':
      case '3':
      case '4':
      case '5':
      case '6':
      case '7':
      case '8':
      case '9':
        _calc.inputDigit(action);
      case 'decimal':
        _calc.inputDecimal();
      case 'add':
        _calc.inputOperator('+');
      case 'subtract':
        _calc.inputOperator('-');
      case 'multiply':
        _calc.inputOperator('*');
      case 'divide':
        _calc.inputOperator('/');
      case 'percent':
        _calc.inputOperator('%');
      case 'power':
        _calc.inputOperator('^');
      case 'equals':
        final entry = _calc.calculate();
        if (entry != null) {
          _history.add(entry);
        }
      case 'clear':
        _calc.clearAll();
      case 'backspace':
        _calc.backspace();
      case 'negate':
        _calc.inputFunction('negate');
      case 'lparen':
        _calc.inputLparen();
      case 'rparen':
        _calc.inputRparen();
      case 'sin':
      case 'cos':
      case 'tan':
      case 'asin':
      case 'acos':
      case 'atan':
      case 'log':
      case 'ln':
      case 'sqrt':
      case 'cbrt':
      case 'square':
      case 'cube':
      case 'reciprocal':
      case 'factorial':
      case 'pi':
      case 'econst':
      case 'exp':
      case 'tenx':
      case 'abs':
        _calc.inputFunction(action);
    }
  }

  void _toggleTheme() {
    setState(() => _isDark = !_isDark);
  }

  void _toggleAngle() {
    setState(() {
      _calc.angleMode =
          _calc.angleMode == AngleMode.deg ? AngleMode.rad : AngleMode.deg;
    });
  }

  void _showMemoryMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _MemoryMenu(calc: _calc, onChanged: () => setState(() {})),
    );
  }

  void _showToast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 20, left: 40, right: 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _isDark;
    final theme = isDark ? _darkTheme() : _lightTheme();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  _buildHeader(),
                  _buildMemoryIndicator(),
                  CalcDisplay(
                    expression: _calc.expression,
                    result: _calc.formattedCurrent,
                    hasMemory: false,
                  ),
                  _buildTabs(),
                  Expanded(child: _buildButtons()),
                ],
              ),
              if (_showHistory)
                HistoryPanel(
                  history: _history,
                  onTapEntry: (entry) {
                    setState(() {
                      _calc.current = entry.result.replaceAll(',', '');
                      _calc.expression =
                          entry.expression.replaceAll(' =', '');
                      _calc.isNewEntry = true;
                      _calc.justEvaluated = false;
                      _showHistory = false;
                    });
                  },
                  onClear: () {
                    _history.clear();
                    setState(() {});
                  },
                  onClose: () => setState(() => _showHistory = false),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            'Calc Pro',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const Spacer(),
          _headerBtn(
            _calc.angleMode == AngleMode.deg ? 'DEG' : 'RAD',
            () => _toggleAngle(),
          ),
          const SizedBox(width: 4),
          _headerBtn('M', () => _showMemoryMenu()),
          const SizedBox(width: 4),
          _headerBtn(_isDark ? '☀️' : '🌙', () => _toggleTheme()),
          const SizedBox(width: 4),
          _headerBtn('📋', () => setState(() => _showHistory = !_showHistory)),
        ],
      ),
    );
  }

  Widget _headerBtn(String text, VoidCallback onTap) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildMemoryIndicator() {
    return const SizedBox(height: 0);
  }

  Widget _buildTabs() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: (_isDark
                  ? const Color(0xFF2A2A5E)
                  : const Color(0xFFE8E8F5))
              .withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _showSci = false),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: !_showSci
                        ? (_isDark
                            ? const Color(0xFF2A2A5E)
                            : const Color(0xFFE8E8F5))
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Basic',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: !_showSci
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _showSci = true),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: _showSci
                        ? (_isDark
                            ? const Color(0xFF2A2A5E)
                            : const Color(0xFFE8E8F5))
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Scientific',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: _showSci
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtons() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
      child: _showSci ? _buildSciGrid() : _buildBasicGrid(),
    );
  }

  Widget _buildBasicGrid() {
    final isDark = _isDark;
    final numColor = isDark ? const Color(0xFF1A1A3E) : const Color(0xFFF5F5F5);
    final opColor = isDark ? const Color(0xFF2A2A5E) : const Color(0xFFE8E8F5);
    final eqColor = isDark ? const Color(0xFFE94560) : const Color(0xFFE94560);
    final clearColor =
        isDark ? const Color(0xFF533483) : const Color(0xFF7C4DFF);
    final numText =
        isDark ? Colors.white : const Color(0xFF1A1A2E);
    final opText = isDark ? const Color(0xFFE94560) : const Color(0xFFE94560);
    final eqText = Colors.white;
    final clearText = Colors.white;

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = (constraints.maxWidth - 36) / 4;
        return Column(
          children: [
            Row(children: [
              CalcButton(text: 'AC', onPressed: () => _onBtnPress('clear'), color: clearColor, textColor: clearText, fontSize: 16),
              CalcButton(text: '⌫', onPressed: () => _onBtnPress('backspace'), color: clearColor, textColor: clearText, fontSize: 18),
              CalcButton(text: '%', onPressed: () => _onBtnPress('percent'), color: opColor, textColor: opText),
              CalcButton(text: '÷', onPressed: () => _onBtnPress('divide'), color: opColor, textColor: opText),
            ]),
            Row(children: [
              CalcButton(text: '7', onPressed: () => _onBtnPress('7'), color: numColor, textColor: numText),
              CalcButton(text: '8', onPressed: () => _onBtnPress('8'), color: numColor, textColor: numText),
              CalcButton(text: '9', onPressed: () => _onBtnPress('9'), color: numColor, textColor: numText),
              CalcButton(text: '×', onPressed: () => _onBtnPress('multiply'), color: opColor, textColor: opText),
            ]),
            Row(children: [
              CalcButton(text: '4', onPressed: () => _onBtnPress('4'), color: numColor, textColor: numText),
              CalcButton(text: '5', onPressed: () => _onBtnPress('5'), color: numColor, textColor: numText),
              CalcButton(text: '6', onPressed: () => _onBtnPress('6'), color: numColor, textColor: numText),
              CalcButton(text: '−', onPressed: () => _onBtnPress('subtract'), color: opColor, textColor: opText),
            ]),
            Row(children: [
              CalcButton(text: '1', onPressed: () => _onBtnPress('1'), color: numColor, textColor: numText),
              CalcButton(text: '2', onPressed: () => _onBtnPress('2'), color: numColor, textColor: numText),
              CalcButton(text: '3', onPressed: () => _onBtnPress('3'), color: numColor, textColor: numText),
              CalcButton(text: '+', onPressed: () => _onBtnPress('add'), color: opColor, textColor: opText),
            ]),
            Row(children: [
              CalcButton(text: '0', onPressed: () => _onBtnPress('0'), color: numColor, textColor: numText, width: w * 2 + 6),
              CalcButton(text: '.', onPressed: () => _onBtnPress('decimal'), color: numColor, textColor: numText),
              CalcButton(text: '=', onPressed: () => _onBtnPress('equals'), color: eqColor, textColor: eqText, fontSize: 24),
            ]),
          ],
        );
      },
    );
  }

  Widget _buildSciGrid() {
    final isDark = _isDark;
    final numColor = isDark ? const Color(0xFF1A1A3E) : const Color(0xFFF5F5F5);
    final opColor = isDark ? const Color(0xFF2A2A5E) : const Color(0xFFE8E8F5);
    final eqColor = isDark ? const Color(0xFFE94560) : const Color(0xFFE94560);
    final clearColor =
        isDark ? const Color(0xFF533483) : const Color(0xFF7C4DFF);
    final funcColor =
        isDark ? const Color(0xFF2A2A5E) : const Color(0xFFE8E8F5);
    final numText = isDark ? Colors.white : const Color(0xFF1A1A2E);
    final opText = isDark ? const Color(0xFFE94560) : const Color(0xFFE94560);
    final eqText = Colors.white;
    final clearText = Colors.white;
    final funcText =
        isDark ? const Color(0xFFA0A0B8) : const Color(0xFF666666);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: Column(
            children: [
              Row(children: [
                CalcButton(text: 'sin', onPressed: () => _onBtnPress('sin'), color: funcColor, textColor: funcText, fontSize: 13),
                CalcButton(text: 'cos', onPressed: () => _onBtnPress('cos'), color: funcColor, textColor: funcText, fontSize: 13),
                CalcButton(text: 'tan', onPressed: () => _onBtnPress('tan'), color: funcColor, textColor: funcText, fontSize: 13),
                CalcButton(text: 'log', onPressed: () => _onBtnPress('log'), color: funcColor, textColor: funcText, fontSize: 13),
                CalcButton(text: 'ln', onPressed: () => _onBtnPress('ln'), color: funcColor, textColor: funcText, fontSize: 13),
              ]),
              Row(children: [
                CalcButton(text: 'sin⁻¹', onPressed: () => _onBtnPress('asin'), color: funcColor, textColor: funcText, fontSize: 11),
                CalcButton(text: 'cos⁻¹', onPressed: () => _onBtnPress('acos'), color: funcColor, textColor: funcText, fontSize: 11),
                CalcButton(text: 'tan⁻¹', onPressed: () => _onBtnPress('atan'), color: funcColor, textColor: funcText, fontSize: 11),
                CalcButton(text: '√', onPressed: () => _onBtnPress('sqrt'), color: funcColor, textColor: funcText, fontSize: 14),
                CalcButton(text: '∛', onPressed: () => _onBtnPress('cbrt'), color: funcColor, textColor: funcText, fontSize: 14),
              ]),
              Row(children: [
                CalcButton(text: 'x²', onPressed: () => _onBtnPress('square'), color: funcColor, textColor: funcText, fontSize: 13),
                CalcButton(text: 'x³', onPressed: () => _onBtnPress('cube'), color: funcColor, textColor: funcText, fontSize: 13),
                CalcButton(text: 'xʸ', onPressed: () => _onBtnPress('power'), color: funcColor, textColor: opText, fontSize: 13),
                CalcButton(text: 'x!', onPressed: () => _onBtnPress('factorial'), color: funcColor, textColor: funcText, fontSize: 13),
                CalcButton(text: '1/x', onPressed: () => _onBtnPress('reciprocal'), color: funcColor, textColor: funcText, fontSize: 11),
              ]),
              Row(children: [
                CalcButton(text: 'π', onPressed: () => _onBtnPress('pi'), color: funcColor, textColor: funcText, fontSize: 14),
                CalcButton(text: 'e', onPressed: () => _onBtnPress('econst'), color: funcColor, textColor: funcText, fontSize: 14),
                CalcButton(text: 'eˣ', onPressed: () => _onBtnPress('exp'), color: funcColor, textColor: funcText, fontSize: 13),
                CalcButton(text: '10ˣ', onPressed: () => _onBtnPress('tenx'), color: funcColor, textColor: funcText, fontSize: 12),
                CalcButton(text: '|x|', onPressed: () => _onBtnPress('abs'), color: funcColor, textColor: funcText, fontSize: 13),
              ]),
              const SizedBox(height: 4),
              Row(children: [
                CalcButton(text: 'AC', onPressed: () => _onBtnPress('clear'), color: clearColor, textColor: clearText, fontSize: 14),
                CalcButton(text: '⌫', onPressed: () => _onBtnPress('backspace'), color: clearColor, textColor: clearText, fontSize: 16),
                CalcButton(text: '%', onPressed: () => _onBtnPress('percent'), color: opColor, textColor: opText, fontSize: 16),
                CalcButton(text: '÷', onPressed: () => _onBtnPress('divide'), color: opColor, textColor: opText, fontSize: 16),
                CalcButton(text: '×', onPressed: () => _onBtnPress('multiply'), color: opColor, textColor: opText, fontSize: 16),
              ]),
              Row(children: [
                CalcButton(text: '7', onPressed: () => _onBtnPress('7'), color: numColor, textColor: numText),
                CalcButton(text: '8', onPressed: () => _onBtnPress('8'), color: numColor, textColor: numText),
                CalcButton(text: '9', onPressed: () => _onBtnPress('9'), color: numColor, textColor: numText),
                CalcButton(text: '−', onPressed: () => _onBtnPress('subtract'), color: opColor, textColor: opText),
                CalcButton(text: '+', onPressed: () => _onBtnPress('add'), color: opColor, textColor: opText),
              ]),
              Row(children: [
                CalcButton(text: '4', onPressed: () => _onBtnPress('4'), color: numColor, textColor: numText),
                CalcButton(text: '5', onPressed: () => _onBtnPress('5'), color: numColor, textColor: numText),
                CalcButton(text: '6', onPressed: () => _onBtnPress('6'), color: numColor, textColor: numText),
                CalcButton(text: '(', onPressed: () => _onBtnPress('lparen'), color: funcColor, textColor: funcText),
                CalcButton(text: ')', onPressed: () => _onBtnPress('rparen'), color: funcColor, textColor: funcText),
              ]),
              Row(children: [
                CalcButton(text: '1', onPressed: () => _onBtnPress('1'), color: numColor, textColor: numText),
                CalcButton(text: '2', onPressed: () => _onBtnPress('2'), color: numColor, textColor: numText),
                CalcButton(text: '3', onPressed: () => _onBtnPress('3'), color: numColor, textColor: numText),
                CalcButton(text: '0', onPressed: () => _onBtnPress('0'), color: numColor, textColor: numText),
                CalcButton(text: '.', onPressed: () => _onBtnPress('decimal'), color: numColor, textColor: numText),
              ]),
              Row(children: [
                CalcButton(text: '±', onPressed: () => _onBtnPress('negate'), color: funcColor, textColor: funcText),
                const Spacer(),
                CalcButton(text: '=', onPressed: () => _onBtnPress('equals'), color: eqColor, textColor: eqText, fontSize: 22, width: 80),
              ]),
            ],
          ),
        );
      },
    );
  }

  ThemeData _darkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0F0F1A),
      colorScheme: const ColorScheme.dark(
        surface: Color(0xFF16213E),
        primary: Color(0xFFE94560),
        secondary: Color(0xFF533483),
        onSurface: Colors.white,
        onPrimary: Colors.white,
      ),
    );
  }

  ThemeData _lightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF0F0F5),
      colorScheme: const ColorScheme.light(
        surface: Colors.white,
        primary: Color(0xFFE94560),
        secondary: Color(0xFF7C4DFF),
        onSurface: const Color(0xFF1A1A2E),
        onPrimary: Colors.white,
      ),
    );
  }
}

class _MemoryMenu extends StatelessWidget {
  final CalculatorState calc;
  final VoidCallback onChanged;

  const _MemoryMenu({required this.calc, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16213E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(
            'Memory',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '= ${calc.current}',
            style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          _memBtn(context, 'MC', () {
            calc.inputFunction('negate');
            onChanged();
            Navigator.pop(context);
          }),
          _memBtn(context, 'MR', () {
            onChanged();
            Navigator.pop(context);
          }),
          _memBtn(context, 'M+', () {
            onChanged();
            Navigator.pop(context);
          }),
          _memBtn(context, 'M−', () {
            onChanged();
            Navigator.pop(context);
          }),
          _memBtn(context, 'MS', () {
            onChanged();
            Navigator.pop(context);
          }),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _memBtn(BuildContext context, String label, VoidCallback onTap) {
    final theme = Theme.of(context);
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: _memColor(label, theme),
            foregroundColor: _memTextColor(label, theme),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Color _memColor(String label, ThemeData theme) {
    if (label == 'MC' || label == 'MR') {
      return theme.colorScheme.secondary;
    }
    return theme.colorScheme.primary;
  }

  Color _memTextColor(String label, ThemeData theme) {
    return theme.colorScheme.onPrimary;
  }
}
