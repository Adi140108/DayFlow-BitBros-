import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/attendance/attendance_record.dart';
import '../../core/attendance/attendance_repository.dart';
import '../../core/auth/auth_notifier.dart';
import '../../core/components/app_button.dart';
import '../../core/components/app_text_field.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

class CorrectionRequestDialog extends ConsumerStatefulWidget {
  final AttendanceRecord record;

  const CorrectionRequestDialog({super.key, required this.record});

  @override
  ConsumerState<CorrectionRequestDialog> createState() => _CorrectionRequestDialogState();
}

class _CorrectionRequestDialogState extends ConsumerState<CorrectionRequestDialog> {
  final _checkInController = TextEditingController();
  final _checkOutController = TextEditingController();
  final _reasonController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkInController.text = widget.record.checkInAt ?? '09:00';
    _checkOutController.text = widget.record.checkOutAt ?? '17:00';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderLg),
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Request Attendance Correction', style: AppTypography.sectionHeading),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Date: ${widget.record.attendanceDate}',
                style: AppTypography.bodySmall.copyWith(
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: 'Corrected Check-In Time',
                hintText: 'YYYY-MM-DDTHH:MM:SS',
                controller: _checkInController,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: 'Corrected Check-Out Time',
                hintText: 'YYYY-MM-DDTHH:MM:SS',
                controller: _checkOutController,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: 'Reason for Adjustment (Required)',
                hintText: 'Forgot to check out due to external meeting',
                controller: _reasonController,
                maxLines: 2,
              ),
              if (_error != null) ...[
                const SizedBox(height: AppSpacing.md),
                Text(_error!, style: AppTypography.caption.copyWith(color: AppColors.error)),
              ],
              const SizedBox(height: AppSpacing.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppButton.secondary(
                    label: 'Cancel',
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  AppButton(
                    label: 'Submit Request',
                    isLoading: _isLoading,
                    onPressed: _submit,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final reason = _reasonController.text.trim();
    if (reason.isEmpty) {
      setState(() => _error = 'Please provide a reason for the correction.');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final session = ref.read(authNotifierProvider).state;
      final repo = AttendanceRepository();

      await repo.requestCorrection(
        organizationId: session.activeOrganization!.id,
        employeeId: widget.record.employeeId,
        attendanceId: widget.record.id,
        attendanceDate: widget.record.attendanceDate,
        originalCheckIn: widget.record.checkInAt,
        originalCheckOut: widget.record.checkOutAt,
        requestedCheckIn: _checkInController.text.trim(),
        requestedCheckOut: _checkOutController.text.trim(),
        reason: reason,
        requesterId: session.user!.uid,
      );

      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }
}
