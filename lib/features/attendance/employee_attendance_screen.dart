import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import 'correction_request_dialog.dart';

class EmployeeAttendanceScreen extends ConsumerStatefulWidget {
  const EmployeeAttendanceScreen({super.key});

  @override
  ConsumerState<EmployeeAttendanceScreen> createState() => _EmployeeAttendanceScreenState();
}

class _EmployeeAttendanceScreenState extends ConsumerState<EmployeeAttendanceScreen> {
  final _attendanceRepo = AttendanceRepository();
  AttendanceRecord? _todayRecord;
  List<AttendanceRecord> _history = [];
  bool _isLoading = true;
  bool _isActionLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final session = ref.read(authNotifierProvider).state;
    if (session.user == null || session.activeOrganization == null) return;

    setState(() => _isLoading = true);
    try {
      final record = await _attendanceRepo.getTodayRecord(
        session.activeOrganization!.id,
        session.user!.uid,
      );
      final history = await _attendanceRepo.getAttendanceHistory(session.user!.uid);

      setState(() {
        _todayRecord = record;
        _history = history;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCheckedIn = _todayRecord?.checkInAt != null && _todayRecord?.checkOutAt == null;
    final isCheckedOut = _todayRecord?.checkInAt != null && _todayRecord?.checkOutAt != null;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('My Attendance Engine', style: AppTypography.pageTitle),
          const SizedBox(height: AppSpacing.md),

          // Check-In / Check-Out Action Card
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Today\'s Session', style: AppTypography.sectionHeading),
                        Text(
                          'Schedule: Standard Shift (09:00 - 17:00 • 15m Grace Period)',
                          style: AppTypography.bodySmall.copyWith(
                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                          ),
                        ),
                      ],
                    ),
                    AppStatusBadge(
                      label: isCheckedIn
                          ? 'ACTIVE SESSION'
                          : isCheckedOut
                              ? 'SHIFT COMPLETED'
                              : 'NOT CHECKED IN',
                      variant: isCheckedIn
                          ? AppBadgeVariant.success
                          : isCheckedOut
                              ? AppBadgeVariant.neutral
                              : AppBadgeVariant.warning,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                if (_error != null) ...[
                  Text(_error!, style: AppTypography.caption.copyWith(color: AppColors.error)),
                  const SizedBox(height: AppSpacing.md),
                ],
                Row(
                  children: [
                    if (!isCheckedIn && !isCheckedOut)
                      AppButton(
                        label: 'Check In Now',
                        icon: Icons.login,
                        isLoading: _isActionLoading,
                        onPressed: _handleCheckIn,
                      )
                    else if (isCheckedIn)
                      AppButton(
                        label: 'Check Out Now',
                        icon: Icons.logout,
                        isLoading: _isActionLoading,
                        onPressed: _handleCheckOut,
                      )
                    else
                      const AppStatusBadge.success(label: 'Checked Out for Today'),
                  ],
                ),
                if (_todayRecord != null) ...[
                  const SizedBox(height: AppSpacing.lg),
                  const Divider(),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMetric('Check In', _todayRecord!.checkInAt != null ? _formatTime(_todayRecord!.checkInAt!) : '--:--'),
                      _buildMetric('Check Out', _todayRecord!.checkOutAt != null ? _formatTime(_todayRecord!.checkOutAt!) : '--:--'),
                      _buildMetric('Worked', '${_todayRecord!.totalWorkedMinutes} mins'),
                      _buildMetric('Late Lateness', '${_todayRecord!.lateMinutes} mins'),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Historical Records Table
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Attendance History', style: AppTypography.sectionHeading),
              if (_todayRecord != null)
                AppButton.secondary(
                  label: 'Request Correction',
                  icon: Icons.edit_calendar,
                  size: AppButtonSize.small,
                  onPressed: () async {
                    final updated = await showDialog<bool>(
                      context: context,
                      builder: (context) => CorrectionRequestDialog(record: _todayRecord!),
                    );
                    if (updated == true) _loadData();
                  },
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (_history.isEmpty)
            const AppEmptyState(
              title: 'No Historical Attendance Records',
              description: 'Your check-in and check-out logs will appear here.',
            )
          else
            AppTable(
              columns: const [
                AppTableColumn(title: 'Date', width: 110),
                AppTableColumn(title: 'Check In', width: 100),
                AppTableColumn(title: 'Check Out', width: 100),
                AppTableColumn(title: 'Worked', width: 90),
                AppTableColumn(title: 'Late', width: 80),
                AppTableColumn(title: 'Status', width: 110),
              ],
              rows: _history.map((rec) {
                return [
                  Text(rec.attendanceDate, style: AppTypography.label),
                  Text(rec.checkInAt != null ? _formatTime(rec.checkInAt!) : '--:--', style: AppTypography.bodySmall),
                  Text(rec.checkOutAt != null ? _formatTime(rec.checkOutAt!) : '--:--', style: AppTypography.bodySmall),
                  Text('${rec.totalWorkedMinutes}m', style: AppTypography.bodySmall),
                  Text('${rec.lateMinutes}m', style: AppTypography.bodySmall),
                  AppStatusBadge(
                    label: rec.status.toUpperCase(),
                    variant: rec.status == 'present'
                        ? AppBadgeVariant.success
                        : AppBadgeVariant.neutral,
                  ),
                ];
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
          ),
        ),
        Text(value, style: AppTypography.label),
      ],
    );
  }

  String _formatTime(String isoString) {
    final dt = DateTime.parse(isoString);
    return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  Future<void> _handleCheckIn() async {
    final session = ref.read(authNotifierProvider).state;
    setState(() {
      _isActionLoading = true;
      _error = null;
    });

    try {
      await _attendanceRepo.checkIn(
        organizationId: session.activeOrganization!.id,
        employeeId: session.user!.uid,
      );
      await _loadData();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isActionLoading = false);
    }
  }

  Future<void> _handleCheckOut() async {
    final session = ref.read(authNotifierProvider).state;
    setState(() {
      _isActionLoading = true;
      _error = null;
    });

    try {
      await _attendanceRepo.checkOut(
        organizationId: session.activeOrganization!.id,
        employeeId: session.user!.uid,
      );
      await _loadData();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isActionLoading = false);
    }
  }
}
