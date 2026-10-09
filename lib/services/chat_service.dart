import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../utils/constants.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  CollectionReference get _chatsRef =>
      _firestore.collection(AppConstants.chatsCollection);

  /// Generates deterministic unique chat ID by sorting user IDs alphabetically
  static String generateChatId(String uid1, String uid2) {
    final sortedList = [uid1, uid2]..sort();
    return '${sortedList[0]}_${sortedList[1]}';
  }

  /// Send message to chat room and update recent conversation metadata
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String receiverId,
    required String text,
  }) async {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty) return;

    final String messageId = _uuid.v4();
    final now = DateTime.now();

    final message = MessageModel(
      messageId: messageId,
      senderId: senderId,
      receiverId: receiverId,
      text: trimmedText,
      timestamp: now,
      isSeen: false,
    );

    final batch = _firestore.batch();

    // 1. Add message to sub-collection
    final messageDocRef = _chatsRef
        .doc(chatId)
        .collection(AppConstants.messagesCollection)
        .doc(messageId);
    batch.set(messageDocRef, message.toMap());

    // 2. Update parent chat document
    final chatDocRef = _chatsRef.doc(chatId);
    batch.set(
      chatDocRef,
      {
        'chatId': chatId,
        'participants': [senderId, receiverId],
        'lastMessage': trimmedText,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'unreadCount.$receiverId': FieldValue.increment(1),
      },
      SetOptions(merge: true),
    );

    await batch.commit();
  }

  /// Real-time stream of messages for a chat room
  Stream<List<MessageModel>> getMessagesStream(String chatId) {
    return _chatsRef
        .doc(chatId)
        .collection(AppConstants.messagesCollection)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MessageModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Real-time stream of recent conversations for the current user
  Stream<List<ChatModel>> getRecentChatsStream(String currentUserId) {
    return _chatsRef
        .where('participants', arrayContains: currentUserId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ChatModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Mark all unread messages received by current user as seen
  Future<void> markMessagesAsSeen(String chatId, String currentUserId) async {
    try {
      final unreadDocs = await _chatsRef
          .doc(chatId)
          .collection(AppConstants.messagesCollection)
          .where('receiverId', isEqualTo: currentUserId)
          .where('isSeen', isEqualTo: false)
          .get();

      if (unreadDocs.docs.isNotEmpty) {
        final batch = _firestore.batch();
        for (final doc in unreadDocs.docs) {
          batch.update(doc.reference, {'isSeen': true});
        }
        // Reset unread count for current user
        batch.set(
          _chatsRef.doc(chatId),
          {'unreadCount.$currentUserId': 0},
          SetOptions(merge: true),
        );
        await batch.commit();
      } else {
        // Just reset count if already empty
        await _chatsRef.doc(chatId).set(
          {'unreadCount.$currentUserId': 0},
          SetOptions(merge: true),
        );
      }
    } catch (_) {
      // Ignored if permissions prevent update or already cleared
    }
  }

  /// Update typing indicator status
  Future<void> setTypingStatus({
    required String chatId,
    required String userId,
    required bool isTyping,
  }) async {
    try {
      await _chatsRef.doc(chatId).set({
        'typing.$userId': isTyping,
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  /// Clear all messages in a chat conversation (चैट साफ़ करें)
  Future<void> clearChat(String chatId) async {
    try {
      final msgs = await _messagesRef(chatId).get();
      final batch = _firestore.batch();
      for (final doc in msgs.docs) {
        batch.delete(doc.reference);
      }
      batch.update(_chatsRef.doc(chatId), {
        'lastMessage': 'Chat cleared',
        'lastMessageTime': FieldValue.serverTimestamp(),
      });
      await batch.commit();
    } catch (_) {}
  }

  /// Stream typing indicator status for the other participant
  Stream<bool> getTypingStream({
    required String chatId,
    required String otherUserId,
  }) {
    return _chatsRef.doc(chatId).snapshots().map((doc) {
      if (!doc.exists) return false;
      final data = doc.data() as Map<String, dynamic>?;
      if (data == null || data['typing'] == null) return false;
      final typingMap = data['typing'] as Map<String, dynamic>?;
      return typingMap?[otherUserId] as bool? ?? false;
    });
  }
}
