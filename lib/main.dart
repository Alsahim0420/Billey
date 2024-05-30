// lib/main.dart
import 'package:flutter/material.dart';
import 'package:my_finances_app/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'providers/transaction_provider.dart';
import 'screens/transaction_list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TransactionProvider(),
      child: MaterialApp(
        title: 'Financial Manager',
        theme: AppTheme().getTheme(),
        home: const TransactionListScreen(),
      ),
    );
  }
}
