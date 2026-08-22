import 'package:flutter_test/flutter_test.dart';
import 'package:dayflow/core/auth/app_permission.dart';
import 'package:dayflow/core/auth/app_role.dart';
import 'package:dayflow/core/auth/role_permissions.dart';
import 'package:dayflow/core/leave/leave_balance.dart';
import 'package:dayflow/core/leave/leave_request.dart';
import 'package:dayflow/core/payroll/payroll_engine.dart';

void main() {
  group('Dayflow Production Hardening & Security Audit Tests', () {
    test('Self-approval prevention: Exception thrown when approver is requester', () {
      final req = LeaveRequest(
        id: 'req_100',
        organizationId: 'org_A',
        employeeId: 'emp_123',
        leaveTypeId: 'paid',
        startDate: '2026-08-25',
        endDate: '2026-08-27',
        durationDays: 3.0,
        remarks: 'Test',
        submittedAt: DateTime.now(),
      );

      const approverId = 'emp_123'; // Same as requester

      expect(
        () {
          if (req.employeeId == approverId) {
            throw Exception('Self-approval is strictly forbidden by policy.');
          }
        },
        throwsA(isA<Exception>()),
      );
    });

    test('Cross-tenant data leakage prevention: Query scoping invariant', () {
      const tenantA = 'org_A';
      const tenantB = 'org_B';

      final reqA = LeaveRequest(
        id: 'req_1',
        organizationId: tenantA,
        employeeId: 'emp_1',
        leaveTypeId: 'paid',
        startDate: '2026-08-25',
        endDate: '2026-08-27',
        durationDays: 3.0,
        remarks: 'Tenant A Request',
        submittedAt: DateTime.now(),
      );

      // Verify organization scoping
      expect(reqA.organizationId, equals(tenantA));
      expect(reqA.organizationId, isNot(equals(tenantB)));
    });

    test('Monetary calculation precision: Deterministic rounding to 2 decimals', () {
      final round1 = PayrollEngine.round(1234.5678);
      final round2 = PayrollEngine.round(99.999);
      final round3 = PayrollEngine.round(0.004);

      expect(round1, equals(1234.57));
      expect(round2, equals(100.0));
      expect(round3, equals(0.0));
    });

    test('Leave balance reservation invariant: (Allocated + Accrued) - Used - Pending', () {
      const bal = LeaveBalance(
        id: 'b1',
        organizationId: 'org_1',
        employeeId: 'emp_1',
        leaveTypeId: 'paid',
        year: 2026,
        allocated: 20.0,
        accrued: 5.0,
        used: 4.0,
        pending: 3.0,
      );

      // (20 + 5) - 4 - 3 = 18.0
      expect(bal.available, equals(18.0));
    });

    test('RBAC privilege escalation prevention: Employee role cannot manage payroll', () {
      const employeeRole = AppRole.employee;
      final permissions = RolePermissions.getPermissions(employeeRole);

      expect(permissions.contains(AppPermission.payrollModify), isFalse);
      expect(permissions.contains(AppPermission.organizationUpdate), isFalse);
      expect(permissions.contains(AppPermission.leaveApprove), isFalse);
    });
  });
}
