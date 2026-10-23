import '../models/category.dart';
import '../models/transaction.dart';
import 'expense_categorizer.dart';

class CategorizationReport {
  const CategorizationReport(
      this.updated, this.unresolved, this.skipped, this.remaining);
  final int updated, unresolved, skipped, remaining;
}

class UncategorizedExpenseMigration {
  static bool eligible(TransactionModel tx, String owner) =>
      tx.type == TransactionType.gasto &&
      (tx.ownerId == null || tx.ownerId == owner) &&
      tx.effectiveCategoryId == 'other';

  Future<CategorizationReport> run({
    required String owner,
    required List<TransactionModel> transactions,
    required List<CategoryModel> categories,
    required ExpenseCategorizer categorizer,
    required bool Function() sessionIsCurrent,
    required Future<bool> Function(TransactionModel, TransactionModel) update,
    void Function(int processed, int total)? onProgress,
    int limit = 20,
  }) async {
    if (limit < 1 || limit > 100) throw ArgumentError.value(limit, 'limit');
    if (!await categorizer.isConfigured) {
      throw StateError('Gemini no está configurado.');
    }
    final pending = transactions.where((tx) => eligible(tx, owner)).toList();
    final batch = pending.take(limit).toList();
    var updated = 0, unresolved = 0, skipped = 0, processed = 0;
    for (final before in batch) {
      if (!sessionIsCurrent()) break;
      try {
        final after =
            await categorizer.categorize(before, categories, requireAI: true);
        if (!sessionIsCurrent()) break;
        if (await update(before, after)) {
          updated++;
        } else {
          skipped++;
        }
      } on CategoryReviewRequired {
        unresolved++;
      }
      processed++;
      onProgress?.call(processed, batch.length);
    }
    return CategorizationReport(
        updated, unresolved, skipped, pending.length - processed);
  }
}
