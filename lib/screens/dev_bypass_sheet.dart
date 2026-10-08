import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import 'ai_assistant_screen.dart';
import 'admin_dashboard_screen.dart';
import 'business_profile_screen.dart';
import 'group_call_screen.dart';
import 'community_screen.dart';
import 'linked_devices_screen.dart';
import 'backup_sync_screen.dart';
import 'privacy_security_screen.dart';
import 'starred_messages_screen.dart';
import 'search_screen.dart';
import 'call_screen.dart';
import '../models/user_model.dart';

/// Developer Bypass & Diagnostic Inspector Suite (Opened via Floating Dev Circle)
class DevBypassSheet extends StatelessWidget {
  const DevBypassSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isBypassActive = authProvider.isDevBypass;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: isBypassActive ? Colors.cyanAccent.withOpacity(0.5) : Colors.amber.withOpacity(0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isBypassActive ? Colors.cyanAccent : Colors.amber).withOpacity(0.25),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.4),
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isBypassActive
                              ? [Colors.cyan, AppColors.primary]
                              : [Colors.amber, Colors.deepOrange],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isBypassActive ? Icons.bolt_rounded : Icons.lock_open_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Developer Inspection Suite',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          isBypassActive ? '🔓 SuperDev Bypass ACTIVE' : '🔒 Bypass Inactive',
                          style: TextStyle(
                            fontSize: 12,
                            color: isBypassActive ? Colors.greenAccent : Colors.amber,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Scrollable Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 1. One-tap bypass toggle banner
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: (isBypassActive ? Colors.cyan : Colors.amber).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: (isBypassActive ? Colors.cyan : Colors.amber).withOpacity(0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Instant Auth Bypass', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            SizedBox(height: 2),
                            Text('Test every screen with full mock database and zero credentials.', style: TextStyle(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                      ),
                      Switch(
                        value: isBypassActive,
                        activeColor: Colors.cyanAccent,
                        onChanged: (val) async {
                          await authProvider.toggleDevBypass();
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),
                const Text(
                  '🚀 DIRECT FEATURE & SCREEN JUMP',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryLight,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 8),

                // Grid of direct navigation buttons
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 2.1,
                  children: [
                    _buildJumpCard(
                      context,
                      title: 'Universal AI Suite',
                      subtitle: 'Chat, Translate, Summarize',
                      icon: Icons.auto_awesome_rounded,
                      color: AppColors.aiPurple,
                      screen: const AiAssistantScreen(),
                    ),
                    _buildJumpCard(
                      context,
                      title: 'Group Video Grid',
                      subtitle: '4-Person HD Grid Call',
                      icon: Icons.video_call_rounded,
                      color: Colors.blueAccent,
                      screen: const GroupCallScreen(groupName: '🚀 Universal AI Devs', isVideo: true),
                    ),
                    _buildJumpCard(
                      context,
                      title: 'Business Hub',
                      subtitle: 'Catalog, Orders, Profile',
                      icon: Icons.storefront_rounded,
                      color: AppColors.businessBlue,
                      screen: const BusinessProfileScreen(),
                    ),
                    _buildJumpCard(
                      context,
                      title: 'Admin Dashboard',
                      subtitle: 'Telemetry, Bans, Moderation',
                      icon: Icons.admin_panel_settings_rounded,
                      color: AppColors.adminGold,
                      screen: const AdminDashboardScreen(),
                    ),
                    _buildJumpCard(
                      context,
                      title: 'Linked Devices',
                      subtitle: 'Web/Desktop Sync, QR',
                      icon: Icons.devices_rounded,
                      color: Colors.teal,
                      screen: const LinkedDevicesScreen(),
                    ),
                    _buildJumpCard(
                      context,
                      title: 'Cloud Backup',
                      subtitle: 'AES-256 Cloud Sync',
                      icon: Icons.cloud_sync_rounded,
                      color: Colors.green,
                      screen: const BackupSyncScreen(),
                    ),
                    _buildJumpCard(
                      context,
                      title: 'Privacy & 2FA',
                      subtitle: 'App Lock, E2EE, Fingerprint',
                      icon: Icons.security_rounded,
                      color: Colors.deepOrange,
                      screen: const PrivacySecurityScreen(),
                    ),
                    _buildJumpCard(
                      context,
                      title: 'Global Search',
                      subtitle: 'Filter Media, Docs, Chats',
                      icon: Icons.search_rounded,
                      color: Colors.indigo,
                      screen: const SearchScreen(),
                    ),
                    _buildJumpCard(
                      context,
                      title: 'Communities',
                      subtitle: 'Broadcast Announcements',
                      icon: Icons.groups_rounded,
                      color: Colors.purple,
                      screen: const CommunityScreen(),
                    ),
                    _buildJumpCard(
                      context,
                      title: 'Starred Messages',
                      subtitle: 'Bookmarks across chats',
                      icon: Icons.star_rounded,
                      color: Colors.amber,
                      screen: const StarredMessagesScreen(),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                const Text(
                  '⚡ SIMULATE REAL-TIME EVENTS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryLight,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 8),

                _buildSimulationTile(
                  icon: Icons.videocam_rounded,
                  color: Colors.green,
                  title: 'Simulate Incoming HD Video Call',
                  subtitle: 'Receive call from Alice Johnson',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CallScreen(
                          targetUser: UserModel(
                            uid: 'user_alice_01',
                            name: 'Alice Johnson',
                            email: 'alice@universalchat.app',
                            status: 'Calling you via Universal HD Call',
                            createdAt: DateTime.now(),
                          ),
                          isVideo: true,
                          isIncoming: true,
                        ),
                      ),
                    );
                  },
                ),
                _buildSimulationTile(
                  icon: Icons.phone_in_talk_rounded,
                  color: Colors.teal,
                  title: 'Simulate Incoming Voice Call',
                  subtitle: 'Receive voice call from Charlie Dev',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CallScreen(
                          targetUser: UserModel(
                            uid: 'user_charlie_03',
                            name: 'Charlie Dev',
                            email: 'charlie@universalchat.app',
                            status: 'Calling you via Universal Audio Call',
                            createdAt: DateTime.now(),
                          ),
                          isVideo: false,
                          isIncoming: true,
                        ),
                      ),
                    );
                  },
                ),
                _buildSimulationTile(
                  icon: Icons.chat_bubble_rounded,
                  color: Colors.blue,
                  title: 'Simulate Push Notification & Message',
                  subtitle: 'Trigger background FCM simulation banner',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Row(
                          children: [
                            Icon(Icons.notifications_active_rounded, color: Colors.white),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text('🔔 Alice Johnson: "Hey! The Universal Chat v1.4.0 build is live on GitHub!"'),
                            ),
                          ],
                        ),
                        backgroundColor: AppColors.primary,
                        duration: Duration(seconds: 4),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJumpCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Widget screen,
  }) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 9, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimulationTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11)),
        trailing: const Icon(Icons.play_circle_fill_rounded, color: AppColors.primary, size: 22),
        onTap: onTap,
      ),
    );
  }
}
