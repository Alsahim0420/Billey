import 'package:billey/theme/app_theme.dart';
import 'package:billey/theme/billey_palette.dart';
import 'package:billey/theme/billey_theme_scope.dart';
import 'package:billey/theme/colors/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _Probe extends StatelessWidget {
  const _Probe();
  @override
  Widget build(BuildContext context) {
    BilleyThemeScope.isDarkOf(context);
    return Scaffold(
        body: Column(children: [
      ColoredBox(
          key: const Key('background'),
          color: AppColors.backgroundColor,
          child:
              Text('Billey', style: TextStyle(color: AppColors.textPrimary))),
      const TextField(key: Key('form')),
    ]));
  }
}

void main() {
  testWidgets('legacy colors animate both ways without replacing page state',
      (tester) async {
    final mode = ValueNotifier(ThemeMode.dark);
    addTearDown(mode.dispose);
    addTearDown(() => AppColors.isDarkMode = true);
    final themes = AppTheme();
    await tester.pumpWidget(ValueListenableBuilder<ThemeMode>(
        valueListenable: mode,
        builder: (_, value, __) => MaterialApp(
            theme: themes.lightTheme(),
            darkTheme: themes.darkTheme(),
            themeMode: value,
            themeAnimationDuration: const Duration(milliseconds: 420),
            themeAnimationCurve: Curves.easeInOutCubic,
            builder: (_, child) => BilleyThemeBinder(child: child!),
            home: const _Probe())));
    await tester.pumpAndSettle();
    Color background() =>
        tester.widget<ColoredBox>(find.byKey(const Key('background'))).color;
    final dark = BilleyPalette.dark().backgroundColor;
    final light = BilleyPalette.light().backgroundColor;
    expect(background(), dark);
    await tester.enterText(find.byKey(const Key('form')), 'Conservado');
    mode.value = ThemeMode.light;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));
    expect(background(), isNot(dark));
    expect(background(), isNot(light));
    await tester.pumpAndSettle();
    expect(background(), light);
    mode.value = ThemeMode.dark;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));
    expect(background(), isNot(light));
    expect(background(), isNot(dark));
    // A second toggle during the animation keeps the screen and its form.
    mode.value = ThemeMode.light;
    await tester.pumpAndSettle();
    expect(background(), light);
    expect(find.text('Conservado'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
