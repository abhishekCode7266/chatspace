import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/mock_data_service.dart';
import '../services/notification_service.dart';
import '../services/user_service.dart';
import '../utils/constants.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isDevBypass = false;
  StreamSubscription<User?>? _authSubscription;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isDevBypass => _isDevBypass;

  AuthProvider() {
    _initAuthListener();
  }

  Future<void> _initAuthListener() async {
    final prefs = await SharedPreferences.getInstance();
    final isDev = prefs.getBool(AppConstants.prefDevBypass) ?? false;

    if (isDev) {
      _isDevBypass = true;
      _currentUser = MockDataService.instance.currentDevUser;
      notifyListeners();
      return;
    }

    try {
      _authSubscription = _authService.authStateChanges.listen((User? user) async {
        if (user != null) {
          await _loadUserProfile(user.uid);
        } else {
          _currentUser = null;
          notifyListeners();
        }
      });
    } catch (_) {
      // Firebase may not be initialized yet in local test/preview
    }
  }

  Future<void> _loadUserProfile(String uid) async {
    try {
      final userModel = await _userService.getUserProfile(uid);
      if (userModel != null) {
        _currentUser = userModel;
        await _userService.updateOnlineStatus(uid: uid, isOnline: true);
        await NotificationService.instance.getAndSaveToken(uid);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user profile: $e');
    }
  }

  /// Signup with Email & Password
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final cred = await _authService.signUpWithEmailPassword(
        email: email,
        password: password,
      );

      final user = UserModel(
        uid: cred.user!.uid,
        name: name.trim(),
        email: email.trim(),
        isOnline: true,
        lastSeen: DateTime.now(),
        createdAt: DateTime.now(),
      );

      await _userService.createUserProfile(user);
      _currentUser = user;
      await NotificationService.instance.getAndSaveToken(user.uid);

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Login with Email & Password
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final cred = await _authService.signInWithEmailPassword(
        email: email,
        password: password,
      );

      await _loadUserProfile(cred.user!.uid);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Send Forgot Password Reset Email
  Future<bool> forgotPassword(String email) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.sendPasswordResetEmail(email);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  /// Developer Mode Bypass Login (डेवलपर मोड बाईपास)
  /// Instantly logs in with full mock real-time capabilities
  Future<void> developerBypassLogin() async {
    _setLoading(true);
    _clearError();

    await Future.delayed(const Duration(milliseconds: 300));

    _isDevBypass = true;
    _currentUser = MockDataService.instance.currentDevUser;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefDevBypass, true);

    _setLoading(false);
  }

  /// Toggle Developer Mode Bypass on or off
  Future<void> toggleDevBypass() async {
    final prefs = await SharedPreferences.getInstance();
    if (_isDevBypass) {
      _isDevBypass = false;
      await prefs.setBool(AppConstants.prefDevBypass, false);
      if (_currentUser?.uid == AppConstants.devUserId) {
        _currentUser = null;
      }
    } else {
      _isDevBypass = true;
      _currentUser = MockDataService.instance.currentDevUser;
      await prefs.setBool(AppConstants.prefDevBypass, true);
    }
    notifyListeners();
  }

  /// Explicitly set Developer Mode Bypass state
  Future<void> setDevBypass(bool value) async {
    if (_isDevBypass == value) return;
    await toggleDevBypass();
  }

  /// Update Display Name and Status Bio
  Future<bool> updateProfile({
    required String name,
    required String status,
  }) async {
    if (_currentUser == null) return false;

    _setLoading(true);
    _clearError();

    try {
      if (_isDevBypass) {
        MockDataService.instance.updateDevUserProfile(
          name: name,
          status: status,
        );
        _currentUser = _currentUser!.copyWith(name: name, status: status);
      } else {
        await _userService.updateUserProfile(
          uid: _currentUser!.uid,
          name: name,
          status: status,
        );
        _currentUser = _currentUser!.copyWith(name: name, status: status);
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Failed to update profile: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Sign Out and reset presence
  Future<void> logout() async {
    _setLoading(true);

    try {
      if (_isDevBypass) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(AppConstants.prefDevBypass);
        _isDevBypass = false;
        _currentUser = null;
      } else {
        if (_currentUser != null) {
          await _userService.updateOnlineStatus(
            uid: _currentUser!.uid,
            isOnline: false,
          );
        }
        await _authService.signOut();
        _currentUser = null;
      }
    } catch (e) {
      debugPrint('Logout error: $e');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String msg) {
    _errorMessage = msg;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
