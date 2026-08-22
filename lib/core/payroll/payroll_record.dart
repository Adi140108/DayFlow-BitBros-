/// Payroll Record calculation snapshot model for Dayflow.
class PayrollRecord {
  final String id;
  final String organizationId;
  final String payrollPeriodId;
  final String employeeId;
  final String salaryStructureId;
  final double grossPay;
  final double totalDeductions;
  final double totalEmployerContributions;
  final double netPay;
  final String currency;
  final Map<String, double> earningsMap;
  final Map<String, double> deductionsMap;
  final double workedDays;
  final double unpaidLeaveDays;
  final DateTime calculatedAt;

  const PayrollRecord({
    required this.id,
    required this.organizationId,
    required this.payrollPeriodId,
    required this.employeeId,
    required this.salaryStructureId,
    required this.grossPay,
    required this.totalDeductions,
    required this.totalEmployerContributions,
    required this.netPay,
    this.currency = 'INR',
    required this.earningsMap,
    required this.deductionsMap,
    this.workedDays = 22.0,
    this.unpaidLeaveDays = 0.0,
    required this.calculatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'organizationId': organizationId,
      'payrollPeriodId': payrollPeriodId,
      'employeeId': employeeId,
      'salaryStructureId': salaryStructureId,
      'grossPay': grossPay,
      'totalDeductions': totalDeductions,
      'totalEmployerContributions': totalEmployerContributions,
      'netPay': netPay,
      'currency': currency,
      'earningsMap': earningsMap,
      'deductionsMap': deductionsMap,
      'workedDays': workedDays,
      'unpaidLeaveDays': unpaidLeaveDays,
      'calculatedAt': calculatedAt.toIso8601String(),
    };
  }

  factory PayrollRecord.fromMap(Map<String, dynamic> map) {
    return PayrollRecord(
      id: map['id'] as String,
      organizationId: map['organizationId'] as String,
      payrollPeriodId: map['payrollPeriodId'] as String,
      employeeId: map['employeeId'] as String,
      salaryStructureId: map['salaryStructureId'] as String,
      grossPay: (map['grossPay'] as num?)?.toDouble() ?? 0.0,
      totalDeductions: (map['totalDeductions'] as num?)?.toDouble() ?? 0.0,
      totalEmployerContributions: (map['totalEmployerContributions'] as num?)?.toDouble() ?? 0.0,
      netPay: (map['netPay'] as num?)?.toDouble() ?? 0.0,
      currency: map['currency'] as String? ?? 'INR',
      earningsMap: Map<String, double>.from(map['earningsMap'] as Map? ?? {}),
      deductionsMap: Map<String, double>.from(map['deductionsMap'] as Map? ?? {}),
      workedDays: (map['workedDays'] as num?)?.toDouble() ?? 22.0,
      unpaidLeaveDays: (map['unpaidLeaveDays'] as num?)?.toDouble() ?? 0.0,
      calculatedAt: DateTime.parse(map['calculatedAt'] as String),
    );
  }
}
