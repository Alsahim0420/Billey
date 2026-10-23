import 'package:billey/l10n/app_localizations.dart';
import 'package:billey/models/category.dart';
import 'package:billey/models/transaction.dart';
import 'package:billey/providers/category_provider.dart';
import 'package:billey/providers/currency_provider.dart';
import 'package:billey/providers/transaction_provider.dart';
import 'package:billey/widgets/uncategorized_expenses_review.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _Categories extends CategoryProvider {
  @override
  List<CategoryModel> get categories => CategoryModel.getDefaultCategories()
      .where((c) => c.id != 'other')
      .toList();
}

class _Transactions extends TransactionProvider {
  final pending = List.generate(
      17,
      (i) => TransactionModel(
          id: 'pending_$i',
          title: 'Compra $i',
          amount: 12000,
          date: DateTime(2026, 10),
          type: TransactionType.gasto,
          category: TransactionCategory.other,
          currencyCode: 'COP'));
  bool failSave = false;
  String? selected;
  @override
  List<TransactionModel> get uncategorizedExpenses => pending.toList();
  @override
  Future<void> assignPendingCategory(
      TransactionModel before, CategoryModel category) async {
    if (failSave) throw StateError('offline');
    selected = category.id;
    pending.removeWhere((t) => t.id == before.id);
    notifyListeners();
  }
}

Future<void> _show(WidgetTester tester, _Transactions transactions) async {
  await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider<TransactionProvider>.value(value: transactions),
        ChangeNotifierProvider<CategoryProvider>(create: (_) => _Categories()),
        ChangeNotifierProvider(create: (_) => CurrencyProvider()),
      ],
      child: const MaterialApp(
          locale: Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
              body: SingleChildScrollView(
                  child: UncategorizedExpensesReview())))));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
      '17 pending expenses have 17 category selectors; saving removes only that expense',
      (tester) async {
    final provider = _Transactions();
    await _show(tester, provider);
    expect(find.byType(DropdownButtonFormField<String>), findsNWidgets(17));
    expect(find.text('17 gastos por categorizar'), findsOneWidget);
    await tester.tap(find.byType(DropdownButtonFormField<String>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Comida').last);
    await tester.pumpAndSettle();
    expect(provider.selected, 'food');
    expect(find.text('Compra 0'), findsNothing);
    expect(find.text('Compra 1'), findsOneWidget);
    expect(find.byType(DropdownButtonFormField<String>), findsNWidgets(16));
    expect(find.text('16 gastos por categorizar'), findsOneWidget);
  });
  testWidgets('failed save keeps expense and displays retry message',
      (tester) async {
    final provider = _Transactions()..failSave = true;
    await _show(tester, provider);
    await tester.tap(find.byType(DropdownButtonFormField<String>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Comida').last);
    await tester.pumpAndSettle();
    expect(provider.pending.length, 17);
    expect(find.text('Compra 0'), findsOneWidget);
    expect(find.textContaining('No se pudo guardar'), findsOneWidget);
  });
}
