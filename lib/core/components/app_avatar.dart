import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

enum AppAvatarSize { small, medium, large }

/// Reusable User Avatar component for Dayflow HRMS.
class AppAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final AppAvatarSize size;
  final Color? backgroundColor;

  const AppAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.size = AppAvatarSize.medium,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    double dimension;
    TextStyle style;

    switch (size) {
      case AppAvatarSize.small:
        dimension = 32.0;
        style = AppTypography.caption.copyWith(fontWeight: FontWeight.w600);
        break;
      case AppAvatarSize.medium:
        dimension = 40.0;
        style = AppTypography.label;
        break;
      case AppAvatarSize.large:
        dimension = 56.0;
        style = AppTypography.sectionHeading;
        break;
    }

    String initials = '';
    if (name != null && name!.trim().isNotEmpty) {
      final parts = name!.trim().split(' ');
      if (parts.length > 1) {
        initials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      } else {
        initials = parts[0][0].toUpperCase();
      }
    }

    final bg = backgroundColor ??
        (isDark ? AppColors.darkElevatedSurface : AppColors.primaryContainer);
    final fg = isDark ? AppColors.darkTextPrimary : AppColors.primary;

    return Container(
      width: dimension,
      height: dimension,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        image: imageUrl != null && imageUrl!.isNotEmpty
            ? DecorationImage(image: NetworkImage(imageUrl!), fit: BoxFit.cover)
            : null,
      ),
      child: imageUrl == null || imageUrl!.isEmpty
          ? Center(
              child: Text(
                initials.isNotEmpty ? initials : 'U',
                style: style.copyWith(color: fg),
              ),
            )
          : null,
    );
  }
}

/// Avatar group stack primitive.
class AppAvatarGroup extends StatelessWidget {
  final List<AppAvatar> avatars;
  final int maxVisible;

  const AppAvatarGroup({
    super.key,
    required this.avatars,
    this.maxVisible = 3,
  });

  @override
  Widget build(BuildContext context) {
    final visible = avatars.take(maxVisible).toList();
    final remaining = avatars.length - maxVisible;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < visible.length; i++)
          Align(
            widthFactor: 0.7,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  width: 2,
                ),
              ),
              child: visible[i],
            ),
          ),
        if (remaining > 0)
          Align(
            widthFactor: 0.7,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  '+$remaining',
                  style: AppTypography.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
