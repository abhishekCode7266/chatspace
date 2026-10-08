import 'package:flutter/material.dart';
import '../models/admin_model.dart';
import '../utils/constants.dart';

/// Admin Panel & Dashboard
/// Manages Users, Groups, Moderation Reports, Spam Detection, Server Health & Broadcasts
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final SystemMetricsModel _metrics = SystemMetricsModel(
    totalUsers: 14250,
    activeUsersOnline: 3820,
    totalGroups: 940,
    totalMessagesSent: 582100,
    serverUptimePercent: 99.98,
    averageLatencyMs: 22,
    reportedIssues: 2,
    spamBlockedCount: 168,
    lastUpdated: DateTime.now(),
  );

  final List<Map<String, dynamic>> _users = [
    {'uid': 'u_01', 'name': 'Alice Johnson', 'email': 'alice@universalchat.app', 'status': 'Active', 'isBanned': false, 'isVerified': true},
    {'uid': 'u_02', 'name': 'Bob Smith', 'email': 'bob@universalchat.app', 'status': 'Active', 'isBanned': false, 'isVerified': true},
    {'uid': 'u_03', 'name': 'Charlie Dev', 'email': 'charlie@universalchat.app', 'status': 'Active', 'isBanned': false, 'isVerified': true},
    {'uid': 'u_04', 'name': 'Diana Prince', 'email': 'diana@universalchat.app', 'status': 'Active', 'isBanned': false, 'isVerified': false},
    {'uid': 'u_99', 'name': 'SpamBot_3000', 'email': 'spambot@anonymous.net', 'status': 'Flagged', 'isBanned': true, 'isVerified': false},
  ];

  final List<ModerationReportModel> _reports = [
    ModerationReportModel(
      reportId: 'rep_01',
      reportedUserId: 'u_99',
      reportedUserName: 'SpamBot_3000',
      reporterName: 'Alice Johnson',
      reason: 'Repeated promotional phishing links in community channel',
      status: 'Pending',
      timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
    ),
    ModerationReportModel(
      reportId: 'rep_02',
      reportedUserId: 'u_88',
      reportedUserName: 'SuspiciousAccount_42',
      reporterName: 'Charlie Dev',
      reason: 'Unsolicited mass DM spam attempts detected by neural filter',
      status: 'Pending',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
    ),
  ];

  final TextEditingController _broadcastTitleController = TextEditingController();
  final TextEditingController _broadcastMessageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _broadcastTitleController.dispose();
    _broadcastMessageController.dispose();
    super.dispose();
  }

  void _sendBroadcast() {
    final title = _broadcastTitleController.text.trim();
    final message = _broadcastMessageController.text.trim();
    if (title.isEmpty || message.isEmpty) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Global Broadcast'),
        content: Text('Send notification to all ${_metrics.totalUsers} registered users?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              Navigator.pop(ctx);
              _broadcastTitleController.clear();
              _broadcastMessageController.clear();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('📢 Global Broadcast sent to all Universal Chat users successfully!'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            child: const Text('Send Broadcast', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: const [
            Icon(Icons.admin_panel_settings_rounded, color: AppColors.adminGold),
            SizedBox(width: 8),
            Text('Admin Command Center', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.adminGold,
          labelColor: AppColors.adminGold,
          unselectedLabelColor: isDark ? Colors.white70 : Colors.black54,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.speed_rounded), text: 'Telemetry'),
            Tab(icon: Icon(Icons.people_alt_rounded), text: 'Users'),
            Tab(icon: Icon(Icons.security_rounded), text: 'Moderation'),
            Tab(icon: Icon(Icons.campaign_rounded), text: 'Broadcast'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTelemetryTab(isDark),
          _buildUsersTab(isDark),
          _buildModerationTab(isDark),
          _buildBroadcastTab(isDark),
        ],
      ),
    );
  }

  Widget _buildTelemetryTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('System Health & Performance', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: [
              _buildMetricCard('Total Users', '${_metrics.totalUsers}', Icons.groups_rounded, Colors.blue),
              _buildMetricCard('Online Now', '${_metrics.activeUsersOnline}', Icons.sensors_rounded, Colors.green),
              _buildMetricCard('Total Groups', '${_metrics.totalGroups}', Icons.forum_rounded, Colors.purple),
              _buildMetricCard('Messages Sent', '${_metrics.totalMessagesSent}', Icons.chat_bubble_rounded, Colors.teal),
              _buildMetricCard('Server Uptime', '${_metrics.serverUptimePercent}%', Icons.cloud_done_rounded, Colors.orange),
              _buildMetricCard('API Latency', '${_metrics.averageLatencyMs} ms', Icons.timer_rounded, Colors.cyan),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Database & Infrastructure Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          _buildStatusTile('Cloud Firestore Database', 'Healthy • Read/Write 0 errors', Icons.storage_rounded, Colors.green),
          _buildStatusTile('Firebase Auth Gateway', 'Operational • 0 auth drops', Icons.verified_user_rounded, Colors.green),
          _buildStatusTile('WebRTC Voice/Video Signaling', 'Operational • Peer mesh active', Icons.videocam_rounded, Colors.green),
          _buildStatusTile('Neural Spam Detection Filter', 'Active • 168 threats blocked', Icons.shield_rounded, Colors.blue),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildStatusTile(String title, String subtitle, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          const Icon(Icons.check_circle_rounded, color: Colors.green, size: 18),
        ],
      ),
    );
  }

  Widget _buildUsersTab(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _users.length,
      itemBuilder: (context, index) {
        final u = _users[index];
        final isBanned = u['isBanned'] as bool;

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isBanned ? Colors.red.shade100 : Colors.teal.shade100,
              child: Icon(
                isBanned ? Icons.block_rounded : Icons.person_rounded,
                color: isBanned ? Colors.red : AppColors.primary,
              ),
            ),
            title: Row(
              children: [
                Text(u['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                if (u['isVerified'] == true) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.verified_rounded, color: Colors.blueAccent, size: 16),
                ],
              ],
            ),
            subtitle: Text(u['email'], style: const TextStyle(fontSize: 12)),
            trailing: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isBanned ? Colors.green : Colors.redAccent,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              ),
              onPressed: () {
                setState(() {
                  u['isBanned'] = !isBanned;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(isBanned ? '${u['name']} unbanned' : '${u['name']} banned from platform')),
                );
              },
              child: Text(isBanned ? 'Unban' : 'Ban User', style: const TextStyle(color: Colors.white, fontSize: 11)),
            ),
          ),
        );
      },
    );
  }

  Widget _buildModerationTab(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _reports.length,
      itemBuilder: (context, index) {
        final rep = _reports[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Report #${rep.reportId}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(rep.status, style: const TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text('Reported User: ${rep.reportedUserName} (${rep.reportedUserId})', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                Text('Reported by: ${rep.reporterName}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 6),
                Text('Reason: "${rep.reason}"', style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () {
                        setState(() {
                          _reports.removeAt(index);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Spammer banned and message purged!')),
                        );
                      },
                      child: const Text('Ban & Purge', style: TextStyle(color: Colors.white, fontSize: 11)),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _reports.removeAt(index);
                        });
                      },
                      child: const Text('Dismiss Report', style: TextStyle(fontSize: 11)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBroadcastTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Send Platform-Wide Announcement', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          const Text(
            'This message will be instantly delivered to all active Android, Web, and Desktop Universal Chat clients.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _broadcastTitleController,
            decoration: InputDecoration(
              labelText: 'Announcement Title',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _broadcastMessageController,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: 'Announcement Content',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _sendBroadcast,
              icon: const Icon(Icons.campaign_rounded),
              label: const Text('Send Global Notification to All Users'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
