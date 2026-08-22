import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';

enum DayflowLogoSize {
  small,
  medium,
  large,
}

/// Unified, consistent Dayflow Brand Logo component rendering official brand assets.
class DayflowLogo extends StatelessWidget {
  final DayflowLogoSize size;
  final bool showText;
  final Color? textColor;

  const DayflowLogo({
    super.key,
    this.size = DayflowLogoSize.medium,
    this.showText = true,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    double iconBoxSize;
    double textFontSize;

    switch (size) {
      case DayflowLogoSize.small:
        iconBoxSize = 34.0;
        textFontSize = 18.0;
        break;
      case DayflowLogoSize.medium:
        iconBoxSize = 42.0;
        textFontSize = 22.0;
        break;
      case DayflowLogoSize.large:
        iconBoxSize = 64.0;
        textFontSize = 28.0;
        break;
    }

    final effectiveTextColor = textColor ??
        (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary);

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: AppRadius.borderMd,
          child: Container(
            width: iconBoxSize,
            height: iconBoxSize,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppRadius.borderMd,
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Image.asset(
              'assets/images/dayflow_logo.png',
              width: iconBoxSize,
              height: iconBoxSize,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF2563EB), Color(0xFF0D9488)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'D',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: iconBoxSize * 0.5,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        if (showText) ...[
          const SizedBox(width: 10),
          Text(
            'DayFlow',
            style: AppTypography.display.copyWith(
              fontSize: textFontSize,
              fontWeight: FontWeight.w800,
              color: effectiveTextColor,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ],
    );
  }
}
