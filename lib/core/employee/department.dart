/// Department domain model for Dayflow.
class Department {
  final String id;
  final String organizationId;
  final String name;
  final String code;
  final String status; // 'active', 'inactive'

  const Department({
    required this.id,
    required this.organizationId,
    required this.name,
    required this.code,
    this.status = 'active',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'organizationId': organizationId,
      'name': name,
      'code': code,
      'status': status,
    };
  }

  factory Department.fromMap(Map<String, dynamic> map) {
    return Department(
      id: map['id'] as String,
      organizationId: map['organizationId'] as String,
      name: map['name'] as String,
      code: map['code'] as String,
      status: map['status'] as String? ?? 'active',
    );
  }
}
