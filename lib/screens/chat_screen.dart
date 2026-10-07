import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';
import '../models/call_model.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../services/encryption_service.dart';
import '../services/security_service.dart';
import '../utils/constants.dart';
import '../utils/date_formatter.dart';
import '../widgets/message_bubble.dart';
import 'call_screen.dart';

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
  bool _showEmojiBar = false;
  bool _isVoiceRecording = false;

  final List<String> _quickEmojis = [
    '👍', '❤️', '😂', '🔥', '👏', '🙏', '😊', '🎉', '💯', '🚀', '😍', '😎'
  ];

  @override
  void initState() {
    super.initState();
    final authProvider = context.read<AuthProvider>();
    final chatProvider = context.read<ChatProvider>();
    final currentUserId = authProvider.currentUser?.uid ?? '';

    _chatId = chatProvider.getChatId(currentUserId, widget.targetUser.uid);

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
    setState(() {}); // Updates between Send button and Mic button

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

  Future<void> _handleSendMessage({String? customText}) async {
    final text = (customText ?? _messageController.text).trim();
    if (text.isEmpty) return;

    final authProvider = context.read<AuthProvider>();
    final chatProvider = context.read<ChatProvider>();
    final currentUserId = authProvider.currentUser?.uid ?? '';

    if (SecurityService.instance.isUserBlocked(widget.targetUser.uid)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot send message: Contact is blocked.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    _messageController.clear();
    _typingTimer?.cancel();
    _isLocalTyping = false;
    setState(() {});

    chatProvider.setTypingStatus(
      chatId: _chatId,
      userId: currentUserId,
      isTyping: false,
      isDevBypass: authProvider.isDevBypass,
    );

    // E2EE encrypted send
    await chatProvider.sendMessage(
      chatId: _chatId,
      senderId: currentUserId,
      receiverId: widget.targetUser.uid,
      text: text,
      isDevBypass: authProvider.isDevBypass,
    );

    _scrollToBottom();
  }

  void _simulateVoiceNote() {
    setState(() {
      _isVoiceRecording = true;
    });

    Timer(const Duration(milliseconds: 1200), () async {
      if (!mounted) return;
      setState(() {
        _isVoiceRecording = false;
      });

      final authProvider = context.read<AuthProvider>();
      final chatProvider = context.read<ChatProvider>();
      final currentUserId = authProvider.currentUser?.uid ?? '';

      await chatProvider.sendMessage(
        chatId: _chatId,
        senderId: currentUserId,
        receiverId: widget.targetUser.uid,
        text: '🎤 Voice message (0:05)',
        messageType: 'audio',
        audioDuration: '0:05',
        isDevBypass: authProvider.isDevBypass,
      );
      _scrollToBottom();
    });
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

  void _startVideoCall() async {
    final authProvider = context.read<AuthProvider>();
    final chatProvider = context.read<ChatProvider>();
    final currentUserId = authProvider.currentUser?.uid ?? '';

    final duration = await Navigator.push<int>(
      context,
      MaterialPageRoute(
        builder: (_) => CallScreen(
          targetUser: widget.targetUser,
          isVideoCall: true,
        ),
      ),
    );

    final dur = duration ?? 0;
    // Record call log
    await chatProvider.addCallRecord(
      CallModel(
        callId: 'call_${DateTime.now().millisecondsSinceEpoch}',
        callerId: currentUserId,
        receiverId: widget.targetUser.uid,
        callerName: widget.targetUser.name,
        timestamp: DateTime.now(),
        durationSeconds: dur,
        isVideo: true,
        isMissed: dur == 0,
        isOutgoing: true,
      ),
      isDevBypass: authProvider.isDevBypass,
    );

    if (dur > 0) {
      _handleSendMessage(
        customText: '📹 Video call ended (${(dur ~/ 60)}m ${(dur % 60)}s)',
      );
    }
  }

  void _startVoiceCall() async {
    final authProvider = context.read<AuthProvider>();
    final chatProvider = context.read<ChatProvider>();
    final currentUserId = authProvider.currentUser?.uid ?? '';

    final duration = await Navigator.push<int>(
      context,
      MaterialPageRoute(
        builder: (_) => CallScreen(
          targetUser: widget.targetUser,
          isVideoCall: false,
        ),
      ),
    );

    final dur = duration ?? 0;
    // Record call log
    await chatProvider.addCallRecord(
      CallModel(
        callId: 'call_${DateTime.now().millisecondsSinceEpoch}',
        callerId: currentUserId,
        receiverId: widget.targetUser.uid,
        callerName: widget.targetUser.name,
        timestamp: DateTime.now(),
        durationSeconds: dur,
        isVideo: false,
        isMissed: dur == 0,
        isOutgoing: true,
      ),
      isDevBypass: authProvider.isDevBypass,
    );

    if (dur > 0) {
      _handleSendMessage(
        customText: '📞 Voice call ended (${(dur ~/ 60)}m ${(dur % 60)}s)',
      );
    }
  }

  void _showAttachmentsBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1F2C34) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildAttachmentItem(
                    icon: Icons.insert_drive_file_rounded,
                    label: 'Document',
                    color: const Color(0xFF7F66FF),
                    onTap: () {
                      Navigator.pop(ctx);
                      _handleSendMessage(customText: '📄 Document: Project_Report.pdf (1.2 MB)');
                    },
                  ),
                  _buildAttachmentItem(
                    icon: Icons.camera_alt_rounded,
                    label: 'Camera',
                    color: const Color(0xFFD33F8D),
                    onTap: () {
                      Navigator.pop(ctx);
                      _handleSendMessage(customText: '📷 Photo sent');
                    },
                  ),
                  _buildAttachmentItem(
                    icon: Icons.image_rounded,
                    label: 'Gallery',
                    color: const Color(0xFFAC44CF),
                    onTap: () {
                      Navigator.pop(ctx);
                      _handleSendMessage(customText: '🖼️ Image attachment');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildAttachmentItem(
                    icon: Icons.headphones_rounded,
                    label: 'Audio',
                    color: const Color(0xFFE56A2B),
                    onTap: () {
                      Navigator.pop(ctx);
                      _handleSendMessage(customText: '🎧 Audio clip (3:12)');
                    },
                  ),
                  _buildAttachmentItem(
                    icon: Icons.location_on_rounded,
                    label: 'Location',
                    color: const Color(0xFF0F9D58),
                    onTap: () {
                      Navigator.pop(ctx);
                      _handleSendMessage(customText: '📍 Live location shared');
                    },
                  ),
                  _buildAttachmentItem(
                    icon: Icons.person_rounded,
                    label: 'Contact',
                    color: const Color(0xFF009688),
                    onTap: () {
                      Navigator.pop(ctx);
                      _handleSendMessage(customText: '👤 Contact card shared');
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAttachmentItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: color,
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  void _showVerifyEncryptionDialog() {
    final authProvider = context.read<AuthProvider>();
    final currentUserId = authProvider.currentUser?.uid ?? '';
    final fingerprint = EncryptionService.generateSecurityFingerprint(
      currentUserId,
      widget.targetUser.uid,
    );

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.security_rounded, color: AppColors.primary),
              SizedBox(width: 10),
              Text('Verify Security Code'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Messages and calls in this conversation are protected with end-to-end encryption. Compare this 60-digit number with the other participant to verify security.',
                style: TextStyle(fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  fingerprint,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _toggleBlockContact() {
    final security = SecurityService.instance;
    final isBlocked = security.isUserBlocked(widget.targetUser.uid);

    if (isBlocked) {
      security.unblockUser(widget.targetUser.uid);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.targetUser.name} has been unblocked.')),
      );
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Block ${widget.targetUser.name}?'),
          content: const Text(
            'Blocked contacts will no longer be able to call you or send you messages.',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () {
                Navigator.pop(ctx);
                security.blockUser(widget.targetUser.uid);
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${widget.targetUser.name} is now blocked.')),
                );
              },
              child: const Text('Block'),
            ),
          ],
        ),
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
    final hasText = _messageController.text.trim().isNotEmpty;
    final isBlocked = SecurityService.instance.isUserBlocked(widget.targetUser.uid);

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
        actions: [
          // WhatsApp Video Call Button
          IconButton(
            icon: const Icon(Icons.videocam_rounded),
            tooltip: 'Video Call',
            onPressed: _startVideoCall,
          ),
          // WhatsApp Voice Call Button
          IconButton(
            icon: const Icon(Icons.call_rounded),
            tooltip: 'Voice Call',
            onPressed: _startVoiceCall,
          ),
          // WhatsApp More Options Menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (val) {
              if (val == 'verify') {
                _showVerifyEncryptionDialog();
              } else if (val == 'block') {
                _toggleBlockContact();
              } else if (val == 'clear') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Chat history cleared.')),
                );
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'verify',
                child: Row(
                  children: [
                    Icon(Icons.verified_user_rounded, color: AppColors.primary, size: 20),
                    SizedBox(width: 10),
                    Text('Encryption Security Code'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'block',
                child: Row(
                  children: [
                    Icon(
                      isBlocked ? Icons.check_circle_outline : Icons.block_rounded,
                      color: Colors.redAccent,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(isBlocked ? 'Unblock Contact' : 'Block Contact'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline_rounded, size: 20),
                    SizedBox(width: 10),
                    Text('Clear Chat'),
                  ],
                ),
              ),
            ],
          ),
        ],
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

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    itemCount: messages.length + 1, // +1 for WhatsApp E2EE banner
                    itemBuilder: (context, index) {
                      // WhatsApp End-to-End Encryption Banner at top
                      if (index == 0) {
                        return GestureDetector(
                          onTap: _showVerifyEncryptionDialog,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF182229)
                                  : const Color(0xFFFFF3CD),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isDark ? Colors.white12 : const Color(0xFFFFEEBA),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.lock_rounded,
                                  size: 16,
                                  color: Color(0xFF856404),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Messages and calls are end-to-end encrypted. No one outside of this chat, not even WhatsChat, can read or listen to them. Tap to verify.',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      color: isDark ? Colors.amber.shade200 : const Color(0xFF856404),
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      final msgIndex = index - 1;
                      final message = messages[msgIndex];
                      final isMe = message.senderId == currentUserId;

                      bool showDateSep = false;
                      String? dateSepText;
                      if (msgIndex == 0) {
                        showDateSep = true;
                        dateSepText = DateFormatter.formatDateSeparator(message.timestamp);
                      } else {
                        final prevMessage = messages[msgIndex - 1];
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
                        onReactionSelected: (emoji) {
                          chatProvider.toggleReaction(
                            chatId: _chatId,
                            messageId: message.messageId,
                            reaction: emoji,
                            isDevBypass: isDevBypass,
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),

            // Quick Emoji Bar (When emoji button is toggled)
            if (_showEmojiBar)
              Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                color: isDark ? const Color(0xFF1F2C34) : Colors.white,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _quickEmojis.length,
                  itemBuilder: (context, i) {
                    final emoji = _quickEmojis[i];
                    return InkWell(
                      onTap: () {
                        _messageController.text += emoji;
                        _onTextChanged(_messageController.text);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        child: Text(emoji, style: const TextStyle(fontSize: 22)),
                      ),
                    );
                  },
                ),
              ),

            // Blocked contact warning banner
            if (isBlocked)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: Colors.red.shade100,
                child: Text(
                  'You blocked this contact. Unblock to send messages.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red.shade900, fontSize: 13, fontWeight: FontWeight.bold),
                ),
              )
            else
              // WhatsApp Chat Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      // Rounded WhatsApp Input Pill
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF26353D)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Emoji Toggle Button
                              IconButton(
                                icon: Icon(
                                  _showEmojiBar
                                      ? Icons.keyboard_rounded
                                      : Icons.emoji_emotions_outlined,
                                  color: Colors.grey.shade600,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _showEmojiBar = !_showEmojiBar;
                                  });
                                },
                              ),
                              // Message Text Field
                              Expanded(
                                child: TextField(
                                  controller: _messageController,
                                  onChanged: _onTextChanged,
                                  textCapitalization: TextCapitalization.sentences,
                                  minLines: 1,
                                  maxLines: 5,
                                  decoration: InputDecoration(
                                    hintText: _isVoiceRecording
                                        ? 'Recording voice note...'
                                        : 'Message',
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                                  ),
                                ),
                              ),
                              // Attachment Clip Button
                              IconButton(
                                icon: Transform.rotate(
                                  angle: -0.8,
                                  child: Icon(Icons.attach_file_rounded, color: Colors.grey.shade600),
                                ),
                                onPressed: _showAttachmentsBottomSheet,
                              ),
                              // Camera Button (if not typing)
                              if (!hasText)
                                IconButton(
                                  icon: Icon(Icons.camera_alt_rounded, color: Colors.grey.shade600),
                                  onPressed: () {
                                    _handleSendMessage(customText: '📷 Photo');
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Floating Circular WhatsApp Action Button (Mic or Send)
                      GestureDetector(
                        onTap: hasText ? () => _handleSendMessage() : _simulateVoiceNote,
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            hasText ? Icons.send_rounded : Icons.mic_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
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
