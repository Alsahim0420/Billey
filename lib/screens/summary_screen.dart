import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/transaction_provider.dart';
import '../models/transaction.dart';

class MonthlySummaryScreen extends StatelessWidget {
  const MonthlySummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final currentMonth = DateTime.now();
    final transactions =
        transactionProvider.getTransactionsByMonth(currentMonth);

    final totalIncome = transactions
        .where((tx) => tx.type == TransactionType.ingreso)
        .fold(0.0, (sum, tx) => sum + tx.amount);
    final totalExpense = transactions
        .where((tx) => tx.type == TransactionType.gasto)
        .fold(0.0, (sum, tx) => sum + tx.amount);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Summary'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Summary for ${DateFormat.yMMMM().format(currentMonth)}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text('Total Income: \$${totalIncome.toStringAsFixed(2)}'),
            Text('Total Expense: \$${totalExpense.toStringAsFixed(2)}'),
            const Divider(),
            Text(
                'Balance: \$${(totalIncome - totalExpense).toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }
}
