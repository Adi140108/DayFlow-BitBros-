/// Leave Request domain model for Dayflow.
class LeaveRequest {
  final String id;
  final String organizationId;
  final String employeeId;
  final String leaveTypeId;
  final String startDate; // YYYY-MM-DD
  final String endDate; // YYYY-MM-DD
  final double durationDays;
  final bool isHalfDay;
  final String? halfDayPosition; // 'first_half', 'second_half'
  final String remarks;
  final String status; // 'pending', 'approved', 'rejected', 'cancelled'
  final String? approverId;
  final String? reviewerComment;
  final DateTime submittedAt;
  final DateTime? reviewedAt;

  const LeaveRequest({
    required this.id,
    required this.organizationId,
    required this.employeeId,
    required this.leaveTypeId,
    required this.startDate,
    required this.endDate,
    required this.durationDays,
    this.isHalfDay = false,
    this.halfDayPosition,
    required this.remarks,
    this.status = 'pending',
    this.approverId,
    this.reviewerComment,
    required this.submittedAt,
    this.reviewedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'organizationId': organizationId,
      'employeeId': employeeId,
      'leaveTypeId': leaveTypeId,
      'startDate': startDate,
      'endDate': endDate,
      'durationDays': durationDays,
      'isHalfDay': isHalfDay,
      'halfDayPosition': halfDayPosition,
      'remarks': remarks,
      'status': status,
      'approverId': approverId,
      'reviewerComment': reviewerComment,
      'submittedAt': submittedAt.toIso8601String(),
      'reviewedAt': reviewedAt?.toIso8601String(),
    };
  }

  factory LeaveRequest.fromMap(Map<String, dynamic> map) {
    return LeaveRequest(
      id: map['id'] as String,
      organizationId: map['organizationId'] as String,
      employeeId: map['employeeId'] as String,
      leaveTypeId: map['leaveTypeId'] as String,
      startDate: map['startDate'] as String,
      endDate: map['endDate'] as String,
      durationDays: (map['durationDays'] as num?)?.toDouble() ?? 1.0,
      isHalfDay: map['isHalfDay'] as bool? ?? false,
      halfDayPosition: map['halfDayPosition'] as String?,
      remarks: map['remarks'] as String? ?? '',
      status: map['status'] as String? ?? 'pending',
      approverId: map['approverId'] as String?,
      reviewerComment: map['reviewerComment'] as String?,
      submittedAt: DateTime.parse(map['submittedAt'] as String),
      reviewedAt: map['reviewedAt'] != null ? DateTime.parse(map['reviewedAt'] as String) : null,
    );
  }
}
