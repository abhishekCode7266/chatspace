import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Community & Announcement Group Screen
class CommunityScreen extends StatefulWidget {
  final String communityName;
  final String communityDescription;

  const CommunityScreen({
    super.key,
    this.communityName = '🌐 Universal Global Developers & Innovators',
    this.communityDescription = 'Official community for Universal Chat creators, mobile engineers, and AI pioneers. Announcements, releases, and security updates.',
  });

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  bool _isMember = true;
  final List<Map<String, String>> _announcements = [
    {
      'title': '🚀 Universal Chat v1.4.0 Production Release!',
      'body': 'We have officially deployed Universal Chat v1.4.0 with AI companions, Group video calling grids, Business product catalogs, and zero-knowledge E2EE.',
      'time': 'Today at 10:30 AM',
      'author': 'Admin (SuperDev)',
    },
    {
      'title': '🛡️ Security & Privacy Whitepaper Released',
      'body': 'All conversations are secured with client-side AES-256 GCM encryption and 60-digit safety codes. Download the architecture PDF in the Documents section.',
      'time': 'Yesterday at 03:15 PM',
      'author': 'Security Team',
    },
  ];

  final List<Map<String, String>> _subGroups = [
    {'name': '🤖 Universal AI & Flutter Devs', 'members': '1,420 members'},
    {'name': '💡 Tech Innovators & Creators', 'members': '890 members'},
    {'name': '🔒 CyberSecurity & E2EE Watchers', 'members': '2,310 members'},
  ];

  void _copyInviteLink() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🔗 Invite Link copied: https://universalchat.app/c/global-devs-99'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Announcements', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            tooltip: 'Share Invite Link',
            onPressed: _copyInviteLink,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Community Profile Card
            Center(
              child: Column(
                children: [
                  Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.aiPurple],
                      ),
                      boxShadow: [
                        BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 12),
                      ],
                    ),
                    child: const Center(
                      child: Text('🌐', style: TextStyle(fontSize: 42)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.communityName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Official Verified Community • 4,620 Members',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.communityDescription,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: isDark ? Colors.white70 : Colors.black87),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _copyInviteLink,
                        icon: const Icon(Icons.link_rounded),
                        label: const Text('Invite Link'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton(
                        onPressed: () {
                          setState(() => _isMember = !_isMember);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(_isMember ? 'Joined Community!' : 'Left Community')),
                          );
                        },
                        child: Text(_isMember ? 'Joined ✓' : 'Join Community'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Text('📢 Announcements (Admin Only)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),

            ..._announcements.map((a) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              a['title']!,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('Broadcast', style: TextStyle(color: AppColors.primaryLight, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(a['body']!, style: const TextStyle(fontSize: 13, height: 1.35)),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('By ${a['author']}', style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                          Text(a['time']!, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 20),
            const Text('👥 Sub-Groups in this Community', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),

            ..._subGroups.map((g) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF1E293B),
                    child: Icon(Icons.group_rounded, color: AppColors.primaryLight),
                  ),
                  title: Text(g['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Text(g['members']!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Opening ${g['name']}...')),
                    );
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
