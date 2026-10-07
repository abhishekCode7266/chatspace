import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String chatId;
  final List<String> participants;
  final String lastMessage;
  final DateTime? lastMessageTime;
  final Map<String, int> unreadCount;

  ChatModel({
    required this.chatId,
    required this.participants,
    this.lastMessage = '',
    this.lastMessageTime,
    this.unreadCount = const {},
  });

  /// Returns the other user's ID in a 1-to-1 conversation
  String getOtherUserId(String currentUserId) {
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

    return ChatModel(
      chatId: documentId ?? map['chatId'] as String? ?? '',
      participants: participantsList,
      lastMessage: map['lastMessage'] as String? ?? '',
      lastMessageTime: parseDate(map['lastMessageTime']),
      unreadCount: unreadMap,
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
  }) {
    return ChatModel(
      chatId: chatId ?? this.chatId,
      participants: participants ?? this.participants,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}
