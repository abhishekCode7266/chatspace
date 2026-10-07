import 'dart:async';
import '../models/user_model.dart';
import '../models/message_model.dart';
import '../models/chat_model.dart';
import '../utils/constants.dart';

/// Service providing mock real-time data for Developer Bypass Mode
/// Allows developer to test all chat, list, profile, and status features
/// without needing an active Firebase connection or credentials.
class MockDataService {
  static final MockDataService instance = MockDataService._internal();
  MockDataService._internal() {
    _initializeMockData();
  }

  // Streams for mock real-time updates
  final StreamController<List<UserModel>> _usersController =
      StreamController<List<UserModel>>.broadcast();
  final StreamController<List<ChatModel>> _chatsController =
      StreamController<List<ChatModel>>.broadcast();
  final Map<String, StreamController<List<MessageModel>>> _messagesControllers = {};
  final Map<String, StreamController<bool>> _typingControllers = {};

  late UserModel _currentDevUser;
  final List<UserModel> _mockUsers = [];
  final List<ChatModel> _mockChats = [];
  final Map<String, List<MessageModel>> _mockMessages = {};

  UserModel get currentDevUser => _currentDevUser;

  void _initializeMockData() {
    final now = DateTime.now();

    _currentDevUser = UserModel(
      uid: AppConstants.devUserId,
      name: AppConstants.devUserName,
      email: AppConstants.devUserEmail,
      status: AppConstants.devUserStatus,
      isOnline: true,
      lastSeen: now,
      createdAt: now.subtract(const Duration(days: 30)),
    );

    _mockUsers.addAll([
      UserModel(
        uid: 'user_alice_01',
        name: 'Alice Johnson',
        email: 'alice@chatspace.com',
        status: 'Exploring Flutter Material 3 🎨',
        isOnline: true,
        lastSeen: now,
        createdAt: now.subtract(const Duration(days: 20)),
      ),
      UserModel(
        uid: 'user_bob_02',
        name: 'Bob Smith',
        email: 'bob@chatspace.com',
        status: 'Busy at work. Drop a message! 💼',
        isOnline: false,
        lastSeen: now.subtract(const Duration(minutes: 18)),
        createdAt: now.subtract(const Duration(days: 15)),
      ),
      UserModel(
        uid: 'user_charlie_03',
        name: 'Charlie Dev',
        email: 'charlie@chatspace.com',
        status: 'Deploying release builds to Play Store 🚀',
        isOnline: true,
        lastSeen: now,
        createdAt: now.subtract(const Duration(days: 10)),
      ),
      UserModel(
        uid: 'user_diana_04',
        name: 'Diana Prince',
        email: 'diana@chatspace.com',
        status: 'Coffee & Code ☕',
        isOnline: false,
        lastSeen: now.subtract(const Duration(hours: 3)),
        createdAt: now.subtract(const Duration(days: 8)),
      ),
      UserModel(
        uid: 'user_evan_05',
        name: 'Evan Wright',
        email: 'evan@chatspace.com',
        status: 'Offline today. Catch you later! ✈️',
        isOnline: false,
        lastSeen: now.subtract(const Duration(days: 1, hours: 2)),
        createdAt: now.subtract(const Duration(days: 5)),
      ),
    ]);

    // Initial mock chat 1 (Alice)
    final aliceChatId = getChatId(AppConstants.devUserId, 'user_alice_01');
    final aliceMsg1 = MessageModel(
      messageId: 'msg_001',
      senderId: 'user_alice_01',
      receiverId: AppConstants.devUserId,
      text: 'Hey Developer! Welcome to ChatSpace demo mode.',
      timestamp: now.subtract(const Duration(minutes: 12)),
      isSeen: true,
    );
    final aliceMsg2 = MessageModel(
      messageId: 'msg_002',
      senderId: AppConstants.devUserId,
      receiverId: 'user_alice_01',
      text: 'Thanks Alice! Testing the real-time messages and state management.',
      timestamp: now.subtract(const Duration(minutes: 10)),
      isSeen: true,
    );
    final aliceMsg3 = MessageModel(
      messageId: 'msg_003',
      senderId: 'user_alice_01',
      receiverId: AppConstants.devUserId,
      text: 'Everything looks super smooth and responsive! 🚀',
      timestamp: now.subtract(const Duration(minutes: 2)),
      isSeen: false,
    );
    _mockMessages[aliceChatId] = [aliceMsg1, aliceMsg2, aliceMsg3];

    _mockChats.add(
      ChatModel(
        chatId: aliceChatId,
        participants: [AppConstants.devUserId, 'user_alice_01'],
        lastMessage: 'Everything looks super smooth and responsive! 🚀',
        lastMessageTime: now.subtract(const Duration(minutes: 2)),
        unreadCount: {AppConstants.devUserId: 1, 'user_alice_01': 0},
      ),
    );

    // Initial mock chat 2 (Charlie)
    final charlieChatId = getChatId(AppConstants.devUserId, 'user_charlie_03');
    final charlieMsg1 = MessageModel(
      messageId: 'msg_004',
      senderId: 'user_charlie_03',
      receiverId: AppConstants.devUserId,
      text: 'The APK and Google Play Store bundle are configured!',
      timestamp: now.subtract(const Duration(hours: 1)),
      isSeen: true,
    );
    _mockMessages[charlieChatId] = [charlieMsg1];

    _mockChats.add(
      ChatModel(
        chatId: charlieChatId,
        participants: [AppConstants.devUserId, 'user_charlie_03'],
        lastMessage: 'The APK and Google Play Store bundle are configured!',
        lastMessageTime: now.subtract(const Duration(hours: 1)),
        unreadCount: {AppConstants.devUserId: 0, 'user_charlie_03': 0},
      ),
    );
  }

  String getChatId(String uid1, String uid2) {
    final list = [uid1, uid2]..sort();
    return '${list[0]}_${list[1]}';
  }

  // Stream of users
  Stream<List<UserModel>> getUsersStream() {
    Future.microtask(() => _usersController.add(List.from(_mockUsers)));
    return _usersController.stream;
  }

  // Stream of recent chats
  Stream<List<ChatModel>> getRecentChatsStream(String currentUserId) {
    Future.microtask(() => _chatsController.add(List.from(_mockChats)));
    return _chatsController.stream;
  }

  // Stream of messages for a chat
  Stream<List<MessageModel>> getMessagesStream(String chatId) {
    if (!_messagesControllers.containsKey(chatId)) {
      _messagesControllers[chatId] =
          StreamController<List<MessageModel>>.broadcast();
    }
    final msgs = _mockMessages[chatId] ?? [];
    Future.microtask(() => _messagesControllers[chatId]?.add(List.from(msgs)));
    return _messagesControllers[chatId]!.stream;
  }

  // Stream of typing status
  Stream<bool> getTypingStream(String chatId) {
    if (!_typingControllers.containsKey(chatId)) {
      _typingControllers[chatId] = StreamController<bool>.broadcast();
    }
    return _typingControllers[chatId]!.stream;
  }

  // Send message in mock mode + auto-reply simulator
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String receiverId,
    required String text,
  }) async {
    final now = DateTime.now();
    final newMsg = MessageModel(
      messageId: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderId: senderId,
      receiverId: receiverId,
      text: text,
      timestamp: now,
      isSeen: false,
    );

    if (!_mockMessages.containsKey(chatId)) {
      _mockMessages[chatId] = [];
    }
    _mockMessages[chatId]!.add(newMsg);

    // Update or add chat in recent chats
    final chatIdx = _mockChats.indexWhere((c) => c.chatId == chatId);
    if (chatIdx >= 0) {
      final existing = _mockChats[chatIdx];
      final unread = Map<String, int>.from(existing.unreadCount);
      unread[receiverId] = (unread[receiverId] ?? 0) + 1;
      _mockChats[chatIdx] = existing.copyWith(
        lastMessage: text,
        lastMessageTime: now,
        unreadCount: unread,
      );
    } else {
      _mockChats.insert(
        0,
        ChatModel(
          chatId: chatId,
          participants: [senderId, receiverId],
          lastMessage: text,
          lastMessageTime: now,
          unreadCount: {receiverId: 1, senderId: 0},
        ),
      );
    }

    _chatsController.add(List.from(_mockChats));
    _messagesControllers[chatId]?.add(List.from(_mockMessages[chatId]!));

    // Simulate smart auto-reply bot if receiver is a mock contact
    _simulateAutoReply(chatId, receiverId, senderId, text);
  }

  void _simulateAutoReply(
    String chatId,
    String botId,
    String currentUserId,
    String userText,
  ) {
    final botUser = _mockUsers.firstWhere(
      (u) => u.uid == botId,
      orElse: () => UserModel(
        uid: botId,
        name: 'ChatSpace Assistant',
        email: 'bot@chatspace.com',
        createdAt: DateTime.now(),
      ),
    );

    // Start typing indicator after 800ms
    Timer(const Duration(milliseconds: 800), () {
      _typingControllers[chatId]?.add(true);
    });

    // Send reply after 2.2 seconds
    Timer(const Duration(milliseconds: 2200), () {
      _typingControllers[chatId]?.add(false);

      String replyText;
      final lower = userText.toLowerCase();
      if (lower.contains('hello') || lower.contains('hi') || lower.contains('hey')) {
        replyText = 'Hey ${AppConstants.devUserName}! Nice to chat with you. Everything is operating perfectly in real-time!';
      } else if (lower.contains('status') || lower.contains('online')) {
        replyText = 'I am currently marked ${botUser.isOnline ? "Online" : "Away"} in ChatSpace.';
      } else if (lower.contains('test') || lower.contains('apk')) {
        replyText = 'Testing mode verified! Real-time stream, UI bubbles, and state updates are 100% functional.';
      } else {
        replyText = 'Got it! Received: "$userText". Firestore replication & local caching test complete! ✅';
      }

      final now = DateTime.now();
      final replyMsg = MessageModel(
        messageId: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        senderId: botId,
        receiverId: currentUserId,
        text: replyText,
        timestamp: now,
        isSeen: true,
      );

      _mockMessages[chatId]?.add(replyMsg);

      final chatIdx = _mockChats.indexWhere((c) => c.chatId == chatId);
      if (chatIdx >= 0) {
        final existing = _mockChats[chatIdx];
        _mockChats[chatIdx] = existing.copyWith(
          lastMessage: replyText,
          lastMessageTime: now,
        );
      }

      _chatsController.add(List.from(_mockChats));
      _messagesControllers[chatId]?.add(List.from(_mockMessages[chatId] ?? []));
    });
  }

  Future<void> markMessagesAsSeen(String chatId, String currentUserId) async {
    final msgs = _mockMessages[chatId];
    if (msgs != null) {
      bool changed = false;
      for (int i = 0; i < msgs.length; i++) {
        if (msgs[i].receiverId == currentUserId && !msgs[i].isSeen) {
          msgs[i] = msgs[i].copyWith(isSeen: true);
          changed = true;
        }
      }
      if (changed) {
        _messagesControllers[chatId]?.add(List.from(msgs));
      }
    }

    final chatIdx = _mockChats.indexWhere((c) => c.chatId == chatId);
    if (chatIdx >= 0) {
      final existing = _mockChats[chatIdx];
      final unread = Map<String, int>.from(existing.unreadCount);
      unread[currentUserId] = 0;
      _mockChats[chatIdx] = existing.copyWith(unreadCount: unread);
      _chatsController.add(List.from(_mockChats));
    }
  }

  void updateDevUserProfile({required String name, required String status}) {
    _currentDevUser = _currentDevUser.copyWith(name: name, status: status);
  }

  UserModel? getUserById(String uid) {
    if (uid == AppConstants.devUserId) return _currentDevUser;
    final idx = _mockUsers.indexWhere((u) => u.uid == uid);
    if (idx >= 0) return _mockUsers[idx];
    return null;
  }
}
