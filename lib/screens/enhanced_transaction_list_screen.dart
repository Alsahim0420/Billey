import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';
import '../widgets/transaction_card.dart';
import '../widgets/empty_state_widget.dart';
import '../theme/colors/app_colors.dart';
import 'add_transaction_screen.dart';
import 'monthly_summary_screen.dart';

class EnhancedTransactionListScreen extends StatefulWidget {
  const EnhancedTransactionListScreen({super.key});

  @override
  State<EnhancedTransactionListScreen> createState() =>
      _EnhancedTransactionListScreenState();
}

class _EnhancedTransactionListScreenState
    extends State<EnhancedTransactionListScreen> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _filterAnimationController;
  late Animation<double> _filterAnimation;
  bool _isFilterVisible = false;

  @override
  void initState() {
    super.initState();
    _filterAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _filterAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _filterAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _filterAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Consumer<TransactionProvider>(
          builder: (context, provider, child) {
            return Column(
              children: [
                _buildHeader(),
                _buildSearchBar(provider),
                AnimatedBuilder(
                  animation: _filterAnimation,
                  builder: (context, child) {
                    return SizeTransition(
                      sizeFactor: _filterAnimation,
                      child: _buildFilterSection(provider),
                    );
                  },
                ),
                Expanded(
                  child: _buildTransactionList(provider),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.surfaceColor,
        boxShadow: [AppColors.softShadow],
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Mis Transacciones',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              _isFilterVisible ? TablerIcons.filter_off : TablerIcons.filter,
              color: AppColors.primaryColor,
            ),
            onPressed: () {
              setState(() {
                _isFilterVisible = !_isFilterVisible;
              });
              if (_isFilterVisible) {
                _filterAnimationController.forward();
              } else {
                _filterAnimationController.reverse();
              }
            },
          ),
          IconButton(
            icon: const Icon(TablerIcons.chart_pie,
                color: AppColors.primaryColor),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      MonthlySummaryScreen(initialMonth: DateTime.now()),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(TransactionProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.surfaceColor,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar transacciones...',
          prefixIcon:
              const Icon(TablerIcons.search, color: AppColors.primaryColor),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon:
                      const Icon(TablerIcons.x, color: AppColors.textSecondary),
                  onPressed: () {
                    _searchController.clear();
                    provider.searchTransactions('');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: AppColors.backgroundColor,
        ),
        onChanged: (value) {
          provider.searchTransactions(value);
          setState(() {});
        },
      ),
    );
  }

  Widget _buildFilterSection(TransactionProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.surfaceColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filtros',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          // Type filter
          const Text(
            'Tipo de transacción',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildFilterChip(
                'Todos',
                provider.filterType == null,
                () => provider.filterByType(null),
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                'Ingresos',
                provider.filterType == TransactionType.ingreso,
                () => provider.filterByType(TransactionType.ingreso),
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                'Gastos',
                provider.filterType == TransactionType.gasto,
                () => provider.filterByType(TransactionType.gasto),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Category filter
          const Text(
            'Categoría',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFilterChip(
                'Todas',
                provider.filterCategory == null,
                () => provider.filterByCategory(null),
              ),
              ...TransactionCategory.values.map((category) {
                return _buildFilterChip(
                  category.displayName,
                  provider.filterCategory == category,
                  () => provider.filterByCategory(category),
                );
              }).toList(),
            ],
          ),
          const SizedBox(height: 16),

          // Clear filters button
          if (provider.searchQuery.isNotEmpty ||
              provider.filterType != null ||
              provider.filterCategory != null)
            Center(
              child: TextButton.icon(
                onPressed: () {
                  _searchController.clear();
                  provider.clearFilters();
                  setState(() {});
                },
                icon: const Icon(TablerIcons.refresh),
                label: const Text('Limpiar Filtros'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryColor,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color:
              isSelected ? AppColors.primaryColor : AppColors.backgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : AppColors.textLight,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? AppColors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionList(TransactionProvider provider) {
    if (provider.transactions.isEmpty) {
      // Check if it's because of filters
      if (provider.searchQuery.isNotEmpty ||
          provider.filterType != null ||
          provider.filterCategory != null) {
        return EmptyStateWidget(
          icon: TablerIcons.search_off,
          title: 'Sin resultados',
          message:
              'No se encontraron transacciones que coincidan con tu búsqueda o filtros.',
          actionText: 'Limpiar Filtros',
          onAction: () {
            _searchController.clear();
            provider.clearFilters();
            setState(() {});
          },
        );
      } else {
        return EmptyStateWidget(
          icon: Icons.receipt_long_outlined,
          title: '¡Tu primera transacción te espera!',
          message:
              'Comienza registrando tus ingresos y gastos para tener control total de tu dinero.',
          actionText: 'Agregar Transacción',
          onAction: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const AddTransactionScreen(),
              ),
            );
          },
        );
      }
    }

    return RefreshIndicator(
      onRefresh: () async {
        await provider.loadTransactions();
      },
      child: ListView.builder(
        itemCount: provider.transactions.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final transaction = provider.transactions[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: TransactionCard(
              transaction: transaction,
              onPressedDelete: () {
                _showDeleteConfirmation(context, () {
                  provider.deleteTransaction(transaction.id!);
                });
              },
              onPressedEdit: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AddTransactionScreen(
                      transaction: transaction,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, VoidCallback onConfirm) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surfaceColor,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icono principal
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.errorColor.withOpacity(0.1),
                ),
                child: const Icon(
                  TablerIcons.trash,
                  color: AppColors.errorColor,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),

              // Título
              const Text(
                '¿Eliminar transacción?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Mensaje
              const Text(
                'Esta acción no se puede deshacer.\n¿Estás seguro de que quieres continuar?',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Botones
              Row(
                children: [
                  // Botón Cancelar
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.textLight,
                          width: 1,
                        ),
                      ),
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Botón Eliminar
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          colors: [
                            AppColors.errorColor,
                            AppColors.errorColor.withOpacity(0.8),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.errorColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          onConfirm();
                          _showDeleteSuccess(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: AppColors.white,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(TablerIcons.trash, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Eliminar',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteSuccess(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        content: const Row(
          children: [
            Icon(
              TablerIcons.check,
              color: AppColors.white,
              size: 20,
            ),
            SizedBox(width: 12),
            Text(
              'Transacción eliminada correctamente',
              style: TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
