import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calc_pro/engine/calculator_engine.dart';
import 'package:calc_pro/models/calculator_state.dart';
import 'package:calc_pro/models/history_entry.dart';
import 'package:calc_pro/repositories/history_repository.dart';
import 'package:calc_pro/providers/history_provider.dart';

class CalculatorNotifier extends StateNotifier<CalculatorState> {
  final CalculatorEngine _engine;
  final Ref _ref;

  CalculatorNotifier(this._ref)
      : _engine = CalculatorEngine(),
        super(const CalculatorState());

  void inputDigit(String digit) {
    if (state.justEvaluated) {
      state = state.copyWith(
        expression: '',
        currentInput: digit,
        justEvaluated: false,
        isNewEntry: false,
        result: '',
      );
      return;
    }
    if (state.isNewEntry) {
      state = state.copyWith(currentInput: digit, isNewEntry: false);
    } else {
      if (state.currentInput == '0') {
        state = state.copyWith(currentInput: digit);
      } else if (state.currentInput.length < 16) {
        state = state.copyWith(currentInput: state.currentInput + digit);
      }
    }
  }

  void inputDecimal() {
    if (state.justEvaluated) {
      state = state.copyWith(
        expression: '',
        currentInput: '0.',
        justEvaluated: false,
        isNewEntry: false,
        result: '',
      );
      return;
    }
    if (state.isNewEntry) {
      state = state.copyWith(currentInput: '0.', isNewEntry: false);
      return;
    }
    if (!state.currentInput.contains('.')) {
      state = state.copyWith(currentInput: state.currentInput + '.');
    }
  }

  void inputOperator(String op) {
    final displayOp = _displayOp(op);
    final exprOp = op;

    if (state.justEvaluated) {
      state = state.copyWith(
        justEvaluated: false,
        isNewEntry: false,
      );
    }

    String expr = state.expression;
    if (!state.isNewEntry && state.currentInput != '0') {
      if (expr.isNotEmpty && expr.endsWith(')')) {
        expr += ' $displayOp';
      } else {
        expr += state.currentInput;
      }
    } else {
      if (expr.isNotEmpty && '+-×÷^'.contains(expr[expr.length - 1])) {
        expr = expr.substring(0, expr.length - 1).trim();
      }
    }

    expr += ' $displayOp ';
    state = state.copyWith(
      expression: expr,
      currentInput: '0',
      isNewEntry: true,
      error: '',
    );
  }

  void inputFunction(String fn) {
    if (state.justEvaluated) {
      state = state.copyWith(
        expression: '',
        currentInput: fn == 'pi' ? '3.141592653589793' : '2.718281828459045',
        justEvaluated: false,
        isNewEntry: true,
        result: '',
      );
      return;
    }

    final cur = state.currentInput;

    switch (fn) {
      case 'pi':
        _addToExpression('π');
        state = state.copyWith(currentInput: '3.141592653589793', isNewEntry: true);
      case 'e':
        _addToExpression('e');
        state = state.copyWith(currentInput: '2.718281828459045', isNewEntry: true);
      case 'square':
        final v = double.tryParse(cur) ?? 0;
        _addToExpression('${cur}²');
        state = state.copyWith(currentInput: (v * v).toString(), isNewEntry: true);
      case 'cube':
        final v = double.tryParse(cur) ?? 0;
        _addToExpression('${cur}³');
        state = state.copyWith(currentInput: (v * v * v).toString(), isNewEntry: true);
      case 'sqrt':
      case 'cbrt':
      case 'sin':
      case 'cos':
      case 'tan':
      case 'asin':
      case 'acos':
      case 'atan':
      case 'log':
      case 'ln':
      case 'abs':
      case 'exp':
      case 'rand':
        _addToExpression('$fn($cur)');
        final sanitized = _engine.sanitizeExpression(state.expression);
        final result = _engine.evaluate(sanitized, angleMode: state.angleMode);
        if (result != null) {
          state = state.copyWith(currentInput: result.formatted, isNewEntry: true, result: result.formatted);
        }
      case 'factorial':
        _addToExpression('${cur}!');
        final v = double.tryParse(cur) ?? 0;
        if (v >= 0 && v == v.roundToDouble()) {
          int f = 1;
          for (int i = 2; i <= v.round(); i++) f *= i;
          state = state.copyWith(currentInput: f.toString(), isNewEntry: true);
        }
      case 'reciprocal':
        _addToExpression('1/($cur)');
        final v = double.tryParse(cur) ?? 0;
        if (v != 0) {
          state = state.copyWith(currentInput: (1 / v).toString(), isNewEntry: true);
        } else {
          state = state.copyWith(error: 'Cannot divide by zero');
        }
      case 'negate':
        state = state.copyWith(currentInput: (-(double.tryParse(cur) ?? 0)).toString());
      case 'lparen':
        state = state.copyWith(expression: '${state.expression}(', isNewEntry: true);
      case 'rparen':
        state = state.copyWith(expression: '${state.expression})');
      case 'clear':
        state = const CalculatorState();
      case 'backspace':
        if (state.justEvaluated) {
          state = const CalculatorState();
          return;
        }
        if (state.isNewEntry) return;
        final cur2 = state.currentInput;
        if (cur2.length > 1) {
          state = state.copyWith(currentInput: cur2.substring(0, cur2.length - 1));
        } else {
          state = state.copyWith(currentInput: '0', isNewEntry: true);
        }
      case 'equals':
        _calculate();
      default:
        break;
    }
  }

  void _addToExpression(String part) {
    if (!state.isNewEntry && state.currentInput != '0') {
      state = state.copyWith(expression: '${state.expression}${state.currentInput}$part', isNewEntry: true);
    } else {
      state = state.copyWith(expression: '${state.expression}$part', isNewEntry: true);
    }
  }

  void _calculate() {
    var expr = state.expression;
    if (expr.isEmpty) return;

    if (!state.isNewEntry && state.currentInput != '0') {
      if (expr.isNotEmpty && !expr.endsWith(')')) {
        expr += state.currentInput;
      }
    }

    final sanitized = _engine.sanitizeExpression(expr);
    final result = _engine.evaluate(sanitized, angleMode: state.angleMode);

    if (result != null) {
      state = state.copyWith(
        expression: expr,
        currentInput: result.formatted,
        result: result.formatted,
        isNewEntry: true,
        justEvaluated: true,
        error: '',
      );
      _addHistory(expr, result.formatted);
    } else {
      state = state.copyWith(error: 'Error');
    }
  }

  void _addHistory(String expr, String result) {
    final entry = HistoryEntry(expression: '$expr =', result: result);
    _ref.read(historyProvider.notifier).add(entry);
  }

  void memoryClear() {
    state = state.copyWith(hasMemory: false, memoryValue: 0.0);
  }

  void memoryRecall() {
    if (state.hasMemory) {
      state = state.copyWith(currentInput: state.memoryValue.toString(), isNewEntry: true);
    }
  }

  void memoryAdd() {
    final v = double.tryParse(state.currentInput) ?? 0;
    state = state.copyWith(
      memoryValue: state.memoryValue + v,
      hasMemory: true,
    );
  }

  void memorySubtract() {
    final v = double.tryParse(state.currentInput) ?? 0;
    state = state.copyWith(
      memoryValue: state.memoryValue - v,
      hasMemory: true,
    );
  }

  void memoryStore() {
    final v = double.tryParse(state.currentInput) ?? 0;
    state = state.copyWith(memoryValue: v, hasMemory: true);
  }

  void toggleAngleMode() {
    state = state.copyWith(
      angleMode: state.angleMode == AngleMode.deg ? AngleMode.rad : AngleMode.deg,
    );
  }

  void setMode(CalculatorMode mode) {
    state = state.copyWith(mode: mode);
  }

  void toggleHistory() {
    state = state.copyWith(showHistory: !state.showHistory);
  }

  void restoreFromHistory(HistoryEntry entry) {
    state = state.copyWith(
      expression: entry.expression.replaceAll(' =', ''),
      currentInput: entry.result.replaceAll(',', ''),
      isNewEntry: true,
      justEvaluated: false,
      showHistory: false,
    );
  }

  String _displayOp(String op) {
    switch (op) {
      case '+': return '+';
      case '-': return '−';
      case '*': return '×';
      case '/': return '÷';
      case '^': return '^';
      case '%': return '%';
      default: return op;
    }
  }
}

final calculatorProvider = StateNotifierProvider<CalculatorNotifier, CalculatorState>((ref) {
  return CalculatorNotifier(ref);
});
