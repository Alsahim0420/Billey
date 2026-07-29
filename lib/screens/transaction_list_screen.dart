// lib/screens/transaction_list_screen.dart
// ignore_for_file: void_checks

import 'package:billey/l10n/l10n_extensions.dart';
import 'package:billey/screens/add_transaction_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../widgets/transaction_card.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/shimmer_loading.dart';
import '../theme/colors/app_colors.dart';
import 'monthly_summary_screen.dart';
import '../theme/billey_theme_scope.dart';

class TransactionListScreen extends StatelessWidget {
  const TransactionListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    BilleyThemeScope.isDarkOf(context);
    final l10n = context.l10n;
    final provider = Provider.of<TransactionProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          ElevatedButton(
            onPressed: () => _showMonthlySummary(context),
            child: Row(
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 10),
                  child: Text('${l10n.summary} '),
                ),
                const Icon(Icons.calendar_today),
              ],
            ),
          ),
          const SizedBox(
            width: 20,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddTransactionScreen(),
            ),
          );
        },
      ),
      backgroundColor: AppColors.backgroundColor,
      body: FutureBuilder(
        future: provider.loadTransactions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const TransactionListShimmer();
          }

          if (provider.transactions.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.receipt_long_outlined,
              title: l10n.firstTransactionTitle,
              message: l10n.firstTransactionMessage,
              actionText: l10n.addTransaction,
              onAction: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AddTransactionScreen(),
                  ),
                );
              },
            );
          }

          return ListView.builder(
            itemCount: provider.transactions.length,
            padding: const EdgeInsets.only(top: 20),
            itemBuilder: (context, index) {
              final transaction = provider.transactions[index];
              return TransactionCard(
                transaction: transaction,
                onPressedDelete: () {
                  provider.deleteTransaction(transaction.id!);
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
              );
            },
          );
        },
      ),
    );
  }

  void _showMonthlySummary(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            MonthlySummaryScreen(initialMonth: DateTime.now()),
      ),
    );
  }
}
