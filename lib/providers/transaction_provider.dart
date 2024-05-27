import 'package:flutter/material.dart';

import '../transactions/transaction.dart';

class TransactionProvider with ChangeNotifier {
  final List<Transaction> _transactions = [];

  List<Transaction> get transactions => _transactions;

  void addTransaction(
      String title, double amount, DateTime date, TransactionType type) {
    _transactions
        .add(Transaction(title: title, amount: amount, date: date, type: type));
    notifyListeners();
  }

  void editTransaction(String id, String title, double amount, DateTime date) {
    final index = _transactions.indexWhere((tx) => tx.id == id);
    if (index >= 0) {
      _transactions[index] = Transaction(
        // id: id,
        title: title,
        amount: amount,
        date: date,
        type: _transactions[index].type,
      );
      notifyListeners();
    }
  }

  void deleteTransaction(String id) {
    _transactions.removeWhere((tx) => tx.id == id);
    notifyListeners();
  }

  double get totalIncome {
    return _transactions
        .where((tx) => tx.type == TransactionType.income)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double get totalExpense {
    return _transactions
        .where((tx) => tx.type == TransactionType.expense)
        .fold(0.0, (sum, tx) => sum + tx.amount);
  }

  double get balance {
    return totalIncome - totalExpense;
  }

  List<Transaction> getTransactionsByMonth(DateTime month) {
    return _transactions
        .where(
            (tx) => tx.date.year == month.year && tx.date.month == month.month)
        .toList();
  }
}
