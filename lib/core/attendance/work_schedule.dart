/// Work Schedule domain model for Dayflow.
class WorkSchedule {
  final String id;
  final String organizationId;
  final String name;
  final String timezone; // e.g. "Asia/Kolkata", "UTC", "America/New_York"
  final List<int> workingDays; // 1 = Monday, 7 = Sunday
  final String shiftId;
  final int gracePeriodMinutes; // e.g. 15
  final int expectedDurationMinutes; // e.g. 480 (8 hours)
  final String status; // 'active', 'inactive'
  final DateTime createdAt;
  final DateTime updatedAt;

  const WorkSchedule({
    required this.id,
    required this.organizationId,
    required this.name,
    this.timezone = 'UTC',
    this.workingDays = const [1, 2, 3, 4, 5],
    required this.shiftId,
    this.gracePeriodMinutes = 15,
    this.expectedDurationMinutes = 480,
    this.status = 'active',
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'organizationId': organizationId,
      'name': name,
      'timezone': timezone,
      'workingDays': workingDays,
      'shiftId': shiftId,
      'gracePeriodMinutes': gracePeriodMinutes,
      'expectedDurationMinutes': expectedDurationMinutes,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory WorkSchedule.fromMap(Map<String, dynamic> map) {
    return WorkSchedule(
      id: map['id'] as String,
      organizationId: map['organizationId'] as String,
      name: map['name'] as String,
      timezone: map['timezone'] as String? ?? 'UTC',
      workingDays: List<int>.from(map['workingDays'] ?? [1, 2, 3, 4, 5]),
      shiftId: map['shiftId'] as String,
      gracePeriodMinutes: map['gracePeriodMinutes'] as int? ?? 15,
      expectedDurationMinutes: map['expectedDurationMinutes'] as int? ?? 480,
      status: map['status'] as String? ?? 'active',
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }
}
