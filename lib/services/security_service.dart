import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecurityService with ChangeNotifier {
  static final SecurityService instance = SecurityService._internal();
  SecurityService._internal() {
    _loadSecuritySettings();
  }

  static const String _prefAppLockEnabled = 'security_app_lock_enabled';
  static const String _prefAppLockPin = 'security_app_lock_pin';
  static const String _prefBlockedUsers = 'security_blocked_users';

  bool _isAppLockEnabled = false;
  String _currentPin = '1234';
  bool _isAppUnlocked = false;
  final Set<String> _blockedUserIds = {};

  bool get isAppLockEnabled => _isAppLockEnabled;
  String get currentPin => _currentPin;
  bool get isAppUnlocked => _isAppUnlocked;
  Set<String> get blockedUserIds => _blockedUserIds;

  Future<void> _loadSecuritySettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isAppLockEnabled = prefs.getBool(_prefAppLockEnabled) ?? false;
    _currentPin = prefs.getString(_prefAppLockPin) ?? '1234';

    final blocked = prefs.getStringList(_prefBlockedUsers) ?? [];
    _blockedUserIds.addAll(blocked);
    notifyListeners();
  }

  /// Check if user has entered correct PIN
  bool verifyPin(String enteredPin) {
    if (enteredPin == _currentPin) {
      _isAppUnlocked = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Lock app again (e.g. on backgrounding or manual lock)
  void lockApp() {
    if (_isAppLockEnabled) {
      _isAppUnlocked = false;
      notifyListeners();
    }
  }

  /// Toggle App Lock state
  Future<void> setAppLockEnabled(bool enabled) async {
    _isAppLockEnabled = enabled;
    if (!enabled) {
      _isAppUnlocked = true;
    }
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefAppLockEnabled, enabled);
  }

  /// Change Security PIN
  Future<void> changePin(String newPin) async {
    _currentPin = newPin;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefAppLockPin, newPin);
  }

  /// Block a contact
  Future<void> blockUser(String userId) async {
    _blockedUserIds.add(userId);
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefBlockedUsers, _blockedUserIds.toList());
  }

  /// Unblock a contact
  Future<void> unblockUser(String userId) async {
    _blockedUserIds.remove(userId);
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefBlockedUsers, _blockedUserIds.toList());
  }

  /// Check if user is blocked
  bool isUserBlocked(String userId) {
    return _blockedUserIds.contains(userId);
  }
}
