// lib/screens/monthly_summary_screen.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../theme/colors/app_colors.dart';
import '../providers/category_provider.dart';
import '../providers/currency_provider.dart';

class MonthlySummaryScreen extends StatefulWidget {
  final DateTime? initialMonth;
  const MonthlySummaryScreen({Key? key, this.initialMonth}) : super(key: key);

  @override
  State<MonthlySummaryScreen> createState() => _MonthlySummaryScreenState();
}

// Clase auxiliar para los datos del gráfico de categorías
class CategoryChartData {
  final CategoryModel category;
  final double value;
  final double percentage;
  final Color color;

  CategoryChartData({
    required this.category,
    required this.value,
    required this.percentage,
    required this.color,
  });
}

class _MonthlySummaryScreenState extends State<MonthlySummaryScreen> {
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    final initialMonth = widget.initialMonth ?? DateTime.now();
    // Normalizar la fecha para que solo tenga año y mes
    _selectedMonth = DateTime(initialMonth.year, initialMonth.month);
  }

  void _changeMonth(int offset) {
    setState(() {
      final newMonth = _selectedMonth.month + offset;
      final newYear = _selectedMonth.year +
          (newMonth > 12
              ? 1
              : newMonth < 1
                  ? -1
                  : 0);
      final normalizedMonth = newMonth > 12
          ? newMonth - 12
          : newMonth < 1
              ? newMonth + 12
              : newMonth;
      _selectedMonth = DateTime(newYear, normalizedMonth);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final currencyProvider =
        Provider.of<CurrencyProvider>(context, listen: false);
    final transactions = provider.transactions
        .where((t) =>
            t.date.year == _selectedMonth.year &&
            t.date.month == _selectedMonth.month)
        .toList();

    final totalIncome = transactions
        .where((t) => t.type == TransactionType.ingreso)
        .fold(0.0, (sum, t) => sum + t.amount);
    final totalExpense = transactions
        .where((t) => t.type == TransactionType.gasto)
        .fold(0.0, (sum, t) => sum + t.amount);
    final netBalance = totalIncome - totalExpense;

    // Agrupar gastos por categoría usando TransactionCategory
    final Map<CategoryModel, double> expensesByCategory = {};
    final categoryProvider =
        Provider.of<CategoryProvider>(context, listen: false);
    for (var t in transactions.where((t) => t.type == TransactionType.gasto)) {
      // Buscar la categoría por TransactionCategory
      final category = categoryProvider.categories.firstWhere(
        (c) => c.transactionCategory == t.category,
        orElse: () => CategoryModel.getDefaultCategories()
            .firstWhere((c) => c.id == 'other'),
      );
      expensesByCategory[category] =
          (expensesByCategory[category] ?? 0) + t.amount;
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Resumen Mensual'),
        backgroundColor: AppColors.surfaceColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMonthSelector(),
            const SizedBox(height: 20),
            _buildTotals(
                totalIncome, totalExpense, netBalance, currencyProvider),
            const SizedBox(height: 24),
            _buildBarChart(totalIncome, totalExpense),
            const SizedBox(height: 32),
            _buildPieChart(expensesByCategory),
            const SizedBox(height: 32),
            _buildLegend(expensesByCategory),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthSelector() {
    final months =
        List.generate(12, (i) => DateTime(DateTime.now().year, i + 1));
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left,
              color: AppColors.primaryColor, size: 28),
          onPressed: () => _changeMonth(-1),
        ),
        const SizedBox(width: 8),
        DropdownButton<DateTime>(
          value: _selectedMonth,
          dropdownColor: AppColors.surfaceColor,
          style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold),
          underline: Container(),
          items: months.map((month) {
            return DropdownMenuItem(
              value: month,
              child: Text(DateFormat('MMMM yyyy', 'es').format(month)),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                // Normalizar la fecha seleccionada para que solo tenga año y mes
                _selectedMonth = DateTime(value.year, value.month);
              });
            }
          },
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.chevron_right,
              color: AppColors.primaryColor, size: 28),
          onPressed: () => _changeMonth(1),
        ),
      ],
    );
  }

  Widget _buildTotals(double income, double expense, double net,
      CurrencyProvider currencyProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [AppColors.softShadow],
      ),
      child: Column(
        children: [
          // Balance arriba
          _buildTotalItem(
              'Balance', net, AppColors.primaryColor, currencyProvider,
              isMain: true),
          const SizedBox(height: 16),
          // Ingresos y Gastos abajo
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: _buildTotalItem('Ingresos', income,
                    AppColors.incomeColor, currencyProvider),
              ),
              Expanded(
                child: _buildTotalItem('Gastos', expense,
                    AppColors.expenseColor, currencyProvider),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalItem(String label, double value, Color color,
      CurrencyProvider currencyProvider,
      {bool isMain = false}) {
    return Column(
      children: [
        Text(label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: isMain ? 16 : 14,
            )),
        const SizedBox(height: 6),
        Text(
          currencyProvider.format(value),
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: isMain ? 18 : 14,
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart(double income, double expense) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [AppColors.softShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Ingresos vs Gastos',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (income > expense ? income : expense) * 1.2 + 1,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        switch (value.toInt()) {
                          case 0:
                            return const Text('Ingresos',
                                style: TextStyle(
                                    color: AppColors.incomeColor,
                                    fontWeight: FontWeight.bold));
                          case 1:
                            return const Text('Gastos',
                                style: TextStyle(
                                    color: AppColors.expenseColor,
                                    fontWeight: FontWeight.bold));
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  BarChartGroupData(x: 0, barRods: [
                    BarChartRodData(
                      toY: income,
                      color: AppColors.incomeColor,
                      width: 32,
                      borderRadius: BorderRadius.circular(8),
                      backDrawRodData: BackgroundBarChartRodData(show: false),
                    ),
                  ]),
                  BarChartGroupData(x: 1, barRods: [
                    BarChartRodData(
                      toY: expense,
                      color: AppColors.expenseColor,
                      width: 32,
                      borderRadius: BorderRadius.circular(8),
                      backDrawRodData: BackgroundBarChartRodData(show: false),
                    ),
                  ]),
                ],
                gridData: const FlGridData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<CategoryChartData> _getCategoryData(
      Map<CategoryModel, double> expensesByCategory) {
    final totalExpenses =
        expensesByCategory.values.fold(0.0, (sum, amount) => sum + amount);
    return expensesByCategory.entries.map((entry) {
      final percentage =
          totalExpenses > 0 ? (entry.value / totalExpenses) * 100 : 0.0;
      return CategoryChartData(
        category: entry.key,
        value: entry.value,
        percentage: percentage,
        color: entry.key.color,
      );
    }).toList();
  }

  Widget _buildPieChart(Map<CategoryModel, double> data) {
    final categoryData = _getCategoryData(data);
    if (categoryData.isEmpty) {
      return const Center(
        child: Text('No hay gastos este mes',
            style: TextStyle(color: AppColors.textSecondary)),
      );
    }
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [AppColors.softShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Gastos por Categoría',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: PieChart(
              PieChartData(
                sections: categoryData.map((data) {
                  return PieChartSectionData(
                    color: data.color,
                    value: data.value,
                    title: '${data.percentage.toStringAsFixed(1)}%',
                    radius: 60,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  );
                }).toList(),
                sectionsSpace: 2,
                centerSpaceRadius: 40,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(Map<CategoryModel, double> data) {
    final categoryData = _getCategoryData(data);
    if (categoryData.isEmpty) return const SizedBox();
    final currencyProvider =
        Provider.of<CurrencyProvider>(context, listen: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Detalle por Categoría',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        ...categoryData.map((data) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: data.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(data.category.name,
                    style: TextStyle(
                        color: data.color, fontWeight: FontWeight.w600)),
                const SizedBox(width: 8),
                Text('${data.percentage.toStringAsFixed(1)}%',
                    style: const TextStyle(color: AppColors.textSecondary)),
                const SizedBox(width: 8),
                Text(currencyProvider.format(data.value),
                    style: const TextStyle(color: AppColors.textPrimary)),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}
