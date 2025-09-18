// Role constants for consistent role management across the Flutter application

class Roles {
  // Frontend role names (used in UI)
  static const String organizationAdmin = 'OrganizationAdmin';
  static const String ngoMaster = 'NGO Master';
  static const String admin = 'Admin';
  static const String professional = 'Professional';
  static const String teacher = 'Teacher';
  static const String parent = 'Parent';
}

class BackendRoles {
  // Backend role names (used in API calls)
  static const String organizationAdmin = 'OrganizationAdmin';
  static const String ngoAdmin = 'NGOAdmin';
  static const String schoolAdmin = 'SchoolAdmin';
  static const String professional = 'Professional';
  static const String teacher = 'Teacher';
  static const String parent = 'Parent';
}

class RoleMapping {
  // Map frontend roles to backend roles
  static const Map<String, String> frontendToBackend = {
    Roles.organizationAdmin: BackendRoles.organizationAdmin,
    Roles.ngoMaster: BackendRoles.ngoAdmin,
    Roles.admin: BackendRoles.schoolAdmin,
    Roles.professional: BackendRoles.professional,
    Roles.teacher: BackendRoles.teacher,
    Roles.parent: BackendRoles.parent,
  };

  // Map backend roles to frontend roles
  static const Map<String, String> backendToFrontend = {
    BackendRoles.organizationAdmin: Roles.organizationAdmin,
    BackendRoles.ngoAdmin: Roles.ngoMaster,
    BackendRoles.schoolAdmin: Roles.admin,
    BackendRoles.professional: Roles.professional,
    BackendRoles.teacher: Roles.teacher,
    BackendRoles.parent: Roles.parent,
  };

  // Helper methods
  static String normalizeRole(String role) {
    return frontendToBackend[role] ?? role;
  }

  static String denormalizeRole(String role) {
    return backendToFrontend[role] ?? role;
  }
}

class RoleHierarchy {
  // Role hierarchy for permissions (lower number = higher permission)
  static const Map<String, int> hierarchy = {
    Roles.organizationAdmin: 1,
    Roles.ngoMaster: 2,
    Roles.admin: 3,
    Roles.professional: 4,
    Roles.teacher: 5,
    Roles.parent: 6,
  };

  static bool hasPermission(String userRole, String requiredRole) {
    final userLevel = hierarchy[userRole];
    final requiredLevel = hierarchy[requiredRole];
    return userLevel != null && requiredLevel != null && userLevel <= requiredLevel;
  }

  static bool isAdminRole(String role) {
    return [Roles.organizationAdmin, Roles.ngoMaster, Roles.admin].contains(role);
  }

  static bool isUserRole(String role) {
    return [Roles.professional, Roles.teacher, Roles.parent].contains(role);
  }
}
