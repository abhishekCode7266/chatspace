import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _usersRef =>
      _firestore.collection(AppConstants.usersCollection);

  /// Create new user document in Firestore on signup
  Future<void> createUserProfile(UserModel user) async {
    await _usersRef.doc(user.uid).set(user.toMap(), SetOptions(merge: true));
  }

  /// Update user profile (name, status)
  Future<void> updateUserProfile({
    required String uid,
    String? name,
    String? status,
  }) async {
    final Map<String, dynamic> data = {};
    if (name != null && name.trim().isNotEmpty) data['name'] = name.trim();
    if (status != null && status.trim().isNotEmpty) data['status'] = status.trim();

    if (data.isNotEmpty) {
      await _usersRef.doc(uid).update(data);
    }
  }

  /// Get a single user profile once
  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await _usersRef.doc(uid).get();
    if (doc.exists) {
      return UserModel.fromFirestore(doc);
    }
    return null;
  }

  /// Stream a single user profile (to observe online status & changes)
  Stream<UserModel?> streamUserProfile(String uid) {
    return _usersRef.doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    });
  }

  /// Stream all registered users except current user
  Stream<List<UserModel>> getUsersStream(String currentUserId) {
    return _usersRef.snapshots().map((snapshot) {
      return snapshot.docs
          .where((doc) => doc.id != currentUserId)
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Update online status & last seen timestamp
  Future<void> updateOnlineStatus({
    required String uid,
    required bool isOnline,
  }) async {
    try {
      await _usersRef.doc(uid).update({
        'isOnline': isOnline,
        'lastSeen': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // Ignored if offline or unauthenticated during quick disconnect
    }
  }

  /// Save FCM device token to user document
  Future<void> updateFcmToken({
    required String uid,
    required String token,
  }) async {
    try {
      await _usersRef.doc(uid).update({'fcmToken': token});
    } catch (_) {
      // Ignored if permission fails
    }
  }
}
