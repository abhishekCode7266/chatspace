import 'package:cloud_firestore/cloud_firestore.dart';

class CallModel {
  final String callId;
  final String callerId;
  final String receiverId;
  final String callerName;
  final String? callerAvatar;
  final DateTime timestamp;
  final int durationSeconds;
  final bool isVideo;
  final bool isMissed;
  final bool isOutgoing;

  CallModel({
    required this.callId,
    required this.callerId,
    required this.receiverId,
    required this.callerName,
    this.callerAvatar,
    required this.timestamp,
    this.durationSeconds = 0,
    required this.isVideo,
    this.isMissed = false,
    required this.isOutgoing,
  });

  Map<String, dynamic> toMap() {
    return {
      'callId': callId,
      'callerId': callerId,
      'receiverId': receiverId,
      'callerName': callerName,
      'callerAvatar': callerAvatar,
      'timestamp': Timestamp.fromDate(timestamp),
      'durationSeconds': durationSeconds,
      'isVideo': isVideo,
      'isMissed': isMissed,
      'isOutgoing': isOutgoing,
    };
  }

  factory CallModel.fromMap(Map<String, dynamic> map, {String? documentId}) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return CallModel(
      callId: documentId ?? map['callId'] as String? ?? '',
      callerId: map['callerId'] as String? ?? '',
      receiverId: map['receiverId'] as String? ?? '',
      callerName: map['callerName'] as String? ?? 'Unknown',
      callerAvatar: map['callerAvatar'] as String?,
      timestamp: map['timestamp'] != null ? parseDate(map['timestamp']) : DateTime.now(),
      durationSeconds: map['durationSeconds'] as int? ?? 0,
      isVideo: map['isVideo'] as bool? ?? false,
      isMissed: map['isMissed'] as bool? ?? false,
      isOutgoing: map['isOutgoing'] as bool? ?? false,
    );
  }

  factory CallModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return CallModel.fromMap(data, documentId: doc.id);
  }

  CallModel copyWith({
    String? callId,
    String? callerId,
    String? receiverId,
    String? callerName,
    String? callerAvatar,
    DateTime? timestamp,
    int? durationSeconds,
    bool? isVideo,
    bool? isMissed,
    bool? isOutgoing,
  }) {
    return CallModel(
      callId: callId ?? this.callId,
      callerId: callerId ?? this.callerId,
      receiverId: receiverId ?? this.receiverId,
      callerName: callerName ?? this.callerName,
      callerAvatar: callerAvatar ?? this.callerAvatar,
      timestamp: timestamp ?? this.timestamp,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      isVideo: isVideo ?? this.isVideo,
      isMissed: isMissed ?? this.isMissed,
      isOutgoing: isOutgoing ?? this.isOutgoing,
    );
  }
}
