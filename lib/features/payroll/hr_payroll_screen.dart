import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/auth/auth_notifier.dart';
import '../../core/components/app_badge.dart';
import '../../core/components/app_button.dart';
import '../../core/components/app_card.dart';
import '../../core/components/app_feedback.dart';
import '../../core/components/app_table.dart';
import '../../core/components/app_text_field.dart';
import '../../core/payroll/payroll_period.dart';
import '../../core/payroll/payroll_repository.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

class HRPayrollScreen extends ConsumerStatefulWidget {
  const HRPayrollScreen({super.key});

  @override
  ConsumerState<HRPayrollScreen> createState() => _HRPayrollScreenState();
}

class _HRPayrollScreenState extends ConsumerState<HRPayrollScreen> {
  final _payrollRepo = PayrollRepository();
  List<PayrollPeriod> _periods = [];
  bool _isLoading = true;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadPeriods();
  }

  Future<void> _loadPeriods() async {
    final session = ref.read(authNotifierProvider).state;
    if (session.activeOrganization == null) return;

    setState(() => _isLoading = true);
    try {
      final list = await _payrollRepo.getPayrollPeriods(session.activeOrganization!.id);
      setState(() {
        _periods = list;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
              Text('Payroll Processing & Salary Management', style: AppTypography.pageTitle),
              AppButton(
                label: 'Create Pay Period',
                icon: Icons.add,
                size: AppButtonSize.small,
                onPressed: _showCreatePeriodDialog,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Overview Cards
          Row(
            children: [
              Expanded(
                child: AppStatCard(
                  title: 'Total Payroll Periods',
                  value: '${_periods.length}',
                  icon: Icons.date_range,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppStatCard(
                  title: 'Active Period Status',
                  value: _periods.isNotEmpty ? _periods.first.status.toUpperCase() : 'NONE',
                  icon: Icons.payments,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          Text('Organization Payroll Periods', style: AppTypography.sectionHeading),
          const SizedBox(height: AppSpacing.md),

          if (_periods.isEmpty)
            AppEmptyState(
              title: 'No Payroll Periods Configured',
              description: 'Configure your organization payroll periods to begin processing.',
              actionLabel: 'Create Pay Period',
              onAction: _showCreatePeriodDialog,
            )
          else
            AppTable(
              columns: const [
                AppTableColumn(title: 'Period Name', width: 180),
                AppTableColumn(title: 'Date Range', width: 180),
                AppTableColumn(title: 'Frequency', width: 100),
                AppTableColumn(title: 'Status', width: 120),
                AppTableColumn(title: 'Actions'),
              ],
              rows: _periods.map((p) {
                return [
                  Text(p.name, style: AppTypography.label),
                  Text('${p.startDate} to ${p.endDate}', style: AppTypography.bodySmall),
                  Text(p.frequency.toUpperCase(), style: AppTypography.caption),
                  AppStatusBadge(
                    label: p.status.toUpperCase(),
                    variant: p.status == 'published'
                        ? AppBadgeVariant.success
                        : p.status == 'calculated'
                            ? AppBadgeVariant.info
                            : AppBadgeVariant.warning,
                  ),
                  Row(
                    children: [
                      if (p.status == 'open')
                        AppButton(
                          label: 'Calculate Payroll',
                          size: AppButtonSize.small,
                          isLoading: _isProcessing,
                          onPressed: () => _calculate(p.id),
                        )
                      else if (p.status == 'calculated')
                        AppButton(
                          label: 'Publish Payslips',
                          size: AppButtonSize.small,
                          isLoading: _isProcessing,
                          onPressed: () => _publish(p.id),
                        )
                      else
                        Text('Locked & Published', style: AppTypography.caption),
                    ],
                  ),
                ];
              }).toList(),
            ),
        ],
      ),
    );
  }

  Future<void> _calculate(String periodId) async {
    final session = ref.read(authNotifierProvider).state;
    setState(() => _isProcessing = true);
    try {
      await _payrollRepo.calculatePayrollForPeriod(session.activeOrganization!.id, periodId);
      await _loadPeriods();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payroll calculations completed for all active employees.')),
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _publish(String periodId) async {
    setState(() => _isProcessing = true);
    try {
      await _payrollRepo.publishPayrollPeriod(periodId);
      await _loadPeriods();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payslips generated, published and notifications dispatched.')),
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _showCreatePeriodDialog() async {
    final now = DateTime.now();
    final nameCtrl = TextEditingController(text: 'Payroll ${now.year}-${now.month.toString().padLeft(2, '0')}');
    final startCtrl = TextEditingController(text: '${now.year}-${now.month.toString().padLeft(2, '0')}-01');
    final endCtrl = TextEditingController(text: '${now.year}-${now.month.toString().padLeft(2, '0')}-28');
    final payDateCtrl = TextEditingController(text: '${now.year}-${now.month.toString().padLeft(2, '0')}-28');
    bool isSaving = false;
    String? error;

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Create New Payroll Period'),
              content: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppTextField(
                      label: 'Period Name *',
                      hintText: 'e.g. September 2026 Payroll',
                      controller: nameCtrl,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      label: 'Start Date (YYYY-MM-DD) *',
                      hintText: '2026-09-01',
                      controller: startCtrl,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      label: 'End Date (YYYY-MM-DD) *',
                      hintText: '2026-09-30',
                      controller: endCtrl,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      label: 'Payment Date (YYYY-MM-DD) *',
                      hintText: '2026-09-30',
                      controller: payDateCtrl,
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
                          final payDate = payDateCtrl.text.trim();

                          if (name.isEmpty || start.isEmpty || end.isEmpty) {
                            setDialogState(() => error = 'All date fields and period name are required.');
                            return;
                          }

                          setDialogState(() {
                            isSaving = true;
                            error = null;
                          });

                          try {
                            final session = ref.read(authNotifierProvider).state;
                            final newPeriod = PayrollPeriod(
                              id: 'period_${DateTime.now().millisecondsSinceEpoch}',
                              organizationId: session.activeOrganization!.id,
                              name: name,
                              startDate: start,
                              endDate: end,
                              payDate: payDate,
                              status: 'open',
                              createdAt: DateTime.now(),
                            );

                            final messenger = ScaffoldMessenger.of(context);
                            final nav = Navigator.of(ctx);
                            await _payrollRepo.createPayrollPeriod(newPeriod);
                            nav.pop();
                            if (mounted) {
                              _loadPeriods();
                              messenger.showSnackBar(
                                const SnackBar(content: Text('New payroll period created successfully.')),
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
                      : const Text('Create Period'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
