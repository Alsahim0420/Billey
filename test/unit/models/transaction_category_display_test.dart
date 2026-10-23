import 'package:billey/l10n/app_localizations_es.dart';
import 'package:billey/models/category.dart';
import 'package:billey/models/transaction.dart';
import 'package:billey/models/transaction_category_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final l10n = AppLocalizationsEs();
  TransactionModel expense(String? id,
          [TransactionCategory category = TransactionCategory.other]) =>
      TransactionModel(
          title: 'Compra ETF',
          amount: 100,
          date: DateTime(2026, 10),
          type: TransactionType.gasto,
          category: category,
          categoryId: id,
          id: '');
  test(
      'exact custom ID wins over legacy Other and retains inactive category appearance',
      () {
    final investment = CategoryModel(
        id: 'investment_custom',
        name: 'Inversión',
        iconCodePoint: Icons.account_balance.codePoint,
        colorValue: Colors.blue.toARGB32(),
        isActive: false);
    final result = TransactionCategoryDisplay.resolve(
        expense(investment.id), [investment], l10n);
    expect(result.name, 'Inversión');
    expect(result.icon, Icons.account_balance);
    expect(result.color.toARGB32(), Colors.blue.toARGB32());
  });
  test(
      'legacy category is localized, unknown custom ID is not mislabeled Other',
      () {
    expect(
        TransactionCategoryDisplay.resolve(
                expense(null, TransactionCategory.food), [], l10n)
            .name,
        'Comida');
    expect(
        TransactionCategoryDisplay.resolve(expense('missing_custom'), [], l10n)
            .name,
        'Categoría no disponible');
    expect(TransactionCategoryDisplay.resolve(expense(null), [], l10n).name,
        'Sin categorizar');
  });
}
