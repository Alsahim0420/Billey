import 'package:billey/l10n/l10n_extensions.dart';
import 'package:billey/providers/currency_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/transaction.dart';
import '../providers/couple_link_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/transaction_provider.dart';
import '../theme/colors/app_colors.dart';
import '../widgets/owner_avatar.dart';
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
  String? _justRestoredId;

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
                const _ActivityHeader(),
                _SearchAndFilters(
                  controller: _searchController,
                  selectedFilter: _filter,
                  onChanged: (_) => setState(() {}),
                  onOpenFilters: _showFilterSheet,
                ),
                Expanded(
                  child: _ActivityList(
                    grouped: grouped,
                    currencyProvider: currencyProvider,
                    onEdit: _editTransaction,
                    onDelete: (transaction) =>
                        _deleteWithUndo(provider, transaction),
                    justRestoredId: _justRestoredId,
                    onRestoreAnimationDone: () =>
                        setState(() => _justRestoredId = null),
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

  Future<void> _showFilterSheet() async {
    final options = <(_ActivityFilter, String)>[
      (_ActivityFilter.all, context.l10n.filterAll),
      (_ActivityFilter.income, context.l10n.filterIncome),
      (_ActivityFilter.expenses, context.l10n.filterExpenses),
      (_ActivityFilter.pending, context.l10n.filterPending),
    ];

    final chosen = await showModalBottomSheet<_ActivityFilter>(
      context: context,
      backgroundColor: AppColors.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderSubtle,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 18),
                for (final (filter, label) in options)
                  ListTile(
                    onTap: () => Navigator.of(sheetContext).pop(filter),
                    title: Text(
                      label,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: filter == _filter
                            ? FontWeight.w900
                            : FontWeight.w600,
                      ),
                    ),
                    trailing: filter == _filter
                        ? const Icon(TablerIcons.check,
                            color: AppColors.primaryColor)
                        : null,
                  ),
              ],
            ),
          ),
        );
      },
    );

    if (chosen != null && mounted) {
      setState(() => _filter = chosen);
    }
  }

  Future<void> _editTransaction(TransactionModel transaction) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddTransactionScreen(transaction: transaction),
      ),
    );
  }

  /// No confirmation dialog: the row already slides away (see
  /// `DismissiblePane` on `_TransactionRow`) as the delete commits, and
  /// this snackbar gives 6 seconds to undo it instead.
  Future<void> _deleteWithUndo(
    TransactionProvider provider,
    TransactionModel transaction,
  ) async {
    final id = transaction.id;
    if (id == null) return;

    try {
      await provider.deleteTransaction(id);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.transactionDeleteError)),
        );
      }
      return;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 6),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Text(
            context.l10n.transactionDeletedUndo,
            style: TextStyle(color: AppColors.textPrimary),
          ),
          action: SnackBarAction(
            label: context.l10n.undo,
            textColor: AppColors.primaryColor,
            onPressed: () async {
              await provider.addTransaction(transaction);
              if (mounted) setState(() => _justRestoredId = id);
            },
          ),
        ),
      );
  }
}

class _ActivityHeader extends StatelessWidget {
  const _ActivityHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 18),
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
    );
  }
}

class _SearchAndFilters extends StatelessWidget {
  final TextEditingController controller;
  final _ActivityFilter selectedFilter;
  final ValueChanged<String> onChanged;
  final VoidCallback onOpenFilters;

  const _SearchAndFilters({
    required this.controller,
    required this.selectedFilter,
    required this.onChanged,
    required this.onOpenFilters,
  });

  @override
  Widget build(BuildContext context) {
    final hasActiveFilter = selectedFilter != _ActivityFilter.all;

    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 0, 30, 24),
      child: Row(
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
          GestureDetector(
            onTap: onOpenFilters,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
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
                if (hasActiveFilter)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: AppColors.surfaceInput, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityList extends StatelessWidget {
  final Map<String, List<TransactionModel>> grouped;
  final CurrencyProvider currencyProvider;
  final ValueChanged<TransactionModel> onEdit;
  final Future<void> Function(TransactionModel) onDelete;
  final String? justRestoredId;
  final VoidCallback onRestoreAnimationDone;

  const _ActivityList({
    required this.grouped,
    required this.currencyProvider,
    required this.onEdit,
    required this.onDelete,
    required this.justRestoredId,
    required this.onRestoreAnimationDone,
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
            if (transaction.id != null && transaction.id == justRestoredId)
              _SlideInOnce(
                key: ValueKey('restore-${transaction.id}'),
                onDone: onRestoreAnimationDone,
                child: _TransactionRow(
                  transaction: transaction,
                  currencyProvider: currencyProvider,
                  onEdit: () => onEdit(transaction),
                  onDelete: () => onDelete(transaction),
                ),
              )
            else
              _TransactionRow(
                key: ValueKey(transaction.id ?? transaction.hashCode),
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

/// Plays a one-shot slide-in-from-the-left entrance animation, used when a
/// deleted transaction is restored via the "Deshacer" snackbar so it visibly
/// slides back into place instead of just popping back in.
class _SlideInOnce extends StatefulWidget {
  final Widget child;
  final VoidCallback onDone;

  const _SlideInOnce({
    super.key,
    required this.child,
    required this.onDone,
  });

  @override
  State<_SlideInOnce> createState() => _SlideInOnceState();
}

class _SlideInOnceState extends State<_SlideInOnce>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _offset = Tween<Offset>(
      begin: const Offset(-1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward().whenComplete(() {
      if (mounted) widget.onDone();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(position: _offset, child: widget.child);
  }
}

class _TransactionRow extends StatelessWidget {
  final TransactionModel transaction;
  final CurrencyProvider currencyProvider;
  final VoidCallback onEdit;
  final Future<void> Function() onDelete;

  const _TransactionRow({
    super.key,
    required this.transaction,
    required this.currencyProvider,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.ingreso;
    final displayAmount = currencyProvider.formatWithSign(
      transaction.amount,
      isIncome: isIncome,
    );
    final color = isIncome ? AppColors.primaryColor : AppColors.expenseColor;
    final couple = context.watch<CoupleLinkProvider>();
    final isMine = transaction.ownerId == null ||
        transaction.ownerId == FirebaseAuth.instance.currentUser?.uid;
    final profile = context.watch<ProfileProvider>();
    final ownerName = couple.isLinked
        ? (isMine ? profile.displayName : couple.partnerDisplayName)
        : null;
    final ownerPhotoUrl = couple.isLinked
        ? (isMine ? profile.avatarUrl : couple.partnerPhotoUrl)
        : null;

    return Slidable(
      key: ValueKey(transaction.id ?? transaction.hashCode),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.22,
        // No `dismissible` here on purpose: swiping only reveals the
        // button and stays pinned there — it never deletes by itself.
        // Deleting (and the slide-away animation) only happens from an
        // explicit tap on the trash button below.
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 26, left: 8),
              child: Material(
                color: AppColors.expenseColor.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(16),
                // `Builder` gives us a context that's actually a descendant
                // of the `Slidable` below (unlike this method's own
                // `context`, which is the Slidable's *parent*) — required
                // for `Slidable.of(context)` to find it.
                child: Builder(
                  builder: (buttonContext) => InkWell(
                    onTap: () {
                      // Tapping the button plays the same slide-away
                      // animation as a full swipe, then deletes.
                      Slidable.of(buttonContext)?.dismiss(
                        ResizeRequest(
                          const Duration(milliseconds: 300),
                          onDelete,
                        ),
                        duration: const Duration(milliseconds: 300),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: const Center(
                      child:
                          Icon(TablerIcons.trash, color: AppColors.expenseColor),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 26),
          child: Row(
            children: [
              OwnerBadgedIcon(
                ownerName: ownerName,
                ownerPhotoUrl: ownerPhotoUrl,
                isMine: isMine,
                badgeSize: 22,
                child: _ActivityIcon(
                  icon: isIncome
                      ? TablerIcons.wallet
                      : _categoryIcon(transaction.category),
                  color: isIncome
                      ? AppColors.primaryColor
                      : transaction.category.color,
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
