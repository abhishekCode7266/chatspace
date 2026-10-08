import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String chatId;
  final List<String> participants;
  final String lastMessage;
  final DateTime? lastMessageTime;
  final Map<String, int> unreadCount;
  final bool isGroup;
  final String? groupName;
  final String? groupDescription;
  final String? groupAdminId;
  final String? groupAvatar;
  final bool isFavorite;

  // New Universal Chat Capabilities
  final bool isCommunity;
  final String? pinnedMessageId;
  final String? pinnedMessageText;
  final List<String> admins;
  final String? inviteCode;
  final bool isAiAssistant;

  ChatModel({
    required this.chatId,
    required this.participants,
    this.lastMessage = '',
    this.lastMessageTime,
    this.unreadCount = const {},
    this.isGroup = false,
    this.groupName,
    this.groupDescription,
    this.groupAdminId,
    this.groupAvatar,
    this.isFavorite = false,
    this.isCommunity = false,
    this.pinnedMessageId,
    this.pinnedMessageText,
    this.admins = const [],
    this.inviteCode,
    this.isAiAssistant = false,
  });

  /// Returns the other user's ID in a 1-to-1 conversation
  String getOtherUserId(String currentUserId) {
    if (isGroup) return '';
    for (final id in participants) {
      if (id != currentUserId) return id;
    }
    return '';
  }

  /// Returns unread count for current user
  int getUnreadCount(String currentUserId) {
    return unreadCount[currentUserId] ?? 0;
  }

  Map<String, dynamic> toMap() {
    return {
      'chatId': chatId,
      'participants': participants,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime != null ? Timestamp.fromDate(lastMessageTime!) : null,
      'unreadCount': unreadCount,
      'isGroup': isGroup,
      'groupName': groupName,
      'groupDescription': groupDescription,
      'groupAdminId': groupAdminId,
      'groupAvatar': groupAvatar,
      'isFavorite': isFavorite,
      'isCommunity': isCommunity,
      'pinnedMessageId': pinnedMessageId,
      'pinnedMessageText': pinnedMessageText,
      'admins': admins,
      'inviteCode': inviteCode,
      'isAiAssistant': isAiAssistant,
    };
  }

  factory ChatModel.fromMap(Map<String, dynamic> map, {String? documentId}) {
    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      if (val is Timestamp) return val.toDate();
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      if (val is String) return DateTime.tryParse(val);
      return null;
    }

    final rawUnread = map['unreadCount'];
    Map<String, int> unreadMap = {};
    if (rawUnread is Map) {
      rawUnread.forEach((key, value) {
        unreadMap[key.toString()] = (value as num?)?.toInt() ?? 0;
      });
    }

    final rawParticipants = map['participants'];
    List<String> participantsList = [];
    if (rawParticipants is List) {
      participantsList = rawParticipants.map((e) => e.toString()).toList();
    }

    final rawAdmins = map['admins'];
    List<String> adminsList = [];
    if (rawAdmins is List) {
      adminsList = rawAdmins.map((e) => e.toString()).toList();
    } else if (map['groupAdminId'] != null) {
      adminsList = [map['groupAdminId'].toString()];
    }

    return ChatModel(
      chatId: documentId ?? map['chatId'] as String? ?? '',
      participants: participantsList,
      lastMessage: map['lastMessage'] as String? ?? '',
      lastMessageTime: parseDate(map['lastMessageTime']),
      unreadCount: unreadMap,
      isGroup: map['isGroup'] as bool? ?? false,
      groupName: map['groupName'] as String?,
      groupDescription: map['groupDescription'] as String?,
      groupAdminId: map['groupAdminId'] as String?,
      groupAvatar: map['groupAvatar'] as String?,
      isFavorite: map['isFavorite'] as bool? ?? false,
      isCommunity: map['isCommunity'] as bool? ?? false,
      pinnedMessageId: map['pinnedMessageId'] as String?,
      pinnedMessageText: map['pinnedMessageText'] as String?,
      admins: adminsList,
      inviteCode: map['inviteCode'] as String?,
      isAiAssistant: map['isAiAssistant'] as bool? ?? false,
    );
  }

  factory ChatModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ChatModel.fromMap(data, documentId: doc.id);
  }

  ChatModel copyWith({
    String? chatId,
    List<String>? participants,
    String? lastMessage,
    DateTime? lastMessageTime,
    Map<String, int>? unreadCount,
    bool? isGroup,
    String? groupName,
    String? groupDescription,
    String? groupAdminId,
    String? groupAvatar,
    bool? isFavorite,
    bool? isCommunity,
    String? pinnedMessageId,
    String? pinnedMessageText,
    List<String>? admins,
    String? inviteCode,
    bool? isAiAssistant,
  }) {
    return ChatModel(
      chatId: chatId ?? this.chatId,
      participants: participants ?? this.participants,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      isGroup: isGroup ?? this.isGroup,
      groupName: groupName ?? this.groupName,
      groupDescription: groupDescription ?? this.groupDescription,
      groupAdminId: groupAdminId ?? this.groupAdminId,
      groupAvatar: groupAvatar ?? this.groupAvatar,
      isFavorite: isFavorite ?? this.isFavorite,
      isCommunity: isCommunity ?? this.isCommunity,
      pinnedMessageId: pinnedMessageId ?? this.pinnedMessageId,
      pinnedMessageText: pinnedMessageText ?? this.pinnedMessageText,
      admins: admins ?? this.admins,
      inviteCode: inviteCode ?? this.inviteCode,
      isAiAssistant: isAiAssistant ?? this.isAiAssistant,
    );
  }
}
