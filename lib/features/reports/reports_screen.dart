import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/analytics/analytics_repository.dart';
import '../../core/attendance/attendance_repository.dart';
import '../../core/auth/auth_notifier.dart';
import '../../core/components/app_button.dart';
import '../../core/components/app_card.dart';
import '../../core/components/app_table.dart';
import '../../core/employee/employee_repository.dart';
import '../../core/reports/report_engine.dart';
import '../../core/reports/report_repository.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/file_download_helper.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  final _reportRepo = ReportRepository();
  final _analyticsRepo = AnalyticsRepository();
  final _employeeRepo = EmployeeRepository();
  final _attendanceRepo = AttendanceRepository();

  List<ReportMetadata> _reports = [];
  bool _isLoading = true;
  bool _isGenerating = false;
  String? _loadedOrgId;

  @override
  void initState() {
    super.initState();
    _checkAndLoad();
  }

  void _checkAndLoad() {
    final session = ref.read(authNotifierProvider).state;
    final orgId = session.activeOrganization?.id;
    if (orgId != null) {
      _loadReportsForOrg(orgId);
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadReportsForOrg(String orgId) async {
    _loadedOrgId = orgId;
    if (mounted) setState(() => _isLoading = true);
    try {
      final list = await _reportRepo.getReports(orgId);
      if (mounted) {
        setState(() {
          _reports = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(authNotifierProvider).state;
    final orgId = session.activeOrganization?.id;

    if (orgId != null && orgId != _loadedOrgId && !_isLoading) {
      Future.microtask(() => _loadReportsForOrg(orgId));
    } else if (orgId == null && _isLoading) {
      Future.microtask(() {
        if (mounted && _isLoading) setState(() => _isLoading = false);
      });
    }
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
              Text('Reports & Data Exports', style: AppTypography.pageTitle),
              Wrap(
                spacing: AppSpacing.sm,
                children: [
                  AppButton(
                    label: 'Export Employees CSV',
                    icon: Icons.people_outline,
                    size: AppButtonSize.small,
                    isLoading: _isGenerating,
                    onPressed: _exportEmployeeDirectoryCsv,
                  ),
                  AppButton(
                    label: 'Export Attendance CSV',
                    icon: Icons.calendar_today_outlined,
                    size: AppButtonSize.small,
                    isLoading: _isGenerating,
                    onPressed: _exportAttendanceCsv,
                  ),
                  AppButton.secondary(
                    label: 'Workforce Metrics CSV',
                    icon: Icons.bar_chart_outlined,
                    size: AppButtonSize.small,
                    isLoading: _isGenerating,
                    onPressed: _exportWorkforceMetricsCsv,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Export Overview Cards
          Row(
            children: [
              Expanded(
                child: AppStatCard(
                  title: 'Available Reports',
                  value: '3 Formats',
                  icon: Icons.table_chart_outlined,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppStatCard(
                  title: 'Export History',
                  value: '${_reports.length}',
                  icon: Icons.history,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          Text('Generated Report Log & Downloads', style: AppTypography.sectionHeading),
          const SizedBox(height: AppSpacing.md),

          // Report List Table
          AppTable(
            columns: const [
              AppTableColumn(title: 'Report Title', width: 280),
              AppTableColumn(title: 'Category', width: 140),
              AppTableColumn(title: 'Format', width: 90),
              AppTableColumn(title: 'Generated Date', width: 140),
              AppTableColumn(title: 'Action'),
            ],
            rows: _reports.map((r) {
              return [
                Text(r.title, style: AppTypography.label),
                Text(r.category, style: AppTypography.bodySmall),
                Text(r.format, style: AppTypography.caption),
                Text('${r.createdAt.year}-${r.createdAt.month.toString().padLeft(2, '0')}-${r.createdAt.day.toString().padLeft(2, '0')}', style: AppTypography.bodySmall),
                AppButton.text(
                  label: 'Re-Download',
                  size: AppButtonSize.small,
                  onPressed: () {
                    final filename = "${r.category.toLowerCase()}_report.csv";
                    final sampleCsv = "Report,${r.title}\nCategory,${r.category}\nGenerated At,${r.createdAt}\nFormat,${r.format}\nStatus,Complete\n";
                    FileDownloadHelper.downloadTextFile(
                      filename: filename,
                      content: sampleCsv,
                      mimeType: 'text/csv;charset=utf-8',
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Downloading $filename...')),
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

  Future<void> _exportEmployeeDirectoryCsv() async {
    final session = ref.read(authNotifierProvider).state;
    if (session.activeOrganization == null) return;

    setState(() => _isGenerating = true);
    try {
      final employees = await _employeeRepo.getEmployees(session.activeOrganization!.id);
      final headers = [
        'Employee ID',
        'Full Name',
        'Email',
        'Phone',
        'Department',
        'Designation',
        'Employment Type',
        'Status',
        'Joining Date',
        'Gender',
        'Residential Address',
      ];

      final rows = employees.map((e) {
        return [
          e.employeeId,
          e.fullName,
          e.email,
          e.phone ?? '',
          e.departmentId ?? '',
          e.designationId ?? '',
          e.employmentType,
          e.status,
          e.joiningDate ?? '',
          e.gender ?? '',
          e.address ?? '',
        ];
      }).toList();

      final csvContent = ReportEngine.generateCsv(headers, rows);
      final now = DateTime.now();
      final dateStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      final filename = "dayflow_employee_directory_$dateStr.csv";

      // 1. Trigger actual browser file download
      FileDownloadHelper.downloadTextFile(
        filename: filename,
        content: csvContent,
        mimeType: 'text/csv;charset=utf-8',
      );

      // 2. Persist metadata
      final meta = ReportMetadata(
        id: 'rep_${now.millisecondsSinceEpoch}',
        organizationId: session.activeOrganization!.id,
        title: 'Employee Directory Export ($filename)',
        category: 'Employees',
        format: 'CSV',
        storagePath: 'organizations/${session.activeOrganization!.id}/reports/$filename',
        createdAt: now,
      );
      await _reportRepo.saveReportMetadata(meta);
      _checkAndLoad();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Employee directory CSV ($filename) downloaded successfully.')),
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  Future<void> _exportAttendanceCsv() async {
    final session = ref.read(authNotifierProvider).state;
    if (session.activeOrganization == null) return;

    setState(() => _isGenerating = true);
    try {
      final records = await _attendanceRepo.getOrganizationAttendance(session.activeOrganization!.id);
      final headers = [
        'Record ID',
        'Employee ID',
        'Attendance Date',
        'Check In Time',
        'Check Out Time',
        'Worked Minutes',
        'Overtime Minutes',
        'Is Late',
        'Late Minutes',
        'Status',
      ];

      final rows = records.map((r) {
        return [
          r.id,
          r.employeeId,
          r.attendanceDate,
          r.checkInAt ?? '',
          r.checkOutAt ?? '',
          r.totalWorkedMinutes,
          r.overtimeMinutes,
          r.isLate ? 'YES' : 'NO',
          r.lateMinutes,
          r.status,
        ];
      }).toList();

      final csvContent = ReportEngine.generateCsv(headers, rows);
      final now = DateTime.now();
      final dateStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      final filename = "dayflow_attendance_log_$dateStr.csv";

      // 1. Trigger actual browser file download
      FileDownloadHelper.downloadTextFile(
        filename: filename,
        content: csvContent,
        mimeType: 'text/csv;charset=utf-8',
      );

      // 2. Persist metadata
      final meta = ReportMetadata(
        id: 'rep_${now.millisecondsSinceEpoch}',
        organizationId: session.activeOrganization!.id,
        title: 'Attendance Records Log ($filename)',
        category: 'Attendance',
        format: 'CSV',
        storagePath: 'organizations/${session.activeOrganization!.id}/reports/$filename',
        createdAt: now,
      );
      await _reportRepo.saveReportMetadata(meta);
      _checkAndLoad();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Attendance log CSV ($filename) downloaded successfully.')),
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  Future<void> _exportWorkforceMetricsCsv() async {
    final session = ref.read(authNotifierProvider).state;
    if (session.activeOrganization == null) return;

    setState(() => _isGenerating = true);
    try {
      final wf = await _analyticsRepo.getWorkforceMetrics(session.activeOrganization!.id);
      final csv = ReportEngine.generateCsv(
        ['Metric Category', 'Count / Value'],
        [
          ['Total Registered Employees', wf.totalEmployees],
          ['Active Status Employees', wf.activeEmployees],
          ['Onboarding Status Employees', wf.onboardingEmployees],
        ],
      );

      final now = DateTime.now();
      final dateStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      final filename = "dayflow_workforce_metrics_$dateStr.csv";

      // 1. Trigger actual browser file download
      FileDownloadHelper.downloadTextFile(
        filename: filename,
        content: csv,
        mimeType: 'text/csv;charset=utf-8',
      );

      // 2. Persist metadata
      final meta = ReportMetadata(
        id: 'rep_${now.millisecondsSinceEpoch}',
        organizationId: session.activeOrganization!.id,
        title: 'Workforce Operational Report ($filename)',
        category: 'Workforce',
        format: 'CSV',
        storagePath: 'organizations/${session.activeOrganization!.id}/reports/$filename',
        createdAt: now,
      );

      await _reportRepo.saveReportMetadata(meta);
      _checkAndLoad();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Workforce metrics CSV ($filename) downloaded successfully.')),
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }
}
