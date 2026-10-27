import 'package:billey/models/transaction.dart';
import 'package:billey/providers/transaction_provider.dart';
import 'package:billey/services/firestore_transaction_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

class _Auth extends Fake implements FirebaseAuth {}

class _Db extends Fake implements FirebaseFirestore {}

class _User extends Fake implements User {
  @override
  String get uid => 'me';
}

class _Service extends FirestoreTransactionService {
  _Service() : super(firebaseAuth: _Auth(), firestore: _Db());
  @override
  User get currentUser => _User();
}

TransactionModel tx(String id, String? owner, double amount,
        {TransactionType type = TransactionType.gasto,
        List<String> sharedWith = const []}) =>
    TransactionModel(
        id: id,
        title: id,
        amount: amount,
        date: DateTime(2026, 10, 23),
        type: type,
        category: TransactionCategory.food,
        categoryId: 'food',
        ownerId: owner,
        sharedWith: sharedWith);
void main() {
  test(
      'partner expense and income stay visible but never affect personal totals',
      () {
    final provider = TransactionProvider.cloud(service: _Service());
    provider.setTestTransactions([
      tx('salary', 'me', 1000, type: TransactionType.ingreso),
      tx('own-shared', 'me', 100, sharedWith: ['partner']),
      tx('legacy', null, 50),
      tx('partner-expense', 'partner', 600),
      tx('partner-income', 'partner', 200, type: TransactionType.ingreso),
    ]);
    expect(provider.transactions.length, 5);
    expect(provider.allTransactions.length, 5);
    expect(provider.personalTransactions.length, 3);
    expect(provider.getTotalIncome(), 1000);
    expect(provider.getTotalExpenses(), 150);
    expect(provider.getMonthlySummary(DateTime(2026, 10)), 850);
    expect(provider.getTransactionsByMonth(DateTime(2026, 10)).length, 3);
    expect(
        provider
            .getTransactionsByDateRange(
                DateTime(2026, 10, 1), DateTime(2026, 10, 31))
            .length,
        3);
    expect(provider.getTotalByCategory(TransactionCategory.food), 1150);
    provider.searchTransactions('partner-expense');
    expect(provider.transactions.single.ownerId, 'partner');
    expect(provider.personalVisibleTransactions, isEmpty);
    expect(provider.getTotalExpenses(), 150);
    provider.dispose();
  });
  test('only a partner expense means zero personal expenses and balance', () {
    final provider = TransactionProvider.cloud(service: _Service());
    provider.setTestTransactions([tx('bill', 'partner', 300)]);
    expect(provider.transactions.length, 1);
    expect(provider.personalTransactions, isEmpty);
    expect(provider.getTotalExpenses(), 0);
    expect(provider.getMonthlySummary(DateTime(2026, 10)), 0);
    provider.dispose();
  });
  test('shared records cannot be edited or deleted through the provider',
      () async {
    final provider = TransactionProvider.cloud(service: _Service());
    final shared = tx('bill', 'partner', 300);
    provider.setTestTransactions([shared]);
    await expectLater(provider.editTransaction(shared), throwsStateError);
    await expectLater(provider.deleteTransaction('bill'), throwsStateError);
    expect(provider.transactions.single, shared);
    provider.dispose();
  });
}
