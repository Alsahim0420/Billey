import 'package:flutter/material.dart';

import 'billey_palette.dart';

/// Colores semánticos de Billey vía Theme — se actualizan solos al cambiar themeMode.
@immutable
class BilleyTheme extends ThemeExtension<BilleyTheme> {
  final BilleyPalette palette;

  const BilleyTheme(this.palette);

  bool get isDark => palette.isDark;

  Color get backgroundColor => palette.backgroundColor;
  Color get backgroundAlt => palette.backgroundAlt;
  Color get surfaceColor => palette.surfaceColor;
  Color get surfaceElevated => palette.surfaceElevated;
  Color get surfaceInput => palette.surfaceInput;
  Color get surfacePressed => palette.surfacePressed;
  Color get charcoal => palette.charcoal;
  Color get borderSubtle => palette.borderSubtle;
  Color get textPrimary => palette.textPrimary;
  Color get textSecondary => palette.textSecondary;
  Color get textLight => palette.textLight;

  static BilleyTheme of(BuildContext context) {
    final ext = Theme.of(context).extension<BilleyTheme>();
    assert(ext != null, 'BilleyTheme no está registrado en ThemeData');
    return ext!;
  }

  static BilleyTheme? maybeOf(BuildContext context) =>
      Theme.of(context).extension<BilleyTheme>();

  @override
  BilleyTheme copyWith({BilleyPalette? palette}) =>
      BilleyTheme(palette ?? this.palette);

  @override
  BilleyTheme lerp(ThemeExtension<BilleyTheme>? other, double t) {
    if (other is! BilleyTheme) return this;
    return t < 0.5 ? this : other;
  }
}

extension BilleyThemeContext on BuildContext {
  BilleyTheme get billey => BilleyTheme.of(this);
}
