import 'package:billey/providers/currency_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../l10n/l10n_extensions.dart';
import '../l10n/localization_helpers.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../theme/billey_theme_scope.dart';
import '../theme/colors/app_colors.dart';

class SpendingInsightsScreen extends StatefulWidget {
  const SpendingInsightsScreen({super.key});

  @override
  State<SpendingInsightsScreen> createState() => _SpendingInsightsScreenState();
}

class _SpendingInsightsScreenState extends State<SpendingInsightsScreen> {
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    BilleyThemeScope.isDarkOf(context);
    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      body: SafeArea(
        child: Consumer2<TransactionProvider, CurrencyProvider>(
          builder: (context, provider, currencyProvider, child) {
            final expenses =
                _expensesForMonth(provider.transactions, _selectedMonth);
            final previousExpenses = _expensesForMonth(
              provider.transactions,
              DateTime(_selectedMonth.year, _selectedMonth.month - 1),
            );
            final categoryData = _categoryBreakdown(expenses);
            final chartData =
                categoryData.isEmpty ? _demoBreakdown(l10n) : categoryData;
            final totalSpend = expenses.fold(0.0, (sum, tx) => sum + tx.amount);
            final demoTotal =
                chartData.fold(0.0, (sum, item) => sum + item.amount);
            final displayedTotal = totalSpend == 0 ? demoTotal : totalSpend;
            final weeklyThisMonth = _weeklyTotals(expenses);
            final weeklyLastMonth = _weeklyTotals(previousExpenses);

            return ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 34),
              children: [
                _InsightsHeader(onBack: () => Navigator.maybePop(context)),
                const SizedBox(height: 18),
                Center(
                  child: _MonthSelector(
                    selectedMonth: _selectedMonth,
                    onChanged: (month) {
                      setState(() => _selectedMonth = month);
                    },
                  ),
                ),
                const SizedBox(height: 22),
                _SpendDonut(
                  data: chartData,
                  total: displayedTotal,
                  currencyProvider: currencyProvider,
                ),
                const SizedBox(height: 22),
                _InsightCard(
                  totalSpend: totalSpend,
                  previousSpend: previousExpenses.fold(
                    0.0,
                    (sum, tx) => sum + tx.amount,
                  ),
                ),
                const SizedBox(height: 22),
                _SectionHeader(
                  title: l10n.monthlyComparison,
                  action: l10n.viewReport,
                  onTap: () {},
                ),
                const SizedBox(height: 10),
                _MonthlyComparisonChart(
                  thisMonth: weeklyThisMonth,
                  lastMonth: weeklyLastMonth,
                ),
                const SizedBox(height: 26),
                Text(
                  l10n.topCategories,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.35,
                  ),
                ),
                const SizedBox(height: 12),
                for (final item in chartData.take(4))
                  _TopCategoryRow(
                    item: item,
                    total: displayedTotal,
                    currencyProvider: currencyProvider,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<TransactionModel> _expensesForMonth(
    List<TransactionModel> transactions,
    DateTime month,
  ) {
    return transactions.where((transaction) {
      return transaction.type == TransactionType.gasto &&
          transaction.date.year == month.year &&
          transaction.date.month == month.month;
    }).toList();
  }

  List<_CategorySpend> _categoryBreakdown(List<TransactionModel> expenses) {
    final totals = <TransactionCategory, double>{};
    for (final tx in expenses) {
      totals[tx.category] = (totals[tx.category] ?? 0) + tx.amount;
    }

    final items = totals.entries.map((entry) {
      return _CategorySpend(
        category: entry.key,
        amount: entry.value,
        color: _insightColor(entry.key),
      );
    }).toList();

    items.sort((a, b) => b.amount.compareTo(a.amount));
    return items;
  }

  List<double> _weeklyTotals(List<TransactionModel> expenses) {
    final totals = List<double>.filled(4, 0);
    for (final tx in expenses) {
      final weekIndex = ((tx.date.day - 1) ~/ 7).clamp(0, 3);
      totals[weekIndex] += tx.amount;
    }
    if (totals.every((amount) => amount == 0)) {
      return const [420, 760, 540, 980];
    }
    return totals;
  }

  List<_CategorySpend> _demoBreakdown(AppLocalizations l10n) {
    return [
      _CategorySpend(
        category: TransactionCategory.other,
        amount: 1296.20,
        color: AppColors.primaryColor,
        labelOverride: l10n.insightDemoHousing,
        subtitleOverride: l10n.insightDemoHousingSubtitle,
        iconOverride: TablerIcons.home,
      ),
      _CategorySpend(
        category: TransactionCategory.food,
        amount: 810.12,
        color: AppColors.insightsFoodColor,
        labelOverride: l10n.insightDemoFoodDining,
        subtitleOverride: l10n.insightDemoFoodDiningSubtitle,
        iconOverride: TablerIcons.tools_kitchen_2,
      ),
      _CategorySpend(
        category: TransactionCategory.entertainment,
        amount: 648.10,
        color: const Color(0xFF5DF3E6),
        labelOverride: l10n.insightDemoFun,
        subtitleOverride: l10n.insightDemoFunSubtitle,
        iconOverride: TablerIcons.sparkles,
      ),
      _CategorySpend(
        category: TransactionCategory.transport,
        amount: 486.08,
        color: const Color(0xFF64748B),
        labelOverride: l10n.insightDemoTransport,
        subtitleOverride: l10n.insightDemoTransportSubtitle,
        iconOverride: TablerIcons.car,
      ),
    ];
  }

  Color _insightColor(TransactionCategory category) {
    switch (category) {
      case TransactionCategory.food:
        return AppColors.insightsFoodColor;
      case TransactionCategory.transport:
        return const Color(0xFF64748B);
      case TransactionCategory.entertainment:
        return const Color(0xFF5DF3E6);
      case TransactionCategory.health:
        return AppColors.infoColor;
      case TransactionCategory.education:
        return AppColors.categoryEducation;
      case TransactionCategory.other:
        return AppColors.primaryColor;
    }
  }
}

class _InsightsHeader extends StatelessWidget {
  final VoidCallback onBack;

  const _InsightsHeader({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onBack,
          icon: Icon(
            TablerIcons.chevron_left,
            color: AppColors.textPrimary,
            size: 28,
          ),
        ),
        Expanded(
          child: Text(
            context.l10n.spendingInsights,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.35,
            ),
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: Icon(
            TablerIcons.dots,
            color: AppColors.textPrimary,
            size: 24,
          ),
        ),
      ],
    );
  }
}

class _MonthSelector extends StatelessWidget {
  final DateTime selectedMonth;
  final ValueChanged<DateTime> onChanged;

  const _MonthSelector({
    required this.selectedMonth,
    required this.onChanged,
  });

  String _formatMonth(BuildContext context, DateTime month) {
    final locale = Localizations.localeOf(context).toString();
    return DateFormat.yMMMM(locale).format(month);
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<DateTime>(
      color: AppColors.surfaceColor,
      onSelected: onChanged,
      itemBuilder: (context) {
        final now = DateTime.now();
        return List.generate(8, (index) {
          final month = DateTime(now.year, now.month - index);
          return PopupMenuItem(
            value: month,
            child: Text(_formatMonth(context, month)),
          );
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceInput,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _formatMonth(context, selectedMonth),
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              TablerIcons.chevron_down,
              color: AppColors.textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

class _SpendDonut extends StatelessWidget {
  final List<_CategorySpend> data;
  final double total;
  final CurrencyProvider currencyProvider;

  const _SpendDonut({
    required this.data,
    required this.total,
    required this.currencyProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 300,
          width: double.infinity,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  centerSpaceRadius: 92,
                  sectionsSpace: 0,
                  startDegreeOffset: -90,
                  sections: data.map((item) {
                    return PieChartSectionData(
                      value: item.amount,
                      color: item.color,
                      title: '',
                      radius: 36,
                    );
                  }).toList(),
                ),
              ),
              SizedBox(
                width: 150,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      context.l10n.totalSpend,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        currencyProvider.format(total),
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _DonutLegend(data: data, total: total),
      ],
    );
  }
}

class _DonutLegend extends StatelessWidget {
  final List<_CategorySpend> data;
  final double total;

  const _DonutLegend({
    required this.data,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 3.6,
        children: data.take(4).map((item) {
          final percentage = total == 0 ? 0 : (item.amount / total * 100);
          return Row(
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.label(l10n),
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${percentage.round()}%',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final double totalSpend;
  final double previousSpend;

  const _InsightCard({
    required this.totalSpend,
    required this.previousSpend,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hasComparison = previousSpend > 0 && totalSpend > 0;
    final diff = hasComparison
        ? ((previousSpend - totalSpend) / previousSpend * 100)
        : 15.0;
    final isLess = diff >= 0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border:
            Border.all(color: AppColors.primaryColor.withValues(alpha: 0.28)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.primaryColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              TablerIcons.sparkles,
              color: AppColors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.insight,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${l10n.youSpent} ',
                        style: _insightTextStyle(),
                      ),
                      TextSpan(
                        text:
                            '${diff.abs().round()}% ${isLess ? l10n.less : l10n.more}',
                        style: _insightTextStyle().copyWith(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      TextSpan(
                        text: ' ${l10n.insightBudgetTight}',
                        style: _insightTextStyle(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  TextStyle _insightTextStyle() {
    return TextStyle(
      color: AppColors.textPrimary,
      fontSize: 13,
      fontWeight: FontWeight.w500,
      height: 1.45,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String action;
  final VoidCallback onTap;

  const _SectionHeader({
    required this.title,
    required this.action,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.35,
            ),
          ),
        ),
        TextButton(
          onPressed: onTap,
          child: Text(
            action,
            style: const TextStyle(
              color: AppColors.primaryColor,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _MonthlyComparisonChart extends StatelessWidget {
  final List<double> thisMonth;
  final List<double> lastMonth;

  const _MonthlyComparisonChart({
    required this.thisMonth,
    required this.lastMonth,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final currency = context.watch<CurrencyProvider>();
    final maxValue = [
      ...thisMonth,
      ...lastMonth,
      2000.0,
    ].reduce((a, b) => a > b ? a : b);

    return Container(
      height: 220,
      padding: const EdgeInsets.fromLTRB(12, 18, 14, 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceInput,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Expanded(
            child: BarChart(
              BarChartData(
                maxY: maxValue * 1.15,
                minY: 0,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 42,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const _AxisLabel('0');
                        if (value >= maxValue / 4) {
                          return _AxisLabel(currency.formatCompact(value));
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index > 3) {
                          return const SizedBox.shrink();
                        }
                        return _AxisLabel('W${index + 1}');
                      },
                    ),
                  ),
                ),
                barGroups: List.generate(4, (index) {
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: lastMonth[index],
                        color: AppColors.textLight,
                        width: 7,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      BarChartRodData(
                        toY: thisMonth[index],
                        color: AppColors.primaryColor,
                        width: 7,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendDot(color: AppColors.textLight, label: l10n.lastMonth),
              const SizedBox(width: 18),
              _LegendDot(
                color: AppColors.primaryColor,
                label: l10n.thisMonth,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TopCategoryRow extends StatelessWidget {
  final _CategorySpend item;
  final double total;
  final CurrencyProvider currencyProvider;

  const _TopCategoryRow({
    required this.item,
    required this.total,
    required this.currencyProvider,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final percentage = total == 0 ? 0 : item.amount / total * 100;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceInput,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(item.icon, color: item.color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label(l10n),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  item.subtitle(l10n),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                currencyProvider.format(item.amount),
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                '${percentage.round()}%',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AxisLabel extends StatelessWidget {
  final String label;

  const _AxisLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: AppColors.textSecondary,
        fontSize: 10,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _CategorySpend {
  final TransactionCategory category;
  final double amount;
  final Color color;
  final String? labelOverride;
  final String? subtitleOverride;
  final IconData? iconOverride;

  const _CategorySpend({
    required this.category,
    required this.amount,
    required this.color,
    this.labelOverride,
    this.subtitleOverride,
    this.iconOverride,
  });

  String label(AppLocalizations l10n) =>
      labelOverride ?? category.localizedName(l10n);

  String subtitle(AppLocalizations l10n) =>
      subtitleOverride ?? l10n.monthlySpending;

  IconData get icon => iconOverride ?? category.icon;
}
