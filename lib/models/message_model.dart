import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String messageId;
  final String senderId;
  final String receiverId;
  final String text;
  final DateTime timestamp;
  final bool isSeen;
  final String? reaction; // e.g. '👍', '❤️', '😂', '😮', '😢', '🙏'
  final String messageType; // 'text', 'audio', 'image', 'video', 'document', 'call'
  final String? audioDuration; // e.g. '0:14'
  final String? senderName; // for group messages
  final String? mediaUrl;
  final String? fileName;
  final String? fileSize;
  final bool isDisappearing;

  MessageModel({
    required this.messageId,
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.timestamp,
    this.isSeen = false,
    this.reaction,
    this.messageType = 'text',
    this.audioDuration,
    this.senderName,
    this.mediaUrl,
    this.fileName,
    this.fileSize,
    this.isDisappearing = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
      'isSeen': isSeen,
      'reaction': reaction,
      'messageType': messageType,
      'audioDuration': audioDuration,
      'senderName': senderName,
      'mediaUrl': mediaUrl,
      'fileName': fileName,
      'fileSize': fileSize,
      'isDisappearing': isDisappearing,
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map, {String? documentId}) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return MessageModel(
      messageId: documentId ?? map['messageId'] as String? ?? '',
      senderId: map['senderId'] as String? ?? '',
      receiverId: map['receiverId'] as String? ?? '',
      text: map['text'] as String? ?? '',
      timestamp: map['timestamp'] != null ? parseDate(map['timestamp']) : DateTime.now(),
      isSeen: map['isSeen'] as bool? ?? false,
      reaction: map['reaction'] as String?,
      messageType: map['messageType'] as String? ?? 'text',
      audioDuration: map['audioDuration'] as String?,
      senderName: map['senderName'] as String?,
      mediaUrl: map['mediaUrl'] as String?,
      fileName: map['fileName'] as String?,
      fileSize: map['fileSize'] as String?,
      isDisappearing: map['isDisappearing'] as bool? ?? false,
    );
  }

  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return MessageModel.fromMap(data, documentId: doc.id);
  }

  MessageModel copyWith({
    String? messageId,
    String? senderId,
    String? receiverId,
    String? text,
    DateTime? timestamp,
    bool? isSeen,
    String? reaction,
    String? messageType,
    String? audioDuration,
    String? senderName,
    String? mediaUrl,
    String? fileName,
    String? fileSize,
    bool? isDisappearing,
  }) {
    return MessageModel(
      messageId: messageId ?? this.messageId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      isSeen: isSeen ?? this.isSeen,
      reaction: reaction ?? this.reaction,
      messageType: messageType ?? this.messageType,
      audioDuration: audioDuration ?? this.audioDuration,
      senderName: senderName ?? this.senderName,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      isDisappearing: isDisappearing ?? this.isDisappearing,
    );
  }
}
