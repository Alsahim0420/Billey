import 'package:flutter_test/flutter_test.dart';
import 'package:billey/models/financial_cycle.dart';
import 'package:billey/models/category_budget.dart';
import 'package:billey/models/automatic_category_budgets.dart';
import 'package:billey/models/category.dart';
import 'package:billey/models/transaction.dart';
import 'package:billey/providers/income_distribution_provider.dart';
import 'category_budget_test.dart' show expense;

void main() {
  test('27 through 26 crosses calendar months without carrying prior income',
      () {
    const cycle = FinancialCycle(27);
    final period = cycle.containing(DateTime(2026, 11, 1));
    expect(period.start, DateTime(2026, 10, 27));
    expect(period.lastDay, DateTime(2026, 11, 26));
    expect(period.contains(DateTime(2026, 10, 26, 23, 59)), false);
    expect(period.contains(DateTime(2026, 11, 26, 23, 59)), true);
    expect(period.contains(DateTime(2026, 11, 27)), false);
    expect(
        cycle.containing(DateTime(2027, 1, 1)).start, DateTime(2026, 12, 27));
  });
  test(
      'every day belongs to exactly one period including leap and short months',
      () {
    for (final year in [2024, 2026]) {
      for (final day in [1, 27, 29, 30, 31]) {
        final cycle = FinancialCycle(day);
        for (var m = 1; m <= 12; m++) {
          final period = cycle.forMonth(DateTime(year, m));
          final next = cycle.forMonth(DateTime(year, m + 1));
          expect(period.endExclusive, next.start);
          for (var date = period.start;
              date.isBefore(period.endExclusive);
              date = DateTime(date.year, date.month, date.day + 1)) {
            expect(cycle.containing(date).start, period.start);
          }
        }
      }
    }
    expect(const FinancialCycle(31).forMonth(DateTime(2024, 2)).start,
        DateTime(2024, 2, 29));
  });
  test('category spending and automatic income use the same cycle', () {
    const cycle = FinancialCycle(27);
    final month = DateTime(2026, 10);
    final transactions = [
      expense(date: DateTime(2026, 10, 26), amount: 900),
      expense(date: DateTime(2026, 10, 27), amount: 10),
      expense(date: DateTime(2026, 11, 26), amount: 20),
      expense(date: DateTime(2026, 11, 27), amount: 800),
      expense(
          date: DateTime(2026, 10, 27),
          amount: 1000000,
          type: TransactionType.ingreso),
      expense(
          date: DateTime(2026, 11, 27),
          amount: 9000000,
          type: TransactionType.ingreso),
    ];
    expect(
        CategoryBudget.spending(
            transactions: transactions,
            month: month,
            currency: 'COP',
            owner: 'me',
            cycle: cycle)['food'],
        30);
    final budgets = AutomaticCategoryBudgets.calculate(
        month: month,
        currency: 'COP',
        owner: 'me',
        cycle: cycle,
        template: IncomeDistributionProvider.templates.first,
        categories: CategoryModel.getDefaultCategories(),
        transactions: transactions);
    expect(budgets.fold(0.0, (sum, b) => sum + b.limit), 800000);
  });
}
