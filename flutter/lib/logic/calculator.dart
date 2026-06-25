import 'dart:math' as math;
import 'history.dart';

enum AngleMode { deg, rad }

class CalculatorState {
  String expression = '';
  String current = '0';
  bool isNewEntry = true;
  bool justEvaluated = false;
  int parenCount = 0;
  AngleMode angleMode = AngleMode.deg;
  String? lastAnswer;

  void clearAll() {
    expression = '';
    current = '0';
    isNewEntry = true;
    justEvaluated = false;
    parenCount = 0;
  }

  void backspace() {
    if (justEvaluated) {
      clearAll();
      return;
    }
    if (isNewEntry) return;
    if (current.length > 1) {
      current = current.substring(0, current.length - 1);
    } else {
      current = '0';
      isNewEntry = true;
    }
  }

  void inputDigit(String digit) {
    if (justEvaluated) {
      expression = '';
      current = '0';
      justEvaluated = false;
    }
    if (isNewEntry) {
      current = digit;
      isNewEntry = false;
    } else {
      if (current == '0') {
        current = digit;
      } else if (current.length < 16) {
        current += digit;
      }
    }
  }

  void inputDecimal() {
    if (justEvaluated) {
      expression = '';
      current = '0.';
      justEvaluated = false;
      isNewEntry = false;
      return;
    }
    if (isNewEntry) {
      current = '0.';
      isNewEntry = false;
      return;
    }
    if (!current.contains('.')) {
      current += '.';
    }
  }

  void inputOperator(String op) {
    justEvaluated = false;
    isNewEntry = false;

    final exprOp = _displayOp(op);
    final expr = expression;

    if (current != '0' && !isNewEntry) {
      if (expr.isNotEmpty && expr.endsWith(')')) {
        expression = '$expr $exprOp';
      } else {
        expression = '${expr}${_unformat(current)}';
      }
    }

    final last = expression.isNotEmpty ? expression[expression.length - 1] : '';
    if ('+-×÷^('.contains(last) || expression.isEmpty) {
      if ('+-×÷^'.contains(last)) {
        expression = expression.substring(0, expression.length - 1).trim();
      }
    }

    if (op == '%') {
      try {
        final val = double.parse(current) / 100;
        current = _formatDouble(val);
        expression = '${expression}${_unformat(current)}%';
      } catch (_) {
        current = 'Error';
      }
      isNewEntry = true;
      return;
    }

    expression = '$expression $exprOp ';
    current = '0';
    isNewEntry = true;
  }

  void inputFunction(String fn) {
    justEvaluated = false;
    final cur = _unformat(current);

    switch (fn) {
      case 'pi':
        if (!isNewEntry && current != '0') {
          expression += cur;
        }
        expression += 'π';
        current = math.pi.toString();
        isNewEntry = true;

      case 'econst':
        if (!isNewEntry && current != '0') {
          expression += cur;
        }
        expression += 'e';
        current = math.e.toString();
        isNewEntry = true;

      case 'square':
        {
          final v = double.parse(current);
          expression = '$expression${cur}²';
          current = _formatDouble(v * v);
          isNewEntry = true;
        }

      case 'cube':
        {
          final v = double.parse(current);
          expression = '$expression${cur}³';
          current = _formatDouble(v * v * v);
          isNewEntry = true;
        }

      case 'sqrt':
        {
          final v = double.parse(current);
          expression = '$expression√($cur)';
          current = _formatDouble(math.sqrt(v));
          isNewEntry = true;
        }

      case 'cbrt':
        {
          final v = double.parse(current);
          expression = '$expression∛($cur)';
          current = _formatDouble(math.pow(v, 1.0 / 3.0).toDouble());
          isNewEntry = true;
        }

      case 'reciprocal':
        {
          final v = double.parse(current);
          if (v == 0) return;
          expression = '$expression1/($cur)';
          current = _formatDouble(1.0 / v);
          isNewEntry = true;
        }

      case 'factorial':
        {
          final v = double.parse(current);
          if (v < 0 || v != v.roundToDouble()) return;
          int f = 1;
          for (int i = 2; i <= v.round(); i++) {
            f *= i;
          }
          expression = '$expression${cur}!';
          current = f.toString();
          isNewEntry = true;
        }

      case 'negate':
        current = _formatDouble(-double.parse(current));

      case 'sin':
      case 'cos':
      case 'tan':
      case 'asin':
      case 'acos':
      case 'atan':
      case 'log':
      case 'ln':
      case 'exp':
      case 'tenx':
      case 'abs':
        _applyTrigOrMath(fn, cur);
    }
  }

  void _applyTrigOrMath(String fn, String cur) {
    final v = double.parse(current);
    double? r;

    try {
      switch (fn) {
        case 'sin':
          r = angleMode == AngleMode.rad
              ? math.sin(v)
              : math.sin(v * math.pi / 180);
        case 'cos':
          r = angleMode == AngleMode.rad
              ? math.cos(v)
              : math.cos(v * math.pi / 180);
        case 'tan':
          r = angleMode == AngleMode.rad
              ? math.tan(v)
              : math.tan(v * math.pi / 180);
        case 'asin':
          r = angleMode == AngleMode.rad
              ? math.asin(v)
              : math.asin(v) * 180 / math.pi;
        case 'acos':
          r = angleMode == AngleMode.rad
              ? math.acos(v)
              : math.acos(v) * 180 / math.pi;
        case 'atan':
          r = angleMode == AngleMode.rad
              ? math.atan(v)
              : math.atan(v) * 180 / math.pi;
        case 'log':
          r = v > 0 ? math.log(v) / math.ln10 : null;
        case 'ln':
          r = v > 0 ? math.log(v) : null;
        case 'exp':
          r = math.exp(v);
        case 'tenx':
          r = math.pow(10, v).toDouble();
        case 'abs':
          r = v.abs();
      }
    } catch (_) {
      current = 'Error';
      return;
    }

    if (r == null || !r.isFinite) {
      current = 'Error';
      return;
    }

    expression = '$expression$fn($cur)';
    current = _formatDouble(r);
    isNewEntry = true;
  }

  void inputLparen() {
    if (justEvaluated) {
      expression = '';
      current = '0';
      justEvaluated = false;
    }
    expression += '(';
    parenCount++;
  }

  void inputRparen() {
    if (parenCount <= 0) return;
    expression += ')';
    parenCount--;
  }

  HistoryEntry? calculate() {
    var expr = expression;
    if (expr.isEmpty) {
      current = '0';
      isNewEntry = true;
      return null;
    }

    while (expr.count('(') > expr.count(')')) {
      expr += ')';
    }

    final last = expr.isNotEmpty ? expr[expr.length - 1] : '';
    if ('+-×÷^('.contains(last) || last == ' ') return null;

    if (!isNewEntry && current != '0' && last != ')') {
      expr += _unformat(current);
    }

    final result = _evaluate(expr);
    if (result == null || !result.isFinite) {
      current = 'Error';
      expression = expr;
      return null;
    }

    final resultStr = _formatDouble(result);
    final displayExpr = expr;
    expression = expr;
    current = resultStr;
    isNewEntry = true;
    justEvaluated = true;
    lastAnswer = resultStr;

    return HistoryEntry(
      expression: '$displayExpr =',
      result: _formatNumber(resultStr),
    );
  }

  double? _evaluate(String expr) {
    var sanitized = expr
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll('−', '-')
        .replaceAll('π', math.pi.toString())
        .replaceAll('²', '**2')
        .replaceAll('³', '**3')
        .replaceAll('√', 'sqrt')
        .replaceAll('∛', 'cbrt')
        .replaceAll('^', '**');

    sanitized = sanitized.replaceAll('e', math.e.toString());
    sanitized = sanitized.replaceAll('${math.e}xp', 'exp');

    sanitized = sanitized
        .replaceAllMapped(RegExp(r'(\d)\('), (m) => '${m[1]}*(')
        .replaceAllMapped(RegExp(r'\)\( '), (m) => ')*(')
        .replaceAllMapped(RegExp(r'\)(\d)'), (m) => ')*${m[1]}');

    final funcs = {
      'sin': 'sin', 'cos': 'cos', 'tan': 'tan',
      'asin': 'asin', 'acos': 'acos', 'atan': 'atan',
      'log': 'log10', 'ln': 'log', 'sqrt': 'sqrt',
      'cbrt': 'cbrt', 'abs': 'abs', 'exp': 'exp',
    };

    for (final e in funcs.entries) {
      sanitized = sanitized.replaceAllMapped(
        RegExp('${e.key}\\('),
        (m) => 'math.${e.value}(',
      );
    }

    sanitized = sanitized.replaceAllMapped(
      RegExp(r'tenx\('),
      (m) => 'math.pow(10,',
    );

    return _safeEval(sanitized);
  }

  double? _safeEval(String expr) {
    try {
      final exprs = expr.split('=');
      final e = exprs.first;
      return _parseExpression(e);
    } catch (_) {
      return null;
    }
  }

  double _parseExpression(String expr) {
    expr = expr.trim();
    final tokens = _tokenize(expr);
    return _parseAddSub(tokens, 0).value;
  }

  List<String> _tokenize(String expr) {
    final tokens = <String>[];
    String current = '';
    for (int i = 0; i < expr.length; i++) {
      final ch = expr[i];
      if (RegExp(r'[\d.]').hasMatch(ch)) {
        current += ch;
      } else if (ch == '-' && (i == 0 || '+-*/%^(),'.contains(expr[i - 1]))) {
        current += ch;
      } else {
        if (current.isNotEmpty) {
          tokens.add(current);
          current = '';
        }
        if (ch != ' ') tokens.add(ch);
      }
    }
    if (current.isNotEmpty) tokens.add(current);
    return tokens;
  }

  _Result _parseAddSub(List<String> tokens, int pos) {
    var left = _parseMulDiv(tokens, pos);
    while (left.pos < tokens.length) {
      final op = tokens[left.pos];
      if (op != '+' && op != '-') break;
      final right = _parseMulDiv(tokens, left.pos + 1);
      left = _Result(
        op == '+' ? left.value + right.value : left.value - right.value,
        right.pos,
      );
    }
    return left;
  }

  _Result _parseMulDiv(List<String> tokens, int pos) {
    var left = _parsePower(tokens, pos);
    while (left.pos < tokens.length) {
      final op = tokens[left.pos];
      if (op != '*' && op != '/' && op != '%') break;
      final right = _parsePower(tokens, left.pos + 1);
      if (op == '*') {
        left = _Result(left.value * right.value, right.pos);
      } else if (op == '/') {
        if (right.value == 0) throw Exception('Division by zero');
        left = _Result(left.value / right.value, right.pos);
      } else {
        left = _Result(left.value % right.value, right.pos);
      }
    }
    return left;
  }

  _Result _parsePower(List<String> tokens, int pos) {
    var left = _parseUnary(tokens, pos);
    if (left.pos < tokens.length && tokens[left.pos] == '**') {
      final right = _parsePower(tokens, left.pos + 1);
      left = _Result(math.pow(left.value, right.value).toDouble(), right.pos);
    }
    return left;
  }

  _Result _parseUnary(List<String> tokens, int pos) {
    if (pos >= tokens.length) return _Result(0, pos);
    if (tokens[pos] == '-') {
      final next = _parseAtom(tokens, pos + 1);
      return _Result(-next.value, next.pos);
    }
    if (tokens[pos] == '+') {
      return _parseAtom(tokens, pos + 1);
    }
    return _parseAtom(tokens, pos);
  }

  _Result _parseAtom(List<String> tokens, int pos) {
    if (pos >= tokens.length) return _Result(0, pos);

    if (tokens[pos] == '(') {
      final inner = _parseAddSub(tokens, pos + 1);
      if (inner.pos < tokens.length && tokens[inner.pos] == ')') {
        return _Result(inner.value, inner.pos + 1);
      }
      return inner;
    }

    if (tokens[pos].startsWith('math.')) {
      final parts = tokens[pos].split('(');
      if (parts.length == 2) {
        final arg = _parseAddSub(tokens, pos + 1);
        if (arg.pos < tokens.length && tokens[arg.pos] == ')') {
          final func = parts[0].replaceAll('math.', '');
          final val = _applyMathFunc(func, arg.value);
          return _Result(val, arg.pos + 1);
        }
      }
    }

    if (RegExp(r'^[\d.eE+\-]+$').hasMatch(tokens[pos])) {
      return _Result(double.parse(tokens[pos]), pos + 1);
    }

    return _Result(0, pos);
  }

  double _applyMathFunc(String func, double arg) {
    switch (func) {
      case 'sin':
        return math.sin(arg);
      case 'cos':
        return math.cos(arg);
      case 'tan':
        return math.tan(arg);
      case 'asin':
        return math.asin(arg);
      case 'acos':
        return math.acos(arg);
      case 'atan':
        return math.atan(arg);
      case 'log10':
        return math.log(arg) / math.ln10;
      case 'log':
        return math.log(arg);
      case 'sqrt':
        return math.sqrt(arg);
      case 'cbrt':
        return math.pow(arg, 1.0 / 3.0).toDouble();
      case 'abs':
        return arg.abs();
      case 'exp':
        return math.exp(arg);
      default:
        return arg;
    }
  }

  String _displayOp(String op) {
    switch (op) {
      case '+':
        return '+';
      case '-':
        return '−';
      case '*':
        return '×';
      case '/':
        return '÷';
      case '^':
        return '^';
      case '%':
        return '%';
      default:
        return op;
    }
  }

  String _unformat(String s) => s.replaceAll(',', '');

  String _formatDouble(double v) {
    if (v.isInfinite || v.isNaN) return 'Error';
    final str = v.toStringAsFixed(12);
    return str.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$$'), '');
  }

  String _formatNumber(String s) {
    try {
      if (s == 'Error') return s;
      if (s.contains('e') || s.contains('E')) return s;
      final parts = s.split('.');
      var intPart = parts[0];
      final sign = intPart.startsWith('-') ? '-' : '';
      if (sign.isNotEmpty) intPart = intPart.substring(1);
      String formatted = '';
      for (int i = 0; i < intPart.length; i++) {
        if (i > 0 && (intPart.length - i) % 3 == 0) formatted += ',';
        formatted += intPart[i];
      }
      if (parts.length > 1) return '$sign$formatted.${parts[1]}';
      return '$sign$formatted';
    } catch (_) {
      return s;
    }
  }

  String get formattedCurrent {
    try {
      final v = double.parse(current);
      if (v > 999999999 || v < -999999999 || current.contains('e')) {
        if (v != 0 && v.isFinite) return v.toStringAsExponential(6);
        return current;
      }
      return _formatNumber(current);
    } catch (_) {
      return current;
    }
  }
}

class _Result {
  final double value;
  final int pos;
  _Result(this.value, this.pos);
}
