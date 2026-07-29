import 'package:billey/l10n/l10n_extensions.dart';
import 'package:billey/providers/currency_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/transaction_provider.dart';
import '../models/transaction.dart';

class MonthlySummaryScreen extends StatelessWidget {
  const MonthlySummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final currencyProvider =
        Provider.of<CurrencyProvider>(context, listen: false);
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
    final balance = totalIncome - totalExpense;

    final monthLabel = DateFormat.yMMMM(
      Localizations.localeOf(context).toString(),
    ).format(currentMonth);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.monthlySummary),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              l10n.summaryFor(monthLabel),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(l10n.totalIncomeLine(currencyProvider.format(totalIncome))),
            Text(l10n.totalExpenseLine(currencyProvider.format(totalExpense))),
            const Divider(),
            Text(l10n.balanceLine(currencyProvider.format(balance))),
          ],
        ),
      ),
    );
  }
}
