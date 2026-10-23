import 'package:billey/models/category.dart';
import 'package:billey/models/transaction.dart';
import 'package:billey/services/expense_categorizer.dart';
import 'package:billey/services/uncategorized_expense_migration.dart';
import 'package:flutter_test/flutter_test.dart';

class _AI extends Fake implements ExpenseCategorizer {
  bool configured = true;
  final seen = <String>[];
  @override
  Future<bool> get isConfigured async => configured;
  @override
  Future<TransactionModel> categorize(
      TransactionModel tx, List<CategoryModel> categories,
      {bool requireAI = false}) async {
    expect(requireAI, isTrue);
    expect(categories.map((c) => c.id), contains('food'));
    seen.add(tx.id!);
    if (tx.title == 'unknown') throw const CategoryReviewRequired();
    return TransactionModel(
        id: tx.id,
        title: tx.title,
        amount: tx.amount,
        date: tx.date,
        type: tx.type,
        category: TransactionCategory.food,
        categoryId: 'food',
        description: tx.description,
        currencyCode: tx.currencyCode,
        ownerId: tx.ownerId);
  }
}

TransactionModel expense(String id,
        {String? categoryId,
        String owner = 'me',
        String title = 'Comida',
        TransactionCategory category = TransactionCategory.other,
        TransactionType type = TransactionType.gasto}) =>
    TransactionModel(
        id: id,
        title: title,
        amount: 12345,
        date: DateTime(2026, 10),
        type: type,
        category: category,
        categoryId: categoryId,
        ownerId: owner,
        description: 'original',
        currencyCode: 'COP');
void main() {
  test('only own uncategorized expenses, preserving IDs and financial fields',
      () async {
    final ai = _AI();
    final writes = <String>[];
    final report = await UncategorizedExpenseMigration().run(
        owner: 'me',
        categorizer: ai,
        categories: CategoryModel.getDefaultCategories(),
        sessionIsCurrent: () => true,
        transactions: [
          expense('legacy'),
          expense('explicit', categoryId: 'other'),
          expense('custom', categoryId: 'custom_123'),
          expense('categorized', category: TransactionCategory.health),
          expense('partner', owner: 'partner'),
          expense('income', type: TransactionType.ingreso)
        ],
        update: (before, after) async {
          writes.add(before.id!);
          expect(after.id, before.id);
          expect(after.amount, before.amount);
          expect(after.description, before.description);
          expect(after.currencyCode, before.currencyCode);
          return true;
        });
    expect(writes, ['legacy', 'explicit']);
    expect(report.updated, 2);
  });
  test(
      'bounded, resumable, ambiguity and concurrent edits never count as updates',
      () async {
    final report = await UncategorizedExpenseMigration().run(
        owner: 'me',
        categorizer: _AI(),
        categories: CategoryModel.getDefaultCategories(),
        sessionIsCurrent: () => true,
        transactions: [
          expense('unknown', title: 'unknown'),
          expense('edited'),
          expense('next')
        ],
        limit: 2,
        update: (_, __) async => false);
    expect(report.updated, 0);
    expect(report.unresolved, 1);
    expect(report.skipped, 1);
    expect(report.remaining, 1);
  });
  test('session change and absent key prevent writes', () async {
    final ai = _AI();
    Future<void> run() async {
      await UncategorizedExpenseMigration().run(
          owner: 'me',
          categorizer: ai,
          categories: CategoryModel.getDefaultCategories(),
          sessionIsCurrent: () => false,
          transactions: [expense('a')],
          update: (_, __) async {
            fail('No writes');
          });
    }

    await run();
    expect(ai.seen, isEmpty);
    ai.configured = false;
    await expectLater(run(), throwsStateError);
  });
}
