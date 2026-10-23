import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../database/data_base_helper.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../services/expense_categorizer.dart';
import '../services/uncategorized_expense_migration.dart';
import '../services/firestore_transaction_service.dart';

class TransactionProvider with ChangeNotifier {
  ExpenseCategorizer? categorizer;
  List<CategoryModel> Function()? categoryCatalog;
  Future<TransactionModel> _categorize(TransactionModel transaction) async {
    final service = categorizer;
    if (service == null) return transaction;
    return service.categorize(transaction,
        categoryCatalog?.call() ?? CategoryModel.getDefaultCategories());
  }

  final DatabaseHelper? dbHelper;
  final FirestoreTransactionService? firestoreService;
  List<TransactionModel> _transactions = [];
  List<TransactionModel> _filteredTransactions = [];
  String _searchQuery = '';
  TransactionType? _filterType;
  TransactionCategory? _filterCategory;
  String? _partnerUid;

  // Constructor por defecto usa DatabaseHelper.instance
  TransactionProvider()
      : dbHelper = DatabaseHelper.instance,
        firestoreService = null;

  TransactionProvider.cloud({FirestoreTransactionService? service})
      : dbHelper = null,
        firestoreService = service ?? FirestoreTransactionService();

  // Constructor alternativo para tests/mocks
  TransactionProvider.withDb(DatabaseHelper db)
      : dbHelper = db,
        firestoreService = null;

  List<TransactionModel> get transactions => _filteredTransactions.isEmpty &&
          _searchQuery.isEmpty &&
          _filterType == null &&
          _filterCategory == null
      ? _transactions
      : _filteredTransactions;

  List<TransactionModel> get allTransactions => _transactions;

  String get searchQuery => _searchQuery;
  TransactionType? get filterType => _filterType;
  TransactionCategory? get filterCategory => _filterCategory;

  /// Sets (or clears) the linked partner's uid so [loadTransactions] also
  /// pulls in whatever they've shared with us. Reloads immediately if the
  /// partner changed.
  void setPartnerUid(String? partnerUid) {
    if (_partnerUid == partnerUid) return;
    _partnerUid = partnerUid;
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    List<TransactionModel> data;
    if (firestoreService != null) {
      data = await firestoreService!.readAll();
      final partnerUid = _partnerUid;
      if (partnerUid != null) {
        final shared = await firestoreService!.readSharedByPartner(partnerUid);
        data = [...data, ...shared];
      }
    } else {
      data = await dbHelper!.readAllTransactions();
    }
    _transactions = data;
    // Sort by date (most recent first)
    _transactions.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  Future<void> addTransaction(TransactionModel transaction,
      {bool categorySelectedManually = false}) async {
    if (!categorySelectedManually) transaction = await _categorize(transaction);
    if (firestoreService != null) {
      await firestoreService!.create(transaction);
    } else {
      await dbHelper!.create(transaction);
    }
    await loadTransactions();
  }

  Future<void> importApplePay(
      TransactionModel transaction, String owner) async {
    transaction = await _categorize(transaction);
    if (firestoreService != null) {
      await firestoreService!.importApplePay(transaction, owner);
    } else {
      final existing = await dbHelper!.readAllTransactions();
      if (!existing.any((t) => t.id == transaction.id)) {
        await dbHelper!.create(transaction);
      }
    }
  }

  List<TransactionModel> get uncategorizedExpenses {
    final owner = firestoreService?.currentUser?.uid;
    if (owner == null) return [];
    return _transactions
        .where((tx) => UncategorizedExpenseMigration.eligible(tx, owner))
        .toList();
  }

  Future<void> assignPendingCategory(
      TransactionModel before, CategoryModel category) async {
    final cloud = firestoreService;
    final owner = cloud?.currentUser?.uid;
    if (cloud == null ||
        owner == null ||
        !category.isActive ||
        category.id == 'other') {
      throw StateError('Inicia sesión y elige una categoría activa.');
    }
    final available = categoryCatalog?.call() ?? [];
    if (!available
        .any((c) => c.id == category.id && c.isActive && c.id != 'other')) {
      throw StateError('La categoría ya no está disponible.');
    }
    final after = TransactionModel(
        id: before.id,
        title: before.title,
        amount: before.amount,
        date: before.date,
        type: before.type,
        category: category.transactionCategory,
        categoryId: category.id,
        currencyCode: before.currencyCode,
        description: before.description,
        ownerId: before.ownerId,
        sharedWith: before.sharedWith);
    final updated = await cloud.categorizeIfUnchanged(before, after, owner);
    if (cloud.currentUser?.uid != owner) throw StateError('La cuenta cambió.');
    await loadTransactions();
    if (!updated) {
      throw StateError('El gasto cambió. Revisa la lista actualizada.');
    }
  }

  bool recategorizing = false;
  int recategorizedProgress = 0, recategorizationTotal = 0;
  Future<CategorizationReport> categorizePendingExpenses() async {
    if (recategorizing) throw StateError('Ya hay una clasificación en curso.');
    final cloud = firestoreService;
    final owner = cloud?.currentUser?.uid;
    final ai = categorizer;
    if (cloud == null || owner == null || ai == null) {
      throw StateError('Inicia sesión y configura Gemini.');
    }
    recategorizing = true;
    recategorizedProgress = 0;
    recategorizationTotal = 0;
    notifyListeners();
    try {
      final own = await cloud.readAll();
      final categories = List<CategoryModel>.of(categoryCatalog?.call() ?? []);
      return await UncategorizedExpenseMigration().run(
        owner: owner,
        transactions: own,
        categories: categories,
        categorizer: ai,
        sessionIsCurrent: () => cloud.currentUser?.uid == owner,
        update: (before, after) =>
            cloud.categorizeIfUnchanged(before, after, owner),
        onProgress: (done, total) {
          recategorizedProgress = done;
          recategorizationTotal = total;
          notifyListeners();
        },
      );
    } finally {
      recategorizing = false;
      notifyListeners();
      if (cloud.currentUser?.uid == owner) await loadTransactions();
    }
  }

  Future<void> editTransaction(TransactionModel transaction) async {
    if (firestoreService != null) {
      await firestoreService!.update(transaction);
    } else {
      await dbHelper!.update(transaction);
    }
    await loadTransactions();
  }

  Future<void> deleteTransaction(String id) async {
    final index =
        _transactions.indexWhere((transaction) => transaction.id == id);
    final removed = index == -1 ? null : _transactions.removeAt(index);
    _refreshFilteredTransactions();
    notifyListeners();

    try {
      if (firestoreService != null) {
        await firestoreService!.delete(id);
      } else {
        await dbHelper!.delete(id);
      }
    } catch (_) {
      if (removed != null) {
        _transactions.insert(
          index.clamp(0, _transactions.length),
          removed,
        );
        _refreshFilteredTransactions();
        notifyListeners();
      }
      rethrow;
    }
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

  void _refreshFilteredTransactions() {
    if (_searchQuery.isEmpty &&
        _filterType == null &&
        _filterCategory == null) {
      _filteredTransactions = [];
      return;
    }
    _applyFilters();
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
