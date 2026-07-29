import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'billey_palette.dart';
import 'billey_theme_extension.dart';
import 'colors/app_colors.dart';

class AppTheme {
  ThemeData lightTheme() => _buildTheme(Brightness.light);

  ThemeData darkTheme() => _buildTheme(Brightness.dark);

  ThemeData getTheme() => darkTheme();

  ThemeData _buildTheme(Brightness brightness) {
    final palette = BilleyPalette.forBrightness(brightness);
    final isDark = palette.isDark;
    final billey = BilleyTheme(palette);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: palette.backgroundColor,
      extensions: [billey],
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: AppColors.primaryColor,
        onPrimary: AppColors.white,
        secondary: AppColors.primaryColor,
        onSecondary: AppColors.white,
        surface: palette.surfaceColor,
        onSurface: palette.textPrimary,
        error: AppColors.errorColor,
        onError: AppColors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: palette.backgroundColor,
        foregroundColor: palette.textPrimary,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle:
            isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          color: palette.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: IconThemeData(color: palette.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: palette.surfaceColor,
        elevation: isDark ? 0 : 1,
        shadowColor: isDark ? Colors.transparent : const Color(0x14111827),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: palette.backgroundAlt,
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: palette.textSecondary,
      ),
      dividerColor: palette.borderSubtle,
      textTheme: TextTheme(
        headlineLarge: TextStyle(color: palette.textPrimary),
        headlineMedium: TextStyle(color: palette.textPrimary),
        headlineSmall: TextStyle(color: palette.textPrimary),
        bodyLarge: TextStyle(color: palette.textPrimary),
        bodyMedium: TextStyle(color: palette.textPrimary),
        bodySmall: TextStyle(color: palette.textSecondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryColor,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.surfaceInput,
        border: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide(
            color: isDark ? const Color(0x33FFFFFF) : const Color(0xFFD1D5DB),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide(
            color: isDark ? const Color(0x33FFFFFF) : const Color(0xFFD1D5DB),
            width: 1,
          ),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide(color: AppColors.primaryColor, width: 1.5),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide(color: AppColors.errorColor, width: 1),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide(color: AppColors.errorColor, width: 1.5),
        ),
        labelStyle: TextStyle(color: palette.textSecondary),
        hintStyle: TextStyle(color: palette.textLight),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: palette.surfaceColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(24)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: palette.surfaceColor,
        contentTextStyle: TextStyle(color: palette.textPrimary),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      iconTheme: IconThemeData(color: palette.textPrimary),
    );
  }
}
