import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n_extensions.dart';
import '../l10n/localization_helpers.dart';
import '../providers/income_distribution_provider.dart';
import '../theme/billey_theme_scope.dart';
import '../theme/colors/app_colors.dart';

class IncomeDistributionScreen extends StatefulWidget {
  const IncomeDistributionScreen({super.key});

  @override
  State<IncomeDistributionScreen> createState() =>
      _IncomeDistributionScreenState();
}

class _IncomeDistributionScreenState extends State<IncomeDistributionScreen> {
  late double _essentials;
  late double _wants;
  late double _savings;
  bool _initialized = false;

  double get _total => _essentials + _wants + _savings;
  bool get _isValid => _total.round() == 100;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    final active = context.read<IncomeDistributionProvider>().activeTemplate;
    _essentials = active.essentials;
    _wants = active.wants;
    _savings = active.savings;
    _initialized = true;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    BilleyThemeScope.isDarkOf(context);
    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      body: SafeArea(
        child: Consumer<IncomeDistributionProvider>(
          builder: (context, distribution, _) {
            final active = distribution.activeTemplate;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.maybePop(context),
                        icon: Icon(
                          TablerIcons.arrow_left,
                          color: AppColors.textPrimary,
                          size: 26,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          l10n.autoDistribution,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
                    children: [
                      _AutoSwitchCard(
                        enabled: distribution.autoEnabled,
                        activeTemplate: active,
                        onChanged: distribution.setAutoEnabled,
                      ),
                      const SizedBox(height: 24),
                      _SectionLabel(l10n.templatesSection),
                      const SizedBox(height: 12),
                      for (final template
                          in IncomeDistributionProvider.templates) ...[
                        _TemplateTile(
                          template: template,
                          selected: active.id == template.id,
                          onTap: () {
                            _setSliders(template);
                            distribution.selectTemplate(template.id);
                          },
                        ),
                        const SizedBox(height: 10),
                      ],
                      _TemplateTile(
                        template: active.isCustom
                            ? active
                            : IncomeDistributionTemplate(
                                id: IncomeDistributionProvider.customTemplateId,
                                name: l10n.templateCustomName,
                                subtitle: l10n.customTemplateSubtitle,
                                buckets: [
                                  DistributionBucket(
                                    id: 'essentials',
                                    label: l10n.bucketEssentials,
                                    percent: _essentials,
                                    iconKey: 'home',
                                    colorValue: 0xFF2D6CDF,
                                  ),
                                  DistributionBucket(
                                    id: 'wants',
                                    label: l10n.bucketWants,
                                    percent: _wants,
                                    iconKey: 'bag',
                                    colorValue: 0xFF8B4DD7,
                                  ),
                                  DistributionBucket(
                                    id: 'savings',
                                    label: l10n.bucketSavings,
                                    percent: _savings,
                                    iconKey: 'pig',
                                    colorValue: 0xFF0EA56A,
                                  ),
                                ],
                                isCustom: true,
                              ),
                        selected: active.id ==
                            IncomeDistributionProvider.customTemplateId,
                        onTap: () {
                          distribution.selectTemplate(
                            IncomeDistributionProvider.customTemplateId,
                          );
                        },
                      ),
                      const SizedBox(height: 26),
                      _SectionLabel(l10n.customRuleSection),
                      const SizedBox(height: 12),
                      _CustomRulesCard(
                        essentials: _essentials,
                        wants: _wants,
                        savings: _savings,
                        total: _total,
                        isValid: _isValid,
                        onEssentialsChanged: (value) {
                          setState(() => _essentials = value.roundToDouble());
                        },
                        onWantsChanged: (value) {
                          setState(() => _wants = value.roundToDouble());
                        },
                        onSavingsChanged: (value) {
                          setState(() => _savings = value.roundToDouble());
                        },
                        onSave: _isValid
                            ? () async {
                                await distribution.saveCustom(
                                  essentials: _essentials,
                                  wants: _wants,
                                  savings: _savings,
                                );
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(l10n.customRuleSaved),
                                    backgroundColor: AppColors.surfacePressed,
                                  ),
                                );
                              }
                            : null,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _setSliders(IncomeDistributionTemplate template) {
    setState(() {
      _essentials = template.essentials;
      _wants = template.wants;
      _savings = template.savings;
    });
  }
}

class _AutoSwitchCard extends StatelessWidget {
  final bool enabled;
  final IncomeDistributionTemplate activeTemplate;
  final ValueChanged<bool> onChanged;

  const _AutoSwitchCard({
    required this.enabled,
    required this.activeTemplate,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceInput,
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: AppColors.primaryColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              TablerIcons.route_alt_left,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.autoDistributeIncome,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  enabled
                      ? activeTemplate.localizedName(l10n)
                      : l10n.disabledForNewDeposits,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: enabled,
            activeThumbColor: AppColors.white,
            activeTrackColor: AppColors.primaryColor,
            inactiveThumbColor: AppColors.textSecondary,
            inactiveTrackColor: AppColors.surfacePressed,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _TemplateTile extends StatelessWidget {
  final IncomeDistributionTemplate template;
  final bool selected;
  final VoidCallback onTap;

  const _TemplateTile({
    required this.template,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Material(
      color: selected ? AppColors.surfaceElevated : AppColors.surfaceInput,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? AppColors.primaryColor.withValues(alpha: 0.55)
                  : AppColors.borderSubtle,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  template.isCustom
                      ? TablerIcons.adjustments_horizontal
                      : TablerIcons.layout_grid,
                  color: AppColors.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      template.localizedName(l10n),
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      template.localizedSubtitle(l10n),
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${template.essentials.round()}/${template.wants.round()}/${template.savings.round()}',
                style: const TextStyle(
                  color: AppColors.primaryColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                selected ? TablerIcons.circle_check_filled : TablerIcons.circle,
                color:
                    selected ? AppColors.primaryColor : AppColors.textSecondary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomRulesCard extends StatelessWidget {
  final double essentials;
  final double wants;
  final double savings;
  final double total;
  final bool isValid;
  final ValueChanged<double> onEssentialsChanged;
  final ValueChanged<double> onWantsChanged;
  final ValueChanged<double> onSavingsChanged;
  final VoidCallback? onSave;

  const _CustomRulesCard({
    required this.essentials,
    required this.wants,
    required this.savings,
    required this.total,
    required this.isValid,
    required this.onEssentialsChanged,
    required this.onWantsChanged,
    required this.onSavingsChanged,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: AppColors.surfaceInput,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.totalAllocationLabel,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              Text(
                '${total.round()}%',
                style: TextStyle(
                  color:
                      isValid ? AppColors.primaryColor : AppColors.expenseColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _RuleSlider(
            icon: TablerIcons.home,
            label: l10n.bucketEssentials,
            value: essentials,
            color: const Color(0xFF2D6CDF),
            onChanged: onEssentialsChanged,
          ),
          _RuleSlider(
            icon: TablerIcons.shopping_bag,
            label: l10n.bucketWants,
            value: wants,
            color: const Color(0xFF8B4DD7),
            onChanged: onWantsChanged,
          ),
          _RuleSlider(
            icon: TablerIcons.pig_money,
            label: l10n.bucketSavings,
            value: savings,
            color: const Color(0xFF0EA56A),
            onChanged: onSavingsChanged,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                disabledBackgroundColor:
                    AppColors.textLight.withValues(alpha: 0.22),
                foregroundColor: AppColors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                l10n.saveCustomRule,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RuleSlider extends StatelessWidget {
  final IconData icon;
  final String label;
  final double value;
  final Color color;
  final ValueChanged<double> onChanged;

  const _RuleSlider({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, color: color, size: 19),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '${value.round()}%',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: color,
              inactiveTrackColor:
                  AppColors.backgroundColor.withValues(alpha: 0.5),
              thumbColor: AppColors.white,
              overlayColor: color.withValues(alpha: 0.16),
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            ),
            child: Slider(
              min: 0,
              max: 100,
              divisions: 100,
              value: value,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

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
