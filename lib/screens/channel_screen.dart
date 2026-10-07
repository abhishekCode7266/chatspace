import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/channel_model.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../utils/constants.dart';
import '../utils/date_formatter.dart';

class ChannelScreen extends StatelessWidget {
  final ChannelModel channel;

  const ChannelScreen({
    super.key,
    required this.channel,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final chatProvider = context.watch<ChatProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(channel.avatar, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          channel.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (channel.isVerified) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.verified_rounded, color: Colors.white, size: 16),
                      ],
                    ],
                  ),
                  Text(
                    '${channel.followersCount} followers • ${channel.category}',
                    style: const TextStyle(fontSize: 11, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              channel.isFollowing ? Icons.notifications_active_rounded : Icons.notifications_none_rounded,
            ),
            tooltip: channel.isFollowing ? 'Following' : 'Follow',
            onPressed: () {
              chatProvider.toggleChannelFollow(
                channel.channelId,
                isDevBypass: authProvider.isDevBypass,
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Channel Info Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1F2C34) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      channel.handle,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: channel.isFollowing ? Colors.grey.shade400 : AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      onPressed: () {
                        chatProvider.toggleChannelFollow(
                          channel.channelId,
                          isDevBypass: authProvider.isDevBypass,
                        );
                      },
                      child: Text(channel.isFollowing ? 'Following' : 'Follow'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  channel.description,
                  style: TextStyle(
                    fontSize: 13.5,
                    color: isDark ? Colors.white70 : Colors.black87,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // News Updates Section
          Text(
            'Latest Broadcast Updates',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 10),

          // Update Card 1
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            color: isDark ? const Color(0xFF182229) : Colors.white,
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.newspaper_rounded, size: 18, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        DateFormatter.formatMessageTime(channel.timestamp),
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                      ),
                      const Spacer(),
                      const Icon(Icons.share_rounded, size: 18, color: Colors.grey),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    channel.latestUpdate,
                    style: const TextStyle(fontSize: 15, height: 1.4, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.visibility_rounded, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '${(channel.followersCount * 0.72).toInt()} views',
                        style: const TextStyle(fontSize: 11.5, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
