/// A recurring monthly cycle. Adjacent periods share exactly one boundary.
class FinancialCycle {
  const FinancialCycle([this.startDay = 1])
      : assert(startDay >= 1 && startDay <= 31);
  final int startDay;
  int get closingDay => startDay == 1 ? 31 : startDay - 1;
  DateTime startFor(DateTime month) => DateTime(month.year, month.month,
      startDay.clamp(1, DateTime(month.year, month.month + 1, 0).day));
  FinancialPeriod forMonth(DateTime month) => FinancialPeriod(
      startFor(month), startFor(DateTime(month.year, month.month + 1)));
  FinancialPeriod containing(DateTime date) {
    final local = date.toLocal();
    final month = DateTime(local.year, local.month);
    return forMonth(local.isBefore(startFor(month))
        ? DateTime(local.year, local.month - 1)
        : month);
  }
}

class FinancialPeriod {
  const FinancialPeriod(this.start, this.endExclusive);
  final DateTime start, endExclusive;
  DateTime get lastDay =>
      DateTime(endExclusive.year, endExclusive.month, endExclusive.day - 1);
  bool contains(DateTime date) =>
      !date.toLocal().isBefore(start) && date.toLocal().isBefore(endExclusive);
}
