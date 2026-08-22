/// Work Location domain model for Dayflow.
class Location {
  final String id;
  final String organizationId;
  final String name;
  final String? address;
  final String? timezone;
  final String status; // 'active', 'inactive'

  const Location({
    required this.id,
    required this.organizationId,
    required this.name,
    this.address,
    this.timezone = 'UTC',
    this.status = 'active',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'organizationId': organizationId,
      'name': name,
      'address': address,
      'timezone': timezone,
      'status': status,
    };
  }

  factory Location.fromMap(Map<String, dynamic> map) {
    return Location(
      id: map['id'] as String,
      organizationId: map['organizationId'] as String,
      name: map['name'] as String,
      address: map['address'] as String?,
      timezone: map['timezone'] as String? ?? 'UTC',
      status: map['status'] as String? ?? 'active',
    );
  }
}
