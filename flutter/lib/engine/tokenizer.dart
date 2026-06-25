enum TokenType {
  number,
  plus,
  minus,
  multiply,
  divide,
  power,
  modulo,
  percent,
  lparen,
  rparen,
  function,
  constant,
  factorial,
  comma,
}

class Token {
  final TokenType type;
  final String value;
  final double? numericValue;

  const Token({required this.type, required this.value, this.numericValue});

  @override
  String toString() => 'Token($type, $value)';
}

class Tokenizer {
  final String input;
  int _pos = 0;

  Tokenizer(this.input);

  List<Token> tokenize() {
    final tokens = <Token>[];
    _pos = 0;

    while (_pos < input.length) {
      final ch = input[_pos];

      if (ch == ' ') {
        _pos++;
        continue;
      }

      if (_isDigit(ch) || (ch == '.' && _pos + 1 < input.length && _isDigit(input[_pos + 1]))) {
        tokens.add(_readNumber());
        continue;
      }

      if (_isLetter(ch)) {
        tokens.add(_readIdentifier());
        continue;
      }

      switch (ch) {
        case '+':
          tokens.add(const Token(type: TokenType.plus, value: '+'));
          _pos++;
        case '-':
          tokens.add(const Token(type: TokenType.minus, value: '-'));
          _pos++;
        case '×':
        case '*':
          tokens.add(const Token(type: TokenType.multiply, value: '×'));
          _pos++;
        case '÷':
        case '/':
          tokens.add(const Token(type: TokenType.divide, value: '÷'));
          _pos++;
        case '^':
          tokens.add(const Token(type: TokenType.power, value: '^'));
          _pos++;
        case '%':
          tokens.add(const Token(type: TokenType.percent, value: '%'));
          _pos++;
        case '(':
          tokens.add(const Token(type: TokenType.lparen, value: '('));
          _pos++;
        case ')':
          tokens.add(const Token(type: TokenType.rparen, value: ')'));
          _pos++;
        case '!':
          tokens.add(const Token(type: TokenType.factorial, value: '!'));
          _pos++;
        case ',':
          tokens.add(const Token(type: TokenType.comma, value: ','));
          _pos++;
        case 'π':
          tokens.add(Token(type: TokenType.constant, value: 'π', numericValue: 3.141592653589793));
          _pos++;
        case 'e':
          if (_pos + 1 < input.length && _isLetter(input[_pos + 1])) {
            tokens.add(_readIdentifier());
          } else {
            tokens.add(Token(type: TokenType.constant, value: 'e', numericValue: 2.718281828459045));
            _pos++;
          }
        default:
          _pos++;
      }
    }

    return tokens;
  }

  Token _readNumber() {
    final start = _pos;
    while (_pos < input.length && (_isDigit(input[_pos]) || input[_pos] == '.')) {
      _pos++;
    }
    final str = input.substring(start, _pos);
    return Token(
      type: TokenType.number,
      value: str,
      numericValue: double.tryParse(str) ?? 0,
    );
  }

  Token _readIdentifier() {
    final start = _pos;
    while (_pos < input.length && (_isLetter(input[_pos]) || _isDigit(input[_pos]))) {
      _pos++;
    }
    final id = input.substring(start, _pos);

    const functions = {
      'sin', 'cos', 'tan', 'asin', 'acos', 'atan',
      'log', 'ln', 'sqrt', 'cbrt', 'abs', 'exp', 'rand',
    };

    const constants = {
      'pi': 3.141592653589793,
      'e': 2.718281828459045,
    };

    if (functions.contains(id)) {
      return Token(type: TokenType.function, value: id);
    }
    if (constants.containsKey(id)) {
      return Token(type: TokenType.constant, value: id, numericValue: constants[id]);
    }

    return Token(type: TokenType.function, value: id);
  }

  bool _isDigit(String ch) => ch.codeUnitAt(0) >= 48 && ch.codeUnitAt(0) <= 57;
  bool _isLetter(String ch) {
    final c = ch.codeUnitAt(0);
    return (c >= 65 && c <= 90) || (c >= 97 && c <= 122);
  }
}
