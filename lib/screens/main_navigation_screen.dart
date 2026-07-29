import 'package:billey/l10n/l10n_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:provider/provider.dart';

import '../services/local_profile_storage.dart';
import '../providers/theme_settings_provider.dart';
import '../theme/colors/app_colors.dart';
import 'add_transaction_screen.dart';
import 'dashboard_screen.dart';
import 'enhanced_transaction_list_screen.dart';
import 'profile_screen.dart';
import 'profile_setup_screen.dart';
import 'savings_goals_screen.dart';
import '../theme/billey_theme_scope.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  bool _checkedProfileSetup = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_checkedProfileSetup) return;
    _checkedProfileSetup = true;
    _validateProfileSetup();
  }

  Future<void> _validateProfileSetup() async {
    final hasCustomProfile = await LocalProfileStorage.hasCustomProfile();
    if (!hasCustomProfile && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const ProfileSetupScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    BilleyThemeScope.isDarkOf(context);
    final isDark = context.watch<ThemeSettingsProvider>().isDarkMode;

    final screens = [
      DashboardScreen(key: ValueKey('dash-$isDark')),
      SavingsGoalsScreen(key: ValueKey('goals-$isDark')),
      EnhancedTransactionListScreen(key: ValueKey('activity-$isDark')),
    ];

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: screens[_selectedIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundAlt,
          border: Border(
            top: BorderSide(color: AppColors.borderSubtle),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 72,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  _buildNavItem(0, TablerIcons.home, l10n.navHome),
                  _buildNavItem(1, TablerIcons.flag, l10n.navGoals),
                  _buildAddNavButton(),
                  _buildNavItem(2, TablerIcons.cash, l10n.navActivity),
                  _buildProfileNavItem(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: isSelected ? 32 : 0,
              height: 4,
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(999),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primaryColor.withValues(alpha: 0.55),
                          blurRadius: 10,
                        ),
                      ]
                    : null,
              ),
            ),
            Icon(
              icon,
              color:
                  isSelected ? AppColors.primaryColor : AppColors.textSecondary,
              size: 28,
            ),
            const SizedBox(height: 6),
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

  Widget _buildAddNavButton() {
    return Expanded(
      child: Center(
        child: Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: AppColors.primaryColor,
            shape: BoxShape.circle,
            boxShadow: [
              AppColors.glow(AppColors.primaryColor),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: _navigateToAddTransaction,
              child: const Icon(
                TablerIcons.plus,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileNavItem() {
    final l10n = context.l10n;
    return Expanded(
      child: GestureDetector(
        onTap: _openProfile,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 18),
            Icon(
              TablerIcons.user,
              color: AppColors.textSecondary,
              size: 28,
            ),
            const SizedBox(height: 6),
            Text(
              l10n.navProfile,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
                height: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToAddTransaction() {
    _openAddTransaction();
  }

  void _openAddTransaction() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const AddTransactionScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
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
  }

  void _openProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ProfileScreen(),
      ),
    );
  }
}
