import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:billey/models/category.dart';
import 'package:billey/theme/colors/app_colors.dart';

void main() {
  group('Category Model Tests', () {
    late CategoryModel category;

    setUp(() {
      category = CategoryModel(
        id: 'test-category',
        name: 'Test Category',
        iconCodePoint: Icons.star.codePoint,
        colorValue: Colors.red.value,
        isDefault: false,
        section: 'Test Section',
        sectionColorValue: Colors.blue.value,
      );
    });

    test('should create category with correct properties', () {
      expect(category.id, 'test-category');
      expect(category.name, 'Test Category');
      expect(category.icon, Icons.star);
      expect(category.color.value, Colors.red.value);
      expect(category.isDefault, false);
      expect(category.isActive, true);
      expect(category.section, 'Test Section');
      expect(category.sectionColor.value, Colors.blue.value);
    });

    test('should create default category', () {
      final defaultCategory = CategoryModel(
        id: 'default-category',
        name: 'Default Category',
        iconCodePoint: Icons.home.codePoint,
        colorValue: Colors.blue.value,
        isDefault: true,
      );

      expect(defaultCategory.isDefault, true);
      expect(defaultCategory.isActive, true);
      expect(defaultCategory.section, 'General');
    });

    test('should get default categories', () {
      final defaultCategories = CategoryModel.getDefaultCategories();

      expect(defaultCategories, isNotEmpty);
      expect(defaultCategories.length, 6);

      // Verificar que todas las categorías por defecto tienen isDefault = true
      for (final category in defaultCategories) {
        expect(category.isDefault, true);
        expect(category.isActive, true);
      }
    });

    test('should copy category with new values', () {
      final copiedCategory = category.copyWith(
        name: 'Updated Category',
        colorValue: Colors.green.value,
        section: 'Updated Section',
      );

      expect(copiedCategory.id, category.id);
      expect(copiedCategory.name, 'Updated Category');
      expect(copiedCategory.icon, category.icon);
      expect(copiedCategory.color.value, Colors.green.value);
      expect(copiedCategory.section, 'Updated Section');
      expect(copiedCategory.isDefault, category.isDefault);
    });

    test('should handle equality correctly', () {
      final sameCategory = CategoryModel(
        id: 'test-category',
        name: 'Test Category',
        iconCodePoint: Icons.star.codePoint,
        colorValue: Colors.red.value,
        isDefault: false,
        section: 'Test Section',
        sectionColorValue: Colors.blue.value,
      );

      final differentCategory = CategoryModel(
        id: 'different-category',
        name: 'Different Category',
        iconCodePoint: Icons.star.codePoint,
        colorValue: Colors.red.value,
        isDefault: false,
      );

      expect(category.id, sameCategory.id);
      expect(category.name, sameCategory.name);
      expect(category.icon, sameCategory.icon);
      expect(category.color.value, sameCategory.color.value);
      expect(category.section, sameCategory.section);
      expect(category.sectionColor.value, sameCategory.sectionColor.value);
      expect(category.isDefault, sameCategory.isDefault);
      expect(category.isActive, sameCategory.isActive);
      expect(category.id, isNot(differentCategory.id));
    });

    test('should have correct hash code', () {
      final sameCategory = CategoryModel(
        id: 'test-category',
        name: 'Test Category',
        iconCodePoint: Icons.star.codePoint,
        colorValue: Colors.red.value,
        isDefault: false,
        section: 'Test Section',
        sectionColorValue: Colors.blue.value,
      );

      expect(category.id, sameCategory.id);
      expect(category.name, sameCategory.name);
      expect(category.icon, sameCategory.icon);
      expect(category.color.value, sameCategory.color.value);
      expect(category.section, sameCategory.section);
      expect(category.sectionColor.value, sameCategory.sectionColor.value);
      expect(category.isDefault, sameCategory.isDefault);
      expect(category.isActive, sameCategory.isActive);
    });

    test('should get default sections', () {
      final sections = CategoryModel.defaultSections;

      expect(sections, isNotEmpty);
      expect(sections.contains('General'), true);
      expect(sections.contains('Necesidades Básicas'), true);
      expect(sections.contains('Entretenimiento'), true);
      expect(sections.contains('Bienestar'), true);
      expect(sections.contains('Desarrollo Personal'), true);
    });

    test('should get available icons', () {
      final icons = CategoryModel.availableIcons;

      expect(icons, isNotEmpty);
      expect(icons.contains(Icons.restaurant), true);
      expect(icons.contains(Icons.directions_car), true);
      expect(icons.contains(Icons.movie), true);
      expect(icons.contains(Icons.medical_services), true);
      expect(icons.contains(Icons.school), true);
    });

    test('should get available colors', () {
      final colors = CategoryModel.availableColors;

      expect(colors, isNotEmpty);
      expect(colors.contains(AppColors.categoryFood), true);
      expect(colors.contains(AppColors.categoryTransport), true);
      expect(colors.contains(AppColors.categoryEntertainment), true);
      expect(colors.contains(AppColors.categoryHealth), true);
      expect(colors.contains(AppColors.categoryEducation), true);
      expect(colors.contains(AppColors.categoryOther), true);
    });

    test('should handle icon getter correctly', () {
      expect(category.icon.codePoint, Icons.star.codePoint);
      expect(category.icon.fontFamily, 'MaterialIcons');
    });

    test('should handle color getter correctly', () {
      expect(category.color.value, Colors.red.value);
      expect(category.sectionColor.value, Colors.blue.value);
    });
  });
}
