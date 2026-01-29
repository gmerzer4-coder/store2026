// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:store2026/main.dart';

void main() {
  testWidgets('Splash shows then navigates to Home', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(firebaseEnabled: false));

    // Splash is first; image asset is used but we can check the route replacement
    expect(find.byType(MaterialApp), findsOneWidget);

    // wait for splash timer (2s)
    await tester.pump(const Duration(milliseconds: 1900));
    await tester.pumpAndSettle();

    // Home page should be visible (app bar title 'المتجر')
    expect(find.text('المتجر'), findsOneWidget);
  });
}
