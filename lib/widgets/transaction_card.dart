import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
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
        subtitle: Text('${Utils().valueCurrency(transaction.amount)} '),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primaryColorTransparent,
          ),
          child: Icon(
            transaction.type == TransactionType.ingreso
                ? TablerIcons.credit_card_refund
                : TablerIcons.credit_card_pay,
            color: transaction.type == TransactionType.ingreso
                ? AppColors.incomeColor
                : AppColors.expenseColor,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isFromMonth)
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: onPressedEdit,
              ),
            if (!isFromMonth)
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () =>
                    _showConfirmationDialog(context, onPressed: () {
                  onPressedDelete();
                }),
              ),
          ],
        ),
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context,
      {required Function() onPressed}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: EdgeInsets.zero,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: const Center(
                  child: Text(
                    'Eliminar Transaccion',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: const Icon(
                  TablerIcons.trash_x,
                  size: 70,
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Estas Seguro de eliminar esta transaccion'),
              ),
              Container(
                padding: const EdgeInsets.only(right: 20, bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                      child: const Text('Eliminar'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ).then((result) {
      if (result == true) {
        onPressed();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.expenseColor,
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(
                  TablerIcons.square_rounded_check,
                  color: AppColors.white,
                  size: 50,
                ),
                Text(
                  "Transacción eliminada correctamente",
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.white,
                  ),
                )
              ],
            ),
          ),
        );
      }
    });
  }
}
