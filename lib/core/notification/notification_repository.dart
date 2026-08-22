import 'package:cloud_firestore/cloud_firestore.dart';
import 'app_notification.dart';

/// Repository for In-App Notifications and user read status management.
class NotificationRepository {
  final FirebaseFirestore _firestore;

  NotificationRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Fetches unread & recent notifications for a user
  Future<List<AppNotification>> getUserNotifications(String userId, {int limit = 20}) async {
    final snapshot = await _firestore
        .collection('notifications')
        .where('recipientUserId', isEqualTo: userId)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => AppNotification.fromMap(doc.data()))
        .toList();
  }

  /// Marks a specific notification as read
  Future<void> markAsRead(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).update({'isRead': true});
  }

  /// Marks all notifications for a user as read
  Future<void> markAllAsRead(String userId) async {
    final snapshot = await _firestore
        .collection('notifications')
        .where('recipientUserId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _firestore.batch();
    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }
}
