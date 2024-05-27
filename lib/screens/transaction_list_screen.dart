import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/transaction_provider.dart';
import 'edit_transaction.dart';

class TransactionListScreen extends StatelessWidget {
  const TransactionListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final transactionsData = Provider.of<TransactionProvider>(context);
    final transactions = transactionsData.transactions;

    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (ctx, index) {
        return ListTile(
          title: Text(transactions[index].title),
          subtitle: Text('\$${transactions[index].amount.toStringAsFixed(2)}'),
          trailing: IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      EditTransactionScreen(transaction: transactions[index]),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
