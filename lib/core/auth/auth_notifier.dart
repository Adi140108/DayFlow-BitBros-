import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../organization/organization.dart';
import '../organization/organization_membership.dart';
import '../organization/organization_repository.dart';
import 'app_permission.dart';
import 'app_role.dart';
import 'app_user.dart';
import 'firebase_auth_service.dart';
import 'role_permissions.dart';
import 'user_repository.dart';

enum AuthSessionStatus {
  initializing,
  unauthenticated,
  unverified,
  noOrganization,
  authenticated,
  error,
}

class AuthSessionState {
  final AuthSessionStatus status;
  final AppUser? user;
  final Organization? activeOrganization;
  final OrganizationMembership? activeMembership;
  final String? errorMessage;

  AppRole? get activeRole => activeMembership?.role;

  const AuthSessionState({
    required this.status,
    this.user,
    this.activeOrganization,
    this.activeMembership,
    this.errorMessage,
  });

  const AuthSessionState.initializing()
      : status = AuthSessionStatus.initializing,
        user = null,
        activeOrganization = null,
        activeMembership = null,
        errorMessage = null;

  const AuthSessionState.unauthenticated()
      : status = AuthSessionStatus.unauthenticated,
        user = null,
        activeOrganization = null,
        activeMembership = null,
        errorMessage = null;

  const AuthSessionState.unverified(AppUser u)
      : status = AuthSessionStatus.unverified,
        user = u,
        activeOrganization = null,
        activeMembership = null,
        errorMessage = null;

  const AuthSessionState.noOrganization(AppUser u)
      : status = AuthSessionStatus.noOrganization,
        user = u,
        activeOrganization = null,
        activeMembership = null,
        errorMessage = null;

  const AuthSessionState.authenticated({
    required this.user,
    required Organization organization,
    required OrganizationMembership membership,
  })  : status = AuthSessionStatus.authenticated,
        activeOrganization = organization,
        activeMembership = membership,
        errorMessage = null;

  const AuthSessionState.error(String message)
      : status = AuthSessionStatus.error,
        user = null,
        activeOrganization = null,
        activeMembership = null,
        errorMessage = message;
}

class AuthNotifier extends ChangeNotifier {
  final FirebaseAuthService _authService;
  final UserRepository _userRepo;
  final OrganizationRepository _orgRepo;
  StreamSubscription? _authSub;

  AuthSessionState _state = const AuthSessionState.initializing();
  AuthSessionState get state => _state;

  AuthNotifier({
    FirebaseAuthService? authService,
    UserRepository? userRepo,
    OrganizationRepository? orgRepo,
  })  : _authService = authService ?? FirebaseAuthService(),
        _userRepo = userRepo ?? UserRepository(),
        _orgRepo = orgRepo ?? OrganizationRepository() {
    _init();
  }

  void _init() {
    _authSub = _authService.authStateChanges.listen((fbUser) async {
      if (fbUser == null) {
        _state = const AuthSessionState.unauthenticated();
        notifyListeners();
        return;
      }

      final appUser = AppUser(
        uid: fbUser.uid,
        email: fbUser.email ?? '',
        displayName: fbUser.displayName,
        isEmailVerified: fbUser.emailVerified,
        createdAt: DateTime.now(),
      );

      // Save/Merge user document
      await _userRepo.saveUser(appUser);

      // Skip email verification — go directly to org resolution
      // Resolve Organization Memberships
      await resolveUserOrganization(appUser);
    });
  }

  Future<void> resolveUserOrganization(AppUser appUser) async {
    try {
      final memberships = await _orgRepo.getUserMemberships(appUser.uid);
      if (memberships.isEmpty) {
        _state = AuthSessionState.noOrganization(appUser);
        notifyListeners();
        return;
      }

      final activeMembership = memberships.first;
      final org = await _orgRepo.getOrganization(activeMembership.organizationId);

      if (org == null) {
        _state = AuthSessionState.noOrganization(appUser);
        notifyListeners();
        return;
      }

      _state = AuthSessionState.authenticated(
        user: appUser,
        organization: org,
        membership: activeMembership,
      );
      notifyListeners();
    } catch (e) {
      _state = AuthSessionState.error(e.toString());
      notifyListeners();
    }
  }

  /// Evaluates whether the current active user has the specified [permission]
  bool can(AppPermission permission) {
    if (_state.status != AuthSessionStatus.authenticated || _state.activeMembership == null) {
      return false;
    }
    return RolePermissions.hasPermission(_state.activeMembership!.role, permission);
  }

  /// Sign In handler
  Future<void> signIn(String email, String password) async {
    try {
      await _authService.signIn(email: email, password: password);
    } catch (e) {
      _state = AuthSessionState.error(e.toString());
      notifyListeners();
      rethrow;
    }
  }

  /// Sign Up handler
  Future<void> signUp(String email, String password, String name) async {
    try {
      await _authService.signUp(email: email, password: password, displayName: name);
    } catch (e) {
      _state = AuthSessionState.error(e.toString());
      notifyListeners();
      rethrow;
    }
  }

  /// Create Organization handler
  Future<void> createOrganization(String name, String legalName) async {
    if (_state.user == null) return;
    try {
      await _orgRepo.createOrganization(
        name: name,
        legalName: legalName,
        ownerUid: _state.user!.uid,
      );
      await resolveUserOrganization(_state.user!);
    } catch (e) {
      _state = AuthSessionState.error(e.toString());
      notifyListeners();
      rethrow;
    }
  }

  /// Sign Out handler
  Future<void> signOut() async {
    await _authService.signOut();
    _state = const AuthSessionState.unauthenticated();
    notifyListeners();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}

final authNotifierProvider = Provider<AuthNotifier>((ref) {
  final notifier = AuthNotifier();
  ref.onDispose(() => notifier.dispose());
  return notifier;
});
