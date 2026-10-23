import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';

import '../theme/colors/app_colors.dart';

/// One back control for both custom headers and standard app bars.
class BilleyBackButton extends StatelessWidget {
  const BilleyBackButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => IconButton(
        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        onPressed: onPressed ?? () => Navigator.of(context).maybePop(),
        icon: Icon(
          TablerIcons.arrow_left,
          color: AppColors.textPrimary,
          size: 26,
        ),
      );
}
