import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/auth/auth_notifier.dart';
import '../../core/components/app_badge.dart';
import '../../core/components/app_button.dart';
import '../../core/components/app_card.dart';
import '../../core/components/app_feedback.dart';
import '../../core/components/app_table.dart';
import '../../core/leave/leave_repository.dart';
import '../../core/leave/leave_request.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

class ApprovalDashboardScreen extends ConsumerStatefulWidget {
  const ApprovalDashboardScreen({super.key});

  @override
  ConsumerState<ApprovalDashboardScreen> createState() => _ApprovalDashboardScreenState();
}

class _ApprovalDashboardScreenState extends ConsumerState<ApprovalDashboardScreen> {
  final _leaveRepo = LeaveRepository();
  List<LeaveRequest> _allRequests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final session = ref.read(authNotifierProvider).state;
    if (session.activeOrganization == null) return;

    setState(() => _isLoading = true);
    try {
      final requests = await _leaveRepo.getOrganizationLeaveRequests(session.activeOrganization!.id);
      setState(() {
        _allRequests = requests;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pendingRequests = _allRequests.where((r) => r.status == 'pending').toList();
    final approvedCount = _allRequests.where((r) => r.status == 'approved').length;
    final rejectedCount = _allRequests.where((r) => r.status == 'rejected').length;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Leave Approval Queue & Management', style: AppTypography.pageTitle),
          const SizedBox(height: AppSpacing.md),

          // Stats Overview
          Row(
            children: [
              Expanded(
                child: AppStatCard(
                  title: 'Pending Approvals',
                  value: '${pendingRequests.length}',
                  icon: Icons.pending_actions,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppStatCard(
                  title: 'Total Approved',
                  value: '$approvedCount',
                  icon: Icons.check_circle_outline,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppStatCard(
                  title: 'Total Rejected',
                  value: '$rejectedCount',
                  icon: Icons.highlight_off,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          // Pending Approval Queue Section
          Text('Pending Leave Requests', style: AppTypography.sectionHeading),
          const SizedBox(height: AppSpacing.md),

          if (pendingRequests.isEmpty)
            const AppEmptyState(
              title: 'No Pending Leave Approvals',
              description: 'All employee leave applications have been reviewed.',
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: pendingRequests.length,
              separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final req = pendingRequests[index];
                return AppCard(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Employee ID: ${req.employeeId} • ${req.leaveTypeId.toUpperCase()} (${req.durationDays} days)',
                              style: AppTypography.label,
                            ),
                            const SizedBox(height: AppSpacing.xxs),
                            Text(
                              'Dates: ${req.startDate} to ${req.endDate}',
                              style: AppTypography.bodySmall,
                            ),
                            Text(
                              'Remarks: ${req.remarks}',
                              style: AppTypography.caption.copyWith(
                                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          AppButton(
                            label: 'Approve',
                            size: AppButtonSize.small,
                            onPressed: () => _review(req.id, true),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          AppButton.destructive(
                            label: 'Reject',
                            size: AppButtonSize.small,
                            onPressed: () => _review(req.id, false),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          const SizedBox(height: AppSpacing.xl),

          // All Leave Applications History
          Text('All Organization Leave Applications', style: AppTypography.sectionHeading),
          const SizedBox(height: AppSpacing.md),
          AppTable(
            columns: const [
              AppTableColumn(title: 'Employee ID', width: 120),
              AppTableColumn(title: 'Type', width: 100),
              AppTableColumn(title: 'Dates', width: 180),
              AppTableColumn(title: 'Duration', width: 90),
              AppTableColumn(title: 'Status', width: 110),
            ],
            rows: _allRequests.map((req) {
              return [
                Text(req.employeeId, style: AppTypography.label),
                Text(req.leaveTypeId.toUpperCase(), style: AppTypography.bodySmall),
                Text('${req.startDate} to ${req.endDate}', style: AppTypography.bodySmall),
                Text('${req.durationDays}d', style: AppTypography.bodySmall),
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

  Future<void> _review(String requestId, bool approve) async {
    final session = ref.read(authNotifierProvider).state;
    try {
      if (approve) {
        await _leaveRepo.approveLeaveRequest(
          requestId: requestId,
          approverId: session.user!.uid,
          reviewerComment: 'Approved by HR/Manager',
        );
      } else {
        await _leaveRepo.rejectLeaveRequest(
          requestId: requestId,
          approverId: session.user!.uid,
          reviewerComment: 'Rejected by HR/Manager',
        );
      }
      await _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }
}
