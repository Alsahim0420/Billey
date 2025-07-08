import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';
import '../theme/colors/app_colors.dart';
import '../resources/utils.dart';
import 'add_transaction_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Consumer<TransactionProvider>(
          builder: (context, provider, child) {
            // Check if there are no transactions
            if (provider.transactions.isEmpty) {
              return _buildWelcomeDashboard(context);
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 20),
                  _buildBalanceCards(provider),
                  const SizedBox(height: 20),
                  _buildMonthlyChart(provider),
                  const SizedBox(height: 20),
                  _buildCategoryChart(provider),
                  const SizedBox(height: 20),
                  _buildRecentTransactions(provider),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final now = DateTime.now();
    final greeting = _getGreeting();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          DateFormat('dd/MM/yyyy').format(now),
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceCards(TransactionProvider provider) {
    final totalIncome = provider.getTotalIncome();
    final totalExpenses = provider.getTotalExpenses();
    final balance = totalIncome - totalExpenses;

    return Column(
      children: [
        // Balance Total - Tarjeta completa arriba
        _buildBalanceCard(
          'Balance Total',
          Utils().valueCurrency(balance),
          balance >= 0 ? AppColors.successColor : AppColors.errorColor,
          balance >= 0 ? Icons.trending_up : Icons.trending_down,
          isMainCard: true,
        ),
        const SizedBox(height: 12),
        // Ingresos y Gastos - En fila abajo con más espacio
        Row(
          children: [
            Expanded(
              child: _buildBalanceCard(
                'Ingresos',
                Utils().valueCurrency(totalIncome),
                AppColors.incomeColor,
                Icons.arrow_upward,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildBalanceCard(
                'Gastos',
                Utils().valueCurrency(totalExpenses),
                AppColors.expenseColor,
                Icons.arrow_downward,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBalanceCard(
      String title, String amount, Color color, IconData icon,
      {bool isMainCard = false}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [AppColors.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: isMainCard ? 28 : 20),
              Container(
                padding: EdgeInsets.all(isMainCard ? 6 : 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: isMainCard ? 20 : 16),
              ),
            ],
          ),
          SizedBox(height: isMainCard ? 16 : 12),
          Text(
            title,
            style: TextStyle(
              fontSize: isMainCard ? 16 : 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: TextStyle(
              fontSize: isMainCard ? 24 : 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyChart(TransactionProvider provider) {
    final monthlyData = _getMonthlyData(provider);
    // Determinar el balance del último mes
    final lastBalance = monthlyData.isNotEmpty ? monthlyData.last.y : 0;
    final isNegative = lastBalance < 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [AppColors.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tendencia Mensual',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: monthlyData.map((e) => FlSpot(e.x, e.y)).toList(),
                    isCurved: true,
                    gradient: LinearGradient(
                      colors: isNegative
                          ? [
                              AppColors.expenseColor,
                              AppColors.expenseColorLight
                            ]
                          : [
                              AppColors.primaryColor,
                              AppColors.primaryColorDark
                            ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: isNegative
                            ? [
                                AppColors.expenseColor.withOpacity(0.3),
                                AppColors.expenseColor.withOpacity(0.1)
                              ]
                            : [
                                AppColors.primaryColor.withOpacity(0.3),
                                AppColors.primaryColor.withOpacity(0.1)
                              ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChart(TransactionProvider provider) {
    final categoryData = _getCategoryData(provider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [AppColors.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gastos por Categoría',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
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
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: categoryData.map((data) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: data.color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    data.category.displayName,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions(TransactionProvider provider) {
    final recentTransactions = provider.transactions.take(5).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [AppColors.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Transacciones Recientes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...recentTransactions.map((transaction) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: transaction.category.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      transaction.category.icon,
                      color: transaction.category.color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaction.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          transaction.category.displayName,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${transaction.type == TransactionType.gasto ? '-' : '+'}${Utils().valueCurrency(transaction.amount)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: transaction.type == TransactionType.gasto
                          ? AppColors.expenseColor
                          : AppColors.incomeColor,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildWelcomeDashboard(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 24),

          // Welcome Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [AppColors.cardShadow],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: AppColors.white,
                  size: 48,
                ),
                const SizedBox(height: 16),
                const Text(
                  '¡Bienvenido a My Finances!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Comienza tu viaje hacia la libertad financiera',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AddTransactionScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.white,
                      foregroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Agregar Primera Transacción',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Info Cards
          const Text(
            'Funcionalidades Principales',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildFeatureCard(
                  Icons.trending_up,
                  'Seguimiento',
                  'Registra ingresos y gastos fácilmente',
                  AppColors.incomeColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFeatureCard(
                  Icons.pie_chart,
                  'Gráficos',
                  'Visualiza tus patrones de gasto',
                  AppColors.primaryColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildFeatureCard(
                  Icons.category,
                  'Categorías',
                  'Organiza por tipo de gasto',
                  AppColors.warningColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFeatureCard(
                  Icons.insights,
                  'Reportes',
                  'Análisis detallado mensual',
                  AppColors.infoColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Tips Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [AppColors.cardShadow],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.successColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.lightbulb_outline,
                        color: AppColors.successColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Consejos para Empezar',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildTipItem('📊', 'Registra todas tus transacciones diarias'),
                _buildTipItem('🏷️', 'Usa categorías para organizar mejor'),
                _buildTipItem('📈', 'Revisa tus gráficos semanalmente'),
                _buildTipItem('💡', 'Establece metas de ahorro mensuales'),
              ],
            ),
          ),

          const SizedBox(height: 100), // Space for FAB
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
      IconData icon, String title, String description, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [AppColors.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return '¡Buenos días!';
    if (hour < 18) return '¡Buenas tardes!';
    return '¡Buenas noches!';
  }

  List<FlSpot> _getMonthlyData(TransactionProvider provider) {
    final now = DateTime.now();
    final data = <FlSpot>[];

    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final balance = provider.getMonthlySummary(month);
      data.add(FlSpot(i.toDouble(), balance.toDouble()));
    }

    return data;
  }

  List<CategoryChartData> _getCategoryData(TransactionProvider provider) {
    final expenses = provider.transactions
        .where((t) => t.type == TransactionType.gasto)
        .toList();

    final categoryTotals = <TransactionCategory, double>{};

    for (final expense in expenses) {
      categoryTotals[expense.category] =
          (categoryTotals[expense.category] ?? 0) + expense.amount;
    }

    final totalExpenses =
        categoryTotals.values.fold(0.0, (sum, amount) => sum + amount);

    return categoryTotals.entries.map((entry) {
      final percentage =
          totalExpenses > 0 ? (entry.value / totalExpenses) * 100 : 0.0;
      return CategoryChartData(
        category: entry.key,
        value: entry.value,
        percentage: percentage.toDouble(),
        color: entry.key.color,
      );
    }).toList();
  }
}

class CategoryChartData {
  final TransactionCategory category;
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
