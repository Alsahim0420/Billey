import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../l10n/l10n_extensions.dart';
import '../../providers/currency_provider.dart';
import 'apple_pay_controller.dart';

class ApplePaySettingsScreen extends StatelessWidget {
  const ApplePaySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ApplePayController>();
    final l10n = context.l10n;
    final currency = context.watch<CurrencyProvider>().selectedCurrency.code;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.applePayTitle)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(l10n.applePayScope),
          const SizedBox(height: 16),
          if (!controller.supported)
            Text(l10n.applePayRequiresIOS17)
          else ...[
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.applePayAllowReceipt),
              subtitle: Text(l10n.applePayReceiptConsent(currency)),
              value: controller.receiving,
              onChanged: controller.busy ? null : controller.configure,
            ),
            Text(l10n.applePayAutomationStatus),
            if (controller.configuredCurrency != null)
              Text(l10n
                  .applePayConfiguredCurrency(controller.configuredCurrency!)),
            if (controller.receiving &&
                controller.configuredCurrency != currency)
              TextButton(
                onPressed:
                    controller.busy ? null : () => controller.configure(true),
                child: Text(l10n.applePayUseCurrency(currency)),
              ),
            const Divider(height: 32),
            Text(l10n.applePayLastReceipt(controller.lastReceived == null
                ? l10n.applePayNone
                : DateFormat.yMd().add_Hm().format(controller.lastReceived!))),
            Text(l10n.applePayPending(controller.pending)),
            if (controller.message != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(controller.message!,
                    semanticsLabel: controller.message),
              ),
            if (controller.busy) const LinearProgressIndicator(),
            OutlinedButton.icon(
              onPressed: controller.busy ? null : controller.refresh,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.applePayRetry),
            ),
            OutlinedButton.icon(
              onPressed: controller.busy || !controller.receiving
                  ? null
                  : controller.testReceipt,
              icon: const Icon(Icons.science_outlined),
              label: Text(l10n.applePayTest),
            ),
            Text(l10n.applePayTestExplanation),
          ],
          const Divider(height: 32),
          Text(l10n.applePaySetup,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Text(l10n.applePaySteps),
          const SizedBox(height: 16),
          Text(l10n.applePayMapping),
          const SizedBox(height: 16),
          Text(l10n.applePayLocked),
          const SizedBox(height: 16),
          Text(l10n.applePayShortcutAvailability),
        ],
      ),
    );
  }
}
