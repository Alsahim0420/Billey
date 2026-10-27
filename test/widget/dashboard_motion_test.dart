import 'package:shared_preferences/shared_preferences.dart';
import 'package:billey/l10n/app_localizations.dart';
import 'package:billey/models/category.dart';
import 'package:billey/models/category_budget.dart';
import 'package:billey/models/financial_cycle.dart';
import 'package:billey/models/transaction.dart';
import 'package:billey/providers/amount_visibility_provider.dart';
import 'package:billey/providers/budget_provider.dart';
import 'package:billey/providers/category_provider.dart';
import 'package:billey/providers/couple_link_provider.dart';
import 'package:billey/providers/currency_provider.dart';
import 'package:billey/providers/income_distribution_provider.dart';
import 'package:billey/providers/profile_provider.dart';
import 'package:billey/providers/transaction_provider.dart';
import 'package:billey/screens/dashboard_screen.dart';
import 'package:billey/theme/billey_theme_scope.dart';
import 'package:billey/widgets/budget_spend_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _Profile extends Fake with ChangeNotifier implements ProfileProvider {
  @override
  bool get hasAvatar => false;
  @override
  String greetingForHour(int hour, AppLocalizations l10n) => 'Hola, Pablo';
}

class _Couple extends Fake with ChangeNotifier implements CoupleLinkProvider {
  @override
  bool get isLinked => false;
}

class _Categories extends CategoryProvider {
  @override
  List<CategoryModel> get allCategories => CategoryModel.getDefaultCategories();
}

class _Budgets extends Fake with ChangeNotifier implements BudgetProvider {
  @override
  String? get userId => 'me';
  @override
  bool get loaded => true;
  @override
  bool get hasError => false;
  @override
  List<CategoryBudget> effectiveForMonth(
    DateTime month,
    String currency, {
    required IncomeDistributionProvider? distribution,
    FinancialCycle cycle = const FinancialCycle(),
    required Iterable<CategoryModel> categories,
    required Iterable<TransactionModel> transactions,
  }) =>
      [
        CategoryBudget(
            month: CategoryBudget.monthKey(month),
            categoryId: 'food',
            categoryName: 'Comida',
            currency: currency,
            limit: 1000)
      ];
}

void main() {
  testWidgets(
      'Home paints immediately and totals and bars move on intermediate frames',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(430, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final transactions = TransactionProvider()
      ..setTestTransactions([
        TransactionModel(
            id: 'income',
            title: 'Pago',
            amount: 5000,
            date: DateTime.now(),
            type: TransactionType.ingreso,
            category: TransactionCategory.other),
        TransactionModel(
            id: 'expense',
            title: 'Mercado',
            amount: 1000,
            date: DateTime.now(),
            type: TransactionType.gasto,
            category: TransactionCategory.food),
      ]);
    final currency = CurrencyProvider();
    await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: transactions),
          ChangeNotifierProvider.value(value: currency),
          ChangeNotifierProvider(create: (_) => AmountVisibilityProvider()),
          ChangeNotifierProvider<CategoryProvider>(
              create: (_) => _Categories()),
          ChangeNotifierProvider<BudgetProvider>(create: (_) => _Budgets()),
          ChangeNotifierProvider<ProfileProvider>(create: (_) => _Profile()),
          ChangeNotifierProvider<CoupleLinkProvider>(create: (_) => _Couple()),
        ],
        child: MaterialApp(
            locale: const Locale('es'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (_, child) => BilleyThemeBinder(child: child!),
            home: const DashboardScreen())));
    expect(find.text('Hola, Pablo'), findsOneWidget);
    expect(tester.takeException(), isNull);
    var plot = tester.widget<BudgetSpendBar>(find.byType(BudgetSpendBar).first);
    expect(plot.animation!.value, 0);
    expect(find.text(currency.format(4000)), findsNothing);
    await tester.pump(const Duration(milliseconds: 250));
    plot = tester.widget<BudgetSpendBar>(find.byType(BudgetSpendBar).first);
    expect(plot.animation!.value, greaterThan(0));
    expect(plot.animation!.value, lessThan(1));
    expect(find.text(currency.format(4000)), findsNothing);
    final partialBalance = 4000 * Curves.easeOutCubic.transform(250 / 900);
    expect(find.text(currency.format(partialBalance)), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text(currency.format(4000)), findsOneWidget);
    expect(plot.animation!.value, 1);
    expect(tester.takeException(), isNull);
    final visibility = tester
        .element(find.byType(DashboardScreen))
        .read<AmountVisibilityProvider>();
    final existingAnimation = plot.animation;
    await visibility.toggle();
    await tester.pumpAndSettle();
    expect(find.byType(BudgetSpendBar), findsOneWidget);
    expect(tester.widget<BudgetSpendBar>(find.byType(BudgetSpendBar)).animation,
        same(existingAnimation));
    expect(find.text(currency.format(4000)), findsNothing);
    expect(find.text(currency.format(1000)), findsNothing);
    for (final tooltip in tester.widgetList<Tooltip>(find.byType(Tooltip))) {
      expect(tooltip.message ?? '', isNot(contains(currency.format(1000))));
    }
    await visibility.toggle();
    await tester.pumpAndSettle();
    expect(find.text(currency.format(4000)), findsOneWidget);
    expect(tester.widget<BudgetSpendBar>(find.byType(BudgetSpendBar)).animation,
        same(existingAnimation));
    // Reproduce the actual splash -> Home pushReplacement fade, rather than
    // testing only a Dashboard mounted directly as MaterialApp.home.
    Navigator.of(tester.element(find.byType(DashboardScreen))).pushReplacement(
        PageRouteBuilder<void>(
            transitionDuration: Duration.zero,
            pageBuilder: (_, animation, secondary) =>
                const Scaffold(body: Text('Splash de prueba'))));
    await tester.pumpAndSettle();
    late PageRouteBuilder<void> entranceRoute;
    Navigator.of(tester.element(find.text('Splash de prueba'))).pushReplacement(
        entranceRoute = PageRouteBuilder<void>(
            transitionDuration: const Duration(milliseconds: 300),
            pageBuilder: (_, animation, secondary) => const DashboardScreen(),
            transitionsBuilder: (_, animation, secondary, child) =>
                FadeTransition(opacity: animation, child: child)));
    await tester.pump(); // Hero preparation lays out the route offstage.
    await tester.pump(); // Start the actual entrance ticker.
    await tester.pump(const Duration(milliseconds: 200));
    plot = tester.widget<BudgetSpendBar>(find.byType(BudgetSpendBar).first);
    expect(plot.animation!.value, 0);
    expect(find.text(currency.format(4000)), findsNothing);
    expect(find.text('Hola, Pablo'), findsOneWidget);
    for (var frame = 0;
        frame < 40 &&
            (entranceRoute.offstage ||
                entranceRoute.animation!.status != AnimationStatus.completed);
        frame++) {
      await tester.pump(const Duration(milliseconds: 16));
      expect(plot.animation!.value, 0);
    }
    expect(entranceRoute.offstage, false);
    expect(entranceRoute.animation!.status, AnimationStatus.completed);
    await tester.pump(); // First ticker frame after the route has entered.
    await tester.pump(const Duration(milliseconds: 250));
    expect(plot.animation!.value, greaterThan(0));
    expect(plot.animation!.value, lessThan(1));
    expect(find.text(currency.format(partialBalance)), findsOneWidget);
    await tester.pumpAndSettle();
    expect(plot.animation!.value, 1);
    expect(find.text(currency.format(4000)), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
