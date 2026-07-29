import 'package:billey/l10n/l10n_extensions.dart';
import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:provider/provider.dart';

import 'add_transaction_screen.dart';
import 'summary_screen.dart';
import 'transaction_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.financialManager),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  // ignore: prefer_const_constructors
                  builder: (context) => AddTransactionScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: const TransactionListScreen(),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.summarize),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const MonthlySummaryScreen(),
            ),
          );
        },
      ),
    );
  }
}
