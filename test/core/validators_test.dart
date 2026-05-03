import 'package:coffeeno/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Validators.email', () {
    test('rejects null and empty', () {
      expect(Validators.email(null), isNotNull);
      expect(Validators.email(''), isNotNull);
    });

    test('rejects malformed addresses', () {
      expect(Validators.email('no-at.com'), isNotNull);
      expect(Validators.email('a@b'), isNotNull);
      expect(Validators.email('@x.com'), isNotNull);
    });

    test('accepts a typical address', () {
      expect(Validators.email('user@example.com'), isNull);
      expect(Validators.email('first.last@sub.domain.co'), isNull);
    });
  });

  group('Validators.password', () {
    test('rejects null, empty, and short', () {
      expect(Validators.password(null), isNotNull);
      expect(Validators.password(''), isNotNull);
      expect(Validators.password('short'), isNotNull);
    });

    test('accepts 8+ character passwords', () {
      expect(Validators.password('12345678'), isNull);
    });
  });

  group('Validators.required', () {
    test('rejects null, empty, and whitespace-only', () {
      expect(Validators.required(null), isNotNull);
      expect(Validators.required(''), isNotNull);
      expect(Validators.required('   '), isNotNull);
    });

    test('accepts non-blank strings', () {
      expect(Validators.required('x'), isNull);
    });

    test('includes the field name in the message', () {
      final err = Validators.required(null, 'Username');
      expect(err, contains('Username'));
    });
  });

  group('Validators.username', () {
    test('rejects short and empty names', () {
      expect(Validators.username(null), isNotNull);
      expect(Validators.username(''), isNotNull);
      expect(Validators.username('ab'), isNotNull);
    });

    test('rejects characters outside [a-zA-Z0-9_]', () {
      expect(Validators.username('john doe'), isNotNull);
      expect(Validators.username('john-doe'), isNotNull);
      expect(Validators.username('john.doe'), isNotNull);
    });

    test('accepts valid usernames', () {
      expect(Validators.username('alice_01'), isNull);
      expect(Validators.username('Bob'), isNull);
    });
  });
}
