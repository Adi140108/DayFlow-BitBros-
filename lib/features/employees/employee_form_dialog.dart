import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/auth/auth_notifier.dart';
import '../../core/components/app_button.dart';
import '../../core/components/app_select.dart';
import '../../core/components/app_text_field.dart';
import '../../core/employee/employee.dart';
import '../../core/employee/employee_repository.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

/// Creation and Editing form dialog for Employee records.
class EmployeeFormDialog extends ConsumerStatefulWidget {
  final Employee? employee;

  const EmployeeFormDialog({super.key, this.employee});

  @override
  ConsumerState<EmployeeFormDialog> createState() => _EmployeeFormDialogState();
}

class _EmployeeFormDialogState extends ConsumerState<EmployeeFormDialog> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  String _employmentType = 'full_time';
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.employee != null) {
      _fullNameController.text = widget.employee!.fullName;
      _emailController.text = widget.employee!.email;
      _phoneController.text = widget.employee!.phone ?? '';
      _employmentType = widget.employee!.employmentType;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditing = widget.employee != null;

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
              Text(
                isEditing ? 'Edit Employee Record' : 'Add New Employee',
                style: AppTypography.sectionHeading,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: 'Full Name',
                hintText: 'John Doe',
                controller: _fullNameController,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: 'Work Email',
                hintText: 'john@company.com',
                controller: _emailController,
                readOnly: isEditing,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: 'Phone Number',
                hintText: '+1 555-0199',
                controller: _phoneController,
              ),
              const SizedBox(height: AppSpacing.md),
              AppDropdown<String>(
                label: 'Employment Type',
                value: _employmentType,
                items: const [
                  DropdownMenuItem(value: 'full_time', child: Text('Full Time')),
                  DropdownMenuItem(value: 'part_time', child: Text('Part Time')),
                  DropdownMenuItem(value: 'contract', child: Text('Contract')),
                  DropdownMenuItem(value: 'intern', child: Text('Intern')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _employmentType = val);
                },
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
                    label: isEditing ? 'Save Changes' : 'Create Employee',
                    isLoading: _isLoading,
                    onPressed: _save,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    final name = _fullNameController.text.trim();
    final email = _emailController.text.trim();

    if (name.isEmpty || email.isEmpty) {
      setState(() => _error = 'Name and email are required.');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final repo = EmployeeRepository();
      final notifier = ref.read(authNotifierProvider);
      final session = notifier.state;

      if (widget.employee != null) {
        final updated = widget.employee!.copyWith(
          fullName: name,
          phone: _phoneController.text.trim(),
          employmentType: _employmentType,
        );
        await repo.updateEmployee(updated);
      } else {
        await repo.createEmployee(
          organizationId: session.activeOrganization!.id,
          fullName: name,
          email: email,
          phone: _phoneController.text.trim(),
          employmentType: _employmentType,
        );
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }
}
