import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/analytics/analytics_engine.dart';
import '../../core/analytics/analytics_repository.dart';
import '../../core/auth/auth_notifier.dart';
import '../../core/components/app_card.dart';
import '../../core/auth/app_role.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

class RoleDashboardScreen extends ConsumerStatefulWidget {
  const RoleDashboardScreen({super.key});

  @override
  ConsumerState<RoleDashboardScreen> createState() => _RoleDashboardScreenState();
}

class _RoleDashboardScreenState extends ConsumerState<RoleDashboardScreen> {
  final _analyticsRepo = AnalyticsRepository();
  WorkforceMetrics? _workforce;
  AttendanceMetrics? _attendance;
  LeaveMetrics? _leave;
  PayrollMetrics? _payroll;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMetrics();
  }

  Future<void> _loadMetrics() async {
    final session = ref.read(authNotifierProvider).state;
    if (session.activeOrganization == null) return;

    setState(() => _isLoading = true);
    try {
      final orgId = session.activeOrganization!.id;
      final wf = await _analyticsRepo.getWorkforceMetrics(orgId);
      final att = await _analyticsRepo.getAttendanceMetrics(orgId);
      final lv = await _analyticsRepo.getLeaveMetrics(orgId);
      final pr = await _analyticsRepo.getPayrollMetrics(orgId);

      setState(() {
        _workforce = wf;
        _attendance = att;
        _leave = lv;
        _payroll = pr;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(authNotifierProvider).state;
    final role = session.activeMembership?.role;
    final isOwnerOrHR = role == AppRole.organizationOwner || role == AppRole.admin || role == AppRole.hr || role == AppRole.hrManager;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Dashboard & Operational Analytics', style: AppTypography.pageTitle),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    'Real-time organization metrics and workforce performance metrics.',
                    style: AppTypography.bodySmall,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Workforce & Attendance Overview Cards
          Row(
            children: [
              Expanded(
                child: AppStatCard(
                  title: 'Active Employees',
                  value: '${_workforce?.activeEmployees ?? 0}',
                  icon: Icons.people_outline,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppStatCard(
                  title: 'Attendance Rate',
                  value: '${_attendance?.attendancePercentage ?? 0}%',
                  icon: Icons.check_circle_outline,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppStatCard(
                  title: 'Pending Leave',
                  value: '${_leave?.pendingCount ?? 0}',
                  icon: Icons.pending_actions,
                ),
              ),
              if (isOwnerOrHR) ...[
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppStatCard(
                    title: 'Gross Payroll',
                    value: '₹${(_payroll?.totalGrossPay ?? 0).toStringAsFixed(0)}',
                    icon: Icons.account_balance_wallet_outlined,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          // Department & Attendance Details
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Workforce by Status', style: AppTypography.sectionHeading),
                      const SizedBox(height: AppSpacing.md),
                      _MetricRow('Total Registered Employees', '${_workforce?.totalEmployees ?? 0}'),
                      _MetricRow('Active Status', '${_workforce?.activeEmployees ?? 0}'),
                      _MetricRow('Onboarding Status', '${_workforce?.onboardingEmployees ?? 0}'),
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
                      Text('Today\'s Attendance Summary', style: AppTypography.sectionHeading),
                      const SizedBox(height: AppSpacing.md),
                      _MetricRow('Present Count', '${_attendance?.presentCount ?? 0}'),
                      _MetricRow('Late Arrivals', '${_attendance?.lateCount ?? 0}'),
                      _MetricRow('Approved Leave', '${_attendance?.leaveCount ?? 0}'),
                      _MetricRow('Avg Worked Hours', '${_attendance?.averageWorkedHours ?? 0} hrs'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
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
