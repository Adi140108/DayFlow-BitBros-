import 'package:flutter_test/flutter_test.dart';
import 'package:dayflow/core/attendance/shift.dart';
import 'package:dayflow/core/attendance/work_schedule.dart';
import 'package:dayflow/core/attendance/attendance_engine.dart';
import 'package:dayflow/core/attendance/attendance_correction.dart';

void main() {
  group('Dayflow Attendance Engine Tests', () {
    final standardShift = const Shift(
      id: 'shift_1',
      organizationId: 'org_1',
      name: 'Standard Shift',
      startTime: '09:00',
      endTime: '17:00',
      gracePeriodMinutes: 15,
    );

    test('On-time arrival within grace period is not flagged as late', () {
      final checkIn = DateTime(2026, 8, 22, 9, 10); // 09:10 (within 15m grace)
      final checkOut = DateTime(2026, 8, 22, 17, 0);

      final result = AttendanceEngine.calculate(
        checkInAt: checkIn,
        checkOutAt: checkOut,
        shift: standardShift,
      );

      expect(result.isLate, isFalse);
      expect(result.lateMinutes, equals(0));
      expect(result.status, equals('present'));
    });

    test('Late arrival past grace period is correctly flagged with duration', () {
      final checkIn = DateTime(2026, 8, 22, 9, 25); // 09:25 (25 mins late)
      final checkOut = DateTime(2026, 8, 22, 17, 0);

      final result = AttendanceEngine.calculate(
        checkInAt: checkIn,
        checkOutAt: checkOut,
        shift: standardShift,
      );

      expect(result.isLate, isTrue);
      expect(result.lateMinutes, equals(25));
    });

    test('Overtime is calculated correctly when worked duration exceeds expected duration', () {
      final checkIn = DateTime(2026, 8, 22, 9, 0);
      final checkOut = DateTime(2026, 8, 22, 19, 0); // 10 hours worked (600 mins)

      final result = AttendanceEngine.calculate(
        checkInAt: checkIn,
        checkOutAt: checkOut,
        shift: standardShift,
        expectedDurationMinutes: 480, // 8 hours
      );

      expect(result.totalWorkedMinutes, equals(600));
      expect(result.overtimeMinutes, equals(120)); // 2 hours overtime
    });

    test('WorkSchedule and AttendanceCorrection model serialization', () {
      final schedule = WorkSchedule(
        id: 'sch_1',
        organizationId: 'org_1',
        name: 'Flexi Schedule',
        shiftId: 'shift_1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final corr = AttendanceCorrection(
        id: 'corr_1',
        organizationId: 'org_1',
        employeeId: 'emp_1',
        attendanceId: 'rec_1',
        attendanceDate: '2026-08-22',
        requestedCheckIn: '2026-08-22T09:00:00Z',
        requestedCheckOut: '2026-08-22T17:00:00Z',
        reason: 'Network outage during check in',
        requesterId: 'emp_1',
        createdAt: DateTime.now(),
      );

      expect(WorkSchedule.fromMap(schedule.toMap()).name, equals('Flexi Schedule'));
      expect(AttendanceCorrection.fromMap(corr.toMap()).reason, equals('Network outage during check in'));
    });
  });
}
