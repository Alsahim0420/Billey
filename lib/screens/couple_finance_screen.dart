import 'dart:math' as math;

import 'package:billey/l10n/l10n_extensions.dart';
import 'package:billey/providers/couple_link_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:provider/provider.dart';

import '../providers/transaction_provider.dart';
import '../theme/colors/app_colors.dart';

const _otpLength = 6;

class CoupleFinanceScreen extends StatefulWidget {
  const CoupleFinanceScreen({super.key});

  static Route<void> route() {
    return MaterialPageRoute(builder: (_) => const CoupleFinanceScreen());
  }

  @override
  State<CoupleFinanceScreen> createState() => _CoupleFinanceScreenState();
}

class _CoupleFinanceScreenState extends State<CoupleFinanceScreen> {
  final _codeController = TextEditingController();
  bool _redeeming = false;
  bool _codeHasError = false;
  CoupleLinkProvider? _coupleLinkProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Cached here (safe: ancestor lookups work in didChangeDependencies)
    // so dispose() doesn't need context.read(), which is unsafe once the
    // widget has been deactivated.
    _coupleLinkProvider = context.read<CoupleLinkProvider>();
  }

  @override
  void initState() {
    super.initState();
    // Deferred to after the first frame: calling startGeneratingCode()
    // synchronously here would call notifyListeners() while this very
    // widget tree is still being built, which Flutter disallows.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final couple = context.read<CoupleLinkProvider>();
      if (!couple.isLinked) {
        couple.startGeneratingCode();
      }
    });
  }

  @override
  void dispose() {
    _coupleLinkProvider?.stopGeneratingCode();
    _codeController.dispose();
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
      ),
      body: Consumer<CoupleLinkProvider>(
        builder: (context, couple, _) {
          if (!couple.isLoaded) {
            return const Center(child: CircularProgressIndicator());
          }
          return couple.isLinked
              ? _buildLinkedView(context, couple)
              : _buildPairingView(context, couple);
        },
      ),
    );
  }

  Widget _buildPairingView(BuildContext context, CoupleLinkProvider couple) {
    final l10n = context.l10n;
    final remaining = couple.codeRemaining.inSeconds.clamp(0, 300);

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
            l10n.coupleIntro,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.45,
            ),
          ),
        ),
        const SizedBox(height: 26),
        Text(
          l10n.coupleMyCodeLabel,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.coupleMyCodeHint,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 16),
        _CodeCard(
          code: couple.myCode,
          isLoading: couple.isGeneratingCode && couple.myCode == null,
          remainingSeconds: remaining,
          onCopy: couple.myCode == null
              ? null
              : () {
                  Clipboard.setData(ClipboardData(text: couple.myCode!));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.done)),
                  );
                },
        ),
        const SizedBox(height: 36),
        Row(
          children: [
            Expanded(child: Divider(color: AppColors.borderSubtle)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                l10n.coupleEnterPartnerCode,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
            Expanded(child: Divider(color: AppColors.borderSubtle)),
          ],
        ),
        const SizedBox(height: 20),
        _OtpCodeInput(
          controller: _codeController,
          hasError: _codeHasError,
          onChanged: () {
            if (_codeHasError) setState(() => _codeHasError = false);
          },
          onCompleted: () => _redeem(couple),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.topCenter,
          child: !_codeHasError
              ? const SizedBox(width: double.infinity)
              : Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    l10n.coupleInvalidCode,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.expenseColor,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
        ),
        const SizedBox(height: 22),
        SizedBox(
          height: 52,
          child: FilledButton(
            onPressed: _redeeming ? null : () => _redeem(couple),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _redeeming
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(AppColors.white),
                    ),
                  )
                : Text(
                    l10n.coupleLinkButton,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildLinkedView(BuildContext context, CoupleLinkProvider couple) {
    final l10n = context.l10n;
    final partnerName = couple.partnerDisplayName?.trim().isNotEmpty == true
        ? couple.partnerDisplayName!.trim()
        : l10n.defaultUser;
    final myUid = FirebaseAuth.instance.currentUser?.uid;
    final sharedCount = context
        .watch<TransactionProvider>()
        .allTransactions
        .where((t) =>
            t.ownerId == myUid && t.sharedWith.contains(couple.partnerUid))
        .length;
    final sharedSummary = sharedCount == 0
        ? l10n.coupleSharedCountZero(partnerName)
        : sharedCount == 1
            ? l10n.coupleSharedCountOne(partnerName)
            : l10n.coupleSharedCountMany(sharedCount, partnerName);

    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 40),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surfaceColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.infoColor.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  partnerName.isNotEmpty ? partnerName[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: AppColors.infoColor,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                l10n.coupleLinkedWith(partnerName),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w900,
                  fontSize: 17,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.coupleLinkedSubtitle,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: sharedCount > 0
                ? AppColors.primaryColor.withValues(alpha: 0.1)
                : AppColors.surfaceColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: sharedCount > 0
                  ? AppColors.primaryColor.withValues(alpha: 0.3)
                  : AppColors.borderSubtle,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: sharedCount > 0
                      ? AppColors.primaryColor.withValues(alpha: 0.16)
                      : AppColors.textSecondary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  sharedCount > 0
                      ? TablerIcons.rosette_discount_check
                      : TablerIcons.eye_off,
                  color: sharedCount > 0
                      ? AppColors.primaryColor
                      : AppColors.textSecondary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  sharedSummary,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
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

  Future<void> _redeem(CoupleLinkProvider couple) async {
    final l10n = context.l10n;
    final code = _codeController.text.trim();
    if (code.length != _otpLength || _redeeming) return;

    setState(() {
      _redeeming = true;
      _codeHasError = false;
    });
    final error = await couple.redeemCode(code);
    if (!mounted) return;

    if (error != null) {
      setState(() {
        _redeeming = false;
        _codeHasError = true;
      });
      _codeController.clear();
      HapticFeedback.heavyImpact();
      return;
    }

    setState(() => _redeeming = false);
    couple.stopGeneratingCode();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.coupleLinkedSuccess)),
    );
  }

  Future<void> _confirmUnlink(
    BuildContext context,
    CoupleLinkProvider couple,
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

    if (confirmed != true || !context.mounted) return;
    final error = await couple.unlink();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error ?? l10n.coupleUnlinked),
      ),
    );
  }
}

class _CodeCard extends StatelessWidget {
  const _CodeCard({
    required this.code,
    required this.isLoading,
    required this.remainingSeconds,
    required this.onCopy,
  });

  final String? code;
  final bool isLoading;
  final int remainingSeconds;
  final VoidCallback? onCopy;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final progress = remainingSeconds / CoupleLinkProvider.codeTtl.inSeconds;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.primaryColor,
            AppColors.primaryColorDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          if (isLoading)
            const SizedBox(
              height: 44,
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation(AppColors.white),
                ),
              ),
            )
          else
            GestureDetector(
              onTap: onCopy,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _spacedCode(code ?? '------'),
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(TablerIcons.copy,
                      color: AppColors.white, size: 20),
                ],
              ),
            ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 4,
              backgroundColor: AppColors.white.withValues(alpha: 0.25),
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.coupleCodeExpiresIn(remainingSeconds),
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  String _spacedCode(String code) => code.split('').join(' ');
}

/// Digit-by-digit code entry, like an SMS verification prompt: a real
/// (invisible) text field drives keyboard input while six animated boxes
/// render the digits — each one "pops" in as it's typed, the active box
/// glows, and a wrong code makes the whole row shake red.
class _OtpCodeInput extends StatefulWidget {
  const _OtpCodeInput({
    required this.controller,
    required this.hasError,
    required this.onChanged,
    required this.onCompleted,
  });

  final TextEditingController controller;
  final bool hasError;
  final VoidCallback onChanged;
  final VoidCallback onCompleted;

  @override
  State<_OtpCodeInput> createState() => _OtpCodeInputState();
}

class _OtpCodeInputState extends State<_OtpCodeInput>
    with SingleTickerProviderStateMixin {
  final _focusNode = FocusNode();
  late final AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    widget.controller.addListener(_handleTextChange);
  }

  void _handleTextChange() {
    setState(() {});
    widget.onChanged();
    if (widget.controller.text.length == _otpLength) {
      _focusNode.unfocus();
      widget.onCompleted();
    }
  }

  @override
  void didUpdateWidget(covariant _OtpCodeInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.hasError && !oldWidget.hasError) {
      HapticFeedback.selectionClick();
      _shakeController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleTextChange);
    _focusNode.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = widget.controller.text;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _focusNode.requestFocus(),
      child: AnimatedBuilder(
        animation: _shakeController,
        builder: (context, child) {
          final t = _shakeController.value;
          final offset = math.sin(t * math.pi * 6) * (1 - t) * 10;
          return Transform.translate(offset: Offset(offset, 0), child: child);
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(_otpLength, (index) {
                final filled = index < text.length;
                final isActive = index == text.length && _focusNode.hasFocus;
                return _OtpDigitBox(
                  digit: filled ? text[index] : '',
                  isActive: isActive,
                  hasError: widget.hasError,
                );
              }),
            ),
            // Real input capturing the keyboard, invisible but present so
            // taps/autofill/paste all work normally.
            Opacity(
              opacity: 0,
              child: TextField(
                controller: widget.controller,
                focusNode: _focusNode,
                autofocus: true,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                showCursor: false,
                autofillHints: const [AutofillHints.oneTimeCode],
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(_otpLength),
                ],
                decoration: const InputDecoration(
                  counterText: '',
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OtpDigitBox extends StatelessWidget {
  const _OtpDigitBox({
    required this.digit,
    required this.isActive,
    required this.hasError,
  });

  final String digit;
  final bool isActive;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final filled = digit.isNotEmpty;
    final borderColor = hasError
        ? AppColors.expenseColor
        : isActive
            ? AppColors.primaryColor
            : filled
                ? AppColors.primaryColor.withValues(alpha: 0.55)
                : AppColors.borderSubtle;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      width: 46,
      height: 58,
      decoration: BoxDecoration(
        color: hasError
            ? AppColors.expenseColor.withValues(alpha: 0.08)
            : AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: borderColor,
          width: isActive || hasError ? 2 : 1.4,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: AppColors.primaryColor.withValues(alpha: 0.35),
                  blurRadius: 14,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      alignment: Alignment.center,
      child: TweenAnimationBuilder<double>(
        key: ValueKey(digit.isEmpty ? 'empty' : digit),
        tween: Tween(begin: filled ? 0.4 : 1, end: 1),
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutBack,
        builder: (context, scale, child) {
          return Transform.scale(scale: scale, child: child);
        },
        child: Text(
          digit,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
