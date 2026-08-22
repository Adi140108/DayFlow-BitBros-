class WorkforceMetrics {
  final int totalEmployees;
  final int activeEmployees;
  final int onboardingEmployees;
  final Map<String, int> departmentDistribution;

  const WorkforceMetrics({
    required this.totalEmployees,
    required this.activeEmployees,
    required this.onboardingEmployees,
    required this.departmentDistribution,
  });
}

class AttendanceMetrics {
  final int totalRecords;
  final int presentCount;
  final int lateCount;
  final int leaveCount;
  final double averageWorkedHours;

  const AttendanceMetrics({
    required this.totalRecords,
    required this.presentCount,
    required this.lateCount,
    required this.leaveCount,
    required this.averageWorkedHours,
  });

  double get attendancePercentage =>
      totalRecords > 0 ? ((presentCount / totalRecords) * 100).roundToDouble() : 0.0;
}

class LeaveMetrics {
  final int totalRequests;
  final int pendingCount;
  final int approvedCount;
  final int rejectedCount;
  final Map<String, int> leaveTypeBreakdown;

  const LeaveMetrics({
    required this.totalRequests,
    required this.pendingCount,
    required this.approvedCount,
    required this.rejectedCount,
    required this.leaveTypeBreakdown,
  });
}

class PayrollMetrics {
  final double totalGrossPay;
  final double totalDeductions;
  final double totalNetPay;
  final int processedRecords;

  const PayrollMetrics({
    required this.totalGrossPay,
    required this.totalDeductions,
    required this.totalNetPay,
    required this.processedRecords,
  });
}
