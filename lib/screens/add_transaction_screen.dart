// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/transaction_provider.dart';
import '../providers/category_provider.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../theme/colors/app_colors.dart';
import 'add_edit_category_screen.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat('#,##0.##');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Remove all non-digit characters except decimal point
    String numericText = newValue.text.replaceAll(RegExp(r'[^0-9.]'), '');

    // Handle multiple decimal points
    List<String> parts = numericText.split('.');
    if (parts.length > 2) {
      numericText = '${parts[0]}.${parts.sublist(1).join('')}';
    }

    // Limit to 2 decimal places
    if (parts.length == 2 && parts[1].length > 2) {
      numericText = '${parts[0]}.${parts[1].substring(0, 2)}';
    }

    if (numericText.isEmpty) {
      return newValue.copyWith(text: '');
    }

    double? value = double.tryParse(numericText);
    if (value == null) {
      return oldValue;
    }

    String formatted = _formatter.format(value);

    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class AddTransactionScreen extends StatefulWidget {
  final TransactionModel? transaction;

  const AddTransactionScreen({super.key, this.transaction});

  @override
  _AddTransactionScreenState createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  late String _id;
  late DateTime _date;
  late TransactionType _type;
  CategoryModel? _selectedCategory;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.transaction != null) {
      _id = widget.transaction!.id!;
      _titleController.text = widget.transaction!.title;
      // Format the amount with NumberFormat for editing
      final NumberFormat formatter = NumberFormat('#,##0.##');
      _amountController.text = formatter.format(widget.transaction!.amount);
      _descriptionController.text = widget.transaction!.description ?? '';
      _date = widget.transaction!.date;
      _type = widget.transaction!.type;
      // Para editar, cargaremos la categoría después de que se inicialice el provider
      _selectedCategory = null;
    } else {
      _id = DateTime.now().millisecondsSinceEpoch.toString();
      _date = DateTime.now();
      _type = TransactionType.gasto;
      _selectedCategory = null;
    }

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(
          widget.transaction == null
              ? 'Nueva Transacción'
              : 'Editar Transacción',
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
            onPressed: _saveTransaction,
            child: Text(
              widget.transaction == null ? 'GUARDAR' : 'ACTUALIZAR',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Información Básica'),
                const SizedBox(height: 16),
                _buildTitleField(),
                const SizedBox(height: 16),
                _buildAmountField(),
                const SizedBox(height: 24),
                _buildSectionTitle('Tipo y Categoría'),
                const SizedBox(height: 16),
                _buildTypeSelector(),
                const SizedBox(height: 16),
                _buildCategorySelector(),
                const SizedBox(height: 24),
                _buildSectionTitle('Detalles'),
                const SizedBox(height: 16),
                _buildDateSelector(),
                const SizedBox(height: 16),
                _buildDescriptionField(),
                const SizedBox(height: 32),
                _buildSaveButton(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildTitleField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [AppColors.cardShadow],
      ),
      child: TextFormField(
        controller: _titleController,
        decoration: const InputDecoration(
          labelText: 'Concepto de la transacción',
          prefixIcon:
              Icon(TablerIcons.text_caption, color: AppColors.primaryColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: AppColors.surfaceColor,
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Por favor ingresa un concepto';
          }
          if (value.trim().length < 3) {
            return 'El concepto debe tener al menos 3 caracteres';
          }
          return null;
        },
        textCapitalization: TextCapitalization.sentences,
        maxLength: 50,
      ),
    );
  }

  Widget _buildAmountField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [AppColors.cardShadow],
      ),
      child: TextFormField(
        controller: _amountController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          CurrencyInputFormatter(),
        ],
        decoration: const InputDecoration(
          labelText: 'Valor en pesos colombianos (COP)',
          helperText: 'Ejemplo: 25000.50',
          prefixIcon:
              Icon(TablerIcons.currency_dollar, color: AppColors.primaryColor),
          prefixText: '\$ ',
          suffixText: 'COP',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: AppColors.surfaceColor,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor ingresa un valor';
          }
          // Remove formatting (commas) before validation
          String cleanValue = value.replaceAll(',', '');
          final amount = double.tryParse(cleanValue);
          if (amount == null) {
            return 'Ingresa un valor válido';
          }
          if (amount <= 0) {
            return 'El valor debe ser mayor a 0';
          }
          if (amount > 999999999) {
            return 'El valor es demasiado grande';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [AppColors.cardShadow],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTypeOption(
              TransactionType.ingreso,
              'Ingreso',
              TablerIcons.arrow_up_circle,
              AppColors.incomeColor,
            ),
          ),
          const SizedBox(width: 1),
          Expanded(
            child: _buildTypeOption(
              TransactionType.gasto,
              'Gasto',
              TablerIcons.arrow_down_circle,
              AppColors.expenseColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeOption(
    TransactionType type,
    String label,
    IconData icon,
    Color color,
  ) {
    final isSelected = _type == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          _type = type;
          // Limpiar categoría seleccionada para que el usuario tenga que elegir una
          _selectedCategory = null;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : AppColors.textLight,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : AppColors.textSecondary,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected ? color : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Consumer<CategoryProvider>(
      builder: (context, provider, child) {
        final categoriesBySection = provider.categoriesBySection;

        // Si estamos editando y aún no hemos cargado la categoría, intentar cargarla
        if (widget.transaction != null && _selectedCategory == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _loadCategoryForExistingTransaction(provider);
          });
        }

        return Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [AppColors.cardShadow],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      _selectedCategory != null
                          ? TablerIcons.check
                          : TablerIcons.circle,
                      size: 18,
                      color: _selectedCategory != null
                          ? AppColors.successColor
                          : AppColors.textLight,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _selectedCategory != null
                          ? 'Categoría seleccionada: ${_selectedCategory!.name}'
                          : 'Selecciona una categoría',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _selectedCategory != null
                            ? AppColors.successColor
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  children: categoriesBySection.entries.map((entry) {
                    final section = entry.key;
                    final categories = entry.value;
                    final sectionColor = provider.getSectionColor(section);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8, bottom: 8),
                            child: Row(
                              children: [
                                Container(
                                  width: 3,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: sectionColor,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  section,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: sectionColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: categories.map((category) {
                              final isSelected =
                                  _selectedCategory?.id == category.id;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedCategory = category;
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? category.color.withOpacity(0.1)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isSelected
                                          ? category.color
                                          : AppColors.textLight,
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        category.icon,
                                        color: isSelected
                                            ? category.color
                                            : AppColors.textSecondary,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        category.name,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: isSelected
                                              ? category.color
                                              : AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              // Botón para agregar nueva categoría
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: OutlinedButton.icon(
                  onPressed: () => _navigateToAddCategory(),
                  icon: const Icon(
                    TablerIcons.plus,
                    size: 18,
                    color: AppColors.primaryColor,
                  ),
                  label: const Text(
                    'Agregar nueva categoría',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor.withOpacity(0.05),
                    side: BorderSide(
                      color: AppColors.primaryColor.withOpacity(0.3),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDateSelector() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [AppColors.cardShadow],
      ),
      child: ListTile(
        leading:
            const Icon(TablerIcons.calendar, color: AppColors.primaryColor),
        title: const Text('Fecha de la transacción'),
        subtitle: Text(
          DateFormat('dd/MM/yyyy').format(_date),
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: AppColors.primaryColor,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: _presentDatePicker,
      ),
    );
  }

  Widget _buildDescriptionField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [AppColors.cardShadow],
      ),
      child: TextFormField(
        controller: _descriptionController,
        maxLines: 3,
        maxLength: 200,
        decoration: const InputDecoration(
          labelText: 'Descripción (opcional)',
          prefixIcon: Icon(TablerIcons.note, color: AppColors.primaryColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: AppColors.surfaceColor,
        ),
        textCapitalization: TextCapitalization.sentences,
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _saveTransaction,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.transaction == null ? TablerIcons.plus : TablerIcons.edit,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              widget.transaction == null
                  ? 'Agregar Transacción'
                  : 'Actualizar Transacción',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveTransaction() async {
    if (_formKey.currentState!.validate()) {
      // Validar que se haya seleccionado una categoría
      if (_selectedCategory == null) {
        _showErrorMessage(
            '⚠️ Por favor selecciona una categoría antes de guardar');

        // Hacer scroll hacia la sección de categorías
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        return;
      }

      // Remove formatting (commas) from amount before parsing
      String cleanAmount = _amountController.text.replaceAll(',', '');

      final transaction = TransactionModel(
        id: _id,
        title: _titleController.text.trim(),
        amount: double.parse(cleanAmount),
        date: _date,
        type: _type,
        category: _selectedCategory!
            .transactionCategory, // Usar la categoría seleccionada
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      );

      if (widget.transaction == null) {
        await Provider.of<TransactionProvider>(context, listen: false)
            .addTransaction(transaction);
        if (mounted) {
          _showSuccessMessage('Transacción agregada correctamente');
          Navigator.of(context).pop();
        }
      } else {
        await Provider.of<TransactionProvider>(context, listen: false)
            .editTransaction(transaction);
        if (mounted) {
          _showSuccessMessage('Transacción actualizada correctamente');
          Navigator.of(context).pop();
        }
      }
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        content: Row(
          children: [
            const Icon(
              TablerIcons.check,
              color: AppColors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        content: Row(
          children: [
            const Icon(
              TablerIcons.alert_circle,
              color: AppColors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _presentDatePicker() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: AppColors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null && pickedDate != _date) {
      setState(() {
        _date = pickedDate;
      });
    }
  }

  void _navigateToAddCategory() async {
    // Navegar a la pantalla de agregar categoría
    final result = await Navigator.of(context).push<CategoryModel>(
      MaterialPageRoute(
        builder: (context) => const AddEditCategoryScreen(),
      ),
    );

    // Si se creó una nueva categoría, seleccionarla automáticamente
    if (result != null && mounted) {
      setState(() {
        _selectedCategory = result;
      });

      // Mostrar mensaje de confirmación
      _showSuccessMessage('Categoría "${result.name}" creada y seleccionada');
    }
  }

  void _loadCategoryForExistingTransaction(CategoryProvider provider) {
    if (widget.transaction != null && _selectedCategory == null) {
      // Por ahora, como las transacciones usan el enum TransactionCategory,
      // seleccionamos la primera categoría disponible como fallback
      // En el futuro se puede mejorar esto para mapear correctamente
      final categories = provider.categories;
      if (categories.isNotEmpty) {
        setState(() {
          _selectedCategory = categories.first;
        });
      }
    }
  }
}
