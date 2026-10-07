import 'dart:async';
import '../models/user_model.dart';
import '../models/message_model.dart';
import '../models/chat_model.dart';
import '../models/call_model.dart';
import '../models/status_model.dart';
import '../utils/constants.dart';

/// Service providing mock real-time data for Developer Bypass Mode
/// Allows developer to test all chat, list, profile, call, status, and E2EE features
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
  final StreamController<List<CallModel>> _callsController =
      StreamController<List<CallModel>>.broadcast();
  final StreamController<List<StatusModel>> _statusController =
      StreamController<List<StatusModel>>.broadcast();
  final Map<String, StreamController<List<MessageModel>>> _messagesControllers = {};
  final Map<String, StreamController<bool>> _typingControllers = {};

  late UserModel _currentDevUser;
  final List<UserModel> _mockUsers = [];
  final List<ChatModel> _mockChats = [];
  final List<CallModel> _mockCalls = [];
  final List<StatusModel> _mockStatuses = [];
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
        email: 'alice@whatschat.com',
        status: 'Exploring Flutter Material 3 🎨',
        isOnline: true,
        lastSeen: now,
        createdAt: now.subtract(const Duration(days: 20)),
      ),
      UserModel(
        uid: 'user_bob_02',
        name: 'Bob Smith',
        email: 'bob@whatschat.com',
        status: 'Busy at work. Drop a message! 💼',
        isOnline: false,
        lastSeen: now.subtract(const Duration(minutes: 18)),
        createdAt: now.subtract(const Duration(days: 15)),
      ),
      UserModel(
        uid: 'user_charlie_03',
        name: 'Charlie Dev',
        email: 'charlie@whatschat.com',
        status: 'Deploying release builds to Play Store 🚀',
        isOnline: true,
        lastSeen: now,
        createdAt: now.subtract(const Duration(days: 10)),
      ),
      UserModel(
        uid: 'user_diana_04',
        name: 'Diana Prince',
        email: 'diana@whatschat.com',
        status: 'Coffee & Code ☕',
        isOnline: false,
        lastSeen: now.subtract(const Duration(hours: 3)),
        createdAt: now.subtract(const Duration(days: 8)),
      ),
      UserModel(
        uid: 'user_evan_05',
        name: 'Evan Wright',
        email: 'evan@whatschat.com',
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
      text: 'Hey Developer! Welcome to WhatsChat WhatsApp-like experience.',
      timestamp: now.subtract(const Duration(minutes: 15)),
      isSeen: true,
    );
    final aliceMsg2 = MessageModel(
      messageId: 'msg_002',
      senderId: AppConstants.devUserId,
      receiverId: 'user_alice_01',
      text: 'Thanks Alice! Testing real-time messages, audio notes, and HD calls.',
      timestamp: now.subtract(const Duration(minutes: 12)),
      isSeen: true,
      reaction: '👍',
    );
    final aliceMsg3 = MessageModel(
      messageId: 'msg_003',
      senderId: 'user_alice_01',
      receiverId: AppConstants.devUserId,
      text: 'Voice note preview (0:14)',
      timestamp: now.subtract(const Duration(minutes: 8)),
      isSeen: true,
      messageType: 'audio',
      audioDuration: '0:14',
      reaction: '❤️',
    );
    final aliceMsg4 = MessageModel(
      messageId: 'msg_004',
      senderId: 'user_alice_01',
      receiverId: AppConstants.devUserId,
      text: 'Everything looks super smooth, just like WhatsApp! 🚀',
      timestamp: now.subtract(const Duration(minutes: 2)),
      isSeen: false,
    );
    _mockMessages[aliceChatId] = [aliceMsg1, aliceMsg2, aliceMsg3, aliceMsg4];

    _mockChats.add(
      ChatModel(
        chatId: aliceChatId,
        participants: [AppConstants.devUserId, 'user_alice_01'],
        lastMessage: 'Everything looks super smooth, just like WhatsApp! 🚀',
        lastMessageTime: now.subtract(const Duration(minutes: 2)),
        unreadCount: {AppConstants.devUserId: 1, 'user_alice_01': 0},
      ),
    );

    // Initial mock chat 2 (Charlie)
    final charlieChatId = getChatId(AppConstants.devUserId, 'user_charlie_03');
    final charlieMsg1 = MessageModel(
      messageId: 'msg_005',
      senderId: 'user_charlie_03',
      receiverId: AppConstants.devUserId,
      text: 'The Play Store bundle (.aab) and APK are compiled and ready!',
      timestamp: now.subtract(const Duration(hours: 1)),
      isSeen: true,
      reaction: '🔥',
    );
    _mockMessages[charlieChatId] = [charlieMsg1];

    _mockChats.add(
      ChatModel(
        chatId: charlieChatId,
        participants: [AppConstants.devUserId, 'user_charlie_03'],
        lastMessage: 'The Play Store bundle (.aab) and APK are compiled and ready!',
        lastMessageTime: now.subtract(const Duration(hours: 1)),
        unreadCount: {AppConstants.devUserId: 0, 'user_charlie_03': 0},
      ),
    );

    // Initial mock call logs
    _mockCalls.addAll([
      CallModel(
        callId: 'call_01',
        callerId: 'user_alice_01',
        receiverId: AppConstants.devUserId,
        callerName: 'Alice Johnson',
        timestamp: now.subtract(const Duration(minutes: 42)),
        durationSeconds: 165,
        isVideo: true,
        isMissed: false,
        isOutgoing: false,
      ),
      CallModel(
        callId: 'call_02',
        callerId: AppConstants.devUserId,
        receiverId: 'user_charlie_03',
        callerName: 'Charlie Dev',
        timestamp: now.subtract(const Duration(hours: 2, minutes: 15)),
        durationSeconds: 340,
        isVideo: false,
        isMissed: false,
        isOutgoing: true,
      ),
      CallModel(
        callId: 'call_03',
        callerId: 'user_bob_02',
        receiverId: AppConstants.devUserId,
        callerName: 'Bob Smith',
        timestamp: now.subtract(const Duration(hours: 5)),
        durationSeconds: 0,
        isVideo: true,
        isMissed: true,
        isOutgoing: false,
      ),
      CallModel(
        callId: 'call_04',
        callerId: AppConstants.devUserId,
        receiverId: 'user_diana_04',
        callerName: 'Diana Prince',
        timestamp: now.subtract(const Duration(days: 1, hours: 3)),
        durationSeconds: 210,
        isVideo: false,
        isMissed: false,
        isOutgoing: true,
      ),
    ]);

    // Initial mock statuses
    _mockStatuses.addAll([
      StatusModel(
        statusId: 'stat_01',
        userId: 'user_alice_01',
        userName: 'Alice Johnson',
        text: 'Building high-performance Flutter mobile apps! 💙✨\nMaterial 3 design is amazing.',
        backgroundColorHex: 0xFF005C4B,
        timestamp: now.subtract(const Duration(minutes: 35)),
        isViewed: false,
      ),
      StatusModel(
        statusId: 'stat_02',
        userId: 'user_charlie_03',
        userName: 'Charlie Dev',
        text: 'Play Store release build ready! 🚀\nWhatsChat v1.2.0 is live on GitHub.',
        backgroundColorHex: 0xFF128C7E,
        timestamp: now.subtract(const Duration(hours: 2)),
        isViewed: false,
      ),
      StatusModel(
        statusId: 'stat_03',
        userId: 'user_diana_04',
        userName: 'Diana Prince',
        text: 'Weekend coffee & coding session ☕🎧',
        backgroundColorHex: 0xFF5856D6,
        timestamp: now.subtract(const Duration(hours: 6)),
        isViewed: true,
      ),
    ]);
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

  // Stream of calls
  Stream<List<CallModel>> getCallsStream(String currentUserId) {
    Future.microtask(() => _callsController.add(List.from(_mockCalls)));
    return _callsController.stream;
  }

  // Stream of statuses
  Stream<List<StatusModel>> getStatusStream() {
    Future.microtask(() => _statusController.add(List.from(_mockStatuses)));
    return _statusController.stream;
  }

  // Add a call record
  Future<void> addCallRecord(CallModel call) async {
    _mockCalls.insert(0, call);
    _callsController.add(List.from(_mockCalls));
  }

  // Mark status as viewed
  Future<void> markStatusViewed(String statusId) async {
    final idx = _mockStatuses.indexWhere((s) => s.statusId == statusId);
    if (idx >= 0) {
      _mockStatuses[idx] = _mockStatuses[idx].copyWith(isViewed: true);
      _statusController.add(List.from(_mockStatuses));
    }
  }

  // Add new status story
  Future<void> addStatus(StatusModel status) async {
    _mockStatuses.insert(0, status);
    _statusController.add(List.from(_mockStatuses));
  }

  // Toggle or add reaction
  Future<void> toggleReaction(String chatId, String messageId, String reaction) async {
    final msgs = _mockMessages[chatId];
    if (msgs != null) {
      final idx = msgs.indexWhere((m) => m.messageId == messageId);
      if (idx >= 0) {
        final currentReaction = msgs[idx].reaction;
        final newReaction = currentReaction == reaction ? null : reaction;
        msgs[idx] = msgs[idx].copyWith(reaction: newReaction);
        _messagesControllers[chatId]?.add(List.from(msgs));
      }
    }
  }

  // Send message in mock mode + auto-reply simulator
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String receiverId,
    required String text,
    String messageType = 'text',
    String? audioDuration,
  }) async {
    final now = DateTime.now();
    final newMsg = MessageModel(
      messageId: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderId: senderId,
      receiverId: receiverId,
      text: text,
      timestamp: now,
      isSeen: false,
      messageType: messageType,
      audioDuration: audioDuration,
    );

    if (!_mockMessages.containsKey(chatId)) {
      _mockMessages[chatId] = [];
    }
    _mockMessages[chatId]!.add(newMsg);

    // Update or add chat in recent chats
    final displayText = messageType == 'audio' ? '🎤 Voice message ($audioDuration)' : text;
    final chatIdx = _mockChats.indexWhere((c) => c.chatId == chatId);
    if (chatIdx >= 0) {
      final existing = _mockChats[chatIdx];
      final unread = Map<String, int>.from(existing.unreadCount);
      unread[receiverId] = (unread[receiverId] ?? 0) + 1;
      _mockChats[chatIdx] = existing.copyWith(
        lastMessage: displayText,
        lastMessageTime: now,
        unreadCount: unread,
      );
    } else {
      _mockChats.insert(
        0,
        ChatModel(
          chatId: chatId,
          participants: [senderId, receiverId],
          lastMessage: displayText,
          lastMessageTime: now,
          unreadCount: {receiverId: 1, senderId: 0},
        ),
      );
    }

    _chatsController.add(List.from(_mockChats));
    _messagesControllers[chatId]?.add(List.from(_mockMessages[chatId]!));

    // Simulate smart auto-reply bot if receiver is a mock contact and message is text
    if (messageType == 'text') {
      _simulateAutoReply(chatId, receiverId, senderId, text);
    } else if (messageType == 'audio') {
      _simulateAudioAutoReply(chatId, receiverId, senderId);
    }
  }

  void _simulateAudioAutoReply(String chatId, String botId, String currentUserId) {
    Timer(const Duration(milliseconds: 1500), () {
      _typingControllers[chatId]?.add(true);
    });

    Timer(const Duration(milliseconds: 3000), () {
      _typingControllers[chatId]?.add(false);
      final now = DateTime.now();
      final replyMsg = MessageModel(
        messageId: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        senderId: botId,
        receiverId: currentUserId,
        text: 'Voice note preview (0:09)',
        timestamp: now,
        isSeen: true,
        messageType: 'audio',
        audioDuration: '0:09',
        reaction: '👍',
      );

      _mockMessages[chatId]?.add(replyMsg);
      final chatIdx = _mockChats.indexWhere((c) => c.chatId == chatId);
      if (chatIdx >= 0) {
        final existing = _mockChats[chatIdx];
        _mockChats[chatIdx] = existing.copyWith(
          lastMessage: '🎤 Voice message (0:09)',
          lastMessageTime: now,
        );
      }

      _chatsController.add(List.from(_mockChats));
      _messagesControllers[chatId]?.add(List.from(_mockMessages[chatId] ?? []));
    });
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
        name: 'WhatsChat Assistant',
        email: 'bot@whatschat.com',
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
        replyText = 'Hey ${AppConstants.devUserName}! Nice to chat with you in WhatsChat. Real-time messaging, status & HD calls are working!';
      } else if (lower.contains('status') || lower.contains('online')) {
        replyText = 'I am currently marked ${botUser.isOnline ? "Online" : "Away"} in WhatsChat.';
      } else if (lower.contains('test') || lower.contains('apk') || lower.contains('call')) {
        replyText = 'Testing mode verified! Real-time stream, UI bubbles, call logs, and state updates are 100% functional.';
      } else {
        replyText = 'Got it! Received: "$userText". E2EE message encryption & local caching verified! ✅';
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
