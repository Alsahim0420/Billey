import 'package:flutter/material.dart';
import 'package:my_finances_app/models/transaction.dart';
import 'package:my_finances_app/resources/utils.dart';

import '../theme/colors/app_colors.dart';

class TransactionCard extends StatelessWidget {
  final TransactionModel transaction;
  final Function() onPressedEdit;
  final Function() onPressedDelete;
  final bool isFromMonth;
  const TransactionCard({
    super.key,
    required this.transaction,
    required this.onPressedEdit,
    required this.onPressedDelete,
    this.isFromMonth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.primaryColor,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        title: Text(transaction.title),
        subtitle: Text(
            '${Utils().valueCurrency(transaction.amount)} - ${Utils().capitalize(transaction.type.name)}'),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primaryColorTransparent,
          ),
          child: Icon(
            transaction.type == TransactionType.ingreso
                ? Icons.arrow_downward_rounded
                : Icons.arrow_upward_rounded,
            color: transaction.type == TransactionType.ingreso
                ? AppColors.incomeColor
                : AppColors.expenseColor,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // if (!isFromMonth)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onPressedEdit,
            ),
            // if (!isFromMonth)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: onPressedDelete,
            ),
          ],
        ),
      ),
    );
  }
}
