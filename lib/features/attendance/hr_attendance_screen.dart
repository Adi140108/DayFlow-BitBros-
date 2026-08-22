import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/attendance/attendance_correction.dart';
import '../../core/attendance/attendance_record.dart';
import '../../core/attendance/attendance_repository.dart';
import '../../core/auth/auth_notifier.dart';
import '../../core/components/app_badge.dart';
import '../../core/components/app_button.dart';
import '../../core/components/app_card.dart';
import '../../core/components/app_feedback.dart';
import '../../core/components/app_table.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

class HRAttendanceScreen extends ConsumerStatefulWidget {
  const HRAttendanceScreen({super.key});

  @override
  ConsumerState<HRAttendanceScreen> createState() => _HRAttendanceScreenState();
}

class _HRAttendanceScreenState extends ConsumerState<HRAttendanceScreen> {
  final _repo = AttendanceRepository();
  List<AttendanceRecord> _records = [];
  List<AttendanceCorrection> _pendingCorrections = [];
  bool _isLoading = true;
  int _activeTab = 0; // 0 = Records, 1 = Corrections Review

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final session = ref.read(authNotifierProvider).state;
    if (session.activeOrganization == null) return;

    setState(() => _isLoading = true);
    try {
      final records = await _repo.getOrganizationAttendance(session.activeOrganization!.id);
      final corrections = await _repo.getPendingCorrections(session.activeOrganization!.id);

      setState(() {
        _records = records;
        _pendingCorrections = corrections;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final presentCount = _records.where((r) => r.status == 'present').length;
    final halfDayCount = _records.where((r) => r.status == 'half_day').length;
    final lateCount = _records.where((r) => r.isLate).length;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Workforce Attendance Engine', style: AppTypography.pageTitle),
          const SizedBox(height: AppSpacing.md),

          // Overview Stats Grid
          Row(
            children: [
              Expanded(
                child: AppStatCard(
                  title: 'Present Today',
                  value: '$presentCount',
                  icon: Icons.check_circle_outline,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppStatCard(
                  title: 'Half Day',
                  value: '$halfDayCount',
                  icon: Icons.hourglass_bottom,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppStatCard(
                  title: 'Late Arrivals',
                  value: '$lateCount',
                  icon: Icons.access_time,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppStatCard(
                  title: 'Pending Corrections',
                  value: '${_pendingCorrections.length}',
                  icon: Icons.edit_calendar,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          // Navigation Tabs
          Row(
            children: [
              AppButton(
                label: 'All Attendance Logs',
                variant: _activeTab == 0 ? AppButtonVariant.primary : AppButtonVariant.secondary,
                size: AppButtonSize.small,
                onPressed: () => setState(() => _activeTab = 0),
              ),
              const SizedBox(width: AppSpacing.sm),
              AppButton(
                label: 'Pending Corrections (${_pendingCorrections.length})',
                variant: _activeTab == 1 ? AppButtonVariant.primary : AppButtonVariant.secondary,
                size: AppButtonSize.small,
                onPressed: () => setState(() => _activeTab = 1),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Tab Content
          if (_activeTab == 0) ...[
            if (_records.isEmpty)
              const AppEmptyState(
                title: 'No Attendance Records Found',
                description: 'No employee check-ins recorded for today.',
              )
            else
              AppTable(
                columns: const [
                  AppTableColumn(title: 'Employee ID', width: 120),
                  AppTableColumn(title: 'Date', width: 110),
                  AppTableColumn(title: 'Check In', width: 100),
                  AppTableColumn(title: 'Check Out', width: 100),
                  AppTableColumn(title: 'Worked', width: 90),
                  AppTableColumn(title: 'Status', width: 110),
                ],
                rows: _records.map((rec) {
                  return [
                    Text(rec.employeeId, style: AppTypography.label),
                    Text(rec.attendanceDate, style: AppTypography.bodySmall),
                    Text(rec.checkInAt != null ? _formatTime(rec.checkInAt!) : '--:--', style: AppTypography.bodySmall),
                    Text(rec.checkOutAt != null ? _formatTime(rec.checkOutAt!) : '--:--', style: AppTypography.bodySmall),
                    Text('${rec.totalWorkedMinutes}m', style: AppTypography.bodySmall),
                    AppStatusBadge(
                      label: rec.status.toUpperCase(),
                      variant: rec.status == 'present'
                          ? AppBadgeVariant.success
                          : AppBadgeVariant.neutral,
                    ),
                  ];
                }).toList(),
              ),
          ] else ...[
            if (_pendingCorrections.isEmpty)
              const AppEmptyState(
                title: 'No Pending Corrections',
                description: 'All employee attendance correction requests have been reviewed.',
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _pendingCorrections.length,
                separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final corr = _pendingCorrections[index];
                  return AppCard(
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Date: ${corr.attendanceDate}', style: AppTypography.label),
                              Text('Requested: ${corr.requestedCheckIn} -> ${corr.requestedCheckOut}', style: AppTypography.bodySmall),
                              Text(
                                'Reason: ${corr.reason}',
                                style: AppTypography.caption.copyWith(
                                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            AppButton(
                              label: 'Approve',
                              size: AppButtonSize.small,
                              onPressed: () => _review(corr.id, true),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            AppButton.destructive(
                              label: 'Reject',
                              size: AppButtonSize.small,
                              onPressed: () => _review(corr.id, false),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ],
      ),
    );
  }

  String _formatTime(String isoString) {
    final dt = DateTime.parse(isoString);
    return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  Future<void> _review(String correctionId, bool approve) async {
    final session = ref.read(authNotifierProvider).state;
    try {
      await _repo.reviewCorrection(
        correctionId: correctionId,
        reviewerId: session.user!.uid,
        approve: approve,
      );
      await _loadData();
    } catch (e) {
      // Error handling
    }
  }
}
