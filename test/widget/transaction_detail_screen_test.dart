import 'package:billey/database/data_base_helper.dart';
import 'package:billey/l10n/app_localizations.dart';
import 'package:billey/models/transaction.dart';
import 'package:billey/providers/category_provider.dart';
import 'package:billey/providers/currency_provider.dart';
import 'package:billey/providers/transaction_provider.dart';
import 'package:billey/screens/transaction_detail_screen.dart';
import 'package:billey/theme/billey_theme_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _Transactions extends TransactionProvider {
  _Transactions() : super.withDb(DatabaseHelper.instance);
  TransactionModel? saved;
  @override
  Future<void> editTransaction(TransactionModel transaction) async {
    saved = transaction;
  }
}

void main() {
  final original = TransactionModel(
    id: 'applepay_sample',
    title: 'Café',
    amount: 12500.50,
    date: DateTime(2026, 10, 22, 14, 30),
    type: TransactionType.gasto,
    category: TransactionCategory.food,
    categoryId: 'food',
    currencyCode: 'COP',
    description: 'Origen: Apple Pay/Atajos\nMoneda original: COP',
    sharedWith: const ['partner'],
  );

  Future<_Transactions> open(WidgetTester tester) async {
    final provider = _Transactions();
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider<TransactionProvider>.value(value: provider),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => CurrencyProvider()),
      ],
      child: MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (_, child) => BilleyThemeBinder(child: child!),
        home: Builder(
            builder: (context) => Scaffold(
                    body: TextButton(
                  onPressed: () =>
                      Navigator.of(context).push(MaterialPageRoute<void>(
                    builder: (_) =>
                        TransactionDetailScreen(transaction: original),
                  )),
                  child: const Text('Abrir'),
                ))),
      ),
    ));
    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();
    return provider;
  }

  testWidgets('manual edit preserves cents, source, sharing and original date',
      (tester) async {
    final provider = await open(tester);
    // No speech or distribution providers are supplied: detail needs neither.
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text('Notas y origen'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).first, 'Café editado');
    tester.testTextInput.hide();
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Guardar'), 250,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    final saved = provider.saved!;
    expect(saved.id, original.id);
    expect(saved.title, 'Café editado');
    expect(saved.amount, 12500.5);
    expect(saved.date, original.date);
    expect(saved.type, original.type);
    expect(saved.description, original.description);
    expect(saved.sharedWith, original.sharedWith);
    expect(saved.category, original.category);
    expect(saved.categoryId, original.categoryId);
    expect(saved.currencyCode, original.currencyCode);
  });

  testWidgets('invalid amount does not save', (tester) async {
    final provider = await open(tester);
    await tester.enterText(find.byType(TextFormField).at(1), '0');
    tester.testTextInput.hide();
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Guardar'), 250,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    expect(provider.saved, isNull);
    expect(find.text('Detalle de transacción'), findsOneWidget);
  });
}
