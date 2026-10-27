import '../../widgets/billey_back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../l10n/l10n_extensions.dart';
import '../../providers/currency_provider.dart';
import '../../theme/billey_theme_scope.dart';
import '../../theme/colors/app_colors.dart';
import 'apple_pay_controller.dart';

part 'android_payments_settings_screen.dart';

class ApplePaySettingsScreen extends StatelessWidget {
  const ApplePaySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    BilleyThemeScope.isDarkOf(context);
    final controller = context.watch<ApplePayController>();
    final l10n = context.l10n;
    final currency = context.watch<CurrencyProvider>().selectedCurrency.code;
    final steps = l10n.applePayGuideSteps.split('\n');
    final last = controller.lastReceived;
    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      appBar: AppBar(
        leading:
            Navigator.of(context).canPop() ? const BilleyBackButton() : null,
        backgroundColor: AppColors.backgroundAlt,
        elevation: 0,
        title: const Text('Apple Pay'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 36),
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: _IconTile(icon: TablerIcons.wallet, size: 56),
              ),
              const SizedBox(height: 18),
              Text(l10n.applePayTitle,
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 28,
                      height: 1.12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.8)),
              const SizedBox(height: 10),
              _Body(l10n.applePayIntro),
              const SizedBox(height: 24),
              _Panel(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Row(children: [
                      const _IconTile(icon: TablerIcons.download),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Text(l10n.applePayAllowReceipt,
                              style: _titleStyle)),
                      const SizedBox(width: 8),
                      Switch.adaptive(
                        value: controller.receiving,
                        activeTrackColor: AppColors.primaryColor,
                        onChanged: !controller.supported || controller.busy
                            ? null
                            : controller.configure,
                      ),
                    ]),
                    const SizedBox(height: 14),
                    _Body(controller.supported
                        ? l10n.applePayAccountHint(currency)
                        : l10n.applePayRequiresIOS17),
                    if (controller.configuredCurrency != null) ...[
                      const SizedBox(height: 14),
                      Row(children: [
                        const Icon(TablerIcons.coin,
                            size: 16, color: AppColors.primaryColor),
                        const SizedBox(width: 7),
                        Expanded(
                            child: Text(
                                l10n.applePayConfiguredCurrency(
                                    controller.configuredCurrency!),
                                style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600))),
                      ]),
                    ],
                    if (controller.receiving &&
                        controller.configuredCurrency != currency)
                      TextButton(
                        onPressed: controller.busy
                            ? null
                            : () => controller.configure(true),
                        child: Text(l10n.applePayUseCurrency(currency)),
                      ),
                  ])),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(TablerIcons.info_circle,
                          size: 15, color: AppColors.textLight),
                      const SizedBox(width: 7),
                      Expanded(
                          child: Text(l10n.applePayAutomationStatus,
                              style: TextStyle(
                                  color: AppColors.textLight,
                                  fontSize: 12,
                                  height: 1.45))),
                    ]),
              ),
              const SizedBox(height: 26),
              _SectionLabel(l10n.applePayActivity),
              const SizedBox(height: 10),
              _Panel(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Row(children: [
                      const _IconTile(icon: TablerIcons.receipt),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text(l10n.applePayLastLabel, style: _titleStyle),
                            const SizedBox(height: 5),
                            Text(
                                last == null
                                    ? l10n.applePayNone
                                    : DateFormat.yMMMd(
                                            Localizations.localeOf(context)
                                                .toLanguageTag())
                                        .add_Hm()
                                        .format(last),
                                style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13)),
                          ])),
                      IconButton(
                        tooltip: l10n.applePayRetry,
                        onPressed: controller.busy || !controller.supported
                            ? null
                            : controller.refresh,
                        icon: const Icon(TablerIcons.refresh,
                            color: AppColors.primaryColor, size: 21),
                      ),
                    ]),
                    const SizedBox(height: 16),
                    Divider(height: 1, color: AppColors.borderSubtle),
                    const SizedBox(height: 14),
                    Row(children: [
                      Expanded(
                          child: Text(l10n.applePayPendingLabel,
                              style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13))),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                            color:
                                AppColors.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8)),
                        child: Text('${controller.pending}',
                            style: const TextStyle(
                                color: AppColors.primaryColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w800)),
                      ),
                    ]),
                    if (controller.busy) ...[
                      const SizedBox(height: 16),
                      LinearProgressIndicator(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(4)),
                    ],
                    if (controller.message != null) ...[
                      const SizedBox(height: 14),
                      Semantics(
                          liveRegion: true, child: _Body(controller.message!)),
                    ],
                  ])),
              const SizedBox(height: 26),
              _SectionLabel(l10n.applePaySetup),
              const SizedBox(height: 10),
              _Panel(
                  child: Column(children: [
                for (var i = 0; i < steps.length; i++)
                  _GuideStep(
                      number: i + 1,
                      text: steps[i].replaceFirst(RegExp(r'^\d+\.\s*'), ''),
                      last: i == steps.length - 1),
              ])),
              const SizedBox(height: 14),
              SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: AppColors.white,
                      disabledBackgroundColor: AppColors.surfaceInput,
                      disabledForegroundColor: AppColors.textLight,
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: controller.busy ||
                            !controller.supported ||
                            !controller.receiving
                        ? null
                        : controller.testReceipt,
                    icon: const Icon(TablerIcons.flask, size: 20),
                    label: Text(l10n.applePayTestShort,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w800)),
                  )),
              const SizedBox(height: 9),
              Text(l10n.applePayTestHint,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: AppColors.textLight, fontSize: 12, height: 1.45)),
              const SizedBox(height: 26),
              _SectionLabel(l10n.applePayMoreDetails),
              const SizedBox(height: 10),
              _Panel(
                  padding: EdgeInsets.zero,
                  child: Column(children: [
                    _Details(
                        icon: TablerIcons.adjustments,
                        title: l10n.applePayMappingTitle,
                        paragraphs: [l10n.applePaySteps, l10n.applePayMapping]),
                    Divider(
                        height: 1,
                        indent: 18,
                        endIndent: 18,
                        color: AppColors.borderSubtle),
                    _Details(
                        icon: TablerIcons.shield_check,
                        title: l10n.applePayScopeTitle,
                        paragraphs: [
                          l10n.applePayScope,
                          l10n.applePayLocked,
                          l10n.applePayReceiptConsent(currency)
                        ]),
                    Divider(
                        height: 1,
                        indent: 18,
                        endIndent: 18,
                        color: AppColors.borderSubtle),
                    _Details(
                        icon: TablerIcons.bolt,
                        title: l10n.applePayShortcutTitle,
                        paragraphs: [
                          l10n.applePayShortcutAvailability,
                          l10n.applePayTestExplanation
                        ]),
                  ])),
            ],
          ),
        ),
      ),
    );
  }
}

TextStyle get _titleStyle => TextStyle(
    color: AppColors.textPrimary,
    fontSize: 14,
    fontWeight: FontWeight.w800,
    height: 1.35);

class _Body extends StatelessWidget {
  const _Body(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(text,
      style:
          TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.6));
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child, this.padding = const EdgeInsets.all(18)});
  final Widget child;
  final EdgeInsets padding;
  @override
  Widget build(BuildContext context) => Container(
        padding: padding,
        decoration: BoxDecoration(
            color: AppColors.surfaceColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.borderSubtle)),
        child: child,
      );
}

class _IconTile extends StatelessWidget {
  const _IconTile({required this.icon, this.size = 42});
  final IconData icon;
  final double size;
  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
            color: AppColors.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(size == 56 ? 16 : 12)),
        child: Icon(icon,
            size: size == 56 ? 28 : 21, color: AppColors.primaryColor),
      );
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(text.toUpperCase(),
      style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.1));
}

class _GuideStep extends StatelessWidget {
  const _GuideStep(
      {required this.number, required this.text, required this.last});
  final int number;
  final String text;
  final bool last;
  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(bottom: last ? 0 : 18),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8)),
              child: Text('$number',
                  style: const TextStyle(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 12))),
          const SizedBox(width: 12),
          Expanded(child: _Body(text)),
        ]),
      );
}

class _Details extends StatelessWidget {
  const _Details(
      {required this.icon, required this.title, required this.paragraphs});
  final IconData icon;
  final String title;
  final List<String> paragraphs;
  @override
  Widget build(BuildContext context) => Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 3),
          childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
          iconColor: AppColors.primaryColor,
          collapsedIconColor: AppColors.textLight,
          leading: Icon(icon, size: 21, color: AppColors.primaryColor),
          title: Text(title, style: _titleStyle),
          children: [
            for (var i = 0; i < paragraphs.length; i++)
              Padding(
                  padding: EdgeInsets.only(top: i == 0 ? 0 : 12),
                  child: _Body(paragraphs[i]))
          ],
        ),
      );
}
