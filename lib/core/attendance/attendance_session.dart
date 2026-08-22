/// Attendance Work Session domain model.
class AttendanceSession {
  final String id;
  final String attendanceId;
  final String employeeId;
  final DateTime checkInAt;
  final DateTime? checkOutAt;
  final int durationMinutes;
  final String status; // 'active', 'completed'

  const AttendanceSession({
    required this.id,
    required this.attendanceId,
    required this.employeeId,
    required this.checkInAt,
    this.checkOutAt,
    this.durationMinutes = 0,
    this.status = 'active',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'attendanceId': attendanceId,
      'employeeId': employeeId,
      'checkInAt': checkInAt.toIso8601String(),
      'checkOutAt': checkOutAt?.toIso8601String(),
      'durationMinutes': durationMinutes,
      'status': status,
    };
  }

  factory AttendanceSession.fromMap(Map<String, dynamic> map) {
    return AttendanceSession(
      id: map['id'] as String,
      attendanceId: map['attendanceId'] as String,
      employeeId: map['employeeId'] as String,
      checkInAt: DateTime.parse(map['checkInAt'] as String),
      checkOutAt: map['checkOutAt'] != null ? DateTime.parse(map['checkOutAt'] as String) : null,
      durationMinutes: map['durationMinutes'] as int? ?? 0,
      status: map['status'] as String? ?? 'active',
    );
  }
}
