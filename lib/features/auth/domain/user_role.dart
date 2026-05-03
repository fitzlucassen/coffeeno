/// The set of roles a user can hold in the app.
///
/// Roles are additive: a user can simultaneously be a regular [user] and
/// one or more of [roaster], [farmer], [admin]. Always persisted on the
/// user document as an array under `roles`.
enum UserRole {
  user,
  roaster,
  farmer,
  admin;

  /// Firestore-serialized form. Keep values stable — changing them requires a
  /// data migration.
  String get wireName => switch (this) {
        UserRole.user => 'user',
        UserRole.roaster => 'roaster',
        UserRole.farmer => 'farmer',
        UserRole.admin => 'admin',
      };

  static UserRole? fromWire(String? value) {
    if (value == null) return null;
    for (final role in UserRole.values) {
      if (role.wireName == value) return role;
    }
    return null;
  }
}

/// Parses a raw Firestore value (either the legacy `role: String` field or the
/// new `roles: List<String>` field) into a non-empty role set.
///
/// Unknown values are ignored. If nothing parses, falls back to
/// `{UserRole.user}` so downstream code never has to handle an empty set.
Set<UserRole> parseRoles({
  Object? rolesField,
  Object? legacyRoleField,
}) {
  final result = <UserRole>{};
  if (rolesField is List) {
    for (final entry in rolesField) {
      final parsed = UserRole.fromWire(entry as String?);
      if (parsed != null) result.add(parsed);
    }
  }
  if (result.isEmpty) {
    final legacy = UserRole.fromWire(legacyRoleField as String?);
    if (legacy != null) result.add(legacy);
  }
  if (result.isEmpty) result.add(UserRole.user);
  return result;
}

List<String> rolesToWire(Set<UserRole> roles) =>
    roles.map((r) => r.wireName).toList(growable: false);
