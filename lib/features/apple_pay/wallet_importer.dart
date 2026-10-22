import '../../features/speech/domain/expense_voice_parser.dart';
import '../../models/category.dart';
import '../../models/transaction.dart';

class WalletEntry {
  WalletEntry.fromMap(Map<Object?, Object?> map)
      : id = map['id'] as String,
        owner = map['owner'] as String,
        amount = double.parse(map['amount'] as String),
        currency = map['currency'] as String,
        merchant = map['merchant'] as String,
        date = DateTime.fromMillisecondsSinceEpoch(
          ((map['date'] as num) * 1000).round(),
        ),
        dateIsReceipt = map['dateIsReceipt'] as bool,
        card = map['card'] as String?,
        isTest = map['test'] as bool {
    if (!RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$')
            .hasMatch(id) ||
        owner.isEmpty ||
        !amount.isFinite ||
        amount <= 0 ||
        amount > 1e12 ||
        !const ['COP', 'USD', 'EUR', 'MXN', 'BRL'].contains(currency)) {
      throw const FormatException('Entrada de Apple Pay inválida.');
    }
  }

  final String id, owner, currency, merchant;
  final double amount;
  final DateTime date;
  final bool dateIsReceipt, isTest;
  final String? card;

  TransactionModel toTransaction(List<CategoryModel> categories) {
    final available =
        categories.isEmpty ? CategoryModel.getDefaultCategories() : categories;
    // Reuse the same expense categorization and fallback as the voice form.
    final draft = const ExpenseVoiceParser().parse(
      merchant,
      now: date,
      customCategories: {for (final c in available) c.id: c.name},
    );
    final category = available.firstWhere(
      (c) => c.id == draft.categoryId,
      orElse: () => available.firstWhere(
        (c) => c.id == 'other',
        orElse: () => CategoryModel.getDefaultCategories()
            .firstWhere((c) => c.id == 'other'),
      ),
    );
    return TransactionModel(
      id: 'applepay_$id',
      title: merchant,
      amount: amount,
      date: date,
      type: TransactionType.gasto,
      category: category.transactionCategory,
      description: [
        'Origen: Apple Pay/Atajos',
        'Moneda original: $currency',
        if (dateIsReceipt) 'Fecha de recepción (fecha de compra no disponible)',
        if (card?.isNotEmpty ?? false) 'Alias de tarjeta: $card',
        'Referencia: $id',
      ].join('\n'),
    );
  }
}

/// An entry is acknowledged only after a durable, idempotent save succeeds.
/// Native ownership and stable IDs survive app restarts and lost responses.
class WalletImporter {
  Future<int> import({
    required List<WalletEntry> entries,
    required String owner,
    required String currency,
    required List<CategoryModel> categories,
    required Future<void> Function(TransactionModel, String) save,
    required Future<void> Function(String, String) acknowledge,
    required bool Function() sessionIsCurrent,
  }) async {
    var count = 0;
    for (final entry in entries) {
      if (!sessionIsCurrent()) break;
      if (entry.owner != owner) continue;
      if (entry.isTest) continue; // Test receipts never enter finances.
      if (entry.currency != currency) {
        throw StateError('Hay gastos en ${entry.currency} pendientes. '
            'Selecciona esa moneda en Billey para importarlos sin conversión.');
      }
      await save(entry.toTransaction(categories), owner);
      await acknowledge(owner, entry.id);
      count++;
    }
    return count;
  }
}
