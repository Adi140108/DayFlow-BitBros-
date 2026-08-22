import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/auth/auth_notifier.dart';
import '../../core/components/app_button.dart';
import '../../core/components/app_card.dart';
import '../../core/components/app_feedback.dart';
import '../../core/components/app_table.dart';
import '../../core/payroll/payroll_repository.dart';
import '../../core/payroll/payslip.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/file_download_helper.dart';

class EmployeePayrollScreen extends ConsumerStatefulWidget {
  const EmployeePayrollScreen({super.key});

  @override
  ConsumerState<EmployeePayrollScreen> createState() => _EmployeePayrollScreenState();
}

class _EmployeePayrollScreenState extends ConsumerState<EmployeePayrollScreen> {
  final _payrollRepo = PayrollRepository();
  List<Payslip> _payslips = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPayslips();
  }

  Future<void> _loadPayslips() async {
    final session = ref.read(authNotifierProvider).state;
    if (session.user == null) return;

    setState(() => _isLoading = true);
    try {
      final list = await _payrollRepo.getEmployeePayslips(session.user!.uid);
      setState(() {
        _payslips = list;
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
          Text('My Payslips & Compensation', style: AppTypography.pageTitle),
          const SizedBox(height: AppSpacing.md),

          // Overview Banner Card
          AppCard(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.account_balance_wallet, color: AppColors.primary, size: 32),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Salary & Payslip Statements', style: AppTypography.sectionHeading),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        'View and download your monthly published payslips securely.',
                        style: AppTypography.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          Text('Published Payslips History', style: AppTypography.sectionHeading),
          const SizedBox(height: AppSpacing.md),

          if (_payslips.isEmpty)
            const AppEmptyState(
              title: 'No Payslips Found',
              description: 'Your published monthly payslips will appear here once processed by HR.',
            )
          else
            AppTable(
              columns: const [
                AppTableColumn(title: 'Period', width: 140),
                AppTableColumn(title: 'Published Date', width: 160),
                AppTableColumn(title: 'Storage Key'),
                AppTableColumn(title: 'Action', width: 120),
              ],
              rows: _payslips.map((p) {
                return [
                  Text(p.payrollPeriodId, style: AppTypography.label),
                  Text('${p.publishedAt.year}-${p.publishedAt.month.toString().padLeft(2, '0')}-${p.publishedAt.day.toString().padLeft(2, '0')}', style: AppTypography.bodySmall),
                  Text(p.storagePath, style: AppTypography.caption),
                  AppButton(
                    label: 'Download',
                    size: AppButtonSize.small,
                    icon: Icons.download,
                    onPressed: () {
                      final payslipText = "========================================\n"
                          "        DAYFLOW HRMS PAYSLIP STATEMENT\n"
                          "========================================\n"
                          "Period: ${p.payrollPeriodId}\n"
                          "Employee ID / UID: ${p.employeeId}\n"
                          "Published Date: ${p.publishedAt}\n"
                          "Storage Path: ${p.storagePath}\n"
                          "----------------------------------------\n"
                          "Status: VERIFIED & PUBLISHED\n"
                          "========================================\n";
                      FileDownloadHelper.downloadTextFile(
                        filename: "payslip_${p.payrollPeriodId}_${p.employeeId}.txt",
                        content: payslipText,
                        mimeType: "text/plain",
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Downloading payslip for ${p.payrollPeriodId}...')),
                      );
                    },
                  ),
                ];
              }).toList(),
            ),
        ],
      ),
    );
  }
}
