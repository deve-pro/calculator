/// Evaluates a calculator expression containing +, −, ×, ÷, %, and parentheses.
///
/// Percent is a postfix operator: `5%` is `0.05`. Both calculator symbols
/// (×, ÷, −) and their ASCII equivalents (*, /, -) are accepted.
double calculateExpression(String expression) =>
    _ExpressionParser(expression).parse();

/// Formats a result to ten significant digits without unnecessary zeroes.
String formatCalculatorResult(double value) {
  if (!value.isFinite) {
    throw const FormatException('Result is not finite');
  }
  if (value == 0) return '0';

  final precise = value.toStringAsPrecision(10);
  final exponentIndex = precise.indexOf(RegExp('[eE]'));
  if (exponentIndex >= 0) {
    final mantissa = precise.substring(0, exponentIndex);
    final exponent = precise.substring(exponentIndex + 1);
    return '${_trimDecimalZeroes(mantissa)}e$exponent';
  }
  return _trimDecimalZeroes(precise);
}

String _trimDecimalZeroes(String value) {
  if (!value.contains('.')) return value;
  return value
      .replaceFirst(RegExp(r'0+$'), '')
      .replaceFirst(RegExp(r'\.$'), '');
}

class _ExpressionParser {
  _ExpressionParser(this._source);

  final String _source;
  int _cursor = 0;

  double parse() {
    if (_source.trim().isEmpty) {
      _fail('Enter an expression');
    }

    final value = _parseSum();
    _skipWhitespace();
    if (_cursor != _source.length) {
      _fail('Unexpected character');
    }
    if (!value.isFinite) {
      _fail('Result is outside the supported range');
    }
    return value;
  }

  double _parseSum() {
    var value = _parseProduct();
    while (true) {
      if (_match('+')) {
        value += _parseProduct();
      } else if (_match('−') || _match('-')) {
        value -= _parseProduct();
      } else {
        return value;
      }
    }
  }

  double _parseProduct() {
    var value = _parseUnary();
    while (true) {
      if (_match('×') || _match('*')) {
        value *= _parseUnary();
      } else if (_match('÷') || _match('/')) {
        final divisor = _parseUnary();
        if (divisor == 0) {
          _fail('Cannot divide by zero');
        }
        value /= divisor;
      } else {
        return value;
      }
    }
  }

  double _parseUnary() {
    if (_match('+')) return _parseUnary();
    if (_match('−') || _match('-')) return -_parseUnary();

    var value = _parsePrimary();
    while (_match('%')) {
      value /= 100;
    }
    return value;
  }

  double _parsePrimary() {
    if (_match('(')) {
      final value = _parseSum();
      if (!_match(')')) {
        _fail('Expected a closing parenthesis');
      }
      return value;
    }
    return _parseNumber();
  }

  double _parseNumber() {
    _skipWhitespace();
    final start = _cursor;
    var digitCount = 0;

    while (_isDigit(_currentChar)) {
      _cursor++;
      digitCount++;
    }

    if (_currentChar == '.') {
      _cursor++;
      while (_isDigit(_currentChar)) {
        _cursor++;
        digitCount++;
      }
    }

    if (digitCount == 0) {
      _fail('Expected a number');
    }

    if (_currentChar == 'e' || _currentChar == 'E') {
      _cursor++;
      if (_currentChar == '+' || _currentChar == '-' || _currentChar == '−') {
        _cursor++;
      }

      var exponentDigitCount = 0;
      while (_isDigit(_currentChar)) {
        _cursor++;
        exponentDigitCount++;
      }
      if (exponentDigitCount == 0) {
        _fail('Expected exponent digits');
      }
    }

    final literal = _source
        .substring(start, _cursor)
        .replaceAll('−', '-');
    final value = double.tryParse(literal);
    if (value == null || !value.isFinite) {
      _fail('Invalid number');
    }
    return value;
  }

  bool _match(String character) {
    _skipWhitespace();
    if (_currentChar != character) return false;
    _cursor++;
    return true;
  }

  void _skipWhitespace() {
    while (_cursor < _source.length && _source[_cursor].trim().isEmpty) {
      _cursor++;
    }
  }

  String? get _currentChar =>
      _cursor < _source.length ? _source[_cursor] : null;

  bool _isDigit(String? character) {
    if (character == null) return false;
    final codeUnit = character.codeUnitAt(0);
    return codeUnit >= 48 && codeUnit <= 57;
  }

  Never _fail(String message) =>
      throw FormatException(message, _source, _cursor);
}
