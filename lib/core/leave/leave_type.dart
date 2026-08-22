/// LeaveType domain model for Dayflow.
class LeaveType {
  final String id;
  final String organizationId;
  final String name; // e.g. 'Paid Leave', 'Sick Leave', 'Unpaid Leave'
  final String code; // e.g. 'PL', 'SL', 'UL'
  final bool isPaid;
  final bool requiresBalance;
  final bool halfDayAllowed;
  final String status; // 'active', 'inactive'

  const LeaveType({
    required this.id,
    required this.organizationId,
    required this.name,
    required this.code,
    this.isPaid = true,
    this.requiresBalance = true,
    this.halfDayAllowed = true,
    this.status = 'active',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'organizationId': organizationId,
      'name': name,
      'code': code,
      'isPaid': isPaid,
      'requiresBalance': requiresBalance,
      'halfDayAllowed': halfDayAllowed,
      'status': status,
    };
  }

  factory LeaveType.fromMap(Map<String, dynamic> map) {
    return LeaveType(
      id: map['id'] as String,
      organizationId: map['organizationId'] as String,
      name: map['name'] as String,
      code: map['code'] as String,
      isPaid: map['isPaid'] as bool? ?? true,
      requiresBalance: map['requiresBalance'] as bool? ?? true,
      halfDayAllowed: map['halfDayAllowed'] as bool? ?? true,
      status: map['status'] as String? ?? 'active',
    );
  }
}
