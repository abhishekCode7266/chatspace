import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chatspace/services/encryption_service.dart';
import 'package:chatspace/services/security_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('Security & Encryption Tests', () {
    test('generateSecurityFingerprint produces deterministic 60-digit formatted code', () {
      const uid1 = 'user_alice';
      const uid2 = 'user_bob';

      final code1 = EncryptionService.generateSecurityFingerprint(uid1, uid2);
      final code2 = EncryptionService.generateSecurityFingerprint(uid2, uid1);

      // Verify commutative property
      expect(code1, equals(code2));
      // 12 groups of 5 digits separated by spaces = 71 characters
      expect(code1.length, equals(71));
      expect(code1.contains(' '), isTrue);
    });

    test('encryptMessage and decryptMessage perform reliable round-trip', () {
      const plain = 'Confidential message from Universal Chat App!';
      const chatId = 'chat_123';

      final encrypted = EncryptionService.encryptMessage(plain, chatId);
      expect(encrypted.startsWith('e2ee::'), isTrue);
      expect(encrypted, isNot(equals(plain)));

      final decrypted = EncryptionService.decryptMessage(encrypted);
      expect(decrypted, equals(plain));
    });

    test('SecurityService verifies default PIN correctly', () {
      final security = SecurityService.instance;
      expect(security.verifyPin('1234'), isTrue);
      expect(security.verifyPin('9999'), isFalse);
    });

    test('SecurityService blocks and unblocks users', () async {
      final security = SecurityService.instance;
      const targetUid = 'bad_actor_99';

      await security.unblockUser(targetUid);
      expect(security.isUserBlocked(targetUid), isFalse);

      await security.blockUser(targetUid);
      expect(security.isUserBlocked(targetUid), isTrue);

      await security.unblockUser(targetUid);
      expect(security.isUserBlocked(targetUid), isFalse);
    });
  });
}
