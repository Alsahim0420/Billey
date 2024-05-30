import 'package:flutter/material.dart';

import '../database/data_base_helper.dart';
import '../models/transaction.dart';

class TransactionProvider with ChangeNotifier {
  List<TransactionModel> _transactions = [];

  List<TransactionModel> get transactions => _transactions;

  Future<void> loadTransactions() async {
    final data = await DatabaseHelper.instance.readAllTransactions();
    _transactions = data;
    notifyListeners();
  }

  void addTransaction(TransactionModel transaction) async {
    await DatabaseHelper.instance.create(
      TransactionModel(
        id: transaction.id,
        title: transaction.title,
        amount: transaction.amount,
        date: transaction.date,
        type: transaction.type,
      ),
    );
    loadTransactions();
  }

  void editTransaction(TransactionModel transaction) async {
    await DatabaseHelper.instance.update(transaction);
    loadTransactions();
  }

  void deleteTransaction(String id) async {
    await DatabaseHelper.instance.delete(id);
    loadTransactions();
  }

  double getTotalIncome() {
    return _transactions
        .where((transaction) => transaction.type == TransactionType.ingreso)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  double getTotalExpenses() {
    return _transactions
        .where((transaction) => transaction.type == TransactionType.gasto)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  double getMonthlySummary(DateTime date) {
    double income = getTransactionsByMonth(date)
        .where((transaction) => transaction.type == TransactionType.ingreso)
        .fold(0.0, (sum, item) => sum + item.amount);

    double expenses = getTransactionsByMonth(date)
        .where((transaction) => transaction.type == TransactionType.gasto)
        .fold(0.0, (sum, item) => sum + item.amount);

    return income - expenses;
  }

  List<TransactionModel> getTransactionsByMonth(DateTime date) {
    return _transactions
        .where((transaction) =>
            transaction.date.year == date.year &&
            transaction.date.month == date.month)
        .toList();
  }
}
