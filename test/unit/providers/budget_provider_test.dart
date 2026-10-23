import 'dart:async';
import 'package:billey/models/category_budget.dart';
import 'package:billey/models/category.dart';
import 'package:billey/models/transaction.dart';
import 'package:billey/providers/income_distribution_provider.dart';
import 'package:billey/providers/budget_provider.dart';
import 'package:billey/services/firestore_budget_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

class _Distribution extends IncomeDistributionProvider {
  IncomeDistributionTemplate template =
      IncomeDistributionProvider.templates.first;
  bool enabled = true;
  @override
  Future<void> load() async {}
  @override
  bool get isLoaded => true;
  @override
  bool get autoEnabled => enabled;
  @override
  IncomeDistributionTemplate get activeTemplate => template;
}

class _Auth extends Fake implements FirebaseAuth {}

class _Db extends Fake implements FirebaseFirestore {}

class _Service extends FirestoreBudgetService {
  _Service() : super(auth: _Auth(), firestore: _Db());
  final streams = <String, StreamController<List<CategoryBudget>>>{};
  Future<List<CategoryBudget>>? nextRead;
  @override
  Future<List<CategoryBudget>> readOnce(String owner) =>
      nextRead ?? Future.value([]);
  List<String>? copied;
  @override
  Stream<List<CategoryBudget>> watch(String owner) =>
      streams.putIfAbsent(owner, () => StreamController.broadcast()).stream;
  @override
  Future<int> copyMonth(
      String owner, String source, String target, String currency) async {
    copied = [owner, source, target, currency];
    return 2;
  }
}

CategoryBudget budget(String category,
        {String month = '2026-10', String currency = 'COP'}) =>
    CategoryBudget(
        month: month,
        categoryId: category,
        categoryName: category,
        currency: currency,
        limit: 100);
void main() {
  test('account switches clear previous limits and ignore old events',
      () async {
    final service = _Service();
    final provider = BudgetProvider(service: service);
    addTearDown(() async {
      provider.dispose();
      for (final s in service.streams.values) {
        await s.close();
      }
    });
    provider.bindUser('a');
    service.streams['a']!.add([budget('food')]);
    await Future<void>.delayed(Duration.zero);
    expect(provider.forMonth(DateTime(2026, 10), 'COP').length, 1);
    provider.bindUser('b');
    expect(provider.forMonth(DateTime(2026, 10), 'COP'), isEmpty);
    service.streams['a']!.add([budget('transport')]);
    service.streams['b']!.add([
      budget('health'),
      budget('food', currency: 'USD'),
      budget('food', month: '2026-11')
    ]);
    await Future<void>.delayed(Duration.zero);
    expect(provider.forMonth(DateTime(2026, 10), 'COP').single.categoryId,
        'health');
    expect(() => provider.save('a', budget('food')), throwsStateError);
    provider.bindUser(null);
    expect(provider.forMonth(DateTime(2026, 10), 'COP'), isEmpty);
  });
  test(
      'manual limits override changing automatic defaults and reset restores them',
      () async {
    final distribution = _Distribution();
    await distribution.load();
    final service = _Service();
    final provider = BudgetProvider(service: service)..bindUser('a');
    final income = TransactionModel(
        id: 'income',
        title: 'Income',
        amount: 1000000,
        date: DateTime(2026, 10),
        type: TransactionType.ingreso,
        category: TransactionCategory.other,
        ownerId: 'a',
        currencyCode: 'COP');
    List<CategoryBudget> limits() =>
        provider.effectiveForMonth(DateTime(2026, 10), 'COP',
            distribution: distribution,
            categories: CategoryModel.getDefaultCategories(),
            transactions: [income]);
    final automatic = limits().firstWhere((b) => b.categoryId == 'food').limit;
    service.streams['a']!.add([budget('food')]);
    await Future<void>.delayed(Duration.zero);
    expect(limits().firstWhere((b) => b.categoryId == 'food').limit, 100);
    distribution.template = IncomeDistributionProvider.templates[2];
    expect(limits().firstWhere((b) => b.categoryId == 'food').limit, 100);
    service.streams['a']!.add([]);
    await Future<void>.delayed(Duration.zero);
    expect(limits().firstWhere((b) => b.categoryId == 'food').limit,
        lessThan(automatic));
    distribution.enabled = false;
    expect(limits(), isEmpty);
    provider.dispose();
    distribution.dispose();
    await service.streams['a']!.close();
  });
  test(
      'refresh preserves cached budgets on error and ignores a response after account switch',
      () async {
    final service = _Service();
    final provider = BudgetProvider(service: service)..bindUser('a');
    service.streams['a']!.add([budget('food')]);
    await Future<void>.delayed(Duration.zero);
    service.nextRead = Future.error(StateError('offline'));
    await expectLater(provider.refresh(), throwsStateError);
    expect(
        provider.forMonth(DateTime(2026, 10), 'COP').single.categoryId, 'food');
    expect(provider.hasError, isTrue);
    final pending = Completer<List<CategoryBudget>>();
    service.nextRead = pending.future;
    final refreshing = provider.refresh();
    provider.bindUser('b');
    pending.complete([budget('transport')]);
    await refreshing;
    expect(provider.forMonth(DateTime(2026, 10), 'COP'), isEmpty);
    provider.dispose();
    for (final stream in service.streams.values) {
      await stream.close();
    }
  });
  test('copying January uses December of previous year', () async {
    final service = _Service();
    final provider = BudgetProvider(service: service);
    addTearDown(() async {
      provider.dispose();
      for (final s in service.streams.values) {
        await s.close();
      }
    });
    provider.bindUser('a');
    expect(await provider.copyPrevious('a', DateTime(2026, 1), 'COP'), 2);
    expect(service.copied, ['a', '2025-12', '2026-01', 'COP']);
  });
}
