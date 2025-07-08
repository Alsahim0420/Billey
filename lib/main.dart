// lib/main.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_finances_app/screens/splash_screen.dart';
import 'package:my_finances_app/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'providers/transaction_provider.dart';
import 'providers/category_provider.dart';
import 'models/transaction.dart';
import 'models/category.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es');

  // Inicializar Hive
  await Hive.initFlutter();

  // Registrar los adaptadores de Hive
  Hive.registerAdapter(TransactionModelAdapter());
  Hive.registerAdapter(TransactionTypeAdapter());
  Hive.registerAdapter(TransactionCategoryAdapter());
  Hive.registerAdapter(CategoryModelAdapter());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CategoryProvider()),
        ChangeNotifierProvider(create: (context) => TransactionProvider()),
      ],
      child: MaterialApp(
        title: 'Financial Manager',
        theme: AppTheme().getTheme(),
        home: const SplashScreen(),
      ),
    );
  }
}
