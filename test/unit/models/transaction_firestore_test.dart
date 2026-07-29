import 'package:billey/models/transaction.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('serializes a transaction with its authenticated owner', () {
    final transaction = TransactionModel(
      id: 'transaction-1',
      title: 'Almuerzo',
      amount: 25000,
      date: DateTime.utc(2026, 7, 29, 12),
      type: TransactionType.gasto,
      category: TransactionCategory.food,
      description: 'Menú del día',
    );

    final data = transaction.toFirestore(userId: 'user-123');

    expect(data['id'], 'transaction-1');
    expect(data['userId'], 'user-123');
    expect(data['date'], isA<Timestamp>());
    expect(data['type'], 'gasto');
    expect(data['category'], 'food');
  });

  test('deserializes a Firestore transaction using the document id', () {
    final transaction = TransactionModel.fromFirestore('firestore-id', {
      'id': 'untrusted-id',
      'userId': 'user-123',
      'title': 'Taxi',
      'amount': 18000,
      'date': Timestamp.fromDate(DateTime.utc(2026, 7, 29)),
      'type': 'gasto',
      'category': 'transport',
      'description': null,
    });

    expect(transaction.id, 'firestore-id');
    expect(transaction.amount, 18000);
    expect(transaction.type, TransactionType.gasto);
    expect(transaction.category, TransactionCategory.transport);
  });
}
