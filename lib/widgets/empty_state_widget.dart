import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import '../theme/colors/app_colors.dart';

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionText;
  final VoidCallback? onAction;
  final Color? color;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionText,
    this.onAction,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = color ?? AppColors.primaryColor;
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 600;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Ajustar tamaños según el espacio disponible
        final iconSize = isSmallScreen ? 80.0 : 120.0;
        final iconSizeInner = isSmallScreen ? 40.0 : 60.0;
        final titleSize = isSmallScreen ? 20.0 : 24.0;
        final messageSize = isSmallScreen ? 14.0 : 16.0;
        final spacing = isSmallScreen ? 16.0 : 24.0;
        final padding = isSmallScreen ? 16.0 : 32.0;

        return Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Padding(
                  padding: EdgeInsets.all(padding),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: iconSize,
                        height: iconSize,
                        decoration: BoxDecoration(
                          color: primaryColor == AppColors.primaryColor
                              ? const Color.fromARGB(255, 0, 150, 135)
                                  .withAlpha(25)
                              : primaryColor.withAlpha(25),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          icon,
                          size: iconSizeInner,
                          color: primaryColor,
                        ),
                      ),
                      SizedBox(height: spacing),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: titleSize,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: spacing * 0.5),
                      Text(
                        message,
                        style: TextStyle(
                          fontSize: messageSize,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: isSmallScreen ? 3 : null,
                        overflow: isSmallScreen ? TextOverflow.ellipsis : null,
                      ),
                      if (actionText != null && onAction != null) ...[
                        SizedBox(height: spacing),
                        ElevatedButton.icon(
                          onPressed: onAction,
                          icon: const Icon(TablerIcons.plus, size: 18),
                          label: Text(
                            actionText!,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 14 : 16,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: AppColors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 16 : 24,
                              vertical: isSmallScreen ? 8 : 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
