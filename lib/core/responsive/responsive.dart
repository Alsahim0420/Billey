import 'package:flutter/material.dart';

/// Escala tamaños según [MediaQuery] usando un diseño de referencia (Figma / mockup).
///
/// Inicializar en [MaterialApp.builder]:
/// ```dart
/// builder: (context, child) {
///   Responsive.init(context);
///   return child ?? const SizedBox.shrink();
/// },
/// ```
///
/// Uso: `26.h`, `30.w`, `14.sp`, `12.r`
class Responsive {
  Responsive._();

  /// Ancho del diseño de referencia (ajústalo al de tu Figma).
  static const double designWidth = 390;

  /// Alto del diseño de referencia (ajústalo al de tu Figma).
  static const double designHeight = 844;

  static Size _screenSize = const Size(designWidth, designHeight);
  static bool _initialized = false;

  static bool get isInitialized => _initialized;

  static Size get screenSize => _screenSize;

  static double get screenWidth => _screenSize.width;

  static double get screenHeight => _screenSize.height;

  /// Factor horizontal: pantalla actual / diseño.
  static double get scaleWidth => screenWidth / designWidth;

  /// Factor vertical: pantalla actual / diseño.
  static double get scaleHeight => screenHeight / designHeight;

  /// Menor de los dos factores (iconos, radios, fuentes proporcionales).
  static double get scaleMin =>
      scaleWidth < scaleHeight ? scaleWidth : scaleHeight;

  /// Actualiza medidas en cada frame (rotación, split view, etc.).
  static void init(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    _screenSize = mediaQuery.size;
    _initialized = true;
  }

  static double _scaledWidth(num value) {
    _assertInitialized();
    return value.toDouble() * scaleWidth;
  }

  static double _scaledHeight(num value) {
    _assertInitialized();
    return value.toDouble() * scaleHeight;
  }

  static double _scaledMin(num value) {
    _assertInitialized();
    return value.toDouble() * scaleMin;
  }

  static void _assertInitialized() {
    assert(
      _initialized,
      'Responsive no está inicializado. Añade Responsive.init(context) '
      'en MaterialApp.builder o envuelve la app con ResponsiveScope.',
    );
  }
}

/// Extensiones en [num] para tamaños responsivos.
extension ResponsiveNum on num {
  /// Ancho escalado (ej. `padding: EdgeInsets.symmetric(horizontal: 16.w)`).
  double get w => Responsive._scaledWidth(this);

  /// Alto escalado (ej. `SizedBox(height: 26.h)`).
  double get h => Responsive._scaledHeight(this);

  /// Tamaño de fuente escalado de forma proporcional.
  double get sp => Responsive._scaledMin(this);

  /// Radio / borde escalado (usa el factor menor para no deformar).
  double get r => Responsive._scaledMin(this);
}

/// Envuelve la app si prefieres no usar [MaterialApp.builder].
class ResponsiveScope extends StatelessWidget {
  const ResponsiveScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    return child;
  }
}
