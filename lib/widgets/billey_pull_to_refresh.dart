import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import '../l10n/l10n_extensions.dart';
import '../theme/colors/app_colors.dart';

class BilleyPullToRefresh extends StatelessWidget {
  const BilleyPullToRefresh(
      {super.key, required this.onRefresh, required this.builder});
  final Future<void> Function() onRefresh;
  final Widget Function(BuildContext, ScrollPhysics) builder;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return EasyRefresh.builder(
      header: ClassicHeader(
        triggerOffset: 76,
        safeArea: false,
        hapticFeedback: true,
        showMessage: false,
        spacing: 10,
        iconDimension: 22,
        progressIndicatorSize: 20,
        progressIndicatorStrokeWidth: 2.4,
        processedDuration: const Duration(milliseconds: 650),
        dragText: l10n.homeRefreshPull,
        armedText: l10n.homeRefreshRelease,
        readyText: l10n.homeRefreshing,
        processingText: l10n.homeRefreshing,
        processedText: l10n.homeRefreshDone,
        failedText: l10n.homeRefreshFailed,
        iconTheme: const IconThemeData(color: AppColors.primaryColor),
        textStyle: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w700),
        succeededIcon: const Icon(TablerIcons.circle_check,
            color: AppColors.primaryColor, size: 22),
        failedIcon: const Icon(TablerIcons.alert_circle,
            color: AppColors.expenseColor, size: 22),
      ),
      onRefresh: () async {
        try {
          await onRefresh();
          return IndicatorResult.success;
        } catch (_) {
          return IndicatorResult.fail;
        }
      },
      childBuilder: builder,
    );
  }
}
