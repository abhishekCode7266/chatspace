import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/chat_model.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../utils/constants.dart';
import '../utils/date_formatter.dart';

class ChatTile extends StatelessWidget {
  final ChatModel chat;
  final VoidCallback onTap;

  const ChatTile({
    super.key,
    required this.chat,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final chatProvider = context.read<ChatProvider>();
    final currentUserId = authProvider.currentUser?.uid ?? '';
    final isDevBypass = authProvider.isDevBypass;
    final otherUserId = chat.getOtherUserId(currentUserId);
    final unreadCount = chat.getUnreadCount(currentUserId);

    if (chat.isGroup) {
      final name = chat.groupName ?? 'Group Chat';
      return ListTile(
        onTap: onTap,
        onLongPress: () {
          chatProvider.toggleChatFavorite(chat.chatId, isDevBypass: isDevBypass);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(chat.isFavorite ? 'Removed from Favorites' : 'Added to Favorites ⭐'),
              duration: const Duration(seconds: 1),
            ),
          );
        },
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: const Color(0xFF007AFF).withOpacity(0.18),
              child: const Icon(
                Icons.groups_rounded,
                color: Color(0xFF007AFF),
                size: 28,
              ),
            ),
            if (chat.isFavorite)
              const Positioned(
                bottom: 0,
                right: 0,
                child: Icon(
                  Icons.star_rounded,
                  color: Colors.amber,
                  size: 16,
                ),
              ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
              decoration: BoxDecoration(
                color: const Color(0xFF007AFF).withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'GROUP',
                style: TextStyle(
                  color: Color(0xFF007AFF),
                  fontSize: 9.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            chat.lastMessage.isNotEmpty ? chat.lastMessage : 'Tap to open group',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: unreadCount > 0
                  ? Theme.of(context).colorScheme.onSurface
                  : Colors.grey.shade600,
              fontWeight: unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              DateFormatter.formatChatListTime(chat.lastMessageTime),
              style: TextStyle(
                fontSize: 12,
                color: unreadCount > 0 ? AppColors.primary : Colors.grey,
                fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 6),
            if (unreadCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  unreadCount > 99 ? '99+' : unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else
              const SizedBox(height: 18),
          ],
        ),
      );
    }

    return FutureBuilder<UserModel?>(
      future: chatProvider.getUserById(otherUserId, isDevBypass),
      builder: (context, snapshot) {
        final otherUser = snapshot.data;
        final name = otherUser?.name ?? 'User';
        final isOnline = otherUser?.isOnline ?? false;

        return ListTile(
          onTap: onTap,
          onLongPress: () {
            chatProvider.toggleChatFavorite(chat.chatId, isDevBypass: isDevBypass);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(chat.isFavorite ? 'Removed from Favorites' : 'Added to Favorites ⭐'),
                duration: const Duration(seconds: 1),
              ),
            );
          },
          leading: Stack(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.primary.withOpacity(0.15),
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              if (isOnline)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColors.online,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        width: 2.5,
                      ),
                    ),
                  ),
                ),
              if (chat.isFavorite)
                const Positioned(
                  top: 0,
                  left: 0,
                  child: Icon(
                    Icons.star_rounded,
                    color: Colors.amber,
                    size: 16,
                  ),
                ),
            ],
          ),
          title: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.w600,
              fontSize: 16,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              chat.lastMessage.isNotEmpty ? chat.lastMessage : 'Tap to chat',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: unreadCount > 0
                  ? Theme.of(context).colorScheme.onSurface
                  : Colors.grey.shade600,
                fontWeight: unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                DateFormatter.formatChatListTime(chat.lastMessageTime),
                style: TextStyle(
                  fontSize: 12,
                  color: unreadCount > 0 ? AppColors.primary : Colors.grey,
                  fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              const SizedBox(height: 6),
              if (unreadCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    unreadCount > 99 ? '99+' : unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else
                const SizedBox(height: 18),
            ],
          ),
        );
      },
    );
  }
}
