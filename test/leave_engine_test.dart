import 'package:flutter_test/flutter_test.dart';
import 'package:dayflow/core/leave/leave_type.dart';
import 'package:dayflow/core/leave/leave_balance.dart';
import 'package:dayflow/core/leave/leave_request.dart';
import 'package:dayflow/core/notification/app_notification.dart';

void main() {
  group('Dayflow Leave Engine & Policy Tests', () {
    test('Working leave days calculation skips weekends', () {
      final start = DateTime(2026, 8, 21); // Friday
      final end = DateTime(2026, 8, 24); // Monday

      // Calculate working days (Friday + Monday = 2 days)
      double days = 0.0;
      DateTime current = start;
      while (!current.isAfter(end)) {
        if (current.weekday != DateTime.saturday && current.weekday != DateTime.sunday) {
          days += 1.0;
        }
        current = current.add(const Duration(days: 1));
      }

      expect(days, equals(2.0));
    });

    test('Available leave balance formula calculates correctly', () {
      const bal = LeaveBalance(
        id: 'bal_1',
        organizationId: 'org_1',
        employeeId: 'emp_1',
        leaveTypeId: 'paid',
        year: 2026,
        allocated: 15.0,
        accrued: 2.0,
        used: 3.0,
        pending: 2.0,
      );

      // (15 + 2) - 3 - 2 = 12.0
      expect(bal.available, equals(12.0));
    });

    test('LeaveType, LeaveRequest and AppNotification model serialization', () {
      const type = LeaveType(
        id: 'paid',
        organizationId: 'org_1',
        name: 'Paid Leave',
        code: 'PL',
      );

      final req = LeaveRequest(
        id: 'req_1',
        organizationId: 'org_1',
        employeeId: 'emp_1',
        leaveTypeId: 'paid',
        startDate: '2026-08-25',
        endDate: '2026-08-27',
        durationDays: 3.0,
        remarks: 'Vacation',
        submittedAt: DateTime.now(),
      );

      final notif = AppNotification(
        id: 'notif_1',
        organizationId: 'org_1',
        recipientUserId: 'emp_1',
        type: 'leave_approved',
        title: 'Leave Approved',
        message: 'Your leave has been approved.',
        createdAt: DateTime.now(),
      );

      expect(LeaveType.fromMap(type.toMap()).code, equals('PL'));
      expect(LeaveRequest.fromMap(req.toMap()).durationDays, equals(3.0));
      expect(AppNotification.fromMap(notif.toMap()).type, equals('leave_approved'));
    });
  });
}
