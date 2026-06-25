import 'package:calc_pro/engine/calculator_engine.dart';

enum CalculatorMode { basic, scientific }

class CalculatorState {
  final String expression;
  final String currentInput;
  final String result;
  final String error;
  final CalculatorMode mode;
  final AngleMode angleMode;
  final bool hasMemory;
  final double memoryValue;
  final bool isNewEntry;
  final bool justEvaluated;
  final bool showHistory;

  const CalculatorState({
    this.expression = '',
    this.currentInput = '0',
    this.result = '',
    this.error = '',
    this.mode = CalculatorMode.basic,
    this.angleMode = AngleMode.deg,
    this.hasMemory = false,
    this.memoryValue = 0.0,
    this.isNewEntry = true,
    this.justEvaluated = false,
    this.showHistory = false,
  });

  CalculatorState copyWith({
    String? expression,
    String? currentInput,
    String? result,
    String? error,
    CalculatorMode? mode,
    AngleMode? angleMode,
    bool? hasMemory,
    double? memoryValue,
    bool? isNewEntry,
    bool? justEvaluated,
    bool? showHistory,
  }) {
    return CalculatorState(
      expression: expression ?? this.expression,
      currentInput: currentInput ?? this.currentInput,
      result: result ?? this.result,
      error: error ?? this.error,
      mode: mode ?? this.mode,
      angleMode: angleMode ?? this.angleMode,
      hasMemory: hasMemory ?? this.hasMemory,
      memoryValue: memoryValue ?? this.memoryValue,
      isNewEntry: isNewEntry ?? this.isNewEntry,
      justEvaluated: justEvaluated ?? this.justEvaluated,
      showHistory: showHistory ?? this.showHistory,
    );
  }
}
