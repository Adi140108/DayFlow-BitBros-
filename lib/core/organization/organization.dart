/// Multi-tenant Organization entity for Dayflow.
class Organization {
  final String id;
  final String name;
  final String legalName;
  final String ownerId;
  final String status; // 'active', 'suspended'
  final DateTime createdAt;

  const Organization({
    required this.id,
    required this.name,
    required this.legalName,
    required this.ownerId,
    this.status = 'active',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'legalName': legalName,
      'ownerId': ownerId,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Organization.fromMap(Map<String, dynamic> map) {
    return Organization(
      id: map['id'] as String,
      name: map['name'] as String,
      legalName: map['legalName'] as String? ?? map['name'] as String,
      ownerId: map['ownerId'] as String,
      status: map['status'] as String? ?? 'active',
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
