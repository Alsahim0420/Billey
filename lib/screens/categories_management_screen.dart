import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';
import '../models/category.dart';
import '../theme/colors/app_colors.dart';
import 'add_edit_category_screen.dart';

class CategoriesManagementScreen extends StatelessWidget {
  const CategoriesManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Gestión de Categorías',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(TablerIcons.plus, color: AppColors.primaryColor),
            onPressed: () => _navigateToAddCategory(context),
          ),
        ],
      ),
      body: Consumer<CategoryProvider>(
        builder: (context, provider, child) {
          final categoriesBySection = provider.categoriesBySection;
          final inactiveCategories =
              provider.allCategories.where((c) => !c.isActive).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Secciones de categorías activas
                ...categoriesBySection.entries.map((entry) {
                  final section = entry.key;
                  final categories = entry.value;
                  final sectionColor = provider.getSectionColor(section);

                  return _buildSectionGroup(
                      context, section, categories, sectionColor);
                }).toList(),

                // Categorías desactivadas
                if (inactiveCategories.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  _buildSectionHeader(
                      'Categorías Desactivadas', inactiveCategories.length),
                  const SizedBox(height: 12),
                  ...inactiveCategories
                      .map((category) => _buildCategoryTile(
                          context, category, provider, false))
                      .toList(),
                ],

                const SizedBox(height: 32),
                _buildAddCategoryButton(context),
                const SizedBox(height: 100), // Space for FAB
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionGroup(BuildContext context, String section,
      List<CategoryModel> categories, Color sectionColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: sectionColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: sectionColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header de la sección
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: sectionColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  TablerIcons.folder,
                  color: sectionColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  section,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: sectionColor,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: sectionColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    categories.length.toString(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: sectionColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Categorías de la sección
          ...categories
              .map((category) => _buildCategoryTile(context, category,
                  Provider.of<CategoryProvider>(context), true))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildCategoryTile(
    BuildContext context,
    CategoryModel category,
    CategoryProvider provider,
    bool isActive,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [AppColors.cardShadow],
        border: !isActive
            ? Border.all(
                color: AppColors.textLight.withOpacity(0.3),
                width: 1,
              )
            : null,
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: category.color.withOpacity(isActive ? 0.1 : 0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            category.icon,
            color: isActive ? category.color : category.color.withOpacity(0.5),
            size: 24,
          ),
        ),
        title: Text(
          category.name,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              category.section,
              style: TextStyle(
                fontSize: 12,
                color: category.sectionColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                if (category.isDefault) ...[
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.infoColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Por defecto',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.infoColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                if (!isActive) ...[
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.warningColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Desactivada',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.warningColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(
            TablerIcons.dots_vertical,
            color: AppColors.textSecondary,
          ),
          onSelected: (value) =>
              _handleMenuAction(context, value, category, provider),
          itemBuilder: (context) => [
            if (isActive) ...[
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(TablerIcons.edit, size: 16),
                    SizedBox(width: 8),
                    Text('Editar'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(TablerIcons.trash,
                        size: 16, color: AppColors.errorColor),
                    SizedBox(width: 8),
                    Text(
                      'Eliminar',
                      style: TextStyle(color: AppColors.errorColor),
                    ),
                  ],
                ),
              ),
            ] else ...[
              const PopupMenuItem(
                value: 'restore',
                child: Row(
                  children: [
                    Icon(TablerIcons.refresh,
                        size: 16, color: AppColors.successColor),
                    SizedBox(width: 8),
                    Text(
                      'Activar',
                      style: TextStyle(color: AppColors.successColor),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAddCategoryButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryColor,
          width: 2,
        ),
      ),
      child: TextButton.icon(
        onPressed: () => _navigateToAddCategory(context),
        icon: const Icon(
          TablerIcons.plus,
          color: AppColors.primaryColor,
        ),
        label: const Text(
          'Agregar Nueva Categoría',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryColor,
          ),
        ),
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _navigateToAddCategory(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddEditCategoryScreen(),
      ),
    );
  }

  void _navigateToEditCategory(BuildContext context, CategoryModel category) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditCategoryScreen(category: category),
      ),
    );
  }

  void _handleMenuAction(
    BuildContext context,
    String action,
    CategoryModel category,
    CategoryProvider provider,
  ) {
    switch (action) {
      case 'edit':
        _navigateToEditCategory(context, category);
        break;
      case 'delete':
        _showDeleteConfirmation(context, category, provider);
        break;
      case 'restore':
        provider.restoreCategory(category.id);
        _showSnackBar(
          context,
          'Categoría "${category.name}" activada',
          AppColors.successColor,
        );
        break;
    }
  }

  void _showDeleteConfirmation(
    BuildContext context,
    CategoryModel category,
    CategoryProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Eliminar Categoría'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¿Estás seguro de que quieres eliminar la categoría "${category.name}"?',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            if (category.isDefault)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warningColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(
                      TablerIcons.alert_triangle,
                      color: AppColors.warningColor,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Es una categoría por defecto. Se puede eliminar pero podría afectar el funcionamiento.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.warningColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            const Text(
              'Esta acción no se puede deshacer.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              provider.deleteCategory(category.id);
              _showSnackBar(
                context,
                'Categoría "${category.name}" eliminada',
                AppColors.errorColor,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorColor,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        content: Text(
          message,
          style: const TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
