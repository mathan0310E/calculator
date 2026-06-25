import 'package:flutter_test/flutter_test.dart';
import 'package:calc_pro/engine/calculator_engine.dart';
import 'package:calc_pro/engine/tokenizer.dart';

void main() {
  group('Tokenizer', () {
    test('tokenizes simple addition', () {
      final tokenizer = Tokenizer('2+3');
      final tokens = tokenizer.tokenize();
      expect(tokens.length, 3);
      expect(tokens[0].type, TokenType.number);
      expect(tokens[0].value, '2');
      expect(tokens[1].type, TokenType.plus);
      expect(tokens[2].type, TokenType.number);
      expect(tokens[2].value, '3');
    });

    test('tokenizes decimal numbers', () {
      final tokenizer = Tokenizer('3.14');
      final tokens = tokenizer.tokenize();
      expect(tokens.length, 1);
      expect(tokens[0].numericValue, closeTo(3.14, 0.001));
    });

    test('tokenizes functions', () {
      final tokenizer = Tokenizer('sin(30)');
      final tokens = tokenizer.tokenize();
      expect(tokens.length, 4);
      expect(tokens[0].type, TokenType.function);
      expect(tokens[0].value, 'sin');
      expect(tokens[1].type, TokenType.lparen);
      expect(tokens[2].type, TokenType.number);
      expect(tokens[3].type, TokenType.rparen);
    });

    test('tokenizes constant pi', () {
      final tokenizer = Tokenizer('pi');
      final tokens = tokenizer.tokenize();
      expect(tokens.length, 1);
      expect(tokens[0].type, TokenType.constant);
    });
  });

  group('CalculatorEngine', () {
    late CalculatorEngine engine;

    setUp(() {
      engine = CalculatorEngine();
    });

    test('evaluates addition', () {
      final result = engine.evaluate('2+3');
      expect(result, isNotNull);
      expect(result!.value, closeTo(5, 0.001));
    });

    test('evaluates subtraction', () {
      final result = engine.evaluate('10-3');
      expect(result!.value, closeTo(7, 0.001));
    });

    test('evaluates multiplication', () {
      final result = engine.evaluate('4*5');
      expect(result!.value, closeTo(20, 0.001));
    });

    test('evaluates division', () {
      final result = engine.evaluate('10/2');
      expect(result!.value, closeTo(5, 0.001));
    });

    test('respects operator precedence', () {
      final result = engine.evaluate('2+3*4');
      expect(result!.value, closeTo(14, 0.001));
    });

    test('evaluates parentheses', () {
      final result = engine.evaluate('(2+3)*4');
      expect(result!.value, closeTo(20, 0.001));
    });

    test('evaluates power', () {
      final result = engine.evaluate('2^3');
      expect(result!.value, closeTo(8, 0.001));
    });

    test('evaluates sin in degrees', () {
      final result = engine.evaluate('sin(30)');
      expect(result!.value, closeTo(0.5, 0.001));
    });

    test('evaluates cos in degrees', () {
      final result = engine.evaluate('cos(60)');
      expect(result!.value, closeTo(0.5, 0.001));
    });

    test('evaluates sqrt', () {
      final result = engine.evaluate('sqrt(16)');
      expect(result!.value, closeTo(4, 0.001));
    });

    test('evaluates pi constant', () {
      final result = engine.evaluate('pi');
      expect(result!.value, closeTo(3.14159, 0.001));
    });

    test('evaluates complex expression', () {
      final result = engine.evaluate('2+3*4-5/2');
      expect(result!.value, closeTo(11.5, 0.001));
    });

    test('returns null for division by zero', () {
      final result = engine.evaluate('1/0');
      expect(result, isNull);
    });

    test('evaluates nested parentheses', () {
      final result = engine.evaluate('((2+3)*2)');
      expect(result!.value, closeTo(10, 0.001));
    });

    test('evaluates log', () {
      final result = engine.evaluate('log(100)');
      expect(result!.value, closeTo(2, 0.001));
    });

    test('evaluates ln', () {
      final result = engine.evaluate('ln(e)');
      expect(result!.value, closeTo(1, 0.1));
    });
  });
}
