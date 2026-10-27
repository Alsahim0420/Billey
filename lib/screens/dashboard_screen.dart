import '../widgets/route_entrance_mixin.dart';
import '../widgets/chart_reveal.dart';
import '../widgets/budget_spend_bar.dart';
import '../widgets/animated_value_visibility.dart';
import '../providers/amount_visibility_provider.dart';
import '../models/financial_cycle.dart';
import '../providers/financial_cycle_provider.dart';
import 'financial_cycle_screen.dart';
import 'dart:math' as math;

import 'package:billey/l10n/l10n_extensions.dart';
import 'package:billey/providers/currency_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../l10n/localization_helpers.dart';
import '../models/transaction.dart';
import '../models/transaction_category_display.dart';
import '../models/category_budget.dart';
import '../providers/budget_provider.dart';
import '../providers/income_distribution_provider.dart';
import '../models/category.dart';
import '../providers/category_provider.dart';
import '../providers/couple_link_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/transaction_provider.dart';
import '../theme/colors/app_colors.dart';
import '../widgets/owner_avatar.dart';
import '../widgets/billey_pull_to_refresh.dart';
import '../widgets/monthly_period_builder.dart';
import '../theme/billey_theme_scope.dart';
import 'transaction_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, this.onViewAllTransactions});

  final VoidCallback? onViewAllTransactions;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _animationRevision = 0;
  @override
  Widget build(BuildContext context) {
    BilleyThemeScope.isDarkOf(context);
    return MonthlyPeriodBuilder(
        builder: (context, month) => Scaffold(
              backgroundColor: AppColors.backgroundColor,
              body: SafeArea(
                child: Consumer2<TransactionProvider, ProfileProvider>(
                  builder: (context, provider, profile, child) {
                    final currencyProvider =
                        Provider.of<CurrencyProvider>(context, listen: false);
                    final cycle =
                        context.watch<FinancialCycleProvider?>()?.cycle ??
                            const FinancialCycle();
                    final movements = provider.personalTransactions
                        .where((t) => cycle.forMonth(month).contains(t.date));
                    final totalIncome = movements
                        .where((t) => t.type == TransactionType.ingreso)
                        .fold(0.0, (s, t) => s + t.amount);
                    final totalExpenses = movements
                        .where((t) => t.type == TransactionType.gasto)
                        .fold(0.0, (s, t) => s + t.amount);
                    // Leftover money from previous cycles carries over;
                    // only the income/expense totals and charts reset.
                    final carryOver = provider.personalTransactions
                        .where((t) => t.date
                            .toLocal()
                            .isBefore(cycle.forMonth(month).start))
                        .fold(
                            0.0,
                            (s, t) => t.type == TransactionType.ingreso
                                ? s + t.amount
                                : s - t.amount);
                    final balance = carryOver + totalIncome - totalExpenses;
                    final recentTransactions =
                        provider.transactions.take(4).toList();

                    return BilleyPullToRefresh(
                      onRefresh: () async {
                        final budgets = context.read<BudgetProvider>();
                        await Future.wait([
                          provider.loadTransactions(),
                          profile.load(),
                          budgets.refresh(),
                        ]);
                        if (mounted) setState(() => _animationRevision++);
                      },
                      builder: (context, physics) => SingleChildScrollView(
                        physics: physics,
                        padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _HomeHeader(
                              greeting: profile.greetingForHour(
                                DateTime.now().hour,
                                context.l10n,
                              ),
                              avatarUrl:
                                  profile.hasAvatar ? profile.avatarUrl : null,
                            ),
                            const SizedBox(height: 44),
                            _TotalBalance(
                                key: ValueKey('balance_$_animationRevision'),
                                balance: balance,
                                carryOver: carryOver,
                                currency: currencyProvider,
                                month: month),
                            TextButton.icon(
                              onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const FinancialCycleScreen())),
                              icon: const Icon(Icons.calendar_month_outlined,
                                  size: 18),
                              label: Text(context
                                          .watch<FinancialCycleProvider?>()
                                          ?.configured ==
                                      true
                                  ? (Localizations.localeOf(context)
                                              .languageCode ==
                                          'en'
                                      ? 'Change cycle'
                                      : 'Cambiar ciclo')
                                  : (Localizations.localeOf(context)
                                              .languageCode ==
                                          'en'
                                      ? 'Configure your cycle'
                                      : 'Configura tu ciclo')),
                            ),
                            const SizedBox(height: 18),
                            Row(
                              children: [
                                Expanded(
                                  child: _MetricCard(
                                    key: ValueKey('income_$_animationRevision'),
                                    label: context.l10n.income,
                                    amount: totalIncome,
                                    color: AppColors.incomeColor,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _MetricCard(
                                    key: ValueKey(
                                        'expenses_$_animationRevision'),
                                    label: context.l10n.expenses,
                                    amount: totalExpenses,
                                    color: AppColors.expenseColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            _HomeAnalyticsChart(
                              animationRevision: _animationRevision,
                              transactions: provider.allTransactions,
                              personalTransactions:
                                  provider.personalTransactions,
                            ),
                            const SizedBox(height: 26),
                            _RecentTransactions(
                              onViewAll: widget.onViewAllTransactions,
                              transactions: recentTransactions,
                              currencyProvider: currencyProvider,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ));
  }
}

enum _HomeChartMode { monthlyTrend, expensesByCategory, expensesByPerson }

enum _HomeChartPeriod { thisMonth, lastMonth }

class _HomeAnalyticsChart extends StatefulWidget {
  const _HomeAnalyticsChart(
      {required this.transactions,
      required this.personalTransactions,
      this.animationRevision = 0});

  final List<TransactionModel> transactions;
  final List<TransactionModel> personalTransactions;
  final int animationRevision;

  @override
  State<_HomeAnalyticsChart> createState() => _HomeAnalyticsChartState();
}

class _HomeAnalyticsChartState extends State<_HomeAnalyticsChart> {
  static const int _chartMonthsCount = 6;

  _HomeChartMode _mode = _HomeChartMode.expensesByCategory;
  _HomeChartPeriod _period = _HomeChartPeriod.thisMonth;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final currency = context.watch<CurrencyProvider>();
    final couple = context.watch<CoupleLinkProvider>();
    final profile = context.watch<ProfileProvider>();
    final isBreakdown = _mode != _HomeChartMode.monthlyTrend;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _FilterChipRow(
                children: [
                  _FilterChip(
                    label: l10n.homeChartByCategory,
                    selected: _mode == _HomeChartMode.expensesByCategory,
                    onTap: () => setState(
                      () => _mode = _HomeChartMode.expensesByCategory,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: l10n.homeChartTrend,
                    selected: _mode == _HomeChartMode.monthlyTrend,
                    onTap: () => setState(
                      () => _mode = _HomeChartMode.monthlyTrend,
                    ),
                  ),
                  if (couple.isLinked) ...[
                    const SizedBox(width: 8),
                    _FilterChip(
                      label: l10n.homeChartByPerson,
                      selected: _mode == _HomeChartMode.expensesByPerson,
                      onTap: () => setState(
                        () => _mode = _HomeChartMode.expensesByPerson,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        if (isBreakdown) ...[
          const SizedBox(height: 10),
          _FilterChipRow(
            children: [
              _FilterChip(
                label: Localizations.localeOf(context).languageCode == 'en'
                    ? 'This cycle'
                    : 'Este ciclo',
                selected: _period == _HomeChartPeriod.thisMonth,
                onTap: () => setState(
                  () => _period = _HomeChartPeriod.thisMonth,
                ),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: Localizations.localeOf(context).languageCode == 'en'
                    ? 'Previous cycle'
                    : 'Ciclo anterior',
                selected: _period == _HomeChartPeriod.lastMonth,
                onTap: () => setState(
                  () => _period = _HomeChartPeriod.lastMonth,
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 16),
        if (_mode == _HomeChartMode.monthlyTrend)
          _MonthlyTrendContent(data: _monthlyChartData())
        else
          _BreakdownContent(
            animationRevision: widget.animationRevision,
            showBudgets: _mode == _HomeChartMode.expensesByCategory,
            title: _mode == _HomeChartMode.expensesByCategory
                ? l10n.expensesByCategory
                : l10n.sharedComparisonTitle,
            data: _mode == _HomeChartMode.expensesByCategory
                ? _categoryChartData(l10n)
                : _personChartData(l10n, couple, profile),
            periodLabel: _periodLabel(l10n),
            currency: currency,
          ),
      ],
    );
  }

  FinancialCycle get _cycle =>
      context.watch<FinancialCycleProvider?>()?.cycle ?? const FinancialCycle();

  DateTime get _selectedMonth {
    final now = _cycle.containing(DateTime.now()).start;
    if (_period == _HomeChartPeriod.thisMonth) {
      return DateTime(now.year, now.month);
    }
    return DateTime(now.year, now.month - 1);
  }

  String _periodLabel(AppLocalizations l10n) {
    final period = _cycle.forMonth(_selectedMonth);
    final format =
        DateFormat.yMMMd(Localizations.localeOf(context).toLanguageTag());
    return '${format.format(period.start)} – ${format.format(period.lastDay)}';
  }

  _MonthlyChartData _monthlyChartData() {
    final now = _cycle.containing(DateTime.now()).start;
    final spots = <FlSpot>[];
    final labels = <String>[];
    final locale = Localizations.localeOf(context).toString();

    for (var i = _chartMonthsCount - 1; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final balance = _monthlyBalance(month);
      spots.add(FlSpot((_chartMonthsCount - 1 - i).toDouble(), balance));
      labels.add(_formatMonthLabel(month, locale));
    }

    return _MonthlyChartData(
      spots: spots,
      monthLabels: labels,
      trendLabel: _formatMonthTrend(spots),
    );
  }

  double _monthlyBalance(DateTime month) {
    final monthTransactions = widget.personalTransactions.where((transaction) {
      return _cycle.forMonth(month).contains(transaction.date);
    });

    final income = monthTransactions
        .where((transaction) => transaction.type == TransactionType.ingreso)
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
    final expenses = monthTransactions
        .where((transaction) => transaction.type == TransactionType.gasto)
        .fold(0.0, (sum, transaction) => sum + transaction.amount);

    return income - expenses;
  }

  List<TransactionModel> _expensesInSelectedMonth() {
    final month = _selectedMonth;
    return widget.transactions.where((transaction) {
      return transaction.type == TransactionType.gasto &&
          _cycle.forMonth(month).contains(transaction.date);
    }).toList();
  }

  _BreakdownChartData _categoryChartData(AppLocalizations l10n) {
    final currency = context.watch<CurrencyProvider>().selectedCurrency.code;
    final budgetsProvider = context.watch<BudgetProvider>();
    final categories = context.watch<CategoryProvider>().allCategories;
    final owner = budgetsProvider.userId;
    final totals = CategoryBudget.spending(
      transactions: widget.transactions,
      month: _selectedMonth,
      cycle: _cycle,
      currency: currency,
      owner: owner ?? '',
    );
    final budgets = {
      if (owner != null && budgetsProvider.userId == owner)
        for (final b in budgetsProvider.effectiveForMonth(
            _selectedMonth, currency,
            distribution: context.watch<IncomeDistributionProvider?>(),
            cycle: _cycle,
            categories: categories.isEmpty
                ? CategoryModel.getDefaultCategories()
                : categories,
            transactions: widget.transactions))
          b.categoryId: b,
    };
    final items = <_SpendItem>[];
    for (final id in {...totals.keys, ...budgets.keys}) {
      final category = categories.where((c) => c.id == id).firstOrNull;
      final legacy =
          TransactionCategory.values.where((c) => c.name == id).firstOrNull;
      items.add(_SpendItem(
        label: category?.isDefault == false
            ? category!.name
            : legacy?.localizedName(l10n) ??
                category?.name ??
                budgets[id]?.categoryName ??
                TransactionCategory.other.localizedName(l10n),
        icon: category?.icon ??
            _categoryIcon(legacy ?? TransactionCategory.other),
        amount: totals[id] ?? 0,
        color: category?.color ??
            _categoryColor(legacy ?? TransactionCategory.other),
        budget: budgets[id]?.limit,
      ));
    }
    items.sort((a, b) => b.amount.compareTo(a.amount));

    final total = items.fold(0.0, (sum, item) => sum + item.amount);
    return _BreakdownChartData(items: items, total: total);
  }

  _BreakdownChartData _personChartData(
    AppLocalizations l10n,
    CoupleLinkProvider couple,
    ProfileProvider profile,
  ) {
    final myUid =
        context.read<TransactionProvider>().firestoreService?.currentUser?.uid;
    double mine = 0;
    double partner = 0;
    for (final transaction in _expensesInSelectedMonth()) {
      final isMine =
          transaction.ownerId == null || transaction.ownerId == myUid;
      if (isMine) {
        mine += transaction.amount;
      } else {
        partner += transaction.amount;
      }
    }

    final partnerName = couple.partnerDisplayName?.trim().isNotEmpty == true
        ? couple.partnerDisplayName!.trim()
        : l10n.defaultUser;

    final items = <_SpendItem>[
      if (mine > 0)
        _SpendItem(
          label: l10n.youLabel,
          icon: TablerIcons.user,
          amount: mine,
          color: AppColors.primaryColor,
          isMine: true,
          avatarUrl: profile.hasAvatar ? profile.avatarUrl : null,
        ),
      if (partner > 0)
        _SpendItem(
          label: partnerName,
          icon: TablerIcons.user,
          amount: partner,
          color: AppColors.infoColor,
          isMine: false,
          avatarUrl: couple.partnerPhotoUrl,
        ),
    ]..sort((a, b) => b.amount.compareTo(a.amount));

    final total = items.fold(0.0, (sum, item) => sum + item.amount);
    return _BreakdownChartData(items: items, total: total);
  }

  String _formatMonthLabel(DateTime date, String locale) {
    final label = DateFormat('MMM', locale).format(date);
    final cleaned = label.replaceAll('.', '').trim();
    if (cleaned.isEmpty) return '';
    return cleaned.length >= 3
        ? cleaned.substring(0, 3).toUpperCase()
        : cleaned.toUpperCase();
  }

  String? _formatMonthTrend(List<FlSpot> spots) {
    if (spots.length < 2) return null;

    final previous = spots[spots.length - 2].y;
    final current = spots.last.y;

    if (previous == 0) {
      if (current == 0) return null;
      return current > 0 ? '+100%' : '-100%';
    }

    final change = ((current - previous) / previous.abs()) * 100;
    final sign = change >= 0 ? '+' : '';
    return '$sign${change.toStringAsFixed(1)}%';
  }

  Color _categoryColor(TransactionCategory category) {
    return switch (category) {
      TransactionCategory.food => AppColors.insightsFoodColor,
      TransactionCategory.transport => const Color(0xFF64748B),
      TransactionCategory.entertainment => const Color(0xFF5DF3E6),
      TransactionCategory.health => AppColors.infoColor,
      TransactionCategory.education => AppColors.categoryEducation,
      TransactionCategory.other => AppColors.primaryColor,
    };
  }

  IconData _categoryIcon(TransactionCategory category) {
    return switch (category) {
      TransactionCategory.food => TablerIcons.bowl_chopsticks,
      TransactionCategory.transport => TablerIcons.car,
      TransactionCategory.entertainment => TablerIcons.movie,
      TransactionCategory.health => TablerIcons.heart,
      TransactionCategory.education => TablerIcons.school,
      TransactionCategory.other => TablerIcons.receipt,
    };
  }
}

class _FilterChipRow extends StatelessWidget {
  const _FilterChipRow({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: children),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppColors.primaryColor.withValues(alpha: 0.12)
          : AppColors.backgroundAlt,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? AppColors.primaryColor : AppColors.borderSubtle,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color:
                  selected ? AppColors.primaryColor : AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _MonthlyTrendContent extends StatelessWidget {
  const _MonthlyTrendContent({required this.data});

  final _MonthlyChartData data;

  List<FlSpot> get spots => data.spots;

  @override
  Widget build(BuildContext context) {
    final values = spots.map((spot) => spot.y).toList();
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final range = (maxValue - minValue).abs();
    final chartMinY = minValue - (range == 0 ? 10 : range * 0.22);
    final chartMaxY = maxValue + (range == 0 ? 10 : range * 0.18);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                context.l10n.recentMonths,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.35,
                ),
              ),
            ),
            if (data.trendLabel != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      data.trendLabel!.startsWith('-')
                          ? Icons.trending_down_rounded
                          : Icons.trending_up_rounded,
                      color: AppColors.primaryColor,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      context.watch<AmountVisibilityProvider?>()?.hidden == true
                          ? '•••'
                          : data.trendLabel!,
                      style: const TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 220,
          child: LineChart(
            LineChartData(
              minX: spots.first.x,
              maxX: spots.last.x,
              minY: chartMinY,
              maxY: chartMaxY,
              gridData: const FlGridData(show: false),
              titlesData: const FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              lineTouchData: const LineTouchData(enabled: false),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  preventCurveOverShooting: true,
                  color: AppColors.primaryColor,
                  barWidth: 3,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.primaryColor.withValues(alpha: 0.28),
                        AppColors.primaryColor.withValues(alpha: 0.02),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children:
              data.monthLabels.map((label) => _ChartLabel(label)).toList(),
        ),
      ],
    );
  }
}

class _BreakdownContent extends StatelessWidget {
  const _BreakdownContent({
    required this.title,
    required this.data,
    required this.periodLabel,
    required this.currency,
    this.showBudgets = false,
    this.animationRevision = 0,
  });

  final String title;
  final _BreakdownChartData data;
  final String periodLabel;
  final CurrencyProvider currency;
  final bool showBudgets;
  final int animationRevision;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!showBudgets) ...[
                    Text(
                      title,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.35,
                      ),
                    ),
                    const SizedBox(height: 2),
                  ],
                  Text(
                    periodLabel,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            if (data.total > 0)
              Text(
                context.watch<AmountVisibilityProvider?>()?.hidden == true
                    ? '••••••'
                    : currency.format(data.total),
                style: const TextStyle(
                  color: AppColors.expenseColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
          ],
        ),
        const SizedBox(height: 14),
        if (showBudgets) ...[
          if (context.watch<BudgetProvider>().hasError)
            Text(l10n.budgetLoadError,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12))
          else if (!context.watch<BudgetProvider>().loaded)
            const LinearProgressIndicator()
          else if (!data.items.any((i) => i.budget != null))
            Text(
                Localizations.localeOf(context).languageCode == 'en'
                    ? 'No budget limits for this cycle. Open budgets to review your limits and automatic distribution.'
                    : 'No hay límites de presupuesto para este ciclo. Abre Presupuestos para revisar tus límites y la distribución automática.',
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 12, height: 1.4)),
          const SizedBox(height: 8),
        ],
        if (data.items.isEmpty)
          _ChartEmptyState(message: l10n.noExpensesInPeriod)
        else ...[
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: FractionallySizedBox(
                widthFactor: 1,
                child: Container(
                  height: 432,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: AppColors.isDarkMode
                        ? AppColors.surfaceColor
                        : AppColors.backgroundAlt,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  // The bars scroll inside this bounded viewport; headings,
                  // filters and the breakdown below remain stationary.
                  child: ChartReveal(
                    key: ValueKey(
                      '$animationRevision-$title-$periodLabel-${data.items.map((i) => '${i.amount}:${i.budget}').join(',')}',
                    ),
                    animationBuilder: (context, animation) =>
                        _BreakdownBarChart(
                            data: data, progress: 1, animation: animation),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            l10n.topCategories,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          for (final item in data.items.take(4))
            _SpendRow(item: item, total: data.total, currency: currency),
        ],
      ],
    );
  }
}

/// Compacts an amount to at most 3 significant digits plus a K/M suffix
/// (e.g. 250000 → "250K", 1250000 → "1.3M") for labels too small to fit a
/// full currency-formatted number, like the value shown above each bar.
String _compactAmount(double amount) {
  final abs = amount.abs();
  final sign = amount < 0 ? '-' : '';
  if (abs >= 1000000) {
    final value = abs / 1000000;
    final formatted =
        value >= 100 ? value.toStringAsFixed(0) : value.toStringAsFixed(1);
    return '$sign${formatted}M';
  }
  if (abs >= 1000) {
    return '$sign${(abs / 1000).round()}K';
  }
  return '$sign${abs.round()}';
}

class _BreakdownBarChart extends StatelessWidget {
  const _BreakdownBarChart(
      {required this.data, required this.progress, this.animation});

  final _BreakdownChartData data;
  final double progress;
  final Animation<double>? animation;

  @override
  Widget build(BuildContext context) {
    if (data.items.any((item) => item.budget != null) ||
        data.items.every((item) => item.isMine == null)) {
      return _BudgetComparisonBars(
          data: data, progress: progress, animation: animation);
    }
    final maxAmount = data.items
        .map((item) => item.amount)
        .fold(0.0, (max, value) => value > max ? value : max);

    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(top: 8, bottom: 12),
        child: SizedBox(
          // Each category keeps enough room for its bar, value and icon.
          // Overflow scrolls instead of squeezing the chart into the viewport.
          width: math.max(constraints.maxWidth, data.items.length * 104.0),
          height: constraints.maxHeight - 20,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              // Extra headroom above the tallest bar so its always-on value
              // label (below) has room to sit above the bar instead of clipping.
              maxY: maxAmount * 1.35,
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barTouchData: BarTouchData(
                enabled: false,
                touchTooltipData: BarTouchTooltipData(
                  tooltipPadding: EdgeInsets.zero,
                  tooltipMargin: 10,
                  direction: TooltipDirection.top,
                  getTooltipColor: (_) => Colors.transparent,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final item = data.items[group.x];
                    return BarTooltipItem(
                      context.watch<AmountVisibilityProvider?>()?.hidden == true
                          ? '••••••'
                          : _compactAmount(item.amount),
                      TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                leftTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= data.items.length) {
                        return const SizedBox.shrink();
                      }
                      final item = data.items[index];
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: item.isMine != null
                            ? OwnerAvatar(
                                name: item.label,
                                isMine: item.isMine!,
                                photoUrl: item.avatarUrl,
                                size: 22,
                              )
                            : Icon(
                                item.icon,
                                color: item.color,
                                size: 18,
                              ),
                      );
                    },
                  ),
                ),
              ),
              barGroups: [
                for (var i = 0; i < data.items.length; i++)
                  BarChartGroupData(
                    x: i,
                    showingTooltipIndicators: const [0],
                    barRods: [
                      BarChartRodData(
                        toY: data.items[i].amount * progress,
                        color: data.items[i].color,
                        width: 64,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Shared monetary scale: the line marks the limit, the fill is actual spend.
class _BudgetComparisonBars extends StatelessWidget {
  const _BudgetComparisonBars(
      {required this.data, required this.progress, this.animation});
  final _BreakdownChartData data;
  final double progress;
  final Animation<double>? animation;

  @override
  Widget build(BuildContext context) {
    final currency = context.watch<CurrencyProvider>();
    final hidden = context.watch<AmountVisibilityProvider?>()?.hidden == true;
    String money(double value) => hidden ? '••••••' : currency.format(value);
    String compact(double value) =>
        hidden ? '••••••' : currency.formatCompact(value);
    final l10n = context.l10n;
    final maxValue = data.items.fold<double>(
        1,
        (value, item) =>
            math.max(value, math.max(item.amount, item.budget ?? 0)));
    return LayoutBuilder(builder: (context, constraints) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: SizedBox(
          width: math.max(constraints.maxWidth, data.items.length * 94.0),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            for (final item in data.items)
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Tooltip(
                  triggerMode: TooltipTriggerMode.tap,
                  message: item.budget == null
                      ? '${item.label}: ${money(item.amount)}'
                      : '${item.label}\n${l10n.budgetSpentOf(money(item.amount), money(item.budget!))}\n${item.amount > item.budget! ? l10n.budgetOverBy(money(item.amount - item.budget!)) : l10n.budgetRemaining(money(item.budget! - item.amount))}',
                  child: BudgetBarLayout(
                    width: 88,
                    header: const SizedBox.shrink(),
                    bar: BudgetBarDetails(
                      budget: item.budget,
                      amount: item.amount,
                      maximum: maxValue,
                      progress: progress,
                      animation: animation,
                      color: item.color,
                      icon: item.icon,
                      amountLabel: compact(item.amount * progress),
                      amountFormatter: compact,
                      bar: BudgetSpendBar(
                        amount: item.amount,
                        budget: item.budget,
                        maximum: maxValue,
                        color: item.color,
                        progress: progress,
                        animation: animation,
                        semanticLabel: item.budget == null
                            ? '${item.label}: ${money(item.amount)}'
                            : '${item.label}: ${l10n.budgetSpentOf(money(item.amount), money(item.budget!))}',
                      ),
                    ),
                    footer: Column(mainAxisSize: MainAxisSize.min, children: [
                      Text(item.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 10,
                              fontWeight: FontWeight.w700)),
                      Text(
                          item.budget != null && item.amount > item.budget!
                              ? (hidden
                                  ? '••••••'
                                  : '+${compact(item.amount - item.budget!)}')
                              : ' ',
                          maxLines: 1,
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Color.lerp(
                                  item.color, AppColors.textPrimary, 0.35))),
                    ]),
                  ),
                ),
              )),
          ]),
        ),
      );
    });
  }
}

class _SpendRow extends StatelessWidget {
  const _SpendRow({
    required this.item,
    required this.total,
    required this.currency,
  });

  final _SpendItem item;
  final double total;
  final CurrencyProvider currency;

  @override
  Widget build(BuildContext context) {
    final percentage = total == 0 ? 0 : (item.amount / total * 100);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: item.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            context.watch<AmountVisibilityProvider?>()?.hidden == true
                ? '•••'
                : '${percentage.round()}%',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            context.watch<AmountVisibilityProvider?>()?.hidden == true
                ? '••••••'
                : currency.format(item.amount),
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartEmptyState extends StatelessWidget {
  const _ChartEmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 36),
      decoration: BoxDecoration(
        color: AppColors.backgroundAlt,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SpendItem {
  const _SpendItem({
    required this.label,
    required this.icon,
    required this.amount,
    required this.color,
    this.isMine,
    this.avatarUrl,
    this.budget,
  });

  final String label;
  final IconData icon;
  final double amount;
  final Color color;
  final double? budget;

  /// Set only for "by person" items — null keeps category items on their
  /// plain category icon in the bar chart's axis instead of an avatar.
  final bool? isMine;
  final String? avatarUrl;
}

class _BreakdownChartData {
  const _BreakdownChartData({
    required this.items,
    required this.total,
  });

  final List<_SpendItem> items;
  final double total;
}

class _MonthlyChartData {
  final List<FlSpot> spots;
  final List<String> monthLabels;
  final String? trendLabel;

  const _MonthlyChartData({
    required this.spots,
    required this.monthLabels,
    this.trendLabel,
  });
}

class _HomeHeader extends StatelessWidget {
  final String greeting;
  final String? avatarUrl;

  const _HomeHeader({
    required this.greeting,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.welcomeBack,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                greeting,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.55,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withValues(alpha: 0.12),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.borderSubtle, width: 1.2),
          ),
          child: ClipOval(
            child: avatarUrl != null
                ? Image.network(
                    avatarUrl!,
                    fit: BoxFit.cover,
                    width: 52,
                    height: 52,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.person_rounded,
                      color: AppColors.primaryColor,
                      size: 30,
                    ),
                  )
                : const Icon(
                    Icons.person_rounded,
                    color: AppColors.primaryColor,
                    size: 30,
                  ),
          ),
        ),
      ],
    );
  }
}

class _TotalBalance extends StatelessWidget {
  final double balance;
  final double carryOver;
  final CurrencyProvider currency;
  final DateTime month;

  const _TotalBalance({
    super.key,
    required this.balance,
    required this.carryOver,
    required this.currency,
    required this.month,
  });

  @override
  Widget build(BuildContext context) {
    final isNegative = balance < 0;
    return Center(
      child: Column(
        children: [
          Text(
            '${Localizations.localeOf(context).languageCode == 'en' ? 'Available balance' : 'Saldo disponible'} · ${DateFormat.MMMd(Localizations.localeOf(context).toLanguageTag()).format((context.watch<FinancialCycleProvider?>()?.cycle ?? const FinancialCycle()).forMonth(month).start)} – ${DateFormat.MMMd(Localizations.localeOf(context).toLanguageTag()).format((context.watch<FinancialCycleProvider?>()?.cycle ?? const FinancialCycle()).forMonth(month).lastDay)}',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          IconButton(
            tooltip: context.watch<AmountVisibilityProvider?>()?.hidden == true
                ? (Localizations.localeOf(context).languageCode == 'en'
                    ? 'Show amounts'
                    : 'Mostrar valores')
                : (Localizations.localeOf(context).languageCode == 'en'
                    ? 'Hide amounts'
                    : 'Ocultar valores'),
            onPressed: () => context.read<AmountVisibilityProvider>().toggle(),
            icon: Icon(
                context.watch<AmountVisibilityProvider?>()?.hidden == true
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppColors.textSecondary,
                size: 22),
          ),
          _AnimatedCurrencyText(
            value: balance,
            formatter: currency.format,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color:
                  isNegative ? AppColors.expenseColor : AppColors.textPrimary,
              fontSize: 40,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.2,
              height: 1.0,
            ),
          ),
          if (carryOver.abs() >= 0.005) ...[
            const SizedBox(height: 8),
            Text(
              '${Localizations.localeOf(context).languageCode == 'en' ? 'Carried over from previous cycles' : 'Sobrante de ciclos anteriores'}: ${context.watch<AmountVisibilityProvider?>()?.hidden == true ? '••••••' : currency.format(carryOver)}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: carryOver < 0
                    ? AppColors.expenseColor
                    : AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Counts up (or down) to [value] from whatever it last displayed —
/// animates from 0 on first mount, and smoothly from the old to the new
/// value on later rebuilds (e.g. after a transaction changes a total).
class _AnimatedCurrencyText extends StatefulWidget {
  const _AnimatedCurrencyText({
    required this.value,
    required this.formatter,
    required this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  final double value;
  final String Function(double) formatter;
  final TextStyle style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  State<_AnimatedCurrencyText> createState() => _AnimatedCurrencyTextState();
}

class _AnimatedCurrencyTextState extends State<_AnimatedCurrencyText>
    with
        SingleTickerProviderStateMixin,
        RouteEntranceMixin<_AnimatedCurrencyText> {
  late final AnimationController _controller;
  double _from = 0;
  double get _value =>
      _from +
      (widget.value - _from) * Curves.easeOutCubic.transform(_controller.value);
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
  }

  @override
  void startEntranceAnimation() => _controller.forward();
  @override
  void didUpdateWidget(covariant _AnimatedCurrencyText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _from = _from +
          (oldWidget.value - _from) *
              Curves.easeOutCubic.transform(_controller.value);
      _controller.reset();
      if (entranceStarted) _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hidden = context.watch<AmountVisibilityProvider?>()?.hidden == true;
    return AnimatedValueVisibility(
      hidden: hidden,
      alignment: widget.textAlign == TextAlign.center
          ? Alignment.center
          : Alignment.centerLeft,
      replacement: Text('••••••',
          textAlign: widget.textAlign,
          maxLines: widget.maxLines,
          overflow: widget.overflow,
          style: widget.style),
      child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => Text(widget.formatter(_value),
              textAlign: widget.textAlign,
              maxLines: widget.maxLines,
              overflow: widget.overflow,
              style: widget.style)),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;

  const _MetricCard({
    super.key,
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final currency = context.watch<CurrencyProvider>();
    final symbol = currency.selectedCurrency.symbol;

    return Container(
      height: 108,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                symbol,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          _AnimatedCurrencyText(
            value: amount,
            formatter: currency.formatValue,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 21,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.55,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartLabel extends StatelessWidget {
  final String text;

  const _ChartLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: AppColors.textLight,
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _RecentTransactions extends StatelessWidget {
  final VoidCallback? onViewAll;
  final List<TransactionModel> transactions;
  final CurrencyProvider currencyProvider;

  const _RecentTransactions({
    this.onViewAll,
    required this.transactions,
    required this.currencyProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                context.l10n.recentTransactions,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            TextButton(
              onPressed: onViewAll,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryColor,
                padding: EdgeInsets.zero,
                minimumSize: const Size(56, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                context.l10n.seeAll,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (transactions.isEmpty)
          const _EmptyRecentTransactions()
        else
          ...transactions.map(
            (transaction) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _RecentTransactionRow(
                transaction: transaction,
                currencyProvider: currencyProvider,
              ),
            ),
          ),
      ],
    );
  }
}

class _RecentTransactionRow extends StatelessWidget {
  final TransactionModel transaction;
  final CurrencyProvider currencyProvider;

  const _RecentTransactionRow({
    required this.transaction,
    required this.currencyProvider,
  });

  @override
  Widget build(BuildContext context) {
    final category = TransactionCategoryDisplay.resolve(transaction,
        context.watch<CategoryProvider>().allCategories, context.l10n);
    final isIncome = transaction.type == TransactionType.ingreso;
    final amountColor =
        isIncome ? AppColors.incomeColor : AppColors.textPrimary;

    final couple = context.watch<CoupleLinkProvider>();
    final isMine = transaction.ownerId == null ||
        context.read<TransactionProvider>().isOwnTransaction(transaction);
    final profile = context.watch<ProfileProvider>();
    final ownerName = couple.isLinked
        ? (isMine ? profile.displayName : couple.partnerDisplayName)
        : null;
    final ownerPhotoUrl = couple.isLinked
        ? (isMine ? profile.avatarUrl : couple.partnerPhotoUrl)
        : null;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => TransactionDetailScreen(transaction: transaction),
      )),
      child: Row(
        children: [
          OwnerBadgedIcon(
            ownerName: ownerName,
            ownerPhotoUrl: ownerPhotoUrl,
            isMine: isMine,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.surfaceColor,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Icon(
                isIncome ? Icons.payments_outlined : category.icon,
                color: isIncome ? AppColors.incomeColor : category.color,
                size: 23,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.25,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  isMine
                      ? '${category.name} · ${_formatTransactionTime(context, transaction.date)}'
                      : '${category.name} · ${context.l10n.sharedInformational}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          AnimatedValueVisibility(
              hidden:
                  context.watch<AmountVisibilityProvider?>()?.hidden == true,
              alignment: Alignment.centerRight,
              replacement: Text('••••••',
                  style: TextStyle(
                      color: amountColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w900)),
              child: Text(
                isMine
                    ? currencyProvider.formatWithSign(
                        transaction.amount,
                        isIncome: isIncome,
                      )
                    : currencyProvider.format(transaction.amount),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: amountColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.25,
                ),
              )),
        ],
      ),
    );
  }

  String _formatTransactionTime(BuildContext context, DateTime date) {
    final l10n = context.l10n;
    final now = DateTime.now();
    final sameDay =
        date.year == now.year && date.month == now.month && date.day == now.day;
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final isYesterday = date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
    final time = DateFormat('h:mm a').format(date);

    if (sameDay) return l10n.todayAt(time);
    if (isYesterday) return l10n.yesterdayAt(time);
    return DateFormat('MMM d, h:mm a').format(date);
  }
}

class _EmptyRecentTransactions extends StatelessWidget {
  const _EmptyRecentTransactions();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Text(
        context.l10n.noTransactionsYet,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
