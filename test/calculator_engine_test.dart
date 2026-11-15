import 'package:calculator/calculator_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('calculateExpression', () {
    test('uses standard operator precedence', () {
      expect(calculateExpression('2 + 3 × 4'), 14);
    });

    test('supports parentheses and unary minus', () {
      expect(calculateExpression('(2 + 3) × −4'), -20);
    });

    test('supports decimals and scientific notation', () {
      expect(calculateExpression('.5 + 1e-2'), closeTo(0.51, 1e-12));
    });

    test('treats percent as a postfix percentage', () {
      expect(calculateExpression('200 × 5%'), 10);
    });

    test('rejects division by zero', () {
      expect(
        () => calculateExpression('4 ÷ 0'),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects incomplete expressions', () {
      expect(
        () => calculateExpression('7 +'),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
