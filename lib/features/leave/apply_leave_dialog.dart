import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/auth/auth_notifier.dart';
import '../../core/components/app_button.dart';
import '../../core/components/app_select.dart';
import '../../core/components/app_text_field.dart';
import '../../core/leave/leave_repository.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

class ApplyLeaveDialog extends ConsumerStatefulWidget {
  const ApplyLeaveDialog({super.key});

  @override
  ConsumerState<ApplyLeaveDialog> createState() => _ApplyLeaveDialogState();
}

class _ApplyLeaveDialogState extends ConsumerState<ApplyLeaveDialog> {
  final _remarksController = TextEditingController();
  String _leaveTypeId = 'paid';
  DateTime _startDate = DateTime.now().add(const Duration(days: 1));
  DateTime _endDate = DateTime.now().add(const Duration(days: 1));
  bool _isHalfDay = false;
  bool _isLoading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderLg),
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Apply for Leave', style: AppTypography.sectionHeading),
              const SizedBox(height: AppSpacing.md),
              AppDropdown<String>(
                label: 'Leave Type',
                value: _leaveTypeId,
                items: const [
                  DropdownMenuItem(value: 'paid', child: Text('Paid Leave (PL)')),
                  DropdownMenuItem(value: 'sick', child: Text('Sick Leave (SL)')),
                  DropdownMenuItem(value: 'unpaid', child: Text('Unpaid Leave (UL)')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _leaveTypeId = val);
                },
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _startDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          setState(() {
                            _startDate = picked;
                            if (_endDate.isBefore(_startDate)) _endDate = _startDate;
                          });
                        }
                      },
                      child: Text('Start: ${_formatDate(_startDate)}'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _endDate,
                          firstDate: _startDate,
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) setState(() => _endDate = picked);
                      },
                      child: Text('End: ${_formatDate(_endDate)}'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Apply as Half Day'),
                value: _isHalfDay,
                onChanged: (val) => setState(() => _isHalfDay = val ?? false),
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: 'Remarks / Reason (Required)',
                hintText: 'Family commitment / Medical appointment',
                controller: _remarksController,
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
                    label: 'Submit Leave Request',
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

  String _formatDate(DateTime dt) => "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";

  Future<void> _submit() async {
    final remarks = _remarksController.text.trim();
    if (remarks.isEmpty) {
      setState(() => _error = 'Please enter remarks for your leave application.');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final session = ref.read(authNotifierProvider).state;
      final repo = LeaveRepository();

      await repo.submitLeaveRequest(
        organizationId: session.activeOrganization!.id,
        employeeId: session.user!.uid,
        leaveTypeId: _leaveTypeId,
        startDate: _startDate,
        endDate: _endDate,
        isHalfDay: _isHalfDay,
        remarks: remarks,
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
