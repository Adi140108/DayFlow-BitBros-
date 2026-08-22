import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/auth/auth_notifier.dart';
import '../../core/components/app_badge.dart';
import '../../core/components/app_button.dart';
import '../../core/components/app_card.dart';
import '../../core/components/app_feedback.dart';
import '../../core/components/app_table.dart';
import '../../core/payroll/payroll_period.dart';
import '../../core/payroll/payroll_repository.dart';
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
            const AppEmptyState(
              title: 'No Payroll Periods Configured',
              description: 'Configure your organization payroll periods to begin processing.',
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
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }
}
