/// Leave Policy rules model for Dayflow.
class LeavePolicy {
  final String id;
  final String organizationId;
  final String leaveTypeId;
  final double defaultAllocation; // e.g. 20.0 days
  final int maxConsecutiveDays;
  final bool allowHalfDay;

  const LeavePolicy({
    required this.id,
    required this.organizationId,
    required this.leaveTypeId,
    this.defaultAllocation = 15.0,
    this.maxConsecutiveDays = 14,
    this.allowHalfDay = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'organizationId': organizationId,
      'leaveTypeId': leaveTypeId,
      'defaultAllocation': defaultAllocation,
      'maxConsecutiveDays': maxConsecutiveDays,
      'allowHalfDay': allowHalfDay,
    };
  }

  factory LeavePolicy.fromMap(Map<String, dynamic> map) {
    return LeavePolicy(
      id: map['id'] as String,
      organizationId: map['organizationId'] as String,
      leaveTypeId: map['leaveTypeId'] as String,
      defaultAllocation: (map['defaultAllocation'] as num?)?.toDouble() ?? 15.0,
      maxConsecutiveDays: map['maxConsecutiveDays'] as int? ?? 14,
      allowHalfDay: map['allowHalfDay'] as bool? ?? true,
    );
  }
}
