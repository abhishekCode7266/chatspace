import 'package:flutter/material.dart';

class AppConstants {
  // App Info
  static const String appName = 'WhatsChat';
  static const String appTagline = 'Simple. Secure. Reliable Messaging & HD Calling.';
  static const String appVersion = '1.2.0';

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String chatsCollection = 'chats';
  static const String messagesCollection = 'messages';
  static const String callsCollection = 'calls';
  static const String statusCollection = 'statuses';

  // SharedPreferences Keys
  static const String prefThemeMode = 'theme_mode';
  static const String prefDevBypass = 'developer_bypass_enabled';
  static const String prefCurrentUserId = 'current_user_id';

  // Notification Channel
  static const String notificationChannelId = 'whatschat_high_importance_channel';
  static const String notificationChannelName = 'WhatsChat Messages';
  static const String notificationChannelDesc = 'Real-time chat & HD call alerts';

  // Developer Bypass Defaults
  static const String devUserId = 'dev_user_whatschat_99';
  static const String devUserName = 'Developer (Admin)';
  static const String devUserEmail = 'developer@whatschat.internal';
  static const String devUserStatus = '🚀 WhatsChat Developer Bypass Active | Testing Mode';
}

class AppColors {
  // Brand colors
  static const Color primary = Color(0xFF00A884);
  static const Color primaryDark = Color(0xFF008069);
  static const Color primaryLight = Color(0xFF25D366);
  static const Color secondary = Color(0xFF128C7E);
  static const Color accent = Color(0xFF34B7F1);

  // Status colors
  static const Color online = Color(0xFF25D366);
  static const Color offline = Color(0xFF9E9E9E);
  static const Color seenTick = Color(0xFF34B7F1);
  static const Color sentTick = Color(0xFF8696A0);

  // Chat Bubble colors - Light Theme
  static const Color lightSentBubble = Color(0xFFE7FFDB);
  static const Color lightReceivedBubble = Color(0xFFFFFFFF);
  static const Color lightChatBackground = Color(0xFFECE5DD);

  // Chat Bubble colors - Dark Theme
  static const Color darkSentBubble = Color(0xFF005C4B);
  static const Color darkReceivedBubble = Color(0xFF202C33);
  static const Color darkChatBackground = Color(0xFF0B141A);

  // Neutral Colors
  static const Color darkBackground = Color(0xFF121B22);
  static const Color darkSurface = Color(0xFF1F2C34);
  static const Color darkCard = Color(0xFF233138);

  static const Color lightBackground = Color(0xFFF7F8FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
}
