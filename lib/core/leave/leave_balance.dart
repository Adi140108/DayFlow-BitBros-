/// Employee Leave Balance domain model for Dayflow.
class LeaveBalance {
  final String id;
  final String organizationId;
  final String employeeId;
  final String leaveTypeId;
  final int year;
  final double allocated;
  final double accrued;
  final double used;
  final double pending;

  const LeaveBalance({
    required this.id,
    required this.organizationId,
    required this.employeeId,
    required this.leaveTypeId,
    required this.year,
    this.allocated = 0.0,
    this.accrued = 0.0,
    this.used = 0.0,
    this.pending = 0.0,
  });

  /// Available balance formula: (allocated + accrued) - used - pending
  double get available => (allocated + accrued) - used - pending;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'organizationId': organizationId,
      'employeeId': employeeId,
      'leaveTypeId': leaveTypeId,
      'year': year,
      'allocated': allocated,
      'accrued': accrued,
      'used': used,
      'pending': pending,
    };
  }

  factory LeaveBalance.fromMap(Map<String, dynamic> map) {
    return LeaveBalance(
      id: map['id'] as String,
      organizationId: map['organizationId'] as String,
      employeeId: map['employeeId'] as String,
      leaveTypeId: map['leaveTypeId'] as String,
      year: map['year'] as int,
      allocated: (map['allocated'] as num?)?.toDouble() ?? 0.0,
      accrued: (map['accrued'] as num?)?.toDouble() ?? 0.0,
      used: (map['used'] as num?)?.toDouble() ?? 0.0,
      pending: (map['pending'] as num?)?.toDouble() ?? 0.0,
    );
  }

  LeaveBalance copyWith({
    String? id,
    String? organizationId,
    String? employeeId,
    String? leaveTypeId,
    int? year,
    double? allocated,
    double? accrued,
    double? used,
    double? pending,
  }) {
    return LeaveBalance(
      id: id ?? this.id,
      organizationId: organizationId ?? this.organizationId,
      employeeId: employeeId ?? this.employeeId,
      leaveTypeId: leaveTypeId ?? this.leaveTypeId,
      year: year ?? this.year,
      allocated: allocated ?? this.allocated,
      accrued: accrued ?? this.accrued,
      used: used ?? this.used,
      pending: pending ?? this.pending,
    );
  }
}
