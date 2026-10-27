import '../models/financial_cycle.dart';
import '../providers/financial_cycle_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n_extensions.dart';
import '../l10n/localization_helpers.dart';
import '../models/category.dart';
import '../models/category_budget.dart';
import '../providers/budget_provider.dart';
import '../providers/income_distribution_provider.dart';
import '../providers/category_provider.dart';
import '../providers/currency_provider.dart';
import '../providers/transaction_provider.dart';
import '../theme/billey_theme_scope.dart';
import '../theme/colors/app_colors.dart';
import '../widgets/billey_back_button.dart';

class CategoryBudgetsScreen extends StatefulWidget {
  const CategoryBudgetsScreen({super.key});
  @override
  State<CategoryBudgetsScreen> createState() => _CategoryBudgetsScreenState();
}

class _CategoryBudgetsScreenState extends State<CategoryBudgetsScreen> {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  bool _copying = false;
  int? _cycleDay;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final cycle = context.watch<FinancialCycleProvider?>()?.cycle ??
        const FinancialCycle();
    if (_cycleDay != cycle.startDay) {
      _cycleDay = cycle.startDay;
      final start = cycle.containing(DateTime.now()).start;
      _month = DateTime(start.year, start.month);
    }
  }

  Future<void> _copy({bool next = false}) async {
    final provider = context.read<BudgetProvider>();
    final owner = provider.userId;
    if (owner == null || _copying) return;
    final currency = context.read<CurrencyProvider>().selectedCurrency.code;
    setState(() => _copying = true);
    try {
      final count = next
          ? await provider.copyNext(owner, _month, currency)
          : await provider.copyPrevious(owner, _month, currency);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.budgetCopied(count))));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.budgetSaveError)));
      }
    } finally {
      if (mounted) setState(() => _copying = false);
    }
  }

  Future<void> _edit(CategoryModel category, CategoryBudget? budget) async {
    final provider = context.read<BudgetProvider>();
    final owner = provider.userId;
    if (owner == null) return;
    final currency = context.read<CurrencyProvider>();
    final l10n = context.l10n;
    final name = category.isDefault
        ? category.transactionCategory.localizedName(l10n)
        : category.name;
    await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _BudgetEditor(
            owner: owner,
            category: category,
            categoryName: name,
            month: _month,
            currency: currency.selectedCurrency,
            existing: budget,
            canRemove: provider
                .forMonth(_month, currency.selectedCurrency.code)
                .any((b) => b.categoryId == category.id),
            provider: provider));
  }

  @override
  Widget build(BuildContext context) {
    BilleyThemeScope.isDarkOf(context);
    final l10n = context.l10n;
    final provider = context.watch<BudgetProvider>();
    final currency = context.watch<CurrencyProvider>();
    final categoryProvider = context.watch<CategoryProvider>();
    final distribution = context.watch<IncomeDistributionProvider?>();
    final cycle = context.watch<FinancialCycleProvider?>()?.cycle ??
        const FinancialCycle();
    final budgets = provider.effectiveForMonth(
        _month, currency.selectedCurrency.code,
        distribution: distribution,
        cycle: cycle,
        categories: categoryProvider.categories.isEmpty
            ? CategoryModel.getDefaultCategories()
            : categoryProvider.categories,
        transactions: context.watch<TransactionProvider>().allTransactions);
    final byId = {for (final b in budgets) b.categoryId: b};
    final spent = CategoryBudget.spending(
      transactions: context.watch<TransactionProvider>().allTransactions,
      month: _month,
      cycle: cycle,
      currency: currency.selectedCurrency.code,
      owner: provider.userId ?? '',
    );
    final categories = <String, CategoryModel>{
      for (final c in categoryProvider.categories.isEmpty
          ? CategoryModel.getDefaultCategories()
          : categoryProvider.categories)
        c.id: c,
    };
    // Budgets remain visible if a custom category isn't present on this device.
    for (final b in budgets) {
      categories.putIfAbsent(
          b.categoryId,
          () => CategoryModel(
              id: b.categoryId,
              name: b.categoryName,
              iconCodePoint: Icons.category.codePoint,
              colorValue: AppColors.primaryColor.toARGB32()));
    }
    for (final c in CategoryModel.getDefaultCategories()) {
      if (spent.containsKey(c.id)) categories.putIfAbsent(c.id, () => c);
    }
    final total = budgets.fold(0.0, (sum, b) => sum + b.limit);
    final tracked =
        budgets.fold(0.0, (sum, b) => sum + (spent[b.categoryId] ?? 0));
    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      appBar: AppBar(
          backgroundColor: AppColors.backgroundAlt,
          leading: const BilleyBackButton(),
          title: Text(l10n.monthlyBudgets),
          elevation: 0),
      body: Center(
          child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 36),
            children: [
              Row(children: [
                IconButton(
                    tooltip: l10n.budgetPreviousMonth,
                    onPressed: _copying || _month.year <= 1900
                        ? null
                        : () => setState(() =>
                            _month = DateTime(_month.year, _month.month - 1)),
                    icon: Icon(TablerIcons.chevron_left,
                        color: AppColors.textPrimary)),
                Expanded(
                    child: Text(
                        '${DateFormat.yMMMd(Localizations.localeOf(context).toLanguageTag()).format(cycle.forMonth(_month).start)} – ${DateFormat.yMMMd(Localizations.localeOf(context).toLanguageTag()).format(cycle.forMonth(_month).lastDay)}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w800))),
                IconButton(
                    tooltip: l10n.budgetNextMonth,
                    onPressed: _copying || _month.year >= 2999
                        ? null
                        : () => setState(() =>
                            _month = DateTime(_month.year, _month.month + 1)),
                    icon: Icon(TablerIcons.chevron_right,
                        color: AppColors.textPrimary)),
              ]),
              const SizedBox(height: 12),
              Text(
                  distribution?.autoEnabled == true
                      ? l10n.budgetAutomaticHint
                      : l10n.budgetIntro,
                  style: TextStyle(
                      color: AppColors.textSecondary,
                      height: 1.5,
                      fontSize: 13)),
              const SizedBox(height: 20),
              if (provider.userId == null)
                Text(l10n.budgetSignIn)
              else ...[
                _BudgetPanel(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(l10n.budgetPlanned,
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 13)),
                      const SizedBox(height: 6),
                      Text(currency.format(total),
                          style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.8)),
                      const SizedBox(height: 18),
                      _SummaryRow(
                          label: l10n.budgetTrackedSpend,
                          value: currency.format(tracked)),
                      const SizedBox(height: 8),
                      _SummaryRow(
                          label: total >= tracked
                              ? l10n.budgetAvailable
                              : l10n.budgetExceeded,
                          value: currency.format((total - tracked).abs()),
                          color: tracked > total
                              ? AppColors.expenseColor
                              : AppColors.primaryColor),
                    ])),
                const SizedBox(height: 14),
                OutlinedButton.icon(
                    onPressed:
                        _copying || !provider.loaded || _month.year <= 1900
                            ? null
                            : () => _copy(),
                    icon: _copying
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(TablerIcons.copy, size: 18),
                    label: Text(l10n.budgetCopyPrevious)),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                    onPressed:
                        _copying || !provider.loaded || _month.year >= 2999
                            ? null
                            : () => _copy(next: true),
                    icon: const Icon(TablerIcons.copy, size: 18),
                    label: Text(l10n.budgetCopyNext)),
                const SizedBox(height: 6),
                Text(l10n.budgetCopyHint,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: AppColors.textLight, fontSize: 12, height: 1.4)),
                const SizedBox(height: 22),
                if (!provider.loaded) const LinearProgressIndicator(),
                if (provider.hasError) ...[
                  Text(l10n.budgetLoadError,
                      style: const TextStyle(color: AppColors.expenseColor)),
                  TextButton(
                      onPressed: () => provider.bindUser(provider.userId),
                      child: Text(l10n.budgetRetry)),
                ],
                if (provider.loaded)
                  for (final c in categories.values) ...[
                    _BudgetCategoryCard(
                        category: c,
                        budget: byId[c.id],
                        spent: spent[c.id] ?? 0,
                        onTap: _copying || provider.hasError
                            ? null
                            : () => _edit(c, byId[c.id])),
                    const SizedBox(height: 12),
                  ],
                const SizedBox(height: 10),
                Text(l10n.budgetLegacyHint,
                    style: TextStyle(
                        color: AppColors.textLight, fontSize: 12, height: 1.5)),
              ],
            ]),
      )),
    );
  }
}

class _BudgetCategoryCard extends StatelessWidget {
  const _BudgetCategoryCard(
      {required this.category,
      required this.budget,
      required this.spent,
      required this.onTap});
  final CategoryModel category;
  final CategoryBudget? budget;
  final double spent;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final currency = context.watch<CurrencyProvider>();
    final limit = budget?.limit;
    final remaining = (limit ?? 0) - spent;
    final color = limit != null && spent > limit
        ? AppColors.expenseColor
        : limit != null && spent >= limit * 0.8
            ? AppColors.warningColor
            : AppColors.primaryColor;
    return Material(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: _BudgetPanel(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Row(children: [
                  Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                          color: category.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12)),
                      child:
                          Icon(category.icon, color: category.color, size: 22)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Text(
                          category.isDefault
                              ? category.transactionCategory.localizedName(l10n)
                              : category.name,
                          style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: 15))),
                  const SizedBox(width: 8),
                  const Icon(TablerIcons.pencil,
                      size: 19, color: AppColors.primaryColor),
                ]),
                const SizedBox(height: 16),
                Text(
                    limit == null
                        ? l10n.budgetNotSet
                        : l10n.budgetSpentOf(
                            currency.format(spent), currency.format(limit)),
                    style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                if (limit != null) ...[
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                      value: (spent / limit).clamp(0.0, 1.0),
                      minHeight: 7,
                      color: color,
                      backgroundColor: AppColors.surfaceInput,
                      borderRadius: BorderRadius.circular(8)),
                  const SizedBox(height: 9),
                  Text(
                      remaining >= 0
                          ? l10n.budgetRemaining(currency.format(remaining))
                          : l10n.budgetOverBy(currency.format(-remaining)),
                      style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.w700)),
                ] else ...[
                  const SizedBox(height: 6),
                  Text(l10n.budgetSpentOf(currency.format(spent), '—'),
                      style:
                          TextStyle(color: AppColors.textLight, fontSize: 12)),
                ],
              ])),
        ));
  }
}

class _BudgetEditor extends StatefulWidget {
  const _BudgetEditor(
      {required this.owner,
      required this.category,
      required this.categoryName,
      required this.month,
      required this.currency,
      required this.existing,
      required this.canRemove,
      required this.provider});
  final String owner, categoryName;
  final CategoryModel category;
  final DateTime month;
  final Currency currency;
  final CategoryBudget? existing;
  final bool canRemove;
  final BudgetProvider provider;
  @override
  State<_BudgetEditor> createState() => _BudgetEditorState();
}

class _BudgetEditorState extends State<_BudgetEditor> {
  final _form = GlobalKey<FormState>();
  late final _amount = TextEditingController(
      text: widget.existing == null
          ? ''
          : NumberFormat('#,##0.##', widget.currency.locale)
              .format(widget.existing!.limit));
  bool _busy = false;
  String? _error;
  double? _parse(String? text) {
    try {
      return NumberFormat.decimalPattern(widget.currency.locale)
          .parse(text ?? '')
          .toDouble();
    } on FormatException {
      return null;
    }
  }

  Future<void> _commit({bool remove = false}) async {
    if (_busy || (!remove && !_form.currentState!.validate())) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      if (remove) {
        await widget.provider.remove(widget.owner, widget.existing!);
      } else {
        await widget.provider.save(
            widget.owner,
            CategoryBudget(
              month: CategoryBudget.monthKey(widget.month),
              categoryId: widget.category.id,
              categoryName: widget.categoryName,
              currency: widget.currency.code,
              limit: _parse(_amount.text)!,
            ));
      }
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = context.l10n.budgetSaveError;
        });
      }
    }
  }

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return PopScope(
        canPop: !_busy,
        child: Container(
          padding: EdgeInsets.fromLTRB(
              24, 22, 24, 24 + MediaQuery.viewInsetsOf(context).bottom),
          decoration: BoxDecoration(
              color: AppColors.surfaceColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24))),
          child: SafeArea(
              top: false,
              child: Form(
                  key: _form,
                  child: SingleChildScrollView(
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.budgetEditTitle,
                              style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 21,
                                  fontWeight: FontWeight.w900)),
                          const SizedBox(height: 8),
                          Text(
                              '${widget.categoryName} · ${DateFormat.yMMMM(Localizations.localeOf(context).toLanguageTag()).format(widget.month)}',
                              style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13)),
                          const SizedBox(height: 22),
                          TextFormField(
                              controller: _amount,
                              enabled: !_busy,
                              autofocus: true,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              decoration: InputDecoration(
                                  labelText: l10n.transactionAmountLabel,
                                  prefixText: '${widget.currency.symbol} ',
                                  suffixText: widget.currency.code,
                                  filled: true,
                                  fillColor: AppColors.surfaceInput,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none)),
                              validator: (text) {
                                final amount = _parse(text);
                                return amount == null ||
                                        !amount.isFinite ||
                                        amount <= 0 ||
                                        amount > 1e12
                                    ? l10n.budgetInvalidAmount
                                    : null;
                              }),
                          if (_error != null)
                            Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Text(_error!,
                                    style: const TextStyle(
                                        color: AppColors.expenseColor))),
                          const SizedBox(height: 20),
                          SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                  style: FilledButton.styleFrom(
                                      backgroundColor: AppColors.primaryColor,
                                      foregroundColor: AppColors.white,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(14))),
                                  onPressed: _busy ? null : () => _commit(),
                                  child: _busy
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white))
                                      : Text(l10n.save))),
                          if (widget.existing != null && widget.canRemove)
                            Center(
                                child: TextButton(
                                    onPressed: _busy
                                        ? null
                                        : () => _commit(remove: true),
                                    child: Text(l10n.budgetRemove,
                                        style: const TextStyle(
                                            color: AppColors.expenseColor)))),
                        ]),
                  ))),
        ));
  }
}

class _BudgetPanel extends StatelessWidget {
  const _BudgetPanel({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderSubtle)),
      child: child);
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value, this.color});
  final String label, value;
  final Color? color;
  @override
  Widget build(BuildContext context) => Row(children: [
        Expanded(
            child: Text(label,
                style:
                    TextStyle(color: AppColors.textSecondary, fontSize: 12))),
        const SizedBox(width: 12),
        Text(value,
            style: TextStyle(
                color: color ?? AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w800)),
      ]);
}
