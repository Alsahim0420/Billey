import 'dart:convert';

import 'package:billey/l10n/l10n_extensions.dart';
import 'package:billey/l10n/localization_helpers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/savings_goal_style.dart';
import '../providers/currency_provider.dart';
import '../theme/colors/app_colors.dart';
import '../theme/billey_theme_scope.dart';

class SavingsGoalsScreen extends StatefulWidget {
  const SavingsGoalsScreen({super.key});

  @override
  State<SavingsGoalsScreen> createState() => _SavingsGoalsScreenState();
}

class _SavingsGoalsScreenState extends State<SavingsGoalsScreen> {
  static const _storageKey = 'billey_savings_goals';
  final List<_SavingsGoal> _goals = [];

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  double get _totalSavings =>
      _goals.fold(0, (total, goal) => total + goal.currentAmount);

  @override
  Widget build(BuildContext context) {
    BilleyThemeScope.isDarkOf(context);
    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
          children: [
            _Header(onSettingsTap: _clearGoals),
            const SizedBox(height: 24),
            _TotalSavingsCard(amount: _totalSavings),
            const SizedBox(height: 28),
            for (final goal in _goals) ...[
              _GoalCard(
                goal: goal,
                onTap: () => _showGoalSheet(goal: goal),
              ),
              const SizedBox(height: 16),
            ],
            _AddGoalPlaceholder(onTap: () => _showGoalSheet()),
          ],
        ),
      ),
    );
  }

  Future<void> _loadGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);

    if (raw == null) return;

    final decoded = jsonDecode(raw) as List<dynamic>;
    setState(() {
      _goals
        ..clear()
        ..addAll(decoded.map((item) {
          return _SavingsGoal.fromJson(item as Map<String, dynamic>);
        }));
    });
  }

  Future<void> _saveGoals() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(_goals.map((goal) => goal.toJson()).toList()),
    );
  }

  Future<void> _clearGoals() async {
    setState(() {
      _goals.clear();
    });
    await _saveGoals();
  }

  Future<void> _showGoalSheet({_SavingsGoal? goal}) async {
    final titleController = TextEditingController(text: goal?.title ?? '');
    final subtitleController =
        TextEditingController(text: goal?.subtitle ?? '');
    final currentController = TextEditingController(
      text: goal?.currentAmount.toStringAsFixed(0) ?? '',
    );
    final targetController = TextEditingController(
      text: goal?.targetAmount.toStringAsFixed(0) ?? '',
    );
    final monthsController = TextEditingController(
      text: goal?.monthsLeft.toString() ?? '',
    );
    var selectedStyle = goal?.style ?? SavingsGoalStyle.emergency;

    final sheetFuture = showModalBottomSheet<_SavingsGoal>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                decoration: BoxDecoration(
                  color: AppColors.surfaceColor,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(26)),
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
                          goal == null
                              ? context.l10n.newGoalSheet
                              : context.l10n.editGoalSheet,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 18),
                        _GoalInput(
                          controller: titleController,
                          label: context.l10n.goalTitle,
                          hint: context.l10n.goalTitleHint,
                        ),
                        const SizedBox(height: 12),
                        _GoalInput(
                          controller: subtitleController,
                          label: context.l10n.goalCategoryLabel,
                          hint: context.l10n.goalCategorySheetHint,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _GoalInput(
                                controller: currentController,
                                label: context.l10n.saved,
                                hint: '800000',
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _GoalInput(
                                controller: targetController,
                                label: context.l10n.target,
                                hint: '3000000',
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _GoalInput(
                          controller: monthsController,
                          label: context.l10n.monthsLeft,
                          hint: '2',
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 10,
                          children: [
                            for (final style in SavingsGoalStyle.values)
                              ChoiceChip(
                                selected: selectedStyle == style,
                                label: Text(style.localizedLabel(context.l10n)),
                                avatar: Icon(style.icon, size: 18),
                                selectedColor:
                                    style.color.withValues(alpha: 0.22),
                                backgroundColor: AppColors.surfaceInput,
                                labelStyle: TextStyle(
                                  color: selectedStyle == style
                                      ? style.color
                                      : AppColors.textPrimary,
                                  fontWeight: FontWeight.w800,
                                ),
                                side: BorderSide(
                                  color: selectedStyle == style
                                      ? style.color
                                      : AppColors.borderSubtle,
                                ),
                                onSelected: (_) {
                                  setSheetState(() => selectedStyle = style);
                                },
                              ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: () {
                              final title = titleController.text.trim();
                              final current = double.tryParse(
                                currentController.text.trim(),
                              );
                              final target = double.tryParse(
                                targetController.text.trim(),
                              );
                              final months = int.tryParse(
                                monthsController.text.trim(),
                              );

                              if (title.isEmpty ||
                                  current == null ||
                                  target == null ||
                                  target <= 0 ||
                                  months == null) {
                                return;
                              }

                              Navigator.pop(
                                context,
                                _SavingsGoal(
                                  id: goal?.id ??
                                      DateTime.now()
                                          .millisecondsSinceEpoch
                                          .toString(),
                                  title: title,
                                  subtitle:
                                      subtitleController.text.trim().isEmpty
                                          ? context.l10n.goalDefaultSubtitle
                                          : subtitleController.text.trim(),
                                  currentAmount: current,
                                  targetAmount: target,
                                  monthsLeft: months,
                                  style: selectedStyle,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              foregroundColor: AppColors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(
                              goal == null
                                  ? context.l10n.createGoal
                                  : context.l10n.saveGoal,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                        if (goal != null) ...[
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _deleteGoal(goal);
                              },
                              child: Text(
                                context.l10n.deleteGoal,
                                style: const TextStyle(
                                    color: AppColors.expenseColor),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    sheetFuture.whenComplete(() {
      titleController.dispose();
      subtitleController.dispose();
      currentController.dispose();
      targetController.dispose();
      monthsController.dispose();
    });

    final saved = await sheetFuture;

    if (saved == null) return;

    setState(() {
      final index = _goals.indexWhere((item) => item.id == saved.id);
      if (index == -1) {
        _goals.add(saved);
      } else {
        _goals[index] = saved;
      }
    });
    await _saveGoals();
  }

  Future<void> _deleteGoal(_SavingsGoal goal) async {
    setState(() => _goals.removeWhere((item) => item.id == goal.id));
    await _saveGoals();
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onSettingsTap;

  const _Header({required this.onSettingsTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.financialFreedom,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                context.l10n.yourGoals,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.8,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.textPrimary.withValues(alpha: 0.08),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: IconButton(
            onPressed: onSettingsTap,
            icon: Icon(
              Icons.settings_outlined,
              color: AppColors.textPrimary,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }
}

class _TotalSavingsCard extends StatelessWidget {
  final double amount;

  const _TotalSavingsCard({required this.amount});

  @override
  Widget build(BuildContext context) {
    final currency = context.watch<CurrencyProvider>();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
      decoration: BoxDecoration(
        color: AppColors.surfaceInput.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderSubtle),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            AppColors.surfaceInput.withValues(alpha: 0.9),
            AppColors.primaryColor.withValues(alpha: 0.08),
          ],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.totalSavings,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  currency.format(amount),
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.8,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.trending_up_rounded,
                  color: AppColors.primaryColor,
                  size: 18,
                ),
                SizedBox(width: 5),
                Text(
                  '+12%',
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
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

class _GoalCard extends StatelessWidget {
  final _SavingsGoal goal;
  final VoidCallback onTap;

  const _GoalCard({
    required this.goal,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final progress = goal.progress.clamp(0.0, 1.0);
    final currency = context.watch<CurrencyProvider>();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        decoration: BoxDecoration(
          color: AppColors.surfaceInput.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: goal.style.color.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: goal.style == SavingsGoalStyle.emergency
                        ? [
                            BoxShadow(
                              color: goal.style.color.withValues(alpha: 0.22),
                              blurRadius: 30,
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    goal.style.icon,
                    color: goal.style.color,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.4,
                        ),
                      ),
                      Text(
                        goal.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${(progress * 100).round()}%',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: currency.format(goal.currentAmount),
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        TextSpan(
                          text: ' / ${currency.format(goal.targetAmount)}',
                          style: TextStyle(
                            color: AppColors.textLight,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: goal.style.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    context.l10n.monthsLeftBadge(goal.monthsLeft),
                    style: TextStyle(
                      color: goal.style == SavingsGoalStyle.emergency
                          ? AppColors.primaryColor
                          : AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 9,
                color: goal.style.color,
                backgroundColor:
                    AppColors.backgroundColor.withValues(alpha: 0.45),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddGoalPlaceholder extends StatelessWidget {
  final VoidCallback onTap;

  const _AddGoalPlaceholder({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        height: 96,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: AppColors.textLight.withValues(alpha: 0.45),
            style: BorderStyle.solid,
          ),
        ),
        child: Center(
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.textSecondary,
                width: 3,
              ),
            ),
            child: Icon(
              Icons.add_rounded,
              color: AppColors.textSecondary,
              size: 30,
            ),
          ),
        ),
      ),
    );
  }
}

class _GoalInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType? keyboardType;

  const _GoalInput({
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
        filled: true,
        fillColor: AppColors.surfaceInput,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _SavingsGoal {
  final String id;
  final String title;
  final String subtitle;
  final double currentAmount;
  final double targetAmount;
  final int monthsLeft;
  final SavingsGoalStyle style;

  const _SavingsGoal({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.currentAmount,
    required this.targetAmount,
    required this.monthsLeft,
    required this.style,
  });

  double get progress => targetAmount <= 0 ? 0 : currentAmount / targetAmount;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'currentAmount': currentAmount,
      'targetAmount': targetAmount,
      'monthsLeft': monthsLeft,
      'style': style.name,
    };
  }

  factory _SavingsGoal.fromJson(Map<String, dynamic> json) {
    return _SavingsGoal(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      currentAmount: (json['currentAmount'] as num).toDouble(),
      targetAmount: (json['targetAmount'] as num).toDouble(),
      monthsLeft: json['monthsLeft'] as int,
      style: SavingsGoalStyle.fromName(json['style'] as String),
    );
  }
}
