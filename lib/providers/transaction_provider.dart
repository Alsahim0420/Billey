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

  /// Sharing grants visibility; only the owner's ledger affects their money.
  bool isOwnTransaction(TransactionModel transaction) =>
      transaction.ownerId == null ||
      transaction.ownerId == firestoreService?.currentUser?.uid;
  List<TransactionModel> get personalTransactions =>
      _transactions.where(isOwnTransaction).toList();
  List<TransactionModel> get personalVisibleTransactions =>
      transactions.where(isOwnTransaction).toList();

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
    _refreshFilteredTransactions();
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
    if (!isOwnTransaction(transaction)) {
      throw StateError('El movimiento compartido es solo informativo.');
    }
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
    if (index != -1 && !isOwnTransaction(_transactions[index])) {
      throw StateError('El movimiento compartido es solo informativo.');
    }
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
    return personalTransactions
        .where((transaction) => transaction.type == TransactionType.ingreso)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  double getTotalExpenses() {
    return personalTransactions
        .where((transaction) => transaction.type == TransactionType.gasto)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  double getMonthlyIncome(DateTime month) => getTransactionsByMonth(month)
      .where((tx) => tx.type == TransactionType.ingreso)
      .fold(0.0, (sum, tx) => sum + tx.amount);

  double getMonthlyExpenses(DateTime month) => getTransactionsByMonth(month)
      .where((tx) => tx.type == TransactionType.gasto)
      .fold(0.0, (sum, tx) => sum + tx.amount);

  double getMonthlySummary(DateTime date) =>
      getMonthlyIncome(date) - getMonthlyExpenses(date);

  List<TransactionModel> getTransactionsByMonth(DateTime date) {
    return personalTransactions.where((transaction) {
      final localDate = transaction.date.toLocal();
      return localDate.year == date.year && localDate.month == date.month;
    }).toList();
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
    return personalTransactions.where((transaction) {
      return transaction.date
              .isAfter(start.subtract(const Duration(days: 1))) &&
          transaction.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  double getTotalByCategory(TransactionCategory category) {
    return personalTransactions
        .where((transaction) => transaction.category == category)
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  @visibleForTesting
  void setTestTransactions(List<TransactionModel> txs) {
    _transactions = txs;
    _filteredTransactions = [];
  }
}
