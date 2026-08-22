import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/attendance/attendance_correction.dart';
import '../../core/attendance/attendance_record.dart';
import '../../core/attendance/attendance_repository.dart';
import '../../core/attendance/schedule_repository.dart';
import '../../core/attendance/shift.dart';
import '../../core/auth/auth_notifier.dart';
import '../../core/components/app_badge.dart';
import '../../core/components/app_button.dart';
import '../../core/components/app_card.dart';
import '../../core/components/app_feedback.dart';
import '../../core/components/app_table.dart';
import '../../core/components/app_text_field.dart';
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
  final _scheduleRepo = ScheduleRepository();

  List<AttendanceRecord> _records = [];
  List<AttendanceCorrection> _pendingCorrections = [];
  List<Shift> _shifts = [];
  bool _isLoading = true;
  int _activeTab = 0; // 0 = Records, 1 = Corrections Review, 2 = Specific Work Timing Config

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
      final shifts = await _scheduleRepo.getShifts(session.activeOrganization!.id);

      setState(() {
        _records = records;
        _pendingCorrections = corrections;
        _shifts = shifts;
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Workforce Attendance & Shifts', style: AppTypography.pageTitle),
              if (_activeTab == 2)
                AppButton(
                  label: 'Define Specific Shift Time',
                  icon: Icons.add_alarm,
                  size: AppButtonSize.small,
                  onPressed: () => _showShiftDialog(),
                ),
            ],
          ),
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
              const SizedBox(width: AppSpacing.sm),
              AppButton(
                label: 'Specific Work Time & Shifts (${_shifts.length})',
                variant: _activeTab == 2 ? AppButtonVariant.primary : AppButtonVariant.secondary,
                size: AppButtonSize.small,
                onPressed: () => setState(() => _activeTab = 2),
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
          ] else if (_activeTab == 1) ...[
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
          ] else ...[
            // Tab 2: Specific Shift Timings Configuration (PDF Requirement 4)
            if (_shifts.isEmpty)
              AppEmptyState(
                title: 'No Specific Shifts Defined',
                description: 'Define specific working hours, shift start/end times and grace periods for your institute or organization.',
                actionLabel: 'Define First Shift',
                onAction: () => _showShiftDialog(),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _shifts.length,
                separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, index) {
                  final shift = _shifts[index];
                  final isActive = shift.status == 'active';
                  return AppCard(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.success.withValues(alpha: 0.1)
                                : AppColors.lightDivider,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.schedule,
                            color: isActive ? AppColors.success : AppColors.lightTextMuted,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(shift.name, style: AppTypography.sectionHeading),
                                  const SizedBox(width: AppSpacing.sm),
                                  AppStatusBadge(
                                    label: isActive ? 'ACTIVE DEFAULT' : 'INACTIVE',
                                    variant: isActive ? AppBadgeVariant.success : AppBadgeVariant.neutral,
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.xxs),
                              Text(
                                'Working Hours: ${shift.startTime} to ${shift.endTime} • Grace Period: ${shift.gracePeriodMinutes} mins ${shift.isOvernight ? '• (Overnight Shift)' : ''}',
                                style: AppTypography.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            if (!isActive)
                              AppButton.secondary(
                                label: 'Set as Active',
                                size: AppButtonSize.small,
                                onPressed: () async {
                                  final updated = shift.copyWith(status: 'active');
                                  await _scheduleRepo.createShift(updated);
                                  _loadData();
                                },
                              ),
                            const SizedBox(width: AppSpacing.xs),
                            AppButton(
                              label: 'Edit Timing',
                              icon: Icons.edit,
                              size: AppButtonSize.small,
                              onPressed: () => _showShiftDialog(shift: shift),
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

  Future<void> _showShiftDialog({Shift? shift}) async {
    final nameCtrl = TextEditingController(text: shift?.name ?? 'General Working Shift');
    final startCtrl = TextEditingController(text: shift?.startTime ?? '09:00');
    final endCtrl = TextEditingController(text: shift?.endTime ?? '17:00');
    final graceCtrl = TextEditingController(text: (shift?.gracePeriodMinutes ?? 15).toString());
    bool isOvernight = shift?.isOvernight ?? false;
    bool isActive = shift?.status == 'active' || shift == null;
    bool isSaving = false;
    String? error;

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(shift == null ? 'Define Specific Work Timing' : 'Edit Shift Timing'),
              content: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppTextField(
                      label: 'Shift / Department Name *',
                      hintText: 'e.g. Morning Shift / Academic Faculty Hours',
                      controller: nameCtrl,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            label: 'Start Time (HH:MM) *',
                            hintText: '09:00',
                            controller: startCtrl,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: AppTextField(
                            label: 'End Time (HH:MM) *',
                            hintText: '17:00',
                            controller: endCtrl,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      label: 'Allowed Grace Period (Minutes)',
                      hintText: '15',
                      controller: graceCtrl,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Overnight / Cross-Midnight Shift'),
                      value: isOvernight,
                      onChanged: (v) => setDialogState(() => isOvernight = v ?? false),
                    ),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Set as Active Default Schedule for Organization'),
                      value: isActive,
                      onChanged: (v) => setDialogState(() => isActive = v ?? true),
                    ),
                    if (error != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(error!, style: AppTypography.caption.copyWith(color: AppColors.error)),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          final name = nameCtrl.text.trim();
                          final start = startCtrl.text.trim();
                          final end = endCtrl.text.trim();
                          final grace = int.tryParse(graceCtrl.text.trim()) ?? 15;

                          if (name.isEmpty || start.isEmpty || end.isEmpty) {
                            setDialogState(() => error = 'Please enter shift name, start time and end time.');
                            return;
                          }

                          setDialogState(() {
                            isSaving = true;
                            error = null;
                          });

                          try {
                            final session = ref.read(authNotifierProvider).state;
                            final toSave = Shift(
                              id: shift?.id ?? '',
                              organizationId: session.activeOrganization!.id,
                              name: name,
                              startTime: start,
                              endTime: end,
                              gracePeriodMinutes: grace,
                              isOvernight: isOvernight,
                              status: isActive ? 'active' : 'inactive',
                            );

                            final messenger = ScaffoldMessenger.of(context);
                            final nav = Navigator.of(ctx);
                            await _scheduleRepo.createShift(toSave);
                            nav.pop();
                            if (mounted) {
                              _loadData();
                              messenger.showSnackBar(
                                const SnackBar(content: Text('Specific working time configuration saved successfully.')),
                              );
                            }
                          } catch (e) {
                            setDialogState(() {
                              error = e.toString();
                              isSaving = false;
                            });
                          }
                        },
                  child: isSaving
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Save Timing'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
