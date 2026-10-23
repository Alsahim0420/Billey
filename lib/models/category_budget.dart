import 'transaction.dart';

class CategoryBudget {
  CategoryBudget(
      {required this.month,
      required this.categoryId,
      required this.categoryName,
      required this.currency,
      required this.limit}) {
    if (!RegExp(r'^(19|2[0-9])[0-9]{2}-(0[1-9]|1[0-2])$').hasMatch(month) ||
        !RegExp(r'^[a-zA-Z0-9_-]{1,100}$').hasMatch(categoryId) ||
        categoryName.trim().isEmpty ||
        categoryName.length > 120 ||
        !const ['COP', 'USD', 'EUR', 'MXN', 'BRL'].contains(currency) ||
        !limit.isFinite ||
        limit <= 0 ||
        limit > 1e12) {
      throw const FormatException('Presupuesto inválido.');
    }
  }

  final String month, categoryId, categoryName, currency;
  final double limit;
  String get id => '${month}_${currency}_$categoryId';
  static String monthKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}';

  Map<String, dynamic> toMap() => {
        'month': month,
        'categoryId': categoryId,
        'categoryName': categoryName,
        'currency': currency,
        'limit': limit
      };

  factory CategoryBudget.fromMap(Map<String, dynamic> data) => CategoryBudget(
        month: data['month'] as String,
        categoryId: data['categoryId'] as String,
        categoryName: data['categoryName'] as String,
        currency: data['currency'] as String,
        limit: (data['limit'] as num).toDouble(),
      );

  CategoryBudget forMonth(String value) => CategoryBudget(
      month: value,
      categoryId: categoryId,
      categoryName: categoryName,
      currency: currency,
      limit: limit);

  static Map<String, double> spending(
      {required Iterable<TransactionModel> transactions,
      required DateTime month,
      required String currency,
      required String owner}) {
    final totals = <String, double>{};
    for (final tx in transactions) {
      final date = tx.date.toLocal();
      if (tx.type != TransactionType.gasto ||
          date.year != month.year ||
          date.month != month.month ||
          (tx.ownerId != null && tx.ownerId != owner) ||
          (tx.currencyCode != null && tx.currencyCode != currency)) {
        continue;
      }
      totals.update(tx.effectiveCategoryId, (sum) => sum + tx.amount,
          ifAbsent: () => tx.amount);
    }
    return totals;
  }
}
