import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'calculator_engine.dart';

const _backgroundColor = Color(0xFF0B0C12);
const _panelColor = Color(0xFF151721);
const _accentColor = Color(0xFF927CFF);
const _mintColor = Color(0xFF8CE7D2);
const _supabaseUrl = String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: 'https://snirkcljtqpxoaixmwob.supabase.co',
);
const _supabaseAnonKey = String.fromEnvironment(
  'SUPABASE_ANON_KEY',
  defaultValue: 'sb_publishable_55Wd2TAcM_iImHNn2tAPUw_mbrqA8zI',
);
const _mobileAuthRedirect = 'io.supabase.calculator://login-callback/';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: _supabaseUrl, anonKey: _supabaseAnonKey);
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sine · Scientific Calculator',
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
      home: const _AuthGate(),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final auth = Supabase.instance.client.auth;
    return StreamBuilder<AuthState>(
      stream: auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = snapshot.data?.session ?? auth.currentSession;
        if (session == null) return const _SignInPage();
        return CalculatorPage(
          userEmail: session.user.email,
          onSignOut: () => Supabase.instance.client.auth.signOut(),
        );
      },
    );
  }
}

class _SignInPage extends StatefulWidget {
  const _SignInPage();

  @override
  State<_SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<_SignInPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  bool _creatingAccount = false;
  bool _obscurePassword = true;
  String? _error;
  String? _notice;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || !email.contains('@')) {
      setState(() {
        _error = 'Enter a valid email address.';
        _notice = null;
      });
      return;
    }
    if (password.length < 6) {
      setState(() {
        _error = 'Your password must be at least 6 characters.';
        _notice = null;
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _notice = null;
    });
    try {
      final auth = Supabase.instance.client.auth;
      if (_creatingAccount) {
        final response = await auth.signUp(
          email: email,
          password: password,
          emailRedirectTo: kIsWeb ? Uri.base.origin : _mobileAuthRedirect,
        );
        if (response.session == null && mounted) {
          setState(() {
            _notice = 'Check your email for a confirmation link, then sign in.';
            _creatingAccount = false;
            _passwordController.clear();
          });
        }
      } else {
        await auth.signInWithPassword(email: email, password: password);
      }
    } on AuthException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (_) {
      if (mounted) setState(() => _error = 'Could not complete your request. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[Color(0xFF19172A), _backgroundColor, Color(0xFF0A1114)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: _panelColor,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: const Color(0x20FFFFFF)),
                    boxShadow: const <BoxShadow>[
                      BoxShadow(color: Color(0x35000000), blurRadius: 36, offset: Offset(0, 16)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Center(
                        child: Container(
                          width: 62,
                          height: 62,
                          decoration: BoxDecoration(
                            color: const Color(0x33927CFF),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(Icons.functions_rounded, color: _accentColor, size: 32),
                        ),
                      ),
                      const SizedBox(height: 25),
                      const Text(
                        'Sine',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, letterSpacing: -1),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Your scientific workspace,\nready when you are.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xFF9A9CAC), height: 1.5, fontSize: 15),
                      ),
                      const SizedBox(height: 28),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const <String>[AutofillHints.email],
                        textInputAction: TextInputAction.next,
                        decoration: _authInputDecoration('Email address', Icons.email_outlined),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        autofillHints: <String>[_creatingAccount ? AutofillHints.newPassword : AutofillHints.password],
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _submit(),
                        decoration: _authInputDecoration('Password', Icons.lock_outline_rounded).copyWith(
                          suffixIcon: IconButton(
                            tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                          ),
                        ),
                      ),
                      if (_error != null) ...<Widget>[
                        const SizedBox(height: 14),
                        Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFFFF9AA7), fontSize: 12)),
                      ],
                      if (_notice != null) ...<Widget>[
                        const SizedBox(height: 14),
                        Text(_notice!, textAlign: TextAlign.center, style: const TextStyle(color: _mintColor, fontSize: 12)),
                      ],
                      const SizedBox(height: 18),
                      FilledButton(
                        onPressed: _loading ? null : _submit,
                        style: FilledButton.styleFrom(
                          backgroundColor: _accentColor,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(54),
                          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: _loading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : Text(_creatingAccount ? 'Create account' : 'Sign in'),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: _loading
                            ? null
                            : () => setState(() {
                                  _creatingAccount = !_creatingAccount;
                                  _error = null;
                                  _notice = null;
                                }),
                        child: Text(_creatingAccount ? 'Already have an account? Sign in' : 'New here? Create an account'),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Your account is securely managed by Supabase.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xFF777A8A), fontSize: 12),
                      ),

                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

InputDecoration _authInputDecoration(String label, IconData icon) => InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20),
      filled: true,
      fillColor: const Color(0xFF1C1E29),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0x1FFFFFFF)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: _accentColor),
      ),
    );

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key, this.userEmail, this.onSignOut});

  final String? userEmail;
  final VoidCallback? onSignOut;

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  static const _scientificKeyLabels = <String>[
    'sin', 'cos', 'tan', 'ln', 'log',
    '√', 'x²', 'xʸ', 'π', 'e',
    '(', ')', '!', 'AC', '⌫',
    '7', '8', '9', '÷', '%',
    '4', '5', '6', '×', '−',
    '1', '2', '3', '+', '=',
    '00', '0', '.', 'Ans', 'DEG',
  ];
  static const _standardKeyLabels = <String>[
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
  bool _degrees = true;
  bool _scientificMode = true;

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
      if (key == 'DEG') {
        _degrees = !_degrees;
        _refreshPreview();
        return;
      }
      if (key == 'Ans') {
        if (_justEvaluated) _expression = '';
        _expression += _result;
        _justEvaluated = false;
        _refreshPreview();
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
      if (key == 'π' || key == 'e') {
        _appendConstant(key);
        return;
      }
      if (key == 'sin' || key == 'cos' || key == 'tan' || key == 'ln' || key == 'log') {
        _appendFunction(key);
        return;
      }
      if (key == '√') {
        _appendFunction('sqrt');
        return;
      }
      if (key == 'x²') {
        _expression += '^2';
        _refreshPreview();
        return;
      }
      if (key == 'xʸ') {
        _appendOperator('^');
        return;
      }
      if (key == '!') {
        if (_expression.isNotEmpty && !_isOperatorKey(_lastCharacter)) {
          _expression += '!';
          _refreshPreview();
        }
        return;
      }
      if (key == '(') {
        if (_justEvaluated) _expression = '';
        _expression += _endsWithValue ? '×(' : '(';
        _justEvaluated = false;
        _refreshPreview();
        return;
      }
      if (key == ')') {
        if (_expression.isNotEmpty && _endsWithValue) {
          _expression += ')';
          _refreshPreview();
        }
        return;
      }
      _appendDigits(key);
    });
  }

  String get _lastCharacter => _expression.isEmpty ? '' : _expression[_expression.length - 1];
  bool get _endsWithValue => _lastCharacter.isNotEmpty &&
      (!_isOperatorKey(_lastCharacter) && _lastCharacter != '(' && _lastCharacter != '.');

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
    if (_expression.endsWith('%') ||
        _expression.endsWith(')') ||
        _expression.endsWith('!') ||
        _expression.endsWith('π') ||
        _expression.endsWith('e')) {
      _expression += '×';
    }
    _expression += digits;
    _refreshPreview();
  }

  void _appendConstant(String value) {
    if (_justEvaluated) _expression = '';
    if (_endsWithValue) _expression += '×';
    _expression += value;
    _justEvaluated = false;
    _refreshPreview();
  }

  void _appendFunction(String name) {
    if (_justEvaluated) _expression = '';
    if (_endsWithValue) _expression += '×';
    _expression += '$name(';
    _justEvaluated = false;
    _refreshPreview();
  }

  void _appendDecimal() {
    if (_justEvaluated) {
      _expression = '';
      _justEvaluated = false;
    }
    final token = _currentNumberToken();
    if (token.contains('.') || token.contains('e') || token.contains('E')) return;
    if (_expression.isEmpty || _isOperatorKey(_lastCharacter) || _lastCharacter == '(') {
      _expression += '0';
    }
    _expression += '.';
    _refreshPreview();
  }

  void _appendOperator(String operator) {
    _justEvaluated = false;
    if (_expression.isEmpty) {
      if (operator == '−' || operator == '-') _expression = operator;
      _refreshPreview();
      return;
    }
    if (_isOperatorKey(_lastCharacter)) {
      if (operator == '−' || operator == '-') {
        _expression += operator;
      } else {
        _expression = '${_expression.substring(0, _expression.length - 1)}$operator';
      }
    } else {
      _expression += operator;
    }
    _refreshPreview();
  }

  void _appendPercent() {
    if (_expression.isEmpty || !_endsWithValue || _expression.endsWith('%')) return;
    _justEvaluated = false;
    _expression += '%';
    _refreshPreview();
  }

  void _evaluate() {
    if (_expression.isEmpty) return;
    try {
      final answer = formatCalculatorResult(calculateExpression(_expression, degrees: _degrees));
      _expression = answer;
      _result = answer;
      _message = null;
      _justEvaluated = true;
    } on FormatException catch (error) {
      _message = error.message.toString().toLowerCase().contains('divide by zero')
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
      _result = formatCalculatorResult(calculateExpression(_expression, degrees: _degrees));
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
      } else if ((character == '+' || character == '-' || character == '−') &&
          start >= 2 && (_expression[start - 2] == 'e' || _expression[start - 2] == 'E')) {
        start -= 2;
      } else if (character == 'e' || character == 'E') {
        start--;
      } else {
        break;
      }
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
            colors: <Color>[Color(0xFF151522), _backgroundColor, Color(0xFF0A1114)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _CalculatorHeader(
                  userEmail: widget.userEmail,
                  onSignOut: widget.onSignOut,
                  scientificMode: _scientificMode,
                  onToggleMode: () => setState(() => _scientificMode = !_scientificMode),
                ),
                const SizedBox(height: 12),
                Expanded(
                  flex: 38,
                  child: _DisplayPanel(
                    expression: _expression.isEmpty ? '0' : _expression,
                    result: _result,
                    message: _message,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  flex: 62,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final labels = _scientificMode
                          ? _scientificKeyLabels
                          : _standardKeyLabels;
                      final columns = _scientificMode ? 5 : 4;
                      final rows = _scientificMode ? 7 : 5;
                      final spacing = _scientificMode ? 7.0 : 10.0;
                      final keyWidth =
                          (constraints.maxWidth - spacing * (columns - 1)) / columns;
                      final keyHeight =
                          (constraints.maxHeight - spacing * (rows - 1)) / rows;
                      return GridView.builder(
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: labels.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          crossAxisSpacing: spacing,
                          mainAxisSpacing: spacing,
                          childAspectRatio: keyWidth / keyHeight,
                        ),
                        itemBuilder: (context, index) {
                          final label = labels[index];
                          return _CalculatorKey(
                            label: label,
                            tone: _toneFor(label),
                            active: label == 'DEG' && _degrees,
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
  const _CalculatorHeader({
    required this.scientificMode,
    required this.onToggleMode,
    this.userEmail,
    this.onSignOut,
  });

  final bool scientificMode;
  final VoidCallback onToggleMode;
  final String? userEmail;
  final VoidCallback? onSignOut;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(color: const Color(0x33927CFF), borderRadius: BorderRadius.circular(14)),
          child: const Icon(Icons.functions_rounded, color: _accentColor, size: 23),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text('SINE', style: TextStyle(color: Color(0xFFF4F3FA), fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 1.7)),
              const SizedBox(height: 2),
              Text(
                scientificMode ? 'Scientific calculator' : 'Standard calculator',
                style: const TextStyle(color: Color(0xFF9698A7), fontSize: 11),
              ),
            ],
          ),
        ),
        Tooltip(
          message: 'Switch to ${scientificMode ? 'standard' : 'scientific'} mode',
          child: TextButton.icon(
            key: const ValueKey<String>('calculator-mode-toggle'),
            onPressed: onToggleMode,
            icon: Icon(scientificMode ? Icons.calculate_outlined : Icons.science_outlined, size: 17),
            label: Text(scientificMode ? 'SCI' : 'STD'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFC8BFFF),
              padding: const EdgeInsets.symmetric(horizontal: 9),
              minimumSize: const Size(0, 40),
              textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.7),
            ),
          ),
        ),
        if (userEmail != null)
          IconButton(
            tooltip: 'Sign out${userEmail!.isEmpty ? '' : ' · $userEmail'}',
            onPressed: onSignOut,
            icon: const Icon(Icons.logout_rounded, size: 19, color: Color(0xFFB9BBC8)),
          ),
      ],
    );
  }
}

class _DisplayPanel extends StatelessWidget {
  const _DisplayPanel({required this.expression, required this.result, required this.message});

  final String expression;
  final String result;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
      decoration: BoxDecoration(
        color: _panelColor,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: const Color(0x18FFFFFF)),
        boxShadow: const <BoxShadow>[BoxShadow(color: Color(0x25000000), blurRadius: 28, offset: Offset(0, 12))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Text('EXPRESSION', style: TextStyle(color: Color(0xFF8E91A0), fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
              const Spacer(),
              if (message != null)
                Flexible(child: Text(message!, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.right, style: const TextStyle(color: Color(0xFFFF8D9A), fontSize: 10, fontWeight: FontWeight.w600)))
              else
                const Text('LIVE PREVIEW', style: TextStyle(color: Color(0xFF6F7280), fontSize: 9, fontWeight: FontWeight.w600, letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(expression, key: const ValueKey<String>('expression-display'), maxLines: 1, style: const TextStyle(color: Color(0xFFF3F2F8), fontSize: 37, fontWeight: FontWeight.w400, letterSpacing: 0.3)),
              ),
            ),
          ),
          Container(height: 1, color: const Color(0x17FFFFFF)),
          const SizedBox(height: 9),
          Row(
            children: <Widget>[
              const Text('RESULT', style: TextStyle(color: Color(0xFF858895), fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
              const SizedBox(width: 12),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 160),
                      child: Text(result, key: ValueKey<String>('result-$result'), style: const TextStyle(color: _mintColor, fontSize: 28, fontWeight: FontWeight.w600)),
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

enum _KeyTone { number, utility, scientific, operator, equals }

class _CalculatorKey extends StatelessWidget {
  const _CalculatorKey({required this.label, required this.tone, required this.onPressed, this.active = false});

  final String label;
  final _KeyTone tone;
  final VoidCallback onPressed;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = switch (tone) {
      _KeyTone.number => const Color(0xFF1B1D27),
      _KeyTone.utility => const Color(0xFF292B36),
      _KeyTone.scientific => active ? const Color(0xFF38324F) : const Color(0xFF20202D),
      _KeyTone.operator => const Color(0xFF242331),
      _KeyTone.equals => _accentColor,
    };
    final foregroundColor = switch (tone) {
      _KeyTone.number => const Color(0xFFF2F1F7),
      _KeyTone.utility => const Color(0xFFD2D3DC),
      _KeyTone.scientific => active ? _mintColor : const Color(0xFFC8BFFF),
      _KeyTone.operator => _accentColor,
      _KeyTone.equals => Colors.white,
    };
    final fontSize = tone == _KeyTone.scientific ? 13.0 : tone == _KeyTone.equals ? 22.0 : 19.0;
    final radius = BorderRadius.circular(15);
    final semantics = switch (label) {
      '⌫' => 'Delete last character',
      '÷' => 'Divide',
      '×' => 'Multiply',
      '−' => 'Minus',
      'xʸ' => 'Power',
      '√' => 'Square root',
      'π' => 'Pi',
      'Ans' => 'Previous answer',
      'DEG' => 'Toggle degrees and radians',
      _ => label,
    };
    return Semantics(
      button: true,
      label: semantics,
      child: Material(
        color: backgroundColor,
        elevation: tone == _KeyTone.equals ? 3 : 0,
        shadowColor: const Color(0x66927CFF),
        shape: RoundedRectangleBorder(borderRadius: radius, side: BorderSide(color: tone == _KeyTone.number ? const Color(0x12FFFFFF) : Colors.transparent)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: radius,
          onTap: onPressed,
          child: Center(
            child: label == '⌫'
                ? Icon(Icons.backspace_outlined, color: foregroundColor, size: 17)
                : Text(label == 'DEG' && !active ? 'RAD' : label, style: TextStyle(color: foregroundColor, fontSize: fontSize, fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }
}

_KeyTone _toneFor(String label) {
  if (label == '=') return _KeyTone.equals;
  if (label == 'AC' || label == '⌫') return _KeyTone.utility;
  if (label == '%' || _isOperatorKey(label)) return _KeyTone.operator;
  if (_isDigitCharacter(label.isEmpty ? 'a' : label[0]) || label == '00' || label == '.' || label == 'Ans' || label == '(' || label == ')') return _KeyTone.number;
  return _KeyTone.scientific;
}

bool _isOperatorKey(String value) => value == '+' || value == '−' || value == '×' || value == '÷' || value == '^' || value == '-';

bool _isDigitCharacter(String character) {
  final codeUnit = character.codeUnitAt(0);
  return codeUnit >= 48 && codeUnit <= 57;
}
