import 'package:billey/l10n/l10n_extensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/category_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/transaction_provider.dart';
import '../services/local_profile_storage.dart';
import '../theme/billey_theme_scope.dart';
import '../theme/colors/app_colors.dart';
import 'main_navigation_screen.dart';
import 'profile_setup_screen.dart';
import 'slide_show_intro_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _progressController;
  late AnimationController _fadeController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _progressValue;
  late Animation<double> _fadeOpacity;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startLoadingSequence();
  }

  void _initializeAnimations() {
    // Logo animation
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _logoScale = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _logoOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeInOut,
    ));

    // Progress animation
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _progressValue = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));

    // Fade animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeOpacity = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
  }

  void _startLoadingSequence() async {
    // Start logo animation
    _logoController.forward();

    // Wait a bit, then start progress
    await Future.delayed(const Duration(milliseconds: 500));
    _progressController.forward();

    // Initialize provider data
    if (mounted) {
      await Provider.of<CategoryProvider>(context, listen: false).initialize();
    }
    if (mounted) {
      await Provider.of<TransactionProvider>(context, listen: false)
          .loadTransactions();
    }

    // Wait for progress to complete
    await _progressController.forward();

    // Small delay for better UX
    await Future.delayed(const Duration(milliseconds: 500));

    // Revisar si ya se mostró el onboarding y si el usuario tiene un perfil propio
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
    final hasCustomProfile = await LocalProfileStorage.hasCustomProfile();

    // Precalentar perfil local (para que ProfileSetup tenga datos actualizados)
    if (mounted) {
      await context.read<ProfileProvider>().load();
    }

    // Navegar según corresponda
    if (mounted) {
      _fadeController.forward().then((_) {
        if (mounted) {
          final target = !hasSeenOnboarding
              ? const IntroScreen()
              : hasCustomProfile
                  ? const MainNavigationScreen()
                  : const ProfileSetupScreen();

          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => target,
              transitionDuration: const Duration(milliseconds: 300),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _progressController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    BilleyThemeScope.isDarkOf(context);

    return Scaffold(
      body: AnimatedBuilder(
        animation: _fadeOpacity,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeOpacity.value,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.backgroundAlt,
                    AppColors.backgroundColor,
                    AppColors.backgroundColor,
                  ],
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),

                    // Logo animado
                    AnimatedBuilder(
                      animation: _logoController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _logoScale.value,
                          child: Opacity(
                            opacity: _logoOpacity.value,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppColors.primaryColor
                                      .withValues(alpha: 0.22),
                                ),
                                boxShadow: [
                                  AppColors.glow(AppColors.primaryColor),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.asset(
                                  'icono.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 30),

                    // Título
                    AnimatedBuilder(
                      animation: _logoOpacity,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _logoOpacity.value,
                          child: Column(
                            children: [
                              Text(
                                l10n.appTitle,
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.splashSubtitle,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.textSecondary,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const Spacer(flex: 2),

                    // Indicador de progreso
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 60),
                      child: Column(
                        children: [
                          Text(
                            l10n.loading,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 16),
                          AnimatedBuilder(
                            animation: _progressValue,
                            builder: (context, child) {
                              return Stack(
                                children: [
                                  Container(
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryColor
                                          .withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  FractionallySizedBox(
                                    widthFactor: _progressValue.value,
                                    child: Container(
                                      height: 4,
                                      decoration: BoxDecoration(
                                        gradient: AppColors.primaryGradient,
                                        borderRadius: BorderRadius.circular(2),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.primaryColor
                                                .withValues(alpha: 0.4),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const Spacer(flex: 1),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
