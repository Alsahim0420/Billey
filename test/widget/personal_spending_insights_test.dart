import 'package:billey/l10n/app_localizations.dart';
import 'package:billey/models/transaction.dart';
import 'package:billey/providers/currency_provider.dart';
import 'package:billey/providers/transaction_provider.dart';
import 'package:billey/screens/spending_insights_screen.dart';
import 'package:billey/theme/billey_theme_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets(
      'only partner expenses shows zero personal spending without demo amounts',
      (tester) async {
    final transactions = TransactionProvider()
      ..setTestTransactions([
        TransactionModel(
            id: 'partner',
            title: 'Pago de la otra persona',
            amount: 1234567,
            date: DateTime.now(),
            type: TransactionType.gasto,
            category: TransactionCategory.food,
            ownerId: 'partner'),
      ]);
    final currency = CurrencyProvider();
    await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: transactions),
          ChangeNotifierProvider.value(value: currency),
        ],
        child: MaterialApp(
            locale: const Locale('es'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (_, child) => BilleyThemeBinder(child: child!),
            home: const SpendingInsightsScreen())));
    await tester.pumpAndSettle();
    expect(find.text(currency.format(0)), findsWidgets);
    expect(find.text(currency.format(1234567)), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
