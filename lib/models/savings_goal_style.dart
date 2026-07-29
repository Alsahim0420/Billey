import 'package:flutter/material.dart';

import '../theme/colors/app_colors.dart';

enum SavingsGoalStyle {
  emergency(
    'Emergencia',
    Icons.shield_outlined,
    AppColors.primaryColor,
  ),
  trip(
    'Viaje',
    Icons.flight_rounded,
    AppColors.infoColor,
  ),
  car(
    'Auto',
    Icons.directions_car_rounded,
    Color(0xFFC084FC),
  ),
  home(
    'Casa',
    Icons.home_outlined,
    Color(0xFFFF8A65),
  ),
  education(
    'Educación',
    Icons.school_outlined,
    Color(0xFFAB47BC),
  ),
  health(
    'Salud',
    Icons.favorite_outline,
    Color(0xFFEF5350),
  ),
  tech(
    'Tecnología',
    Icons.devices_outlined,
    Color(0xFF42A5F5),
  ),
  wedding(
    'Boda',
    Icons.favorite_border_rounded,
    Color(0xFFEC407A),
  ),
  business(
    'Negocio',
    Icons.work_outline_rounded,
    Color(0xFF26A69A),
  ),
  gift(
    'Regalo',
    Icons.card_giftcard_outlined,
    Color(0xFFFFB74D),
  );

  const SavingsGoalStyle(this.label, this.icon, this.color);

  final String label;
  final IconData icon;
  final Color color;

  static SavingsGoalStyle fromName(String name) {
    return SavingsGoalStyle.values.firstWhere(
      (style) => style.name == name,
      orElse: () => SavingsGoalStyle.emergency,
    );
  }
}
