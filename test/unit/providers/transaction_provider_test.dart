import 'package:flutter_test/flutter_test.dart';
import 'package:my_finances_app/providers/transaction_provider.dart';
import 'package:my_finances_app/models/transaction.dart';

void main() {
  group('TransactionProvider lógica interna', () {
    late TransactionProvider provider;
    late List<TransactionModel> testTransactions;

    setUp(() {
      provider = TransactionProvider();
      testTransactions = [
        TransactionModel(
          id: 'income-1',
          title: 'Salary',
          amount: 1000.0,
          date: DateTime(2024, 1, 10),
          type: TransactionType.ingreso,
          category: TransactionCategory.food,
        ),
        TransactionModel(
          id: 'income-2',
          title: 'Bonus',
          amount: 500.0,
          date: DateTime(2024, 1, 15),
          type: TransactionType.ingreso,
          category: TransactionCategory.food,
        ),
        TransactionModel(
          id: 'expense-1',
          title: 'Food',
          amount: 200.0,
          date: DateTime(2024, 1, 20),
          type: TransactionType.gasto,
          category: TransactionCategory.food,
        ),
      ];
      // Simular carga de transacciones directamente
      provider
        ..clearFilters()
        ..setTestTransactions(List.from(testTransactions));
    });

    test('getTotalIncome y getTotalExpenses', () {
      expect(provider.getTotalIncome(), 1500.0);
      expect(provider.getTotalExpenses(), 200.0);
    });

    test('filterByType', () {
      provider.filterByType(TransactionType.ingreso);
      expect(provider.transactions.length, 2);
      provider.filterByType(TransactionType.gasto);
      expect(provider.transactions.length, 1);
    });

    test('filterByCategory', () {
      provider.filterByCategory(TransactionCategory.food);
      expect(provider.transactions.length, 3);
    });

    test('searchTransactions', () {
      provider.searchTransactions('Salary');
      expect(provider.transactions.length, 1);
    });

    test('clearFilters', () {
      provider.searchTransactions('test');
      provider.filterByType(TransactionType.ingreso);
      expect(provider.searchQuery, 'test');
      expect(provider.filterType, TransactionType.ingreso);
      provider.clearFilters();
      expect(provider.searchQuery, isEmpty);
      expect(provider.filterType, isNull);
      expect(provider.filterCategory, isNull);
    });

    test('getTransactionsByMonth', () {
      final januaryTransactions =
          provider.getTransactionsByMonth(DateTime(2024, 1, 1));
      expect(januaryTransactions.length, 3);
      final februaryTransactions =
          provider.getTransactionsByMonth(DateTime(2024, 2, 1));
      expect(februaryTransactions.length, 0);
    });

    test('getTotalByCategory', () {
      final foodTotal = provider.getTotalByCategory(TransactionCategory.food);
      expect(foodTotal, 1700.0); // 1000 + 500 + 200
    });

    test('getTransactionsByDateRange', () {
      final rangeTransactions = provider.getTransactionsByDateRange(
        DateTime(2024, 1, 1),
        DateTime(2024, 1, 31),
      );
      expect(rangeTransactions.length, 3);
    });

    test('getMonthlySummary', () {
      final summary = provider.getMonthlySummary(DateTime(2024, 1, 1));
      expect(summary, 1300.0); // 1500 income - 200 expenses
    });

    test('getters iniciales', () {
      expect(provider.searchQuery, isEmpty);
      expect(provider.filterType, isNull);
      expect(provider.filterCategory, isNull);
    });

    test('sin transacciones', () {
      provider.setTestTransactions([]);
      expect(provider.getTotalIncome(), 0.0);
      expect(provider.getTotalExpenses(), 0.0);
      expect(provider.getMonthlySummary(DateTime.now()), 0.0);
      expect(provider.getTransactionsByMonth(DateTime.now()), isEmpty);
      expect(provider.getTotalByCategory(TransactionCategory.food), 0.0);
    });
  });
}
