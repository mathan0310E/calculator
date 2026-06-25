import 'dart:math' as math;
import 'tokenizer.dart';

enum AngleMode { deg, rad }

class CalculationResult {
  final double value;
  final String formatted;
  final String expression;

  const CalculationResult({
    required this.value,
    required this.formatted,
    required this.expression,
  });
}

class CalculatorEngine {
  final List<Token> _output = [];
  final List<Token> _operators = [];

  CalculationResult? evaluate(String expression, {AngleMode angleMode = AngleMode.deg}) {
    try {
      final tokenizer = Tokenizer(expression);
      final tokens = tokenizer.tokenize();
      _output.clear();
      _operators.clear();

      _shuntingYard(tokens);

      final result = _evaluateRPN(angleMode);
      return CalculationResult(
        value: result,
        formatted: _formatNumber(result),
        expression: expression,
      );
    } catch (_) {
      return null;
    }
  }

  void _shuntingYard(List<Token> tokens) {
    for (int i = 0; i < tokens.length; i++) {
      final token = tokens[i];

      switch (token.type) {
        case TokenType.number:
        case TokenType.constant:
          _output.add(token);

        case TokenType.function:
          _operators.add(token);

        case TokenType.factorial:
          if (_output.isNotEmpty) {
            final last = _output.removeLast();
            final v = last.numericValue ?? 0;
            if (v >= 0 && v == v.roundToDouble()) {
              int f = 1;
              for (int j = 2; j <= v.round(); j++) f *= j;
              _output.add(Token(type: TokenType.number, value: f.toString(), numericValue: f.toDouble()));
            }
          }

        case TokenType.comma:
          while (_operators.isNotEmpty && _operators.last.type != TokenType.lparen) {
            _output.add(_operators.removeLast());
          }

        case TokenType.plus:
        case TokenType.minus:
          while (_operators.isNotEmpty && _operators.last.type != TokenType.lparen) {
            _output.add(_operators.removeLast());
          }
          _operators.add(token);

        case TokenType.multiply:
        case TokenType.divide:
        case TokenType.modulo:
          while (_operators.isNotEmpty && _operators.last.type != TokenType.lparen &&
              _operators.last.type != TokenType.plus && _operators.last.type != TokenType.minus) {
            _output.add(_operators.removeLast());
          }
          _operators.add(token);

        case TokenType.power:
          _operators.add(token);

        case TokenType.percent:
          _operators.add(token);

        case TokenType.lparen:
          _operators.add(token);

        case TokenType.rparen:
          while (_operators.isNotEmpty && _operators.last.type != TokenType.lparen) {
            _output.add(_operators.removeLast());
          }
          if (_operators.isNotEmpty && _operators.last.type == TokenType.lparen) {
            _operators.removeLast();
          }
          if (_operators.isNotEmpty && _operators.last.type == TokenType.function) {
            _output.add(_operators.removeLast());
          }
      }
    }

    while (_operators.isNotEmpty) {
      _output.add(_operators.removeLast());
    }
  }

  double _evaluateRPN(AngleMode angleMode) {
    final stack = <double>[];

    for (final token in _output) {
      switch (token.type) {
        case TokenType.number:
        case TokenType.constant:
          stack.add(token.numericValue ?? 0);

        case TokenType.plus:
          _binaryOp(stack, (a, b) => a + b);
        case TokenType.minus:
          _binaryOp(stack, (a, b) => a - b);
        case TokenType.multiply:
          _binaryOp(stack, (a, b) => a * b);
        case TokenType.divide:
          _binaryOp(stack, (a, b) => b == 0 ? double.nan : a / b);
        case TokenType.power:
          _binaryOp(stack, (a, b) => math.pow(a, b).toDouble());
        case TokenType.modulo:
          _binaryOp(stack, (a, b) => b == 0 ? double.nan : a % b);
        case TokenType.percent:
          if (stack.length >= 1) {
            stack.add(stack.removeLast() / 100);
          }

        case TokenType.function:
          _applyFunction(stack, token.value, angleMode);

        default:
          break;
      }
    }

    if (stack.length != 1) throw Exception('Invalid expression');
    final result = stack.last;
    if (!result.isFinite) throw Exception('Result is not finite');
    return result;
  }

  void _binaryOp(List<double> stack, double Function(double, double) op) {
    if (stack.length < 2) return;
    final b = stack.removeLast();
    final a = stack.removeLast();
    stack.add(op(a, b));
  }

  void _applyFunction(List<double> stack, String name, AngleMode angleMode) {
    if (stack.isEmpty) return;
    final arg = stack.removeLast();

    double result;
    switch (name) {
      case 'sin':
        result = angleMode == AngleMode.deg ? math.sin(arg * math.pi / 180) : math.sin(arg);
      case 'cos':
        result = angleMode == AngleMode.deg ? math.cos(arg * math.pi / 180) : math.cos(arg);
      case 'tan':
        result = angleMode == AngleMode.deg ? math.tan(arg * math.pi / 180) : math.tan(arg);
      case 'asin':
        result = angleMode == AngleMode.deg ? math.asin(arg) * 180 / math.pi : math.asin(arg);
      case 'acos':
        result = angleMode == AngleMode.deg ? math.acos(arg) * 180 / math.pi : math.acos(arg);
      case 'atan':
        result = angleMode == AngleMode.deg ? math.atan(arg) * 180 / math.pi : math.atan(arg);
      case 'log':
        result = math.log(arg) / math.ln10;
      case 'ln':
        result = math.log(arg);
      case 'sqrt':
        result = math.sqrt(arg);
      case 'cbrt':
        result = math.pow(arg, 1.0 / 3.0).toDouble();
      case 'abs':
        result = arg.abs();
      case 'exp':
        result = math.exp(arg);
      case 'rand':
        result = math.Random().nextDouble();
      default:
        result = arg;
    }

    if (!result.isFinite) throw Exception('Function result is not finite');
    stack.add(result);
  }

  String _formatNumber(double value) {
    if (value >= 1e15 || value <= -1e15 || (value.abs() < 1e-10 && value != 0)) {
      return value.toStringAsExponential(6);
    }
    final str = value.toStringAsFixed(10)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
    return _addThousandsSeparator(str);
  }

  String _addThousandsSeparator(String s) {
    final parts = s.split('.');
    var intPart = parts[0];
    final sign = intPart.startsWith('-') ? '-' : '';
    if (sign.isNotEmpty) intPart = intPart.substring(1);
    String result = '';
    for (int i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) result += ',';
      result += intPart[i];
    }
    if (parts.length > 1) return '$sign$result.${parts[1]}';
    return '$sign$result';
  }

  String sanitizeExpression(String expr) {
    return expr
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll('−', '-')
        .replaceAll('²', '**2')
        .replaceAll('³', '**3')
        .replaceAll('π', 'pi')
        .replaceAll('e', 'e');
  }

  String get displayOperators {
    return {'+': '+', '-': '−', '*': '×', '/': '÷', '%': '%', '^': '^'} as String;
  }
}
