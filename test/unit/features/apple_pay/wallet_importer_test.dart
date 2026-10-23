import 'package:billey/features/apple_pay/wallet_importer.dart';
import 'package:billey/models/category.dart';
import 'package:billey/models/transaction.dart';
import 'package:flutter_test/flutter_test.dart';

WalletEntry entry(
        {String id = '10000000-0000-4000-8000-000000000001',
        String owner = 'a',
        String currency = 'COP',
        bool test = false,
        String amount = '12500.50',
        String merchant = 'Uber'}) =>
    WalletEntry.fromMap({
      'id': id,
      'owner': owner,
      'amount': amount,
      'currency': currency,
      'merchant': merchant,
      'date': 1792670400,
      'dateIsReceipt': true,
      'test': test,
    });

void main() {
  test('validates native payload again before importing', () {
    for (final amount in ['0', '-1', 'NaN', 'Infinity', '1000000000001']) {
      expect(() => entry(amount: amount), throwsFormatException);
    }
    expect(() => entry(currency: r'$'), throwsFormatException);
  });

  test(
      'reuses categorization, origin and fallback without parsing merchant amount/date',
      () {
    final tx = entry(merchant: 'Uber ayer 999').toTransaction([]);
    expect(tx.amount, 12500.5);
    expect(tx.category, TransactionCategory.transport);
    expect(tx.type, TransactionType.gasto);
    expect(tx.date, entry().date);
    expect(tx.description, contains('Apple Pay/Atajos'));
    expect(tx.description, contains('COP'));
    expect(tx.description, contains('Fecha de recepción'));
    expect(entry(merchant: 'Desconocido').toTransaction([]).category,
        TransactionCategory.other);
    expect(
        entry(merchant: 'Uber')
            .toTransaction(CategoryModel.getDefaultCategories()
                .where((c) => c.id != 'transport')
                .toList())
            .category,
        TransactionCategory.other);
  });

  test('lost acknowledgment retries stable ID; equal purchases remain distinct',
      () async {
    final stored = <String?, TransactionModel>{};
    final acked = <String>[];
    var failAck = true;
    Future<void> run(List<WalletEntry> entries) => WalletImporter()
        .import(
          entries: entries,
          owner: 'a',
          currency: 'COP',
          categories: [],
          save: (tx, owner) async {
            stored.putIfAbsent(tx.id, () => tx);
          },
          acknowledge: (owner, id) async {
            if (failAck) throw StateError('Simulated crash before ack');
            acked.add(id);
          },
          sessionIsCurrent: () => true,
        )
        .then((_) {});
    await expectLater(run([entry()]), throwsStateError);
    expect(stored.length, 1);
    expect(acked, isEmpty);
    failAck = false;
    await run([entry(), entry(id: '10000000-0000-4000-8000-000000000002')]);
    expect(stored.length, 2);
    expect(acked.length, 2);
  });

  test('failed persistence never acknowledges', () async {
    var acked = false;
    await expectLater(
        WalletImporter().import(
          entries: [entry()],
          owner: 'a',
          currency: 'COP',
          categories: [],
          save: (_, __) async => throw StateError('Offline'),
          acknowledge: (_, __) async {
            acked = true;
          },
          sessionIsCurrent: () => true,
        ),
        throwsStateError);
    expect(acked, isFalse);
  });

  test('test receipts, other owners and changed sessions never create expenses',
      () async {
    var saves = 0;
    Future<int> run(List<WalletEntry> entries, bool current) =>
        WalletImporter().import(
          entries: entries,
          owner: 'a',
          currency: 'COP',
          categories: [],
          save: (_, __) async {
            saves++;
          },
          acknowledge: (_, __) async {},
          sessionIsCurrent: () => current,
        );
    expect(await run([entry(test: true), entry(owner: 'b')], true), 0);
    expect(await run([entry()], false), 0);
    expect(saves, 0);
    await expectLater(run([entry(currency: 'USD')], true), throwsStateError);
    expect(saves, 0);
  });
}
