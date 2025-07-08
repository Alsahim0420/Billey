import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import '../theme/colors/app_colors.dart';
import 'transaction.dart';

part 'category.g.dart';

@HiveType(typeId: 3)
class CategoryModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final int iconCodePoint;

  @HiveField(3)
  final int colorValue;

  @HiveField(4)
  final bool isDefault;

  @HiveField(5)
  final bool isActive;

  @HiveField(6)
  final String section;

  @HiveField(7)
  final int sectionColorValue;

  CategoryModel({
    required this.id,
    required this.name,
    required this.iconCodePoint,
    required this.colorValue,
    this.isDefault = false,
    this.isActive = true,
    this.section = 'General',
    this.sectionColorValue = 0xFF009688,
  });

  IconData get icon => IconData(iconCodePoint, fontFamily: 'MaterialIcons');
  Color get color => Color(colorValue);
  Color get sectionColor => Color(sectionColorValue);

  // Mapear CategoryModel a TransactionCategory
  TransactionCategory get transactionCategory {
    switch (id) {
      case 'food':
        return TransactionCategory.food;
      case 'transport':
        return TransactionCategory.transport;
      case 'entertainment':
        return TransactionCategory.entertainment;
      case 'health':
        return TransactionCategory.health;
      case 'education':
        return TransactionCategory.education;
      default:
        return TransactionCategory.other;
    }
  }

  // Categorías por defecto
  static List<CategoryModel> getDefaultCategories() {
    return [
      CategoryModel(
        id: 'food',
        name: 'Comida',
        iconCodePoint: Icons.restaurant.codePoint,
        colorValue: AppColors.categoryFood.value,
        isDefault: true,
        section: 'Necesidades Básicas',
        sectionColorValue: AppColors.categoryFood.value,
      ),
      CategoryModel(
        id: 'transport',
        name: 'Transporte',
        iconCodePoint: Icons.directions_car.codePoint,
        colorValue: AppColors.categoryTransport.value,
        isDefault: true,
        section: 'Necesidades Básicas',
        sectionColorValue: AppColors.categoryFood.value,
      ),
      CategoryModel(
        id: 'entertainment',
        name: 'Entretenimiento',
        iconCodePoint: Icons.movie.codePoint,
        colorValue: AppColors.categoryEntertainment.value,
        isDefault: true,
        section: 'Entretenimiento',
        sectionColorValue: AppColors.categoryEntertainment.value,
      ),
      CategoryModel(
        id: 'health',
        name: 'Salud',
        iconCodePoint: Icons.medical_services.codePoint,
        colorValue: AppColors.categoryHealth.value,
        isDefault: true,
        section: 'Bienestar',
        sectionColorValue: AppColors.categoryHealth.value,
      ),
      CategoryModel(
        id: 'education',
        name: 'Educación',
        iconCodePoint: Icons.school.codePoint,
        colorValue: AppColors.categoryEducation.value,
        isDefault: true,
        section: 'Desarrollo Personal',
        sectionColorValue: AppColors.categoryEducation.value,
      ),
      CategoryModel(
        id: 'other',
        name: 'Otros',
        iconCodePoint: Icons.category.codePoint,
        colorValue: AppColors.categoryOther.value,
        isDefault: true,
        section: 'General',
        sectionColorValue: AppColors.categoryOther.value,
      ),
    ];
  }

  // Secciones predefinidas
  static List<String> get defaultSections => [
        'General',
        'Necesidades Básicas',
        'Entretenimiento',
        'Bienestar',
        'Desarrollo Personal',
        'Trabajo',
        'Hogar',
        'Inversiones',
      ];

  // Íconos disponibles para categorías
  static List<IconData> get availableIcons => [
        Icons.restaurant,
        Icons.directions_car,
        Icons.movie,
        Icons.medical_services,
        Icons.school,
        Icons.category,
        Icons.shopping_cart,
        Icons.home,
        Icons.work,
        Icons.sports,
        Icons.travel_explore,
        Icons.pets,
        Icons.child_care,
        Icons.fitness_center,
        Icons.local_gas_station,
        Icons.phone,
        Icons.wifi,
        Icons.flash_on,
        Icons.water_drop,
        Icons.celebration,
        Icons.card_giftcard,
        Icons.savings,
        Icons.payment,
      ];

  // Colores disponibles para categorías
  static List<Color> get availableColors => [
        AppColors.categoryFood,
        AppColors.categoryTransport,
        AppColors.categoryEntertainment,
        AppColors.categoryHealth,
        AppColors.categoryEducation,
        AppColors.categoryOther,
        AppColors.primaryColor,
        AppColors.successColor,
        AppColors.warningColor,
        AppColors.errorColor,
        AppColors.infoColor,
        const Color(0xFF9C27B0), // Purple
        const Color(0xFF2196F3), // Blue
        const Color(0xFF00BCD4), // Cyan
        const Color(0xFF8BC34A), // Light Green
        const Color(0xFFCDDC39), // Lime
        const Color(0xFFFFC107), // Amber
        const Color(0xFF795548), // Brown
        const Color(0xFF607D8B), // Blue Grey
      ];

  CategoryModel copyWith({
    String? id,
    String? name,
    int? iconCodePoint,
    int? colorValue,
    bool? isDefault,
    bool? isActive,
    String? section,
    int? sectionColorValue,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      colorValue: colorValue ?? this.colorValue,
      isDefault: isDefault ?? this.isDefault,
      isActive: isActive ?? this.isActive,
      section: section ?? this.section,
      sectionColorValue: sectionColorValue ?? this.sectionColorValue,
    );
  }
}
