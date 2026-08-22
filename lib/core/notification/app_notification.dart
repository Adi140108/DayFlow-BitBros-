/// Centralized App Notification domain model for Dayflow.
class AppNotification {
  final String id;
  final String organizationId;
  final String recipientUserId;
  final String type; // 'leave_submitted', 'leave_approved', 'leave_rejected', 'leave_cancelled'
  final String title;
  final String message;
  final bool isRead;
  final String? relatedResourceType; // e.g. 'leaveRequest'
  final String? relatedResourceId;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.organizationId,
    required this.recipientUserId,
    required this.type,
    required this.title,
    required this.message,
    this.isRead = false,
    this.relatedResourceType,
    this.relatedResourceId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'organizationId': organizationId,
      'recipientUserId': recipientUserId,
      'type': type,
      'title': title,
      'message': message,
      'isRead': isRead,
      'relatedResourceType': relatedResourceType,
      'relatedResourceId': relatedResourceId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AppNotification.fromMap(Map<String, dynamic> map) {
    return AppNotification(
      id: map['id'] as String,
      organizationId: map['organizationId'] as String,
      recipientUserId: map['recipientUserId'] as String,
      type: map['type'] as String,
      title: map['title'] as String,
      message: map['message'] as String,
      isRead: map['isRead'] as bool? ?? false,
      relatedResourceType: map['relatedResourceType'] as String?,
      relatedResourceId: map['relatedResourceId'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
