import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/category.dart';
import '../theme/colors/app_colors.dart';

class CategoryProvider with ChangeNotifier {
  static const String _boxName = 'categories';
  Box<CategoryModel>? _box;
  List<CategoryModel> _categories = [];

  List<CategoryModel> get categories =>
      _categories.where((c) => c.isActive).toList();
  List<CategoryModel> get allCategories => _categories;

  Future<void> initialize() async {
    _box = await Hive.openBox<CategoryModel>(_boxName);
    await loadCategories();
  }

  Future<void> loadCategories() async {
    if (_box == null) return;

    _categories = _box!.values.toList();

    // Si no hay categorías, agregar las por defecto
    if (_categories.isEmpty) {
      await _addDefaultCategories();
    }

    notifyListeners();
  }

  Future<void> _addDefaultCategories() async {
    final defaultCategories = CategoryModel.getDefaultCategories();

    for (final category in defaultCategories) {
      await _box!.put(category.id, category);
      _categories.add(category);
    }

    notifyListeners();
  }

  Future<void> addCategory(CategoryModel category) async {
    if (_box == null) return;

    await _box!.put(category.id, category);
    _categories.add(category);
    notifyListeners();
  }

  Future<void> updateCategory(CategoryModel category) async {
    if (_box == null) return;

    await _box!.put(category.id, category);

    final index = _categories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      _categories[index] = category;
    }

    notifyListeners();
  }

  Future<void> deleteCategory(String categoryId) async {
    if (_box == null) return;

    await _box!.delete(categoryId);
    _categories.removeWhere((c) => c.id == categoryId);
    notifyListeners();
  }

  Future<void> restoreCategory(String categoryId) async {
    if (_box == null) return;

    final categoryIndex = _categories.indexWhere((c) => c.id == categoryId);
    if (categoryIndex != -1) {
      final category = _categories[categoryIndex];
      final restoredCategory = category.copyWith(isActive: true);
      await updateCategory(restoredCategory);
    }
  }

  CategoryModel? getCategoryById(String id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (e) {
      // Si no encuentra la categoría, devolver la categoría "Otros"
      return _categories.firstWhere((c) => c.id == 'other');
    }
  }

  String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  bool isNameTaken(String name, {String? excludeId}) {
    return _categories.any(
        (c) => c.name.toLowerCase() == name.toLowerCase() && c.id != excludeId);
  }

  Map<String, List<CategoryModel>> get categoriesBySection {
    final Map<String, List<CategoryModel>> sections = {};

    for (final category in categories) {
      if (!sections.containsKey(category.section)) {
        sections[category.section] = [];
      }
      sections[category.section]!.add(category);
    }

    return sections;
  }

  List<String> get availableSections {
    final customSections = _categories
        .map((c) => c.section)
        .where((s) => !CategoryModel.defaultSections.contains(s))
        .toSet()
        .toList();

    return [...CategoryModel.defaultSections, ...customSections];
  }

  Color getSectionColor(String section) {
    final categoriesInSection = _categories.where((c) => c.section == section);
    if (categoriesInSection.isNotEmpty) {
      return categoriesInSection.first.sectionColor;
    }
    return AppColors.primaryColor;
  }
}
