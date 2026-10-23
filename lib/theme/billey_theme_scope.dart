import 'package:flutter/material.dart';

import 'billey_theme_extension.dart';
import 'billey_palette.dart';
import 'colors/app_colors.dart';

/// Notifica a descendientes cuando cambia el modo claro/oscuro.
class BilleyThemeScope extends InheritedWidget {
  const BilleyThemeScope({
    super.key,
    required this.isDarkMode,
    this.palette,
    required super.child,
  });

  final bool isDarkMode;
  final BilleyPalette? palette;

  static bool isDarkOf(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<BilleyThemeScope>();
    assert(scope != null, 'BilleyThemeScope no encontrado sobre este context');
    return scope!.isDarkMode;
  }

  @override
  bool updateShouldNotify(BilleyThemeScope oldWidget) =>
      isDarkMode != oldWidget.isDarkMode || palette != oldWidget.palette;
}

/// Sincroniza [AppColors] con el [Theme] activo de Material.
class BilleyThemeBinder extends StatelessWidget {
  const BilleyThemeBinder({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final palette = BilleyTheme.maybeOf(context)?.palette;
    if (palette != null) {
      AppColors.applyPalette(palette);
    } else {
      AppColors.isDarkMode = isDark;
    }

    return BilleyThemeScope(
      isDarkMode: isDark,
      palette: palette,
      child: child,
    );
  }
}
