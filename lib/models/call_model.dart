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
  final bool isGroupCall;
  final List<String> participantNames;

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
    this.isGroupCall = false,
    this.participantNames = const [],
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
      'isGroupCall': isGroupCall,
      'participantNames': participantNames,
    };
  }

  factory CallModel.fromMap(Map<String, dynamic> map, {String? documentId}) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    final rawParticipants = map['participantNames'];
    List<String> participants = [];
    if (rawParticipants is List) {
      participants = rawParticipants.map((e) => e.toString()).toList();
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
      isOutgoing: map['isOutgoing'] as bool? ?? true,
      isGroupCall: map['isGroupCall'] as bool? ?? false,
      participantNames: participants,
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
    bool? isGroupCall,
    List<String>? participantNames,
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
      isGroupCall: isGroupCall ?? this.isGroupCall,
      participantNames: participantNames ?? this.participantNames,
    );
  }
}
