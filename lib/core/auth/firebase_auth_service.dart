import 'package:firebase_auth/firebase_auth.dart';
import 'app_user.dart';

/// Service interfacing directly with Firebase Authentication SDK.
class FirebaseAuthService {
  final FirebaseAuth _firebaseAuth;

  FirebaseAuthService({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
  User? get currentUser => _firebaseAuth.currentUser;

  /// Signs up a new user with email and password
  Future<AppUser> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user!;
      if (displayName != null) {
        await user.updateDisplayName(displayName);
      }
      await user.sendEmailVerification();

      return AppUser(
        uid: user.uid,
        email: user.email!,
        displayName: displayName ?? user.displayName,
        isEmailVerified: user.emailVerified,
        createdAt: DateTime.now(),
      );
    } on FirebaseAuthException catch (e) {
      throw mapAuthException(e);
    }
  }

  /// Signs in an existing user with email and password
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user!;
      return AppUser(
        uid: user.uid,
        email: user.email!,
        displayName: user.displayName,
        isEmailVerified: user.emailVerified,
        createdAt: DateTime.now(),
      );
    } on FirebaseAuthException catch (e) {
      throw mapAuthException(e);
    }
  }

  /// Sends email verification to current user
  Future<void> sendEmailVerification() async {
    try {
      await _firebaseAuth.currentUser?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw mapAuthException(e);
    }
  }

  /// Sends password reset email
  Future<void> sendPasswordReset(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw mapAuthException(e);
    }
  }

  /// Reloads current user auth state
  Future<void> reloadUser() async {
    await _firebaseAuth.currentUser?.reload();
  }

  /// Signs out current user
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  /// User-safe error message mapping for FirebaseAuthException
  static String mapAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'email-already-in-use':
        return 'An account already exists for this email address.';
      case 'weak-password':
        return 'The password provided is too weak. Please use at least 8 characters.';
      case 'too-many-requests':
        return 'Too many unsuccessful attempts. Please try again later.';
      default:
        return e.message ?? 'An unexpected authentication error occurred.';
    }
  }
}
