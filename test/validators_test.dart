import 'package:flutter_test/flutter_test.dart';
import 'package:chatspace/utils/validators.dart';

void main() {
  group('AppValidators Unit Tests', () {
    test('validateEmail correctly accepts valid email formats', () {
      expect(AppValidators.validateEmail('user@chatspace.com'), isNull);
      expect(AppValidators.validateEmail('john.doe123@domain.co.in'), isNull);
      expect(AppValidators.validateEmail('admin+testing@example.org'), isNull);
    });

    test('validateEmail rejects empty and invalid formats', () {
      expect(AppValidators.validateEmail(''), isNotNull);
      expect(AppValidators.validateEmail(null), isNotNull);
      expect(AppValidators.validateEmail('invalid-email'), isNotNull);
      expect(AppValidators.validateEmail('test@domain'), isNotNull);
      expect(AppValidators.validateEmail('@domain.com'), isNotNull);
    });

    test('validatePassword requires at least 6 characters', () {
      expect(AppValidators.validatePassword('123456'), isNull);
      expect(AppValidators.validatePassword('secure_password_99'), isNull);
      expect(AppValidators.validatePassword('12345'), isNotNull);
      expect(AppValidators.validatePassword(''), isNotNull);
      expect(AppValidators.validatePassword(null), isNotNull);
    });

    test('validateName requires at least 2 non-whitespace characters', () {
      expect(AppValidators.validateName('Rajnesh'), isNull);
      expect(AppValidators.validateName('AI'), isNull);
      expect(AppValidators.validateName('A'), isNotNull);
      expect(AppValidators.validateName('   '), isNotNull);
      expect(AppValidators.validateName(null), isNotNull);
    });

    test('validateConfirmPassword checks for equality', () {
      expect(AppValidators.validateConfirmPassword('pass123', 'pass123'), isNull);
      expect(AppValidators.validateConfirmPassword('pass123', 'diffPass'), isNotNull);
      expect(AppValidators.validateConfirmPassword('', 'pass123'), isNotNull);
      expect(AppValidators.validateConfirmPassword(null, 'pass123'), isNotNull);
    });

    test('validateStatus checks status length', () {
      expect(AppValidators.validateStatus('Hey there!'), isNull);
      expect(AppValidators.validateStatus(''), isNotNull);
      expect(AppValidators.validateStatus('a' * 105), isNotNull);
    });
  });
}
