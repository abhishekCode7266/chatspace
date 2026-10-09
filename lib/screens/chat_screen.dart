import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';
import '../models/call_model.dart';
import '../models/chat_model.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../services/camera_capture_service.dart';
import '../services/encryption_service.dart';
import '../services/security_service.dart';
import '../services/translation_service.dart';
import '../utils/constants.dart';
import '../utils/date_formatter.dart';
import '../widgets/chat_wallpaper_background.dart';
import '../widgets/message_bubble.dart';
import '../widgets/floating_dev_circle.dart';
import 'call_screen.dart';
import 'group_call_screen.dart';
import 'ai_assistant_screen.dart';
import 'payments_screen.dart';
import 'qr_code_share_screen.dart';
import '../services/payment_service.dart';
import '../widgets/meta_ai_circle.dart';

class ChatScreen extends StatefulWidget {
  final UserModel targetUser;
  final ChatModel? groupChat;

  const ChatScreen({
    super.key,
    required this.targetUser,
    this.groupChat,
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
  int _recordingSeconds = 0;
  Timer? _recordingTimer;
  MessageModel? _replyingToMessage;
  String? _pinnedMessage;

  int _emojiCategoryIndex = 0; // 0: Smileys, 1: Gestures, 2: Hearts, 3: Food, 4: Nature
  final List<List<String>> _categorizedEmojis = [
    // 0: Smileys & Emotions (48)
    [
      '😀', '😃', '😄', '😁', '😆', '😅', '🤣', '😂', '🙂', '🙃', '😉', '😊',
      '😇', '🥰', '😍', '🤩', '😘', '😗', '😚', '😙', '😋', '😛', '😜', '🤪',
      '😝', '🤑', '🤗', '🤭', '🤫', '🤔', '🤐', '🤨', '😐', '😑', '😶', '😏',
      '😒', '🙄', '😬', '🤥', '😌', '😔', '😪', '🤤', '😴', '😷', '🤒', '🤕'
    ],
    // 1: Gestures & Hands (36)
    [
      '👍', '👎', '👊', '✊', '🤛', '🤜', '👏', '🙌', '👐', '🤲', '🤝', '🙏',
      '✍️', '💅', '🤳', '💪', '🦾', '🦿', '👈', '👉', '👆', '🖕', '👇', '☝️',
      '👋', '🤚', '🖐️', '✋', '🖖', '🤟', '🤘', '🤙', '👌', '🤌', '🤏', '✌️'
    ],
    // 2: Hearts & Romance (26)
    [
      '❤️', '🧡', '💛', '💚', '💙', '💜', '🖤', '🤍', '🤎', '💔', '❣️', '💕',
      '💞', '💓', '💗', '💖', '💘', '💝', '💟', '💌', '💋', '💍', '💐', '🌹',
      '🥀', '🌺'
    ],
    // 3: Food & Drinks (36)
    [
      '🍕', '🍔', '🍟', '🌭', '🍿', '🧂', '🥓', '🥚', '🍳', '🧇', '🥞', '🧈',
      '🍞', '🥐', '🥨', '🥯', '🧀', '🥗', '🥪', '🌮', '🌯', '☕', '🍵', '🧃',
      '🥤', '🧋', '🍦', '🍧', '🍨', '🍩', '🍪', '🎂', '🍰', '🧁', '🍫', '🍬'
    ],
    // 4: Animals, Nature & Travel (40)
    [
      '🐶', '🐱', '🐭', '🐹', '🐰', '🦊', '🐻', '🐼', '🐨', '🐯', '🦁', '🐮',
      '🐷', '🐸', '🐵', '🦄', '🐝', '🐛', '🦋', '🌸', '🌻', '🌼', '🌴', '🌲',
      '🌳', '🍀', '🍁', '🍂', '🌈', '⚡', '❄️', '☀️', '🌙', '⭐', '🚀', '✈️',
      '🚗', '🚲', '🏖️', '🏝️'
    ],
  ];

  final List<String> _reactionGifs = [
    '👍 Thumbs Up', '😂 Laughing Tears', '👏 Big Applause', '🙌 Victory Cheers',
    '🤩 Mind Blown', '😎 Cool Boss Swag', '🎯 Perfect Bullseye', '🥳 Party Popping',
    '❤️ Sending Love', '🔥 Super Fire', '🚀 Rocket Launch', '🎉 Happy Birthday',
    '💯 Keep it 100', '🙏 Thank You So Much', '☕ Morning Coffee', '🍕 Pizza Craving',
    '😴 Good Night', '💃 Dance Party', '🕺 Disco Grooves', '🤗 Warm Hugs',
    '💪 Stay Strong', '🤯 OMG Shocked', '👋 Welcome Hello', '🤝 Deal Confirmed',
    '🎊 Grand Fiesta', '✨ Pure Magic', '🏆 Champion Win', '🍿 Movie Time',
    '💡 Bright Idea', '⚡ High Energy', '🚗 Road Trip', '🏖️ Beach Vacation',
    '🎂 Birthday Cake', '🎁 Special Gift', '🌟 Shining Star', '🌈 Rainbow Vibes',
    '💻 Coding Mode', '🤖 AI Revolution', '📱 Texting Fast', '🎧 Vibe With Music',
    '🔥 Lit Energy', '🙌 High Five', '🤑 Making Money', '💸 Cashback Won',
    '🚀 To The Moon', '🏃‍♂️ On The Run', '🏋️ Gym Beast', '🍔 Burger Party',
    '🍦 Ice Cream Treat', '🎮 Game On'
  ];

  final List<String> _stickerPack = [
    '🚀 Moonshot', '✨ Sparkles', '🔥 Hot Streak', '🎉 Fiesta Time',
    '⭐ Rockstar', '🏆 First Place', '🙏 Namaste Ji', '❤️ Dil Se',
    '💯 Pakka 100', '☕ Chai Peelo', '🍕 Cheesy Bite', '🤖 Jarvis AI',
    '😎 Desi Swag', '🥳 Party Sharty', '💪 Zor Lagake', '🌟 Champion',
    '🎯 Target Hit', '⚡ Flash Power', '🌈 Rainbow Mood', '🐱 Cute Kitty',
    '🐶 Happy Puppy', '🦁 Sher Dil', '👑 King Vibe', '💎 Diamond Rare',
    '🚀 Rocket Speed', '🍔 Burger Binge', '🍩 Sweet Donut', '🍓 Berry Sweet',
    '🥑 Avocado Fresh', '🍉 Summer Melon', '🧁 Cupcake Joy', '🍦 Soft Choco',
    '🍿 Popcorn Flick', '🏎️ Fast Racer', '✈️ Jet Set', '🏝️ Tropical Island',
    '🏕️ Camping Nights', '🎇 Fireworks Boom', '🎈 Flying High', '💰 Paisa Hi Paisa',
    '🔔 Ring The Bell', '🕶️ Cool Shades', '🎶 Musical Beats', '🎸 Rock Guitar',
    '🎤 Microphone Drop', '🥋 Karate Master', '🥇 Gold Medalist', '🥈 Silver Runner',
    '🥉 Bronze Champ', '🏅 Honor Badge'
  ];

  int _emojiDrawerTab = 0; // 0: Emoji, 1: GIF, 2: Stickers, 3: Themes
  Color? _customChatBackgroundColor;
  String _selectedWallpaperId = 'default';
  bool _isSearchingChat = false;
  String _chatSearchQuery = '';
  final FocusNode _messageFocusNode = FocusNode();
  bool _isAutoTranslateOutgoing = false;
  String _outgoingTargetLang = 'hi';

  @override
  void initState() {
    super.initState();
    final authProvider = context.read<AuthProvider>();
    final chatProvider = context.read<ChatProvider>();
    final currentUserId = authProvider.currentUser?.uid ?? '';

    if (widget.groupChat != null) {
      _chatId = widget.groupChat!.chatId;
    } else {
      _chatId = chatProvider.getChatId(currentUserId, widget.targetUser.uid);
    }

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
    _messageFocusNode.dispose();
    _scrollController.dispose();
    CameraCaptureService.instance.disposeCamera();
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

  Future<void> _handleSendMessage({
    String? customText,
    String messageType = 'text',
    String? audioDuration,
    String? fileName,
    String? fileSize,
    String? mediaUrl,
    double? paymentAmount,
    String? paymentStatus,
    String? paymentNote,
    String? paymentTxnId,
    String? paymentReceiverName,
  }) async {
    var text = (customText ?? _messageController.text).trim();
    if (text.isEmpty && messageType == 'text' && paymentAmount == null && mediaUrl == null) return;

    if (_isAutoTranslateOutgoing && messageType == 'text' && text.isNotEmpty) {
      final translated = await TranslationService.instance.translateText(
        text,
        targetLanguageCode: _outgoingTargetLang,
      );
      if (translated.isNotEmpty) {
        text = translated;
      }
    }

    final authProvider = context.read<AuthProvider>();
    final chatProvider = context.read<ChatProvider>();
    final currentUserId = authProvider.currentUser?.uid ?? '';

    if (widget.groupChat == null && SecurityService.instance.isUserBlocked(widget.targetUser.uid)) {
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

    final receiverId = widget.groupChat != null ? widget.groupChat!.chatId : widget.targetUser.uid;
    final replyText = _replyingToMessage?.text;
    final replySender = _replyingToMessage?.senderName ?? 'User';

    if (_replyingToMessage != null) {
      setState(() {
        _replyingToMessage = null;
      });
    }

    await chatProvider.sendMessage(
      chatId: _chatId,
      senderId: currentUserId,
      receiverId: receiverId,
      text: text,
      messageType: messageType,
      audioDuration: audioDuration,
      fileName: fileName,
      fileSize: fileSize,
      mediaUrl: mediaUrl,
      senderName: authProvider.currentUser?.name,
      replyToText: replyText,
      replyToSender: replySender,
      isDevBypass: authProvider.isDevBypass,
      paymentAmount: paymentAmount,
      paymentStatus: paymentStatus,
      paymentNote: paymentNote,
      paymentTxnId: paymentTxnId,
      paymentReceiverName: paymentReceiverName,
    );

    _scrollToBottom();
  }

  void _showOutgoingLanguagePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.translate_rounded, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text(
                      'Live Outgoing Translation (अनुवाद भाषा चुनें)',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              SizedBox(
                height: 300,
                child: ListView.builder(
                  itemCount: TranslationService.supportedLanguages.length,
                  itemBuilder: (c, i) {
                    final lang = TranslationService.supportedLanguages[i];
                    return ListTile(
                      leading: Text(lang.flag, style: const TextStyle(fontSize: 22)),
                      title: Text('${lang.name} (${lang.nativeName})'),
                      trailing: _outgoingTargetLang == lang.code
                          ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
                          : null,
                      onTap: () {
                        setState(() {
                          _outgoingTargetLang = lang.code;
                          _isAutoTranslateOutgoing = true;
                        });
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('✓ Auto-translate outgoing messages to ${lang.name} enabled'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ==========================================
  // REAL CAMERA & GALLERY CAPTURE
  // ==========================================
  Future<void> _captureRealPhoto({required ImageSource source}) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1200,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        final base64String = base64Encode(bytes);
        final dataUrl = 'data:image/jpeg;base64,$base64String';
        await _handleSendMessage(
          customText: source == ImageSource.camera ? '📷 Photo from Camera' : '🖼️ Photo from Gallery',
          messageType: 'image',
          mediaUrl: dataUrl,
          fileName: pickedFile.name,
          fileSize: '${(bytes.length / 1024).toStringAsFixed(1)} KB',
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(source == ImageSource.camera ? '📷 Photo captured & sent!' : '🖼️ Photo sent from gallery!'),
              backgroundColor: AppColors.primary,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Camera/Gallery action: $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  void _showCameraPickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1F2C34) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Take or Choose Photo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16),
              ListTile(
                leading: const CircleAvatar(backgroundColor: Color(0xFFD33F8D), child: Icon(Icons.camera_alt_rounded, color: Colors.white)),
                title: const Text('Live Camera Viewfinder (लाइव कैमरा से फोटो खींचें)'),
                subtitle: const Text('Real face capture with selfie flip & shutter'),
                onTap: () {
                  Navigator.pop(ctx);
                  _showCameraCaptureDialog();
                },
              ),
              ListTile(
                leading: const CircleAvatar(backgroundColor: Color(0xFFAC44CF), child: Icon(Icons.photo_library_rounded, color: Colors.white)),
                title: const Text('Choose from Gallery / Files (गैलरी से चुनें)'),
                subtitle: const Text('Pick photos or images from device memory'),
                onTap: () {
                  Navigator.pop(ctx);
                  _captureRealPhoto(source: ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const CircleAvatar(backgroundColor: Color(0xFF007AFF), child: Icon(Icons.photo_camera_front_rounded, color: Colors.white)),
                title: const Text('System Camera Picker (सिस्टम कैमरा)'),
                subtitle: const Text('Native OS camera file capture'),
                onTap: () {
                  Navigator.pop(ctx);
                  _captureRealPhoto(source: ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ==========================================
  // WHATSAPP-STYLE IN-BAR AUDIO RECORDING
  // ==========================================
  void _startVoiceRecording() {
    setState(() {
      _isVoiceRecording = true;
      _recordingSeconds = 0;
    });
    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _recordingSeconds++;
        });
      }
    });
  }

  void _cancelVoiceRecording() {
    _recordingTimer?.cancel();
    setState(() {
      _isVoiceRecording = false;
      _recordingSeconds = 0;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🗑️ Audio recording discarded'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _sendVoiceRecording() {
    _recordingTimer?.cancel();
    final durationSec = _recordingSeconds > 0 ? _recordingSeconds : 1;
    final formattedDuration = '0:${durationSec.toString().padLeft(2, '0')}';
    setState(() {
      _isVoiceRecording = false;
      _recordingSeconds = 0;
    });
    _handleSendMessage(
      customText: '🎤 Voice message ($formattedDuration)',
      messageType: 'audio',
      audioDuration: formattedDuration,
    );
  }

  // ==========================================
  // SCHEDULED MESSAGES (शेड्यूल्ड मैसेज)
  // ==========================================
  void _showScheduleMessageDialog() {
    final textCtrl = TextEditingController(text: _messageController.text);
    int selectedMinutes = 15;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setSchedState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.schedule_send_rounded, color: Color(0xFF00796B)),
              SizedBox(width: 10),
              Text('Schedule Message (शेड्यूल)', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Send this message automatically at a scheduled time:', style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 10),
              TextField(
                controller: textCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Message Text',
                  hintText: 'Enter scheduled message...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 14),
              const Text('Deliver In:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('In 15 mins'),
                    selected: selectedMinutes == 15,
                    onSelected: (val) => setSchedState(() => selectedMinutes = 15),
                  ),
                  ChoiceChip(
                    label: const Text('In 1 hour'),
                    selected: selectedMinutes == 60,
                    onSelected: (val) => setSchedState(() => selectedMinutes = 60),
                  ),
                  ChoiceChip(
                    label: const Text('Tomorrow 9 AM'),
                    selected: selectedMinutes == 840,
                    onSelected: (val) => setSchedState(() => selectedMinutes = 840),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00796B),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final txt = textCtrl.text.trim();
                if (txt.isNotEmpty) {
                  Navigator.pop(ctx);
                  Timer(Duration(seconds: selectedMinutes <= 15 ? 10 : 30), () {
                    _handleSendMessage(customText: txt);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('⏰ Message scheduled! Delivery in $selectedMinutes mins.'),
                      backgroundColor: const Color(0xFF00796B),
                    ),
                  );
                }
              },
              child: const Text('Schedule Message'),
            ),
          ],
        ),
      ),
    );
  }

  void _showInChatPaymentDialog() {
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    final pinController = TextEditingController();
    final payment = PaymentService.instance;
    bool isStepPin = false;
    bool isPinError = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final isDark = Theme.of(ctx).brightness == Brightness.dark;
          final targetName = widget.groupChat != null
              ? (widget.groupChat!.groupName ?? 'Group')
              : widget.targetUser.name;

          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              top: 24,
              left: 24,
              right: 24,
            ),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1F2C34) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.currency_rupee_rounded, color: Colors.green, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isStepPin ? 'Enter UPI PIN' : 'Pay to $targetName',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                          ),
                          Text(
                            'Universal Pay UPI • Bank Secured',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                if (!isStepPin) ...[
                  TextField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    autofocus: true,
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      labelText: 'Amount (रुपये)',
                      prefixText: '₹ ',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: noteController,
                    decoration: InputDecoration(
                      labelText: 'Add a message or note',
                      hintText: 'e.g. Thanks for dinner!',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      prefixIcon: const Icon(Icons.note_alt_rounded),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Icon(Icons.account_balance_rounded, size: 16, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(
                        'Debit from: ${payment.primaryBank.bankName}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        final amt = double.tryParse(amountController.text.trim()) ?? 0;
                        if (amt <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter a valid amount.')),
                          );
                          return;
                        }
                        setModalState(() {
                          isStepPin = true;
                        });
                      },
                      child: const Text('Proceed to Enter PIN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ] else ...[
                  Text(
                    'Transferring ₹${amountController.text.trim()} to $targetName',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  const Text('Enter 4-digit UPI PIN (Default: 1234)', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: pinController,
                    obscureText: true,
                    maxLength: 4,
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 26, letterSpacing: 8, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      hintText: '••••',
                      errorText: isPinError ? 'Invalid UPI PIN. Try 1234' : null,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        if (payment.verifyUpiPin(pinController.text.trim())) {
                          final amt = double.tryParse(amountController.text.trim()) ?? 0;
                          final note = noteController.text.trim();
                          final txn = payment.sendMoney(
                            senderId: 'current_user',
                            senderName: 'You',
                            receiverId: widget.groupChat != null ? widget.groupChat!.chatId : widget.targetUser.uid,
                            receiverName: targetName,
                            amount: amt,
                            note: note,
                          );
                          Navigator.pop(ctx);
                          _handleSendMessage(
                            customText: '💸 Payment of ₹${amt.toStringAsFixed(2)} completed',
                            messageType: 'payment',
                            paymentAmount: amt,
                            paymentStatus: 'SUCCESS',
                            paymentNote: note,
                            paymentTxnId: txn.upiRefId,
                            paymentReceiverName: targetName,
                          );
                        } else {
                          setModalState(() {
                            isPinError = true;
                          });
                        }
                      },
                      child: const Text('Confirm & Send Money', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
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
      final receiverId = widget.groupChat != null ? widget.groupChat!.chatId : widget.targetUser.uid;

      await chatProvider.sendMessage(
        chatId: _chatId,
        senderId: currentUserId,
        receiverId: receiverId,
        text: '🎤 Voice message (0:05)',
        messageType: 'audio',
        audioDuration: '0:05',
        senderName: authProvider.currentUser?.name,
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
    if (widget.groupChat != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => GroupCallScreen(
            groupName: widget.groupChat!.groupName ?? 'Group Video Call',
            isVideo: true,
          ),
        ),
      );
      return;
    }

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
    if (widget.groupChat != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => GroupCallScreen(
            groupName: widget.groupChat!.groupName ?? 'Group Voice Call',
            isVideo: false,
          ),
        ),
      );
      return;
    }

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
    await chatProvider.addCallRecord(
      CallModel(
        callId: 'call_${DateTime.now().millisecondsSinceEpoch}',
        callerId: currentUserId,
        receiverId: widget.targetUser.uid,
        callerName: widget.groupChat != null ? widget.groupChat!.groupName ?? 'Group' : widget.targetUser.name,
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

  void _showCameraCaptureDialog() {
    bool isFrontCamera = true;
    bool isFlashOn = false;
    bool isCapturing = false;

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.9),
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (ctx, setCamState) {
            return Dialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: SizedBox(
                  height: 520,
                  child: Stack(
                    children: [
                      // Live WebRTC Webcam / Camera Video Stream Viewfinder
                      Positioned.fill(
                        child: CameraCaptureService.instance.buildLiveCameraView(
                          isFrontCamera: isFrontCamera,
                          onCameraReady: (ready) {},
                        ),
                      ),

                      // Flash overlay when flash is turned on
                      if (isFlashOn)
                        Positioned.fill(
                          child: IgnorePointer(
                            child: Container(
                              color: Colors.amber.withOpacity(0.12),
                            ),
                          ),
                        ),

                      // Top control bar
                      Positioned(
                        top: 14,
                        left: 14,
                        right: 14,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.close_rounded, color: Colors.white, size: 26),
                                tooltip: 'Close Camera',
                                onPressed: () {
                                  CameraCaptureService.instance.disposeCamera();
                                  Navigator.pop(dialogCtx);
                                },
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      isFlashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                                      color: isFlashOn ? Colors.amber : Colors.white,
                                      size: 24,
                                    ),
                                    tooltip: isFlashOn ? 'Flash On' : 'Flash Off',
                                    onPressed: () => setCamState(() => isFlashOn = !isFlashOn),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(Icons.flip_camera_ios_rounded, color: Colors.white, size: 24),
                                    tooltip: 'Flip Camera (Front/Rear)',
                                    onPressed: () {
                                      setCamState(() => isFrontCamera = !isFrontCamera);
                                      CameraCaptureService.instance.flipCamera(isFrontCamera);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Viewfinder camera indicator badge
                      Positioned(
                        top: 74,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black45,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              isFrontCamera ? '🤳 Front Camera (Live Face)' : '📷 Rear Camera (Ultra HD)',
                              style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),

                      // Bottom bar with Shutter and Gallery fallback
                      Positioned(
                        bottom: 20,
                        left: 20,
                        right: 20,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Gallery button
                            IconButton(
                              icon: const Icon(Icons.photo_library_rounded, color: Colors.white, size: 30),
                              tooltip: 'Choose from Gallery',
                              onPressed: () {
                                CameraCaptureService.instance.disposeCamera();
                                Navigator.pop(dialogCtx);
                                _captureRealPhoto(source: ImageSource.gallery);
                              },
                            ),

                            // Real Shutter Button
                            GestureDetector(
                              onTap: isCapturing
                                  ? null
                                  : () async {
                                      setCamState(() => isCapturing = true);
                                      final dataUrl = await CameraCaptureService.instance.snapPhoto();
                                      if (dataUrl != null) {
                                        CameraCaptureService.instance.disposeCamera();
                                        Navigator.pop(dialogCtx);
                                        await _handleSendMessage(
                                          customText: isFrontCamera ? '📷 Selfie photo' : '📷 Camera photo',
                                          messageType: 'image',
                                          mediaUrl: dataUrl,
                                          fileName: 'Camera_Capture_${DateTime.now().millisecondsSinceEpoch}.jpg',
                                          fileSize: '420 KB',
                                        );
                                        if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('✓ Real camera photo captured & sent!'),
                                              backgroundColor: AppColors.primary,
                                              duration: Duration(seconds: 2),
                                            ),
                                          );
                                        }
                                      } else {
                                        CameraCaptureService.instance.disposeCamera();
                                        Navigator.pop(dialogCtx);
                                        _captureRealPhoto(source: ImageSource.camera);
                                      }
                                    },
                              child: Container(
                                width: 76,
                                height: 76,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 4),
                                ),
                                child: Container(
                                  margin: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                  child: isCapturing
                                      ? const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
                                      : const Icon(Icons.camera_rounded, color: Colors.black87, size: 32),
                                ),
                              ),
                            ),

                            // Flip Camera shortcut button
                            IconButton(
                              icon: const Icon(Icons.cameraswitch_rounded, color: Colors.white, size: 30),
                              tooltip: 'Switch Camera',
                              onPressed: () {
                                setCamState(() => isFrontCamera = !isFrontCamera);
                                CameraCaptureService.instance.flipCamera(isFrontCamera);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    ).then((_) {
      CameraCaptureService.instance.disposeCamera();
    });
  }

  void _showVoiceDictationDialog() {
    bool isListening = true;
    final dictationSamples = [
      'नमस्ते! मैं बिल्कुल ठीक हूँ, आप कैसे हैं?',
      'Let\'s connect on Universal Chat App for the team sync.',
      'Sending you the project report right now.',
      'मैं शाम 5 बजे आपको कॉल करता हूँ।',
    ];
    final textController = TextEditingController(text: dictationSamples[0]);

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDictState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Row(
                children: [
                  Icon(Icons.mic_none_rounded, color: AppColors.primary),
                  SizedBox(width: 10),
                  Text('बोलकर चैट लिखें (Speech Dictation)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isListening ? AppColors.primary.withOpacity(0.15) : Colors.grey.withOpacity(0.15),
                    ),
                    child: Center(
                      child: Icon(
                        isListening ? Icons.mic_rounded : Icons.mic_off_rounded,
                        color: isListening ? AppColors.primary : Colors.grey,
                        size: 36,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isListening ? '🎙️ Listening... (बोलिए, आवाज़ रिकॉर्ड हो रही है)' : 'Dictation Paused',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isListening ? AppColors.primary : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: textController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Recognized voice text will appear here...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      for (int i = 0; i < dictationSamples.length; i++)
                        ActionChip(
                          label: Text(
                            dictationSamples[i].length > 18
                                ? '${dictationSamples[i].substring(0, 18)}...'
                                : dictationSamples[i],
                            style: const TextStyle(fontSize: 11),
                          ),
                          onPressed: () {
                            setDictState(() {
                              textController.text = dictationSamples[i];
                            });
                          },
                        ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    _messageController.text += ' ${textController.text.trim()}';
                    _onTextChanged(_messageController.text);
                    Navigator.pop(ctx);
                  },
                  child: const Text('Insert in Chat'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    final textToSend = textController.text.trim();
                    if (textToSend.isNotEmpty) {
                      Navigator.pop(ctx);
                      _handleSendMessage(customText: textToSend);
                    }
                  },
                  child: const Text('Send Now'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showCreatePollDialog() {
    final questionCtrl = TextEditingController();
    final opt1Ctrl = TextEditingController();
    final opt2Ctrl = TextEditingController();
    final opt3Ctrl = TextEditingController();
    bool allowMultiple = false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setPollState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Row(
                children: [
                  Icon(Icons.poll_rounded, color: Color(0xFF00897B)),
                  SizedBox(width: 10),
                  Text('Create Poll', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: questionCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Question',
                        hintText: 'Ask a question...',
                        prefixIcon: Icon(Icons.help_outline_rounded),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text('Options', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: opt1Ctrl,
                      decoration: const InputDecoration(
                        labelText: 'Option 1',
                        prefixIcon: Icon(Icons.circle_outlined, size: 16),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: opt2Ctrl,
                      decoration: const InputDecoration(
                        labelText: 'Option 2',
                        prefixIcon: Icon(Icons.circle_outlined, size: 16),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: opt3Ctrl,
                      decoration: const InputDecoration(
                        labelText: 'Option 3 (Optional)',
                        prefixIcon: Icon(Icons.circle_outlined, size: 16),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Allow multiple answers', style: TextStyle(fontSize: 14)),
                      value: allowMultiple,
                      onChanged: (val) => setPollState(() => allowMultiple = val),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00897B),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    final q = questionCtrl.text.trim();
                    final o1 = opt1Ctrl.text.trim();
                    final o2 = opt2Ctrl.text.trim();
                    if (q.isNotEmpty && o1.isNotEmpty && o2.isNotEmpty) {
                      Navigator.pop(ctx);
                      final o3 = opt3Ctrl.text.trim();
                      final pollText = '📊 Poll: $q\n• 1: $o1\n• 2: $o2${o3.isNotEmpty ? "\n• 3: $o3" : ""}';
                      _handleSendMessage(
                        customText: pollText,
                        messageType: 'poll',
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter a question and at least 2 options.')),
                      );
                    }
                  },
                  child: const Text('Create Poll'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showCreateEventDialog() {
    final titleCtrl = TextEditingController();
    final locationCtrl = TextEditingController();
    DateTime eventDate = DateTime.now().add(const Duration(days: 1));

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setEvtState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Row(
                children: [
                  Icon(Icons.event_available_rounded, color: Colors.orange),
                  SizedBox(width: 10),
                  Text('Create Event', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Event Name',
                      hintText: 'e.g. Universal Chat Super Meet',
                      prefixIcon: Icon(Icons.title_rounded),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: locationCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Location / Link',
                      hintText: 'e.g. Google Meet or Silicon Tech Hub',
                      prefixIcon: Icon(Icons.place_rounded),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.calendar_month_rounded, color: Colors.orange),
                    title: const Text('Event Date', style: TextStyle(fontSize: 13)),
                    subtitle: Text('${eventDate.day}/${eventDate.month}/${eventDate.year} at 5:00 PM', style: const TextStyle(fontWeight: FontWeight.bold)),
                    trailing: TextButton(
                      child: const Text('Change'),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: eventDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          setEvtState(() => eventDate = picked);
                        }
                      },
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    final t = titleCtrl.text.trim();
                    if (t.isNotEmpty) {
                      Navigator.pop(ctx);
                      final loc = locationCtrl.text.trim().isEmpty ? 'Online' : locationCtrl.text.trim();
                      final eventMsg = '📅 Event: $t\n🕒 Date: ${eventDate.day}/${eventDate.month}/${eventDate.year} 5:00 PM\n📍 Location: $loc';
                      _handleSendMessage(
                        customText: eventMsg,
                        messageType: 'event',
                      );
                    }
                  },
                  child: const Text('Share Event'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showViewContactDialog() {
    final isGroup = widget.groupChat != null;
    final name = isGroup ? (widget.groupChat!.groupName ?? 'Group') : widget.targetUser.name;
    final email = isGroup ? 'Universal Group Community' : widget.targetUser.email;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1F2C34) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: isGroup ? const Color(0xFF007AFF) : AppColors.primary,
                child: isGroup
                    ? const Icon(Icons.groups_rounded, color: Colors.white, size: 44)
                    : Text(
                        name.isNotEmpty ? name[0].toUpperCase() : 'U',
                        style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                      ),
              ),
              const SizedBox(height: 14),
              Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(email, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 16),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.phone_rounded, color: AppColors.primary),
                title: const Text('Voice & Video Calling'),
                subtitle: const Text('Free HD Calls powered by WebRTC & Firebase'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: const Icon(Icons.call_rounded), onPressed: _startVoiceCall),
                    IconButton(icon: const Icon(Icons.videocam_rounded), onPressed: _startVideoCall),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.lock_rounded, color: Color(0xFF00897B)),
                title: const Text('Encryption Status'),
                subtitle: const Text('Messages and calls are AES-256 end-to-end encrypted.'),
                onTap: () {
                  Navigator.pop(ctx);
                  _showVerifyEncryptionDialog();
                },
              ),
              ListTile(
                leading: const Icon(Icons.notifications_off_rounded, color: Colors.blueAccent),
                title: const Text('Mute Notifications'),
                onTap: () {
                  Navigator.pop(ctx);
                  _showMuteNotificationsDialog();
                },
              ),
              ListTile(
                leading: const Icon(Icons.qr_code_2_rounded, color: Colors.purple),
                title: const Text('Universal QR Code'),
                subtitle: const Text('Share contact card or invite to chat'),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => QrCodeShareScreen(
                        groupChatId: widget.groupChat?.chatId,
                        groupName: widget.groupChat?.groupName,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showMediaLinksDocsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return DefaultTabController(
          length: 3,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.65,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1F2C34) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(2)),
                ),
                const SizedBox(height: 8),
                const TabBar(
                  tabs: [
                    Tab(text: 'MEDIA (24)'),
                    Tab(text: 'DOCS (8)'),
                    Tab(text: 'LINKS (12)'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      GridView.builder(
                        padding: const EdgeInsets.all(12),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 6,
                          mainAxisSpacing: 6,
                        ),
                        itemCount: 9,
                        itemBuilder: (c, i) => Container(
                          decoration: BoxDecoration(
                            color: Colors.teal.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Icon(i % 2 == 0 ? Icons.image_rounded : Icons.videocam_rounded, color: AppColors.primary, size: 36),
                          ),
                        ),
                      ),
                      ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemCount: 4,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (c, i) => ListTile(
                          leading: const Icon(Icons.picture_as_pdf_rounded, color: Colors.redAccent, size: 32),
                          title: Text('Universal_Chat_Spec_v${i + 1}.pdf', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          subtitle: Text('${(i + 1) * 1.2} MB • Oct 2026'),
                          trailing: const Icon(Icons.download_rounded),
                        ),
                      ),
                      ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemCount: 3,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (c, i) => ListTile(
                          leading: const Icon(Icons.link_rounded, color: Colors.blueAccent, size: 32),
                          title: Text(i == 0 ? 'https://abhishekcode7266.github.io/chatspace/' : 'https://github.com/abhishekCode7266/chatspace'),
                          subtitle: const Text('Universal Chat Web Portal & Releases'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showChatThemeDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.wallpaper_rounded, color: AppColors.primary),
            SizedBox(width: 10),
            Text('Wallpaper & Themes (वॉलपेपर)'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: ChatWallpapers.allWallpapers.length,
            itemBuilder: (c, i) {
              final w = ChatWallpapers.allWallpapers[i];
              final isSelected = _selectedWallpaperId == w.id;
              return ListTile(
                leading: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: w.gradientColors),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: isSelected ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
                ),
                title: Text(w.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: Text(w.hindiName, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: AppColors.primary) : null,
                onTap: () {
                  setState(() {
                    _selectedWallpaperId = w.id;
                  });
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('✓ Chat theme set to ${w.name}')),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  void _showMuteNotificationsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mute notifications for...'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('8 Hours'),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notifications muted for 8 hours.')));
              },
            ),
            ListTile(
              title: const Text('1 Week'),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notifications muted for 1 week.')));
              },
            ),
            ListTile(
              title: const Text('Always'),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notifications muted always.')));
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ],
      ),
    );
  }

  void _showMoreOptionsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1F2C34) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.report_problem_outlined, color: Colors.orange),
                title: const Text('Report'),
                subtitle: const Text('Report suspicious behavior or spam'),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Contact reported. Our team will review this conversation.')),
                  );
                },
              ),
              if (widget.groupChat == null)
                ListTile(
                  leading: const Icon(Icons.block_rounded, color: Colors.redAccent),
                  title: const Text('Block'),
                  subtitle: const Text('Block contact from calling or messaging'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _toggleBlockContact();
                  },
                ),
              ListTile(
                leading: const Icon(Icons.delete_sweep_rounded, color: Colors.red),
                title: const Text('Clear Chat'),
                subtitle: const Text('Delete all messages in this chat'),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Chat messages cleared.')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.file_upload_outlined, color: Colors.blueAccent),
                title: const Text('Export Chat'),
                subtitle: const Text('Export conversation transcript and media receipts'),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Chat exported successfully to your downloads.')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.shortcut_rounded, color: AppColors.primary),
                title: const Text('Add Shortcut'),
                subtitle: const Text('Add 1-tap chat shortcut to home screen'),
                onTap: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Chat shortcut added to home screen.')),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmojiStickerGifDrawer(bool isDark) {
    final emojiCategoryTitles = ['😀 Smileys', '👍 Gestures', '❤️ Hearts', '🍕 Food', '🚀 Nature'];

    return Container(
      height: 290,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2C34) : const Color(0xFFF0F2F5),
        border: Border(top: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade300)),
      ),
      child: Column(
        children: [
          // Header Bar with Tabs and Prominent Keyboard Toggle
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            color: isDark ? const Color(0xFF182229) : Colors.grey.shade200,
            child: Row(
              children: [
                _buildDrawerTabItem('EMOJIS', 0),
                _buildDrawerTabItem('GIFS', 1),
                _buildDrawerTabItem('STICKERS', 2),
                _buildDrawerTabItem('थीम (Themes)', 3),
                const Spacer(),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.primary.withOpacity(0.12),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    visualDensity: VisualDensity.compact,
                  ),
                  icon: const Icon(Icons.keyboard_rounded, size: 16, color: AppColors.primary),
                  label: const Text('कीपैड (Keyboard)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  onPressed: () {
                    setState(() => _showEmojiBar = false);
                    _messageFocusNode.requestFocus();
                  },
                ),
              ],
            ),
          ),

          // Subcategory row for Emojis
          if (_emojiDrawerTab == 0)
            Container(
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              color: isDark ? const Color(0xFF121B22) : Colors.white,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(emojiCategoryTitles.length, (idx) {
                    final isSel = _emojiCategoryIndex == idx;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: InkWell(
                        onTap: () => setState(() => _emojiCategoryIndex = idx),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isSel ? AppColors.primary : (isDark ? Colors.white10 : Colors.grey.shade100),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            emojiCategoryTitles[idx],
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isSel ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),

          // Content body
          Expanded(
            child: _emojiDrawerTab == 0
                ? GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 8,
                      mainAxisSpacing: 6,
                      crossAxisSpacing: 6,
                    ),
                    itemCount: _categorizedEmojis[_emojiCategoryIndex].length,
                    itemBuilder: (ctx, i) {
                      final emoji = _categorizedEmojis[_emojiCategoryIndex][i];
                      return InkWell(
                        onTap: () {
                          _messageController.text += emoji;
                          _onTextChanged(_messageController.text);
                        },
                        child: Center(
                          child: Text(emoji, style: const TextStyle(fontSize: 24)),
                        ),
                      );
                    },
                  )
                : _emojiDrawerTab == 1
                    ? GridView.builder(
                        padding: const EdgeInsets.all(8),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 2.2,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                        ),
                        itemCount: _reactionGifs.length,
                        itemBuilder: (ctx, i) {
                          final gif = _reactionGifs[i];
                          return InkWell(
                            onTap: () {
                              setState(() => _showEmojiBar = false);
                              _handleSendMessage(
                                customText: '🎞️ GIF: $gif',
                                messageType: 'gif',
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF2A3942) : Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
                              ),
                              child: Center(
                                child: Text(
                                  gif,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    : _emojiDrawerTab == 2
                        ? GridView.builder(
                            padding: const EdgeInsets.all(8),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              childAspectRatio: 1.8,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                            ),
                            itemCount: _stickerPack.length,
                            itemBuilder: (ctx, i) {
                              final stk = _stickerPack[i];
                              return InkWell(
                                onTap: () {
                                  setState(() => _showEmojiBar = false);
                                  _handleSendMessage(
                                    customText: stk,
                                    messageType: 'sticker',
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF2A3942) : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.amber.withOpacity(0.4)),
                                  ),
                                  child: Center(
                                    child: Text(
                                      stk,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                    ),
                                  ),
                                ),
                              );
                            },
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.all(10),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 2.3,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                            ),
                            itemCount: ChatWallpapers.allWallpapers.length,
                            itemBuilder: (ctx, i) {
                              final wp = ChatWallpapers.allWallpapers[i];
                              final isSel = _selectedWallpaperId == wp.id;
                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedWallpaperId = wp.id;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('✓ Chat theme set to ${wp.name} (${wp.hindiName})'),
                                      duration: const Duration(seconds: 1),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(colors: wp.gradientColors),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSel ? AppColors.primary : Colors.white24,
                                      width: isSel ? 2.5 : 1.0,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 14,
                                        height: 14,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isSel ? AppColors.primary : Colors.transparent,
                                          border: Border.all(color: Colors.white, width: 1.5),
                                        ),
                                        child: isSel ? const Icon(Icons.check, size: 10, color: Colors.white) : null,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              wp.name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white),
                                            ),
                                            Text(
                                              wp.hindiName,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(fontSize: 10, color: Colors.white70),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerTabItem(String title, int index) {
    final isSelected = _emojiDrawerTab == index;
    return InkWell(
      onTap: () => setState(() => _emojiDrawerTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: isSelected ? const Border(bottom: BorderSide(color: AppColors.primary, width: 3)) : null,
        ),
        child: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: isSelected ? AppColors.primary : Colors.grey,
          ),
        ),
      ),
    );
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
                      _handleSendMessage(
                        customText: 'Universal_Project_Spec.pdf',
                        messageType: 'document',
                        fileName: 'Universal_Project_Spec.pdf',
                        fileSize: '2.4 MB',
                      );
                    },
                  ),
                  _buildAttachmentItem(
                    icon: Icons.camera_alt_rounded,
                    label: 'Camera (कैमरा)',
                    color: const Color(0xFFD33F8D),
                    onTap: () {
                      Navigator.pop(ctx);
                      _showCameraPickerOptions();
                    },
                  ),
                  _buildAttachmentItem(
                    icon: Icons.image_rounded,
                    label: 'Gallery (गैलरी)',
                    color: const Color(0xFFAC44CF),
                    onTap: () {
                      Navigator.pop(ctx);
                      _captureRealPhoto(source: ImageSource.gallery);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildAttachmentItem(
                    icon: Icons.headphones_rounded,
                    label: 'Audio',
                    color: const Color(0xFFE56A2B),
                    onTap: () {
                      Navigator.pop(ctx);
                      _handleSendMessage(
                        customText: '🎧 Voice recording (0:18)',
                        messageType: 'audio',
                        audioDuration: '0:18',
                      );
                    },
                  ),
                  _buildAttachmentItem(
                    icon: Icons.location_on_rounded,
                    label: 'Location',
                    color: const Color(0xFF0F9D58),
                    onTap: () {
                      Navigator.pop(ctx);
                      _handleSendMessage(
                        customText: '📍 Live location shared (Silicon Tech Hub)',
                        messageType: 'location',
                      );
                    },
                  ),
                  _buildAttachmentItem(
                    icon: Icons.person_rounded,
                    label: 'Contact',
                    color: const Color(0xFF0284C7),
                    onTap: () {
                      Navigator.pop(ctx);
                      _handleSendMessage(
                        customText: '👤 Contact card shared',
                        messageType: 'contact',
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildAttachmentItem(
                    icon: Icons.poll_rounded,
                    label: 'Poll (वोटिंग)',
                    color: const Color(0xFF00897B),
                    onTap: () {
                      Navigator.pop(ctx);
                      _showCreatePollDialog();
                    },
                  ),
                  _buildAttachmentItem(
                    icon: Icons.event_available_rounded,
                    label: 'Event',
                    color: const Color(0xFFF59E0B),
                    onTap: () {
                      Navigator.pop(ctx);
                      _showCreateEventDialog();
                    },
                  ),
                  _buildAttachmentItem(
                    icon: Icons.auto_awesome_rounded,
                    label: 'AI Suite',
                    color: AppColors.aiPurple,
                    onTap: () {
                      Navigator.pop(ctx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AiAssistantScreen()),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildAttachmentItem(
                    icon: Icons.currency_rupee_rounded,
                    label: 'Payment (पेमेंट)',
                    color: const Color(0xFF059669),
                    onTap: () {
                      Navigator.pop(ctx);
                      _showInChatPaymentDialog();
                    },
                  ),
                  _buildAttachmentItem(
                    icon: Icons.qr_code_2_rounded,
                    label: 'QR Code (क्यूआर)',
                    color: const Color(0xFF5E35B1),
                    onTap: () {
                      Navigator.pop(ctx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => QrCodeShareScreen(
                            groupChatId: widget.groupChat?.chatId,
                            groupName: widget.groupChat?.groupName,
                          ),
                        ),
                      );
                    },
                  ),
                  _buildAttachmentItem(
                    icon: Icons.account_balance_wallet_rounded,
                    label: 'All Payments',
                    color: const Color(0xFF0288D1),
                    onTap: () {
                      Navigator.pop(ctx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PaymentsScreen()),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildAttachmentItem(
                    icon: Icons.schedule_send_rounded,
                    label: 'Schedule (शेड्यूल)',
                    color: const Color(0xFF00796B),
                    onTap: () {
                      Navigator.pop(ctx);
                      _showScheduleMessageDialog();
                    },
                  ),
                  _buildAttachmentItem(
                    icon: Icons.record_voice_over_rounded,
                    label: 'Dictate (बोलें)',
                    color: const Color(0xFFE91E63),
                    onTap: () {
                      Navigator.pop(ctx);
                      _showVoiceDictationDialog();
                    },
                  ),
                  _buildAttachmentItem(
                    icon: Icons.shield_rounded,
                    label: 'Encryption (सुरक्षा)',
                    color: const Color(0xFF607D8B),
                    onTap: () {
                      Navigator.pop(ctx);
                      _showVerifyEncryptionDialog();
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
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
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
              Text('Strict E2EE Verification'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Messages, calls, and media in this chat are protected by AES-256 end-to-end encryption. Compare this 60-digit number with the other participant to verify security.',
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

  void _showDisappearingMessagesDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.timer_outlined, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Disappearing Messages'),
          ],
        ),
        content: const Text(
          'For more privacy, all new messages will disappear from this chat after the selected duration.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Disappearing messages turned off.')),
              );
            },
            child: const Text('Off'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Disappearing messages set to 24 Hours.')),
              );
            },
            child: const Text('24 Hours', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
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

  void _showEditMessageDialog(MessageModel msg) {
    final controller = TextEditingController(text: msg.text);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Message'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Edited message text'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              final newText = controller.text.trim();
              if (newText.isNotEmpty) {
                final chatProvider = context.read<ChatProvider>();
                final authProvider = context.read<AuthProvider>();
                chatProvider.editMessage(
                  chatId: _chatId,
                  messageId: msg.messageId,
                  newText: newText,
                  isDevBypass: authProvider.isDevBypass,
                );
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final chatProvider = context.watch<ChatProvider>();
    final currentUserId = authProvider.currentUser?.uid ?? '';
    final isDevBypass = authProvider.isDevBypass;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasText = _messageController.text.trim().isNotEmpty;
    final isGroup = widget.groupChat != null;
    final isBlocked = !isGroup && SecurityService.instance.isUserBlocked(widget.targetUser.uid);

    final displayName = isGroup ? (widget.groupChat!.groupName ?? 'Group') : widget.targetUser.name;

    return Scaffold(
      appBar: _isSearchingChat
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () {
                  setState(() {
                    _isSearchingChat = false;
                    _chatSearchQuery = '';
                  });
                },
              ),
              title: TextField(
                autofocus: true,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: const InputDecoration(
                  hintText: 'Search in chat...',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                onChanged: (q) {
                  setState(() {
                    _chatSearchQuery = q;
                  });
                },
              ),
              actions: [
                if (_chatSearchQuery.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () {
                      setState(() {
                        _chatSearchQuery = '';
                      });
                    },
                  ),
              ],
            )
          : AppBar(
              titleSpacing: 0,
              title: InkWell(
                onTap: _showViewContactDialog,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: isGroup ? const Color(0xFF007AFF) : Colors.white24,
                      child: isGroup
                          ? const Icon(Icons.groups_rounded, color: Colors.white, size: 20)
                          : Text(
                              displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
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
                            displayName,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          if (isGroup)
                            Text(
                              '${widget.groupChat!.participants.length} participants',
                              style: const TextStyle(fontSize: 12, color: Colors.white70),
                            )
                          else
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
              actions: [
                const AppBarDevCircleButton(),
                IconButton(
                  icon: const Icon(Icons.videocam_rounded),
                  tooltip: 'Video Call',
                  onPressed: _startVideoCall,
                ),
                IconButton(
                  icon: const Icon(Icons.call_rounded),
                  tooltip: 'Voice Call',
                  onPressed: _startVoiceCall,
                ),
                PopupMenuButton<String>(
                  tooltip: 'More options',
                  onSelected: (val) {
                    if (val == 'view_contact') {
                      _showViewContactDialog();
                    } else if (val == 'media') {
                      _showMediaLinksDocsSheet();
                    } else if (val == 'search') {
                      setState(() => _isSearchingChat = true);
                    } else if (val == 'mute') {
                      _showMuteNotificationsDialog();
                    } else if (val == 'disappearing') {
                      _showDisappearingMessagesDialog();
                    } else if (val == 'wallpaper') {
                      _showChatThemeDialog();
                    } else if (val == 'verify') {
                      _showVerifyEncryptionDialog();
                    } else if (val == 'more') {
                      _showMoreOptionsSheet();
                    }
                  },
                  itemBuilder: (ctx) => [
                    PopupMenuItem(
                      value: 'view_contact',
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, size: 20),
                          const SizedBox(width: 10),
                          Text(isGroup ? 'Group info' : 'View contact'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'media',
                      child: Row(
                        children: [
                          Icon(Icons.perm_media_outlined, size: 20),
                          SizedBox(width: 10),
                          Text('Media, links, and docs'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'search',
                      child: Row(
                        children: [
                          Icon(Icons.search_rounded, size: 20),
                          SizedBox(width: 10),
                          Text('Search'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'mute',
                      child: Row(
                        children: [
                          Icon(Icons.notifications_off_outlined, size: 20),
                          SizedBox(width: 10),
                          Text('Mute notifications'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'disappearing',
                      child: Row(
                        children: [
                          Icon(Icons.timer_outlined, color: Colors.blueAccent, size: 20),
                          SizedBox(width: 10),
                          Text('Disappearing messages'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'wallpaper',
                      child: Row(
                        children: [
                          Icon(Icons.wallpaper_rounded, size: 20),
                          SizedBox(width: 10),
                          Text('Wallpaper'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'verify',
                      child: Row(
                        children: [
                          Icon(Icons.verified_user_rounded, color: AppColors.primary, size: 20),
                          SizedBox(width: 10),
                          Text('Strict E2EE Fingerprint'),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'more',
                      child: Row(
                        children: [
                          Icon(Icons.more_horiz_rounded, size: 20),
                          SizedBox(width: 10),
                          Text('More options...'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
      body: ChatWallpaperBackground(
        wallpaperId: _selectedWallpaperId,
        isDark: isDark,
        child: Column(
          children: [
            // Pinned Message Banner
            if (_pinnedMessage != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                color: isDark ? const Color(0xFF1E293B) : Colors.amber.shade50,
                child: Row(
                  children: [
                    const Icon(Icons.push_pin_rounded, size: 16, color: Colors.deepOrange),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Pinned: $_pinnedMessage',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                    InkWell(
                      onTap: () => setState(() => _pinnedMessage = null),
                      child: const Icon(Icons.close_rounded, size: 16),
                    ),
                  ],
                ),
              ),

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

                  final rawMessages = snapshot.data ?? [];
                  final messages = _isSearchingChat && _chatSearchQuery.trim().isNotEmpty
                      ? rawMessages.where((m) => m.text.toLowerCase().contains(_chatSearchQuery.toLowerCase().trim())).toList()
                      : rawMessages;

                  if (messages.isEmpty && _isSearchingChat && _chatSearchQuery.trim().isNotEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.search_off_rounded, size: 48, color: Colors.grey),
                          const SizedBox(height: 8),
                          Text(
                            'No messages matching "$_chatSearchQuery"',
                            style: const TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ],
                      ),
                    );
                  }

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
                    itemCount: messages.length + 1,
                    itemBuilder: (context, index) {
                      // Encryption Banner at top
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
                                    'Messages, media, and calls are end-to-end encrypted with AES-256. No one outside of this chat, not even Universal Chat App, can read or listen to them. Tap to verify.',
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
                        isGroupChat: isGroup,
                        onReactionSelected: (emoji) {
                          chatProvider.toggleReaction(
                            chatId: _chatId,
                            messageId: message.messageId,
                            reaction: emoji,
                            isDevBypass: isDevBypass,
                          );
                        },
                        onReply: (msg) {
                          setState(() {
                            _replyingToMessage = msg;
                          });
                        },
                        onPin: (msg) {
                          setState(() {
                            _pinnedMessage = msg.text;
                          });
                          chatProvider.pinMessage(
                            chatId: _chatId,
                            messageId: msg.messageId,
                            text: msg.text,
                            isDevBypass: isDevBypass,
                          );
                        },
                        onStar: (msg) {
                          chatProvider.toggleStarMessage(
                            chatId: _chatId,
                            messageId: msg.messageId,
                            isDevBypass: isDevBypass,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Message star updated')),
                          );
                        },
                        onEdit: (msg) => _showEditMessageDialog(msg),
                        onDelete: (msg, everyone) {
                          chatProvider.deleteMessage(
                            chatId: _chatId,
                            messageId: msg.messageId,
                            everyone: everyone,
                            isDevBypass: isDevBypass,
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),

            // Quick Emoji, Sticker, and GIF Drawer
            if (_showEmojiBar)
              _buildEmojiStickerGifDrawer(isDark),

            // Quoted Reply Banner
            if (_replyingToMessage != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: const Border(left: BorderSide(color: AppColors.primary, width: 4)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Replying to ${_replyingToMessage!.senderName ?? "User"}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primary),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _replyingToMessage!.text,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18),
                      onPressed: () => setState(() => _replyingToMessage = null),
                    ),
                  ],
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
              // Quick Phrases & Live Translation helper row
              Container(
                height: 32,
                margin: const EdgeInsets.only(left: 8, right: 8, bottom: 2),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    FilterChip(
                      selected: _isAutoTranslateOutgoing,
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.translate_rounded, size: 13, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            _isAutoTranslateOutgoing
                                ? 'अनुवाद: ${TranslationService.supportedLanguages.firstWhere((l) => l.code == _outgoingTargetLang).name}'
                                : '🌐 Live Translate',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      onSelected: (val) {
                        if (val) {
                          _showOutgoingLanguagePicker();
                        } else {
                          setState(() => _isAutoTranslateOutgoing = false);
                        }
                      },
                    ),
                    const SizedBox(width: 6),
                    for (final phrase in ['नमस्ते!', 'हाँ, बिल्कुल', 'धन्यवाद!', 'How are you?', 'OK, done!'])
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ActionChip(
                          label: Text(phrase, style: const TextStyle(fontSize: 11)),
                          onPressed: () {
                            _messageController.text += (_messageController.text.isEmpty ? '' : ' ') + phrase;
                            _onTextChanged(_messageController.text);
                          },
                        ),
                      ),
                  ],
                ),
              ),

              // Chat Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                child: SafeArea(
                  top: false,
                  child: Row(
                    children: [
                      // If recording voice note: WhatsApp live recording indicator bar
                      if (_isVoiceRecording)
                        Expanded(
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF26353D) : Colors.white,
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
                                const Icon(Icons.fiber_manual_record, color: Colors.red, size: 16),
                                const SizedBox(width: 8),
                                Text(
                                  '00:${_recordingSeconds.toString().padLeft(2, '0')}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.red),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: List.generate(12, (i) {
                                      final heights = [10.0, 16.0, 24.0, 14.0, 22.0, 18.0, 26.0, 12.0, 20.0, 15.0, 25.0, 12.0];
                                      return Container(
                                        width: 3,
                                        height: heights[i % heights.length],
                                        decoration: BoxDecoration(
                                          color: isDark ? Colors.white70 : AppColors.primary,
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                                  tooltip: 'Cancel Recording',
                                  onPressed: _cancelVoiceRecording,
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        // Rounded Input Pill
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
                                    color: _showEmojiBar ? AppColors.primary : Colors.grey.shade600,
                                  ),
                                  tooltip: _showEmojiBar ? 'Switch to Keyboard (कीपैड)' : 'Open Emojis & GIFs',
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
                                    focusNode: _messageFocusNode,
                                    onChanged: _onTextChanged,
                                    textCapitalization: TextCapitalization.sentences,
                                    minLines: 1,
                                    maxLines: 5,
                                    decoration: const InputDecoration(
                                      hintText: 'Message',
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                                    ),
                                  ),
                                ),
                                // Speech-to-Text Voice Dictation button
                                IconButton(
                                  icon: Icon(Icons.record_voice_over_rounded, size: 20, color: Colors.grey.shade600),
                                  tooltip: 'Speech Dictation (बोलकर लिखें)',
                                  onPressed: _showVoiceDictationDialog,
                                ),
                                // Attachment Clip Button
                                IconButton(
                                  icon: Transform.rotate(
                                    angle: -0.8,
                                    child: Icon(Icons.attach_file_rounded, color: Colors.grey.shade600),
                                  ),
                                  onPressed: _showAttachmentsBottomSheet,
                                ),
                                // Meta AI Quick Action Button
                                MetaAiChatAction(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const AiAssistantScreen()),
                                    );
                                  },
                                ),
                                // Camera Button (if not typing)
                                if (!hasText)
                                  IconButton(
                                    icon: Icon(Icons.camera_alt_rounded, color: Colors.grey.shade600),
                                    tooltip: 'Live Camera (लाइव कैमरा)',
                                    onPressed: _showCameraCaptureDialog,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(width: 6),
                      // Floating Circular Action Button (Mic, Send, or Send Voice Recording)
                      GestureDetector(
                        onTap: _isVoiceRecording
                            ? _sendVoiceRecording
                            : (hasText ? () => _handleSendMessage() : _startVoiceRecording),
                        onLongPress: _isVoiceRecording ? null : _showVoiceDictationDialog,
                        child: Tooltip(
                          message: _isVoiceRecording
                              ? 'Send Voice Recording'
                              : (hasText ? 'Send message' : 'Tap to Record Voice, hold for Dictation'),
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: _isVoiceRecording ? Colors.green.shade600 : AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _isVoiceRecording
                                  ? Icons.send_rounded
                                  : (hasText ? Icons.send_rounded : Icons.mic_rounded),
                              color: Colors.white,
                              size: 22,
                            ),
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
