import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/auth/app_permission.dart';
import '../../core/auth/auth_notifier.dart';
import '../../core/components/app_avatar.dart';
import '../../core/components/app_badge.dart';
import '../../core/components/app_button.dart';
import '../../core/components/app_card.dart';
import '../../core/components/app_feedback.dart';
import '../../core/components/app_file_surface.dart';
import '../../core/components/app_text_field.dart';
import '../../core/employee/employee.dart';
import '../../core/employee/employee_document.dart';
import '../../core/employee/employee_repository.dart';
import '../../core/employee/document_repository.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import 'employee_form_dialog.dart';

class EmployeeDetailsScreen extends ConsumerStatefulWidget {
  final String id;

  const EmployeeDetailsScreen({super.key, required this.id});

  @override
  ConsumerState<EmployeeDetailsScreen> createState() => _EmployeeDetailsScreenState();
}

class _EmployeeDetailsScreenState extends ConsumerState<EmployeeDetailsScreen> {
  final _employeeRepo = EmployeeRepository();
  final _docRepo = DocumentRepository();

  Employee? _employee;
  List<EmployeeDocument> _documents = [];
  bool _isLoading = true;
  bool _isEditingSelfService = false;

  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isSavingSelfService = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final emp = await _employeeRepo.getEmployeeById(widget.id);
      if (emp != null) {
        final docs = await _docRepo.getEmployeeDocuments(emp.id);
        _phoneController.text = emp.phone ?? '';
        _addressController.text = emp.address ?? '';
        setState(() {
          _employee = emp;
          _documents = docs;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final notifier = ref.watch(authNotifierProvider);
    final session = notifier.state;
    final isSelf = session.user?.uid == _employee?.userId;
    final canEditAll = notifier.can(AppPermission.employeesUpdate);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_employee == null) {
      return const AppErrorState(message: 'Employee record not found.');
    }

    final emp = _employee!;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Profile Card
          AppCard(
            child: Row(
              children: [
                AppAvatar(name: emp.fullName, imageUrl: emp.avatarUrl, size: AppAvatarSize.large),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(emp.fullName, style: AppTypography.pageTitle),
                          const SizedBox(width: AppSpacing.sm),
                          AppStatusBadge(
                            label: emp.status.toUpperCase(),
                            variant: emp.status == 'active'
                                ? AppBadgeVariant.success
                                : AppBadgeVariant.neutral,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        'Employee ID: ${emp.employeeId} • ${emp.email}',
                        style: AppTypography.body.copyWith(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (canEditAll)
                  AppButton.secondary(
                    label: 'Edit Full Record',
                    icon: Icons.edit,
                    size: AppButtonSize.small,
                    onPressed: () async {
                      final updated = await showDialog<bool>(
                        context: context,
                        builder: (context) => EmployeeFormDialog(employee: emp),
                      );
                      if (updated == true) _loadData();
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Personal Information Section (Self-service Editable)
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Personal Information', style: AppTypography.sectionHeading),
                    if (isSelf || canEditAll)
                      AppButton.text(
                        label: _isEditingSelfService ? 'Cancel' : 'Edit Self-Service',
                        size: AppButtonSize.small,
                        onPressed: () {
                          setState(() {
                            _isEditingSelfService = !_isEditingSelfService;
                          });
                        },
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                if (_isEditingSelfService) ...[
                  AppTextField(label: 'Phone Number', controller: _phoneController),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(label: 'Residential Address', controller: _addressController, maxLines: 2),
                  const SizedBox(height: AppSpacing.md),
                  AppButton(
                    label: 'Save Self-Service Updates',
                    isLoading: _isSavingSelfService,
                    size: AppButtonSize.small,
                    onPressed: _saveSelfService,
                  ),
                ] else ...[
                  _buildDetailRow('Full Name', emp.fullName),
                  _buildDetailRow('Email', emp.email),
                  _buildDetailRow('Phone', emp.phone ?? 'Not provided'),
                  _buildDetailRow('Address', emp.address ?? 'Not provided'),
                  _buildDetailRow('Date of Birth', emp.dateOfBirth ?? 'Not provided'),
                  _buildDetailRow('Emergency Contact', emp.emergencyContact ?? 'Not provided'),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Employment Information Section
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Employment Information', style: AppTypography.sectionHeading),
                const SizedBox(height: AppSpacing.md),
                _buildDetailRow('Employee ID', emp.employeeId),
                _buildDetailRow('Employment Type', emp.employmentType.replaceAll('_', ' ').toUpperCase()),
                _buildDetailRow('Joining Date', emp.joiningDate ?? 'Not specified'),
                _buildDetailRow('Department ID', emp.departmentId ?? 'Unassigned'),
                _buildDetailRow('Designation ID', emp.designationId ?? 'Unassigned'),
                _buildDetailRow('Reporting Manager ID', emp.managerId ?? 'None'),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Employee Documents Section
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Employee Documents', style: AppTypography.sectionHeading),
                const SizedBox(height: AppSpacing.md),
                if (_documents.isEmpty)
                  Text(
                    'No documents uploaded for this employee.',
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _documents.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final doc = _documents[index];
                      return ListTile(
                        leading: const Icon(Icons.picture_as_pdf_outlined, color: AppColors.primary),
                        title: Text(doc.name, style: AppTypography.label),
                        subtitle: Text('${doc.category.toUpperCase()} • ${(doc.fileSize / 1024).toStringAsFixed(1)} KB'),
                      );
                    },
                  ),
                const SizedBox(height: AppSpacing.md),
                const AppFileUploadSurface(
                  title: 'Upload HR Document (PDF / Image)',
                  subtitle: 'Backblaze B2 Document Storage Integration',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            ),
          ),
          Text(value, style: AppTypography.label),
        ],
      ),
    );
  }

  Future<void> _saveSelfService() async {
    setState(() => _isSavingSelfService = true);
    try {
      await _employeeRepo.updateSelfServiceProfile(
        widget.id,
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
      );
      await _loadData();
      setState(() {
        _isSavingSelfService = false;
        _isEditingSelfService = false;
      });
    } catch (e) {
      setState(() => _isSavingSelfService = false);
    }
  }
}
