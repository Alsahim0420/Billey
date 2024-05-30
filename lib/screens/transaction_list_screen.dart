// lib/screens/transaction_list_screen.dart
// ignore_for_file: void_checks

import 'package:flutter/material.dart';
import 'package:my_finances_app/screens/add_transaction_screen.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';

import '../widgets/transaction_card.dart';
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
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _showMonthlySummary(context),
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
      body: FutureBuilder(
        future: provider.loadTransactions(),
        builder: (context, data) {
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
        builder: (context) => MonthlySummaryScreen(month: DateTime.now()),
      ),
    );
  }
}
