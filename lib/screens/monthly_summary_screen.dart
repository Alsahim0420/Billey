// lib/screens/monthly_summary_screen.dart
import 'package:flutter/material.dart';
import 'package:my_finances_app/resources/utils.dart';
import 'package:my_finances_app/theme/colors/app_colors.dart';
import 'package:my_finances_app/widgets/transaction_card.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';

class MonthlySummaryScreen extends StatelessWidget {
  final DateTime month;

  const MonthlySummaryScreen({super.key, required this.month});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final transactions = provider.getTransactionsByMonth(month);

    return Scaffold(
      appBar: AppBar(
        title: Text('Resumen de ${Utils().getmonthsbyNumber(month.month)}'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Total Income: ${Utils().valueCurrency(provider.getTotalIncome())}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Total Expenses: ${Utils().valueCurrency(provider.getTotalExpenses())}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Net Balance: ${Utils().valueCurrency(provider.getMonthlySummary(month))}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(color: AppColors.primaryColor),
          Expanded(
            child: ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];

                return TransactionCard(
                  isFromMonth: true,
                  transaction: transaction,
                  onPressedEdit: () {},
                  onPressedDelete: () {},
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
