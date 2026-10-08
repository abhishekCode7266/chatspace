import 'package:flutter/material.dart';
import '../models/message_model.dart';
import '../utils/constants.dart';
import '../utils/date_formatter.dart';

/// Starred & Bookmarked Messages Screen
class StarredMessagesScreen extends StatefulWidget {
  const StarredMessagesScreen({super.key});

  @override
  State<StarredMessagesScreen> createState() => _StarredMessagesScreenState();
}

class _StarredMessagesScreenState extends State<StarredMessagesScreen> {
  final List<MessageModel> _starredMessages = [
    MessageModel(
      messageId: 'star_01',
      senderId: 'user_alice_01',
      receiverId: 'dev_user_universal_99',
      senderName: 'Alice Johnson',
      text: 'Here is the project architecture roadmap for Universal Chat App v1.4.0! 🚀',
      timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      isSeen: true,
      isStarred: true,
    ),
    MessageModel(
      messageId: 'star_02',
      senderId: 'user_charlie_03',
      receiverId: 'group_flutter_devs_01',
      senderName: 'Charlie Dev',
      text: 'v1.4.0 Google Play Store release build is verified with 0 lint errors and 100% test pass rate! 🔒',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isSeen: true,
      isStarred: true,
    ),
    MessageModel(
      messageId: 'star_03',
      senderId: 'user_diana_04',
      receiverId: 'dev_user_universal_99',
      senderName: 'Diana Prince',
      text: 'Universal AI Assistant can summarize 1,000+ messages in less than 2 seconds.',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      isSeen: true,
      isStarred: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Starred Messages', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: _starredMessages.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.star_border_rounded, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('No starred messages yet', style: TextStyle(fontSize: 16, color: Colors.grey)),
                  SizedBox(height: 4),
                  Text('Long press any message to star it for easy access', style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _starredMessages.length,
              itemBuilder: (context, index) {
                final msg = _starredMessages[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with sender name and timestamp
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 14,
                                  backgroundColor: AppColors.primary.withOpacity(0.2),
                                  child: Text(
                                    msg.senderName?.isNotEmpty == true ? msg.senderName![0] : 'U',
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  msg.senderName ?? 'User',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  DateFormatter.formatTimestamp(msg.timestamp),
                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Message Text
                        Text(
                          msg.text,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white : Colors.black87,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Action Bar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  _starredMessages.removeAt(index);
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Message unstarred')),
                                );
                              },
                              icon: const Icon(Icons.star_border_rounded, size: 16),
                              label: const Text('Unstar', style: TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
