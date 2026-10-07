import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../utils/constants.dart';
import '../utils/date_formatter.dart';
import '../widgets/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  final UserModel targetUser;

  const ChatScreen({
    super.key,
    required this.targetUser,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _typingTimer;
  bool _isLocalTyping = false;
  late String _chatId;

  @override
  void initState() {
    super.initState();
    final authProvider = context.read<AuthProvider>();
    final chatProvider = context.read<ChatProvider>();
    final currentUserId = authProvider.currentUser?.uid ?? '';

    _chatId = chatProvider.getChatId(currentUserId, widget.targetUser.uid);

    // Mark messages as seen when entering screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      chatProvider.markMessagesAsSeen(
        chatId: _chatId,
        currentUserId: currentUserId,
        isDevBypass: authProvider.isDevBypass,
      );
    });
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onTextChanged(String text) {
    final authProvider = context.read<AuthProvider>();
    final chatProvider = context.read<ChatProvider>();
    final currentUserId = authProvider.currentUser?.uid ?? '';

    if (text.trim().isNotEmpty && !_isLocalTyping) {
      _isLocalTyping = true;
      chatProvider.setTypingStatus(
        chatId: _chatId,
        userId: currentUserId,
        isTyping: true,
        isDevBypass: authProvider.isDevBypass,
      );
    }

    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(milliseconds: 1500), () {
      if (_isLocalTyping) {
        _isLocalTyping = false;
        chatProvider.setTypingStatus(
          chatId: _chatId,
          userId: currentUserId,
          isTyping: false,
          isDevBypass: authProvider.isDevBypass,
        );
      }
    });
  }

  Future<void> _handleSendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final authProvider = context.read<AuthProvider>();
    final chatProvider = context.read<ChatProvider>();
    final currentUserId = authProvider.currentUser?.uid ?? '';

    _messageController.clear();
    _typingTimer?.cancel();
    _isLocalTyping = false;

    chatProvider.setTypingStatus(
      chatId: _chatId,
      userId: currentUserId,
      isTyping: false,
      isDevBypass: authProvider.isDevBypass,
    );

    await chatProvider.sendMessage(
      chatId: _chatId,
      senderId: currentUserId,
      receiverId: widget.targetUser.uid,
      text: text,
      isDevBypass: authProvider.isDevBypass,
    );

    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final chatProvider = context.watch<ChatProvider>();
    final currentUserId = authProvider.currentUser?.uid ?? '';
    final isDevBypass = authProvider.isDevBypass;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white24,
              child: Text(
                widget.targetUser.name.isNotEmpty
                    ? widget.targetUser.name[0].toUpperCase()
                    : 'U',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.targetUser.name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  // Typing Indicator or Online Status
                  StreamBuilder<bool>(
                    stream: chatProvider.getTypingStream(
                      chatId: _chatId,
                      otherUserId: widget.targetUser.uid,
                      isDevBypass: isDevBypass,
                    ),
                    builder: (context, typingSnap) {
                      final isTyping = typingSnap.data ?? false;
                      if (isTyping) {
                        return const Text(
                          'typing...',
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      }
                      return Text(
                        DateFormatter.formatLastSeen(
                          isOnline: widget.targetUser.isOnline,
                          lastSeen: widget.targetUser.lastSeen,
                        ),
                        style: TextStyle(
                          fontSize: 12,
                          color: widget.targetUser.isOnline
                              ? const Color(0xFFB9F6CA)
                              : Colors.white70,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Container(
        color: isDark
            ? AppColors.darkChatBackground
            : AppColors.lightChatBackground,
        child: Column(
          children: [
            // Messages Stream
            Expanded(
              child: StreamBuilder<List<MessageModel>>(
                stream: chatProvider.getMessagesStream(
                  chatId: _chatId,
                  isDevBypass: isDevBypass,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final messages = snapshot.data ?? [];

                  // Auto mark incoming messages as seen
                  if (messages.isNotEmpty) {
                    final hasUnseen = messages.any(
                      (m) => m.receiverId == currentUserId && !m.isSeen,
                    );
                    if (hasUnseen) {
                      chatProvider.markMessagesAsSeen(
                        chatId: _chatId,
                        currentUserId: currentUserId,
                        isDevBypass: isDevBypass,
                      );
                    }
                  }

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scrollToBottom();
                  });

                  if (messages.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.waving_hand_rounded,
                            size: 48,
                            color: Colors.amber.shade600,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Say hi to ${widget.targetUser.name}!',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Send a message to start the conversation.',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.white38 : Colors.black45,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isMe = message.senderId == currentUserId;

                      bool showDateSep = false;
                      String? dateSepText;
                      if (index == 0) {
                        showDateSep = true;
                        dateSepText = DateFormatter.formatDateSeparator(message.timestamp);
                      } else {
                        final prevMessage = messages[index - 1];
                        final prevDate = DateTime(
                          prevMessage.timestamp.year,
                          prevMessage.timestamp.month,
                          prevMessage.timestamp.day,
                        );
                        final curDate = DateTime(
                          message.timestamp.year,
                          message.timestamp.month,
                          message.timestamp.day,
                        );
                        if (prevDate != curDate) {
                          showDateSep = true;
                          dateSepText = DateFormatter.formatDateSeparator(message.timestamp);
                        }
                      }

                      return MessageBubble(
                        message: message,
                        isMe: isMe,
                        showDateSeparator: showDateSep,
                        dateSeparatorText: dateSepText,
                      );
                    },
                  );
                },
              ),
            ),

            // Message Input Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              color: isDark ? AppColors.darkSurface : Colors.white,
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF26353D)
                              : const Color(0xFFF0F2F5),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: TextField(
                          controller: _messageController,
                          onChanged: _onTextChanged,
                          textCapitalization: TextCapitalization.sentences,
                          minLines: 1,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            hintText: 'Type a message...',
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                        onPressed: _handleSendMessage,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
