import 'package:calculator/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('the keypad evaluates a basic expression', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const CalculatorApp());

    await tester.tap(find.text('2').last);
    await tester.tap(find.text('+').last);
    await tester.tap(find.text('2').last);
    await tester.tap(find.text('=').last);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('result-4')), findsOneWidget);
  });
}
