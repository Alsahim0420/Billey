import 'package:billey/l10n/l10n_extensions.dart';
import 'package:billey/providers/couple_finance_provider.dart';
import 'package:billey/providers/currency_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/couple_finance.dart';
import '../theme/colors/app_colors.dart';
import 'couple_qr_display_screen.dart';

class CoupleWalletDetailScreen extends StatelessWidget {
  const CoupleWalletDetailScreen({
    super.key,
    required this.walletId,
  });

  final String walletId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Consumer2<CoupleFinanceProvider, CurrencyProvider>(
      builder: (context, couple, currency, _) {
        final wallet = couple.walletById(walletId);
        if (wallet == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.coupleSharedWallet)),
            body: Center(child: Text(l10n.coupleWalletNotFound)),
          );
        }

        final locale = currency.selectedCurrency.locale;
        final spentPercent =
            wallet.budget == 0 ? 0.0 : wallet.spent / wallet.budget;

        return Scaffold(
          backgroundColor: AppColors.backgroundAlt,
          appBar: AppBar(
            backgroundColor: AppColors.surfaceColor,
            elevation: 0,
            title: Text(
              wallet.title,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w900,
              ),
            ),
            iconTheme: IconThemeData(color: AppColors.textPrimary),
            actions: [
              IconButton(
                onPressed: () => _shareUpdate(context, couple, wallet.title),
                icon: const Icon(TablerIcons.qrcode),
                color: AppColors.primaryColor,
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _addExpense(context, couple, wallet),
            backgroundColor: AppColors.primaryColor,
            foregroundColor: AppColors.white,
            icon: const Icon(TablerIcons.plus),
            label: Text(l10n.coupleAddExpense),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            children: [
              _SummaryCard(
                wallet: wallet,
                currency: currency,
                spentPercent: spentPercent,
              ),
              const SizedBox(height: 12),
              Text(
                '${l10n.coupleFrom} ${wallet.senderName} → ${wallet.holderName}',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.coupleExpenses,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              if (wallet.expenses.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Text(
                    l10n.coupleNoExpensesYet,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              else
                ...wallet.expenses.map(
                  (expense) => _ExpenseTile(
                    expense: expense,
                    currency: currency,
                    locale: locale,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _shareUpdate(
    BuildContext context,
    CoupleFinanceProvider couple,
    String walletTitle,
  ) {
    final l10n = context.l10n;
    final payload = couple.buildSyncQr();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CoupleQrDisplayScreen(
          title: l10n.coupleSyncQrTitle,
          subtitle: l10n.coupleSyncQrSubtitle(walletTitle),
          payload: payload,
        ),
      ),
    );
  }

  Future<void> _addExpense(
    BuildContext context,
    CoupleFinanceProvider couple,
    SharedWallet wallet,
  ) async {
    final l10n = context.l10n;
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    final link = couple.link;
    final currency = context.read<CurrencyProvider>();

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            16,
            20,
            20 + MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.coupleAddExpense,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: l10n.coupleExpenseTitle,
                  hintText: l10n.expenseHint,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                inputFormatters:
                    currency.usesDecimals ? null : [currency.inputFormatter],
                decoration: InputDecoration(
                  labelText: l10n.coupleExpenseAmount,
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () {
                  final amount = currency.parseValue(amountController.text) ?? 0;
                  if (titleController.text.trim().length < 2 || amount <= 0) {
                    return;
                  }
                  Navigator.pop(sheetContext, true);
                },
                child: Text(l10n.save),
              ),
            ],
          ),
        );
      },
    );

    if (saved != true || !context.mounted) return;

    final amount = currency.parseValue(amountController.text) ?? 0;
    await couple.addExpense(
      walletId: wallet.id,
      title: titleController.text.trim(),
      amount: amount,
      spentBy: link?.myName ?? wallet.holderName,
    );

    titleController.dispose();
    amountController.dispose();
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.wallet,
    required this.currency,
    required this.spentPercent,
  });

  final SharedWallet wallet;
  final CurrencyProvider currency;
  final double spentPercent;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _metricRow(l10n.coupleBudget, currency.format(wallet.budget)),
          const SizedBox(height: 8),
          _metricRow(l10n.coupleSpent, currency.format(wallet.spent),
              color: AppColors.expenseColor),
          const SizedBox(height: 8),
          _metricRow(l10n.coupleRemaining, currency.format(wallet.remaining),
              color: AppColors.primaryColor),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: spentPercent.clamp(0, 1),
              minHeight: 8,
              backgroundColor: AppColors.backgroundAlt,
              color: spentPercent > 0.85
                  ? AppColors.expenseColor
                  : AppColors.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricRow(String label, String value, {Color? color}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color ?? AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  const _ExpenseTile({
    required this.expense,
    required this.currency,
    required this.locale,
  });

  final SharedWalletExpense expense;
  final CurrencyProvider currency;
  final String locale;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.title,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${expense.spentBy} · ${DateFormat.yMMMd(locale).format(expense.date)}',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            currency.format(expense.amount),
            style: const TextStyle(
              color: AppColors.expenseColor,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
