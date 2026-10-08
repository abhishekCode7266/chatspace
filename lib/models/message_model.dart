import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String messageId;
  final String senderId;
  final String receiverId;
  final String text;
  final DateTime timestamp;
  final bool isSeen;
  final String? reaction; // e.g. '👍', '❤️', '😂', '😮', '😢', '🙏'
  final String messageType; // 'text', 'audio', 'image', 'video', 'document', 'location', 'contact', 'sticker', 'call'
  final String? audioDuration; // e.g. '0:14'
  final String? senderName; // for group messages
  final String? mediaUrl;
  final String? fileName;
  final String? fileSize;
  final bool isDisappearing;

  // New WhatsApp Pro & Universal Chat Features
  final String? replyToText;
  final String? replyToSender;
  final bool isPinned;
  final bool isStarred;
  final bool isEdited;
  final bool isDeletedForEveryone;
  final bool isDeletedForMe;
  final String? locationName;
  final String? locationCoords;
  final String? contactName;
  final String? contactPhone;
  final String? stickerUrl;
  final double? uploadProgress;
  final int forwardCount;

  // In-Chat Payment & WhatsApp Pay / UPI fields
  final double? paymentAmount;
  final String? paymentStatus; // 'SUCCESS', 'PENDING', 'FAILED'
  final String? paymentNote;
  final String? paymentTxnId;
  final String? paymentReceiverName;

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
    this.replyToText,
    this.replyToSender,
    this.isPinned = false,
    this.isStarred = false,
    this.isEdited = false,
    this.isDeletedForEveryone = false,
    this.isDeletedForMe = false,
    this.locationName,
    this.locationCoords,
    this.contactName,
    this.contactPhone,
    this.stickerUrl,
    this.uploadProgress,
    this.forwardCount = 0,
    this.paymentAmount,
    this.paymentStatus,
    this.paymentNote,
    this.paymentTxnId,
    this.paymentReceiverName,
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
      'replyToText': replyToText,
      'replyToSender': replyToSender,
      'isPinned': isPinned,
      'isStarred': isStarred,
      'isEdited': isEdited,
      'isDeletedForEveryone': isDeletedForEveryone,
      'isDeletedForMe': isDeletedForMe,
      'locationName': locationName,
      'locationCoords': locationCoords,
      'contactName': contactName,
      'contactPhone': contactPhone,
      'stickerUrl': stickerUrl,
      'uploadProgress': uploadProgress,
      'forwardCount': forwardCount,
      'paymentAmount': paymentAmount,
      'paymentStatus': paymentStatus,
      'paymentNote': paymentNote,
      'paymentTxnId': paymentTxnId,
      'paymentReceiverName': paymentReceiverName,
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
      replyToText: map['replyToText'] as String?,
      replyToSender: map['replyToSender'] as String?,
      isPinned: map['isPinned'] as bool? ?? false,
      isStarred: map['isStarred'] as bool? ?? false,
      isEdited: map['isEdited'] as bool? ?? false,
      isDeletedForEveryone: map['isDeletedForEveryone'] as bool? ?? false,
      isDeletedForMe: map['isDeletedForMe'] as bool? ?? false,
      locationName: map['locationName'] as String?,
      locationCoords: map['locationCoords'] as String?,
      contactName: map['contactName'] as String?,
      contactPhone: map['contactPhone'] as String?,
      stickerUrl: map['stickerUrl'] as String?,
      uploadProgress: (map['uploadProgress'] as num?)?.toDouble(),
      forwardCount: map['forwardCount'] as int? ?? 0,
      paymentAmount: (map['paymentAmount'] as num?)?.toDouble(),
      paymentStatus: map['paymentStatus'] as String?,
      paymentNote: map['paymentNote'] as String?,
      paymentTxnId: map['paymentTxnId'] as String?,
      paymentReceiverName: map['paymentReceiverName'] as String?,
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
    String? replyToText,
    String? replyToSender,
    bool? isPinned,
    bool? isStarred,
    bool? isEdited,
    bool? isDeletedForEveryone,
    bool? isDeletedForMe,
    String? locationName,
    String? locationCoords,
    String? contactName,
    String? contactPhone,
    String? stickerUrl,
    double? uploadProgress,
    int? forwardCount,
    double? paymentAmount,
    String? paymentStatus,
    String? paymentNote,
    String? paymentTxnId,
    String? paymentReceiverName,
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
      replyToText: replyToText ?? this.replyToText,
      replyToSender: replyToSender ?? this.replyToSender,
      isPinned: isPinned ?? this.isPinned,
      isStarred: isStarred ?? this.isStarred,
      isEdited: isEdited ?? this.isEdited,
      isDeletedForEveryone: isDeletedForEveryone ?? this.isDeletedForEveryone,
      isDeletedForMe: isDeletedForMe ?? this.isDeletedForMe,
      locationName: locationName ?? this.locationName,
      locationCoords: locationCoords ?? this.locationCoords,
      contactName: contactName ?? this.contactName,
      contactPhone: contactPhone ?? this.contactPhone,
      stickerUrl: stickerUrl ?? this.stickerUrl,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      forwardCount: forwardCount ?? this.forwardCount,
      paymentAmount: paymentAmount ?? this.paymentAmount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentNote: paymentNote ?? this.paymentNote,
      paymentTxnId: paymentTxnId ?? this.paymentTxnId,
      paymentReceiverName: paymentReceiverName ?? this.paymentReceiverName,
    );
  }
}
