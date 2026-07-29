import 'dart:io';

import 'package:billey/l10n/l10n_extensions.dart';
import 'package:billey/providers/currency_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../l10n/localization_helpers.dart';
import '../models/transaction.dart';
import '../providers/profile_provider.dart';
import '../providers/transaction_provider.dart';
import '../theme/colors/app_colors.dart';
import 'enhanced_transaction_list_screen.dart';
import '../theme/billey_theme_scope.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    BilleyThemeScope.isDarkOf(context);
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Consumer2<TransactionProvider, ProfileProvider>(
          builder: (context, provider, profile, child) {
            final currencyProvider =
                Provider.of<CurrencyProvider>(context, listen: false);
            final totalIncome = provider.getTotalIncome();
            final totalExpenses = provider.getTotalExpenses();
            final balance = totalIncome - totalExpenses;
            final recentTransactions = provider.transactions.take(4).toList();

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HomeHeader(
                    greeting: profile.greetingForHour(
                      DateTime.now().hour,
                      context.l10n,
                    ),
                    imagePath: profile.hasLocalImage ? profile.imagePath : null,
                  ),
                  const SizedBox(height: 44),
                  _TotalBalance(
                    amount: currencyProvider.format(balance),
                    isNegative: balance < 0,
                  ),
                  const SizedBox(height: 38),
                  Row(
                    children: [
                      Expanded(
                        child: _MetricCard(
                          label: context.l10n.income,
                          amount: totalIncome,
                          color: AppColors.incomeColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _MetricCard(
                          label: context.l10n.expenses,
                          amount: totalExpenses,
                          color: AppColors.expenseColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _HomeAnalyticsChart(
                    transactions: provider.allTransactions,
                  ),
                  const SizedBox(height: 26),
                  _RecentTransactions(
                    transactions: recentTransactions,
                    currencyProvider: currencyProvider,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

enum _HomeChartMode { monthlyTrend, expensesByCategory }

enum _HomeChartPeriod { thisMonth, lastMonth }

class _HomeAnalyticsChart extends StatefulWidget {
  const _HomeAnalyticsChart({required this.transactions});

  final List<TransactionModel> transactions;

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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FilterChipRow(
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
            ],
          ),
          if (_mode == _HomeChartMode.expensesByCategory) ...[
            const SizedBox(height: 10),
            _FilterChipRow(
              children: [
                _FilterChip(
                  label: l10n.thisMonth,
                  selected: _period == _HomeChartPeriod.thisMonth,
                  onTap: () => setState(
                    () => _period = _HomeChartPeriod.thisMonth,
                  ),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: l10n.lastMonth,
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
            _CategoryBreakdownContent(
              data: _categoryChartData(),
              periodLabel: _periodLabel(l10n),
              currency: currency,
            ),
        ],
      ),
    );
  }

  DateTime get _selectedMonth {
    final now = DateTime.now();
    if (_period == _HomeChartPeriod.thisMonth) {
      return DateTime(now.year, now.month);
    }
    return DateTime(now.year, now.month - 1);
  }

  String _periodLabel(AppLocalizations l10n) {
    return _period == _HomeChartPeriod.thisMonth
        ? l10n.thisMonth
        : l10n.lastMonth;
  }

  _MonthlyChartData _monthlyChartData() {
    final now = DateTime.now();
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
    final monthTransactions = widget.transactions.where((transaction) {
      return transaction.date.year == month.year &&
          transaction.date.month == month.month;
    });

    final income = monthTransactions
        .where((transaction) => transaction.type == TransactionType.ingreso)
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
    final expenses = monthTransactions
        .where((transaction) => transaction.type == TransactionType.gasto)
        .fold(0.0, (sum, transaction) => sum + transaction.amount);

    return income - expenses;
  }

  _CategoryChartData _categoryChartData() {
    final month = _selectedMonth;
    final expenses = widget.transactions.where((transaction) {
      return transaction.type == TransactionType.gasto &&
          transaction.date.year == month.year &&
          transaction.date.month == month.month;
    }).toList();

    final totals = <TransactionCategory, double>{};
    for (final transaction in expenses) {
      totals[transaction.category] =
          (totals[transaction.category] ?? 0) + transaction.amount;
    }

    final items = totals.entries
        .map(
          (entry) => _CategorySpendItem(
            category: entry.key,
            amount: entry.value,
            color: _categoryColor(entry.key),
          ),
        )
        .toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));

    final total = items.fold(0.0, (sum, item) => sum + item.amount);
    return _CategoryChartData(items: items, total: total);
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
                      data.trendLabel!,
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

class _CategoryBreakdownContent extends StatelessWidget {
  const _CategoryBreakdownContent({
    required this.data,
    required this.periodLabel,
    required this.currency,
  });

  final _CategoryChartData data;
  final String periodLabel;
  final CurrencyProvider currency;

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
                  Text(
                    l10n.expensesByCategory,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.35,
                    ),
                  ),
                  const SizedBox(height: 2),
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
                currency.format(data.total),
                style: const TextStyle(
                  color: AppColors.expenseColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
          ],
        ),
        const SizedBox(height: 14),
        if (data.items.isEmpty)
          _ChartEmptyState(message: l10n.noExpensesInPeriod)
        else ...[
          SizedBox(
            height: 210,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    centerSpaceRadius: 58,
                    sectionsSpace: 2,
                    startDegreeOffset: -90,
                    sections: data.items.map((item) {
                      return PieChartSectionData(
                        value: item.amount,
                        color: item.color,
                        title: '',
                        radius: 34,
                      );
                    }).toList(),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.totalSpend,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currency.format(data.total),
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
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
            _CategorySpendRow(
              item: item,
              total: data.total,
              currency: currency,
            ),
        ],
      ],
    );
  }
}

class _CategorySpendRow extends StatelessWidget {
  const _CategorySpendRow({
    required this.item,
    required this.total,
    required this.currency,
  });

  final _CategorySpendItem item;
  final double total;
  final CurrencyProvider currency;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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
              item.category.localizedName(l10n),
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            '${percentage.round()}%',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            currency.format(item.amount),
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

class _CategorySpendItem {
  const _CategorySpendItem({
    required this.category,
    required this.amount,
    required this.color,
  });

  final TransactionCategory category;
  final double amount;
  final Color color;
}

class _CategoryChartData {
  const _CategoryChartData({
    required this.items,
    required this.total,
  });

  final List<_CategorySpendItem> items;
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
  final String? imagePath;

  const _HomeHeader({
    required this.greeting,
    this.imagePath,
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
            child: imagePath != null
                ? Image.file(
                    File(imagePath!),
                    fit: BoxFit.cover,
                    width: 52,
                    height: 52,
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
  final String amount;
  final bool isNegative;

  const _TotalBalance({
    required this.amount,
    required this.isNegative,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text(
            context.l10n.totalBalance,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            amount,
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
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;

  const _MetricCard({
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final currency = context.watch<CurrencyProvider>();
    final valueText = currency.formatValue(amount);
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
          Text(
            valueText,
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
  final List<TransactionModel> transactions;
  final CurrencyProvider currencyProvider;

  const _RecentTransactions({
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
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const EnhancedTransactionListScreen(),
                  ),
                );
              },
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
    final isIncome = transaction.type == TransactionType.ingreso;
    final amountPrefix = isIncome ? '+' : '-';
    final amountColor =
        isIncome ? AppColors.incomeColor : AppColors.textPrimary;

    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.surfaceColor,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Icon(
            isIncome ? Icons.payments_outlined : transaction.category.icon,
            color: isIncome ? AppColors.incomeColor : AppColors.textPrimary,
            size: 23,
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
                _formatTransactionTime(context, transaction.date),
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
        Text(
          '$amountPrefix ${currencyProvider.format(transaction.amount)}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.right,
          style: TextStyle(
            color: amountColor,
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.25,
          ),
        ),
      ],
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
