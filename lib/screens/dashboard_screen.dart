import 'dart:io';

import 'package:billey/l10n/l10n_extensions.dart';
import 'package:billey/providers/currency_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

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
                    imagePath:
                        profile.hasLocalImage ? profile.imagePath : null,
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
                  _MonthlyTrendChart(data: _getMonthlyChartData(provider)),
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

  static const int _chartMonthsCount = 6;

  _MonthlyChartData _getMonthlyChartData(TransactionProvider provider) {
    final now = DateTime.now();
    final spots = <FlSpot>[];
    final labels = <String>[];

    for (var i = _chartMonthsCount - 1; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final balance = provider.getMonthlySummary(month);
      spots.add(FlSpot((_chartMonthsCount - 1 - i).toDouble(), balance));
      labels.add(_formatMonthLabel(month));
    }

    return _MonthlyChartData(
      spots: spots,
      monthLabels: labels,
      trendLabel: _formatMonthTrend(spots),
    );
  }

  String _formatMonthLabel(DateTime date) {
    final label = DateFormat('MMM', 'es').format(date);
    return label.replaceAll('.', '').substring(0, 3).toUpperCase();
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

class _MonthlyTrendChart extends StatelessWidget {
  final _MonthlyChartData data;

  const _MonthlyTrendChart({required this.data});

  List<FlSpot> get spots => data.spots;

  @override
  Widget build(BuildContext context) {
    final values = spots.map((spot) => spot.y).toList();
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final range = (maxValue - minValue).abs();
    final chartMinY = minValue - (range == 0 ? 10 : range * 0.22);
    final chartMaxY = maxValue + (range == 0 ? 10 : range * 0.18);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
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
            height: 240,
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
            children: data.monthLabels
                .map((label) => _ChartLabel(label))
                .toList(),
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
