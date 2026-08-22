import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/auth/app_permission.dart';
import '../../core/auth/auth_notifier.dart';
import '../../core/components/app_avatar.dart';
import '../../core/components/app_badge.dart';
import '../../core/components/app_button.dart';
import '../../core/components/app_card.dart';
import '../../core/components/app_feedback.dart';
import '../../core/components/app_select.dart';
import '../../core/components/app_table.dart';
import '../../core/components/app_text_field.dart';
import '../../core/employee/employee.dart';
import '../../core/employee/employee_repository.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import 'employee_form_dialog.dart';

class EmployeeDirectoryScreen extends ConsumerStatefulWidget {
  const EmployeeDirectoryScreen({super.key});

  @override
  ConsumerState<EmployeeDirectoryScreen> createState() => _EmployeeDirectoryScreenState();
}

class _EmployeeDirectoryScreenState extends ConsumerState<EmployeeDirectoryScreen> {
  final _searchController = TextEditingController();
  final _employeeRepo = EmployeeRepository();
  String? _statusFilter;
  List<Employee> _employees = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    final notifier = ref.read(authNotifierProvider);
    final session = notifier.state;
    if (session.activeOrganization == null) return;

    setState(() => _isLoading = true);
    try {
      final list = await _employeeRepo.getEmployees(
        session.activeOrganization!.id,
        status: _statusFilter,
        searchQuery: _searchController.text,
      );
      setState(() {
        _employees = list;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final notifier = ref.watch(authNotifierProvider);
    final canCreate = notifier.can(AppPermission.employeesCreate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Action Bar
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Employee Directory',
              style: AppTypography.sectionHeading.copyWith(
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            if (canCreate)
              AppButton(
                label: 'Add Employee',
                icon: Icons.add,
                size: AppButtonSize.small,
                onPressed: () async {
                  final added = await showDialog<bool>(
                    context: context,
                    builder: (context) => const EmployeeFormDialog(),
                  );
                  if (added == true) _loadEmployees();
                },
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // Filter & Search Controls Bar
        Row(
          children: [
            Expanded(
              child: AppTextField(
                hintText: 'Search by ID, Name, or Email...',
                isSearch: true,
                controller: _searchController,
                onChanged: (_) => _loadEmployees(),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            SizedBox(
              width: 140,
              child: AppDropdown<String?>(
                value: _statusFilter,
                hintText: 'All Statuses',
                items: const [
                  DropdownMenuItem(value: null, child: Text('All Statuses')),
                  DropdownMenuItem(value: 'active', child: Text('Active')),
                  DropdownMenuItem(value: 'onboarding', child: Text('Onboarding')),
                  DropdownMenuItem(value: 'suspended', child: Text('Suspended')),
                  DropdownMenuItem(value: 'exited', child: Text('Exited')),
                ],
                onChanged: (val) {
                  setState(() => _statusFilter = val);
                  _loadEmployees();
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        // Data Display
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.all(AppSpacing.xxl),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_employees.isEmpty)
          AppEmptyState(
            title: 'No Employees Found',
            description: 'There are no employees matching your current filter criteria.',
            actionLabel: canCreate ? 'Add First Employee' : null,
            onAction: canCreate
                ? () async {
                    final added = await showDialog<bool>(
                      context: context,
                      builder: (context) => const EmployeeFormDialog(),
                    );
                    if (added == true) _loadEmployees();
                  }
                : null,
          )
        else if (isMobile)
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _employees.length,
            separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final emp = _employees[index];
              return AppCard(
                onTap: () => context.go('/employees/${emp.id}'),
                child: Row(
                  children: [
                    AppAvatar(name: emp.fullName, imageUrl: emp.avatarUrl),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(emp.fullName, style: AppTypography.label),
                          Text(
                            '${emp.employeeId} • ${emp.email}',
                            style: AppTypography.bodySmall.copyWith(
                              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppStatusBadge(
                      label: emp.status.toUpperCase(),
                      variant: emp.status == 'active'
                          ? AppBadgeVariant.success
                          : AppBadgeVariant.neutral,
                    ),
                  ],
                ),
              );
            },
          )
        else
          AppTable(
            columns: const [
              AppTableColumn(title: 'Employee ID', width: 110),
              AppTableColumn(title: 'Name & Email'),
              AppTableColumn(title: 'Type', width: 100),
              AppTableColumn(title: 'Status', width: 110),
            ],
            rows: _employees.map((emp) {
              return [
                InkWell(
                  onTap: () => context.go('/employees/${emp.id}'),
                  child: Text(
                    emp.employeeId,
                    style: AppTypography.label.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => context.go('/employees/${emp.id}'),
                  child: Row(
                    children: [
                      AppAvatar(name: emp.fullName, imageUrl: emp.avatarUrl, size: AppAvatarSize.small),
                      const SizedBox(width: AppSpacing.sm),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(emp.fullName, style: AppTypography.label),
                          Text(emp.email, style: AppTypography.caption),
                        ],
                      ),
                    ],
                  ),
                ),
                Text(emp.employmentType.replaceAll('_', ' ').toUpperCase(), style: AppTypography.caption),
                AppStatusBadge(
                  label: emp.status.toUpperCase(),
                  variant: emp.status == 'active'
                      ? AppBadgeVariant.success
                      : AppBadgeVariant.neutral,
                ),
              ];
            }).toList(),
          ),
      ],
    );
  }
}
