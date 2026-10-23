import 'package:billey/l10n/app_localizations.dart';
import 'package:billey/models/category_budget.dart';
import 'package:billey/providers/budget_provider.dart';
import 'package:billey/providers/category_provider.dart';
import 'package:billey/providers/currency_provider.dart';
import 'package:billey/providers/transaction_provider.dart';
import 'package:billey/screens/category_budgets_screen.dart';
import 'package:billey/services/firestore_budget_service.dart';
import 'package:billey/theme/billey_theme_scope.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _Auth extends Fake implements FirebaseAuth {}

class _Db extends Fake implements FirebaseFirestore {}

class _Service extends FirestoreBudgetService {
  _Service() : super(auth: _Auth(), firestore: _Db());
}

class _Budgets extends BudgetProvider {
  _Budgets() : super(service: _Service()) {
    userId = 'me';
    loaded = true;
  }
  CategoryBudget? saved;
  @override
  Future<void> save(String owner, CategoryBudget budget) async {
    expect(owner, 'me');
    saved = budget;
  }
}

void main() {
  testWidgets('category sheet saves a monthly limit in selected currency',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final budgets = _Budgets();
    await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider<BudgetProvider>.value(value: budgets),
          ChangeNotifierProvider(create: (_) => CategoryProvider()),
          ChangeNotifierProvider(create: (_) => CurrencyProvider()),
          ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ],
        child: MaterialApp(
            locale: const Locale('es'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (_, child) => BilleyThemeBinder(child: child!),
            home: const CategoryBudgetsScreen())));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Comida'), 200);
    await tester.tap(find.text('Comida'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), '250000');
    tester.testTextInput.hide();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Guardar'));
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    expect(budgets.saved!.limit, 250000);
    expect(budgets.saved!.categoryId, 'food');
    expect(budgets.saved!.currency, 'COP');
    expect(budgets.saved!.month, CategoryBudget.monthKey(DateTime.now()));
    expect(find.byType(TextFormField), findsNothing);
  });
}
