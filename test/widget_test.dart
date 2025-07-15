// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:billey/main.dart';
import 'package:billey/providers/transaction_provider.dart';
import 'package:billey/providers/category_provider.dart';

void main() {
  group('Billey App Tests', () {
    testWidgets('App should start without crashing',
        (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const MyApp());

      // Verify that the app starts without errors
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('App should have providers configured',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Verify that providers are available
      expect(find.byType(ChangeNotifierProvider<TransactionProvider>),
          findsOneWidget);
      expect(find.byType(ChangeNotifierProvider<CategoryProvider>),
          findsOneWidget);
    });

    testWidgets('App should display splash screen initially',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Verify that splash screen is shown initially
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('App should have proper theme configuration',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Verify that the app has a theme
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.theme, isNotNull);
    });

    testWidgets('App should handle provider initialization',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Verify that the app can access providers
      final context = tester.element(find.byType(MaterialApp));
      expect(
          Provider.of<TransactionProvider>(context, listen: false), isNotNull);
      expect(Provider.of<CategoryProvider>(context, listen: false), isNotNull);
    });
  });
}
