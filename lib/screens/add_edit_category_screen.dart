import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:provider/provider.dart';
import '../providers/category_provider.dart';
import '../models/category.dart';
import '../theme/colors/app_colors.dart';

class AddEditCategoryScreen extends StatefulWidget {
  final CategoryModel? category;

  const AddEditCategoryScreen({super.key, this.category});

  @override
  State<AddEditCategoryScreen> createState() => _AddEditCategoryScreenState();
}

class _AddEditCategoryScreenState extends State<AddEditCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _sectionController = TextEditingController();

  late IconData _selectedIcon;
  late Color _selectedColor;
  late String _selectedSection;
  late Color _selectedSectionColor;
  bool _isEditing = false;
  bool _isCustomSection = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.category != null;

    if (_isEditing) {
      _nameController.text = widget.category!.name;
      _selectedIcon = widget.category!.icon;
      _selectedColor = widget.category!.color;
      _selectedSection = widget.category!.section;
      _selectedSectionColor = widget.category!.sectionColor;
      _isCustomSection =
          !CategoryModel.defaultSections.contains(_selectedSection);
      if (_isCustomSection) {
        _sectionController.text = _selectedSection;
      }
    } else {
      _selectedIcon = CategoryModel.availableIcons.first;
      _selectedColor = CategoryModel.availableColors.first;
      _selectedSection = CategoryModel.defaultSections.first;
      _selectedSectionColor = CategoryModel.availableColors.first;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _sectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Editar Categoría' : 'Nueva Categoría',
          style: const TextStyle(
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
          TextButton(
            onPressed: _saveCategory,
            child: Text(
              _isEditing ? 'GUARDAR' : 'CREAR',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPreview(),
              const SizedBox(height: 24),
              _buildNameField(),
              const SizedBox(height: 24),
              _buildSectionSelector(),
              const SizedBox(height: 24),
              _buildIconSelector(),
              const SizedBox(height: 24),
              _buildColorSelector(),
              const SizedBox(height: 32),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreview() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [AppColors.cardShadow],
      ),
      child: Column(
        children: [
          const Text(
            'Vista Previa',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _selectedColor.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _selectedColor.withAlpha(51),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _selectedIcon,
                    color: _selectedColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _nameController.text.isEmpty
                            ? 'Nombre de la categoría'
                            : _nameController.text,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _nameController.text.isEmpty
                              ? AppColors.textLight
                              : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isCustomSection
                            ? (_sectionController.text.isEmpty
                                ? 'Sección personalizada'
                                : _sectionController.text)
                            : _selectedSection,
                        style: TextStyle(
                          fontSize: 12,
                          color: _selectedSectionColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nombre de la Categoría',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [AppColors.cardShadow],
          ),
          child: TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              hintText: 'Ej: Gimnasio, Mascotas, etc.',
              prefixIcon: Icon(TablerIcons.tag, color: AppColors.primaryColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: AppColors.surfaceColor,
            ),
            textCapitalization: TextCapitalization.words,
            maxLength: 20,
            onChanged: (value) => setState(() {}),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Por favor ingresa un nombre';
              }
              if (value.trim().length < 2) {
                return 'El nombre debe tener al menos 2 caracteres';
              }

              final provider =
                  Provider.of<CategoryProvider>(context, listen: false);
              if (provider.isNameTaken(value.trim(),
                  excludeId: widget.category?.id)) {
                return 'Ya existe una categoría con este nombre';
              }

              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSectionSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sección',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [AppColors.cardShadow],
          ),
          child: Column(
            children: [
              // Selector de sección predefinida o personalizada
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isCustomSection = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 8),
                        decoration: BoxDecoration(
                          color: !_isCustomSection
                              ? _selectedSectionColor.withAlpha(25)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: !_isCustomSection
                                ? _selectedSectionColor
                                : AppColors.textLight.withAlpha(76),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Radio<bool>(
                              value: false,
                              groupValue: _isCustomSection,
                              onChanged: (value) =>
                                  setState(() => _isCustomSection = value!),
                              activeColor: _selectedSectionColor,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                'Predefinida',
                                style: TextStyle(
                                  color: !_isCustomSection
                                      ? _selectedSectionColor
                                      : AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isCustomSection = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 8),
                        decoration: BoxDecoration(
                          color: _isCustomSection
                              ? _selectedSectionColor.withAlpha(25)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _isCustomSection
                                ? _selectedSectionColor
                                : AppColors.textLight.withAlpha(76),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Radio<bool>(
                              value: true,
                              groupValue: _isCustomSection,
                              onChanged: (value) =>
                                  setState(() => _isCustomSection = value!),
                              activeColor: _selectedSectionColor,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                'Personalizada',
                                style: TextStyle(
                                  color: _isCustomSection
                                      ? _selectedSectionColor
                                      : AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Selector de sección o campo personalizado
              if (_isCustomSection)
                TextFormField(
                  controller: _sectionController,
                  decoration: InputDecoration(
                    hintText: 'Nombre de la sección',
                    prefixIcon:
                        Icon(TablerIcons.folder, color: _selectedSectionColor),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: AppColors.surfaceColor,
                  ),
                  textCapitalization: TextCapitalization.words,
                  maxLength: 20,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El nombre de la sección es requerido';
                    }
                    return null;
                  },
                  onChanged: (value) =>
                      setState(() => _selectedSection = value),
                )
              else
                DropdownButtonFormField<String>(
                  value: _selectedSection,
                  decoration: InputDecoration(
                    hintText: 'Seleccionar sección',
                    prefixIcon:
                        Icon(TablerIcons.folder, color: _selectedSectionColor),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: AppColors.surfaceColor,
                  ),
                  items: CategoryModel.defaultSections.map((section) {
                    return DropdownMenuItem(
                      value: section,
                      child: Text(section),
                    );
                  }).toList(),
                  onChanged: (value) =>
                      setState(() => _selectedSection = value!),
                ),

              const SizedBox(height: 16),

              // Selector de color de sección
              const Text(
                'Color de la sección',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemCount: CategoryModel.availableColors.length,
                itemBuilder: (context, index) {
                  final color = CategoryModel.availableColors[index];
                  final isSelected =
                      _selectedSectionColor.toARGB32() == color.toARGB32();

                  return GestureDetector(
                    onTap: () => setState(() => _selectedSectionColor = color),
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.transparent,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: color.withAlpha(76),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            )
                          : null,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIconSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Selecciona un Ícono',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [AppColors.cardShadow],
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: CategoryModel.availableIcons.length,
            itemBuilder: (context, index) {
              final icon = CategoryModel.availableIcons[index];
              final isSelected = icon.codePoint == _selectedIcon.codePoint;

              return GestureDetector(
                onTap: () => setState(() => _selectedIcon = icon),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _selectedColor.withAlpha(51)
                        : AppColors.backgroundColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? _selectedColor : AppColors.textLight,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color:
                        isSelected ? _selectedColor : AppColors.textSecondary,
                    size: 24,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildColorSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Selecciona un Color',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [AppColors.cardShadow],
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: CategoryModel.availableColors.length,
            itemBuilder: (context, index) {
              final color = CategoryModel.availableColors[index];
              final isSelected = color.toARGB32() == _selectedColor.toARGB32();

              return GestureDetector(
                onTap: () => setState(() => _selectedColor = color),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.textPrimary
                          : Colors.transparent,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withAlpha(76),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 20,
                        )
                      : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _saveCategory,
        icon: Icon(_isEditing ? TablerIcons.device_floppy : TablerIcons.plus),
        label: Text(
          _isEditing ? 'Guardar Cambios' : 'Crear Categoría',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _saveCategory() {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<CategoryProvider>(context, listen: false);

      final finalSection =
          _isCustomSection ? _sectionController.text.trim() : _selectedSection;

      final category = CategoryModel(
        id: _isEditing ? widget.category!.id : provider.generateId(),
        name: _nameController.text.trim(),
        iconCodePoint: _selectedIcon.codePoint,
        colorValue: _selectedColor.toARGB32(),
        isDefault: _isEditing ? widget.category!.isDefault : false,
        isActive: true,
        section: finalSection,
        sectionColorValue: _selectedSectionColor.toARGB32(),
      );

      if (_isEditing) {
        provider.updateCategory(category);
        _showSnackBar('Categoría actualizada correctamente');
        Navigator.pop(context);
      } else {
        provider.addCategory(category);
        _showSnackBar('Categoría creada correctamente');
        // Regresar la nueva categoría para que pueda ser seleccionada automáticamente
        Navigator.pop(context, category);
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        content: Row(
          children: [
            const Icon(
              TablerIcons.check,
              color: AppColors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              message,
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
