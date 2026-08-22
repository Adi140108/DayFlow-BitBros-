import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/auth/auth_notifier.dart';
import '../../core/components/app_button.dart';
import '../../core/components/app_text_field.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

import '../../core/components/app_select.dart';

/// Screen for creating a new Organization (Onboarding).
class CreateOrganizationScreen extends ConsumerStatefulWidget {
  const CreateOrganizationScreen({super.key});

  @override
  ConsumerState<CreateOrganizationScreen> createState() => _CreateOrganizationScreenState();
}

class _CreateOrganizationScreenState extends ConsumerState<CreateOrganizationScreen> {
  final _nameController = TextEditingController();
  final _legalNameController = TextEditingController();
  String _institutionType = 'corporate';
  String _adminRole = 'owner';
  bool _isLoading = false;
  String? _error;

  final List<DropdownMenuItem<String>> _institutionItems = const [
    DropdownMenuItem(value: 'corporate', child: Text('Corporate Business / Tech Company')),
    DropdownMenuItem(value: 'education', child: Text('Educational Institution / University / School')),
    DropdownMenuItem(value: 'startup', child: Text('Startup / Small Business')),
    DropdownMenuItem(value: 'nonprofit', child: Text('Non-Profit Organization / NGO')),
    DropdownMenuItem(value: 'government', child: Text('Government / Public Sector')),
  ];

  final List<DropdownMenuItem<String>> _roleItems = const [
    DropdownMenuItem(value: 'owner', child: Text('Organization Owner & Founder')),
    DropdownMenuItem(value: 'hr_admin', child: Text('Chief Human Resources Officer (CHRO) / HR Admin')),
    DropdownMenuItem(value: 'director', child: Text('Director / Executive Administrator')),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480.0),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: AppRadius.borderLg,
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
                boxShadow: AppRadius.shadowMd,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.business_outlined, size: 48, color: AppColors.primary),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Setup Your Organization',
                    style: AppTypography.sectionHeading.copyWith(
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    'Create your organization workspace on Dayflow',
                    style: AppTypography.body.copyWith(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppTextField(
                    label: 'Organization / Institution Name',
                    hintText: 'e.g. Acme Corp / Stanford University',
                    controller: _nameController,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppDropdown<String>(
                    label: 'Institution Type / Industry Sector',
                    value: _institutionType,
                    items: _institutionItems,
                    onChanged: (val) {
                      if (val != null) setState(() => _institutionType = val);
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppDropdown<String>(
                    label: 'Your Role in Institution',
                    value: _adminRole,
                    items: _roleItems,
                    onChanged: (val) {
                      if (val != null) setState(() => _adminRole = val);
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    label: 'Legal Entity Name (Optional)',
                    hintText: 'e.g. Acme Corporation LLC',
                    controller: _legalNameController,
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(_error!, style: AppTypography.caption.copyWith(color: AppColors.error)),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  AppButton(
                    label: 'Create Organization Workspace',
                    isFullWidth: true,
                    isLoading: _isLoading,
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Organization name is required.');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final legalName = _legalNameController.text.trim().isEmpty ? name : _legalNameController.text.trim();
      await ref.read(authNotifierProvider).createOrganization(name, legalName);
      if (mounted) context.go('/dashboard');
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }
}
