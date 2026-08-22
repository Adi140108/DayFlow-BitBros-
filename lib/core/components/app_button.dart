import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

enum AppButtonVariant { primary, secondary, text, destructive }
enum AppButtonSize { small, medium, large }

/// Reusable production-grade button component for Dayflow HRMS.
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
  });

  const AppButton.secondary({
    super.key,
    required this.label,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
  }) : variant = AppButtonVariant.secondary;

  const AppButton.text({
    super.key,
    required this.label,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
  }) : variant = AppButtonVariant.text;

  const AppButton.destructive({
    super.key,
    required this.label,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
  }) : variant = AppButtonVariant.destructive;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final enabled = onPressed != null && !isLoading;

    Color bg;
    Color fg;
    BoxBorder? border;

    switch (variant) {
      case AppButtonVariant.primary:
        bg = AppColors.primary;
        fg = Colors.white;
        break;
      case AppButtonVariant.secondary:
        bg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
        fg = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
        border = Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder);
        break;
      case AppButtonVariant.text:
        bg = Colors.transparent;
        fg = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
        break;
      case AppButtonVariant.destructive:
        bg = AppColors.error;
        fg = Colors.white;
        break;
    }

    double height;
    EdgeInsets padding;
    TextStyle fontStyle;

    switch (size) {
      case AppButtonSize.small:
        height = 32.0;
        padding = const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs);
        fontStyle = AppTypography.button.copyWith(fontSize: 12.0);
        break;
      case AppButtonSize.medium:
        height = 40.0;
        padding = const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs);
        fontStyle = AppTypography.button;
        break;
      case AppButtonSize.large:
        height = 48.0;
        padding = const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.sm);
        fontStyle = AppTypography.button.copyWith(fontSize: 16.0);
        break;
    }

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(fg),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
        ] else if (icon != null) ...[
          Icon(icon, size: size == AppButtonSize.small ? 14 : 18, color: fg),
          const SizedBox(width: AppSpacing.xs),
        ],
        Text(label, style: fontStyle.copyWith(color: fg)),
      ],
    );

    Widget buttonWidget = Material(
      color: enabled ? bg : (isDark ? AppColors.darkDisabled : AppColors.lightDisabled),
      borderRadius: AppRadius.borderMd,
      child: InkWell(
        onTap: enabled ? onPressed : null,
        borderRadius: AppRadius.borderMd,
        child: Container(
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            border: border,
            borderRadius: AppRadius.borderMd,
          ),
          child: Center(child: content),
        ),
      ),
    );

    if (isFullWidth) {
      return SizedBox(width: double.infinity, child: buttonWidget);
    }
    return buttonWidget;
  }
}
