import 'package:cloud_firestore/cloud_firestore.dart';

class StatusModel {
  final String statusId;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String text;
  final String? mediaUrl;
  final int backgroundColorHex;
  final DateTime timestamp;
  final bool isViewed;
  final int viewCount;
  final List<String> viewers;
  final String statusType; // 'text', 'photo', 'video', 'gif'
  final String? caption;

  StatusModel({
    required this.statusId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.text,
    this.mediaUrl,
    this.backgroundColorHex = 0xFF005C4B,
    required this.timestamp,
    this.isViewed = false,
    this.viewCount = 0,
    this.viewers = const [],
    this.statusType = 'text',
    this.caption,
  });

  Map<String, dynamic> toMap() {
    return {
      'statusId': statusId,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'text': text,
      'mediaUrl': mediaUrl,
      'backgroundColorHex': backgroundColorHex,
      'timestamp': Timestamp.fromDate(timestamp),
      'isViewed': isViewed,
      'viewCount': viewCount,
      'viewers': viewers,
      'statusType': statusType,
      'caption': caption,
    };
  }

  factory StatusModel.fromMap(Map<String, dynamic> map, {String? documentId}) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    final rawViewers = map['viewers'];
    List<String> viewersList = [];
    if (rawViewers is List) {
      viewersList = rawViewers.map((e) => e.toString()).toList();
    }

    return StatusModel(
      statusId: documentId ?? map['statusId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      userName: map['userName'] as String? ?? 'User',
      userAvatar: map['userAvatar'] as String?,
      text: map['text'] as String? ?? '',
      mediaUrl: map['mediaUrl'] as String?,
      backgroundColorHex: map['backgroundColorHex'] as int? ?? 0xFF005C4B,
      timestamp: map['timestamp'] != null ? parseDate(map['timestamp']) : DateTime.now(),
      isViewed: map['isViewed'] as bool? ?? false,
      viewCount: map['viewCount'] as int? ?? (viewersList.isNotEmpty ? viewersList.length : 0),
      viewers: viewersList,
      statusType: map['statusType'] as String? ?? 'text',
      caption: map['caption'] as String?,
    );
  }

  factory StatusModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return StatusModel.fromMap(data, documentId: doc.id);
  }

  StatusModel copyWith({
    String? statusId,
    String? userId,
    String? userName,
    String? userAvatar,
    String? text,
    String? mediaUrl,
    int? backgroundColorHex,
    DateTime? timestamp,
    bool? isViewed,
    int? viewCount,
    List<String>? viewers,
    String? statusType,
    String? caption,
  }) {
    return StatusModel(
      statusId: statusId ?? this.statusId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      text: text ?? this.text,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      backgroundColorHex: backgroundColorHex ?? this.backgroundColorHex,
      timestamp: timestamp ?? this.timestamp,
      isViewed: isViewed ?? this.isViewed,
      viewCount: viewCount ?? this.viewCount,
      viewers: viewers ?? this.viewers,
      statusType: statusType ?? this.statusType,
      caption: caption ?? this.caption,
    );
  }
}
