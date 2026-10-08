import 'dart:async';
import '../models/user_model.dart';
import '../models/message_model.dart';
import '../models/chat_model.dart';
import '../models/call_model.dart';
import '../models/status_model.dart';
import '../models/channel_model.dart';
import '../utils/constants.dart';

/// Service providing mock real-time data for Developer Bypass Mode in Universal Chat App
/// Supports 1-to-1 chats, Group chats, News/Channels, Status stories, Voice/Video calls, and E2EE.
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
  final StreamController<List<ChannelModel>> _channelsController =
      StreamController<List<ChannelModel>>.broadcast();
  final Map<String, StreamController<List<MessageModel>>> _messagesControllers = {};
  final Map<String, StreamController<bool>> _typingControllers = {};

  late UserModel _currentDevUser;
  final List<UserModel> _mockUsers = [];
  final List<ChatModel> _mockChats = [];
  final List<CallModel> _mockCalls = [];
  final List<StatusModel> _mockStatuses = [];
  final List<ChannelModel> _mockChannels = [];
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
        email: 'alice@universalchat.app',
        status: 'Exploring Universal Chat App & AI 🎨',
        isOnline: true,
        lastSeen: now,
        createdAt: now.subtract(const Duration(days: 20)),
      ),
      UserModel(
        uid: 'user_bob_02',
        name: 'Bob Smith',
        email: 'bob@universalchat.app',
        status: 'Busy in meeting. Drop a message! 💼',
        isOnline: false,
        lastSeen: now.subtract(const Duration(minutes: 18)),
        createdAt: now.subtract(const Duration(days: 15)),
      ),
      UserModel(
        uid: 'user_charlie_03',
        name: 'Charlie Dev',
        email: 'charlie@universalchat.app',
        status: 'Deploying Universal Chat App v1.3.0 to Play Store 🚀',
        isOnline: true,
        lastSeen: now,
        createdAt: now.subtract(const Duration(days: 10)),
      ),
      UserModel(
        uid: 'user_diana_04',
        name: 'Diana Prince',
        email: 'diana@universalchat.app',
        status: 'Coffee, AI & Next-Gen Apps ☕',
        isOnline: false,
        lastSeen: now.subtract(const Duration(hours: 3)),
        createdAt: now.subtract(const Duration(days: 8)),
      ),
      UserModel(
        uid: 'user_evan_05',
        name: 'Evan Wright',
        email: 'evan@universalchat.app',
        status: 'Offline today. Catch you soon! ✈️',
        isOnline: false,
        lastSeen: now.subtract(const Duration(days: 1, hours: 2)),
        createdAt: now.subtract(const Duration(days: 5)),
      ),
    ]);

    // Initial 1-to-1 Chat: Alice (Marked as Favorite!)
    final aliceChatId = getChatId(AppConstants.devUserId, 'user_alice_01');
    final aliceMsg1 = MessageModel(
      messageId: 'msg_001',
      senderId: 'user_alice_01',
      receiverId: AppConstants.devUserId,
      text: 'Hey Developer! Welcome to Universal Chat App.',
      timestamp: now.subtract(const Duration(minutes: 15)),
      isSeen: true,
    );
    final aliceMsg2 = MessageModel(
      messageId: 'msg_002',
      senderId: AppConstants.devUserId,
      receiverId: 'user_alice_01',
      text: 'Thanks Alice! Testing real-time messages, audio notes, groups, and HD calls.',
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
      text: 'Everything looks super smooth and fast! 🚀',
      timestamp: now.subtract(const Duration(minutes: 2)),
      isSeen: false,
    );
    _mockMessages[aliceChatId] = [aliceMsg1, aliceMsg2, aliceMsg3, aliceMsg4];

    _mockChats.add(
      ChatModel(
        chatId: aliceChatId,
        participants: [AppConstants.devUserId, 'user_alice_01'],
        lastMessage: 'Everything looks super smooth and fast! 🚀',
        lastMessageTime: now.subtract(const Duration(minutes: 2)),
        unreadCount: {AppConstants.devUserId: 1, 'user_alice_01': 0},
        isFavorite: true,
      ),
    );

    // Initial 1-to-1 Chat: Charlie
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
        isFavorite: false,
      ),
    );

    // Initial Group Chat 1: "🚀 Universal AI & Flutter Devs"
    const group1Id = 'group_ai_flutter_01';
    final groupMsg1 = MessageModel(
      messageId: 'gmsg_001',
      senderId: 'user_charlie_03',
      receiverId: group1Id,
      senderName: 'Charlie Dev',
      text: 'Welcome team to the Universal Chat App developer group! 🎉',
      timestamp: now.subtract(const Duration(hours: 4)),
      isSeen: true,
    );
    final groupMsg2 = MessageModel(
      messageId: 'gmsg_002',
      senderId: 'user_alice_01',
      receiverId: group1Id,
      senderName: 'Alice Johnson',
      text: 'Excited for the new group chat & channel features! 🌐✨',
      timestamp: now.subtract(const Duration(hours: 2)),
      isSeen: true,
      reaction: '🔥',
    );
    final groupMsg3 = MessageModel(
      messageId: 'gmsg_003',
      senderId: 'user_charlie_03',
      receiverId: group1Id,
      senderName: 'Charlie Dev',
      text: 'v1.3.0 Google Play Store release build is verified and ready! 🚀',
      timestamp: now.subtract(const Duration(minutes: 18)),
      isSeen: false,
    );
    _mockMessages[group1Id] = [groupMsg1, groupMsg2, groupMsg3];

    _mockChats.add(
      ChatModel(
        chatId: group1Id,
        participants: [
          AppConstants.devUserId,
          'user_alice_01',
          'user_charlie_03',
          'user_bob_02',
        ],
        lastMessage: 'Charlie: v1.3.0 Google Play Store release build is verified and ready! 🚀',
        lastMessageTime: now.subtract(const Duration(minutes: 18)),
        unreadCount: {AppConstants.devUserId: 1},
        isGroup: true,
        groupName: '🚀 Universal AI & Flutter Devs',
        groupDescription: 'Collaborative channel for AI models, Flutter apps, and next-gen communication protocols.',
        groupAdminId: AppConstants.devUserId,
        isFavorite: true,
      ),
    );

    // Initial Group Chat 2: "💡 Tech Innovators"
    const group2Id = 'group_tech_innovators_02';
    final g2Msg1 = MessageModel(
      messageId: 'g2msg_001',
      senderId: 'user_diana_04',
      receiverId: group2Id,
      senderName: 'Diana Prince',
      text: 'End-to-end encryption audit passed with zero vulnerabilities! 🔒',
      timestamp: now.subtract(const Duration(hours: 5)),
      isSeen: true,
    );
    _mockMessages[group2Id] = [g2Msg1];

    _mockChats.add(
      ChatModel(
        chatId: group2Id,
        participants: [
          AppConstants.devUserId,
          'user_diana_04',
          'user_evan_05',
          'user_alice_01',
        ],
        lastMessage: 'Diana: End-to-end encryption audit passed with zero vulnerabilities! 🔒',
        lastMessageTime: now.subtract(const Duration(hours: 5)),
        unreadCount: {AppConstants.devUserId: 0},
        isGroup: true,
        groupName: '💡 Tech Innovators',
        groupDescription: 'Brainstorming revolutionary mobile and AI experiences.',
        groupAdminId: 'user_diana_04',
        isFavorite: false,
      ),
    );

    // Initial Mock Calls (Separated Video & Voice)
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
      CallModel(
        callId: 'call_05',
        callerId: 'user_alice_01',
        receiverId: AppConstants.devUserId,
        callerName: 'Alice Johnson',
        timestamp: now.subtract(const Duration(days: 1, hours: 6)),
        durationSeconds: 520,
        isVideo: false,
        isMissed: false,
        isOutgoing: false,
      ),
    ]);

    // Initial Mock Status Stories
    _mockStatuses.addAll([
      StatusModel(
        statusId: 'stat_01',
        userId: 'user_alice_01',
        userName: 'Alice Johnson',
        text: 'Building next-generation intelligent communication tools! 🌐✨\nUniversal Chat App is live.',
        backgroundColorHex: 0xFF005C4B,
        timestamp: now.subtract(const Duration(minutes: 35)),
        isViewed: false,
      ),
      StatusModel(
        statusId: 'stat_02',
        userId: 'user_charlie_03',
        userName: 'Charlie Dev',
        text: 'Play Store Google Play Bundle ready! 🚀\nUniversal Chat App v1.3.0 is compiled.',
        backgroundColorHex: 0xFF128C7E,
        timestamp: now.subtract(const Duration(hours: 2)),
        isViewed: false,
      ),
      StatusModel(
        statusId: 'stat_03',
        userId: 'user_diana_04',
        userName: 'Diana Prince',
        text: 'Coffee & zero-knowledge cryptography session ☕🎧',
        backgroundColorHex: 0xFF5856D6,
        timestamp: now.subtract(const Duration(hours: 6)),
        isViewed: true,
      ),
    ]);

    // Initial Mock News Channels / Broadcast Updates
    _mockChannels.addAll([
      ChannelModel(
        channelId: 'chan_01',
        name: '🤖 Universal AI Tech Feed',
        handle: '@universal_ai',
        description: 'Official broadcast on Deep Learning, Gemini models, and mobile AI innovations.',
        category: 'Artificial Intelligence',
        avatar: '🤖',
        isVerified: true,
        followersCount: 148500,
        isFollowing: true,
        latestUpdate: 'Gemini 2.5 Flash achieves lightning-fast sub-second latency for real-time mobile multi-agent chats.',
        timestamp: now.subtract(const Duration(minutes: 45)),
      ),
      ChannelModel(
        channelId: 'chan_02',
        name: '📱 Flutter & Mobile Ecosystem',
        handle: '@flutter_global',
        description: 'Updates from the Flutter & Dart global developer community.',
        category: 'Software Engineering',
        avatar: '📱',
        isVerified: true,
        followersCount: 231000,
        isFollowing: true,
        latestUpdate: 'Flutter 3.29 release brings enhanced Impeller GPU pipeline with zero shader compilation jank.',
        timestamp: now.subtract(const Duration(hours: 3)),
      ),
      ChannelModel(
        channelId: 'chan_03',
        name: '🛡️ CyberSecurity & E2EE Watch',
        handle: '@cyber_sec',
        description: 'Global alerts on privacy, cryptography standards, and digital communication safety.',
        category: 'Security',
        avatar: '🛡️',
        isVerified: true,
        followersCount: 92400,
        isFollowing: false,
        latestUpdate: 'New post-quantum cryptographic key exchanges are adopted for universal peer-to-peer security.',
        timestamp: now.subtract(const Duration(hours: 8)),
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

  // Stream of recent chats (1-to-1 + Groups)
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

  // Stream of channels / news
  Stream<List<ChannelModel>> getChannelsStream() {
    Future.microtask(() => _channelsController.add(List.from(_mockChannels)));
    return _channelsController.stream;
  }

  // Toggle channel follow
  Future<void> toggleChannelFollow(String channelId) async {
    final idx = _mockChannels.indexWhere((c) => c.channelId == channelId);
    if (idx >= 0) {
      final cur = _mockChannels[idx];
      _mockChannels[idx] = cur.copyWith(
        isFollowing: !cur.isFollowing,
        followersCount: cur.isFollowing ? cur.followersCount - 1 : cur.followersCount + 1,
      );
      _channelsController.add(List.from(_mockChannels));
    }
  }

  // Toggle favorite chat
  Future<void> toggleChatFavorite(String chatId) async {
    final idx = _mockChats.indexWhere((c) => c.chatId == chatId);
    if (idx >= 0) {
      final cur = _mockChats[idx];
      _mockChats[idx] = cur.copyWith(isFavorite: !cur.isFavorite);
      _chatsController.add(List.from(_mockChats));
    }
  }

  // Create new group chat
  Future<ChatModel> createGroup({
    required String groupName,
    required String groupDescription,
    required List<String> participantIds,
    required String adminId,
  }) async {
    final now = DateTime.now();
    final groupId = 'group_${DateTime.now().millisecondsSinceEpoch}';
    final allParticipants = [adminId, ...participantIds].toSet().toList();

    final welcomeMsg = MessageModel(
      messageId: 'gmsg_${DateTime.now().millisecondsSinceEpoch}',
      senderId: adminId,
      receiverId: groupId,
      senderName: AppConstants.devUserName,
      text: 'Group created: "$groupName". Welcome everyone! 🌐',
      timestamp: now,
      isSeen: true,
    );

    _mockMessages[groupId] = [welcomeMsg];

    final newGroup = ChatModel(
      chatId: groupId,
      participants: allParticipants,
      lastMessage: 'Group created: "$groupName"',
      lastMessageTime: now,
      unreadCount: {},
      isGroup: true,
      groupName: groupName,
      groupDescription: groupDescription,
      groupAdminId: adminId,
      isFavorite: false,
    );

    _mockChats.insert(0, newGroup);
    _chatsController.add(List.from(_mockChats));
    return newGroup;
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

  // Send message in mock mode + auto-reply simulator (Text, Media, Docs, Audio, Location, Contact, Stickers)
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String receiverId,
    required String text,
    String messageType = 'text',
    String? audioDuration,
    String? senderName,
    String? fileName,
    String? fileSize,
    String? mediaUrl,
    String? replyToText,
    String? replyToSender,
    String? locationName,
    String? locationCoords,
    String? contactName,
    String? contactPhone,
    String? stickerUrl,
    double? paymentAmount,
    String? paymentStatus,
    String? paymentNote,
    String? paymentTxnId,
    String? paymentReceiverName,
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
      senderName: senderName ?? AppConstants.devUserName,
      fileName: fileName,
      fileSize: fileSize,
      mediaUrl: mediaUrl,
      replyToText: replyToText,
      replyToSender: replyToSender,
      locationName: locationName,
      locationCoords: locationCoords,
      contactName: contactName,
      contactPhone: contactPhone,
      stickerUrl: stickerUrl,
      paymentAmount: paymentAmount,
      paymentStatus: paymentStatus,
      paymentNote: paymentNote,
      paymentTxnId: paymentTxnId,
      paymentReceiverName: paymentReceiverName,
    );

    if (!_mockMessages.containsKey(chatId)) {
      _mockMessages[chatId] = [];
    }
    _mockMessages[chatId]!.add(newMsg);

    // Format display preview
    String displayText = text;
    if (paymentAmount != null) {
      displayText = '💸 Paid ₹${paymentAmount.toStringAsFixed(2)} via UPI';
    } else if (messageType == 'audio') {
      displayText = '🎤 Voice message ($audioDuration)';
    } else if (messageType == 'image') {
      displayText = '📷 Photo';
    } else if (messageType == 'video') {
      displayText = '🎥 Video';
    } else if (messageType == 'document') {
      displayText = '📄 Document ($fileName)';
    }

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

    // Simulate auto-reply bot if 1-to-1 mock contact
    final isGroup = _mockChats.any((c) => c.chatId == chatId && c.isGroup);
    if (!isGroup) {
      if (messageType == 'text') {
        _simulateAutoReply(chatId, receiverId, senderId, text);
      } else if (messageType == 'audio') {
        _simulateAudioAutoReply(chatId, receiverId, senderId);
      } else if (messageType == 'image' || messageType == 'document') {
        _simulateMediaAutoReply(chatId, receiverId, senderId, messageType);
      }
    }
  }

  void _simulateMediaAutoReply(String chatId, String botId, String currentUserId, String type) {
    Timer(const Duration(milliseconds: 1800), () {
      _typingControllers[chatId]?.add(true);
    });

    Timer(const Duration(milliseconds: 3200), () {
      _typingControllers[chatId]?.add(false);
      final now = DateTime.now();
      final replyText = type == 'image'
          ? 'Great photo! High resolution received via E2EE transfer. 📸'
          : 'Document securely downloaded and verified! 📄✅';

      final replyMsg = MessageModel(
        messageId: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        senderId: botId,
        receiverId: currentUserId,
        text: replyText,
        timestamp: now,
        isSeen: true,
        reaction: '👍',
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
        replyText = 'Hey ${AppConstants.devUserName}! Universal Chat App is running with ultra-fast latency and strict E2EE!';
      } else if (lower.contains('group') || lower.contains('channel')) {
        replyText = 'You can create groups and follow news channels directly from the Universal Chat interface! 🌐';
      } else if (lower.contains('call') || lower.contains('video')) {
        replyText = 'HD voice and video calling channels are operational and logged in the Calls tab.';
      } else {
        replyText = 'Received: "$userText". Encrypted via AES-256 and replicated across nodes! ✅';
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

  Future<void> editMessage(String chatId, String messageId, String newText) async {
    final msgs = _mockMessages[chatId];
    if (msgs != null) {
      final idx = msgs.indexWhere((m) => m.messageId == messageId);
      if (idx >= 0) {
        msgs[idx] = msgs[idx].copyWith(text: newText, isEdited: true);
        _messagesControllers[chatId]?.add(List.from(msgs));
      }
    }
  }

  Future<void> deleteMessage(String chatId, String messageId, {required bool everyone}) async {
    final msgs = _mockMessages[chatId];
    if (msgs != null) {
      final idx = msgs.indexWhere((m) => m.messageId == messageId);
      if (idx >= 0) {
        if (everyone) {
          msgs[idx] = msgs[idx].copyWith(isDeletedForEveryone: true);
        } else {
          msgs[idx] = msgs[idx].copyWith(isDeletedForMe: true);
        }
        _messagesControllers[chatId]?.add(List.from(msgs));
      }
    }
  }

  Future<void> toggleStarMessage(String chatId, String messageId) async {
    final msgs = _mockMessages[chatId];
    if (msgs != null) {
      final idx = msgs.indexWhere((m) => m.messageId == messageId);
      if (idx >= 0) {
        final cur = msgs[idx].isStarred;
        msgs[idx] = msgs[idx].copyWith(isStarred: !cur);
        _messagesControllers[chatId]?.add(List.from(msgs));
      }
    }
  }

  Future<void> pinMessage(String chatId, String messageId, String text) async {
    final msgs = _mockMessages[chatId];
    if (msgs != null) {
      for (int i = 0; i < msgs.length; i++) {
        msgs[i] = msgs[i].copyWith(isPinned: msgs[i].messageId == messageId);
      }
      _messagesControllers[chatId]?.add(List.from(msgs));
    }
    final chatIdx = _mockChats.indexWhere((c) => c.chatId == chatId);
    if (chatIdx >= 0) {
      _mockChats[chatIdx] = _mockChats[chatIdx].copyWith(
        pinnedMessageId: messageId,
        pinnedMessageText: text,
      );
      _chatsController.add(List.from(_mockChats));
    }
  }

  Future<void> unpinMessage(String chatId) async {
    final chatIdx = _mockChats.indexWhere((c) => c.chatId == chatId);
    if (chatIdx >= 0) {
      _mockChats[chatIdx] = _mockChats[chatIdx].copyWith(
        pinnedMessageId: null,
        pinnedMessageText: null,
      );
      _chatsController.add(List.from(_mockChats));
    }
  }

  UserModel? getUserById(String uid) {
    if (uid == AppConstants.devUserId) return _currentDevUser;
    final idx = _mockUsers.indexWhere((u) => u.uid == uid);
    if (idx >= 0) return _mockUsers[idx];
    return null;
  }
}

