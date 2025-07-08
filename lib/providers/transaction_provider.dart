import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../database/data_base_helper.dart';
import '../models/transaction.dart';

class TransactionProvider with ChangeNotifier {
  final DatabaseHelper dbHelper;
  List<TransactionModel> _transactions = [];
  List<TransactionModel> _filteredTransactions = [];
  String _searchQuery = '';
  TransactionType? _filterType;
  TransactionCategory? _filterCategory;

  // Constructor por defecto usa DatabaseHelper.instance
  TransactionProvider() : dbHelper = DatabaseHelper.instance;

  // Constructor alternativo para tests/mocks
  TransactionProvider.withDb(this.dbHelper);

  List<TransactionModel> get transactions => _filteredTransactions.isEmpty &&
          _searchQuery.isEmpty &&
          _filterType == null &&
          _filterCategory == null
      ? _transactions
      : _filteredTransactions;

  String get searchQuery => _searchQuery;
  TransactionType? get filterType => _filterType;
  TransactionCategory? get filterCategory => _filterCategory;

  Future<void> loadTransactions() async {
    final data = await dbHelper.readAllTransactions();
    _transactions = data;
    // Sort by date (most recent first)
    _transactions.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    await dbHelper.create(transaction);
    await loadTransactions();
  }

  Future<void> editTransaction(TransactionModel transaction) async {
    await dbHelper.update(transaction);
    await loadTransactions();
  }

  Future<void> deleteTransaction(String id) async {
    await dbHelper.delete(id);
    await loadTransactions();
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

  void searchTransactions(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void filterByType(TransactionType? type) {
    _filterType = type;
    _applyFilters();
    notifyListeners();
  }

  void filterByCategory(TransactionCategory? category) {
    _filterCategory = category;
    _applyFilters();
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _filterType = null;
    _filterCategory = null;
    _filteredTransactions = [];
    notifyListeners();
  }

  void _applyFilters() {
    var filtered = List<TransactionModel>.from(_transactions);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((transaction) {
        return transaction.title
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            (transaction.description
                    ?.toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ??
                false);
      }).toList();
    }

    // Apply type filter
    if (_filterType != null) {
      filtered = filtered
          .where((transaction) => transaction.type == _filterType)
          .toList();
    }

    // Apply category filter
    if (_filterCategory != null) {
      filtered = filtered
          .where((transaction) => transaction.category == _filterCategory)
          .toList();
    }

    _filteredTransactions = filtered;
  }

  List<TransactionModel> getTransactionsByDateRange(
      DateTime start, DateTime end) {
    return _transactions.where((transaction) {
      return transaction.date
              .isAfter(start.subtract(const Duration(days: 1))) &&
          transaction.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  double getTotalByCategory(TransactionCategory category) {
    return _transactions
        .where((transaction) => transaction.category == category)
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  @visibleForTesting
  void setTestTransactions(List<TransactionModel> txs) {
    _transactions = txs;
    _filteredTransactions = [];
  }
}
