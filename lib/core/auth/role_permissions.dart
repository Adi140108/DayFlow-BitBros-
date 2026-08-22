import 'app_permission.dart';
import 'app_role.dart';

/// Centralized Role-to-Permission policy mapping for Dayflow.
abstract class RolePermissions {
  static final Map<AppRole, Set<AppPermission>> _policy = {
    AppRole.organizationOwner: AppPermission.values.toSet(),
    AppRole.admin: {
      AppPermission.employeesRead,
      AppPermission.employeesCreate,
      AppPermission.employeesUpdate,
      AppPermission.employeesDelete,
      AppPermission.attendanceReadAll,
      AppPermission.attendanceModify,
      AppPermission.leaveReadAll,
      AppPermission.leaveApprove,
      AppPermission.leaveReject,
      AppPermission.payrollReadAll,
      AppPermission.payrollModify,
      AppPermission.documentsReadAll,
      AppPermission.documentsUpload,
      AppPermission.documentsDelete,
      AppPermission.reportsRead,
      AppPermission.analyticsRead,
      AppPermission.organizationRead,
      AppPermission.organizationUpdate,
      AppPermission.rolesRead,
      AppPermission.rolesManage,
    },
    AppRole.hrManager: {
      AppPermission.employeesRead,
      AppPermission.employeesCreate,
      AppPermission.employeesUpdate,
      AppPermission.attendanceReadAll,
      AppPermission.leaveReadAll,
      AppPermission.leaveApprove,
      AppPermission.leaveReject,
      AppPermission.payrollReadAll,
      AppPermission.documentsReadAll,
      AppPermission.documentsUpload,
      AppPermission.reportsRead,
      AppPermission.analyticsRead,
      AppPermission.organizationRead,
    },
    AppRole.hr: {
      AppPermission.employeesRead,
      AppPermission.attendanceReadAll,
      AppPermission.leaveReadAll,
      AppPermission.leaveApprove,
      AppPermission.documentsReadAll,
      AppPermission.documentsUpload,
      AppPermission.organizationRead,
    },
    AppRole.manager: {
      AppPermission.employeesRead,
      AppPermission.attendanceReadTeam,
      AppPermission.leaveReadTeam,
      AppPermission.leaveApprove,
      AppPermission.leaveReject,
      AppPermission.documentsReadSelf,
      AppPermission.organizationRead,
    },
    AppRole.employee: {
      AppPermission.attendanceReadSelf,
      AppPermission.leaveCreate,
      AppPermission.leaveReadSelf,
      AppPermission.payrollReadSelf,
      AppPermission.documentsReadSelf,
      AppPermission.organizationRead,
    },
  };

  /// Returns true if the specified [role] has the given [permission].
  static bool hasPermission(AppRole role, AppPermission permission) {
    final permissions = _policy[role];
    return permissions?.contains(permission) ?? false;
  }

  /// Returns all effective permissions for a given [role].
  static Set<AppPermission> getPermissions(AppRole role) {
    return _policy[role] ?? {};
  }
}
