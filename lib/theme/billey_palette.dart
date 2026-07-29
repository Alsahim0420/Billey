import 'package:flutter/material.dart';

/// Paleta inmutable por modo; evita mutar estado global al construir ThemeData.
class BilleyPalette {
  final bool isDark;
  final Color backgroundColor;
  final Color backgroundAlt;
  final Color surfaceColor;
  final Color surfaceElevated;
  final Color surfaceInput;
  final Color surfacePressed;
  final Color charcoal;
  final Color borderSubtle;
  final Color textPrimary;
  final Color textSecondary;
  final Color textLight;

  const BilleyPalette._({
    required this.isDark,
    required this.backgroundColor,
    required this.backgroundAlt,
    required this.surfaceColor,
    required this.surfaceElevated,
    required this.surfaceInput,
    required this.surfacePressed,
    required this.charcoal,
    required this.borderSubtle,
    required this.textPrimary,
    required this.textSecondary,
    required this.textLight,
  });

  factory BilleyPalette.dark() => const BilleyPalette._(
        isDark: true,
        backgroundColor: Color(0xFF0B0E11),
        backgroundAlt: Color(0xFF12201E),
        surfaceColor: Color(0xFF161B22),
        surfaceElevated: Color(0xFF1A2C29),
        surfaceInput: Color(0xFF1F302D),
        surfacePressed: Color(0xFF2A3F3B),
        charcoal: Color(0xFF12211E),
        borderSubtle: Color(0x14FFFFFF),
        textPrimary: Color(0xFFFFFFFF),
        textSecondary: Color(0xFF9CA3AF),
        textLight: Color(0xFF6B7280),
      );

  factory BilleyPalette.light() => const BilleyPalette._(
        isDark: false,
        backgroundColor: Color(0xFFFFFFFF),
        backgroundAlt: Color(0xFFF3F4F6),
        surfaceColor: Color(0xFFFFFFFF),
        surfaceElevated: Color(0xFFF9FAFB),
        surfaceInput: Color(0xFFF3F4F6),
        surfacePressed: Color(0xFFE5E7EB),
        charcoal: Color(0xFFFFFFFF),
        borderSubtle: Color(0x1A111827),
        textPrimary: Color(0xFF111827),
        textSecondary: Color(0xFF6B7280),
        textLight: Color(0xFF9CA3AF),
      );

  factory BilleyPalette.forBrightness(Brightness brightness) =>
      brightness == Brightness.dark
          ? BilleyPalette.dark()
          : BilleyPalette.light();
}
