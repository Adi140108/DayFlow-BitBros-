import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/auth/auth_notifier.dart';
import '../../core/components/app_badge.dart';
import '../../core/components/app_button.dart';
import '../../core/components/app_card.dart';
import '../../core/components/app_feedback.dart';
import '../../core/components/app_table.dart';
import '../../core/leave/leave_balance.dart';
import '../../core/leave/leave_repository.dart';
import '../../core/leave/leave_request.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import 'apply_leave_dialog.dart';

class EmployeeLeaveScreen extends ConsumerStatefulWidget {
  const EmployeeLeaveScreen({super.key});

  @override
  ConsumerState<EmployeeLeaveScreen> createState() => _EmployeeLeaveScreenState();
}

class _EmployeeLeaveScreenState extends ConsumerState<EmployeeLeaveScreen> {
  final _leaveRepo = LeaveRepository();
  List<LeaveBalance> _balances = [];
  List<LeaveRequest> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final session = ref.read(authNotifierProvider).state;
    if (session.user == null) return;

    setState(() => _isLoading = true);
    try {
      final year = DateTime.now().year;
      final balances = await _leaveRepo.getEmployeeBalances(session.user!.uid, year);
      final requests = await _leaveRepo.getEmployeeLeaveRequests(session.user!.uid);

      setState(() {
        _balances = balances;
        _requests = requests;
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

    final paidBal = _balances.firstWhere((b) => b.leaveTypeId == 'paid', orElse: () => LeaveBalance(id: '1', organizationId: '', employeeId: '', leaveTypeId: 'paid', year: 2026, allocated: 15.0));
    final sickBal = _balances.firstWhere((b) => b.leaveTypeId == 'sick', orElse: () => LeaveBalance(id: '2', organizationId: '', employeeId: '', leaveTypeId: 'sick', year: 2026, allocated: 10.0));
    final unpaidBal = _balances.firstWhere((b) => b.leaveTypeId == 'unpaid', orElse: () => LeaveBalance(id: '3', organizationId: '', employeeId: '', leaveTypeId: 'unpaid', year: 2026, allocated: 30.0));

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('My Leave Management', style: AppTypography.pageTitle),
              AppButton(
                label: 'Apply for Leave',
                icon: Icons.add,
                size: AppButtonSize.small,
                onPressed: () async {
                  final added = await showDialog<bool>(
                    context: context,
                    builder: (context) => const ApplyLeaveDialog(),
                  );
                  if (added == true) _loadData();
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Leave Balances Cards Grid
          Row(
            children: [
              Expanded(
                child: AppStatCard(
                  title: 'Paid Leave Available',
                  value: '${paidBal.available.toStringAsFixed(1)} days',
                  icon: Icons.beach_access,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppStatCard(
                  title: 'Sick Leave Available',
                  value: '${sickBal.available.toStringAsFixed(1)} days',
                  icon: Icons.local_hospital,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppStatCard(
                  title: 'Unpaid Leave Available',
                  value: '${unpaidBal.available.toStringAsFixed(1)} days',
                  icon: Icons.money_off,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          // Leave Requests History Table
          Text('Leave Application History', style: AppTypography.sectionHeading),
          const SizedBox(height: AppSpacing.md),

          if (_requests.isEmpty)
            const AppEmptyState(
              title: 'No Leave Applications Found',
              description: 'Your submitted leave requests will appear here.',
            )
          else
            AppTable(
              columns: const [
                AppTableColumn(title: 'Type', width: 110),
                AppTableColumn(title: 'Start Date', width: 110),
                AppTableColumn(title: 'End Date', width: 110),
                AppTableColumn(title: 'Duration', width: 90),
                AppTableColumn(title: 'Remarks'),
                AppTableColumn(title: 'Status', width: 110),
              ],
              rows: _requests.map((req) {
                return [
                  Text(req.leaveTypeId.toUpperCase(), style: AppTypography.label),
                  Text(req.startDate, style: AppTypography.bodySmall),
                  Text(req.endDate, style: AppTypography.bodySmall),
                  Text('${req.durationDays}d', style: AppTypography.bodySmall),
                  Text(req.remarks, style: AppTypography.bodySmall),
                  AppStatusBadge(
                    label: req.status.toUpperCase(),
                    variant: req.status == 'approved'
                        ? AppBadgeVariant.success
                        : req.status == 'rejected'
                            ? AppBadgeVariant.error
                            : AppBadgeVariant.warning,
                  ),
                ];
              }).toList(),
            ),
        ],
      ),
    );
  }
}
