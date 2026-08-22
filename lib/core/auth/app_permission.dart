/// Strongly-typed granular permissions supported across Dayflow domains.
enum AppPermission {
  employeesRead('employees.read'),
  employeesCreate('employees.create'),
  employeesUpdate('employees.update'),
  employeesDelete('employees.delete'),

  attendanceReadSelf('attendance.read.self'),
  attendanceReadTeam('attendance.read.team'),
  attendanceReadAll('attendance.read.all'),
  attendanceModify('attendance.modify'),

  leaveCreate('leave.create'),
  leaveReadSelf('leave.read.self'),
  leaveReadTeam('leave.read.team'),
  leaveReadAll('leave.read.all'),
  leaveApprove('leave.approve'),
  leaveReject('leave.reject'),

  payrollReadSelf('payroll.read.self'),
  payrollReadAll('payroll.read.all'),
  payrollModify('payroll.modify'),

  documentsReadSelf('documents.read.self'),
  documentsReadAll('documents.read.all'),
  documentsUpload('documents.upload'),
  documentsDelete('documents.delete'),

  reportsRead('reports.read'),
  analyticsRead('analytics.read'),

  organizationRead('organization.read'),
  organizationUpdate('organization.update'),

  rolesRead('roles.read'),
  rolesManage('roles.manage');

  final String value;
  const AppPermission(this.value);
}
