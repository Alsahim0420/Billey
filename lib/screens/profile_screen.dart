import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../features/speech/application/speech_voice_provider.dart';
import '../features/speech/presentation/speech_voice_selector.dart';
import '../l10n/l10n_extensions.dart';
import '../l10n/localization_helpers.dart';
import '../providers/currency_provider.dart';
import '../providers/income_distribution_provider.dart';
import '../providers/locale_settings_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/theme_settings_provider.dart';
import '../providers/transaction_provider.dart';
import '../services/transaction_export_service.dart';
import '../theme/billey_theme_scope.dart';
import '../theme/colors/app_colors.dart';
import '../utils/share_origin.dart';
import 'couple_finance_screen.dart';
import 'categories_management_screen.dart';
import 'income_distribution_screen.dart';
import 'payment_reminders_screen.dart';
import 'spending_insights_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    BilleyThemeScope.isDarkOf(context);
    context.watch<ThemeSettingsProvider>();
    context.watch<LocaleSettingsProvider>();

    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      body: SafeArea(
        bottom: false,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 26),
          children: [
            _ProfileHeader(onBack: () => Navigator.maybePop(context)),
            const SizedBox(height: 26),
            Consumer<ProfileProvider>(
              builder: (context, profile, _) {
                return _ProfileIdentity(
                  displayName: profile.displayName,
                  email: profile.email,
                  imagePath: profile.hasLocalImage ? profile.imagePath : null,
                  onEditAvatar: () => _showAvatarOptions(profile),
                  onEditProfile: () => _showEditProfileSheet(profile),
                );
              },
            ),
            const SizedBox(height: 34),
            _SettingsSectionLabel(l10n.generalSection),
            const SizedBox(height: 12),
            Consumer<ProfileProvider>(
              builder: (context, profile, _) {
                return _ProfileSettingTile(
                  icon: TablerIcons.user,
                  title: l10n.personalInformation,
                  onTap: () => _showEditProfileSheet(profile),
                );
              },
            ),
            const SizedBox(height: 10),
            _ProfileSettingTile(
              icon: TablerIcons.shield,
              title: l10n.accountSecurity,
              onTap: () => _showComingSoon(l10n.accountSecurity),
            ),
            const SizedBox(height: 10),
            Consumer<CurrencyProvider>(
              builder: (context, currencyProvider, _) {
                return _ProfileSettingTile(
                  icon: TablerIcons.currency_dollar,
                  title: l10n.currencySetting,
                  trailingText: currencyProvider.selectedCurrency.symbol,
                  onTap: () => _showCurrencyPicker(currencyProvider),
                );
              },
            ),
            const SizedBox(height: 10),
            Consumer<SpeechVoiceProvider>(
              builder: (context, voiceProvider, _) {
                return _ProfileSettingTile(
                  icon: TablerIcons.microphone,
                  title: l10n.assistantVoice,
                  trailingText: voiceProvider.selectedVoice.name,
                  onTap: _showVoicePicker,
                );
              },
            ),
            const SizedBox(height: 10),
            _ProfileSettingTile(
              icon: TablerIcons.users,
              title: l10n.coupleFinanceTitle,
              onTap: _openCoupleFinance,
            ),
            const SizedBox(height: 10),
            _ProfileSettingTile(
              icon: TablerIcons.category,
              title: l10n.categoryManagement,
              onTap: _openCategoriesManagement,
            ),
            const SizedBox(height: 10),
            _ProfileSettingTile(
              icon: TablerIcons.bell,
              title: l10n.paymentReminders,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const PaymentRemindersScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            _ProfileSettingTile(
              icon: TablerIcons.chart_bar,
              title: l10n.budgetLimits,
              onTap: _openSpendingInsights,
            ),
            const SizedBox(height: 10),
            Consumer<IncomeDistributionProvider>(
              builder: (context, distribution, _) {
                return _ProfileSettingTile(
                  icon: TablerIcons.route_alt_left,
                  title: l10n.autoDistribution,
                  trailingText: distribution.activeTemplate.localizedName(l10n),
                  onTap: _openIncomeDistribution,
                );
              },
            ),
            const SizedBox(height: 28),
            _SettingsSectionLabel(l10n.dataPrivacySection),
            const SizedBox(height: 12),
            Builder(
              builder: (exportContext) {
                return _ProfileSettingTile(
                  icon: TablerIcons.download,
                  title: l10n.dataExport,
                  trailingText: l10n.csvPdf,
                  trailingTextIsBadge: true,
                  onTap: () => _exportData(exportContext),
                );
              },
            ),
            const SizedBox(height: 10),
            Consumer<ThemeSettingsProvider>(
              builder: (context, themeSettings, _) {
                return _ProfileSettingTile(
                  icon: TablerIcons.moon,
                  title: l10n.darkMode,
                  showChevron: false,
                  trailing: Switch.adaptive(
                    value: themeSettings.isDarkMode,
                    activeThumbColor: AppColors.white,
                    activeTrackColor: AppColors.primaryColor,
                    inactiveThumbColor: AppColors.textSecondary,
                    inactiveTrackColor: AppColors.surfacePressed,
                    onChanged: themeSettings.setDarkMode,
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            Consumer<LocaleSettingsProvider>(
              builder: (context, localeSettings, _) {
                return _ProfileSettingTile(
                  icon: TablerIcons.language,
                  title: l10n.language,
                  trailingText: localeSettings.languageLabel(l10n),
                  onTap: () => _showLanguagePicker(localeSettings),
                );
              },
            ),
            const SizedBox(height: 34),
            _LogOutButton(onTap: _showLogOutDialog),
            const SizedBox(height: 18),
            Text(
              l10n.versionInfo,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textLight,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openSpendingInsights() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SpendingInsightsScreen(),
      ),
    );
  }

  void _openCategoriesManagement() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CategoriesManagementScreen(),
      ),
    );
  }

  void _openCoupleFinance() {
    Navigator.of(context).push(CoupleFinanceScreen.route());
  }

  void _openIncomeDistribution() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const IncomeDistributionScreen(),
      ),
    );
  }

  void _showLanguagePicker(LocaleSettingsProvider localeSettings) {
    final l10n = context.l10n;
    final currentLocale = localeSettings.locale;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: AppColors.textLight,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                Text(
                  l10n.selectLanguage,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                _LanguageOptionTile(
                  label: l10n.languageSystem,
                  selected: currentLocale == null,
                  onTap: () {
                    localeSettings.setLocale(null);
                    Navigator.pop(sheetContext);
                  },
                ),
                _LanguageOptionTile(
                  label: l10n.languageEnglish,
                  selected: currentLocale?.languageCode == 'en',
                  onTap: () {
                    localeSettings.setLocale(const Locale('en'));
                    Navigator.pop(sheetContext);
                  },
                ),
                _LanguageOptionTile(
                  label: l10n.languageSpanish,
                  selected: currentLocale?.languageCode == 'es',
                  onTap: () {
                    localeSettings.setLocale(const Locale('es'));
                    Navigator.pop(sheetContext);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCurrencyPicker(CurrencyProvider currencyProvider) async {
    final l10n = context.l10n;
    final selected = currencyProvider.selectedCurrency;
    final selectedCurrency = await showModalBottomSheet<Currency>(
      context: context,
      backgroundColor: AppColors.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: AppColors.textLight,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                Text(
                  l10n.selectCurrency,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                ...CurrencyProvider.supportedCurrencies.map((currency) {
                  final isSelected = currency.code == selected.code;
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 6),
                    title: Text(
                      l10n.currencyItem(
                        currency.localizedName(l10n),
                        currency.code,
                      ),
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                    trailing: isSelected
                        ? const Icon(
                            TablerIcons.check,
                            color: AppColors.primaryColor,
                          )
                        : Text(
                            currency.symbol,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                    onTap: () => Navigator.pop(context, currency),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );

    if (selectedCurrency != null) {
      currencyProvider.setCurrency(selectedCurrency);
    }
  }

  void _showVoicePicker() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.backgroundAlt,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: SpeechVoiceSelector(),
        ),
      ),
    );
  }

  Future<void> _exportData(BuildContext originContext) async {
    final l10n = context.l10n;
    final options = await showModalBottomSheet<ExportOptions>(
      context: context,
      backgroundColor: AppColors.surfaceColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => const _ExportOptionsSheet(),
    );

    if (options == null || !mounted) return;

    final provider = Provider.of<TransactionProvider>(context, listen: false);
    final currency = Provider.of<CurrencyProvider>(context, listen: false);
    final profile = Provider.of<ProfileProvider>(context, listen: false);
    final filtered = TransactionExportService.filterTransactions(
      provider.transactions,
      options.scope,
    );

    if (filtered.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.exportNoData)),
      );
      return;
    }

    try {
      final result = await TransactionExportService.export(
        transactions: provider.transactions,
        options: options,
        l10n: l10n,
        currency: currency,
        userDisplayName: profile.displayName,
      );

      if (!mounted) return;

      final isPdf = options.format == ExportFormat.pdf;
      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile(
              result.file.path,
              mimeType: isPdf ? 'application/pdf' : 'text/csv',
              name: result.fileName,
            ),
          ],
          subject: l10n.exportShareText,
          sharePositionOrigin: shareOriginForContext(originContext),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.exportFailed)),
      );
    }
  }

  Future<void> _showAvatarOptions(ProfileProvider profile) async {
    final l10n = context.l10n;
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.textLight,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                Text(
                  l10n.profilePhoto,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 14),
                ListTile(
                  leading: const Icon(
                    TablerIcons.photo,
                    color: AppColors.primaryColor,
                  ),
                  title: Text(
                    l10n.chooseFromGallery,
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                  onTap: () => Navigator.pop(context, 'gallery'),
                ),
                if (profile.hasLocalImage)
                  ListTile(
                    leading: const Icon(
                      TablerIcons.trash,
                      color: AppColors.expenseColor,
                    ),
                    title: Text(
                      l10n.removePhoto,
                      style: const TextStyle(color: AppColors.expenseColor),
                    ),
                    onTap: () => Navigator.pop(context, 'remove'),
                  ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted || action == null) return;

    if (action == 'gallery') {
      final saved = await profile.pickAndSaveAvatar();
      if (!mounted) return;
      if (saved) {
        _showSnackBar(l10n.photoUpdated);
      }
      return;
    }

    if (action == 'remove') {
      await profile.removeAvatar();
      if (mounted) _showSnackBar(l10n.photoRemoved);
    }
  }

  Future<void> _showEditProfileSheet(ProfileProvider profile) async {
    final l10n = context.l10n;
    final nameController = TextEditingController(text: profile.displayName);
    final emailController = TextEditingController(text: profile.email);

    final sheetFuture = showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            decoration: BoxDecoration(
              color: AppColors.surfaceColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(22)),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.textLight,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  Text(
                    l10n.editProfile,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.dataStoredLocally,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _ProfileTextField(
                    controller: nameController,
                    label: l10n.fullName,
                    hint: l10n.yourName,
                  ),
                  const SizedBox(height: 12),
                  _ProfileTextField(
                    controller: emailController,
                    label: l10n.email,
                    hint: l10n.emailHintShort,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: AppColors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        l10n.save,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    final saved = await sheetFuture;

    final name = nameController.text;
    final email = emailController.text;

    sheetFuture.whenComplete(() {
      nameController.dispose();
      emailController.dispose();
    });

    if (saved != true || !mounted) return;

    final ok = await profile.updateProfile(
      displayName: name,
      email: email,
    );

    if (!mounted) return;

    if (ok) {
      _showSnackBar(l10n.profileUpdated);
    } else {
      _showSnackBar(l10n.checkNameEmail);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.surfacePressed,
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.featureComingSoon(feature)),
        backgroundColor: AppColors.surfacePressed,
      ),
    );
  }

  void _showLogOutDialog() {
    final l10n = context.l10n;
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceColor,
          title: Text(
            l10n.logOut,
            style: TextStyle(color: AppColors.textPrimary),
          ),
          content: Text(
            l10n.logOutMessage,
            style: TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showComingSoon(l10n.logOut);
              },
              child: Text(
                l10n.logOut,
                style: const TextStyle(color: AppColors.expenseColor),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _LanguageOptionTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageOptionTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 6),
      title: Text(
        label,
        style: TextStyle(color: AppColors.textPrimary),
      ),
      trailing: selected
          ? const Icon(
              TablerIcons.check,
              color: AppColors.primaryColor,
            )
          : null,
      onTap: onTap,
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final VoidCallback onBack;

  const _ProfileHeader({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onBack,
          icon: Icon(
            TablerIcons.arrow_left,
            color: AppColors.textPrimary,
            size: 26,
          ),
        ),
        Expanded(
          child: Text(
            context.l10n.settings,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 48),
      ],
    );
  }
}

class _ProfileIdentity extends StatelessWidget {
  final String displayName;
  final String email;
  final String? imagePath;
  final VoidCallback onEditAvatar;
  final VoidCallback onEditProfile;

  const _ProfileIdentity({
    required this.displayName,
    required this.email,
    required this.imagePath,
    required this.onEditAvatar,
    required this.onEditProfile,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final shownName =
        displayName.trim().isEmpty ? l10n.completeProfile : displayName;
    final shownEmail = email.trim().isEmpty ? l10n.addYourEmail : email;

    return Column(
      children: [
        GestureDetector(
          onTap: onEditAvatar,
          child: SizedBox(
            width: 112,
            height: 112,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 98,
                  height: 98,
                  margin: const EdgeInsets.only(left: 7),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primaryColor.withValues(alpha: 0.45),
                      width: 3,
                    ),
                  ),
                  child: ClipOval(
                    child: imagePath != null
                        ? Image.file(
                            File(imagePath!),
                            fit: BoxFit.cover,
                            width: 98,
                            height: 98,
                          )
                        : const Icon(
                            TablerIcons.user,
                            color: AppColors.primaryColor,
                            size: 48,
                          ),
                  ),
                ),
                Positioned(
                  right: 8,
                  bottom: 10,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.backgroundAlt,
                        width: 4,
                      ),
                    ),
                    child: const Icon(
                      TablerIcons.pencil,
                      color: AppColors.white,
                      size: 17,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: onEditProfile,
          child: Column(
            children: [
              Text(
                shownName,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.25,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                shownEmail,
                style: TextStyle(
                  color: email.trim().isEmpty
                      ? AppColors.textSecondary
                      : AppColors.primaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType? keyboardType;

  const _ProfileTextField({
    required this.controller,
    required this.label,
    required this.hint,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(color: AppColors.textSecondary),
        hintStyle: TextStyle(color: AppColors.textLight),
        filled: true,
        fillColor: AppColors.surfaceInput,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _SettingsSectionLabel extends StatelessWidget {
  final String text;

  const _SettingsSectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: AppColors.textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.1,
      ),
    );
  }
}

class _ProfileSettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? trailingText;
  final bool trailingTextIsBadge;
  final Widget? trailing;
  final bool showChevron;
  final VoidCallback? onTap;

  const _ProfileSettingTile({
    required this.icon,
    required this.title,
    this.trailingText,
    this.trailingTextIsBadge = false,
    this.trailing,
    this.showChevron = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceInput,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          constraints: const BoxConstraints(minHeight: 60),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primaryColor,
                  size: 21,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 10),
                trailing!,
              ] else ...[
                if (trailingText != null)
                  Container(
                    constraints: const BoxConstraints(maxWidth: 120),
                    margin: const EdgeInsets.only(right: 10),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: trailingTextIsBadge
                          ? AppColors.white.withValues(alpha: 0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      trailingText!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                if (showChevron)
                  Icon(
                    TablerIcons.chevron_right,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ExportOptionsSheet extends StatefulWidget {
  const _ExportOptionsSheet();

  @override
  State<_ExportOptionsSheet> createState() => _ExportOptionsSheetState();
}

class _ExportOptionsSheetState extends State<_ExportOptionsSheet> {
  ExportFormat _format = ExportFormat.csv;
  ExportScope _scope = ExportScope.all;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          18,
          12,
          18,
          20 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: AppColors.textLight,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            Text(
              l10n.exportDataTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 22),
            _ExportSectionLabel(l10n.exportFormatSection),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _ExportChoiceTile(
                    label: l10n.exportFormatCsv,
                    icon: TablerIcons.file_type_csv,
                    selected: _format == ExportFormat.csv,
                    onTap: () => setState(() => _format = ExportFormat.csv),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ExportChoiceTile(
                    label: l10n.exportFormatPdf,
                    icon: TablerIcons.file_type_pdf,
                    selected: _format == ExportFormat.pdf,
                    onTap: () => setState(() => _format = ExportFormat.pdf),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            _ExportSectionLabel(l10n.exportContentSection),
            const SizedBox(height: 10),
            _ExportChoiceTile(
              label: l10n.exportContentAll,
              icon: TablerIcons.list_details,
              selected: _scope == ExportScope.all,
              onTap: () => setState(() => _scope = ExportScope.all),
            ),
            const SizedBox(height: 8),
            _ExportChoiceTile(
              label: l10n.exportContentExpenses,
              icon: TablerIcons.arrow_down_right,
              selected: _scope == ExportScope.expensesOnly,
              onTap: () => setState(() => _scope = ExportScope.expensesOnly),
            ),
            const SizedBox(height: 8),
            _ExportChoiceTile(
              label: l10n.exportContentIncome,
              icon: TablerIcons.arrow_up_right,
              selected: _scope == ExportScope.incomeOnly,
              onTap: () => setState(() => _scope = ExportScope.incomeOnly),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 50,
              child: FilledButton(
                onPressed: () => Navigator.pop(
                  context,
                  ExportOptions(format: _format, scope: _scope),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  l10n.exportButton,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExportSectionLabel extends StatelessWidget {
  const _ExportSectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        color: AppColors.textSecondary,
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _ExportChoiceTile extends StatelessWidget {
  const _ExportChoiceTile({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppColors.primaryColor.withValues(alpha: 0.12)
          : AppColors.backgroundAlt,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  selected ? AppColors.primaryColor : AppColors.surfacePressed,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color:
                    selected ? AppColors.primaryColor : AppColors.textSecondary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ),
              if (selected)
                const Icon(
                  TablerIcons.check,
                  size: 18,
                  color: AppColors.primaryColor,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogOutButton extends StatelessWidget {
  final VoidCallback onTap;

  const _LogOutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.expenseColor,
          side:
              BorderSide(color: AppColors.expenseColor.withValues(alpha: 0.35)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(
          context.l10n.logOut,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
