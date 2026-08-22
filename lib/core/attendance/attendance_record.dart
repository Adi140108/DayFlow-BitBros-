/// Attendance Record domain model for Dayflow.
class AttendanceRecord {
  final String id;
  final String organizationId;
  final String employeeId;
  final String attendanceDate; // YYYY-MM-DD
  final String timezone;
  final String? scheduleId;
  final String status; // 'present', 'absent', 'half_day', 'leave'
  final int totalWorkedMinutes;
  final int expectedWorkedMinutes;
  final int overtimeMinutes;
  final bool isLate;
  final int lateMinutes;
  final bool isEarlyDeparture;
  final int earlyDepartureMinutes;
  final String? checkInAt; // ISO DateTime
  final String? checkOutAt; // ISO DateTime
  final String correctionStatus; // 'none', 'pending', 'approved', 'rejected'
  final DateTime createdAt;
  final DateTime updatedAt;

  const AttendanceRecord({
    required this.id,
    required this.organizationId,
    required this.employeeId,
    required this.attendanceDate,
    this.timezone = 'UTC',
    this.scheduleId,
    this.status = 'present',
    this.totalWorkedMinutes = 0,
    this.expectedWorkedMinutes = 480,
    this.overtimeMinutes = 0,
    this.isLate = false,
    this.lateMinutes = 0,
    this.isEarlyDeparture = false,
    this.earlyDepartureMinutes = 0,
    this.checkInAt,
    this.checkOutAt,
    this.correctionStatus = 'none',
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'organizationId': organizationId,
      'employeeId': employeeId,
      'attendanceDate': attendanceDate,
      'timezone': timezone,
      'scheduleId': scheduleId,
      'status': status,
      'totalWorkedMinutes': totalWorkedMinutes,
      'expectedWorkedMinutes': expectedWorkedMinutes,
      'overtimeMinutes': overtimeMinutes,
      'isLate': isLate,
      'lateMinutes': lateMinutes,
      'isEarlyDeparture': isEarlyDeparture,
      'earlyDepartureMinutes': earlyDepartureMinutes,
      'checkInAt': checkInAt,
      'checkOutAt': checkOutAt,
      'correctionStatus': correctionStatus,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory AttendanceRecord.fromMap(Map<String, dynamic> map) {
    return AttendanceRecord(
      id: map['id'] as String,
      organizationId: map['organizationId'] as String,
      employeeId: map['employeeId'] as String,
      attendanceDate: map['attendanceDate'] as String,
      timezone: map['timezone'] as String? ?? 'UTC',
      scheduleId: map['scheduleId'] as String?,
      status: map['status'] as String? ?? 'present',
      totalWorkedMinutes: map['totalWorkedMinutes'] as int? ?? 0,
      expectedWorkedMinutes: map['expectedWorkedMinutes'] as int? ?? 480,
      overtimeMinutes: map['overtimeMinutes'] as int? ?? 0,
      isLate: map['isLate'] as bool? ?? false,
      lateMinutes: map['lateMinutes'] as int? ?? 0,
      isEarlyDeparture: map['isEarlyDeparture'] as bool? ?? false,
      earlyDepartureMinutes: map['earlyDepartureMinutes'] as int? ?? 0,
      checkInAt: map['checkInAt'] as String?,
      checkOutAt: map['checkOutAt'] as String?,
      correctionStatus: map['correctionStatus'] as String? ?? 'none',
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  AttendanceRecord copyWith({
    String? id,
    String? organizationId,
    String? employeeId,
    String? attendanceDate,
    String? timezone,
    String? scheduleId,
    String? status,
    int? totalWorkedMinutes,
    int? expectedWorkedMinutes,
    int? overtimeMinutes,
    bool? isLate,
    int? lateMinutes,
    bool? isEarlyDeparture,
    int? earlyDepartureMinutes,
    String? checkInAt,
    String? checkOutAt,
    String? correctionStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AttendanceRecord(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      employeeId: employeeId ?? this.employeeId,
      attendanceDate: attendanceDate ?? this.attendanceDate,
      timezone: timezone ?? this.timezone,
      scheduleId: scheduleId ?? this.scheduleId,
      status: status ?? this.status,
      totalWorkedMinutes: totalWorkedMinutes ?? this.totalWorkedMinutes,
      expectedWorkedMinutes: expectedWorkedMinutes ?? this.expectedWorkedMinutes,
      overtimeMinutes: overtimeMinutes ?? this.overtimeMinutes,
      isLate: isLate ?? this.isLate,
      lateMinutes: lateMinutes ?? this.lateMinutes,
      isEarlyDeparture: isEarlyDeparture ?? this.isEarlyDeparture,
      earlyDepartureMinutes: earlyDepartureMinutes ?? this.earlyDepartureMinutes,
      checkInAt: checkInAt ?? this.checkInAt,
      checkOutAt: checkOutAt ?? this.checkOutAt,
      correctionStatus: correctionStatus ?? this.correctionStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
