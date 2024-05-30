import 'package:flutter/material.dart';

class AppTheme {
  ThemeData getTheme() => ThemeData(
      useMaterial3: true,
      colorSchemeSeed: Colors.teal,
      brightness: Brightness.dark,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.teal,
      ));
}
