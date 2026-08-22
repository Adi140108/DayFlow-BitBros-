import '../auth/app_role.dart';

/// Organization Membership entity for Dayflow.
class OrganizationMembership {
  final String id;
  final String userId;
  final String organizationId;
  final AppRole role;
  final String status; // 'active', 'invited', 'suspended'
  final DateTime createdAt;

  const OrganizationMembership({
    required this.id,
    required this.userId,
    required this.organizationId,
    required this.role,
    this.status = 'active',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'organizationId': organizationId,
      'role': role.value,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory OrganizationMembership.fromMap(Map<String, dynamic> map) {
    return OrganizationMembership(
      id: map['id'] as String,
      userId: map['userId'] as String,
      organizationId: map['organizationId'] as String,
      role: AppRole.fromString(map['role'] as String),
      status: map['status'] as String? ?? 'active',
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
