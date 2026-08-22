import 'salary_component.dart';
import 'salary_structure.dart';

/// Pure deterministic calculation result structure.
class PayrollCalculationResult {
  final double grossPay;
  final double totalDeductions;
  final double totalEmployerContributions;
  final double netPay;
  final Map<String, double> earningsMap;
  final Map<String, double> deductionsMap;

  const PayrollCalculationResult({
    required this.grossPay,
    required this.totalDeductions,
    required this.totalEmployerContributions,
    required this.netPay,
    required this.earningsMap,
    required this.deductionsMap,
  });
}

/// Pure deterministic Payroll Engine for Dayflow.
class PayrollEngine {
  /// Rounds monetary value deterministically to 2 decimal places.
  static double round(double value) {
    return (value * 100).roundToDouble() / 100;
  }

  /// Pure payroll calculation
  static PayrollCalculationResult calculate({
    required SalaryStructure structure,
    double unpaidLeaveDays = 0.0,
    double payableOvertimeHours = 0.0,
    double overtimeHourlyRate = 200.0,
  }) {
    double gross = 0.0;
    double deductions = 0.0;
    double employerContrib = 0.0;

    final earningsMap = <String, double>{};
    final deductionsMap = <String, double>{};

    // Find basic salary component if available
    final basicComp = structure.components.firstWhere(
      (c) => c.code == 'BASIC' || c.name.toLowerCase().contains('basic'),
      orElse: () => const SalaryComponent(id: '0', name: 'Basic', code: 'BASIC', type: 'earning', amount: 30000.0),
    );

    final baseSalary = basicComp.amount;

    // Process Earnings
    for (var comp in structure.components.where((c) => c.type == 'earning')) {
      double val = comp.amount;
      if (comp.calculationType == 'percentage') {
        val = round((comp.percentageOfBase / 100.0) * baseSalary);
      }
      earningsMap[comp.name] = round(val);
      gross += round(val);
    }

    // Overtime Earning
    if (payableOvertimeHours > 0) {
      final overtimeVal = round(payableOvertimeHours * overtimeHourlyRate);
      earningsMap['Overtime Pay'] = overtimeVal;
      gross += overtimeVal;
    }

    // Unpaid Leave Deduction (prorated at 1/22 of Base Salary per unpaid leave day)
    if (unpaidLeaveDays > 0) {
      final unpaidDeduction = round((baseSalary / 22.0) * unpaidLeaveDays);
      deductionsMap['Unpaid Leave Deduction'] = unpaidDeduction;
      deductions += unpaidDeduction;
    }

    // Process Deductions
    for (var comp in structure.components.where((c) => c.type == 'deduction')) {
      double val = comp.amount;
      if (comp.calculationType == 'percentage') {
        val = round((comp.percentageOfBase / 100.0) * baseSalary);
      }
      deductionsMap[comp.name] = round(val);
      deductions += round(val);
    }

    // Process Employer Contributions
    for (var comp in structure.components.where((c) => c.type == 'employer_contribution')) {
      double val = comp.amount;
      if (comp.calculationType == 'percentage') {
        val = round((comp.percentageOfBase / 100.0) * baseSalary);
      }
      employerContrib += round(val);
    }

    gross = round(gross);
    deductions = round(deductions);
    employerContrib = round(employerContrib);
    final net = round(gross - deductions);

    return PayrollCalculationResult(
      grossPay: gross,
      totalDeductions: deductions,
      totalEmployerContributions: employerContrib,
      netPay: net > 0 ? net : 0.0,
      earningsMap: earningsMap,
      deductionsMap: deductionsMap,
    );
  }
}
