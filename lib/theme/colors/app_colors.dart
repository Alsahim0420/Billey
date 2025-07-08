import 'package:flutter/material.dart';

class AppColors {
  // Colores principales (manteniendo el teal)
  static const Color primaryColor = Colors.teal;
  static const Color primaryColorLight = Color.fromARGB(255, 178, 223, 219);
  static const Color primaryColorDark = Color.fromARGB(255, 0, 96, 100);
  static const Color primaryColorTransparent = Color.fromARGB(48, 0, 150, 135);

  // Colores de transacciones (Dark Mode - más vibrantes)
  static const Color incomeColor = Color.fromARGB(255, 72, 199, 116);
  static const Color incomeColorLight = Color.fromARGB(255, 129, 199, 132);
  static const Color expenseColor = Color.fromARGB(255, 239, 83, 80);
  static const Color expenseColorLight = Color.fromARGB(255, 229, 115, 115);

  // Colores de superficie y fondo (Dark Mode)
  static const Color backgroundColor = Color.fromARGB(255, 18, 18, 18);
  static const Color surfaceColor = Color.fromARGB(255, 28, 28, 30);
  static const Color white = Color.fromARGB(255, 255, 255, 255);

  // Colores de texto (Dark Mode)
  static const Color textPrimary = Color.fromARGB(255, 255, 255, 255);
  static const Color textSecondary = Color.fromARGB(255, 174, 174, 178);
  static const Color textLight = Color.fromARGB(255, 142, 142, 147);

  // Colores de estado (Dark Mode - más vibrantes)
  static const Color successColor = Color.fromARGB(255, 72, 199, 116);
  static const Color warningColor = Color.fromARGB(255, 255, 213, 79);
  static const Color errorColor = Color.fromARGB(255, 239, 83, 80);
  static const Color infoColor = Color.fromARGB(255, 41, 182, 246);

  // Colores de categorías (Dark Mode - más vibrantes)
  static const Color categoryFood = Color.fromARGB(255, 255, 183, 77);
  static const Color categoryTransport = Color.fromARGB(255, 100, 129, 245);
  static const Color categoryEntertainment = Color.fromARGB(255, 244, 67, 150);
  static const Color categoryHealth = Color.fromARGB(255, 102, 187, 106);
  static const Color categoryEducation = Color.fromARGB(255, 171, 71, 188);
  static const Color categoryOther = Color.fromARGB(255, 189, 189, 189);

  // Gradientes
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color.fromARGB(255, 0, 150, 135),
      Color.fromARGB(255, 0, 121, 107),
    ],
  );

  static const LinearGradient incomeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color.fromARGB(255, 72, 199, 116),
      Color.fromARGB(255, 56, 142, 60),
    ],
  );

  static const LinearGradient expenseGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color.fromARGB(255, 239, 83, 80),
      Color.fromARGB(255, 198, 40, 40),
    ],
  );

  // Sombras (Dark Mode)
  static const BoxShadow softShadow = BoxShadow(
    color: Color.fromARGB(40, 0, 0, 0),
    blurRadius: 10,
    offset: Offset(0, 2),
  );

  static const BoxShadow cardShadow = BoxShadow(
    color: Color.fromARGB(30, 0, 0, 0),
    blurRadius: 8,
    offset: Offset(0, 4),
  );
}
