import 'shift.dart';

class AttendanceCalculationResult {
  final bool isLate;
  final int lateMinutes;
  final bool isEarlyDeparture;
  final int earlyDepartureMinutes;
  final int totalWorkedMinutes;
  final int overtimeMinutes;
  final String status; // 'present', 'half_day', 'absent'

  const AttendanceCalculationResult({
    required this.isLate,
    required this.lateMinutes,
    required this.isEarlyDeparture,
    required this.earlyDepartureMinutes,
    required this.totalWorkedMinutes,
    required this.overtimeMinutes,
    required this.status,
  });
}

/// Deterministic pure calculation engine for Dayflow attendance metrics.
class AttendanceEngine {
  /// Computes all attendance derived fields based on authoritative server timestamps and shift rules
  static AttendanceCalculationResult calculate({
    required DateTime checkInAt,
    required DateTime checkOutAt,
    required Shift shift,
    int expectedDurationMinutes = 480,
  }) {
    // 1. Calculate Worked Duration
    final workedMinutes = checkOutAt.difference(checkInAt).inMinutes;

    // 2. Parse Scheduled Start Time
    final startParts = shift.startTime.split(':');
    final shiftStartHour = int.parse(startParts[0]);
    final shiftStartMinute = int.parse(startParts[1]);

    final scheduledStart = DateTime(
      checkInAt.year,
      checkInAt.month,
      checkInAt.day,
      shiftStartHour,
      shiftStartMinute,
    );

    final gracePeriod = Duration(minutes: shift.gracePeriodMinutes);
    final allowedCheckIn = scheduledStart.add(gracePeriod);

    final isLate = checkInAt.isAfter(allowedCheckIn);
    final lateMinutes = isLate ? checkInAt.difference(scheduledStart).inMinutes : 0;

    // 3. Parse Scheduled End Time
    final endParts = shift.endTime.split(':');
    final shiftEndHour = int.parse(endParts[0]);
    final shiftEndMinute = int.parse(endParts[1]);

    final endDay = shift.isOvernight ? checkInAt.day + 1 : checkInAt.day;
    final scheduledEnd = DateTime(
      checkInAt.year,
      checkInAt.month,
      endDay,
      shiftEndHour,
      shiftEndMinute,
    );

    final isEarlyDeparture = checkOutAt.isBefore(scheduledEnd);
    final earlyDepartureMinutes = isEarlyDeparture ? scheduledEnd.difference(checkOutAt).inMinutes : 0;

    // 4. Calculate Overtime
    final overtimeMinutes = workedMinutes > expectedDurationMinutes
        ? workedMinutes - expectedDurationMinutes
        : 0;

    // 5. Determine Derived Status
    String status = 'present';
    if (workedMinutes < (expectedDurationMinutes / 2)) {
      status = 'half_day';
    } else if (workedMinutes == 0) {
      status = 'absent';
    }

    return AttendanceCalculationResult(
      isLate: isLate,
      lateMinutes: lateMinutes,
      isEarlyDeparture: isEarlyDeparture,
      earlyDepartureMinutes: earlyDepartureMinutes,
      totalWorkedMinutes: workedMinutes,
      overtimeMinutes: overtimeMinutes,
      status: status,
    );
  }
}
