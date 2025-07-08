import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import '../theme/colors/app_colors.dart';
import 'dashboard_screen.dart';
import 'enhanced_transaction_list_screen.dart';
import 'add_transaction_screen.dart';
import 'monthly_summary_screen.dart';
import 'categories_management_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:csv/csv.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _fabAnimationController;
  late AnimationController _pulseAnimationController;
  late Animation<double> _fabAnimation;
  late Animation<double> _pulseAnimation;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const EnhancedTransactionListScreen(),
    MonthlySummaryScreen(
        initialMonth: DateTime.now()), // Will use current month
  ];

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _pulseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _fabAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOut,
    ));
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseAnimationController,
      curve: Curves.easeInOut,
    ));
    _fabAnimationController.forward();
    _pulseAnimationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _pulseAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _screens[_selectedIndex],
      ),
      floatingActionButton: AnimatedBuilder(
        animation: Listenable.merge([_fabAnimation, _pulseAnimation]),
        builder: (context, child) {
          return Transform.scale(
            scale: _fabAnimation.value * _pulseAnimation.value,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: AppColors.primaryColor.withOpacity(0.2),
                    blurRadius: 40,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const AddTransactionScreen(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          return SlideTransition(
                            position: animation.drive(
                              Tween(
                                begin: const Offset(0.0, 1.0),
                                end: Offset.zero,
                              ).chain(CurveTween(curve: Curves.easeInOut)),
                            ),
                            child: child,
                          );
                        },
                      ),
                    );
                  },
                  child: const Center(
                    child: Icon(
                      TablerIcons.plus,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: AppColors.surfaceColor,
        elevation: 16,
        child: Container(
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, TablerIcons.home, 'Inicio'),
              _buildNavItem(1, TablerIcons.list, 'Lista'),
              const SizedBox(width: 40), // Space for FAB
              _buildNavItem(2, TablerIcons.chart_pie, 'Gráficos'),
              _buildNavItem(3, TablerIcons.settings, 'Ajustes'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () {
        if (index == 3) {
          // Show settings bottom sheet
          _showSettingsBottomSheet();
        } else {
          setState(() {
            _selectedIndex = index;
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryColor.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color:
                  isSelected ? AppColors.primaryColor : AppColors.textSecondary,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? AppColors.primaryColor
                    : AppColors.textSecondary,
                height: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSettingsBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surfaceColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.textLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Configuración',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const Divider(color: AppColors.textLight),
              _buildSettingsItem(
                TablerIcons.category,
                'Gestionar Categorías',
                'Agregar, editar o eliminar categorías',
                () {
                  Navigator.pop(context);
                  _navigateToCategories();
                },
              ),
              _buildSettingsItem(
                TablerIcons.download,
                'Exportar Datos',
                'Descargar tus transacciones',
                () {
                  Navigator.pop(context);
                  _exportData();
                },
              ),
              _buildSettingsItem(
                TablerIcons.share,
                'Compartir App',
                'Recomienda la app a tus amigos',
                () {
                  Navigator.pop(context);
                  _shareApp();
                },
              ),
              _buildSettingsItem(
                TablerIcons.info_circle,
                'Acerca de',
                'Información de la aplicación',
                () {
                  Navigator.pop(context);
                  _showAboutDialog();
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsItem(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: AppColors.primaryColor,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: AppColors.textLight,
      ),
      onTap: onTap,
    );
  }

  void _navigateToCategories() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CategoriesManagementScreen(),
      ),
    );
  }

  void _exportData() async {
    final provider = Provider.of<TransactionProvider>(context, listen: false);
    final transactions = provider.transactions;

    // Generar datos CSV
    List<List<dynamic>> rows = [
      ['Fecha', 'Tipo', 'Categoría', 'Monto', 'Descripción'],
      ...transactions.map((t) => [
            t.date.toIso8601String(),
            t.type.toString().split('.').last,
            t.category.toString(),
            t.amount.toString(),
            t.description ?? ''
          ])
    ];
    String csvData = const ListToCsvConverter().convert(rows);

    // Compartir archivo CSV
    final tempDir = await getTemporaryDirectory();
    final file =
        await File('${tempDir.path}/transacciones.csv').writeAsString(csvData);
    await Share.shareXFiles([XFile(file.path)],
        text: 'Mis transacciones de My Finances');
  }

  void _shareApp() async {
    await Share.share(
      '¡Descarga My Finances y gestiona tus finanzas personales! https://tulink.com/app',
      subject: 'Te recomiendo My Finances',
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'My Finances',
          style: TextStyle(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Versión 1.0.0',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Una aplicación para gestionar tus finanzas personales de manera simple y efectiva.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Desarrollado con 💙 usando Flutter',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textLight,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
