import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

class NavItemData {
  final String title;
  final IconData icon;
  final String route;

  const NavItemData({
    required this.title,
    required this.icon,
    required this.route,
  });
}

const List<NavItemData> kAppNavItems = [
  NavItemData(title: 'Dashboard', icon: Icons.dashboard_outlined, route: '/dashboard'),
  NavItemData(title: 'Employees', icon: Icons.people_outline, route: '/employees'),
  NavItemData(title: 'Attendance', icon: Icons.access_time_outlined, route: '/attendance'),
  NavItemData(title: 'Leave', icon: Icons.event_note_outlined, route: '/leave'),
  NavItemData(title: 'Payroll', icon: Icons.payments_outlined, route: '/payroll'),
  NavItemData(title: 'Documents', icon: Icons.folder_open_outlined, route: '/documents'),
  NavItemData(title: 'Reports', icon: Icons.bar_chart_outlined, route: '/reports'),
  NavItemData(title: 'Analytics', icon: Icons.insights_outlined, route: '/analytics'),
  NavItemData(title: 'Notifications', icon: Icons.notifications_none_outlined, route: '/notifications'),
  NavItemData(title: 'Settings', icon: Icons.settings_outlined, route: '/settings'),
  NavItemData(title: 'Design System', icon: Icons.palette_outlined, route: '/design-system'),
];

/// Collapsible responsive navigation sidebar for Dayflow application shell.
class AppSidebar extends StatelessWidget {
  final bool isCollapsed;
  final VoidCallback onToggleCollapse;
  final String currentRoute;

  const AppSidebar({
    super.key,
    required this.isCollapsed,
    required this.onToggleCollapse,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = isCollapsed ? 72.0 : 240.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: width,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border(
          right: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
      ),
      child: Column(
        children: [
          // Branding Header
          Container(
            height: 64.0,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: AppRadius.borderMd,
                  ),
                  child: const Center(
                    child: Text(
                      'D',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                if (!isCollapsed) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Dayflow',
                    style: AppTypography.sectionHeading.copyWith(
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 1),
          // Nav Items List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              itemCount: kAppNavItems.length,
              itemBuilder: (context, index) {
                final item = kAppNavItems[index];
                final isSelected = currentRoute.startsWith(item.route);

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                    vertical: 2.0,
                  ),
                  child: Tooltip(
                    message: isCollapsed ? item.title : '',
                    child: InkWell(
                      onTap: () => context.go(item.route),
                      borderRadius: AppRadius.borderMd,
                      child: Container(
                        height: 40.0,
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withOpacity(0.12)
                              : Colors.transparent,
                          borderRadius: AppRadius.borderMd,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              item.icon,
                              size: 20,
                              color: isSelected
                                  ? AppColors.primary
                                  : (isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary),
                            ),
                            if (!isCollapsed) ...[
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  item.title,
                                  style: AppTypography.label.copyWith(
                                    color: isSelected
                                        ? AppColors.primary
                                        : (isDark
                                            ? AppColors.darkTextPrimary
                                            : AppColors.lightTextPrimary),
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Collapse Toggle Button
          const Divider(height: 1),
          IconButton(
            icon: Icon(
              isCollapsed ? Icons.chevron_right : Icons.chevron_left,
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            ),
            onPressed: onToggleCollapse,
          ),
        ],
      ),
    );
  }
}
