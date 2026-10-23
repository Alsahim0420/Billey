import 'package:billey/models/automatic_category_budgets.dart';
import 'package:billey/models/category.dart';
import 'package:billey/models/category_budget.dart';
import 'package:billey/models/transaction.dart';
import 'package:billey/providers/income_distribution_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'category_budget_test.dart' show expense;

void main() {
  final month = DateTime(2026, 10);
  final categories = CategoryModel.getDefaultCategories();
  List<CategoryBudget> plan(List<TransactionModel> transactions,
          {IncomeDistributionTemplate? template}) =>
      AutomaticCategoryBudgets.calculate(
          month: month,
          currency: 'COP',
          owner: 'me',
          template: template ?? IncomeDistributionProvider.templates.first,
          categories: categories,
          transactions: transactions);
  test('50/30/20 allocates 50% needs, 30% wants and reserves 20%', () {
    final result =
        plan([expense(type: TransactionType.ingreso, amount: 1000000)]);
    expect(result.fold<double>(0, (sum, b) => sum + b.limit), 800000);
    final needs = categories
        .where((c) => AutomaticCategoryBudgets.bucketFor(c) == 'essentials')
        .map((c) => c.id);
    expect(
        result
            .where((b) => needs.contains(b.categoryId))
            .fold<double>(0, (s, b) => s + b.limit),
        500000);
  });
  test('no income creates no invented budget; ignores partner and currency',
      () {
    expect(plan([]), isEmpty);
    expect(
        plan([
          expense(type: TransactionType.ingreso, owner: 'partner'),
          expense(type: TransactionType.ingreso, currency: 'USD')
        ]),
        isEmpty);
  });
  test('previous month fallback, history weighting and no zero categories', () {
    final result = plan([
      expense(
          type: TransactionType.ingreso,
          date: DateTime(2026, 9),
          amount: 1000000),
      expense(categoryId: 'food', date: DateTime(2026, 9), amount: 500),
    ]);
    expect(result.firstWhere((b) => b.categoryId == 'food').limit,
        greaterThan(400000));
    expect(result.every((b) => b.limit > 0), isTrue);
    expect(result.fold<double>(0, (s, b) => s + b.limit), 800000);
  });
  test(
      'current income replaces fallback and alternate template reserves its envelopes',
      () {
    final result = plan([
      expense(
          type: TransactionType.ingreso,
          date: DateTime(2026, 9),
          amount: 1000000),
      expense(type: TransactionType.ingreso, amount: 2000000),
    ], template: IncomeDistributionProvider.templates[2]);
    expect(result.fold<double>(0, (s, b) => s + b.limit), 1200000);
  });
}
