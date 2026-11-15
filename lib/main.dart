import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'calculator_engine.dart';

const _backgroundColor = Color(0xFF0B0C12);
const _panelColor = Color(0xFF151721);
const _accentColor = Color(0xFF927CFF);
const _mintColor = Color(0xFF8CE7D2);

void main() => runApp(const CalculatorApp());

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _accentColor,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: _backgroundColor,
      ),
      home: const CalculatorPage(),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  static const _keyLabels = <String>[
    'AC', '⌫', '%', '÷',
    '7', '8', '9', '×',
    '4', '5', '6', '−',
    '1', '2', '3', '+',
    '00', '0', '.', '=',
  ];

  String _expression = '';
  String _result = '0';
  String? _message;
  bool _justEvaluated = false;

  void _onKeyPressed(String key) {
    HapticFeedback.selectionClick();
    setState(() {
      if (key == 'AC') {
        _clear();
        return;
      }
      if (key == '⌫') {
        _deleteLast();
        return;
      }
      if (key == '=') {
        _evaluate();
        return;
      }
      if (key == '%') {
        _appendPercent();
        return;
      }
      if (_isOperatorKey(key)) {
        _appendOperator(key);
        return;
      }
      if (key == '.') {
        _appendDecimal();
        return;
      }
      _appendDigits(key);
    });
  }

  void _clear() {
    _expression = '';
    _result = '0';
    _message = null;
    _justEvaluated = false;
  }

  void _deleteLast() {
    if (_expression.isEmpty) return;
    _expression = _expression.substring(0, _expression.length - 1);
    _justEvaluated = false;
    _refreshPreview();
  }

  void _appendDigits(String digits) {
    if (_justEvaluated) {
      _expression = '';
      _justEvaluated = false;
    }
    if (_expression.endsWith('%')) _expression += '×';
    _expression += digits;
    _refreshPreview();
  }

  void _appendDecimal() {
    if (_justEvaluated) {
      _expression = '';
      _justEvaluated = false;
    }

    final lastCharacter = _expression.isEmpty
        ? ''
        : _expression.substring(_expression.length - 1);
    if (lastCharacter.isNotEmpty &&
        !_isOperatorKey(lastCharacter) &&
        lastCharacter != '%' &&
        (_currentNumberToken().contains('.') ||
            _currentNumberToken().contains('e') ||
            _currentNumberToken().contains('E'))) {
      return;
    }

    if (lastCharacter == '%') _expression += '×';
    if (_expression.isEmpty ||
        _isOperatorKey(_expression.substring(_expression.length - 1)) ||
        _expression.endsWith('%')) {
      _expression += '0';
    }
    _expression += '.';
    _refreshPreview();
  }

  void _appendOperator(String operator) {
    _justEvaluated = false;

    if (_expression.isEmpty) {
      if (operator == '−') _expression = operator;
      _refreshPreview();
      return;
    }

    final lastCharacter = _expression.substring(_expression.length - 1);
    if (_isOperatorKey(lastCharacter)) {
      // A minus after another operator is kept as a unary negative sign.
      if (operator == '−') {
        _expression += operator;
      } else {
        var cutAt = _expression.length - 1;
        if (lastCharacter == '−' &&
            cutAt > 0 &&
            _isOperatorKey(_expression.substring(cutAt - 1, cutAt))) {
          cutAt--;
        }
        if (cutAt == 0) return;
        _expression = '${_expression.substring(0, cutAt)}$operator';
      }
    } else {
      _expression += operator;
    }
    _refreshPreview();
  }

  void _appendPercent() {
    if (_expression.isEmpty) return;
    final lastCharacter = _expression.substring(_expression.length - 1);
    if (_isOperatorKey(lastCharacter) || lastCharacter == '%') return;
    _justEvaluated = false;
    _expression += '%';
    _refreshPreview();
  }

  void _evaluate() {
    if (_expression.isEmpty) return;
    try {
      final answer = formatCalculatorResult(
        calculateExpression(_expression),
      );
      _expression = answer;
      _result = answer;
      _message = null;
      _justEvaluated = true;
    } on FormatException catch (error) {
      final errorMessage = error.message.toString().toLowerCase();
      _message = errorMessage.contains('divide by zero')
          ? 'Cannot divide by zero'
          : 'Check the expression';
      _result = '—';
    }
  }

  void _refreshPreview() {
    _message = null;
    if (_expression.isEmpty) {
      _result = '0';
      return;
    }
    try {
      _result = formatCalculatorResult(calculateExpression(_expression));
    } on FormatException {
      _result = '—';
    }
  }

  String _currentNumberToken() {
    var start = _expression.length;
    while (start > 0) {
      final character = _expression[start - 1];
      if (_isDigitCharacter(character) || character == '.') {
        start--;
        continue;
      }
      if ((character == '+' || character == '-' || character == '−') &&
          start >= 2 &&
          (_expression[start - 2] == 'e' || _expression[start - 2] == 'E')) {
        start -= 2;
        continue;
      }
      if (character == 'e' || character == 'E') {
        start--;
        continue;
      }
      break;
    }
    return _expression.substring(start);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              Color(0xFF151522),
              _backgroundColor,
              Color(0xFF0A1114),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const _CalculatorHeader(),
                const SizedBox(height: 18),
                Expanded(
                  flex: 42,
                  child: _DisplayPanel(
                    expression: _expression.isEmpty ? '0' : _expression,
                    result: _result,
                    message: _message,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  flex: 58,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final spacing = constraints.maxWidth < 360 ? 9.0 : 12.0;
                      final keyWidth =
                          (constraints.maxWidth - (spacing * 3)) / 4;
                      final keyHeight =
                          (constraints.maxHeight - (spacing * 4)) / 5;
                      return GridView.builder(
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _keyLabels.length,
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: spacing,
                          mainAxisSpacing: spacing,
                          childAspectRatio: keyWidth / keyHeight,
                        ),
                        itemBuilder: (context, index) {
                          final label = _keyLabels[index];
                          return _CalculatorKey(
                            label: label,
                            tone: _toneFor(label),
                            onPressed: () => _onKeyPressed(label),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CalculatorHeader extends StatelessWidget {
  const _CalculatorHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0x33927CFF),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.calculate_rounded,
            color: _accentColor,
            size: 25,
          ),
        ),
        const SizedBox(width: 13),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'CALCULATOR',
                style: TextStyle(
                  color: Color(0xFFF4F3FA),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.6,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Quick math, clear mind',
                style: TextStyle(
                  color: Color(0xFF9698A7),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0x14FFFFFF),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: const Color(0x18FFFFFF)),
          ),
          child: const Text(
            'STANDARD',
            style: TextStyle(
              color: Color(0xFFB9BBC8),
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
          ),
        ),
      ],
    );
  }
}

class _DisplayPanel extends StatelessWidget {
  const _DisplayPanel({
    required this.expression,
    required this.result,
    required this.message,
  });

  final String expression;
  final String result;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
      decoration: BoxDecoration(
        color: _panelColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0x18FFFFFF)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x25000000),
            blurRadius: 28,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Text(
                'EXPRESSION',
                style: TextStyle(
                  color: Color(0xFF8E91A0),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.3,
                ),
              ),
              const Spacer(),
              if (message != null)
                Flexible(
                  child: Text(
                    message!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: Color(0xFFFF8D9A),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              else
                const Text(
                  'LIVE PREVIEW',
                  style: TextStyle(
                    color: Color(0xFF6F7280),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  expression,
                  key: const ValueKey<String>('expression-display'),
                  maxLines: 1,
                  style: const TextStyle(
                    color: Color(0xFFF3F2F8),
                    fontSize: 42,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ),
          ),
          Container(height: 1, color: const Color(0x17FFFFFF)),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              const Text(
                'RESULT',
                style: TextStyle(
                  color: Color(0xFF858895),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 160),
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                      child: Text(
                        result,
                        key: ValueKey<String>('result-$result'),
                        style: const TextStyle(
                          color: _mintColor,
                          fontSize: 30,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CalculatorKey extends StatelessWidget {
  const _CalculatorKey({
    required this.label,
    required this.tone,
    required this.onPressed,
  });

  final String label;
  final _KeyTone tone;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = switch (tone) {
      _KeyTone.number => const Color(0xFF1B1D27),
      _KeyTone.utility => const Color(0xFF292B36),
      _KeyTone.operator => const Color(0xFF242331),
      _KeyTone.equals => _accentColor,
    };
    final foregroundColor = switch (tone) {
      _KeyTone.number => const Color(0xFFF2F1F7),
      _KeyTone.utility => const Color(0xFFD2D3DC),
      _KeyTone.operator => _accentColor,
      _KeyTone.equals => const Color(0xFFFFFFFF),
    };
    final radius = BorderRadius.circular(20);
    final semanticLabel = switch (label) {
      'AC' => 'Clear',
      '⌫' => 'Delete last character',
      '÷' => 'Divide',
      '×' => 'Multiply',
      '−' => 'Minus',
      '+' => 'Plus',
      '=' => 'Equals',
      _ => label,
    };

    return Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        color: backgroundColor,
        elevation: tone == _KeyTone.equals ? 4 : 0,
        shadowColor: const Color(0x66927CFF),
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(
            color: tone == _KeyTone.number
                ? const Color(0x12FFFFFF)
                : const Color(0x00000000),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: radius,
          onTap: onPressed,
          child: Center(
            child: label == '⌫'
                ? Icon(
                    Icons.backspace_outlined,
                    color: foregroundColor,
                    size: 20,
                  )
                : Text(
                    label,
                    style: TextStyle(
                      color: foregroundColor,
                      fontSize: switch (tone) {
                        _KeyTone.utility => 16,
                        _KeyTone.equals => 26,
                        _KeyTone.number when label == '00' => 19,
                        _ => 23,
                      },
                      fontWeight: tone == _KeyTone.number
                          ? FontWeight.w500
                          : FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

enum _KeyTone { number, utility, operator, equals }

_KeyTone _toneFor(String label) {
  if (label == '=') return _KeyTone.equals;
  if (label == 'AC' || label == '⌫') return _KeyTone.utility;
  if (label == '%' || _isOperatorKey(label)) return _KeyTone.operator;
  return _KeyTone.number;
}

bool _isOperatorKey(String value) =>
    value == '+' || value == '−' || value == '×' || value == '÷';

bool _isDigitCharacter(String character) {
  final codeUnit = character.codeUnitAt(0);
  return codeUnit >= 48 && codeUnit <= 57;
}
