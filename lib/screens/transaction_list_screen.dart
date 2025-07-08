// lib/screens/transaction_list_screen.dart
// ignore_for_file: void_checks

import 'package:flutter/material.dart';
import 'package:my_finances_app/screens/add_transaction_screen.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../widgets/transaction_card.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/shimmer_loading.dart';
import '../theme/colors/app_colors.dart';
import 'monthly_summary_screen.dart';

class TransactionListScreen extends StatelessWidget {
  const TransactionListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Finances'),
        actions: [
          ElevatedButton(
            onPressed: () => _showMonthlySummary(context),
            child: Row(
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 10),
                  child: const Text("Resumen "),
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
