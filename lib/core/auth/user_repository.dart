import 'package:cloud_firestore/cloud_firestore.dart';
import 'app_user.dart';

/// Firestore repository for user profile documents in `users/{userId}`.
class UserRepository {
  final FirebaseFirestore _firestore;

  UserRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Creates or updates a user document
  Future<void> saveUser(AppUser user) async {
    await _firestore.collection('users').doc(user.uid).set(
          user.toMap(),
          SetOptions(merge: true),
        );
  }

  /// Fetches user document by UID
  Future<AppUser?> getUser(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return AppUser.fromMap(doc.data()!);
    }
    return null;
  }
}
