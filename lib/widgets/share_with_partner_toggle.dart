import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n_extensions.dart';
import '../providers/couple_link_provider.dart';
import '../theme/colors/app_colors.dart';

/// A "share with {partner}" switch, shown only when a couple link is
/// active — renders nothing otherwise, so unlinked users see no change.
/// Reused wherever something (a transaction, a savings goal, …) can be
/// selectively shared with a linked partner.
class ShareWithPartnerToggle extends StatelessWidget {
  const ShareWithPartnerToggle({
    super.key,
    required this.value,
    required this.onChanged,
    required this.hint,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Consumer<CoupleLinkProvider>(
      builder: (context, couple, _) {
        if (!couple.isLinked) return const SizedBox.shrink();
        final partnerName = couple.partnerDisplayName?.trim().isNotEmpty == true
            ? couple.partnerDisplayName!.trim()
            : l10n.defaultUser;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surfaceInput,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: value
                  ? AppColors.infoColor.withValues(alpha: 0.45)
                  : AppColors.borderSubtle,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.infoColor.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  TablerIcons.users,
                  color: AppColors.infoColor,
                  size: 19,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.shareWithPartner(partnerName),
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 13.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hint,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: value,
                activeThumbColor: AppColors.white,
                activeTrackColor: AppColors.infoColor,
                onChanged: onChanged,
              ),
            ],
          ),
        );
      },
    );
  }
}
