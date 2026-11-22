import 'dart:math' as _math;

/// Evaluates calculator expressions with arithmetic, scientific functions,
/// constants, parentheses, postfix percent, and factorial operators.
///
/// Supported functions: sin, cos, tan, asin, acos, atan, sqrt, ln, log, abs.
/// Trigonometric functions use radians unless [degrees] is true.
double calculateExpression(String expression, {bool degrees = false}) =>
    _ExpressionParser(expression, degrees: degrees).parse();

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
  _ExpressionParser(this._source, {required this.degrees});

  final String _source;
  final bool degrees;
  int _cursor = 0;

  double parse() {
    if (_source.trim().isEmpty) _fail('Enter an expression');
    final value = _parseSum();
    _skipWhitespace();
    if (_cursor != _source.length) _fail('Unexpected character');
    if (!value.isFinite) _fail('Result is outside the supported range');
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
        if (divisor == 0) _fail('Cannot divide by zero');
        value /= divisor;
      } else {
        return value;
      }
    }
  }

  double _parseUnary() {
    if (_match('+')) return _parseUnary();
    if (_match('−') || _match('-')) return -_parseUnary();
    return _parsePower();
  }

  double _parsePower() {
    var value = _parsePostfix();
    if (_match('^')) {
      value = mathPow(value, _parseUnary());
    }
    return value;
  }

  double _parsePostfix() {
    var value = _parsePrimary();
    while (true) {
      if (_match('%')) {
        value /= 100;
      } else if (_match('!')) {
        value = _factorial(value);
      } else {
        return value;
      }
    }
  }

  double _parsePrimary() {
    _skipWhitespace();
    if (_match('(')) {
      final value = _parseSum();
      if (!_match(')')) _fail('Expected a closing parenthesis');
      return value;
    }
    if (_currentChar == 'π') {
      _cursor++;
      return 3.141592653589793;
    }
    if (_isDigit(_currentChar) || _currentChar == '.') return _parseNumber();

    final identifier = _parseIdentifier();
    if (identifier == 'e') return 2.718281828459045;
    if (!_match('(')) _fail('Expected an opening parenthesis after $identifier');
    final argument = _parseSum();
    if (!_match(')')) _fail('Expected a closing parenthesis');
    final angle = degrees ? argument * (3.141592653589793 / 180) : argument;
    return switch (identifier) {
      'sin' => mathSin(angle),
      'cos' => mathCos(angle),
      'tan' => mathTan(angle),
      'asin' => degrees ? mathAsin(argument) * 180 / 3.141592653589793 : mathAsin(argument),
      'acos' => degrees ? mathAcos(argument) * 180 / 3.141592653589793 : mathAcos(argument),
      'atan' => degrees ? mathAtan(argument) * 180 / 3.141592653589793 : mathAtan(argument),
      'sqrt' => argument < 0 ? double.nan : mathSqrt(argument),
      'ln' => argument <= 0 ? double.nan : mathLog(argument),
      'log' => argument <= 0 ? double.nan : mathLog(argument) / mathLog(10),
      'abs' => argument.abs(),
      _ => throw FormatException('Unknown function: $identifier', _source, _cursor),
    };
  }

  String _parseIdentifier() {
    _skipWhitespace();
    final start = _cursor;
    while (_cursor < _source.length) {
      final c = _source[_cursor];
      if ((c.codeUnitAt(0) >= 65 && c.codeUnitAt(0) <= 90) ||
          (c.codeUnitAt(0) >= 97 && c.codeUnitAt(0) <= 122)) {
        _cursor++;
      } else {
        break;
      }
    }
    if (start == _cursor) _fail('Expected a number or function');
    return _source.substring(start, _cursor).toLowerCase();
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
    if (digitCount == 0) _fail('Expected a number');

    if (_currentChar == 'e' || _currentChar == 'E') {
      _cursor++;
      if (_currentChar == '+' || _currentChar == '-' || _currentChar == '−') {
        _cursor++;
      }
      var exponentDigits = 0;
      while (_isDigit(_currentChar)) {
        _cursor++;
        exponentDigits++;
      }
      if (exponentDigits == 0) _fail('Expected exponent digits');
    }
    final literal = _source.substring(start, _cursor).replaceAll('−', '-');
    final value = double.tryParse(literal);
    if (value == null || !value.isFinite) _fail('Invalid number');
    return value;
  }

  double _factorial(double value) {
    if (value < 0 || value != value.roundToDouble() || value > 170) {
      _fail('Factorial requires an integer from 0 to 170');
    }
    var result = 1.0;
    for (var i = 2; i <= value.toInt(); i++) {
      result *= i;
    }
    return result;
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

  String? get _currentChar => _cursor < _source.length ? _source[_cursor] : null;

  bool _isDigit(String? character) {
    if (character == null) return false;
    final codeUnit = character.codeUnitAt(0);
    return codeUnit >= 48 && codeUnit <= 57;
  }

  Never _fail(String message) => throw FormatException(message, _source, _cursor);
}

// Keeping math behind these aliases makes the parser code easier to scan.
double mathPow(double x, double exponent) => _pow(x, exponent);
double mathSin(double value) => _sin(value);
double mathCos(double value) => _cos(value);
double mathTan(double value) => _tan(value);
double mathAsin(double value) => _asin(value);
double mathAcos(double value) => _acos(value);
double mathAtan(double value) => _atan(value);
double mathSqrt(double value) => _sqrt(value);
double mathLog(double value) => _log(value);

double _pow(double x, double y) => _math.pow(x, y).toDouble();
double _sin(double x) => _math.sin(x);
double _cos(double x) => _math.cos(x);
double _tan(double x) => _math.tan(x);
double _asin(double x) => _math.asin(x);
double _acos(double x) => _math.acos(x);
double _atan(double x) => _math.atan(x);
double _sqrt(double x) => _math.sqrt(x);
double _log(double x) => _math.log(x);
