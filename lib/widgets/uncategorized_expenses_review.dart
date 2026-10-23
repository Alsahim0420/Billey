import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../l10n/l10n_extensions.dart';
import '../l10n/localization_helpers.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import '../providers/category_provider.dart';
import '../providers/currency_provider.dart';
import '../providers/transaction_provider.dart';
import '../theme/colors/app_colors.dart';

/// Every remaining expense is actionable, regardless of the AI batch limit.
class UncategorizedExpensesReview extends StatelessWidget {
  const UncategorizedExpensesReview({super.key, this.onAssigned});
  final VoidCallback? onAssigned;
  @override
  Widget build(BuildContext context) {
    final pending = context.watch<TransactionProvider>().uncategorizedExpenses;
    final categories = context.watch<CategoryProvider>().categories;
    final l10n = context.l10n;
    if (pending.isEmpty) {
      return Text(l10n.categoryReviewEmpty,
          style: const TextStyle(
              color: AppColors.primaryColor, fontWeight: FontWeight.w700));
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(l10n.categoryReviewCount(pending.length),
          style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w800)),
      const SizedBox(height: 6),
      Text(l10n.categoryReviewHint,
          style: TextStyle(color: AppColors.textSecondary, height: 1.4)),
      const SizedBox(height: 14),
      for (final tx in pending)
        _PendingExpenseRow(
            key: ValueKey(tx.id),
            transaction: tx,
            categories: categories,
            onAssigned: onAssigned),
    ]);
  }
}

class _PendingExpenseRow extends StatefulWidget {
  const _PendingExpenseRow(
      {super.key,
      required this.transaction,
      required this.categories,
      this.onAssigned});
  final TransactionModel transaction;
  final List<CategoryModel> categories;
  final VoidCallback? onAssigned;
  @override
  State<_PendingExpenseRow> createState() => _PendingExpenseRowState();
}

class _PendingExpenseRowState extends State<_PendingExpenseRow> {
  bool _saving = false;
  String? _error;
  Future<void> _assign(String? id) async {
    if (_saving || id == null) return;
    final provider = context.read<TransactionProvider>();
    final category = widget.categories.where((c) => c.id == id).firstOrNull;
    if (category == null) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final callback = widget.onAssigned;
      await provider.assignPendingCategory(widget.transaction, category);
      callback?.call();
    } catch (_) {
      if (mounted) {
        setState(() => _error = context.l10n.categoryReviewSaveError);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tx = widget.transaction;
    final l10n = context.l10n;
    final fallback = context.watch<CurrencyProvider>().selectedCurrency;
    final currency = CurrencyProvider.supportedCurrencies
            .where((c) => c.code == tx.currencyCode)
            .firstOrNull ??
        fallback;
    final amount = NumberFormat.currency(
            locale: currency.locale,
            name: currency.code,
            decimalDigits: currency.code == 'COP' ? 0 : 2)
        .format(tx.amount);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: AppColors.backgroundAlt,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderSubtle)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(tx.title,
            style: TextStyle(
                color: AppColors.textPrimary, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text(
            '$amount · ${DateFormat.yMMMd(Localizations.localeOf(context).toLanguageTag()).format(tx.date.toLocal())}',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        const SizedBox(height: 12),
        if (_saving)
          const LinearProgressIndicator()
        else
          DropdownButtonFormField<String>(
            // Reset after a failed save: choosing the same category retries.
            key: ValueKey('${tx.id}-${tx.effectiveCategoryId}-${_error ?? ''}'),
            isExpanded: true,
            decoration: InputDecoration(
                labelText: l10n.chooseCategory,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
            items: [
              for (final c in widget.categories)
                DropdownMenuItem(
                    value: c.id,
                    child: Text(
                        c.isDefault
                            ? c.transactionCategory.localizedName(l10n)
                            : c.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis))
            ],
            onChanged: widget.categories.isEmpty ? null : _assign,
          ),
        if (_error != null)
          Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(_error!,
                  style: const TextStyle(color: AppColors.expenseColor))),
      ]),
    );
  }
}
