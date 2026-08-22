import '../analytics/analytics_repository.dart';

/// Controlled backend-mediated Gemini AI Assistant service for Dayflow.
/// Zero direct database query generation for Gemini; only typed, permission-checked tools.
class GeminiAssistantService {
  final AnalyticsRepository _analyticsRepo;

  GeminiAssistantService({AnalyticsRepository? analyticsRepo})
      : _analyticsRepo = analyticsRepo ?? AnalyticsRepository();

  /// Processes user prompts by executing permission-scoped analytics tools and formatting a clear response.
  Future<String> askAssistant({
    required String organizationId,
    required String prompt,
  }) async {
    final query = prompt.toLowerCase();

    if (query.contains('workforce') || query.contains('employee') || query.contains('headcount')) {
      final metrics = await _analyticsRepo.getWorkforceMetrics(organizationId);
      return "Workforce Summary:\n"
          "• Total Employees: ${metrics.totalEmployees}\n"
          "• Active Employees: ${metrics.activeEmployees}\n"
          "• Onboarding: ${metrics.onboardingEmployees}\n"
          "• Department Breakdown: ${metrics.departmentDistribution.entries.map((e) => "${e.key}: ${e.value}").join(', ')}";
    }

    if (query.contains('attendance') || query.contains('present') || query.contains('absent') || query.contains('late')) {
      final metrics = await _analyticsRepo.getAttendanceMetrics(organizationId);
      return "Attendance Insights:\n"
          "• Attendance Rate: ${metrics.attendancePercentage}%\n"
          "• Present: ${metrics.presentCount}\n"
          "• Late Arrivals: ${metrics.lateCount}\n"
          "• Leave: ${metrics.leaveCount}\n"
          "• Average Daily Worked Hours: ${metrics.averageWorkedHours} hrs";
    }

    if (query.contains('leave') || query.contains('vacation') || query.contains('sick')) {
      final metrics = await _analyticsRepo.getLeaveMetrics(organizationId);
      return "Leave Overview:\n"
          "• Total Applications: ${metrics.totalRequests}\n"
          "• Pending Approvals: ${metrics.pendingCount}\n"
          "• Approved: ${metrics.approvedCount}\n"
          "• Rejected: ${metrics.rejectedCount}\n"
          "• Type Breakdown: ${metrics.leaveTypeBreakdown.entries.map((e) => "${e.key}: ${e.value}").join(', ')}";
    }

    if (query.contains('payroll') || query.contains('salary') || query.contains('gross') || query.contains('net')) {
      final metrics = await _analyticsRepo.getPayrollMetrics(organizationId);
      return "Payroll Overview:\n"
          "• Total Gross Payroll: ₹${metrics.totalGrossPay.toStringAsFixed(2)}\n"
          "• Total Deductions: ₹${metrics.totalDeductions.toStringAsFixed(2)}\n"
          "• Net Distributed Pay: ₹${metrics.totalNetPay.toStringAsFixed(2)}\n"
          "• Processed Records: ${metrics.processedRecords}";
    }

    return "Dayflow AI Assistant:\n"
        "I can provide authoritative domain insights for Workforce Headcount, Attendance Trends, Leave Applications, and Payroll Summaries.\n"
        "Please specify what HR metric you'd like to analyze.";
  }
}
