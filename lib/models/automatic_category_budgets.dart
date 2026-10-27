import '../models/financial_cycle.dart';
import 'category.dart';
import 'category_budget.dart';
import 'transaction.dart';
import '../providers/income_distribution_provider.dart';

/// Derived defaults; explicit monthly Firestore limits always take precedence.
class AutomaticCategoryBudgets {
  static String bucketFor(CategoryModel category) {
    if (['food', 'transport', 'health', 'education'].contains(category.id) ||
        [
          'Necesidades Básicas',
          'Bienestar',
          'Desarrollo Personal',
          'Trabajo',
          'Hogar'
        ].contains(category.section)) {
      return 'essentials';
    }
    if (category.section == 'Inversiones') return 'investing';
    return 'wants';
  }

  static List<CategoryBudget> calculate({
    required DateTime month,
    FinancialCycle cycle = const FinancialCycle(),
    required String currency,
    required String owner,
    required IncomeDistributionTemplate template,
    required Iterable<CategoryModel> categories,
    required Iterable<TransactionModel> transactions,
  }) {
    if (!template.isValid) return [];
    final own = transactions.where((t) =>
        (t.ownerId == null || t.ownerId == owner) &&
        (t.currencyCode == null || t.currencyCode == currency));
    double incomeFor(DateTime m) => own
        .where((t) =>
            t.type == TransactionType.ingreso &&
            cycle.forMonth(m).contains(t.date))
        .fold(0.0, (sum, t) => sum + t.amount);
    final income = incomeFor(month);
    final base =
        income > 0 ? income : incomeFor(DateTime(month.year, month.month - 1));
    if (!base.isFinite || base <= 0) return [];
    final start = cycle.startFor(DateTime(month.year, month.month - 3));
    final end = cycle.startFor(month);
    final history = <String, double>{};
    for (final t in own) {
      final date = t.date.toLocal();
      if (t.type == TransactionType.gasto &&
          !date.isBefore(start) &&
          date.isBefore(end)) {
        history.update(t.effectiveCategoryId, (v) => v + t.amount,
            ifAbsent: () => t.amount);
      }
    }
    final result = <CategoryBudget>[];
    // Savings, investment, buffer and debt envelopes are reserved, never
    // redistributed to ordinary expense categories.
    for (final bucket in template.buckets
        .where((b) => ['essentials', 'wants'].contains(b.id))) {
      final group = categories
          .where(
              (c) => c.isActive && c.id != 'other' && bucketFor(c) == bucket.id)
          .toList()
        ..sort((a, b) => a.id.compareTo(b.id));
      if (group.isEmpty || bucket.percent <= 0) continue;
      final historical =
          group.fold(0.0, (sum, c) => sum + (history[c.id] ?? 0));
      // A small equal share leaves room for categories with no past spending.
      double weight(CategoryModel c) => historical > 0
          ? 0.9 * (history[c.id] ?? 0) / historical + 0.1 / group.length
          : 1 / group.length;
      final scale = currency == 'COP' ? 1 : 100;
      final pool = (base * bucket.percent / 100 * scale).round();
      var remaining = pool;
      for (var i = 0; i < group.length; i++) {
        final c = group[i];
        final units =
            i == group.length - 1 ? remaining : (pool * weight(c)).floor();
        remaining -= units;
        if (units <= 0) continue;
        result.add(CategoryBudget(
            month: CategoryBudget.monthKey(month),
            categoryId: c.id,
            categoryName: c.name,
            currency: currency,
            limit: units / scale));
      }
    }
    return result;
  }
}
