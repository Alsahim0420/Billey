import 'package:billey/l10n/l10n_extensions.dart';
import 'package:billey/providers/couple_finance_provider.dart';
import 'package:billey/providers/currency_provider.dart';
import 'package:billey/providers/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:provider/provider.dart';

import '../models/couple_finance.dart';
import '../theme/colors/app_colors.dart';
import 'couple_qr_display_screen.dart';
import 'couple_qr_scan_screen.dart';
import 'couple_wallet_detail_screen.dart';

class CoupleFinanceScreen extends StatefulWidget {
  const CoupleFinanceScreen({super.key});

  static Route<void> route() {
    return MaterialPageRoute(
      builder: (_) => ChangeNotifierProvider<CoupleFinanceProvider>.value(
        value: CoupleFinanceProvider.instance,
        child: const CoupleFinanceScreen(),
      ),
    );
  }

  @override
  State<CoupleFinanceScreen> createState() => _CoupleFinanceScreenState();
}

class _CoupleFinanceScreenState extends State<CoupleFinanceScreen> {
  final _sharedWithNameController = TextEditingController();

  @override
  void dispose() {
    _sharedWithNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceColor,
        elevation: 0,
        title: Text(
          l10n.coupleFinanceTitle,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w900,
          ),
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        actions: [
          Consumer<CoupleFinanceProvider>(
            builder: (context, couple, _) {
              if (!couple.isLinked) return const SizedBox.shrink();
              return IconButton(
                onPressed: () => _scanUpdate(context),
                icon: const Icon(TablerIcons.scan),
                color: AppColors.primaryColor,
                tooltip: l10n.coupleScanQr,
              );
            },
          ),
        ],
      ),
      body: Consumer3<CoupleFinanceProvider, ProfileProvider, CurrencyProvider>(
        builder: (context, couple, profile, currency, _) {
          if (!couple.isLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!couple.isLinked) {
            return _buildPairingView(context, profile, couple);
          }

          return _buildLinkedView(context, couple, currency);
        },
      ),
      floatingActionButton: Consumer<CoupleFinanceProvider>(
        builder: (context, couple, _) {
          if (!couple.isLinked) return const SizedBox.shrink();
          return FloatingActionButton.extended(
            onPressed: () => _createWallet(context, couple),
            backgroundColor: AppColors.primaryColor,
            foregroundColor: AppColors.white,
            icon: const Icon(TablerIcons.cash),
            label: Text(context.l10n.coupleNewTransfer),
          );
        },
      ),
    );
  }

  Widget _buildPairingView(
    BuildContext context,
    ProfileProvider profile,
    CoupleFinanceProvider couple,
  ) {
    final l10n = context.l10n;
    final myName = profile.displayName.trim().isEmpty
        ? l10n.defaultUser
        : profile.displayName.trim();

    return ListView(
      padding: const EdgeInsets.all(22),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            l10n.couplePairingIntro,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.45,
            ),
          ),
        ),
        const SizedBox(height: 22),
        Text(
          l10n.couplePartnerName,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _sharedWithNameController,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: l10n.couplePartnerNameHint,
            filled: true,
            fillColor: AppColors.surfaceColor,
          ),
        ),
        const SizedBox(height: 20),
        _ActionButton(
          icon: TablerIcons.qrcode,
          label: l10n.coupleShowPairingQr,
          onTap: () async {
            final sharedWithName = _sharedWithNameController.text.trim();
            if (sharedWithName.length < 2) {
              _snack(l10n.couplePartnerNameRequired);
              return;
            }
            final payload = await couple.createPairingQr(
              myName: myName,
              partnerName: sharedWithName,
            );
            if (!context.mounted) return;
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CoupleQrDisplayScreen(
                  title: l10n.couplePairingQrTitle,
                  subtitle: l10n.couplePairingQrSubtitle(sharedWithName),
                  payload: payload,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _ActionButton(
          icon: TablerIcons.scan,
          label: l10n.coupleScanPairingQr,
          outlined: true,
          onTap: () => _scanPairing(context, couple, myName),
        ),
      ],
    );
  }

  Widget _buildLinkedView(
    BuildContext context,
    CoupleFinanceProvider couple,
    CurrencyProvider currency,
  ) {
    final l10n = context.l10n;
    final link = couple.link!;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  TablerIcons.users,
                  color: AppColors.primaryColor,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.coupleLinkedWith(link.partnerName),
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.coupleSyncReminder,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                icon: TablerIcons.qrcode,
                label: l10n.coupleShareUpdate,
                compact: true,
                onTap: () {
                  final payload = couple.buildSyncQr();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CoupleQrDisplayScreen(
                        title: l10n.coupleSyncQrTitle,
                        subtitle: l10n.coupleSyncQrSubtitleAll,
                        payload: payload,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ActionButton(
                icon: TablerIcons.scan,
                label: l10n.coupleScanUpdate,
                compact: true,
                outlined: true,
                onTap: () => _scanUpdate(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          l10n.coupleSharedWallets,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),
        if (couple.wallets.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Text(
              l10n.coupleWalletsEmpty,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        else
          ...couple.wallets.map(
            (wallet) => _WalletCard(
              wallet: wallet,
              currency: currency,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        CoupleWalletDetailScreen(walletId: wallet.id),
                  ),
                );
              },
            ),
          ),
        const SizedBox(height: 20),
        TextButton(
          onPressed: () => _confirmUnlink(context, couple),
          child: Text(
            l10n.coupleUnlink,
            style: const TextStyle(
              color: AppColors.expenseColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _scanPairing(
    BuildContext context,
    CoupleFinanceProvider couple,
    String myName,
  ) async {
    final l10n = context.l10n;
    final payload = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const CoupleQrScanScreen()),
    );
    if (payload == null || !context.mounted) return;

    final error = await couple.acceptPairing(payload: payload, myName: myName);
    if (!context.mounted) return;

    if (error != null) {
      _snack(l10n.coupleSyncInvalid);
      return;
    }
    _snack(l10n.coupleLinkedSuccess);
  }

  Future<void> _scanUpdate(BuildContext context) async {
    final l10n = context.l10n;
    final couple = context.read<CoupleFinanceProvider>();
    final payload = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const CoupleQrScanScreen()),
    );
    if (payload == null || !context.mounted) return;

    final error = await couple.mergeSyncPayload(payload);
    if (!context.mounted) return;

    if (error != null) {
      _snack(l10n.coupleSyncInvalid);
      return;
    }
    _snack(l10n.coupleSyncSuccess);
  }

  Future<void> _createWallet(
    BuildContext context,
    CoupleFinanceProvider couple,
  ) async {
    final l10n = context.l10n;
    final link = couple.link!;
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    var holderIsPartner = true;

    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                16,
                20,
                20 + MediaQuery.viewInsetsOf(sheetContext).bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.coupleNewTransfer,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: l10n.coupleTransferTitle,
                      hintText: l10n.coupleTransferTitleHint,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n.coupleTransferAmount,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.coupleHolderIsPartner(link.partnerName)),
                    value: holderIsPartner,
                    activeThumbColor: AppColors.primaryColor,
                    onChanged: (value) =>
                        setSheetState(() => holderIsPartner = value),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () {
                      final amount =
                          double.tryParse(amountController.text.trim()) ?? 0;
                      if (titleController.text.trim().length < 2 ||
                          amount <= 0) {
                        return;
                      }
                      Navigator.pop(sheetContext, true);
                    },
                    child: Text(l10n.createUpper),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (created != true || !context.mounted) {
      titleController.dispose();
      amountController.dispose();
      return;
    }

    final amount = double.tryParse(amountController.text.trim()) ?? 0;
    final holderName = holderIsPartner ? link.partnerName : link.myName;

    final wallet = await couple.createWallet(
      title: titleController.text.trim(),
      budget: amount,
      holderName: holderName,
    );

    titleController.dispose();
    amountController.dispose();

    if (!context.mounted) return;

    _snack(l10n.coupleWalletCreated);
    final payload = couple.buildSyncQr();
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CoupleQrDisplayScreen(
          title: l10n.coupleSyncQrTitle,
          subtitle: l10n.coupleSyncQrSubtitle(wallet.title),
          payload: payload,
        ),
      ),
    );
  }

  Future<void> _confirmUnlink(
    BuildContext context,
    CoupleFinanceProvider couple,
  ) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.coupleUnlinkTitle),
        content: Text(l10n.coupleUnlinkMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              l10n.coupleUnlink,
              style: const TextStyle(color: AppColors.expenseColor),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await couple.unlink();
      if (context.mounted) _snack(l10n.coupleUnlinked);
    }
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.outlined = false,
    this.compact = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool outlined;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: compact ? 18 : 20),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            label,
            maxLines: 2,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: compact ? 12 : 14,
            ),
          ),
        ),
      ],
    );

    if (outlined) {
      return OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 10 : 16,
            vertical: compact ? 14 : 16,
          ),
          foregroundColor: AppColors.primaryColor,
          side:
              BorderSide(color: AppColors.primaryColor.withValues(alpha: 0.5)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: child,
      );
    }

    return FilledButton(
      onPressed: onTap,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.white,
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 10 : 16,
          vertical: compact ? 14 : 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: child,
    );
  }
}

class _WalletCard extends StatelessWidget {
  const _WalletCard({
    required this.wallet,
    required this.currency,
    required this.onTap,
  });

  final SharedWallet wallet;
  final CurrencyProvider currency;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final progress = wallet.budget == 0
        ? 0.0
        : (wallet.spent / wallet.budget).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        wallet.title,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Text(
                      currency.format(wallet.remaining),
                      style: const TextStyle(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${l10n.coupleFor} ${wallet.holderName} · ${currency.format(wallet.budget)}',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: AppColors.backgroundAlt,
                    color: progress > 0.85
                        ? AppColors.expenseColor
                        : AppColors.primaryColor,
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
