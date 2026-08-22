/// Shift domain model supporting overnight shifts.
class Shift {
  final String id;
  final String organizationId;
  final String name;
  final String startTime; // "09:00"
  final String endTime; // "17:00" or "06:00" (overnight)
  final String timezone;
  final bool isOvernight;
  final int gracePeriodMinutes;
  final String status;

  const Shift({
    required this.id,
    required this.organizationId,
    required this.name,
    required this.startTime,
    required this.endTime,
    this.timezone = 'UTC',
    this.isOvernight = false,
    this.gracePeriodMinutes = 15,
    this.status = 'active',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'organizationId': organizationId,
      'name': name,
      'startTime': startTime,
      'endTime': endTime,
      'timezone': timezone,
      'isOvernight': isOvernight,
      'gracePeriodMinutes': gracePeriodMinutes,
      'status': status,
    };
  }

  factory Shift.fromMap(Map<String, dynamic> map) {
    return Shift(
      id: map['id'] as String,
      organizationId: map['organizationId'] as String,
      name: map['name'] as String,
      startTime: map['startTime'] as String,
      endTime: map['endTime'] as String,
      timezone: map['timezone'] as String? ?? 'UTC',
      isOvernight: map['isOvernight'] as bool? ?? false,
      gracePeriodMinutes: map['gracePeriodMinutes'] as int? ?? 15,
      status: map['status'] as String? ?? 'active',
    );
  }
}
