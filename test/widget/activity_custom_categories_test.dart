import 'package:shared_preferences/shared_preferences.dart';
import 'package:billey/providers/financial_cycle_provider.dart';
import 'package:billey/l10n/app_localizations.dart';
import 'package:billey/models/category.dart';
import 'package:billey/models/transaction.dart';
import 'package:billey/providers/category_provider.dart';
import 'package:billey/providers/couple_link_provider.dart';
import 'package:billey/providers/currency_provider.dart';
import 'package:billey/providers/profile_provider.dart';
import 'package:billey/providers/transaction_provider.dart';
import 'package:billey/screens/enhanced_transaction_list_screen.dart';
import 'package:billey/theme/billey_theme_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _Categories extends CategoryProvider {
  final investment = CategoryModel(
      id: 'investment_custom',
      name: 'Inversión',
      iconCodePoint: Icons.account_balance.codePoint,
      colorValue: Colors.blue.toARGB32());
  @override
  List<CategoryModel> get allCategories =>
      [...CategoryModel.getDefaultCategories(), investment];
}

class _Couple extends Fake with ChangeNotifier implements CoupleLinkProvider {
  @override
  bool get isLinked => false;
}

class _Profile extends Fake with ChangeNotifier implements ProfileProvider {}

void main() {
  testWidgets(
      'activity displays and searches the real custom category and icon',
      (tester) async {
    SharedPreferences.setMockInitialValues({'financial_cycle_start_me': 25});
    final cycle = FinancialCycleProvider();
    await cycle.bindUser('me');
    final period = cycle.cycle.containing(DateTime.now());
    final transactions = TransactionProvider()
      ..setTestTransactions([
        TransactionModel(
            id: 'partner-income',
            title: 'Ingreso compartido de pareja',
            amount: 7000,
            date: period.start,
            type: TransactionType.ingreso,
            category: TransactionCategory.other,
            ownerId: 'partner'),
        TransactionModel(
            id: 'old-income',
            title: 'Ingreso anterior al ciclo',
            amount: 9000,
            date: period.start.subtract(const Duration(days: 1)),
            type: TransactionType.ingreso,
            category: TransactionCategory.other),
        TransactionModel(
            id: 'current-income',
            title: 'Ingreso en inicio del ciclo',
            amount: 1000,
            date: period.start,
            type: TransactionType.ingreso,
            category: TransactionCategory.other),
        TransactionModel(
            id: 'etf',
            title: 'Compra ETF',
            amount: 100,
            date: DateTime.now(),
            type: TransactionType.gasto,
            category: TransactionCategory.other,
            categoryId: 'investment_custom'),
        TransactionModel(
            id: 'food',
            title: 'Mercado',
            amount: 50,
            date: DateTime.now(),
            type: TransactionType.gasto,
            category: TransactionCategory.food),
      ]);
    await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: transactions),
          ChangeNotifierProvider.value(value: cycle),
          ChangeNotifierProvider<CategoryProvider>(
              create: (_) => _Categories()),
          ChangeNotifierProvider(create: (_) => CurrencyProvider()),
          ChangeNotifierProvider<CoupleLinkProvider>(create: (_) => _Couple()),
          ChangeNotifierProvider<ProfileProvider>(create: (_) => _Profile()),
        ],
        child: MaterialApp(
            locale: const Locale('es'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (_, child) => BilleyThemeBinder(child: child!),
            home: const EnhancedTransactionListScreen())));
    await tester.pumpAndSettle();
    expect(find.textContaining('Inversión'), findsOneWidget);
    expect(
        tester
            .widget<Icon>(find.byIcon(Icons.account_balance))
            .color
            ?.toARGB32(),
        Colors.blue.toARGB32());
    expect(find.textContaining('Tus ingresos:').evaluate().single.widget,
        isA<Text>());
    await tester.tap(find.text('Este ciclo'));
    await tester.pumpAndSettle();
    final totals =
        tester.widget<Text>(find.textContaining('Tus ingresos:')).data!;
    expect(totals, contains('1.000'));
    expect(totals, isNot(contains('10.000')));
    await tester.enterText(find.byType(TextField), 'Ingreso anterior al ciclo');
    await tester.pumpAndSettle();
    expect(
        find.byWidgetPredicate(
            (w) => w is Text && w.data == 'Ingreso anterior al ciclo'),
        findsNothing);
    await tester.tap(find.text('Todo el historial'));
    await tester.pumpAndSettle();
    expect(
        find.byWidgetPredicate(
            (w) => w is Text && w.data == 'Ingreso anterior al ciclo'),
        findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Inversión');
    await tester.pumpAndSettle();
    expect(find.text('Compra ETF'), findsOneWidget);
    expect(find.text('Mercado'), findsNothing);
    await tester.enterText(
        find.byType(TextField), 'Ingreso compartido de pareja');
    await tester.tap(find.text('Míos'));
    await tester.pumpAndSettle();
    final partnerTitle = find.byWidgetPredicate(
        (w) => w is Text && w.data == 'Ingreso compartido de pareja');
    expect(partnerTitle, findsNothing);
    await tester.tap(find.text('Compartidos conmigo'));
    await tester.pumpAndSettle();
    expect(partnerTitle, findsOneWidget);
    expect(
        tester.widget<Text>(find.textContaining('Ingresos compartidos:')).data,
        contains('7.000'));
    await tester.tap(find.text('Ambos'));
    await tester.pumpAndSettle();
    expect(partnerTitle, findsOneWidget);
    expect(tester.widget<Text>(find.textContaining('Tus ingresos:')).data,
        isNot(contains('7.000')));
    expect(tester.takeException(), isNull);
  });
}
