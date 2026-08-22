import 'package:flutter_test/flutter_test.dart';
import 'package:dayflow/core/payroll/salary_component.dart';
import 'package:dayflow/core/payroll/salary_structure.dart';
import 'package:dayflow/core/payroll/payroll_engine.dart';
import 'package:dayflow/core/payroll/payroll_period.dart';
import 'package:dayflow/core/payroll/payroll_record.dart';

void main() {
  group('Dayflow Payroll Engine & Policy Tests', () {
    final standardStructure = const SalaryStructure(
      id: 'struct_1',
      organizationId: 'org_1',
      employeeId: 'emp_1',
      effectiveFrom: '2026-01-01',
      currency: 'INR',
      components: [
        SalaryComponent(id: 'c1', name: 'Basic Salary', code: 'BASIC', type: 'earning', amount: 30000.0),
        SalaryComponent(id: 'c2', name: 'House Rent Allowance', code: 'HRA', type: 'earning', amount: 15000.0),
        SalaryComponent(id: 'c3', name: 'Provident Fund', code: 'PF', type: 'deduction', amount: 1800.0),
        SalaryComponent(id: 'c4', name: 'Health Insurance', code: 'INS', type: 'deduction', amount: 1200.0),
      ],
    );

    test('Standard Payroll calculation produces correct Gross, Deductions, and Net Pay', () {
      final result = PayrollEngine.calculate(structure: standardStructure);

      // Gross = 30000 + 15000 = 45000.0
      expect(result.grossPay, equals(45000.0));
      // Deductions = 1800 + 1200 = 3000.0
      expect(result.totalDeductions, equals(3000.0));
      // Net = 45000 - 3000 = 42000.0
      expect(result.netPay, equals(42000.0));
    });

    test('Unpaid leave deduction prorates basic salary correctly', () {
      // 2 days unpaid leave (30000 / 22 * 2 = 2727.27)
      final result = PayrollEngine.calculate(
        structure: standardStructure,
        unpaidLeaveDays: 2.0,
      );

      expect(result.deductionsMap.containsKey('Unpaid Leave Deduction'), isTrue);
      expect(result.deductionsMap['Unpaid Leave Deduction'], equals(2727.27));
      expect(result.netPay, equals(39272.73));
    });

    test('Overtime pay increases gross pay deterministically', () {
      // 5 hours overtime at 200/hr = 1000
      final result = PayrollEngine.calculate(
        structure: standardStructure,
        payableOvertimeHours: 5.0,
        overtimeHourlyRate: 200.0,
      );

      expect(result.grossPay, equals(46000.0));
      expect(result.netPay, equals(43000.0));
    });

    test('Monetary values round deterministically to 2 decimal places', () {
      final rounded = PayrollEngine.round(1234.5678);
      expect(rounded, equals(1234.57));
    });

    test('PayrollPeriod and PayrollRecord model serialization', () {
      final period = PayrollPeriod(
        id: 'p1',
        organizationId: 'org_1',
        name: 'August 2026 Payroll',
        startDate: '2026-08-01',
        endDate: '2026-08-31',
        payDate: '2026-08-31',
        createdAt: DateTime.now(),
      );

      final record = PayrollRecord(
        id: 'r1',
        organizationId: 'org_1',
        payrollPeriodId: 'p1',
        employeeId: 'emp_1',
        salaryStructureId: 'struct_1',
        grossPay: 45000.0,
        totalDeductions: 3000.0,
        totalEmployerContributions: 0.0,
        netPay: 42000.0,
        earningsMap: {'BASIC': 30000.0, 'HRA': 15000.0},
        deductionsMap: {'PF': 1800.0, 'INS': 1200.0},
        calculatedAt: DateTime.now(),
      );

      expect(PayrollPeriod.fromMap(period.toMap()).name, equals('August 2026 Payroll'));
      expect(PayrollRecord.fromMap(record.toMap()).netPay, equals(42000.0));
    });
  });
}
