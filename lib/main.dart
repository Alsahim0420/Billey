// lib/main.dart
import 'package:firebase_auth/firebase_auth.dart';
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
import 'providers/couple_link_provider.dart';
import 'providers/goals_provider.dart';
import 'models/transaction.dart';
import 'models/category.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:billey/core/responsive/responsive.dart';
import 'firebase_options.dart';
import 'features/speech/application/speech_assistant_controller.dart';
import 'features/speech/application/speech_voice_provider.dart';
import 'features/speech/speech_dependencies.dart';

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

  final currencyProvider = CurrencyProvider();
  final paymentReminders = PaymentReminderProvider(
    amountFormatter: currencyProvider.format,
  );
  await paymentReminders.initialize();

  final transactionProvider = TransactionProvider.cloud();
  final categoryProvider = CategoryProvider();
  final profileProvider = ProfileProvider();
  final incomeDistribution = IncomeDistributionProvider();
  final goalsProvider = GoalsProvider();

  final coupleLink = CoupleLinkProvider()..initialize();
  coupleLink.addListener(() {
    transactionProvider.setPartnerUid(coupleLink.partnerUid);
    goalsProvider.setPartnerUid(coupleLink.partnerUid);
  });

  // Local storage (SharedPreferences, Hive) has no built-in concept of
  // "the signed-in user" the way Firestore paths do, so every provider
  // backed by it must explicitly re-load when the account changes —
  // otherwise a new sign-in on the same device keeps showing (or
  // overwriting) the previous account's name, categories, budget split,
  // savings goals and payment reminders.
  FirebaseAuth.instance.authStateChanges().listen((_) {
    profileProvider.load();
    categoryProvider.initialize();
    incomeDistribution.load();
    paymentReminders.reload();
    transactionProvider.loadTransactions();
    goalsProvider.load();
  });

  final speechVoiceProvider = SpeechVoiceProvider();
  await speechVoiceProvider.initialize();

  late final SpeechAssistantController speechAssistant;
  try {
    speechAssistant = await SpeechDependencies.initialize(
      voiceProvider: speechVoiceProvider,
    );
  } catch (error, stackTrace) {
    debugPrint('SpeechDependencies.initialize failed: $error\n$stackTrace');
    speechAssistant = SpeechAssistantController.unavailable(
      'Configura y cifra las variables de ElevenLabs para usar la voz.',
    );
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: transactionProvider),
        ChangeNotifierProvider.value(value: categoryProvider),
        ChangeNotifierProvider.value(value: currencyProvider),
        ChangeNotifierProvider.value(value: incomeDistribution),
        ChangeNotifierProvider.value(value: profileProvider),
        ChangeNotifierProvider.value(value: themeSettings),
        ChangeNotifierProvider.value(value: localeSettings),
        ChangeNotifierProvider.value(value: paymentReminders),
        ChangeNotifierProvider.value(value: goalsProvider),
        ChangeNotifierProvider.value(value: coupleLink),
        ChangeNotifierProvider.value(value: speechAssistant),
        ChangeNotifierProvider.value(value: speechVoiceProvider),
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
