import 'package:billey/models/transaction.dart';
import 'package:billey/providers/transaction_provider.dart';
import 'package:flutter_test/flutter_test.dart';

TransactionModel _tx(
        String id, DateTime date, double amount, TransactionType type,
        {String? owner}) =>
    TransactionModel(
        id: id,
        title: id,
        date: date,
        amount: amount,
        type: type,
        category: TransactionCategory.food,
        ownerId: owner);
void main() {
  test(
      'each month starts at zero without carrying previous income, expenses or surplus',
      () {
    final provider = TransactionProvider()
      ..setTestTransactions([
        _tx('sep-income', DateTime(2026, 9, 1), 1000, TransactionType.ingreso),
        _tx('sep-expense', DateTime(2026, 9, 30), 400, TransactionType.gasto),
        _tx('nov-income', DateTime(2026, 11, 1), 800, TransactionType.ingreso),
      ]);
    expect(provider.getMonthlySummary(DateTime(2026, 9)), 600);
    expect(provider.getMonthlyIncome(DateTime(2026, 10)), 0);
    expect(provider.getMonthlyExpenses(DateTime(2026, 10)), 0);
    expect(provider.getMonthlySummary(DateTime(2026, 10)), 0);
    expect(provider.allTransactions.length, 3);
    provider.dispose();
  });
  test(
      'only current-month personal records count, including UTC timestamps on local month boundaries',
      () {
    final provider = TransactionProvider()
      ..setTestTransactions([
        _tx('last-year', DateTime(2025, 1, 4), 9000, TransactionType.ingreso),
        _tx('december', DateTime(2025, 12, 31, 23, 59).toUtc(), 1000,
            TransactionType.ingreso),
        _tx('january-income', DateTime(2026, 1, 1).toUtc(), 500,
            TransactionType.ingreso),
        _tx('january-expense', DateTime(2026, 1, 31, 23, 59).toUtc(), 75,
            TransactionType.gasto),
        _tx('partner', DateTime(2026, 1, 5), 999, TransactionType.gasto,
            owner: 'partner'),
        _tx('february', DateTime(2026, 2, 1).toUtc(), 100,
            TransactionType.gasto),
      ]);
    expect(provider.getMonthlyIncome(DateTime(2026, 1)), 500);
    expect(provider.getMonthlyExpenses(DateTime(2026, 1)), 75);
    expect(provider.getMonthlySummary(DateTime(2026, 1)), 425);
    expect(provider.getMonthlyExpenses(DateTime(2026, 2)), 100);
    provider.dispose();
  });
}
