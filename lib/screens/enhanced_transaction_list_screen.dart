import 'package:billey/l10n/l10n_extensions.dart';
import 'package:billey/providers/currency_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../theme/colors/app_colors.dart';
import 'add_transaction_screen.dart';
import '../theme/billey_theme_scope.dart';

enum _ActivityFilter { all, income, expenses, pending }

class EnhancedTransactionListScreen extends StatefulWidget {
  const EnhancedTransactionListScreen({super.key});

  @override
  State<EnhancedTransactionListScreen> createState() =>
      _EnhancedTransactionListScreenState();
}

class _EnhancedTransactionListScreenState
    extends State<EnhancedTransactionListScreen> {
  final TextEditingController _searchController = TextEditingController();
  _ActivityFilter _filter = _ActivityFilter.all;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    BilleyThemeScope.isDarkOf(context);
    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      body: SafeArea(
        child: Consumer2<TransactionProvider, CurrencyProvider>(
          builder: (context, provider, currencyProvider, child) {
            final transactions = _visibleTransactions(provider.transactions);
            final grouped = _groupTransactions(context, transactions);
            return Column(
              children: [
                _ActivityHeader(onBack: () => Navigator.maybePop(context)),
                _SearchAndFilters(
                  controller: _searchController,
                  selectedFilter: _filter,
                  onChanged: (_) => setState(() {}),
                  onFilterChanged: (filter) {
                    setState(() => _filter = filter);
                  },
                ),
                Expanded(
                  child: _ActivityList(
                    grouped: grouped,
                    currencyProvider: currencyProvider,
                    onEdit: _editTransaction,
                    onDelete: (transaction) {
                      _confirmDelete(provider, transaction);
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<TransactionModel> _visibleTransactions(List<TransactionModel> source) {
    final query = _searchController.text.trim().toLowerCase();
    var items = List<TransactionModel>.from(source);

    if (query.isNotEmpty) {
      items = items.where((transaction) {
        return transaction.title.toLowerCase().contains(query) ||
            transaction.category.displayName.toLowerCase().contains(query) ||
            (transaction.description?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    switch (_filter) {
      case _ActivityFilter.income:
        items = items
            .where((transaction) => transaction.type == TransactionType.ingreso)
            .toList();
        break;
      case _ActivityFilter.expenses:
        items = items
            .where((transaction) => transaction.type == TransactionType.gasto)
            .toList();
        break;
      case _ActivityFilter.pending:
        items = items
            .where((transaction) =>
                transaction.description?.toLowerCase().contains('pending') ??
                false)
            .toList();
        break;
      case _ActivityFilter.all:
        break;
    }

    items.sort((a, b) => b.date.compareTo(a.date));
    return items;
  }

  Map<String, List<TransactionModel>> _groupTransactions(
    BuildContext context,
    List<TransactionModel> transactions,
  ) {
    final groups = <String, List<TransactionModel>>{};

    for (final transaction in transactions) {
      final label = _dateGroupLabel(context, transaction.date);
      groups.putIfAbsent(label, () => []).add(transaction);
    }

    return groups;
  }

  String _dateGroupLabel(BuildContext context, DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);

    if (target == today) return context.l10n.dateToday;
    if (target == today.subtract(const Duration(days: 1))) {
      return context.l10n.dateYesterday;
    }
    return DateFormat('MMM d, yyyy').format(date).toUpperCase();
  }

  Future<void> _editTransaction(TransactionModel transaction) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddTransactionScreen(transaction: transaction),
      ),
    );
  }

  Future<void> _confirmDelete(
    TransactionProvider provider,
    TransactionModel transaction,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceColor,
        title: Text(context.l10n.deleteTransactionTitle),
        content: Text(
          context.l10n.deleteTransactionMessage(transaction.title),
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              context.l10n.delete,
              style: const TextStyle(color: AppColors.expenseColor),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && transaction.id != null) {
      await provider.deleteTransaction(transaction.id!);
    }
  }
}

class _ActivityHeader extends StatelessWidget {
  final VoidCallback onBack;

  const _ActivityHeader({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 18),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: Icon(
              TablerIcons.arrow_left,
              color: AppColors.textPrimary,
              size: 28,
            ),
          ),
          Expanded(
            child: Text(
              context.l10n.transactions,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 21,
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
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchAndFilters extends StatelessWidget {
  final TextEditingController controller;
  final _ActivityFilter selectedFilter;
  final ValueChanged<String> onChanged;
  final ValueChanged<_ActivityFilter> onFilterChanged;

  const _SearchAndFilters({
    required this.controller,
    required this.selectedFilter,
    required this.onChanged,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 0, 30, 24),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                  ),
                  cursorColor: AppColors.primaryColor,
                  decoration: InputDecoration(
                    hintText: context.l10n.searchHint,
                    hintStyle: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                    prefixIcon: Icon(
                      TablerIcons.search,
                      color: AppColors.textSecondary,
                    ),
                    filled: true,
                    fillColor: AppColors.surfaceInput,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Container(
                width: 62,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.surfaceInput,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  TablerIcons.adjustments_horizontal,
                  color: AppColors.primaryColor,
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _FilterPill(
                label: context.l10n.filterAll,
                selected: selectedFilter == _ActivityFilter.all,
                onTap: () => onFilterChanged(_ActivityFilter.all),
              ),
              const SizedBox(width: 10),
              _FilterPill(
                label: context.l10n.filterIncome,
                selected: selectedFilter == _ActivityFilter.income,
                onTap: () => onFilterChanged(_ActivityFilter.income),
              ),
              const SizedBox(width: 10),
              _FilterPill(
                label: context.l10n.filterExpenses,
                selected: selectedFilter == _ActivityFilter.expenses,
                onTap: () => onFilterChanged(_ActivityFilter.expenses),
              ),
              const SizedBox(width: 10),
              _FilterPill(
                label: context.l10n.filterPending,
                selected: selectedFilter == _ActivityFilter.pending,
                onTap: () => onFilterChanged(_ActivityFilter.pending),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryColor : AppColors.surfaceInput,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: selected ? AppColors.white : AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _ActivityList extends StatelessWidget {
  final Map<String, List<TransactionModel>> grouped;
  final CurrencyProvider currencyProvider;
  final ValueChanged<TransactionModel> onEdit;
  final ValueChanged<TransactionModel> onDelete;

  const _ActivityList({
    required this.grouped,
    required this.currencyProvider,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (grouped.isEmpty) {
      return Center(
        child: Text(
          context.l10n.noTransactionsFound,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(34, 0, 30, 120),
      children: [
        for (final entry in grouped.entries) ...[
          _GroupLabel(entry.key),
          const SizedBox(height: 18),
          for (final transaction in entry.value)
            _TransactionRow(
              transaction: transaction,
              currencyProvider: currencyProvider,
              onEdit: () => onEdit(transaction),
              onDelete: () => onDelete(transaction),
            ),
          const SizedBox(height: 22),
        ],
      ],
    );
  }
}

class _TransactionRow extends StatelessWidget {
  final TransactionModel transaction;
  final CurrencyProvider currencyProvider;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TransactionRow({
    required this.transaction,
    required this.currencyProvider,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.ingreso;
    final amount = currencyProvider.format(transaction.amount);
    final displayAmount = '${isIncome ? '+' : '-'}$amount';
    final color = isIncome ? AppColors.primaryColor : AppColors.expenseColor;

    return Dismissible(
      key: ValueKey(transaction.id ?? transaction.hashCode),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        onDelete();
        return false;
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(TablerIcons.trash, color: AppColors.expenseColor),
      ),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 26),
          child: Row(
            children: [
              _ActivityIcon(
                icon: isIncome
                    ? TablerIcons.wallet
                    : _categoryIcon(transaction.category),
                color: isIncome
                    ? AppColors.primaryColor
                    : transaction.category.color,
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
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _subtitleFor(transaction),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                displayAmount,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _categoryIcon(TransactionCategory category) {
    switch (category) {
      case TransactionCategory.food:
        return TablerIcons.bowl_chopsticks;
      case TransactionCategory.transport:
        return TablerIcons.car;
      case TransactionCategory.entertainment:
        return TablerIcons.movie;
      case TransactionCategory.health:
        return TablerIcons.heart;
      case TransactionCategory.education:
        return TablerIcons.school;
      case TransactionCategory.other:
        return TablerIcons.receipt;
    }
  }

  String _subtitleFor(TransactionModel transaction) {
    final time = DateFormat('h:mm a').format(transaction.date);
    final base = transaction.category.displayName;
    if (transaction.description?.isNotEmpty ?? false) {
      return '$base • ${transaction.description}';
    }
    return '$base • $time';
  }
}

class _GroupLabel extends StatelessWidget {
  final String label;

  const _GroupLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: AppColors.textSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.1,
      ),
    );
  }
}

class _ActivityIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _ActivityIcon({
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 28),
    );
  }
}
