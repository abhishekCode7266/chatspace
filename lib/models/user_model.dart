import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String status;
  final bool isOnline;
  final DateTime? lastSeen;
  final String? fcmToken;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.status = 'Hey there! I am using ChatSpace.',
    this.isOnline = false,
    this.lastSeen,
    this.fcmToken,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'status': status,
      'isOnline': isOnline,
      'lastSeen': lastSeen != null ? Timestamp.fromDate(lastSeen!) : null,
      'fcmToken': fcmToken,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, {String? documentId}) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return UserModel(
      uid: documentId ?? map['uid'] as String? ?? '',
      name: map['name'] as String? ?? 'User',
      email: map['email'] as String? ?? '',
      status: map['status'] as String? ?? 'Hey there! I am using ChatSpace.',
      isOnline: map['isOnline'] as bool? ?? false,
      lastSeen: map['lastSeen'] != null ? parseDate(map['lastSeen']) : null,
      fcmToken: map['fcmToken'] as String?,
      createdAt: map['createdAt'] != null ? parseDate(map['createdAt']) : DateTime.now(),
    );
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel.fromMap(data, documentId: doc.id);
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? status,
    bool? isOnline,
    DateTime? lastSeen,
    String? fcmToken,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      status: status ?? this.status,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      fcmToken: fcmToken ?? this.fcmToken,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
