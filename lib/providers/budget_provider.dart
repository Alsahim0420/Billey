import '../models/financial_cycle.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/category_budget.dart';
import '../models/automatic_category_budgets.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import 'income_distribution_provider.dart';
import '../services/firestore_budget_service.dart';

class BudgetProvider extends ChangeNotifier {
  BudgetProvider({FirestoreBudgetService? service})
      : _service = service ?? FirestoreBudgetService();
  final FirestoreBudgetService _service;
  StreamSubscription<List<CategoryBudget>>? _subscription;
  List<CategoryBudget> _budgets = [];
  String? userId;
  bool loaded = false;
  bool hasError = false;
  int _generation = 0;

  void bindUser(String? uid) {
    final generation = ++_generation;
    _subscription?.cancel();
    _subscription = null;
    userId = uid;
    _budgets = [];
    loaded = uid == null;
    hasError = false;
    notifyListeners();
    if (uid == null) return;
    _subscription = _service.watch(uid).listen((data) {
      if (generation != _generation) return;
      _budgets = data;
      loaded = true;
      hasError = false;
      notifyListeners();
    }, onError: (Object error) {
      if (generation != _generation) return;
      hasError = true;
      loaded = true;
      notifyListeners();
    });
  }

  Future<void> refresh() async {
    final owner = userId;
    final generation = _generation;
    if (owner == null) return;
    try {
      final budgets = await _service.readOnce(owner);
      if (generation != _generation || userId != owner) return;
      _budgets = budgets;
      loaded = true;
      hasError = false;
      notifyListeners();
    } catch (_) {
      if (generation == _generation && userId == owner) {
        hasError = true;
        notifyListeners();
      }
      rethrow;
    }
  }

  List<CategoryBudget> forMonth(DateTime month, String currency) => _budgets
      .where((b) =>
          b.month == CategoryBudget.monthKey(month) && b.currency == currency)
      .toList();

  List<CategoryBudget> effectiveForMonth(
    DateTime month,
    String currency, {
    required IncomeDistributionProvider? distribution,
    FinancialCycle cycle = const FinancialCycle(),
    required Iterable<CategoryModel> categories,
    required Iterable<TransactionModel> transactions,
  }) {
    final defaults = userId != null &&
            distribution != null &&
            distribution.isLoaded &&
            distribution.autoEnabled
        ? AutomaticCategoryBudgets.calculate(
            month: month,
            cycle: cycle,
            currency: currency,
            owner: userId!,
            template: distribution.activeTemplate,
            categories: categories,
            transactions: transactions)
        : <CategoryBudget>[];
    final merged = {for (final b in defaults) b.categoryId: b};
    for (final b in forMonth(month, currency)) {
      merged[b.categoryId] = b;
    }
    return merged.values.toList();
  }

  void _check(String owner) {
    if (userId != owner) throw StateError('La cuenta cambió.');
  }

  Future<void> save(String owner, CategoryBudget budget) {
    _check(owner);
    return _service.save(owner, budget);
  }

  Future<void> remove(String owner, CategoryBudget budget) {
    _check(owner);
    return _service.delete(owner, budget);
  }

  Future<int> copyPrevious(String owner, DateTime month, String currency) {
    _check(owner);
    return _service.copyMonth(
        owner,
        CategoryBudget.monthKey(DateTime(month.year, month.month - 1)),
        CategoryBudget.monthKey(month),
        currency);
  }

  Future<int> copyNext(String owner, DateTime month, String currency) {
    _check(owner);
    return _service.copyMonth(
        owner,
        CategoryBudget.monthKey(DateTime(month.year, month.month + 1)),
        CategoryBudget.monthKey(month),
        currency);
  }

  @override
  void dispose() {
    _generation++;
    _subscription?.cancel();
    super.dispose();
  }
}
