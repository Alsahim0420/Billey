import 'dart:async';
import 'package:billey/l10n/app_localizations.dart';
import 'package:billey/widgets/billey_pull_to_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _show(WidgetTester tester, Future<void> Function() refresh) async {
  await tester.pumpWidget(MaterialApp(
      locale: const Locale('es'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
          body: BilleyPullToRefresh(
              onRefresh: refresh,
              builder: (_, physics) => SingleChildScrollView(
                  physics: physics,
                  child: const SizedBox(
                      height: 180,
                      width: double.infinity,
                      child: Text('Inicio')))))));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
      'short home content refreshes by dragging and awaits data before success',
      (tester) async {
    var calls = 0;
    final request = Completer<void>();
    await _show(tester, () {
      calls++;
      return request.future;
    });
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, 350));
    for (var i = 0; i < 60; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(calls, 1);
    expect(find.text('Actualizando tu información…'), findsOneWidget);
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, 350));
    await tester.pump(const Duration(milliseconds: 200));
    expect(calls, 1);
    request.complete();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Todo actualizado'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
  testWidgets(
      'failed refresh shows error and leaves content available for retry',
      (tester) async {
    final request = Completer<void>();
    await _show(tester, () => request.future);
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, 350));
    for (var i = 0; i < 60; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    request.completeError(StateError('offline'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(
        find.text('No se pudo actualizar. Intenta de nuevo.'), findsOneWidget);
    expect(find.text('Inicio'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
