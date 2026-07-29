// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:billey/screens/splash_screen.dart';
import 'package:billey/screens/auth/auth_screen.dart';
import 'package:billey/theme/app_theme.dart';
import 'package:billey/theme/billey_theme_scope.dart';
import 'package:billey/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'providers/transaction_provider.dart';
import 'providers/category_provider.dart';
import 'providers/currency_provider.dart';
import 'providers/income_distribution_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/theme_settings_provider.dart';
import 'providers/locale_settings_provider.dart';
import 'providers/payment_reminder_provider.dart';
import 'providers/couple_finance_provider.dart';
import 'models/transaction.dart';
import 'models/category.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:billey/core/responsive/responsive.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('es');
  await initializeDateFormatting('en');

  await Hive.initFlutter();

  Hive.registerAdapter(TransactionModelAdapter());
  Hive.registerAdapter(TransactionTypeAdapter());
  Hive.registerAdapter(TransactionCategoryAdapter());
  Hive.registerAdapter(CategoryModelAdapter());

  final themeSettings = ThemeSettingsProvider();
  await themeSettings.initialize();

  final localeSettings = LocaleSettingsProvider();
  await localeSettings.initialize();

  final paymentReminders = PaymentReminderProvider();
  await paymentReminders.initialize();

  final coupleFinance = CoupleFinanceProvider.instance;
  await coupleFinance.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => CurrencyProvider()),
        ChangeNotifierProvider(create: (_) => IncomeDistributionProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider.value(value: themeSettings),
        ChangeNotifierProvider.value(value: localeSettings),
        ChangeNotifierProvider.value(value: paymentReminders),
        ChangeNotifierProvider.value(value: coupleFinance),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeSettingsProvider, LocaleSettingsProvider>(
      builder: (context, themeSettings, localeSettings, _) {
        final appTheme = AppTheme();

        return MaterialApp(
          title: 'Billey',
          theme: appTheme.lightTheme(),
          darkTheme: appTheme.darkTheme(),
          themeMode: themeSettings.themeMode,
          locale: localeSettings.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          themeAnimationDuration: const Duration(milliseconds: 280),
          themeAnimationCurve: Curves.easeInOut,
          builder: (context, child) {
            Responsive.init(context);
            return BilleyThemeBinder(
              child: child ?? const SizedBox.shrink(),
            );
          },
          home: const SplashScreen(),
          routes: {
            '/home': (context) => const SplashScreen(),
            '/auth': (context) => const AuthScreen(),
          },
        );
      },
    );
  }
}
