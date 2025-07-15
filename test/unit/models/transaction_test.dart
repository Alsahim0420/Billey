import 'package:flutter_test/flutter_test.dart';
import 'package:billey/models/transaction.dart';

void main() {
  group('Transaction Model Tests', () {
    late TransactionModel transaction;
    late DateTime testDate;

    setUp(() {
      testDate = DateTime(2024, 1, 15);
      transaction = TransactionModel(
        id: 'test-id',
        title: 'Test Transaction',
        amount: 1000.0,
        description: 'Test transaction description',
        date: testDate,
        type: TransactionType.ingreso,
        category: TransactionCategory.food,
      );
    });

    test('should create transaction with correct properties', () {
      expect(transaction.id, 'test-id');
      expect(transaction.title, 'Test Transaction');
      expect(transaction.amount, 1000.0);
      expect(transaction.description, 'Test transaction description');
      expect(transaction.date, testDate);
      expect(transaction.type, TransactionType.ingreso);
      expect(transaction.category, TransactionCategory.food);
    });

    test('should create transaction without description', () {
      final transactionWithoutDesc = TransactionModel(
        id: 'test-id-2',
        title: 'Transaction without description',
        amount: 500.0,
        date: testDate,
        type: TransactionType.gasto,
        category: TransactionCategory.transport,
      );

      expect(transactionWithoutDesc.description, isNull);
    });

    test('should convert to and from map', () {
      final map = transaction.toMap();
      final fromMap = TransactionModel.fromMap(map);

      expect(fromMap.id, transaction.id);
      expect(fromMap.title, transaction.title);
      expect(fromMap.amount, transaction.amount);
      expect(fromMap.description, transaction.description);
      expect(fromMap.date, transaction.date);
      expect(fromMap.type, transaction.type);
      expect(fromMap.category, transaction.category);
    });

    test('should handle null description in map conversion', () {
      final transactionWithoutDesc = TransactionModel(
        id: 'test-id-3',
        title: 'Transaction without description',
        amount: 300.0,
        date: testDate,
        type: TransactionType.gasto,
        category: TransactionCategory.transport,
      );

      final map = transactionWithoutDesc.toMap();
      final fromMap = TransactionModel.fromMap(map);

      expect(fromMap.description, isNull);
    });

    test('should have correct category display names', () {
      expect(TransactionCategory.food.displayName, 'Comida');
      expect(TransactionCategory.transport.displayName, 'Transporte');
      expect(TransactionCategory.entertainment.displayName, 'Entretenimiento');
      expect(TransactionCategory.health.displayName, 'Salud');
      expect(TransactionCategory.education.displayName, 'Educación');
      expect(TransactionCategory.other.displayName, 'Otros');
    });

    test('should have correct transaction type values', () {
      expect(TransactionType.values.length, 2);
      expect(TransactionType.values.contains(TransactionType.ingreso), true);
      expect(TransactionType.values.contains(TransactionType.gasto), true);
    });

    test('should have correct category values', () {
      expect(TransactionCategory.values.length, 6);
      expect(
          TransactionCategory.values.contains(TransactionCategory.food), true);
      expect(TransactionCategory.values.contains(TransactionCategory.transport),
          true);
      expect(
          TransactionCategory.values
              .contains(TransactionCategory.entertainment),
          true);
      expect(TransactionCategory.values.contains(TransactionCategory.health),
          true);
      expect(TransactionCategory.values.contains(TransactionCategory.education),
          true);
      expect(
          TransactionCategory.values.contains(TransactionCategory.other), true);
    });
  });
}
