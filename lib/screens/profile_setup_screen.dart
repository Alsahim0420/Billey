import 'dart:convert';

import 'package:billey/l10n/app_localizations.dart';
import 'package:billey/l10n/l10n_extensions.dart';
import 'package:billey/l10n/localization_helpers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/speech/presentation/speech_voice_selector.dart';
import '../models/savings_goal_style.dart';
import '../providers/currency_provider.dart';
import '../providers/income_distribution_provider.dart';
import '../providers/profile_provider.dart';
import '../theme/colors/app_colors.dart';
import 'main_navigation_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  static const _goalsStorageKey = 'billey_savings_goals';
  static const _pageCount = 3;

  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  final _customEssentials = TextEditingController(text: '50');
  final _customWants = TextEditingController(text: '30');
  final _customSavings = TextEditingController(text: '20');

  bool _saving = false;
  int _currentPage = 0;
  _GoalsMode _goalsMode = _GoalsMode.empty;
  String _selectedTemplateId = IncomeDistributionProvider.templates.first.id;
  final List<_SetupGoal> _customGoals = [];

  List<String> _pageTitles(AppLocalizations l10n) => [
        l10n.setupPagePersonalData,
        l10n.setupPageGoals,
        l10n.setupPageDistribution,
      ];

  List<String> _pageSubtitles(AppLocalizations l10n) => [
        l10n.setupSubtitlePersonalData,
        l10n.setupSubtitleGoals,
        l10n.setupSubtitleDistribution,
      ];

  /// Metas sugeridas con montos realistas en pesos colombianos (COP).
  List<_SetupGoal> _suggestedGoals(AppLocalizations l10n) => [
        _SetupGoal(
          id: 'starter_emergency',
          title: l10n.goalEmergencyTitle,
          subtitle: l10n.goalEmergencySubtitle,
          currentAmount: 0,
          targetAmount: 3000000,
          monthsLeft: 6,
          style: SavingsGoalStyle.emergency,
        ),
        _SetupGoal(
          id: 'starter_trip',
          title: l10n.goalTripTitle,
          subtitle: l10n.goalTripSubtitle,
          currentAmount: 0,
          targetAmount: 1500000,
          monthsLeft: 8,
          style: SavingsGoalStyle.trip,
        ),
      ];

  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileProvider>();
    final googleUser = FirebaseAuth.instance.currentUser;
    final savedName = profile.displayName.trim();
    final savedEmail = profile.email.trim();

    _nameController = TextEditingController(
      text: savedName.isNotEmpty
          ? savedName
          : (googleUser?.displayName?.trim() ?? ''),
    );
    _emailController = TextEditingController(
      text: savedEmail.isNotEmpty
          ? savedEmail
          : (googleUser?.email?.trim() ?? ''),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _customEssentials.dispose();
    _customWants.dispose();
    _customSavings.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOut,
    );
  }

  bool _validateCurrentPage() {
    final l10n = context.l10n;
    switch (_currentPage) {
      case 0:
        return _formKey.currentState?.validate() ?? false;
      case 1:
        if (_goalsMode == _GoalsMode.custom && _customGoals.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.addGoalOrChooseOption),
              backgroundColor: AppColors.warningColor,
            ),
          );
          return false;
        }
        return true;
      case 2:
        return true;
      default:
        return true;
    }
  }

  void _onNext() {
    if (!_validateCurrentPage()) return;
    if (_currentPage < _pageCount - 1) {
      _goToPage(_currentPage + 1);
    } else {
      _submit();
    }
  }

  void _onBack() {
    if (_currentPage > 0) {
      _goToPage(_currentPage - 1);
    }
  }

  Future<void> _submit() async {
    if (_saving) return;
    final l10n = context.l10n;
    if (!_formKey.currentState!.validate()) {
      _goToPage(0);
      return;
    }

    if (_goalsMode == _GoalsMode.custom && _customGoals.isEmpty) {
      _goToPage(1);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.addGoalOrChooseOption),
          backgroundColor: AppColors.warningColor,
        ),
      );
      return;
    }

    setState(() => _saving = true);
    final profile = context.read<ProfileProvider>();
    final ok = await profile.updateProfile(
      displayName: _nameController.text,
      email: _emailController.text,
    );

    if (ok) {
      await _applyGoalsPreference();
      await _applyTemplatePreference();
    }

    setState(() => _saving = false);

    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.reviewNameEmail),
          backgroundColor: AppColors.errorColor,
        ),
      );
      return;
    }

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
    );
  }

  Future<void> _applyGoalsPreference() async {
    final l10n = context.l10n;
    final prefs = await SharedPreferences.getInstance();

    switch (_goalsMode) {
      case _GoalsMode.empty:
        await prefs.setString(
          _goalsStorageKey,
          jsonEncode(<Map<String, dynamic>>[]),
        );
      case _GoalsMode.starter:
        await prefs.setString(
          _goalsStorageKey,
          jsonEncode(_suggestedGoals(l10n).map((g) => g.toJson()).toList()),
        );
      case _GoalsMode.custom:
        await prefs.setString(
          _goalsStorageKey,
          jsonEncode(_customGoals.map((g) => g.toJson()).toList()),
        );
    }
  }

  Future<void> _applyTemplatePreference() async {
    final distribution = context.read<IncomeDistributionProvider>();
    if (_selectedTemplateId != IncomeDistributionProvider.customTemplateId) {
      await distribution.selectTemplate(_selectedTemplateId);
      return;
    }

    final essentials = double.tryParse(_customEssentials.text.trim()) ?? 0;
    final wants = double.tryParse(_customWants.text.trim()) ?? 0;
    final savings = double.tryParse(_customSavings.text.trim()) ?? 0;
    final total = essentials + wants + savings;
    if (total <= 0) {
      await distribution.selectTemplate(
        IncomeDistributionProvider.templates.first.id,
      );
      return;
    }

    await distribution.saveCustom(
      essentials: essentials * 100 / total,
      wants: wants * 100 / total,
      savings: savings * 100 / total,
      selectCustom: true,
    );
  }

  Future<void> _showAddGoalSheet({_SetupGoal? existing, int? index}) async {
    final saved = await showModalBottomSheet<_SetupGoal>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SetupGoalSheet(existing: existing),
    );

    if (!mounted || saved == null) return;

    setState(() {
      if (index != null) {
        _customGoals[index] = saved;
      } else {
        _customGoals.add(saved);
      }
      _goalsMode = _GoalsMode.custom;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isLastPage = _currentPage == _pageCount - 1;

    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (_currentPage > 0)
                        IconButton(
                          onPressed: _onBack,
                          icon: Icon(
                            TablerIcons.arrow_left,
                            color: AppColors.textPrimary,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        )
                      else
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            TablerIcons.user_check,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _pageTitles(l10n)[_currentPage],
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _pageSubtitles(l10n)[_currentPage],
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${_currentPage + 1}/$_pageCount',
                        style: TextStyle(
                          color: AppColors.textLight,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: List.generate(_pageCount, (index) {
                      final active = index <= _currentPage;
                      return Expanded(
                        child: Container(
                          height: 4,
                          margin: EdgeInsets.only(
                            right: index < _pageCount - 1 ? 6 : 0,
                          ),
                          decoration: BoxDecoration(
                            color: active
                                ? AppColors.primaryColor
                                : AppColors.surfacePressed,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Form(
                key: _formKey,
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (page) => setState(() => _currentPage = page),
                  children: [
                    _buildProfilePage(l10n),
                    _buildGoalsPage(l10n),
                    _buildTemplatePage(l10n),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _onNext,
                  child: _saving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : Text(
                          isLastPage ? l10n.finishButton : l10n.continueButton),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePage(AppLocalizations l10n) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      children: [
        _sectionLabel(l10n.fullName),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameController,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            hintText: l10n.fullNameHint,
          ),
          validator: (value) {
            if ((value?.trim() ?? '').length < 2) {
              return l10n.nameMinLength;
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        _sectionLabel(l10n.email),
        const SizedBox(height: 8),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: l10n.emailHint,
          ),
          validator: (value) {
            final v = value?.trim() ?? '';
            if (v.isEmpty) return l10n.emailRequired;
            if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v)) {
              return l10n.emailInvalid;
            }
            return null;
          },
        ),
        const SizedBox(height: 24),
        const SpeechVoiceSelector(),
      ],
    );
  }

  Widget _buildGoalsPage(AppLocalizations l10n) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      children: [
        _helpBox(l10n.setupGoalsHelp),
        const SizedBox(height: 14),
        SegmentedButton<_GoalsMode>(
          segments: [
            ButtonSegment(
              value: _GoalsMode.empty,
              label: Text(l10n.goalsEmpty),
              icon: const Icon(TablerIcons.trash, size: 18),
            ),
            ButtonSegment(
              value: _GoalsMode.starter,
              label: Text(l10n.goalsSuggested),
              icon: const Icon(TablerIcons.bulb, size: 18),
            ),
            ButtonSegment(
              value: _GoalsMode.custom,
              label: Text(l10n.goalsCustom),
              icon: const Icon(TablerIcons.edit, size: 18),
            ),
          ],
          selected: {_goalsMode},
          onSelectionChanged: (value) {
            setState(() => _goalsMode = value.first);
          },
        ),
        if (_goalsMode == _GoalsMode.empty) ...[
          const SizedBox(height: 16),
          _helpBox(l10n.setupGoalsEmptyHelp),
        ],
        if (_goalsMode == _GoalsMode.starter) ...[
          const SizedBox(height: 16),
          Text(
            l10n.setupSuggestedHeader,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          ..._suggestedGoals(l10n).map(
            (goal) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _GoalPreviewTile(goal: goal),
            ),
          ),
        ],
        if (_goalsMode == _GoalsMode.custom) ...[
          const SizedBox(height: 14),
          if (_customGoals.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Text(
                l10n.setupCustomEmpty,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            )
          else
            ...List.generate(_customGoals.length, (index) {
              final goal = _customGoals[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _CustomGoalTile(
                  goal: goal,
                  onEdit: () => _showAddGoalSheet(
                    existing: goal,
                    index: index,
                  ),
                  onDelete: () {
                    setState(() => _customGoals.removeAt(index));
                  },
                ),
              );
            }),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _showAddGoalSheet,
            icon: const Icon(
              TablerIcons.plus,
              color: AppColors.primaryColor,
            ),
            label: Text(
              l10n.addCustomGoal,
              style: const TextStyle(color: AppColors.primaryColor),
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              side: BorderSide(
                color: AppColors.primaryColor.withValues(alpha: 0.5),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTemplatePage(AppLocalizations l10n) {
    final selectedTemplate =
        _selectedTemplateId == IncomeDistributionProvider.customTemplateId
            ? null
            : IncomeDistributionProvider.templates
                .where((t) => t.id == _selectedTemplateId)
                .cast<IncomeDistributionTemplate?>()
                .firstOrNull;

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      children: [
        _helpBox(l10n.setupDistributionHelp),
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(
          initialValue: _selectedTemplateId,
          decoration: InputDecoration(
            hintText: l10n.chooseTemplate,
          ),
          items: [
            ...IncomeDistributionProvider.templates.map(
              (template) => DropdownMenuItem<String>(
                value: template.id,
                child: Text(template.localizedName(l10n)),
              ),
            ),
            DropdownMenuItem<String>(
              value: IncomeDistributionProvider.customTemplateId,
              child: Text(l10n.customTemplate),
            ),
          ],
          onChanged: (value) {
            if (value == null) return;
            setState(() => _selectedTemplateId = value);
          },
        ),
        if (selectedTemplate != null) ...[
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectedTemplate.localizedSubtitle(l10n),
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: selectedTemplate.buckets.map((bucket) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Color(bucket.colorValue).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${bucket.localizedLabel(l10n)} ${bucket.percent.round()}%',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
        if (_selectedTemplateId ==
            IncomeDistributionProvider.customTemplateId) ...[
          const SizedBox(height: 12),
          Text(
            l10n.setupPercentTip,
            style: TextStyle(
              color: AppColors.textLight,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _PercentInput(
                  controller: _customEssentials,
                  label: l10n.needs,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _PercentInput(
                  controller: _customWants,
                  label: l10n.wants,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _PercentInput(
                  controller: _customSavings,
                  label: l10n.savings,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _helpBox(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceInput,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
          height: 1.35,
        ),
      ),
    );
  }
}

enum _GoalsMode { empty, starter, custom }

class _SetupGoal {
  const _SetupGoal({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.currentAmount,
    required this.targetAmount,
    required this.monthsLeft,
    required this.style,
  });

  final String id;
  final String title;
  final String subtitle;
  final double currentAmount;
  final double targetAmount;
  final int monthsLeft;
  final SavingsGoalStyle style;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'currentAmount': currentAmount,
        'targetAmount': targetAmount,
        'monthsLeft': monthsLeft,
        'style': style.name,
      };
}

class _GoalPreviewTile extends StatelessWidget {
  const _GoalPreviewTile({required this.goal});

  final _SetupGoal goal;

  @override
  Widget build(BuildContext context) {
    final currency = context.watch<CurrencyProvider>();
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: goal.style.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(goal.style.icon, color: goal.style.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  goal.title,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                Text(
                  l10n.goalPreviewWithMonths(
                    goal.subtitle,
                    currency.format(goal.targetAmount),
                    goal.monthsLeft,
                  ),
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomGoalTile extends StatelessWidget {
  const _CustomGoalTile({
    required this.goal,
    required this.onEdit,
    required this.onDelete,
  });

  final _SetupGoal goal;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final currency = context.watch<CurrencyProvider>();
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: goal.style.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(goal.style.icon, color: goal.style.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  goal.title,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                Text(
                  l10n.goalPreviewMeta(
                    goal.subtitle,
                    currency.format(goal.targetAmount),
                  ),
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: Icon(TablerIcons.pencil, color: AppColors.textSecondary),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(TablerIcons.trash, color: AppColors.expenseColor),
          ),
        ],
      ),
    );
  }
}

class _SetupGoalSheet extends StatefulWidget {
  const _SetupGoalSheet({this.existing});

  final _SetupGoal? existing;

  @override
  State<_SetupGoalSheet> createState() => _SetupGoalSheetState();
}

class _SetupGoalSheetState extends State<_SetupGoalSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _subtitleController;
  late final TextEditingController _targetController;
  late final TextEditingController _currentController;
  late final TextEditingController _monthsController;
  late SavingsGoalStyle _style;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    final currency = context.read<CurrencyProvider>();
    _titleController = TextEditingController(text: existing?.title ?? '');
    _subtitleController = TextEditingController(text: existing?.subtitle ?? '');
    _targetController = TextEditingController(
      text: existing != null && existing.targetAmount > 0
          ? currency.formatValue(existing.targetAmount)
          : '',
    );
    _currentController = TextEditingController(
      text: existing != null && existing.currentAmount > 0
          ? currency.formatValue(existing.currentAmount)
          : '',
    );
    _monthsController = TextEditingController(
      text: existing?.monthsLeft.toString() ?? '',
    );
    _style = existing?.style ?? SavingsGoalStyle.emergency;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _targetController.dispose();
    _currentController.dispose();
    _monthsController.dispose();
    super.dispose();
  }

  void _save() {
    final l10n = context.l10n;
    final title = _titleController.text.trim();
    final currency = context.read<CurrencyProvider>();
    final target = currency.parseValue(_targetController.text);
    if (title.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.validGoalName)),
      );
      return;
    }
    if (target == null || target <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.goalTargetPositive)),
      );
      return;
    }

    final existing = widget.existing;
    Navigator.pop(
      context,
      _SetupGoal(
        id: existing?.id ?? 'custom_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        subtitle: _subtitleController.text.trim().isEmpty
            ? l10n.goalPersonalDefault
            : _subtitleController.text.trim(),
        currentAmount: currency.parseValue(_currentController.text) ?? 0,
        targetAmount: target,
        monthsLeft: int.tryParse(_monthsController.text.trim()) ?? 6,
        style: _style,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final existing = widget.existing;
    final l10n = context.l10n;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: BoxDecoration(
          color: AppColors.surfaceColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(26),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 48,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 18),
                    decoration: BoxDecoration(
                      color: AppColors.textLight.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                Text(
                  existing == null ? l10n.newGoal : l10n.editGoal,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 16),
                _SetupField(
                  controller: _titleController,
                  label: l10n.goalName,
                  hint: l10n.goalNameHint,
                ),
                const SizedBox(height: 12),
                _SetupField(
                  controller: _subtitleController,
                  label: l10n.goalCategory,
                  hint: l10n.goalCategoryHint,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _SetupField(
                        controller: _targetController,
                        label: l10n.goalTargetAmount,
                        hint: '3000000',
                        keyboardType: TextInputType.number,
                        inputFormatter: context
                                .watch<CurrencyProvider>()
                                .usesDecimals
                            ? null
                            : context.read<CurrencyProvider>().inputFormatter,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SetupField(
                        controller: _currentController,
                        label: l10n.goalSavedAmount,
                        hint: '0',
                        keyboardType: TextInputType.number,
                        inputFormatter: context
                                .watch<CurrencyProvider>()
                                .usesDecimals
                            ? null
                            : context.read<CurrencyProvider>().inputFormatter,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _SetupField(
                  controller: _monthsController,
                  label: l10n.monthsRemaining,
                  hint: '6',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 14),
                Text(
                  l10n.style,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: SavingsGoalStyle.values.map((s) {
                    final selected = _style == s;
                    return ChoiceChip(
                      selected: selected,
                      label: Text(s.localizedLabel(l10n)),
                      avatar: Icon(s.icon, size: 16, color: s.color),
                      selectedColor: s.color.withValues(alpha: 0.22),
                      backgroundColor: AppColors.surfaceInput,
                      labelStyle: TextStyle(
                        color: selected ? s.color : AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                      side: BorderSide(
                        color: selected ? s.color : AppColors.borderSubtle,
                      ),
                      onSelected: (_) => setState(() => _style = s),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _save,
                    child: Text(existing == null ? l10n.add : l10n.save),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SetupField extends StatelessWidget {
  const _SetupField({
    required this.controller,
    required this.label,
    required this.hint,
    this.keyboardType,
    this.inputFormatter,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType? keyboardType;
  final TextInputFormatter? inputFormatter;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatter == null ? null : [inputFormatter!],
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
      ),
    );
  }
}

class _PercentInput extends StatelessWidget {
  const _PercentInput({
    required this.controller,
    required this.label,
  });

  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        suffixText: '%',
      ),
    );
  }
}
