/// Strongly-typed Roles supported in Dayflow HRMS.
enum AppRole {
  organizationOwner,
  admin,
  hrManager,
  hr,
  manager,
  employee;

  String get value {
    switch (this) {
      case AppRole.organizationOwner:
        return 'organization_owner';
      case AppRole.admin:
        return 'admin';
      case AppRole.hrManager:
        return 'hr_manager';
      case AppRole.hr:
        return 'hr';
      case AppRole.manager:
        return 'manager';
      case AppRole.employee:
        return 'employee';
    }
  }

  static AppRole fromString(String val) {
    switch (val) {
      case 'organization_owner':
        return AppRole.organizationOwner;
      case 'admin':
        return AppRole.admin;
      case 'hr_manager':
        return AppRole.hrManager;
      case 'hr':
        return AppRole.hr;
      case 'manager':
        return AppRole.manager;
      case 'employee':
      default:
        return AppRole.employee;
    }
  }
}
