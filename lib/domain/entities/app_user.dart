enum UserRole { admin, manager, staff, finance, viewer }

extension UserRoleExt on UserRole {
  String get label {
    switch (this) {
      case UserRole.admin:   return 'Admin';
      case UserRole.manager: return 'Manager';
      case UserRole.staff:   return 'Staff';
      case UserRole.finance: return 'Finance';
      case UserRole.viewer:  return 'Viewer';
    }
  }

  bool get canEditInventory  => this == UserRole.admin || this == UserRole.manager || this == UserRole.staff;
  bool get canEditEmployees  => this == UserRole.admin || this == UserRole.manager;
  bool get canEditFinance    => this == UserRole.admin || this == UserRole.finance;
  bool get canEditProjects   => this == UserRole.admin || this == UserRole.manager;
  bool get canViewReports    => this != UserRole.viewer;
  bool get canManageUsers    => this == UserRole.admin;
}

class AppUser {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String passwordHash;
  final UserRole role;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastLogin;

  AppUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.passwordHash,
    required this.role,
    this.isActive = true,
    required this.createdAt,
    this.lastLogin,
  });

  String get fullName => '$firstName $lastName';
  String get initials => '${firstName[0]}${lastName[0]}'.toUpperCase();

  Map<String, dynamic> toMap() => {
    'id': id,
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'passwordHash': passwordHash,
    'role': role.name,
    'isActive': isActive,
    'createdAt': createdAt.toIso8601String(),
    'lastLogin': lastLogin?.toIso8601String(),
  };

  factory AppUser.fromMap(Map<String, dynamic> m) => AppUser(
    id: m['id'],
    firstName: m['firstName'],
    lastName: m['lastName'],
    email: m['email'],
    passwordHash: m['passwordHash'],
    role: UserRole.values.firstWhere((r) => r.name == m['role'], orElse: () => UserRole.viewer),
    isActive: m['isActive'] ?? true,
    createdAt: DateTime.parse(m['createdAt']),
    lastLogin: m['lastLogin'] != null ? DateTime.parse(m['lastLogin']) : null,
  );
}
