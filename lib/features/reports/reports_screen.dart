import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/analytics/analytics_repository.dart';
import '../../core/auth/auth_notifier.dart';
import '../../core/components/app_button.dart';
import '../../core/components/app_table.dart';
import '../../core/reports/report_engine.dart';
import '../../core/reports/report_repository.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  final _reportRepo = ReportRepository();
  final _analyticsRepo = AnalyticsRepository();
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
              Row(
                children: [
                  AppButton(
                    label: 'Export Workforce CSV',
                    icon: Icons.download,
                    size: AppButtonSize.small,
                    isLoading: _isGenerating,
                    onPressed: _exportWorkforceReport,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Report List Table
          AppTable(
            columns: const [
              AppTableColumn(title: 'Report Title', width: 220),
              AppTableColumn(title: 'Category', width: 140),
              AppTableColumn(title: 'Format', width: 90),
              AppTableColumn(title: 'Generated At'),
            ],
            rows: _reports.map((r) {
              return [
                Text(r.title, style: AppTypography.label),
                Text(r.category, style: AppTypography.bodySmall),
                Text(r.format, style: AppTypography.caption),
                Text('${r.createdAt.year}-${r.createdAt.month.toString().padLeft(2, '0')}-${r.createdAt.day.toString().padLeft(2, '0')}', style: AppTypography.bodySmall),
              ];
            }).toList(),
          ),
        ],
      ),
    );
  }

  Future<void> _exportWorkforceReport() async {
    final session = ref.read(authNotifierProvider).state;
    if (session.activeOrganization == null) return;

    setState(() => _isGenerating = true);
    try {
      final wf = await _analyticsRepo.getWorkforceMetrics(session.activeOrganization!.id);
      final csv = ReportEngine.generateCsv(
        ['Metric', 'Count'],
        [
          ['Total Registered Employees', wf.totalEmployees],
          ['Active Status Employees', wf.activeEmployees],
          ['Onboarding Status Employees', wf.onboardingEmployees],
        ],
      );

      final meta = ReportMetadata(
        id: '',
        organizationId: session.activeOrganization!.id,
        title: 'Workforce Operational Report (${csv.length} bytes)',
        category: 'Workforce',
        format: 'CSV',
        storagePath: 'organizations/${session.activeOrganization!.id}/reports/workforce.csv',
        createdAt: DateTime.now(),
      );

      await _reportRepo.saveReportMetadata(meta);
      _checkAndLoad();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Workforce CSV report generated successfully.')),
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }
}
