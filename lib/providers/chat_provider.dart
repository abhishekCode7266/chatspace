import 'package:flutter/material.dart';
import '../models/chat_model.dart';
import '../models/call_model.dart';
import '../models/status_model.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';
import '../services/chat_service.dart';
import '../services/mock_data_service.dart';
import '../services/user_service.dart';

class ChatProvider with ChangeNotifier {
  final ChatService _chatService = ChatService();
  final UserService _userService = UserService();
  final MockDataService _mockDataService = MockDataService.instance;

  bool _isSending = false;
  String? _errorMessage;

  bool get isSending => _isSending;
  String? get errorMessage => _errorMessage;

  /// Generates sorted deterministic chatId
  String getChatId(String uid1, String uid2) {
    return ChatService.generateChatId(uid1, uid2);
  }

  /// Real-time stream of all users except current user
  Stream<List<UserModel>> getUsersStream({
    required String currentUserId,
    required bool isDevBypass,
  }) {
    if (isDevBypass) {
      return _mockDataService.getUsersStream();
    }
    return _userService.getUsersStream(currentUserId);
  }

  /// Real-time stream of recent chats
  Stream<List<ChatModel>> getRecentChatsStream({
    required String currentUserId,
    required bool isDevBypass,
  }) {
    if (isDevBypass) {
      return _mockDataService.getRecentChatsStream(currentUserId);
    }
    return _chatService.getRecentChatsStream(currentUserId);
  }

  /// Real-time stream of messages in a room
  Stream<List<MessageModel>> getMessagesStream({
    required String chatId,
    required bool isDevBypass,
  }) {
    if (isDevBypass) {
      return _mockDataService.getMessagesStream(chatId);
    }
    return _chatService.getMessagesStream(chatId);
  }

  /// Stream typing indicator
  Stream<bool> getTypingStream({
    required String chatId,
    required String otherUserId,
    required bool isDevBypass,
  }) {
    if (isDevBypass) {
      return _mockDataService.getTypingStream(chatId);
    }
    return _chatService.getTypingStream(
      chatId: chatId,
      otherUserId: otherUserId,
    );
  }

  /// Real-time stream of calls
  Stream<List<CallModel>> getCallsStream({
    required String currentUserId,
    required bool isDevBypass,
  }) {
    return _mockDataService.getCallsStream(currentUserId);
  }

  /// Real-time stream of statuses
  Stream<List<StatusModel>> getStatusStream({
    required bool isDevBypass,
  }) {
    return _mockDataService.getStatusStream();
  }

  /// Record a call log
  Future<void> addCallRecord(CallModel call, {required bool isDevBypass}) async {
    await _mockDataService.addCallRecord(call);
    notifyListeners();
  }

  /// Mark status as viewed
  Future<void> markStatusViewed(String statusId, {required bool isDevBypass}) async {
    await _mockDataService.markStatusViewed(statusId);
    notifyListeners();
  }

  /// Add new status story
  Future<void> addStatus(StatusModel status, {required bool isDevBypass}) async {
    await _mockDataService.addStatus(status);
    notifyListeners();
  }

  /// Send message (text, voice note, etc.)
  Future<bool> sendMessage({
    required String chatId,
    required String senderId,
    required String receiverId,
    required String text,
    required bool isDevBypass,
    String messageType = 'text',
    String? audioDuration,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty && messageType == 'text') return false;

    _isSending = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (isDevBypass) {
        await _mockDataService.sendMessage(
          chatId: chatId,
          senderId: senderId,
          receiverId: receiverId,
          text: trimmed,
          messageType: messageType,
          audioDuration: audioDuration,
        );
      } else {
        await _chatService.sendMessage(
          chatId: chatId,
          senderId: senderId,
          receiverId: receiverId,
          text: trimmed,
        );
      }
      _isSending = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to send message: $e';
      _isSending = false;
      notifyListeners();
      return false;
    }
  }

  /// Toggle or update reaction on a message
  Future<void> toggleReaction({
    required String chatId,
    required String messageId,
    required String reaction,
    required bool isDevBypass,
  }) async {
    if (isDevBypass) {
      await _mockDataService.toggleReaction(chatId, messageId, reaction);
      notifyListeners();
    }
  }

  /// Mark unread messages as seen
  Future<void> markMessagesAsSeen({
    required String chatId,
    required String currentUserId,
    required bool isDevBypass,
  }) async {
    try {
      if (isDevBypass) {
        await _mockDataService.markMessagesAsSeen(chatId, currentUserId);
      } else {
        await _chatService.markMessagesAsSeen(chatId, currentUserId);
      }
    } catch (_) {}
  }

  /// Update typing status
  Future<void> setTypingStatus({
    required String chatId,
    required String userId,
    required bool isTyping,
    required bool isDevBypass,
  }) async {
    if (isDevBypass) return;
    try {
      await _chatService.setTypingStatus(
        chatId: chatId,
        userId: userId,
        isTyping: isTyping,
      );
    } catch (_) {}
  }

  /// Fetch user profile (for recent chat tiles)
  Future<UserModel?> getUserById(String uid, bool isDevBypass) async {
    if (isDevBypass) {
      return _mockDataService.getUserById(uid);
    }
    return await _userService.getUserProfile(uid);
  }
}
