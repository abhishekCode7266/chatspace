import 'package:flutter_test/flutter_test.dart';
import 'package:chatspace/services/chat_service.dart';

void main() {
  group('ChatService Chat ID Generation Tests', () {
    test('generateChatId returns sorted combination of both user IDs', () {
      const uid1 = 'user_alpha';
      const uid2 = 'user_beta';

      final chatId1 = ChatService.generateChatId(uid1, uid2);
      final chatId2 = ChatService.generateChatId(uid2, uid1);

      expect(chatId1, equals('user_alpha_user_beta'));
      expect(chatId2, equals('user_alpha_user_beta'));
      expect(chatId1, equals(chatId2));
    });

    test('generateChatId works correctly with arbitrary alphanumeric IDs', () {
      const uidA = 'z99_user';
      const uidB = 'a01_user';

      final chatId = ChatService.generateChatId(uidA, uidB);
      expect(chatId, equals('a01_user_z99_user'));
    });

    test('generateChatId handles identical IDs consistently', () {
      const uid = 'same_user_id';
      final chatId = ChatService.generateChatId(uid, uid);
      expect(chatId, equals('same_user_id_same_user_id'));
    });
  });
}
