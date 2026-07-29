import 'package:flutter/material.dart';

import '../models/category.dart';
import '../theme/colors/app_colors.dart';

class CategorySuggestion {
  const CategorySuggestion({
    required this.icon,
    required this.color,
    this.section,
  });

  final IconData icon;
  final Color color;
  final String? section;
}

class _SuggestionRule {
  const _SuggestionRule({
    required this.keywords,
    required this.icon,
    required this.color,
    this.section,
  });

  final List<String> keywords;
  final IconData icon;
  final Color color;
  final String? section;

  bool matches(String normalizedName) {
    final words = _extractWords(normalizedName);

    for (final keyword in keywords) {
      if (keyword.contains(' ')) {
        if (normalizedName.contains(keyword)) return true;
        continue;
      }

      for (final word in words) {
        if (_wordMatchesKeyword(word, keyword)) return true;
      }
    }

    return false;
  }

  static List<String> _extractWords(String normalizedName) {
    return normalizedName
        .split(RegExp(r'[\s\-_/]+'))
        .where((word) => word.length >= 2)
        .toList();
  }

  static bool _wordMatchesKeyword(String word, String keyword) {
    if (word == keyword) return true;
    if (word.startsWith(keyword) && keyword.length >= 4) return true;
    if (keyword.startsWith(word) && word.length >= 4) return true;
    return false;
  }
}

class CategorySuggestionService {
  static const List<_SuggestionRule> _rules = [
    _SuggestionRule(
      keywords: [
        'deuda',
        'deudas',
        'deudor',
        'prestamo',
        'prestamos',
        'credito',
        'creditos',
        'financiamiento',
        'interes',
        'moroso',
        'loan',
        'debt',
        'hipoteca',
      ],
      icon: Icons.account_balance,
      color: AppColors.errorColor,
      section: 'General',
    ),
    _SuggestionRule(
      keywords: [
        'comida',
        'food',
        'restaurante',
        'restaurant',
        'cafe',
        'almuerzo',
        'cena',
        'desayuno',
        'mercado',
        'supermercado',
        'grocery',
        'lunch',
        'dinner',
      ],
      icon: Icons.restaurant,
      color: AppColors.categoryFood,
      section: 'Necesidades Básicas',
    ),
    _SuggestionRule(
      keywords: [
        'transporte',
        'transport',
        'taxi',
        'uber',
        'didi',
        'gasolina',
        'combustible',
        'autobus',
        'metro',
        'tren',
        'parking',
        'parqueadero',
        'peaje',
        'vehiculo',
        'vehículo',
      ],
      icon: Icons.directions_car,
      color: AppColors.categoryTransport,
      section: 'Necesidades Básicas',
    ),
    _SuggestionRule(
      keywords: [
        'donacion',
        'donar',
        'caridad',
        'charity',
        'ofrenda',
        'diezmo',
        'aporte',
        'contribucion',
        'solidaridad',
        'voluntariado',
        'ong',
        'fundacion',
      ],
      icon: Icons.volunteer_activism,
      color: Color(0xFF9C27B0),
      section: 'General',
    ),
    _SuggestionRule(
      keywords: [
        'iglesia',
        'church',
        'templo',
        'religion',
        'espiritual',
      ],
      icon: Icons.church,
      color: Color(0xFF795548),
      section: 'General',
    ),
    _SuggestionRule(
      keywords: [
        'salud',
        'health',
        'doctor',
        'medico',
        'farmacia',
        'hospital',
        'clinica',
        'dental',
        'terapia',
        'medicina',
      ],
      icon: Icons.medical_services,
      color: AppColors.categoryHealth,
      section: 'Bienestar',
    ),
    _SuggestionRule(
      keywords: [
        'educacion',
        'education',
        'school',
        'colegio',
        'universidad',
        'curso',
        'clase',
        'libro',
        'estudio',
        'matricula',
        'tuition',
      ],
      icon: Icons.school,
      color: AppColors.categoryEducation,
      section: 'Desarrollo Personal',
    ),
    _SuggestionRule(
      keywords: [
        'cine',
        'movie',
        'netflix',
        'spotify',
        'entretenimiento',
        'ocio',
        'juego',
        'gaming',
        'fiesta',
        'celebracion',
        'concierto',
        'discoteca',
      ],
      icon: Icons.movie,
      color: AppColors.categoryEntertainment,
      section: 'Entretenimiento',
    ),
    _SuggestionRule(
      keywords: [
        'casa',
        'hogar',
        'home',
        'renta',
        'alquiler',
        'arriendo',
        'mueble',
        'decoracion',
        'reparacion',
      ],
      icon: Icons.home,
      color: Color(0xFF2196F3),
      section: 'Hogar',
    ),
    _SuggestionRule(
      keywords: [
        'trabajo',
        'work',
        'oficina',
        'nomina',
        'sueldo',
        'freelance',
        'negocio',
        'empresa',
        'cliente',
      ],
      icon: Icons.work,
      color: Color(0xFF607D8B),
      section: 'Trabajo',
    ),
    _SuggestionRule(
      keywords: [
        'mascota',
        'pet',
        'perro',
        'gato',
        'veterinaria',
      ],
      icon: Icons.pets,
      color: Color(0xFF8BC34A),
      section: 'Hogar',
    ),
    _SuggestionRule(
      keywords: [
        'gym',
        'gimnasio',
        'fitness',
        'deporte',
        'sport',
        'entrenamiento',
        'yoga',
        'correr',
        'running',
      ],
      icon: Icons.fitness_center,
      color: AppColors.successColor,
      section: 'Bienestar',
    ),
    _SuggestionRule(
      keywords: [
        'viaje',
        'travel',
        'vacacion',
        'hotel',
        'turismo',
        'vuelo',
        'avion',
      ],
      icon: Icons.travel_explore,
      color: Color(0xFF00BCD4),
      section: 'Entretenimiento',
    ),
    _SuggestionRule(
      keywords: [
        'regalo',
        'gift',
        'cumpleanos',
        'aniversario',
      ],
      icon: Icons.card_giftcard,
      color: AppColors.warningColor,
      section: 'Entretenimiento',
    ),
    _SuggestionRule(
      keywords: [
        'ahorro',
        'saving',
        'emergencia',
        'inversion',
        'invest',
        'bolsa',
        'acciones',
      ],
      icon: Icons.savings,
      color: AppColors.primaryColor,
      section: 'Inversiones',
    ),
    _SuggestionRule(
      keywords: [
        'pago',
        'factura',
        'cuota',
        'tarjeta',
        'servicio',
        'recibo',
      ],
      icon: Icons.payment,
      color: AppColors.warningColor,
      section: 'General',
    ),
    _SuggestionRule(
      keywords: [
        'compra',
        'shopping',
        'tienda',
        'ropa',
        'zapatos',
        'amazon',
        'marketplace',
      ],
      icon: Icons.shopping_cart,
      color: Color(0xFFE91E63),
      section: 'General',
    ),
    _SuggestionRule(
      keywords: [
        'luz',
        'electricidad',
        'energia',
      ],
      icon: Icons.flash_on,
      color: Color(0xFFFFC107),
      section: 'Hogar',
    ),
    _SuggestionRule(
      keywords: [
        'agua',
        'water',
        'acueducto',
      ],
      icon: Icons.water_drop,
      color: Color(0xFF2196F3),
      section: 'Hogar',
    ),
    _SuggestionRule(
      keywords: [
        'internet',
        'wifi',
        'telefono',
        'celular',
        'movil',
        'datos moviles',
        'plan movil',
      ],
      icon: Icons.wifi,
      color: AppColors.infoColor,
      section: 'Necesidades Básicas',
    ),
    _SuggestionRule(
      keywords: [
        'bebe',
        'hijo',
        'hija',
        'nino',
        'nina',
        'infantil',
        'guarderia',
      ],
      icon: Icons.child_care,
      color: Color(0xFFFF9800),
      section: 'Hogar',
    ),
    _SuggestionRule(
      keywords: [
        'gasolinera',
        'estacion servicio',
        'combustible',
      ],
      icon: Icons.local_gas_station,
      color: AppColors.categoryTransport,
      section: 'Necesidades Básicas',
    ),
  ];

  static CategorySuggestion? suggest(String name) {
    final normalized = _normalize(name);
    if (normalized.length < 2) return null;

    for (final rule in _rules) {
      if (rule.matches(normalized)) {
        return CategorySuggestion(
          icon: _resolveIcon(rule.icon),
          color: rule.color,
          section: rule.section,
        );
      }
    }

    return _fallbackFromName(normalized);
  }

  static String _normalize(String input) {
    return input
        .toLowerCase()
        .trim()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('ñ', 'n');
  }

  static IconData _resolveIcon(IconData icon) {
    final available = CategoryModel.availableIcons;
    final match = available.where((item) => item.codePoint == icon.codePoint);
    if (match.isNotEmpty) return match.first;
    return Icons.category;
  }

  static CategorySuggestion _fallbackFromName(String normalizedName) {
    final icons = CategoryModel.availableIcons;
    final colors = CategoryModel.availableColors;
    final hash = normalizedName.codeUnits.fold<int>(
      0,
      (sum, unit) => sum + unit,
    );

    return CategorySuggestion(
      icon: icons[hash % icons.length],
      color: colors[hash % colors.length],
      section: CategoryModel.defaultSections.first,
    );
  }
}
