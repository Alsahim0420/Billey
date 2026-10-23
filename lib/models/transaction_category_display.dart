import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../l10n/localization_helpers.dart';
import '../theme/colors/app_colors.dart';
import 'category.dart';
import 'transaction.dart';

/// Resolve the exact saved ID before using the legacy enum for older entries.
class TransactionCategoryDisplay {
  const TransactionCategoryDisplay(
      {required this.name, required this.icon, required this.color});
  final String name;
  final IconData icon;
  final Color color;

  factory TransactionCategoryDisplay.resolve(TransactionModel transaction,
      Iterable<CategoryModel> catalog, AppLocalizations l10n) {
    final id = transaction.effectiveCategoryId;
    final category = catalog.where((c) => c.id == id).firstOrNull;
    if (category != null) {
      final original = CategoryModel.getDefaultCategories()
          .where((c) => c.id == category.id)
          .firstOrNull;
      return TransactionCategoryDisplay(
          name: category.isDefault && category.name == original?.name
              ? category.transactionCategory.localizedName(l10n)
              : category.name,
          icon: category.icon,
          color: category.color);
    }
    final legacy =
        TransactionCategory.values.where((c) => c.name == id).firstOrNull;
    if (legacy != null) {
      return TransactionCategoryDisplay(
          name: legacy.localizedName(l10n),
          icon: legacy.icon,
          color: legacy.color);
    }
    // A deleted/custom category unavailable on this device is not "Other".
    return TransactionCategoryDisplay(
        name: l10n.transactionCategoryUnavailable,
        icon: Icons.category_outlined,
        color: AppColors.textSecondary);
  }
}
