import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';

enum DayflowLogoSize {
  small,
  medium,
  large,
}

/// Unified, consistent Dayflow Brand Logo component across all screens.
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
    double fontSize;
    double textFontSize;

    switch (size) {
      case DayflowLogoSize.small:
        iconBoxSize = 32.0;
        fontSize = 18.0;
        textFontSize = 18.0;
        break;
      case DayflowLogoSize.medium:
        iconBoxSize = 38.0;
        fontSize = 22.0;
        textFontSize = 22.0;
        break;
      case DayflowLogoSize.large:
        iconBoxSize = 48.0;
        fontSize = 28.0;
        textFontSize = 28.0;
        break;
    }

    final effectiveTextColor = textColor ??
        (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary);

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: iconBoxSize,
          height: iconBoxSize,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: AppRadius.borderMd,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.25),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              'D',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: fontSize,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ),
        if (showText) ...[
          const SizedBox(width: 10),
          Text(
            'Dayflow',
            style: AppTypography.display.copyWith(
              fontSize: textFontSize,
              fontWeight: FontWeight.w700,
              color: effectiveTextColor,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ],
    );
  }
}
