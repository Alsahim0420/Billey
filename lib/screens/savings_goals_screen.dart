import 'package:billey/l10n/app_localizations.dart';
import 'package:billey/l10n/l10n_extensions.dart';
import 'package:billey/l10n/localization_helpers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/savings_goal.dart';
import '../models/savings_goal_style.dart';
import '../models/transaction.dart';
import '../providers/couple_link_provider.dart';
import '../providers/currency_provider.dart';
import '../providers/goals_provider.dart';
import '../providers/income_distribution_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/transaction_provider.dart';
import '../theme/colors/app_colors.dart';
import '../theme/billey_theme_scope.dart';
import '../widgets/owner_avatar.dart';
import '../widgets/share_with_partner_toggle.dart';

class SavingsGoalsScreen extends StatefulWidget {
  const SavingsGoalsScreen({super.key});

  @override
  State<SavingsGoalsScreen> createState() => _SavingsGoalsScreenState();
}

class _SavingsGoalsScreenState extends State<SavingsGoalsScreen> {
  String? _justCreatedGoalId;

  @override
  Widget build(BuildContext context) {
    BilleyThemeScope.isDarkOf(context);
    final goalsProvider = context.watch<GoalsProvider>();
    final goals = goalsProvider.goals;

    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
          children: [
            _Header(onAiTap: _showAiGoalSuggestions),
            const SizedBox(height: 24),
            _TotalSavingsCard(amount: goalsProvider.totalSavings),
            const SizedBox(height: 28),
            for (final goal in goals) ...[
              if (goal.id == _justCreatedGoalId)
                _GoalPopIn(
                  key: ValueKey('create-${goal.id}'),
                  glowColor: goal.style.color,
                  onDone: () =>
                      setState(() => _justCreatedGoalId = null),
                  child: _GoalCard(
                    goal: goal,
                    onTap: () => _showGoalSheet(goal: goal),
                  ),
                )
              else
                _GoalCard(
                  key: ValueKey(goal.id),
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

  double _estimateMonthlyIncome(TransactionProvider provider) {
    final incomeByMonth = <String, double>{};
    for (final transaction in provider.allTransactions) {
      if (transaction.type != TransactionType.ingreso) continue;
      final key = '${transaction.date.year}-${transaction.date.month}';
      incomeByMonth[key] = (incomeByMonth[key] ?? 0) + transaction.amount;
    }
    if (incomeByMonth.isEmpty) return 0;
    final total = incomeByMonth.values.fold(0.0, (a, b) => a + b);
    return total / incomeByMonth.length;
  }

  /// Turns the buckets of the user's active income-distribution plan into
  /// concrete goal suggestions — e.g. a "savings" bucket becomes an
  /// emergency-fund goal sized off their actual average monthly income
  /// (falling back to a sensible default when there isn't enough
  /// transaction history yet to estimate it).
  List<_GoalSuggestion> _buildSuggestions(
    IncomeDistributionTemplate template,
    double monthlyIncome,
  ) {
    final l10n = context.l10n;
    final suggestions = <_GoalSuggestion>[];

    for (final bucket in template.buckets) {
      final monthlyContribution = monthlyIncome * bucket.percent / 100;
      switch (bucket.id) {
        case 'savings':
          suggestions.add(_GoalSuggestion(
            bucketId: bucket.id,
            title: l10n.aiSuggestedEmergencyFund,
            subtitle: bucket.localizedLabel(l10n),
            style: SavingsGoalStyle.emergency,
            targetAmount: monthlyIncome > 0 ? monthlyIncome * 3 : 3000000,
            monthsLeft: 6,
            monthlyContribution: monthlyContribution,
          ));
          break;
        case 'debt':
          suggestions.add(_GoalSuggestion(
            bucketId: bucket.id,
            title: l10n.aiSuggestedDebtPayoff,
            subtitle: bucket.localizedLabel(l10n),
            style: SavingsGoalStyle.business,
            targetAmount: monthlyIncome > 0 ? monthlyContribution * 6 : 2000000,
            monthsLeft: 6,
            monthlyContribution: monthlyContribution,
          ));
          break;
        case 'investing':
          suggestions.add(_GoalSuggestion(
            bucketId: bucket.id,
            title: l10n.aiSuggestedInvestmentFund,
            subtitle: bucket.localizedLabel(l10n),
            style: SavingsGoalStyle.business,
            targetAmount:
                monthlyIncome > 0 ? monthlyContribution * 12 : 2000000,
            monthsLeft: 12,
            monthlyContribution: monthlyContribution,
          ));
          break;
        case 'buffer':
          suggestions.add(_GoalSuggestion(
            bucketId: bucket.id,
            title: l10n.aiSuggestedIncomeBuffer,
            subtitle: bucket.localizedLabel(l10n),
            style: SavingsGoalStyle.emergency,
            targetAmount: monthlyIncome > 0 ? monthlyIncome * 2 : 1500000,
            monthsLeft: 4,
            monthlyContribution: monthlyContribution,
          ));
          break;
        default:
          // "essentials"/"wants" aren't savings-worthy goals on their own.
          break;
      }
    }

    return suggestions;
  }

  Future<void> _showAiGoalSuggestions() async {
    final l10n = context.l10n;
    final template = context.read<IncomeDistributionProvider>().activeTemplate;
    final monthlyIncome =
        _estimateMonthlyIncome(context.read<TransactionProvider>());
    final currency = context.read<CurrencyProvider>();

    final existingTitles = context
        .read<GoalsProvider>()
        .goals
        .map((goal) => goal.title.trim().toLowerCase())
        .toSet();
    final suggestions = _buildSuggestions(template, monthlyIncome)
        .where((s) => !existingTitles.contains(s.title.trim().toLowerCase()))
        .toList();

    if (suggestions.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.aiNoNewSuggestions)),
      );
      return;
    }

    final selected = {for (final s in suggestions) s.bucketId: true};

    final chosen = await showModalBottomSheet<List<_GoalSuggestion>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
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
                              color:
                                  AppColors.textLight.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor
                                    .withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.auto_awesome_rounded,
                                color: AppColors.primaryColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                l10n.aiGoalSuggestionsTitle,
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.aiGoalSuggestionsSubtitle(
                            template.localizedName(l10n),
                            template.ratioLabel,
                          ),
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 18),
                        for (final suggestion in suggestions) ...[
                          _SuggestionTile(
                            suggestion: suggestion,
                            currency: currency,
                            l10n: l10n,
                            selected: selected[suggestion.bucketId] ?? true,
                            onChanged: (value) => setSheetState(
                              () => selected[suggestion.bucketId] = value,
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: () {
                              final picks = suggestions
                                  .where((s) =>
                                      selected[s.bucketId] ?? false)
                                  .toList();
                              Navigator.pop(sheetContext, picks);
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
                              l10n.aiAddSelectedGoals,
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
              ),
            );
          },
        );
      },
    );

    if (chosen == null || chosen.isEmpty) return;

    final goalsProvider = context.read<GoalsProvider>();
    for (final suggestion in chosen) {
      await goalsProvider.create(SavingsGoal(
        id: '${DateTime.now().millisecondsSinceEpoch}_${suggestion.bucketId}',
        title: suggestion.title,
        subtitle: suggestion.subtitle,
        currentAmount: 0,
        targetAmount: suggestion.targetAmount,
        monthsLeft: suggestion.monthsLeft,
        style: suggestion.style,
      ));
    }
  }

  Future<void> _showGoalSheet({SavingsGoal? goal}) async {
    final currency = context.read<CurrencyProvider>();
    final partnerUid = context.read<CoupleLinkProvider>().partnerUid;
    final titleController = TextEditingController(text: goal?.title ?? '');
    final currentController = TextEditingController(
      text: goal == null ? '' : currency.formatValue(goal.currentAmount),
    );
    final targetController = TextEditingController(
      text: goal == null ? '' : currency.formatValue(goal.targetAmount),
    );
    final monthsController = TextEditingController(
      text: goal?.monthsLeft.toString() ?? '',
    );
    var selectedStyle = goal?.style ?? SavingsGoalStyle.emergency;
    var shareWithPartner = goal?.sharedWith.isNotEmpty ?? false;

    final sheetFuture = showModalBottomSheet<SavingsGoal>(
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
                        Row(
                          children: [
                            Expanded(
                              child: _GoalInput(
                                controller: currentController,
                                label: context.l10n.saved,
                                hint: '800000',
                                keyboardType: TextInputType.number,
                                inputFormatter: currency.usesDecimals
                                    ? null
                                    : currency.inputFormatter,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _GoalInput(
                                controller: targetController,
                                label: context.l10n.target,
                                hint: '3000000',
                                keyboardType: TextInputType.number,
                                inputFormatter: currency.usesDecimals
                                    ? null
                                    : currency.inputFormatter,
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
                        const SizedBox(height: 16),
                        ShareWithPartnerToggle(
                          value: shareWithPartner,
                          onChanged: (value) =>
                              setSheetState(() => shareWithPartner = value),
                          hint: context.l10n.shareGoalWithPartnerHint,
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: () {
                              final title = titleController.text.trim();
                              final current =
                                  currency.parseValue(currentController.text);
                              final target =
                                  currency.parseValue(targetController.text);
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
                                SavingsGoal(
                                  id: goal?.id ??
                                      DateTime.now()
                                          .millisecondsSinceEpoch
                                          .toString(),
                                  title: title,
                                  subtitle: selectedStyle
                                      .localizedLabel(context.l10n),
                                  currentAmount: current,
                                  targetAmount: target,
                                  monthsLeft: months,
                                  style: selectedStyle,
                                  sharedWith: shareWithPartner &&
                                          partnerUid != null
                                      ? [partnerUid]
                                      : const [],
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
      // Delayed so the disposal doesn't race the sheet's still-playing
      // close animation, which keeps rebuilding these fields' TextFields
      // for a bit after the Future resolves.
      Future.delayed(const Duration(milliseconds: 350), () {
        titleController.dispose();
        currentController.dispose();
        targetController.dispose();
        monthsController.dispose();
      });
    });

    final saved = await sheetFuture;

    if (saved == null) return;

    final isNew = goal == null;
    final goalsProvider = context.read<GoalsProvider>();

    try {
      if (isNew) {
        await goalsProvider.create(saved);
        if (mounted) setState(() => _justCreatedGoalId = saved.id);
      } else {
        await goalsProvider.update(saved);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.goalSaveError)),
        );
      }
    }
  }

  Future<void> _deleteGoal(SavingsGoal goal) async {
    try {
      await context.read<GoalsProvider>().delete(goal.id);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.goalDeleteError)),
        );
      }
    }
  }
}

/// One suggested goal derived from a bucket of the user's active income
/// distribution plan (see [IncomeDistributionProvider.activeTemplate]).
class _GoalSuggestion {
  final String bucketId;
  final String title;
  final String subtitle;
  final SavingsGoalStyle style;
  final double targetAmount;
  final int monthsLeft;
  final double monthlyContribution;

  const _GoalSuggestion({
    required this.bucketId,
    required this.title,
    required this.subtitle,
    required this.style,
    required this.targetAmount,
    required this.monthsLeft,
    required this.monthlyContribution,
  });
}

class _SuggestionTile extends StatelessWidget {
  final _GoalSuggestion suggestion;
  final CurrencyProvider currency;
  final AppLocalizations l10n;
  final bool selected;
  final ValueChanged<bool> onChanged;

  const _SuggestionTile({
    required this.suggestion,
    required this.currency,
    required this.l10n,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final color = suggestion.style.color;
    final subtitle = suggestion.monthlyContribution > 0
        ? '${currency.format(suggestion.targetAmount)} · ${l10n.aiSuggestionMonthlyHint(currency.format(suggestion.monthlyContribution))}'
        : currency.format(suggestion.targetAmount);

    return InkWell(
      onTap: () => onChanged(!selected),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.1)
              : AppColors.surfaceInput,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? color : AppColors.borderSubtle,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(suggestion.style.icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    suggestion.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Checkbox(
              value: selected,
              activeColor: color,
              onChanged: (value) => onChanged(value ?? false),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onAiTap;

  const _Header({required this.onAiTap});

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
            color: AppColors.primaryColor.withValues(alpha: 0.14),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primaryColor.withValues(alpha: 0.4),
            ),
          ),
          child: IconButton(
            onPressed: onAiTap,
            tooltip: context.l10n.aiSuggestGoalsTooltip,
            icon: const Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.primaryColor,
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

/// Plays a one-shot "pop in" entrance for a freshly created goal: a springy
/// scale-and-overshoot, a fade-in, and a brief glow in the goal's own style
/// color, plus a light haptic tap — celebrates the goal actually landing in
/// the list instead of it just silently appearing.
class _GoalPopIn extends StatefulWidget {
  final Widget child;
  final Color glowColor;
  final VoidCallback onDone;

  const _GoalPopIn({
    super.key,
    required this.child,
    required this.glowColor,
    required this.onDone,
  });

  @override
  State<_GoalPopIn> createState() => _GoalPopInState();
}

class _GoalPopInState extends State<_GoalPopIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _fade;
  late final Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.7, end: 1.05)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 65,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.05, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 35,
      ),
    ]).animate(_controller);
    _fade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.4, curve: Curves.easeOut),
    );
    _glow = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 70),
    ]).animate(_controller);

    HapticFeedback.mediumImpact();
    _controller.forward().whenComplete(() {
      if (mounted) widget.onDone();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fade.value,
          child: Transform.scale(
            scale: _scale.value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: widget.glowColor
                        .withValues(alpha: 0.4 * _glow.value),
                    blurRadius: 28 * _glow.value,
                    spreadRadius: 2 * _glow.value,
                  ),
                ],
              ),
              child: child,
            ),
          ),
        );
      },
      child: widget.child,
    );
  }
}

class _GoalCard extends StatelessWidget {
  final SavingsGoal goal;
  final VoidCallback onTap;

  const _GoalCard({
    super.key,
    required this.goal,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final progress = goal.progress.clamp(0.0, 1.0);
    final currency = context.watch<CurrencyProvider>();
    final couple = context.watch<CoupleLinkProvider>();
    final isMine = goal.ownerId == null ||
        goal.ownerId == FirebaseAuth.instance.currentUser?.uid;
    final profile = context.watch<ProfileProvider>();
    final ownerName = couple.isLinked
        ? (isMine ? profile.displayName : couple.partnerDisplayName)
        : null;
    final ownerPhotoUrl = couple.isLinked
        ? (isMine ? profile.avatarUrl : couple.partnerPhotoUrl)
        : null;

    return InkWell(
      // A partner's shared goal is view-only: editing/deleting is only
      // allowed for its owner (both in the UI and in Firestore rules).
      onTap: isMine ? onTap : null,
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
                OwnerBadgedIcon(
                  ownerName: ownerName,
                  ownerPhotoUrl: ownerPhotoUrl,
                  isMine: isMine,
                  badgeSize: 20,
                  child: SizedBox(
                    width: 44,
                    height: 44,
                    child: Center(
                      child: Icon(
                        goal.style.icon,
                        color: goal.style.color,
                        size: 32,
                      ),
                    ),
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
  final TextInputFormatter? inputFormatter;

  const _GoalInput({
    required this.controller,
    required this.label,
    required this.hint,
    this.keyboardType,
    this.inputFormatter,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatter == null ? null : [inputFormatter!],
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

