import 'dart:ui' as ui;
import 'package:billey/widgets/budget_spend_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
      'wide bars contain readable details for short, full and exceeded values',
      (tester) async {
    for (final scale in [1.0, 2.0]) {
      for (final amount in [0.0, 10.0, 100.0, 150.0]) {
        await tester.pumpWidget(MaterialApp(
            home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(scale)),
          child: Center(
              child: SizedBox(
                  width: 88,
                  height: 402,
                  child: BudgetBarLayout(
                    width: 88,
                    header: const SizedBox.shrink(),
                    footer: const Text('Compras',
                        maxLines: 1, style: TextStyle(fontSize: 10)),
                    bar: BudgetBarDetails(
                        amount: amount,
                        budget: 100,
                        maximum: 150,
                        progress: 1,
                        color: Colors.blue,
                        icon: Icons.shopping_bag,
                        amountLabel: '1,16 M',
                        bar: BudgetSpendBar(
                            amount: amount,
                            budget: 100,
                            maximum: 150,
                            progress: 1,
                            color: Colors.blue,
                            semanticLabel: 'Compras')),
                  ))),
        )));
        await tester.pump();
        expect(tester.takeException(), isNull);
        expect(find.text('1,16 M'), findsOneWidget);
        expect(find.text('116%'), findsNothing);
        expect(tester.getSize(find.byType(BudgetSpendBar)).width, 88);
        final plot = tester.getRect(find.byType(BudgetBarDetails));
        for (final label in ['1,16 M']) {
          final labelRect = tester.getRect(find.text(label));
          expect(plot.contains(labelRect.topLeft), true);
          expect(plot.contains(labelRect.bottomRight), true);
        }
      }
    }
  });

  testWidgets(
      'budget columns fit iPhone constraints with excess and larger text',
      (tester) async {
    for (final scale in [1.0, 1.3, 2.0]) {
      await tester.pumpWidget(MaterialApp(
          home: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(scale)),
        child: Center(
            child: SizedBox(
                width: 176,
                height: 402,
                child: Row(children: [
                  for (final exceeded in [false, true])
                    Expanded(
                        child: BudgetBarLayout(
                      header: const Text('1,16 M',
                          maxLines: 1, style: TextStyle(fontSize: 12)),
                      bar: BudgetSpendBar(
                          key: ValueKey(exceeded),
                          amount: exceeded ? 116 : 80,
                          budget: 100,
                          maximum: 116,
                          color: Colors.blue,
                          progress: 1,
                          semanticLabel: 'Presupuesto'),
                      footer: Column(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.shopping_bag, size: 19),
                        const SizedBox(height: 3),
                        const Text('Compras',
                            maxLines: 1, style: TextStyle(fontSize: 10)),
                        Text(exceeded ? '+16 mil' : ' ',
                            maxLines: 1, style: const TextStyle(fontSize: 10)),
                        Text(exceeded ? '116%' : '80%',
                            maxLines: 1, style: const TextStyle(fontSize: 10)),
                      ]),
                    )),
                ]))),
      )));
      await tester.pump();
      expect(tester.takeException(), isNull);
      final regular = tester.getSize(find.byKey(const ValueKey(false)));
      final excess = tester.getSize(find.byKey(const ValueKey(true)));
      expect(regular.height, greaterThan(0));
      expect(regular.height, excess.height);
    }
  });

  testWidgets('only the portion over the limit uses a darker category tone',
      (tester) async {
    final key = GlobalKey();
    const color = Color(0xff40bfa0);
    Future<int> darkPixels(double amount) async {
      await tester.pumpWidget(MaterialApp(
          home: Center(
              child: RepaintBoundary(
                  key: key,
                  child: SizedBox(
                      width: 64,
                      height: 200,
                      child: BudgetSpendBar(
                          amount: amount,
                          budget: 20,
                          maximum: 40,
                          color: color,
                          progress: 1,
                          semanticLabel: 'Comida'))))));
      await tester.pump();
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final bytes = (await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: 1);
        final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
        image.dispose();
        return data;
      }))!;
      var count = 0;
      // Inspect the region above the target, excluding the target rail itself.
      for (var y = 65; y < 90; y++) {
        for (var x = 10; x < 54; x++) {
          final offset = (y * 64 + x) * 4;
          if (bytes.getUint8(offset + 3) > 200 &&
              bytes.getUint8(offset + 1) < 160) {
            count++;
          }
        }
      }
      expect(tester.takeException(), isNull);
      return count;
    }

    expect(await darkPixels(10), 0);
    expect(await darkPixels(30), greaterThan(100));
  });
  testWidgets('zero, missing budget and very large excess render within bounds',
      (tester) async {
    for (final amount in [0.0, 20.0, 1000000000.0]) {
      for (final budget in [null, 20.0]) {
        await tester.pumpWidget(MaterialApp(
            home: Center(
                child: SizedBox(
                    width: 64,
                    height: 200,
                    child: BudgetSpendBar(
                        amount: amount,
                        budget: budget,
                        maximum: 1000000000,
                        color: Colors.blue,
                        progress: 0.5,
                        semanticLabel: 'Gasto')))));
        await tester.pump();
        expect(tester.takeException(), isNull);
      }
    }
  });
}
