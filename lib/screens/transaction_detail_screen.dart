import '../widgets/billey_back_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n_extensions.dart';
import '../l10n/localization_helpers.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import '../providers/category_provider.dart';
import '../providers/currency_provider.dart';
import '../providers/transaction_provider.dart';
import '../theme/billey_theme_scope.dart';
import '../theme/colors/app_colors.dart';

/// Existing movements have their own manual editor. No recording, salary
/// prompts or income distribution runs while updating an existing movement.
class TransactionDetailScreen extends StatefulWidget {
  const TransactionDetailScreen({super.key, required this.transaction});
  final TransactionModel transaction;

  @override
  State<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.transaction.title);
  final _amount = TextEditingController();
  String? _initialAmount;
  CategoryModel? _category;
  bool _saving = false;

  bool get _canEdit =>
      widget.transaction.ownerId == null ||
      widget.transaction.ownerId == FirebaseAuth.instance.currentUser?.uid;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currency = context.read<CurrencyProvider>().selectedCurrency;
    // Preserve fractional amounts, including COP imports, without rounding them
    // just because the detail was opened and saved.
    _initialAmount ??= NumberFormat('#,##0.########', currency.locale)
        .format(widget.transaction.amount);
    if (_amount.text.isEmpty) _amount.text = _initialAmount!;
  }

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving || !_canEdit || !_form.currentState!.validate()) return;
    final original = widget.transaction;
    final amount = _amount.text == _initialAmount
        ? original.amount
        : context.read<CurrencyProvider>().parseValue(_amount.text)!;
    final updated = TransactionModel(
      id: original.id,
      title: _name.text.trim(),
      amount: amount,
      category: _category?.transactionCategory ?? original.category,
      categoryId: _category?.id ?? original.categoryId,
      currencyCode: original.currencyCode,
      date: original.date,
      type: original.type,
      description: original.description,
      sharedWith: original.sharedWith,
      ownerId: original.ownerId,
    );
    setState(() => _saving = true);
    try {
      await context.read<TransactionProvider>().editTransaction(updated);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.transactionSaveError)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    BilleyThemeScope.isDarkOf(context);
    final l10n = context.l10n;
    final transaction = widget.transaction;
    final currency = context.watch<CurrencyProvider>();
    final available = context.watch<CategoryProvider>().categories;
    final categories =
        available.isEmpty ? CategoryModel.getDefaultCategories() : available;
    final fallback = CategoryModel.getDefaultCategories()
        .firstWhere((c) => c.transactionCategory == transaction.category);
    final current = _category ??
        categories.firstWhere(
          (c) => c.id == transaction.effectiveCategoryId,
          orElse: () => fallback,
        );
    final options = [...categories];
    if (!options.any((c) => c.id == current.id)) options.add(current);
    final enabled = _canEdit && !_saving;
    final income = transaction.type == TransactionType.ingreso;
    final accent = income ? AppColors.incomeColor : AppColors.expenseColor;
    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      appBar: AppBar(
        leading:
            Navigator.of(context).canPop() ? const BilleyBackButton() : null,
        backgroundColor: AppColors.backgroundAlt,
        title: Text(l10n.transactionDetailsTitle),
        elevation: 0,
      ),
      body: Center(
          child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: Form(
          key: _form,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 36),
            children: [
              Center(
                  child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                    income
                        ? TablerIcons.arrow_down_left
                        : TablerIcons.arrow_up_right,
                    color: accent,
                    size: 30),
              )),
              const SizedBox(height: 18),
              Text(
                  currency.formatWithSign(transaction.amount, isIncome: income),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1)),
              const SizedBox(height: 8),
              Text(
                  '${income ? l10n.income : l10n.expenses} · ${DateFormat.yMMMd(Localizations.localeOf(context).toLanguageTag()).format(transaction.date)}',
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 30),
              _DetailPanel(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(l10n.transactionDataTitle,
                        style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _name,
                      enabled: enabled,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: _decoration(
                          l10n.transactionNameLabel, TablerIcons.pencil),
                      validator: (text) => (text?.trim().length ?? 0) < 3
                          ? l10n.conceptMinLength
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amount,
                      enabled: enabled,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: _decoration(
                              l10n.transactionAmountLabel, TablerIcons.coin)
                          .copyWith(suffixText: currency.selectedCurrency.code),
                      validator: (text) {
                        final value = text == _initialAmount
                            ? transaction.amount
                            : currency.parseValue(text ?? '');
                        return value == null || !value.isFinite || value <= 0
                            ? l10n.amountMustBePositive
                            : null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: current.id,
                      isExpanded: true,
                      decoration: _decoration(
                          l10n.chooseCategory, TablerIcons.category),
                      dropdownColor: AppColors.surfaceColor,
                      items: [
                        for (final category in options)
                          DropdownMenuItem(
                              value: category.id,
                              child: Row(children: [
                                Icon(category.icon,
                                    size: 19, color: category.color),
                                const SizedBox(width: 10),
                                Expanded(
                                    child: Text(
                                        category.isDefault
                                            ? category.transactionCategory
                                                .localizedName(l10n)
                                            : category.name,
                                        overflow: TextOverflow.ellipsis)),
                              ])),
                      ],
                      onChanged: !enabled
                          ? null
                          : (id) => setState(() {
                                _category =
                                    options.firstWhere((c) => c.id == id);
                              }),
                    ),
                  ])),
              if (transaction.description?.isNotEmpty ?? false) ...[
                const SizedBox(height: 16),
                _DetailPanel(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Row(children: [
                        const Icon(TablerIcons.notes,
                            color: AppColors.primaryColor, size: 20),
                        const SizedBox(width: 10),
                        Text(l10n.transactionNotesLabel,
                            style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w800)),
                      ]),
                      const SizedBox(height: 12),
                      SelectableText(transaction.description!,
                          style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              height: 1.6)),
                    ])),
              ],
              const SizedBox(height: 24),
              if (_canEdit)
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 17),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(TablerIcons.check, size: 20),
                  label: Text(l10n.save,
                      style: const TextStyle(fontWeight: FontWeight.w800)),
                )
              else
                Text(l10n.transactionSharedReadOnly,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.5)),
            ],
          ),
        ),
      )),
    );
  }

  InputDecoration _decoration(String label, IconData icon) => InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: AppColors.primaryColor),
        filled: true,
        fillColor: AppColors.surfaceInput,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
      );
}

class _DetailPanel extends StatelessWidget {
  const _DetailPanel({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
            color: AppColors.surfaceColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.borderSubtle)),
        child: child,
      );
}
