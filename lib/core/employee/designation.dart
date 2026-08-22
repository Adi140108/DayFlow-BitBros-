/// Designation domain model for Dayflow.
class Designation {
  final String id;
  final String organizationId;
  final String name;
  final String? departmentId;
  final String status; // 'active', 'inactive'

  const Designation({
    required this.id,
    required this.organizationId,
    required this.name,
    this.departmentId,
    this.status = 'active',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'organizationId': organizationId,
      'name': name,
      'departmentId': departmentId,
      'status': status,
    };
  }

  factory Designation.fromMap(Map<String, dynamic> map) {
    return Designation(
      id: map['id'] as String,
      organizationId: map['organizationId'] as String,
      name: map['name'] as String,
      departmentId: map['departmentId'] as String?,
      status: map['status'] as String? ?? 'active',
    );
  }
}
