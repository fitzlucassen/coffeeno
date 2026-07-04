import 'package:coffeeno/core/utils/validators.dart';
import 'package:coffeeno/l10n/app_localizations_en.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final l10n = AppLocalizationsEn();

  group('Validators.email', () {
    test('rejects null and empty', () {
      expect(Validators.email(null, l10n), isNotNull);
      expect(Validators.email('', l10n), isNotNull);
    });

    test('rejects malformed addresses', () {
      expect(Validators.email('no-at.com', l10n), isNotNull);
      expect(Validators.email('a@b', l10n), isNotNull);
      expect(Validators.email('@x.com', l10n), isNotNull);
    });

    test('accepts a typical address', () {
      expect(Validators.email('user@example.com', l10n), isNull);
      expect(Validators.email('first.last@sub.domain.co', l10n), isNull);
    });
  });

  group('Validators.password', () {
    test('rejects null, empty, and short', () {
      expect(Validators.password(null, l10n), isNotNull);
      expect(Validators.password('', l10n), isNotNull);
      expect(Validators.password('short', l10n), isNotNull);
    });

    test('accepts 8+ character passwords', () {
      expect(Validators.password('12345678', l10n), isNull);
    });
  });

  group('Validators.required', () {
    test('rejects null, empty, and whitespace-only', () {
      expect(Validators.required(null, l10n, 'Field'), isNotNull);
      expect(Validators.required('', l10n, 'Field'), isNotNull);
      expect(Validators.required('   ', l10n, 'Field'), isNotNull);
    });

    test('accepts non-blank strings', () {
      expect(Validators.required('x', l10n, 'Field'), isNull);
    });

    test('includes the field name in the message', () {
      final err = Validators.required(null, l10n, 'Username');
      expect(err, contains('Username'));
    });
  });

  group('Validators.username', () {
    test('rejects short and empty names', () {
      expect(Validators.username(null, l10n), isNotNull);
      expect(Validators.username('', l10n), isNotNull);
      expect(Validators.username('ab', l10n), isNotNull);
    });

    test('rejects characters outside [a-zA-Z0-9_]', () {
      expect(Validators.username('john doe', l10n), isNotNull);
      expect(Validators.username('john-doe', l10n), isNotNull);
      expect(Validators.username('john.doe', l10n), isNotNull);
    });

    test('accepts valid usernames', () {
      expect(Validators.username('alice_01', l10n), isNull);
      expect(Validators.username('Bob', l10n), isNull);
    });
  });
}
