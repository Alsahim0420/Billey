import 'package:flutter/material.dart';
import 'colors/app_colors.dart';

class AppTheme {
  ThemeData getTheme() => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.backgroundColor,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primaryColor,
          primaryContainer: AppColors.primaryColorDark,
          secondary: AppColors.primaryColor,
          surface: AppColors.backgroundColor,
          onPrimary: AppColors.white,
          onSecondary: AppColors.white,
          onSurface: AppColors.textPrimary,
          error: AppColors.errorColor,
          onError: AppColors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surfaceColor,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          centerTitle: false,
        ),
        cardTheme: const CardThemeData(
          color: AppColors.surfaceColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.surfaceColor,
          selectedItemColor: AppColors.primaryColor,
          unselectedItemColor: AppColors.textSecondary,
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(color: AppColors.textPrimary),
          headlineMedium: TextStyle(color: AppColors.textPrimary),
          headlineSmall: TextStyle(color: AppColors.textPrimary),
          bodyLarge: TextStyle(color: AppColors.textPrimary),
          bodyMedium: TextStyle(color: AppColors.textPrimary),
          bodySmall: TextStyle(color: AppColors.textSecondary),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primaryColor,
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: AppColors.primaryColor),
          ),
          labelStyle: TextStyle(color: AppColors.textSecondary),
          hintStyle: TextStyle(color: AppColors.textLight),
        ),
        dialogTheme: const DialogThemeData(
          backgroundColor: AppColors.surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: AppColors.surfaceColor,
          contentTextStyle: TextStyle(color: AppColors.textPrimary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      );
}
