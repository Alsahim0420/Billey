import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:billey/providers/financial_cycle_provider.dart';
import 'package:billey/widgets/monthly_period_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('custom cycle rolls over at midnight inside the same month',
      (tester) async {
    SharedPreferences.setMockInitialValues({'financial_cycle_start_me': 27});
    final provider = FinancialCycleProvider();
    await provider.bindUser('me');
    var now = DateTime(2026, 10, 26, 23, 59, 59);
    await tester.pumpWidget(ChangeNotifierProvider.value(
        value: provider,
        child: MaterialApp(
            home: MonthlyPeriodBuilder(
                now: () => now,
                builder: (_, start) => Text('${start.month}-${start.day}')))));
    expect(find.text('9-27'), findsOneWidget);
    now = DateTime(2026, 10, 27);
    await tester.pump(const Duration(milliseconds: 1100));
    expect(find.text('10-27'), findsOneWidget);
    await provider.save(15);
    await tester.pump();
    expect(find.text('10-15'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    provider.dispose();
  });
  testWidgets('open app updates its calendar month at midnight',
      (tester) async {
    var now = DateTime(2026, 10, 31, 23, 59, 59);
    await tester.pumpWidget(MaterialApp(
        home: MonthlyPeriodBuilder(
            now: () => now,
            builder: (_, month) => Text('${month.year}-${month.month}'))));
    expect(find.text('2026-10'), findsOneWidget);
    now = DateTime(2026, 11, 1);
    await tester.pump(const Duration(milliseconds: 1100));
    expect(find.text('2026-11'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });
  testWidgets(
      'resuming after a year boundary updates immediately and keeps state',
      (tester) async {
    var now = DateTime(2026, 12, 20);
    await tester.pumpWidget(MaterialApp(
        home: MonthlyPeriodBuilder(
            now: () => now,
            builder: (_, month) => Scaffold(
                    body: Column(children: [
                  Text('${month.year}-${month.month}'),
                  const TextField()
                ])))));
    await tester.enterText(find.byType(TextField), 'Conservado');
    for (final state in [
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused
    ]) {
      tester.binding.handleAppLifecycleStateChanged(state);
    }
    now = DateTime(2027, 1, 2);
    for (final state in [
      AppLifecycleState.hidden,
      AppLifecycleState.inactive,
      AppLifecycleState.resumed
    ]) {
      tester.binding.handleAppLifecycleStateChanged(state);
    }
    await tester.pump();
    expect(find.text('2027-1'), findsOneWidget);
    expect(find.text('Conservado'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
