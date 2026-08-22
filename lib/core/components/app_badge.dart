import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

enum AppBadgeVariant { success, warning, error, info, neutral }

/// Reusable semantic status badge for Dayflow HR status displays.
class AppStatusBadge extends StatelessWidget {
  final String label;
  final AppBadgeVariant variant;
  final IconData? icon;

  const AppStatusBadge({
    super.key,
    required this.label,
    this.variant = AppBadgeVariant.neutral,
    this.icon,
  });

  const AppStatusBadge.success({
    super.key,
    required this.label,
    this.icon,
  }) : variant = AppBadgeVariant.success;

  const AppStatusBadge.warning({
    super.key,
    required this.label,
    this.icon,
  }) : variant = AppBadgeVariant.warning;

  const AppStatusBadge.error({
    super.key,
    required this.label,
    this.icon,
  }) : variant = AppBadgeVariant.error;

  const AppStatusBadge.info({
    super.key,
    required this.label,
    this.icon,
  }) : variant = AppBadgeVariant.info;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color bg;
    Color fg;

    switch (variant) {
      case AppBadgeVariant.success:
        bg = AppColors.successContainer;
        fg = AppColors.success;
        break;
      case AppBadgeVariant.warning:
        bg = AppColors.warningContainer;
        fg = AppColors.warning;
        break;
      case AppBadgeVariant.error:
        bg = AppColors.errorContainer;
        fg = AppColors.error;
        break;
      case AppBadgeVariant.info:
        bg = AppColors.infoContainer;
        fg = AppColors.info;
        break;
      case AppBadgeVariant.neutral:
        bg = isDark ? AppColors.darkElevatedSurface : AppColors.lightDivider;
        fg = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: 3.0),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.borderCircular,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: AppSpacing.xxs),
          ],
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Simple dot status indicator.
class AppStatusIndicator extends StatelessWidget {
  final AppBadgeVariant variant;
  final String label;

  const AppStatusIndicator({
    super.key,
    required this.variant,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color color;
    switch (variant) {
      case AppBadgeVariant.success:
        color = AppColors.success;
        break;
      case AppBadgeVariant.warning:
        color = AppColors.warning;
        break;
      case AppBadgeVariant.error:
        color = AppColors.error;
        break;
      case AppBadgeVariant.info:
        color = AppColors.info;
        break;
      case AppBadgeVariant.neutral:
        color = isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;
        break;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
      ],
    );
  }
}
