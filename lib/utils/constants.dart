import 'package:flutter/material.dart';

class AppConstants {
  // App Info
  static const String appName = 'Universal Chat App';
  static const String appShortName = 'Universal App';
  static const String appTagline = 'Next-Gen Intelligent Messaging, HD Calling & Media Sharing';
  static const String appVersion = '1.3.0';

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String chatsCollection = 'chats';
  static const String messagesCollection = 'messages';
  static const String callsCollection = 'calls';
  static const String statusCollection = 'statuses';
  static const String channelsCollection = 'channels';

  // SharedPreferences Keys
  static const String prefThemeMode = 'theme_mode';
  static const String prefDevBypass = 'developer_bypass_enabled';
  static const String prefCurrentUserId = 'current_user_id';
  static const String prefFavoriteChats = 'favorite_chat_ids';

  // Notification Channel
  static const String notificationChannelId = 'universal_chat_high_importance_channel';
  static const String notificationChannelName = 'Universal Chat App Alerts';
  static const String notificationChannelDesc = 'Real-time messages, HD calls, and channel updates';

  // Developer Bypass Defaults
  static const String devUserId = 'dev_user_universal_99';
  static const String devUserName = 'Developer (Admin)';
  static const String devUserEmail = 'developer@universalchat.app';
  static const String devUserStatus = '🌐 Universal Chat App Dev Active | Testing Mode';
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
