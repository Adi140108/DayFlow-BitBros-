import 'package:flutter_test/flutter_test.dart';
import 'package:dayflow/core/auth/app_user.dart';
import 'package:dayflow/core/auth/app_role.dart';
import 'package:dayflow/core/auth/app_permission.dart';
import 'package:dayflow/core/auth/role_permissions.dart';
import 'package:dayflow/core/auth/firebase_auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() {
  group('Dayflow RBAC Security Tests', () {
    test('Organization Owner role has all permissions', () {
      expect(
        RolePermissions.hasPermission(AppRole.organizationOwner, AppPermission.organizationUpdate),
        isTrue,
      );
      expect(
        RolePermissions.hasPermission(AppRole.organizationOwner, AppRole.employee == AppRole.employee ? AppPermission.employeesDelete : AppPermission.organizationRead),
        isTrue,
      );
    });

    test('Standard Employee role does NOT have administrative permissions', () {
      expect(
        RolePermissions.hasPermission(AppRole.employee, AppPermission.employeesDelete),
        isFalse,
      );
      expect(
        RolePermissions.hasPermission(AppRole.employee, AppPermission.payrollModify),
        isFalse,
      );
      expect(
        RolePermissions.hasPermission(AppRole.employee, AppPermission.organizationUpdate),
        isFalse,
      );
      expect(
        RolePermissions.hasPermission(AppRole.employee, AppPermission.rolesManage),
        isFalse,
      );
    });

    test('Standard Employee role has self-scoped permissions', () {
      expect(
        RolePermissions.hasPermission(AppRole.employee, AppPermission.attendanceReadSelf),
        isTrue,
      );
      expect(
        RolePermissions.hasPermission(AppRole.employee, AppPermission.leaveCreate),
        isTrue,
      );
      expect(
        RolePermissions.hasPermission(AppRole.employee, AppPermission.payrollReadSelf),
        isTrue,
      );
    });
  });

  group('Dayflow Identity & Auth Helpers Tests', () {
    test('AppUser serialization to and from Map', () {
      final now = DateTime.now();
      final user = AppUser(
        uid: 'user_123',
        email: 'employee@company.com',
        displayName: 'Test User',
        isEmailVerified: true,
        createdAt: now,
      );

      final map = user.toMap();
      final parsed = AppUser.fromMap(map);

      expect(parsed.uid, equals('user_123'));
      expect(parsed.email, equals('employee@company.com'));
      expect(parsed.isEmailVerified, isTrue);
    });

    test('AppRole enum values and string parsing', () {
      expect(AppRole.organizationOwner.value, equals('organization_owner'));
      expect(AppRole.fromString('admin'), equals(AppRole.admin));
      expect(AppRole.fromString('unknown_string'), equals(AppRole.employee));
    });

    test('FirebaseAuthException error mapping', () {
      final e1 = FirebaseAuthException(code: 'wrong-password');
      final e2 = FirebaseAuthException(code: 'weak-password');
      final e3 = FirebaseAuthException(code: 'email-already-in-use');

      expect(FirebaseAuthService.mapAuthException(e1), equals('Invalid email or password.'));
      expect(FirebaseAuthService.mapAuthException(e2), equals('The password provided is too weak. Please use at least 8 characters.'));
      expect(FirebaseAuthService.mapAuthException(e3), equals('An account already exists for this email address.'));
    });
  });
}
