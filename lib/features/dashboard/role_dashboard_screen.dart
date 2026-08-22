import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/analytics/analytics_engine.dart';
import '../../core/analytics/analytics_repository.dart';
import '../../core/auth/app_role.dart';
import '../../core/auth/auth_notifier.dart';
import '../../core/components/app_avatar.dart';
import '../../core/components/app_badge.dart';
import '../../core/components/app_button.dart';
import '../../core/components/app_card.dart';
import '../../core/employee/employee.dart';
import '../../core/employee/employee_repository.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

/// Production-grade Dual Role Dashboard conforming directly to Dayflow HRMS specifications.
/// Provides tailored views: Admin/HR Officer Dashboard (3.2.2) and Employee Dashboard (3.2.1).
class RoleDashboardScreen extends ConsumerStatefulWidget {
  const RoleDashboardScreen({super.key});

  @override
  ConsumerState<RoleDashboardScreen> createState() => _RoleDashboardScreenState();
}

class _RoleDashboardScreenState extends ConsumerState<RoleDashboardScreen> {
  final _analyticsRepo = AnalyticsRepository();
  final _employeeRepo = EmployeeRepository();

  WorkforceMetrics? _workforce;
  AttendanceMetrics? _attendance;
  LeaveMetrics? _leave;
  PayrollMetrics? _payroll;
  List<Employee> _recentEmployees = [];
  bool _isLoading = true;
  String? _loadedOrgId;

  @override
  void initState() {
    super.initState();
    _checkAndLoad();
  }

  void _checkAndLoad() {
    final session = ref.read(authNotifierProvider).state;
    final orgId = session.activeOrganization?.id;
    if (orgId != null) {
      _loadMetricsForOrg(orgId);
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMetricsForOrg(String orgId) async {
    _loadedOrgId = orgId;
    if (mounted) setState(() => _isLoading = true);
    try {
      final wf = await _analyticsRepo.getWorkforceMetrics(orgId);
      final att = await _analyticsRepo.getAttendanceMetrics(orgId);
      final lv = await _analyticsRepo.getLeaveMetrics(orgId);
      final pr = await _analyticsRepo.getPayrollMetrics(orgId);
      final emps = await _employeeRepo.getEmployees(orgId, limit: 5);

      if (mounted) {
        setState(() {
          _workforce = wf;
          _attendance = att;
          _leave = lv;
          _payroll = pr;
          _recentEmployees = emps;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(authNotifierProvider).state;
    final orgId = session.activeOrganization?.id;

    if (orgId != null && orgId != _loadedOrgId && !_isLoading) {
      Future.microtask(() => _loadMetricsForOrg(orgId));
    } else if (orgId == null && _isLoading) {
      Future.microtask(() {
        if (mounted && _isLoading) setState(() => _isLoading = false);
      });
    }

    final role = session.activeMembership?.role;
    final isAdminOrHR = role == AppRole.organizationOwner ||
        role == AppRole.admin ||
        role == AppRole.hr ||
        role == AppRole.hrManager;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dynamic Header with Organization Context
          _buildHeader(session, isAdminOrHR),
          const SizedBox(height: AppSpacing.lg),

          if (isAdminOrHR)
            _buildAdminDashboard(context)
          else
            _buildEmployeeDashboard(context, session),
        ],
      ),
    );
  }

  Widget _buildHeader(AuthSessionState session, bool isAdminOrHR) {
    final userName = session.user?.displayName ?? 'User';
    final orgName = session.activeOrganization?.name ?? 'Dayflow Workspace';
    final roleName = session.activeMembership?.role.name.toUpperCase() ?? 'MEMBER';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back, $userName 👋',
              style: AppTypography.pageTitle,
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              '$orgName • Role: $roleName',
              style: AppTypography.bodySmall,
            ),
          ],
        ),
        AppStatusBadge(
          label: isAdminOrHR ? 'HR / ADMIN WORKSPACE' : 'EMPLOYEE WORKSPACE',
          variant: isAdminOrHR ? AppBadgeVariant.info : AppBadgeVariant.success,
        ),
      ],
    );
  }

  /// 3.2.2 Admin / HR Dashboard
  Widget _buildAdminDashboard(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Level KPI Metrics
        Row(
          children: [
            Expanded(
              child: AppStatCard(
                title: 'Total Workforce',
                value: '${_workforce?.totalEmployees ?? 0}',
                icon: Icons.people_outline,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppStatCard(
                title: 'Attendance Rate',
                value: '${_attendance?.attendancePercentage ?? 0}%',
                icon: Icons.fact_check_outlined,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppStatCard(
                title: 'Pending Leaves',
                value: '${_leave?.pendingCount ?? 0}',
                icon: Icons.pending_actions,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppStatCard(
                title: 'Total Payroll',
                value: '₹${(_payroll?.totalGrossPay ?? 0).toStringAsFixed(0)}',
                icon: Icons.account_balance_wallet_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),

        // Quick Administrative Actions
        Text('Quick Operational Actions', style: AppTypography.sectionHeading),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                title: 'Employees Directory',
                subtitle: 'Manage profiles & onboarding',
                icon: Icons.badge_outlined,
                color: AppColors.primary,
                onTap: () => context.go('/employees'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _QuickActionCard(
                title: 'Attendance Engine',
                subtitle: 'Workforce shifts & records',
                icon: Icons.schedule_outlined,
                color: AppColors.info,
                onTap: () => context.go('/attendance/manage'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _QuickActionCard(
                title: 'Leave Approvals',
                subtitle: '${_leave?.pendingCount ?? 0} requests awaiting review',
                icon: Icons.event_note_outlined,
                color: AppColors.warning,
                onTap: () => context.go('/leave/approvals'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _QuickActionCard(
                title: 'Payroll Control',
                subtitle: 'Process periods & publish slips',
                icon: Icons.payments_outlined,
                color: AppColors.success,
                onTap: () => context.go('/payroll/manage'),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),

        // Operational Detail Cards
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Today's Live Attendance Breakdown
            Expanded(
              flex: 1,
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Today\'s Attendance Breakdown', style: AppTypography.sectionHeading),
                    const SizedBox(height: AppSpacing.md),
                    _MetricRow('Present Today', '${_attendance?.presentCount ?? 0}'),
                    _MetricRow('Late Arrivals', '${_attendance?.lateCount ?? 0}'),
                    _MetricRow('On Approved Leave', '${_attendance?.leaveCount ?? 0}'),
                    _MetricRow('Average Worked Hours', '${_attendance?.averageWorkedHours ?? 0} hrs'),
                    const SizedBox(height: AppSpacing.md),
                    AppButton.secondary(
                      label: 'View Detailed Attendance',
                      size: AppButtonSize.small,
                      icon: Icons.arrow_forward,
                      onPressed: () => context.go('/attendance/manage'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),

            // Employee Quick Roster & Switcher
            Expanded(
              flex: 1,
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Recent Employee Roster', style: AppTypography.sectionHeading),
                        AppButton.text(
                          label: 'View All',
                          size: AppButtonSize.small,
                          onPressed: () => context.go('/employees'),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (_recentEmployees.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                        child: Text('No employees registered yet.'),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _recentEmployees.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final emp = _recentEmployees[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: AppAvatar(name: emp.fullName, size: AppAvatarSize.small),
                            title: Text(emp.fullName, style: AppTypography.label),
                            subtitle: Text('${emp.employeeId} • ${emp.employmentType}'),
                            trailing: const Icon(Icons.chevron_right, size: 18),
                            onTap: () => context.go('/employees/${emp.id}'),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 3.2.1 Employee Dashboard
  Widget _buildEmployeeDashboard(BuildContext context, AuthSessionState session) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Quick Access Cards for Employee (PDF 3.2.1: Profile, Attendance, Leave Requests, Logout)
        Text('Quick Access Navigation', style: AppTypography.sectionHeading),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                title: 'My Profile',
                subtitle: 'Personal & job details',
                icon: Icons.person_outline,
                color: AppColors.primary,
                onTap: () => context.go('/employees'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _QuickActionCard(
                title: 'My Attendance',
                subtitle: 'Daily check-in / out',
                icon: Icons.timer_outlined,
                color: AppColors.info,
                onTap: () => context.go('/attendance'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _QuickActionCard(
                title: 'Leave Requests',
                subtitle: 'Apply & check status',
                icon: Icons.event_available_outlined,
                color: AppColors.warning,
                onTap: () => context.go('/leave'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _QuickActionCard(
                title: 'Salary & Payslips',
                subtitle: 'Monthly compensation',
                icon: Icons.receipt_long_outlined,
                color: AppColors.success,
                onTap: () => context.go('/payroll'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _QuickActionCard(
                title: 'Logout',
                subtitle: 'End current session',
                icon: Icons.logout,
                color: AppColors.error,
                onTap: () => ref.read(authNotifierProvider).signOut(),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),

        // Recent Activity & Status Cards
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Today\'s Shift & Check-In', style: AppTypography.sectionHeading),
                    const SizedBox(height: AppSpacing.md),
                    _MetricRow('Assigned Shift', 'Standard (09:00 - 17:00)'),
                    _MetricRow('Grace Period', '15 minutes'),
                    _MetricRow('Work Policy', 'Full Time • On-site / Remote'),
                    const SizedBox(height: AppSpacing.md),
                    AppButton(
                      label: 'Open Attendance Tracker',
                      icon: Icons.punch_clock,
                      size: AppButtonSize.small,
                      onPressed: () => context.go('/attendance'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              flex: 1,
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Leave & Time-Off Balance Summary', style: AppTypography.sectionHeading),
                    const SizedBox(height: AppSpacing.md),
                    _MetricRow('Paid Annual Leave', '15.0 days available'),
                    _MetricRow('Sick Leave', '10.0 days available'),
                    _MetricRow('Unpaid Leave', 'Available on request'),
                    const SizedBox(height: AppSpacing.md),
                    AppButton.secondary(
                      label: 'Apply for Leave',
                      icon: Icons.add,
                      size: AppButtonSize.small,
                      onPressed: () => context.go('/leave'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xs),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(title, style: AppTypography.label),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: AppTypography.caption.copyWith(
                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  final String label;
  final String value;
  const _MetricRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodySmall),
          Text(value, style: AppTypography.label),
        ],
      ),
    );
  }
}
