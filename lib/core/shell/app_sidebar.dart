import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../auth/app_role.dart';
import '../auth/auth_notifier.dart';
import '../components/app_logo.dart';
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

/// Collapsible role-aware responsive navigation sidebar for Dayflow.
class AppSidebar extends ConsumerWidget {
  final bool isCollapsed;
  final VoidCallback onToggleCollapse;
  final String currentRoute;

  const AppSidebar({
    super.key,
    required this.isCollapsed,
    required this.onToggleCollapse,
    required this.currentRoute,
  });

  List<NavItemData> _getNavItemsForRole(AppRole? role) {
    if (role == AppRole.organizationOwner || role == AppRole.admin) {
      return const [
        NavItemData(title: 'Dashboard', icon: Icons.dashboard_outlined, route: '/dashboard'),
        NavItemData(title: 'Employees', icon: Icons.people_outline, route: '/employees'),
        NavItemData(title: 'Attendance', icon: Icons.access_time_outlined, route: '/attendance/manage'),
        NavItemData(title: 'Leave Approvals', icon: Icons.approval_outlined, route: '/leave/approvals'),
        NavItemData(title: 'Payroll Control', icon: Icons.payments_outlined, route: '/payroll/manage'),
        NavItemData(title: 'Reports & Exports', icon: Icons.bar_chart_outlined, route: '/reports'),
      ];
    } else if (role == AppRole.hrManager || role == AppRole.hr) {
      return const [
        NavItemData(title: 'Dashboard', icon: Icons.dashboard_outlined, route: '/dashboard'),
        NavItemData(title: 'Employees', icon: Icons.people_outline, route: '/employees'),
        NavItemData(title: 'Attendance', icon: Icons.access_time_outlined, route: '/attendance/manage'),
        NavItemData(title: 'Leave Approvals', icon: Icons.approval_outlined, route: '/leave/approvals'),
        NavItemData(title: 'Payroll Control', icon: Icons.payments_outlined, route: '/payroll/manage'),
        NavItemData(title: 'Reports & Exports', icon: Icons.bar_chart_outlined, route: '/reports'),
      ];
    } else {
      // Default: Employee Role
      return const [
        NavItemData(title: 'Dashboard', icon: Icons.dashboard_outlined, route: '/dashboard'),
        NavItemData(title: 'My Attendance', icon: Icons.access_time_outlined, route: '/attendance'),
        NavItemData(title: 'Leave & Time-Off', icon: Icons.event_note_outlined, route: '/leave'),
        NavItemData(title: 'My Payslips', icon: Icons.payments_outlined, route: '/payroll'),
      ];
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = isCollapsed ? 72.0 : 240.0;
    final session = ref.watch(authNotifierProvider).state;
    final navItems = _getNavItemsForRole(session.activeRole);

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
          // Branding Header with unified DayflowLogo
          Container(
            height: 64.0,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                DayflowLogo(
                  size: DayflowLogoSize.small,
                  showText: !isCollapsed,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Nav Items List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              itemCount: navItems.length,
              itemBuilder: (context, index) {
                final item = navItems[index];
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
                              ? AppColors.primary.withValues(alpha: 0.12)
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
