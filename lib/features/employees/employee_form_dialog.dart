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

/// Creation and Comprehensive Editing form dialog for ALL Employee fields.
class EmployeeFormDialog extends ConsumerStatefulWidget {
  final Employee? employee;

  const EmployeeFormDialog({super.key, this.employee});

  @override
  ConsumerState<EmployeeFormDialog> createState() => _EmployeeFormDialogState();
}

class _EmployeeFormDialogState extends ConsumerState<EmployeeFormDialog> {
  // Personal Info Controllers
  final _fullNameController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();
  final _addressController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _avatarUrlController = TextEditingController();

  // Job & Org Info Controllers
  final _departmentController = TextEditingController();
  final _designationController = TextEditingController();
  final _locationController = TextEditingController();
  final _managerController = TextEditingController();
  final _joiningDateController = TextEditingController();

  String _gender = 'unspecified';
  String _employmentType = 'full_time';
  String _status = 'active';

  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.employee != null) {
      final e = widget.employee!;
      _fullNameController.text = e.fullName;
      _displayNameController.text = e.displayName ?? e.fullName;
      _emailController.text = e.email;
      _phoneController.text = e.phone ?? '';
      _dobController.text = e.dateOfBirth ?? '';
      _addressController.text = e.address ?? '';
      _emergencyContactController.text = e.emergencyContact ?? '';
      _avatarUrlController.text = e.avatarUrl ?? '';
      _departmentController.text = e.departmentId ?? '';
      _designationController.text = e.designationId ?? '';
      _locationController.text = e.locationId ?? '';
      _managerController.text = e.managerId ?? '';
      _joiningDateController.text = e.joiningDate ?? '';
      _gender = e.gender ?? 'unspecified';
      _employmentType = e.employmentType;
      _status = e.status;
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
        constraints: const BoxConstraints(maxWidth: 720, maxHeight: 750),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? 'Edit Full Employee Record' : 'Add New Employee',
                    style: AppTypography.sectionHeading,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section 1: Personal Details
                      Text('1. Personal Information', style: AppTypography.label.copyWith(color: AppColors.primary)),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              label: 'Full Name *',
                              hintText: 'Jane Doe',
                              controller: _fullNameController,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: AppTextField(
                              label: 'Display / Preferred Name',
                              hintText: 'Jane',
                              controller: _displayNameController,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              label: 'Work Email *',
                              hintText: 'jane@company.com',
                              controller: _emailController,
                              readOnly: isEditing,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: AppTextField(
                              label: 'Phone Number',
                              hintText: '+91 98765 43210',
                              controller: _phoneController,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              label: 'Date of Birth (YYYY-MM-DD)',
                              hintText: '1995-06-15',
                              controller: _dobController,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: AppDropdown<String>(
                              label: 'Gender',
                              value: _gender,
                              items: const [
                                DropdownMenuItem(value: 'unspecified', child: Text('Prefer not to say')),
                                DropdownMenuItem(value: 'female', child: Text('Female')),
                                DropdownMenuItem(value: 'male', child: Text('Male')),
                                DropdownMenuItem(value: 'other', child: Text('Other')),
                              ],
                              onChanged: (val) {
                                if (val != null) setState(() => _gender = val);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppTextField(
                        label: 'Residential Address',
                        hintText: 'Street address, City, Postal Code',
                        controller: _addressController,
                        maxLines: 2,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              label: 'Emergency Contact Info',
                              hintText: 'e.g. John Doe (+91 98765 43211)',
                              controller: _emergencyContactController,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: AppTextField(
                              label: 'Avatar / Profile Image URL',
                              hintText: 'https://...',
                              controller: _avatarUrlController,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Section 2: Job & Organization Details
                      Text('2. Job & Organizational Details', style: AppTypography.label.copyWith(color: AppColors.primary)),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              label: 'Department',
                              hintText: 'e.g. Engineering, Sales, HR',
                              controller: _departmentController,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: AppTextField(
                              label: 'Designation / Job Title',
                              hintText: 'e.g. Senior Software Engineer',
                              controller: _designationController,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              label: 'Work Location / Office',
                              hintText: 'e.g. Bangalore Campus / Remote',
                              controller: _locationController,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: AppTextField(
                              label: 'Reporting Manager ID / Name',
                              hintText: 'e.g. EMP-001 or Manager Name',
                              controller: _managerController,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              label: 'Joining Date (YYYY-MM-DD)',
                              hintText: '2025-01-15',
                              controller: _joiningDateController,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: AppDropdown<String>(
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
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppDropdown<String>(
                        label: 'Employee Status',
                        value: _status,
                        items: const [
                          DropdownMenuItem(value: 'active', child: Text('Active')),
                          DropdownMenuItem(value: 'onboarding', child: Text('Onboarding')),
                          DropdownMenuItem(value: 'suspended', child: Text('Suspended')),
                          DropdownMenuItem(value: 'exited', child: Text('Exited')),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _status = val);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(_error!, style: AppTypography.caption.copyWith(color: AppColors.error)),
              ],
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppButton.secondary(
                    label: 'Cancel',
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  AppButton(
                    label: isEditing ? 'Save All Changes' : 'Create Employee',
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
      setState(() => _error = 'Full name and work email are required.');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final repo = EmployeeRepository();
      final session = ref.read(authNotifierProvider).state;

      if (widget.employee != null) {
        final updated = widget.employee!.copyWith(
          fullName: name,
          displayName: _displayNameController.text.trim().isNotEmpty
              ? _displayNameController.text.trim()
              : name,
          phone: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
          dateOfBirth: _dobController.text.trim().isNotEmpty ? _dobController.text.trim() : null,
          gender: _gender,
          address: _addressController.text.trim().isNotEmpty ? _addressController.text.trim() : null,
          emergencyContact: _emergencyContactController.text.trim().isNotEmpty
              ? _emergencyContactController.text.trim()
              : null,
          avatarUrl: _avatarUrlController.text.trim().isNotEmpty
              ? _avatarUrlController.text.trim()
              : null,
          departmentId: _departmentController.text.trim().isNotEmpty
              ? _departmentController.text.trim()
              : null,
          designationId: _designationController.text.trim().isNotEmpty
              ? _designationController.text.trim()
              : null,
          locationId: _locationController.text.trim().isNotEmpty
              ? _locationController.text.trim()
              : null,
          managerId: _managerController.text.trim().isNotEmpty
              ? _managerController.text.trim()
              : null,
          joiningDate: _joiningDateController.text.trim().isNotEmpty
              ? _joiningDateController.text.trim()
              : null,
          employmentType: _employmentType,
          status: _status,
        );
        await repo.updateEmployee(updated);
      } else {
        await repo.createEmployee(
          organizationId: session.activeOrganization!.id,
          fullName: name,
          displayName: _displayNameController.text.trim().isNotEmpty
              ? _displayNameController.text.trim()
              : name,
          email: email,
          phone: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
          dateOfBirth: _dobController.text.trim().isNotEmpty ? _dobController.text.trim() : null,
          gender: _gender,
          address: _addressController.text.trim().isNotEmpty ? _addressController.text.trim() : null,
          emergencyContact: _emergencyContactController.text.trim().isNotEmpty
              ? _emergencyContactController.text.trim()
              : null,
          avatarUrl: _avatarUrlController.text.trim().isNotEmpty
              ? _avatarUrlController.text.trim()
              : null,
          departmentId: _departmentController.text.trim().isNotEmpty
              ? _departmentController.text.trim()
              : null,
          designationId: _designationController.text.trim().isNotEmpty
              ? _designationController.text.trim()
              : null,
          locationId: _locationController.text.trim().isNotEmpty
              ? _locationController.text.trim()
              : null,
          managerId: _managerController.text.trim().isNotEmpty
              ? _managerController.text.trim()
              : null,
          joiningDate: _joiningDateController.text.trim().isNotEmpty
              ? _joiningDateController.text.trim()
              : null,
          employmentType: _employmentType,
          status: _status,
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
