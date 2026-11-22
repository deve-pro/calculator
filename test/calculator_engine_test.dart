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

    test('supports scientific functions in degrees and radians', () {
      expect(calculateExpression('sin(30)', degrees: true), closeTo(0.5, 1e-12));
      expect(calculateExpression('cos(0)'), 1);
      expect(calculateExpression('ln(e)'), closeTo(1, 1e-12));
      expect(calculateExpression('log(1000)'), closeTo(3, 1e-12));
      expect(calculateExpression('sqrt(81)'), 9);
    });

    test('supports powers, constants, and factorial', () {
      expect(calculateExpression('2^3^2'), 512);
      expect(calculateExpression('π × 2'), closeTo(6.283185307179586, 1e-12));
      expect(calculateExpression('5!'), 120);
    });

    test('rejects invalid factorial values and incomplete expressions', () {
      expect(() => calculateExpression('2.5!'), throwsA(isA<FormatException>()));
      expect(
        () => calculateExpression('7 +'),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
