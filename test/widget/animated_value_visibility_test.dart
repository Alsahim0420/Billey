import 'package:billey/widgets/animated_value_visibility.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('amount crossfades and leaves no visible value after hiding',
      (tester) async {
    var hidden = false;
    late StateSetter update;
    await tester.pumpWidget(
        MaterialApp(home: StatefulBuilder(builder: (context, setState) {
      update = setState;
      return Scaffold(
          body: AnimatedValueVisibility(
              hidden: hidden,
              replacement: const Text('••••••'),
              child: const Text('123456')));
    })));
    update(() => hidden = true);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('••••••'), findsOneWidget);
    final fades =
        tester.widgetList<FadeTransition>(find.byType(FadeTransition));
    expect(fades.any((f) => f.opacity.value > 0 && f.opacity.value < 1), true);
    await tester.pumpAndSettle();
    expect(find.text('123456'), findsNothing);
    update(() => hidden = false);
    await tester.pumpAndSettle();
    expect(find.text('123456'), findsOneWidget);
    expect(find.text('••••••'), findsNothing);
  });
}
