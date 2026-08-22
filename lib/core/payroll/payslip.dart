/// Payslip domain model for Dayflow.
class Payslip {
  final String id;
  final String organizationId;
  final String payrollPeriodId;
  final String employeeId;
  final String payrollRecordId;
  final String storagePath; // B2 storage document path
  final DateTime publishedAt;

  const Payslip({
    required this.id,
    required this.organizationId,
    required this.payrollPeriodId,
    required this.employeeId,
    required this.payrollRecordId,
    required this.storagePath,
    required this.publishedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'organizationId': organizationId,
      'payrollPeriodId': payrollPeriodId,
      'employeeId': employeeId,
      'payrollRecordId': payrollRecordId,
      'storagePath': storagePath,
      'publishedAt': publishedAt.toIso8601String(),
    };
  }

  factory Payslip.fromMap(Map<String, dynamic> map) {
    return Payslip(
      id: map['id'] as String,
      organizationId: map['organizationId'] as String,
      payrollPeriodId: map['payrollPeriodId'] as String,
      employeeId: map['employeeId'] as String,
      payrollRecordId: map['payrollRecordId'] as String,
      storagePath: map['storagePath'] as String,
      publishedAt: DateTime.parse(map['publishedAt'] as String),
    );
  }
}
