import 'package:cloud_firestore/cloud_firestore.dart';
import 'analytics_engine.dart';

/// Repository for querying dynamic organizational metrics from authoritative collections.
class AnalyticsRepository {
  final FirebaseFirestore _firestore;

  AnalyticsRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Fetches workforce metrics for an organization
  Future<WorkforceMetrics> getWorkforceMetrics(String orgId) async {
    final snapshot = await _firestore
        .collection('employees')
        .where('organizationId', isEqualTo: orgId)
        .get();

    int total = snapshot.docs.length;
    int active = 0;
    int onboarding = 0;
    final deptMap = <String, int>{};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final status = data['employmentStatus'] as String? ?? 'active';
      final dept = data['departmentId'] as String? ?? 'General';

      if (status == 'active') active++;
      if (status == 'onboarding') onboarding++;

      deptMap[dept] = (deptMap[dept] ?? 0) + 1;
    }

    return WorkforceMetrics(
      totalEmployees: total,
      activeEmployees: active,
      onboardingEmployees: onboarding,
      departmentDistribution: deptMap,
    );
  }

  /// Fetches attendance metrics for an organization
  Future<AttendanceMetrics> getAttendanceMetrics(String orgId) async {
    final snapshot = await _firestore
        .collection('attendance_records')
        .where('organizationId', isEqualTo: orgId)
        .get();

    int total = snapshot.docs.length;
    int present = 0;
    int late = 0;
    int leave = 0;
    double totalWorked = 0.0;

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final status = data['status'] as String? ?? 'present';
      final isLate = data['isLate'] as bool? ?? false;
      final workedMins = (data['totalWorkedMinutes'] as num?)?.toDouble() ?? 480.0;

      if (status == 'present') present++;
      if (status == 'leave') leave++;
      if (isLate) late++;

      totalWorked += (workedMins / 60.0);
    }

    final avgWorked = total > 0 ? (totalWorked / total) : 8.0;

    return AttendanceMetrics(
      totalRecords: total,
      presentCount: present,
      lateCount: late,
      leaveCount: leave,
      averageWorkedHours: (avgWorked * 10).roundToDouble() / 10,
    );
  }

  /// Fetches leave metrics for an organization
  Future<LeaveMetrics> getLeaveMetrics(String orgId) async {
    final snapshot = await _firestore
        .collection('leave_requests')
        .where('organizationId', isEqualTo: orgId)
        .get();

    int total = snapshot.docs.length;
    int pending = 0;
    int approved = 0;
    int rejected = 0;
    final typeMap = <String, int>{};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final status = data['status'] as String? ?? 'pending';
      final type = data['leaveTypeId'] as String? ?? 'paid';

      if (status == 'pending') pending++;
      if (status == 'approved') approved++;
      if (status == 'rejected') rejected++;

      typeMap[type] = (typeMap[type] ?? 0) + 1;
    }

    return LeaveMetrics(
      totalRequests: total,
      pendingCount: pending,
      approvedCount: approved,
      rejectedCount: rejected,
      leaveTypeBreakdown: typeMap,
    );
  }

  /// Fetches payroll metrics for an organization
  Future<PayrollMetrics> getPayrollMetrics(String orgId) async {
    final snapshot = await _firestore
        .collection('payroll_records')
        .where('organizationId', isEqualTo: orgId)
        .get();

    double gross = 0.0;
    double deductions = 0.0;
    double net = 0.0;

    for (var doc in snapshot.docs) {
      final data = doc.data();
      gross += (data['grossPay'] as num?)?.toDouble() ?? 0.0;
      deductions += (data['totalDeductions'] as num?)?.toDouble() ?? 0.0;
      net += (data['netPay'] as num?)?.toDouble() ?? 0.0;
    }

    return PayrollMetrics(
      totalGrossPay: gross,
      totalDeductions: deductions,
      totalNetPay: net,
      processedRecords: snapshot.docs.length,
    );
  }
}
