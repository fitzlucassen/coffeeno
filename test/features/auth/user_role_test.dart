import 'package:coffeeno/features/auth/domain/user_role.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserRole', () {
    test('wireName round-trips through fromWire for every role', () {
      for (final role in UserRole.values) {
        expect(UserRole.fromWire(role.wireName), role);
      }
    });

    test('fromWire returns null for unknown strings and null input', () {
      expect(UserRole.fromWire('superuser'), isNull);
      expect(UserRole.fromWire(''), isNull);
      expect(UserRole.fromWire(null), isNull);
    });
  });

  group('parseRoles', () {
    test('parses a valid roles list', () {
      final roles = parseRoles(rolesField: ['roaster', 'farmer']);
      expect(roles, {UserRole.roaster, UserRole.farmer});
    });

    test('falls back to legacy role field when roles list is absent', () {
      final roles = parseRoles(rolesField: null, legacyRoleField: 'admin');
      expect(roles, {UserRole.admin});
    });

    test('prefers new roles list over legacy role field', () {
      final roles = parseRoles(
        rolesField: ['roaster'],
        legacyRoleField: 'user',
      );
      expect(roles, {UserRole.roaster});
    });

    test('drops unknown wire values but keeps recognized ones', () {
      final roles = parseRoles(rolesField: ['roaster', 'ghost', 'admin']);
      expect(roles, {UserRole.roaster, UserRole.admin});
    });

    test('defaults to {user} when nothing parses', () {
      expect(parseRoles(), {UserRole.user});
      expect(parseRoles(rolesField: <String>[]), {UserRole.user});
      expect(
        parseRoles(rolesField: ['bogus'], legacyRoleField: 'also-bogus'),
        {UserRole.user},
      );
    });

    test('de-duplicates repeated entries', () {
      final roles =
          parseRoles(rolesField: ['roaster', 'roaster', 'farmer']);
      expect(roles, {UserRole.roaster, UserRole.farmer});
    });
  });

  test('rolesToWire preserves wire names', () {
    final wire = rolesToWire({UserRole.admin, UserRole.user});
    expect(wire, containsAll(<String>['admin', 'user']));
    expect(wire.length, 2);
  });
}
