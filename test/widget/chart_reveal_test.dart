import 'package:billey/widgets/chart_reveal.dart';
import 'package:billey/widgets/budget_spend_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('fill and amount advance together and replay after refresh',
      (tester) async {
    var builds = 0;
    Future<void> render(int revision) => tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: SizedBox(
                width: 88,
                height: 320,
                child: ChartReveal(
                    key: ValueKey(revision),
                    animationBuilder: (context, animation) {
                      builds++;
                      return BudgetBarDetails(
                          amount: 100,
                          budget: 80,
                          maximum: 100,
                          progress: 1,
                          animation: animation,
                          color: Colors.blue,
                          icon: Icons.shopping_bag,
                          amountLabel: '100',
                          amountFormatter: (value) => value.round().toString(),
                          bar: BudgetSpendBar(
                              amount: 100,
                              budget: 80,
                              maximum: 100,
                              color: Colors.blue,
                              progress: 1,
                              animation: animation,
                              semanticLabel: 'Compras'));
                    })))));
    await render(0);
    expect(find.text('0'), findsOneWidget);
    expect(
        tester
            .widget<BudgetSpendBar>(find.byType(BudgetSpendBar))
            .animation!
            .value,
        0);
    final initialBuilds = builds;
    await tester.pump(const Duration(milliseconds: 300));
    final partial = tester
        .widget<BudgetSpendBar>(find.byType(BudgetSpendBar))
        .animation!
        .value;
    expect(builds, initialBuilds);
    expect(partial, greaterThan(0));
    expect(partial, lessThan(1));
    expect(find.text((100 * partial).round().toString()), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('100'), findsOneWidget);
    expect(
        tester
            .widget<BudgetSpendBar>(find.byType(BudgetSpendBar))
            .animation!
            .value,
        1);
    await render(1);
    expect(find.text('0'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('100'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
