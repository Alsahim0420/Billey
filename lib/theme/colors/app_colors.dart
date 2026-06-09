import 'package:flutter/material.dart';

class AppColors {
  static bool isDarkMode = true;

  // Stitch Billey tokens (igual en ambos modos)
  static const Color primaryColor = Color(0xFF1FAD98);
  static const Color primaryColorLight = Color(0xFF7BE0D0);
  static const Color primaryColorDark = Color(0xFF168675);
  static const Color primaryColorTransparent = Color(0x331FAD98);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF111827);

  // Colores de transacciones
  static const Color incomeColor = Color(0xFF1FAD98);
  static const Color incomeColorLight = Color(0xFF6EE7B7);
  static const Color expenseColor = Color(0xFFFF6B6B);
  static const Color expenseColorLight = Color(0xFFFFA3A3);

  // Fondos oscuros
  static const Color _backgroundDark = Color(0xFF0B0E11);
  static const Color _backgroundAltDark = Color(0xFF12201E);
  static const Color _surfaceDark = Color(0xFF161B22);
  static const Color _surfaceElevatedDark = Color(0xFF1A2C29);
  static const Color _surfaceInputDark = Color(0xFF1F302D);
  static const Color _surfacePressedDark = Color(0xFF2A3F3B);
  static const Color _charcoalDark = Color(0xFF12211E);
  static const Color _borderSubtleDark = Color(0x14FFFFFF);

  // Fondos claros
  static const Color _backgroundLight = Color(0xFFFFFFFF);
  static const Color _backgroundAltLight = Color(0xFFF3F4F6);
  static const Color _surfaceLight = Color(0xFFFFFFFF);
  static const Color _surfaceElevatedLight = Color(0xFFF9FAFB);
  static const Color _surfaceInputLight = Color(0xFFF3F4F6);
  static const Color _surfacePressedLight = Color(0xFFE5E7EB);
  static const Color _charcoalLight = Color(0xFFFFFFFF);
  static const Color _borderSubtleLight = Color(0x1A111827);

  // Texto oscuro
  static const Color _textPrimaryDark = Color(0xFFFFFFFF);
  static const Color _textSecondaryDark = Color(0xFF9CA3AF);
  static const Color _textLightDark = Color(0xFF6B7280);

  // Texto claro
  static const Color _textPrimaryLight = Color(0xFF111827);
  static const Color _textSecondaryLight = Color(0xFF6B7280);
  static const Color _textLightLight = Color(0xFF9CA3AF);

  static Color get backgroundColor =>
      isDarkMode ? _backgroundDark : _backgroundLight;

  static Color get backgroundAlt =>
      isDarkMode ? _backgroundAltDark : _backgroundAltLight;

  static Color get surfaceColor => isDarkMode ? _surfaceDark : _surfaceLight;

  static Color get surfaceElevated =>
      isDarkMode ? _surfaceElevatedDark : _surfaceElevatedLight;

  static Color get surfaceInput =>
      isDarkMode ? _surfaceInputDark : _surfaceInputLight;

  static Color get surfacePressed =>
      isDarkMode ? _surfacePressedDark : _surfacePressedLight;

  static Color get charcoal => isDarkMode ? _charcoalDark : _charcoalLight;

  static Color get borderSubtle =>
      isDarkMode ? _borderSubtleDark : _borderSubtleLight;

  static Color get textPrimary =>
      isDarkMode ? _textPrimaryDark : _textPrimaryLight;

  static Color get textSecondary =>
      isDarkMode ? _textSecondaryDark : _textSecondaryLight;

  static Color get textLight => isDarkMode ? _textLightDark : _textLightLight;

  // Colores de estado
  static const Color successColor = Color(0xFF1FAD98);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color errorColor = Color(0xFFFF6B6B);
  static const Color infoColor = Color(0xFF60A5FA);

  // Colores de categorías
  static const Color categoryFood = Color.fromARGB(255, 255, 183, 77);
  static const Color insightsFoodColor = Color(0xFFFFD54F);
  static const Color categoryTransport = Color.fromARGB(255, 100, 129, 245);
  static const Color categoryEntertainment = Color.fromARGB(255, 244, 67, 150);
  static const Color categoryHealth = Color.fromARGB(255, 102, 187, 106);
  static const Color categoryEducation = Color.fromARGB(255, 171, 71, 188);
  static const Color categoryOther = Color.fromARGB(255, 189, 189, 189);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1FAD98),
      Color(0xFF168675),
    ],
  );

  static const LinearGradient incomeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1FAD98),
      Color(0xFF6EE7B7),
    ],
  );

  static const LinearGradient expenseGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFF6B6B),
      Color(0xFFE94E77),
    ],
  );

  static BoxShadow get softShadow => BoxShadow(
        color: isDarkMode
            ? const Color(0x66000000)
            : const Color(0x1A111827),
        blurRadius: isDarkMode ? 24 : 16,
        offset: const Offset(0, 8),
      );

  static BoxShadow get cardShadow => BoxShadow(
        color: isDarkMode
            ? const Color(0x4D000000)
            : const Color(0x14111827),
        blurRadius: isDarkMode ? 18 : 12,
        offset: const Offset(0, 6),
      );

  static BoxShadow glow(Color color) => BoxShadow(
        color: color.withValues(alpha: isDarkMode ? 0.28 : 0.18),
        blurRadius: 30,
        offset: const Offset(0, 12),
      );
}
