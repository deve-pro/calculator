import 'package:calculator/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('the keypad evaluates a basic expression', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: CalculatorPage()));

    await tester.tap(find.text('2').last);
    await tester.tap(find.text('+').last);
    await tester.tap(find.text('2').last);
    await tester.tap(find.text('=').last);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('result-4')), findsOneWidget);
  });

  testWidgets('mode switch shows the standard keypad and calculates normally', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: CalculatorPage()));
    await tester.tap(find.byKey(const ValueKey<String>('calculator-mode-toggle')));
    await tester.pumpAndSettle();

    expect(find.text('STD'), findsOneWidget);
    expect(find.text('sin'), findsNothing);
    await tester.tap(find.text('2'));
    await tester.tap(find.text('+'));
    await tester.tap(find.text('3'));
    await tester.tap(find.text('='));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('result-5')), findsOneWidget);
  });

  testWidgets('scientific keypad evaluates a trigonometric function', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: CalculatorPage()));
    await tester.tap(find.text('sin'));
    await tester.tap(find.text('0'));
    await tester.tap(find.text(')'));
    await tester.tap(find.text('='));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('result-0')), findsOneWidget);
  });
}
