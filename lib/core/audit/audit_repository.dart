import 'package:cloud_firestore/cloud_firestore.dart';

class AuditLogItem {
  final String id;
  final String organizationId;
  final String actorId;
  final String actorName;
  final String action;
  final String resourceType;
  final String resourceId;
  final DateTime timestamp;

  const AuditLogItem({
    required this.id,
    required this.organizationId,
    required this.actorId,
    required this.actorName,
    required this.action,
    required this.resourceType,
    required this.resourceId,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'organizationId': organizationId,
      'actorId': actorId,
      'actorName': actorName,
      'action': action,
      'resourceType': resourceType,
      'resourceId': resourceId,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory AuditLogItem.fromMap(Map<String, dynamic> map) {
    return AuditLogItem(
      id: map['id'] as String,
      organizationId: map['organizationId'] as String,
      actorId: map['actorId'] as String,
      actorName: map['actorName'] as String? ?? 'System',
      action: map['action'] as String,
      resourceType: map['resourceType'] as String,
      resourceId: map['resourceId'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }
}

class AuditRepository {
  final FirebaseFirestore _firestore;

  AuditRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Logs an audit event
  Future<void> logEvent({
    required String organizationId,
    required String actorId,
    required String actorName,
    required String action,
    required String resourceType,
    required String resourceId,
  }) async {
    final ref = _firestore.collection('audit_logs').doc();
    final item = AuditLogItem(
      id: ref.id,
      organizationId: organizationId,
      actorId: actorId,
      actorName: actorName,
      action: action,
      resourceType: resourceType,
      resourceId: resourceId,
      timestamp: DateTime.now(),
    );
    await ref.set(item.toMap());
  }

  /// Fetches organization audit logs
  Future<List<AuditLogItem>> getAuditLogs(String orgId) async {
    final snapshot = await _firestore
        .collection('audit_logs')
        .where('organizationId', isEqualTo: orgId)
        .limit(50)
        .get();

    return snapshot.docs.map((doc) => AuditLogItem.fromMap(doc.data())).toList();
  }
}
