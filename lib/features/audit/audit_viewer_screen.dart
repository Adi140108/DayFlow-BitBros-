import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/audit/audit_repository.dart';
import '../../core/auth/auth_notifier.dart';
import '../../core/components/app_feedback.dart';
import '../../core/components/app_table.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

class AuditViewerScreen extends ConsumerStatefulWidget {
  const AuditViewerScreen({super.key});

  @override
  ConsumerState<AuditViewerScreen> createState() => _AuditViewerScreenState();
}

class _AuditViewerScreenState extends ConsumerState<AuditViewerScreen> {
  final _auditRepo = AuditRepository();
  List<AuditLogItem> _logs = [];
  bool _isLoading = true;
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
      _loadAuditLogsForOrg(orgId);
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadAuditLogsForOrg(String orgId) async {
    _loadedOrgId = orgId;
    if (mounted) setState(() => _isLoading = true);
    try {
      final list = await _auditRepo.getAuditLogs(orgId);
      if (mounted) {
        setState(() {
          _logs = list;
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
      Future.microtask(() => _loadAuditLogsForOrg(orgId));
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
          Text('Organization Audit Trail', style: AppTypography.pageTitle),
          const SizedBox(height: AppSpacing.md),

          if (_logs.isEmpty)
            const AppEmptyState(
              title: 'No Audit Records Found',
              description: 'System actions and user events will appear here.',
            )
          else
            AppTable(
              columns: const [
                AppTableColumn(title: 'Timestamp', width: 160),
                AppTableColumn(title: 'Actor', width: 140),
                AppTableColumn(title: 'Action', width: 160),
                AppTableColumn(title: 'Resource Type', width: 140),
                AppTableColumn(title: 'Resource ID'),
              ],
              rows: _logs.map((item) {
                return [
                  Text('${item.timestamp.year}-${item.timestamp.month.toString().padLeft(2, '0')}-${item.timestamp.day.toString().padLeft(2, '0')}', style: AppTypography.caption),
                  Text(item.actorName, style: AppTypography.label),
                  Text(item.action, style: AppTypography.bodySmall),
                  Text(item.resourceType, style: AppTypography.bodySmall),
                  Text(item.resourceId, style: AppTypography.caption),
                ];
              }).toList(),
            ),
        ],
      ),
    );
  }
}
