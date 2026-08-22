import 'package:flutter_test/flutter_test.dart';
import 'package:dayflow/core/analytics/analytics_engine.dart';
import 'package:dayflow/core/reports/report_engine.dart';
import 'package:dayflow/core/audit/audit_repository.dart';

void main() {
  group('Dayflow Analytics, Reports & AI Assistant Tests', () {
    test('AttendanceMetrics percentage calculates correctly', () {
      const metrics = AttendanceMetrics(
        totalRecords: 10,
        presentCount: 8,
        lateCount: 1,
        leaveCount: 1,
        averageWorkedHours: 8.0,
      );

      // (8 / 10) * 100 = 80.0%
      expect(metrics.attendancePercentage, equals(80.0));
    });

    test('ReportEngine generates valid CSV text output', () {
      final csv = ReportEngine.generateCsv(
        ['Metric', 'Value'],
        [
          ['Active Employees', 25],
          ['Total Departments', 4],
        ],
      );

      expect(csv, contains('"Metric","Value"'));
      expect(csv, contains('"Active Employees","25"'));
    });

    test('AuditLogItem model serialization', () {
      final item = AuditLogItem(
        id: 'audit_1',
        organizationId: 'org_1',
        actorId: 'user_1',
        actorName: 'Alice HR',
        action: 'APPROVED_LEAVE',
        resourceType: 'leaveRequest',
        resourceId: 'req_123',
        timestamp: DateTime.now(),
      );

      final map = item.toMap();
      final restored = AuditLogItem.fromMap(map);

      expect(restored.actorName, equals('Alice HR'));
      expect(restored.action, equals('APPROVED_LEAVE'));
    });
  });
}
