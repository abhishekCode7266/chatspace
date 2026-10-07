import 'package:cloud_firestore/cloud_firestore.dart';

class ChannelModel {
  final String channelId;
  final String name;
  final String handle;
  final String description;
  final String category;
  final String avatar;
  final bool isVerified;
  final int followersCount;
  final bool isFollowing;
  final String latestUpdate;
  final DateTime timestamp;
  final String? imageUrl;

  ChannelModel({
    required this.channelId,
    required this.name,
    required this.handle,
    required this.description,
    this.category = 'Technology',
    this.avatar = '🌐',
    this.isVerified = true,
    this.followersCount = 12500,
    this.isFollowing = false,
    required this.latestUpdate,
    required this.timestamp,
    this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'channelId': channelId,
      'name': name,
      'handle': handle,
      'description': description,
      'category': category,
      'avatar': avatar,
      'isVerified': isVerified,
      'followersCount': followersCount,
      'isFollowing': isFollowing,
      'latestUpdate': latestUpdate,
      'timestamp': Timestamp.fromDate(timestamp),
      'imageUrl': imageUrl,
    };
  }

  factory ChannelModel.fromMap(Map<String, dynamic> map, {String? documentId}) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return ChannelModel(
      channelId: documentId ?? map['channelId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      handle: map['handle'] as String? ?? '',
      description: map['description'] as String? ?? '',
      category: map['category'] as String? ?? 'General',
      avatar: map['avatar'] as String? ?? '🌐',
      isVerified: map['isVerified'] as bool? ?? false,
      followersCount: map['followersCount'] as int? ?? 0,
      isFollowing: map['isFollowing'] as bool? ?? false,
      latestUpdate: map['latestUpdate'] as String? ?? '',
      timestamp: map['timestamp'] != null ? parseDate(map['timestamp']) : DateTime.now(),
      imageUrl: map['imageUrl'] as String?,
    );
  }

  ChannelModel copyWith({
    String? channelId,
    String? name,
    String? handle,
    String? description,
    String? category,
    String? avatar,
    bool? isVerified,
    int? followersCount,
    bool? isFollowing,
    String? latestUpdate,
    DateTime? timestamp,
    String? imageUrl,
  }) {
    return ChannelModel(
      channelId: channelId ?? this.channelId,
      name: name ?? this.name,
      handle: handle ?? this.handle,
      description: description ?? this.description,
      category: category ?? this.category,
      avatar: avatar ?? this.avatar,
      isVerified: isVerified ?? this.isVerified,
      followersCount: followersCount ?? this.followersCount,
      isFollowing: isFollowing ?? this.isFollowing,
      latestUpdate: latestUpdate ?? this.latestUpdate,
      timestamp: timestamp ?? this.timestamp,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
