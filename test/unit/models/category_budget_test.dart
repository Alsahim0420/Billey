import 'package:billey/models/category_budget.dart';
import 'package:billey/models/transaction.dart';
import 'package:flutter_test/flutter_test.dart';

CategoryBudget budget(
        {String month = '2026-10',
        String category = 'food',
        String currency = 'COP',
        double limit = 200000}) =>
    CategoryBudget(
        month: month,
        categoryId: category,
        categoryName: 'Comida',
        currency: currency,
        limit: limit);
TransactionModel expense(
        {String? categoryId,
        TransactionCategory category = TransactionCategory.food,
        String? currency,
        String? owner = 'me',
        DateTime? date,
        TransactionType type = TransactionType.gasto,
        double amount = 100}) =>
    TransactionModel(
        id: 'tx',
        title: 'Gasto',
        amount: amount,
        date: date ?? DateTime(2026, 10, 22),
        type: type,
        category: category,
        categoryId: categoryId,
        currencyCode: currency,
        ownerId: owner);

void main() {
  test('budget IDs distinguish month, currency and custom category', () {
    expect(budget().id, '2026-10_COP_food');
    expect(budget(currency: 'USD').id, isNot(budget().id));
    expect(budget(category: 'custom_123').id, '2026-10_COP_custom_123');
    expect(budget().forMonth('2026-11').limit, 200000);
    expect(CategoryBudget.fromMap(budget().toMap()).id, budget().id);
    expect(CategoryBudget.monthKey(DateTime(2026, 1)), '2026-01');
  });
  test('invalid limits, currencies, months and IDs are rejected', () {
    for (final limit in [0.0, -1.0, double.nan, double.infinity, 1e12 + 1]) {
      expect(() => budget(limit: limit), throwsFormatException);
    }
    expect(() => budget(month: '2026-13'), throwsFormatException);
    expect(() => budget(month: '2026-1'), throwsFormatException);
    expect(() => budget(category: 'a/b'), throwsFormatException);
    expect(() => budget(currency: r'$'), throwsFormatException);
  });
  test(
      'spending uses exact custom IDs, own expenses, calendar month and currency',
      () {
    final totals = CategoryBudget.spending(
        month: DateTime(2026, 10),
        currency: 'COP',
        owner: 'me',
        transactions: [
          expense(
              categoryId: 'custom_123',
              category: TransactionCategory.other,
              currency: 'COP',
              amount: 80),
          expense(
              categoryId: 'custom_456',
              category: TransactionCategory.other,
              currency: 'COP',
              amount: 50),
          expense(amount: 30), // Legacy default category and missing currency.
          expense(owner: 'partner', amount: 999),
          expense(currency: 'USD', amount: 999),
          expense(type: TransactionType.ingreso, amount: 999),
          expense(date: DateTime(2026, 9, 30), amount: 999),
          expense(date: DateTime(2025, 10, 22), amount: 999),
          expense(date: DateTime(2026, 11, 1), amount: 999),
        ]);
    expect(totals, {'custom_123': 80, 'custom_456': 50, 'food': 30});
  });
  test('legacy Other remains Other; limits are independent per month', () {
    final totals = CategoryBudget.spending(
        month: DateTime(2026, 10),
        currency: 'COP',
        owner: 'me',
        transactions: [expense(category: TransactionCategory.other)]);
    expect(totals['other'], 100);
    expect(totals['custom_123'], isNull);
    expect(budget().forMonth('2026-11').id, isNot(budget().id));
  });
}
