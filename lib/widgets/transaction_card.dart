import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:my_finances_app/models/transaction.dart';
import 'package:my_finances_app/resources/utils.dart';
import 'package:intl/intl.dart';

import '../theme/colors/app_colors.dart';

class TransactionCard extends StatefulWidget {
  final TransactionModel transaction;
  final Function() onPressedEdit;
  final Function() onPressedDelete;
  final bool isFromMonth;

  const TransactionCard({
    super.key,
    required this.transaction,
    required this.onPressedEdit,
    required this.onPressedDelete,
    this.isFromMonth = false,
  });

  @override
  State<TransactionCard> createState() => _TransactionCardState();
}

class _TransactionCardState extends State<TransactionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = widget.transaction.type == TransactionType.ingreso;
    final amount = widget.transaction.amount;
    final formattedDate =
        DateFormat('dd MMM, yyyy').format(widget.transaction.date);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: GestureDetector(
              onTapDown: (_) => _animationController.forward(),
              onTapUp: (_) => _animationController.reverse(),
              onTapCancel: () => _animationController.reverse(),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.surfaceColor,
                      AppColors.surfaceColor.withOpacity(0.8),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isIncome
                          ? AppColors.incomeColor.withOpacity(0.15)
                          : AppColors.expenseColor.withOpacity(0.15),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                      spreadRadius: 0,
                    ),
                  ],
                  border: Border.all(
                    color: isIncome
                        ? AppColors.incomeColor.withOpacity(0.2)
                        : AppColors.expenseColor.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
                      // Gradiente sutil de fondo
                      Positioned(
                        right: -30,
                        top: -30,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                (isIncome
                                        ? AppColors.incomeColor
                                        : AppColors.expenseColor)
                                    .withOpacity(0.1),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Contenido principal
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            // Icono principal con gradiente
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: isIncome
                                      ? [
                                          AppColors.incomeColor,
                                          AppColors.incomeColor
                                              .withOpacity(0.7),
                                        ]
                                      : [
                                          AppColors.expenseColor,
                                          AppColors.expenseColor
                                              .withOpacity(0.7),
                                        ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: (isIncome
                                            ? AppColors.incomeColor
                                            : AppColors.expenseColor)
                                        .withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                _getTransactionIcon(),
                                color: AppColors.white,
                                size: 28,
                              ),
                            ),

                            const SizedBox(width: 16),

                            // Información de la transacción
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Título
                                  Text(
                                    widget.transaction.title,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                      letterSpacing: -0.5,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),

                                  const SizedBox(height: 4),

                                  // Fecha y categoría
                                  Row(
                                    children: [
                                      const Icon(
                                        TablerIcons.calendar_time,
                                        size: 16,
                                        color: AppColors.textSecondary,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        formattedDate,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: AppColors.textSecondary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: widget
                                              .transaction.category.color
                                              .withOpacity(0.15),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: widget
                                                .transaction.category.color
                                                .withOpacity(0.3),
                                            width: 0.5,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              widget.transaction.category.icon,
                                              size: 12,
                                              color: widget
                                                  .transaction.category.color,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              widget.transaction.category
                                                  .displayName,
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: widget
                                                    .transaction.category.color,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 8),

                                  // Monto
                                  Row(
                                    children: [
                                      Text(
                                        isIncome ? '+' : '-',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: isIncome
                                              ? AppColors.incomeColor
                                              : AppColors.expenseColor,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        Utils().valueCurrency(amount),
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: isIncome
                                              ? AppColors.incomeColor
                                              : AppColors.expenseColor,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Descripción (si existe)
                                  if (widget.transaction.description != null &&
                                      widget.transaction.description!
                                          .isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.textLight
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        widget.transaction.description!,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.textSecondary,
                                          fontStyle: FontStyle.italic,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            // Botones de acción
                            if (!widget.isFromMonth) ...[
                              const SizedBox(width: 12),
                              Column(
                                children: [
                                  _buildActionButton(
                                    icon: TablerIcons.edit,
                                    color: AppColors.primaryColor,
                                    onPressed: widget.onPressedEdit,
                                  ),
                                  const SizedBox(height: 8),
                                  _buildActionButton(
                                    icon: TablerIcons.trash,
                                    color: AppColors.errorColor,
                                    onPressed: () =>
                                        _showConfirmationDialog(context),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.1),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onPressed,
          child: Icon(
            icon,
            size: 20,
            color: color,
          ),
        ),
      ),
    );
  }

  IconData _getTransactionIcon() {
    final isIncome = widget.transaction.type == TransactionType.ingreso;

    if (isIncome) {
      return TablerIcons.trending_up;
    } else {
      return TablerIcons.trending_down;
    }
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surfaceColor,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icono principal
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.errorColor.withOpacity(0.2),
                        AppColors.errorColor.withOpacity(0.1),
                      ],
                    ),
                  ),
                  child: const Icon(
                    TablerIcons.trash,
                    color: AppColors.errorColor,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),

                // Título
                const Text(
                  '¿Eliminar transacción?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // Mensaje
                Text(
                  'Se eliminará "${widget.transaction.title}" por ${Utils().valueCurrency(widget.transaction.amount)}.\n\nEsta acción no se puede deshacer.',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Botones
                Row(
                  children: [
                    // Botón Cancelar
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.textLight,
                            width: 1,
                          ),
                        ),
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.textSecondary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Cancelar',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Botón Eliminar
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            colors: [
                              AppColors.errorColor,
                              AppColors.errorColor.withOpacity(0.8),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.errorColor.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: AppColors.white,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(TablerIcons.trash, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Eliminar',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ).then((result) {
      if (result == true) {
        widget.onPressedDelete();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.successColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            content: const Row(
              children: [
                Icon(
                  TablerIcons.check,
                  color: AppColors.white,
                  size: 20,
                ),
                SizedBox(width: 12),
                Text(
                  'Transacción eliminada correctamente',
                  style: TextStyle(
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
    });
  }
}
