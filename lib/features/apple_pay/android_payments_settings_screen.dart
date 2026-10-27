part of 'apple_pay_settings_screen.dart';

String _t(BuildContext context, String es, String en) =>
    Localizations.localeOf(context).languageCode == 'en' ? en : es;

/// Android counterpart of [ApplePaySettingsScreen]: purchases are read from
/// payment notifications once the user grants notification access.
class AndroidPaymentsSettingsScreen extends StatelessWidget {
  const AndroidPaymentsSettingsScreen({super.key});

  static String title(BuildContext context) => _t(context,
      'Registrar compras automáticamente', 'Register purchases automatically');

  // Google Play requires a prominent disclosure and consent before sending the
  // user to the notification access settings.
  Future<void> _requestAccess(
      BuildContext context, ApplePayController controller) async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceColor,
        title:
            Text(_t(context, 'Acceso a notificaciones', 'Notification access')),
        content: Text(
          _t(
              context,
              'Billey leerá únicamente las notificaciones de pago de Google Wallet, de la app de Bancolombia y las alertas de compra que tu banco envía por SMS, para crear tus gastos con el monto y el comercio.\n\nNo lee, guarda ni envía ninguna otra notificación o mensaje. Los datos de cada compra se guardan en tu cuenta de Billey.\n\nPuedes quitar el acceso cuando quieras desde Ajustes.',
              'Billey will only read payment notifications from Google Wallet, the Bancolombia app and the purchase alerts your bank sends by SMS, to create your expenses with the amount and merchant.\n\nNo other notification or message is read, stored or sent. Each purchase is saved to your Billey account.\n\nYou can remove access at any time in Settings.'),
          style: TextStyle(
              color: AppColors.textSecondary, fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(_t(context, 'Ahora no', 'Not now'))),
          FilledButton(
              style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: AppColors.white),
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                  _t(context, 'Aceptar y continuar', 'Accept and continue'))),
        ],
      ),
    );
    if (accepted == true) await controller.openPermissionSettings();
  }

  @override
  Widget build(BuildContext context) {
    BilleyThemeScope.isDarkOf(context);
    final controller = context.watch<ApplePayController>();
    final l10n = context.l10n;
    final currency = context.watch<CurrencyProvider>().selectedCurrency.code;
    final last = controller.lastReceived;
    final steps = [
      _t(context, 'Activa el acceso a notificaciones para Billey.',
          'Turn on notification access for Billey.'),
      _t(context, 'Activa "Registrar en esta cuenta".',
          'Turn on "Register in this account".'),
      _t(
          context,
          'Paga como siempre con Google Wallet o tu tarjeta. Cuando llegue la notificación del pago, Billey guarda la compra.',
          'Pay as usual with Google Wallet or your card. When the payment notification arrives, Billey saves the purchase.'),
      _t(context, 'Abre Billey para ver y revisar tus gastos importados.',
          'Open Billey to see and review your imported expenses.'),
    ];
    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      appBar: AppBar(
        leading:
            Navigator.of(context).canPop() ? const BilleyBackButton() : null,
        backgroundColor: AppColors.backgroundAlt,
        elevation: 0,
        title: Text(_t(context, 'Compras automáticas', 'Automatic purchases')),
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
              Text(title(context),
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 28,
                      height: 1.12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.8)),
              const SizedBox(height: 10),
              _Body(_t(
                  context,
                  'Billey toma tus compras de las notificaciones de pago y las lleva a tus gastos, sin anotarlas una por una.',
                  'Billey picks up your purchases from payment notifications and adds them to your expenses, without typing them one by one.')),
              const SizedBox(height: 24),
              _Panel(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Row(children: [
                      const _IconTile(icon: TablerIcons.bell),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Text(
                              _t(context, 'Acceso a notificaciones',
                                  'Notification access'),
                              style: _titleStyle)),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                            color: (controller.permission
                                    ? AppColors.incomeColor
                                    : AppColors.textLight)
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8)),
                        child: Text(
                            controller.permission
                                ? _t(context, 'Activo', 'On')
                                : _t(context, 'Inactivo', 'Off'),
                            style: TextStyle(
                                color: controller.permission
                                    ? AppColors.incomeColor
                                    : AppColors.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w800)),
                      ),
                    ]),
                    const SizedBox(height: 14),
                    _Body(_t(
                        context,
                        'Solo se leen notificaciones de pago de Google Wallet, de la app de Bancolombia y las alertas de compra por SMS. Las demás se ignoran sin guardarse.',
                        'Only payment notifications from Google Wallet, the Bancolombia app and purchase SMS alerts are read. Everything else is ignored and never stored.')),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: controller.permission
                          ? controller.openPermissionSettings
                          : () => _requestAccess(context, controller),
                      icon: const Icon(TablerIcons.settings, size: 18),
                      label: Text(controller.permission
                          ? _t(context, 'Administrar en Ajustes',
                              'Manage in Settings')
                          : _t(context, 'Dar acceso', 'Grant access')),
                      style: TextButton.styleFrom(
                          foregroundColor: AppColors.primaryColor),
                    ),
                  ])),
              const SizedBox(height: 10),
              _Panel(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Row(children: [
                      const _IconTile(icon: TablerIcons.download),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Text(
                              _t(context, 'Registrar en esta cuenta',
                                  'Register in this account'),
                              style: _titleStyle)),
                      const SizedBox(width: 8),
                      Switch.adaptive(
                        value: controller.receiving,
                        activeTrackColor: AppColors.primaryColor,
                        onChanged: !controller.supported ||
                                controller.busy ||
                                (!controller.permission &&
                                    !controller.receiving)
                            ? null
                            : controller.configure,
                      ),
                    ]),
                    const SizedBox(height: 14),
                    _Body(controller.permission
                        ? _t(
                            context,
                            'Las compras se guardan en esta cuenta y en $currency. El símbolo \$ de la notificación se toma como $currency; no se convierten montos.',
                            'Purchases are saved to this account in $currency. The \$ symbol in the notification is read as $currency; amounts are not converted.')
                        : _t(context, 'Primero da acceso a las notificaciones.',
                            'Grant notification access first.')),
                    if (controller.receiving &&
                        controller.configuredCurrency != null &&
                        controller.configuredCurrency != currency)
                      TextButton(
                        onPressed: controller.busy
                            ? null
                            : () => controller.configure(true),
                        child: Text(l10n.applePayUseCurrency(currency)),
                      ),
                  ])),
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
                      Text('${controller.pending}',
                          style: const TextStyle(
                              color: AppColors.primaryColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w800)),
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
              _SectionLabel(_t(context, 'Cómo funciona', 'How it works')),
              const SizedBox(height: 10),
              _Panel(
                  child: Column(children: [
                for (var i = 0; i < steps.length; i++)
                  _GuideStep(
                      number: i + 1,
                      text: steps[i],
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
                    onPressed: controller.busy || !controller.receiving
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
                        icon: TablerIcons.shield_check,
                        title: l10n.applePayScopeTitle,
                        paragraphs: [
                          _t(
                              context,
                              'Billey solo procesa notificaciones de Google Wallet, de la app de Bancolombia y de tu app de mensajes cuando el texto describe una compra (por ejemplo, "Compraste \$18.900 en…"). No necesita leer tus SMS ni pide ese permiso.',
                              'Billey only processes notifications from Google Wallet, the Bancolombia app and your messaging app when the text describes a purchase (for example, "Compraste \$18.900 en…"). It does not read your SMS inbox or ask for that permission.'),
                          _t(
                              context,
                              'Si la misma compra llega por Google Wallet y por el banco en pocos minutos, se registra una sola vez.',
                              'If the same purchase is announced by Google Wallet and by the bank within a few minutes, it is registered once.'),
                        ]),
                    Divider(
                        height: 1,
                        indent: 18,
                        endIndent: 18,
                        color: AppColors.borderSubtle),
                    _Details(
                        icon: TablerIcons.alert_circle,
                        title: _t(context, 'Límites', 'Limitations'),
                        paragraphs: [
                          _t(
                              context,
                              'Si silencias o desactivas las notificaciones de esas apps, o si cambian el texto de sus avisos, la compra no se detecta. Puedes agregarla a mano y editar su fecha, monto o categoría.',
                              'If you mute or turn off those apps\' notifications, or they change their wording, the purchase is not detected. You can add it manually and edit its date, amount or category.'),
                        ]),
                  ])),
            ],
          ),
        ),
      ),
    );
  }
}
