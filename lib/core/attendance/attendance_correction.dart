/// Attendance Correction Request domain model.
class AttendanceCorrection {
  final String id;
  final String organizationId;
  final String employeeId;
  final String attendanceId;
  final String attendanceDate;
  final String? originalCheckIn;
  final String? originalCheckOut;
  final String requestedCheckIn;
  final String requestedCheckOut;
  final String reason;
  final String requesterId;
  final String? reviewerId;
  final String? reviewerComment;
  final String status; // 'pending', 'approved', 'rejected'
  final DateTime createdAt;
  final DateTime? reviewedAt;

  const AttendanceCorrection({
    required this.id,
    required this.organizationId,
    required this.employeeId,
    required this.attendanceId,
    required this.attendanceDate,
    this.originalCheckIn,
    this.originalCheckOut,
    required this.requestedCheckIn,
    required this.requestedCheckOut,
    required this.reason,
    required this.requesterId,
    this.reviewerId,
    this.reviewerComment,
    this.status = 'pending',
    required this.createdAt,
    this.reviewedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'organizationId': organizationId,
      'employeeId': employeeId,
      'attendanceId': attendanceId,
      'attendanceDate': attendanceDate,
      'originalCheckIn': originalCheckIn,
      'originalCheckOut': originalCheckOut,
      'requestedCheckIn': requestedCheckIn,
      'requestedCheckOut': requestedCheckOut,
      'reason': reason,
      'requesterId': requesterId,
      'reviewerId': reviewerId,
      'reviewerComment': reviewerComment,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'reviewedAt': reviewedAt?.toIso8601String(),
    };
  }

  factory AttendanceCorrection.fromMap(Map<String, dynamic> map) {
    return AttendanceCorrection(
      id: map['id'] as String,
      organizationId: map['organizationId'] as String,
      employeeId: map['employeeId'] as String,
      attendanceId: map['attendanceId'] as String,
      attendanceDate: map['attendanceDate'] as String,
      originalCheckIn: map['originalCheckIn'] as String?,
      originalCheckOut: map['originalCheckOut'] as String?,
      requestedCheckIn: map['requestedCheckIn'] as String,
      requestedCheckOut: map['requestedCheckOut'] as String,
      reason: map['reason'] as String,
      requesterId: map['requesterId'] as String,
      reviewerId: map['reviewerId'] as String?,
      reviewerComment: map['reviewerComment'] as String?,
      status: map['status'] as String? ?? 'pending',
      createdAt: DateTime.parse(map['createdAt'] as String),
      reviewedAt: map['reviewedAt'] != null ? DateTime.parse(map['reviewedAt'] as String) : null,
    );
  }
}
