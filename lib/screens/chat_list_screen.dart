import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/chat_model.dart';
import '../models/call_model.dart';
import '../models/status_model.dart';
import '../models/channel_model.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../utils/constants.dart';
import '../utils/date_formatter.dart';
import '../widgets/chat_tile.dart';
import '../widgets/floating_dev_circle.dart';
import 'chat_screen.dart';
import 'call_screen.dart';
import 'profile_screen.dart';
import 'users_list_screen.dart';
import 'status_view_screen.dart';
import 'group_create_screen.dart';
import 'channel_screen.dart';
import 'ai_assistant_screen.dart';
import 'business_profile_screen.dart';
import 'admin_dashboard_screen.dart';
import 'linked_devices_screen.dart';
import 'backup_sync_screen.dart';
import 'privacy_security_screen.dart';
import 'starred_messages_screen.dart';
import 'search_screen.dart';
import 'community_screen.dart';
import 'payments_screen.dart';
import 'subscription_screen.dart';
import 'qr_code_share_screen.dart';
import '../services/payment_service.dart';
import '../widgets/meta_ai_circle.dart';
import 'dev_bypass_sheet.dart';


class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;

  // Desktop Two-Pane Selection
  UserModel? _desktopSelectedUser;
  ChatModel? _desktopSelectedGroup;

  void _openChat(UserModel targetUser, ChatModel? groupChat) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= 900) {
      setState(() {
        _desktopSelectedUser = targetUser;
        _desktopSelectedGroup = groupChat;
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            targetUser: targetUser,
            groupChat: groupChat,
          ),
        ),
      );
    }
  }

  // Chats Tab Filter Chip: 'all', 'unread', 'favorites', 'groups'
  String _activeChatFilter = 'all';

  // Calls Tab Filter: 'all', 'voice', 'video'
  String _activeCallFilter = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showAddStatusDialog() {
    final textController = TextEditingController();
    final captionController = TextEditingController();
    String statusType = 'text'; // 'text', 'photo', 'video'
    int selectedColor = 0xFF005C4B;
    String selectedPhotoUrl = 'https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?w=800';
    String selectedVideoUrl = 'https://assets.mixkit.co/videos/preview/mixkit-software-developer-working-on-code-41551-large.mp4';

    final photoPresets = [
      {'name': 'Tech Summit 💻', 'url': 'https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?w=800'},
      {'name': 'Mountain Sunset 🌄', 'url': 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=800'},
      {'name': 'Coffee & Work ☕', 'url': 'https://images.unsplash.com/photo-1498050108023-c5249f4df085?w=800'},
      {'name': 'Modern City 🏙️', 'url': 'https://images.unsplash.com/photo-1477959858617-67f30bc75b82?w=800'},
    ];

    final videoPresets = [
      {'name': 'Developer Coding 💻', 'url': 'https://assets.mixkit.co/videos/preview/mixkit-software-developer-working-on-code-41551-large.mp4', 'duration': '0:15'},
      {'name': 'Sunset Waves 🌊', 'url': 'https://assets.mixkit.co/videos/preview/mixkit-waves-in-the-water-1164-large.mp4', 'duration': '0:15'},
      {'name': 'City Traffic Lights 🚗', 'url': 'https://assets.mixkit.co/videos/preview/mixkit-night-traffic-in-the-city-4200-large.mp4', 'duration': '0:20'},
    ];

    final colorOptions = [
      0xFF005C4B,
      0xFF128C7E,
      0xFF075E54,
      0xFF5856D6,
      0xFFFF2D55,
      0xFFFF9500,
      0xFF007AFF,
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final isDark = Theme.of(ctx).brightness == Brightness.dark;
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
                top: 20,
                left: 20,
                right: 20,
              ),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1F2C34) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Share to Status (स्टेटस साझा करें)',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Status Type Selector (Text/Link, Photo, Short Video)
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            avatar: const Icon(Icons.text_fields_rounded, size: 16),
                            label: const Text('Text / Link', style: TextStyle(fontSize: 12)),
                            selected: statusType == 'text',
                            onSelected: (val) {
                              if (val) setModalState(() => statusType = 'text');
                            },
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: ChoiceChip(
                            avatar: const Icon(Icons.photo_camera_rounded, size: 16),
                            label: const Text('Photo', style: TextStyle(fontSize: 12)),
                            selected: statusType == 'photo',
                            onSelected: (val) {
                              if (val) setModalState(() => statusType = 'photo');
                            },
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: ChoiceChip(
                            avatar: const Icon(Icons.videocam_rounded, size: 16),
                            label: const Text('Short Video', style: TextStyle(fontSize: 12)),
                            selected: statusType == 'video',
                            onSelected: (val) {
                              if (val) setModalState(() => statusType = 'video');
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    if (statusType == 'text') ...[
                      // Text / Link Box
                      Container(
                        height: 110,
                        decoration: BoxDecoration(
                          color: Color(selectedColor),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.all(16),
                        alignment: Alignment.center,
                        child: TextField(
                          controller: textController,
                          style: const TextStyle(color: Colors.white, fontSize: 18),
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            hintText: 'Type a status or paste link (https://)...',
                            hintStyle: TextStyle(color: Colors.white70),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: colorOptions.map((c) {
                            return GestureDetector(
                              onTap: () {
                                setModalState(() {
                                  selectedColor = c;
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.only(right: 10),
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Color(c),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: selectedColor == c ? Colors.white : Colors.transparent,
                                    width: 2.5,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ] else if (statusType == 'photo') ...[
                      // Photo Selection and Preview
                      Container(
                        height: 140,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.black26,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              selectedPhotoUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => const Center(
                                child: Icon(Icons.broken_image_rounded, size: 40, color: Colors.grey),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text('HD Photo', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text('Choose Image Preset or Enter URL:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 6),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: photoPresets.map((p) {
                            final isSel = selectedPhotoUrl == p['url'];
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(p['name']!, style: const TextStyle(fontSize: 11)),
                                selected: isSel,
                                onSelected: (val) {
                                  if (val) setModalState(() => selectedPhotoUrl = p['url']!);
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: captionController,
                        decoration: InputDecoration(
                          hintText: 'Add a photo caption...',
                          prefixIcon: const Icon(Icons.title_rounded, size: 20),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          isDense: true,
                        ),
                      ),
                    ] else if (statusType == 'video') ...[
                      // Short Video Selection
                      Container(
                        height: 130,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF001E2B),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.teal.shade700),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.teal.shade900,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.videocam_rounded, color: Colors.white, size: 30),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('Short Video Clip (15s)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                                  const SizedBox(height: 4),
                                  Text(
                                    videoPresets.firstWhere((v) => v['url'] == selectedVideoUrl, orElse: () => videoPresets.first)['name']!,
                                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text('Choose Short Video Preset:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 6),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: videoPresets.map((v) {
                            final isSel = selectedVideoUrl == v['url'];
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text('${v['name']} (${v['duration']})', style: const TextStyle(fontSize: 11)),
                                selected: isSel,
                                onSelected: (val) {
                                  if (val) setModalState(() => selectedVideoUrl = v['url']!);
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: captionController,
                        decoration: InputDecoration(
                          hintText: 'Add a video caption...',
                          prefixIcon: const Icon(Icons.closed_caption_rounded, size: 20),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          isDense: true,
                        ),
                      ),
                    ],

                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        icon: const Icon(Icons.send_rounded),
                        label: const Text('Post Status (स्टेटस साझा करें)', style: TextStyle(fontWeight: FontWeight.bold)),
                        onPressed: () {
                          final text = textController.text.trim();
                          final caption = captionController.text.trim();
                          final auth = context.read<AuthProvider>();
                          final chat = context.read<ChatProvider>();
                          final user = auth.currentUser;

                          if (statusType == 'text' && text.isEmpty) return;

                          if (user != null) {
                            String finalText = text;
                            String? media;
                            if (statusType == 'photo') {
                              media = selectedPhotoUrl;
                              finalText = caption.isNotEmpty ? caption : 'Shared a photo';
                            } else if (statusType == 'video') {
                              media = selectedVideoUrl;
                              finalText = caption.isNotEmpty ? caption : 'Short Video Story';
                            }

                            chat.addStatus(
                              StatusModel(
                                statusId: 'status_${DateTime.now().millisecondsSinceEpoch}',
                                userId: user.uid,
                                userName: user.name,
                                text: finalText,
                                mediaUrl: media,
                                caption: caption.isNotEmpty ? caption : null,
                                statusType: statusType,
                                backgroundColorHex: selectedColor,
                                timestamp: DateTime.now(),
                                isViewed: false,
                              ),
                              isDevBypass: auth.isDevBypass,
                            );
                          }
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('✓ Status story published successfully!'),
                              backgroundColor: AppColors.primary,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _startDirectCall({required bool isVideo}) async {
    final auth = context.read<AuthProvider>();
    final chat = context.read<ChatProvider>();
    final users = await chat.getUsersStream(
      currentUserId: auth.currentUser?.uid ?? '',
      isDevBypass: auth.isDevBypass,
    ).first;

    if (!mounted || users.isEmpty) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1F2C34) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Icon(
                      isVideo ? Icons.videocam_rounded : Icons.call_rounded,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      isVideo ? 'Start HD Video Call' : 'Start Voice Call',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const Divider(),
              ...users.map((targetUser) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: Text(
                      targetUser.name.isNotEmpty ? targetUser.name[0].toUpperCase() : 'U',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(targetUser.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(targetUser.status),
                  trailing: Icon(
                    isVideo ? Icons.videocam_rounded : Icons.call_rounded,
                    color: AppColors.primary,
                  ),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final dur = await Navigator.push<int>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CallScreen(
                          targetUser: targetUser,
                          isVideoCall: isVideo,
                        ),
                      ),
                    );

                    final callDuration = dur ?? 0;
                    final currentUserId = auth.currentUser?.uid ?? '';
                    await chat.addCallRecord(
                      CallModel(
                        callId: 'call_${DateTime.now().millisecondsSinceEpoch}',
                        callerId: currentUserId,
                        receiverId: targetUser.uid,
                        callerName: targetUser.name,
                        timestamp: DateTime.now(),
                        durationSeconds: callDuration,
                        isVideo: isVideo,
                        isMissed: callDuration == 0,
                        isOutgoing: true,
                      ),
                      isDevBypass: auth.isDevBypass,
                    );
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showCreateChannelDialog() {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final handleCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.campaign_rounded, color: AppColors.primary),
            SizedBox(width: 10),
            Text('Create Channel (चैनल बनाएं)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Channels are a one-way broadcast tool for admins to send text, photos, and polls to unlimited followers.', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 12),
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Channel Name', hintText: 'e.g. AI News Hub'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: handleCtrl,
              decoration: const InputDecoration(labelText: 'Handle', prefixText: '@', hintText: 'ai_news_hub'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: descCtrl,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Description', hintText: 'What is this channel about?'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            onPressed: () {
              final n = nameCtrl.text.trim();
              if (n.isNotEmpty) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('✓ Channel "$n" created! You can now post broadcast updates.'),
                    backgroundColor: AppColors.primary,
                  ),
                );
              }
            },
            child: const Text('Create Channel'),
          ),
        ],
      ),
    );
  }

  void _showCreateQuickActionMenu() {
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
              const Text('Create New', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              ListTile(
                leading: const CircleAvatar(backgroundColor: Color(0xFF007AFF), child: Icon(Icons.groups_rounded, color: Colors.white)),
                title: const Text('New Group (नया ग्रुप)'),
                subtitle: const Text('Group chat with up to 1,024 members'),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const GroupCreateScreen()));
                },
              ),
              ListTile(
                leading: const CircleAvatar(backgroundColor: Color(0xFF25D366), child: Icon(Icons.campaign_rounded, color: Colors.white)),
                title: const Text('New Channel (नया चैनल)'),
                subtitle: const Text('Broadcast channel with unlimited followers'),
                onTap: () {
                  Navigator.pop(ctx);
                  _showCreateChannelDialog();
                },
              ),
              ListTile(
                leading: const CircleAvatar(backgroundColor: Color(0xFF9C27B0), child: Icon(Icons.public_rounded, color: Colors.white)),
                title: const Text('New Community (कम्युनिटी)'),
                subtitle: const Text('Organize related groups under one umbrella community'),
                onTap: () {
                  Navigator.pop(ctx);
                  _showCreateCommunityDialog();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentUser = authProvider.currentUser;
    final isDevBypass = authProvider.isDevBypass;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final Widget leftPane = Scaffold(
      appBar: AppBar(
        titleSpacing: NavigationToolbar.kMiddleSpacing,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val.trim().toLowerCase();
                  });
                },
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Search chats, groups, updates...',
                  hintStyle: TextStyle(color: Colors.white60),
                  border: InputBorder.none,
                ),
              )
            : Text(
                AppConstants.appName,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
        actions: _buildResponsiveActions(context, screenWidth, isDevBypass, authProvider),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3.0,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
          tabs: const [
            Tab(text: 'CHATS'),
            Tab(text: 'UPDATES'),
            Tab(text: 'COMMUNITIES'),
            Tab(text: 'CALLS'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildChatsTab(currentUser, isDevBypass, isDark),
          _buildUpdatesTab(currentUser, isDevBypass, isDark),
          _buildCommunitiesTab(currentUser, isDevBypass, isDark),
          _buildCallsTab(currentUser, isDevBypass, isDark),
        ],
      ),
      floatingActionButton: _buildFab(),
    );

    if (!isDesktop) {
      return leftPane;
    }

    // Desktop Two-Pane Split View (WhatsApp Web style)
    return Scaffold(
      body: Row(
        children: [
          SizedBox(
            width: screenWidth > 1300 ? 440 : 380,
            child: leftPane,
          ),
          VerticalDivider(
            width: 1,
            thickness: 1,
            color: isDark ? Colors.white12 : Colors.grey.shade300,
          ),
          Expanded(
            child: _desktopSelectedUser != null
                ? ChatScreen(
                    key: ValueKey(_desktopSelectedUser!.uid),
                    targetUser: _desktopSelectedUser!,
                    groupChat: _desktopSelectedGroup,
                    isEmbeddedDesktop: true,
                  )
                : _buildDesktopPlaceholder(isDark),
          ),
        ],
      ),
    );
  }

  /// Responsive toolbar actions that eliminate header overlap on mobile screens
  List<Widget> _buildResponsiveActions(
    BuildContext context,
    double screenWidth,
    bool isDevBypass,
    AuthProvider authProvider,
  ) {
    final bool isCompact = screenWidth < 520;

    return [
      if (!isCompact)
        IconButton(
          icon: const Icon(Icons.camera_alt_outlined),
          tooltip: 'Camera (कैमरा)',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const UsersListScreen()),
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Select a chat to share live camera photos!')),
            );
          },
        ),
      IconButton(
        icon: Container(
          padding: const EdgeInsets.all(2.5),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 1.5),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.currency_rupee_rounded, size: 15),
        ),
        tooltip: 'Universal Pay (पेमेंट्स)',
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentsScreen()));
        },
      ),
      if (!isCompact)
        IconButton(
          icon: const Icon(Icons.qr_code_scanner_rounded),
          tooltip: 'QR Code & Scanner',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const QrCodeShareScreen(initialTabIndex: 0)),
            );
          },
        ),
      IconButton(
        icon: Icon(_isSearching ? Icons.close_rounded : Icons.search_rounded),
        tooltip: _isSearching ? 'Close Search' : 'Search',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SearchScreen()),
          );
        },
      ),
      if (!isCompact)
        IconButton(
          icon: const Icon(Icons.group_add_rounded),
          tooltip: 'New Group',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const GroupCreateScreen()),
            );
          },
        ),
      PopupMenuButton<String>(
        tooltip: 'More options',
        onSelected: (val) {
          if (val == 'camera') {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const UsersListScreen()));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Select a chat to share live camera photos!')),
            );
          } else if (val == 'payments') {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentsScreen()));
          } else if (val == 'subscription') {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionScreen()));
          } else if (val == 'qr_code') {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const QrCodeShareScreen()));
          } else if (val == 'new_group') {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const GroupCreateScreen()));
          } else if (val == 'contacts') {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const UsersListScreen()));
          } else if (val == 'ai_suite') {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AiAssistantScreen()));
          } else if (val == 'business') {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const BusinessProfileScreen()));
          } else if (val == 'admin') {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminDashboardScreen()));
          } else if (val == 'linked_devices') {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const LinkedDevicesScreen()));
          } else if (val == 'community') {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const CommunityScreen()));
          } else if (val == 'starred') {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const StarredMessagesScreen()));
          } else if (val == 'backup') {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const BackupSyncScreen()));
          } else if (val == 'privacy') {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacySecurityScreen()));
          } else if (val == 'settings') {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
          } else if (val == 'bypass') {
            authProvider.toggleDevBypass();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  authProvider.isDevBypass
                      ? 'Developer Mode Bypass Enabled (बाईपास सक्रिय)'
                      : 'Developer Mode Bypass Disabled',
                ),
                backgroundColor: AppColors.primary,
              ),
            );
          }
        },
        itemBuilder: (ctx) => [
          if (isCompact) ...[
            const PopupMenuItem(
              value: 'camera',
              child: Row(
                children: [
                  Icon(Icons.camera_alt_outlined, color: Colors.teal, size: 20),
                  SizedBox(width: 12),
                  Text('Camera (कैमरा)'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'qr_code',
              child: Row(
                children: [
                  Icon(Icons.qr_code_scanner_rounded, color: Color(0xFF5E35B1), size: 20),
                  SizedBox(width: 12),
                  Text('Scan / Show QR Code'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'new_group',
              child: Row(
                children: [
                  Icon(Icons.groups_rounded, color: Colors.blue, size: 20),
                  SizedBox(width: 12),
                  Text('New Group'),
                ],
              ),
            ),
            const PopupMenuDivider(),
          ],
          const PopupMenuItem(
            value: 'payments',
            child: Row(
              children: [
                Icon(Icons.currency_rupee_rounded, color: Colors.teal, size: 20),
                SizedBox(width: 12),
                Text('Payments (पेमेंट्स)'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'subscription',
            child: Row(
              children: [
                Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                SizedBox(width: 12),
                Text('Universal Pro & Storage'),
              ],
            ),
          ),
          if (!isCompact)
            const PopupMenuItem(
              value: 'qr_code',
              child: Row(
                children: [
                  Icon(Icons.qr_code_2_rounded, color: Color(0xFF5E35B1), size: 20),
                  SizedBox(width: 12),
                  Text('QR Code (क्यूआर)'),
                ],
              ),
            ),
          const PopupMenuDivider(),
          const PopupMenuItem(
            value: 'ai_suite',
            child: Row(
              children: [
                Icon(Icons.auto_awesome_rounded, color: AppColors.aiPurple, size: 20),
                SizedBox(width: 12),
                Text('Universal AI Suite'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'business',
            child: Row(
              children: [
                Icon(Icons.storefront_rounded, color: AppColors.businessBlue, size: 20),
                SizedBox(width: 12),
                Text('Business Hub & Catalog'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'admin',
            child: Row(
              children: [
                Icon(Icons.admin_panel_settings_rounded, color: AppColors.adminGold, size: 20),
                SizedBox(width: 12),
                Text('Admin Dashboard'),
              ],
            ),
          ),
          const PopupMenuDivider(),
          if (!isCompact)
            const PopupMenuItem(
              value: 'new_group',
              child: Row(
                children: [
                  Icon(Icons.groups_rounded, size: 20),
                  SizedBox(width: 12),
                  Text('New Group'),
                ],
              ),
            ),
          const PopupMenuItem(
            value: 'community',
            child: Row(
              children: [
                Icon(Icons.public_rounded, size: 20),
                SizedBox(width: 12),
                Text('Community Announcements'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'linked_devices',
            child: Row(
              children: [
                Icon(Icons.devices_rounded, size: 20),
                SizedBox(width: 12),
                Text('Linked Devices'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'starred',
            child: Row(
              children: [
                Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                SizedBox(width: 12),
                Text('Starred Messages'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'backup',
            child: Row(
              children: [
                Icon(Icons.cloud_sync_rounded, size: 20),
                SizedBox(width: 12),
                Text('Chat Backup & Sync'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'privacy',
            child: Row(
              children: [
                Icon(Icons.security_rounded, size: 20),
                SizedBox(width: 12),
                Text('Privacy & Security'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'settings',
            child: Row(
              children: [
                Icon(Icons.settings_rounded, size: 20),
                SizedBox(width: 12),
                Text('Settings'),
              ],
            ),
          ),
          const PopupMenuDivider(),
          PopupMenuItem(
            value: 'bypass',
            child: Row(
              children: [
                Icon(
                  isDevBypass ? Icons.toggle_on_rounded : Icons.toggle_off_rounded,
                  color: isDevBypass ? Colors.amber.shade700 : null,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(isDevBypass ? 'Disable Dev Bypass' : 'Enable Dev Bypass'),
              ],
            ),
          ),
        ],
      ),
    ];
  }

  /// WhatsApp Web-style Desktop Empty State Placeholder
  Widget _buildDesktopPlaceholder(bool isDark) {
    return Container(
      color: isDark ? const Color(0xFF111B21) : const Color(0xFFF0F2F5),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.12),
                ),
                child: const Icon(
                  Icons.laptop_chromebook_rounded,
                  size: 64,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                AppConstants.appName,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF41525D),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Send and receive messages with live WebRTC camera, speech-to-text dictation, and UPI QR payments.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white60 : const Color(0xFF667781),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                    label: const Text('Start New Chat'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const UsersListScreen()),
                      );
                    },
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
                    label: const Text('Scan QR Code'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const QrCodeShareScreen(initialTabIndex: 1),
                        ),
                      );
                    },
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.teal,
                      side: const BorderSide(color: Colors.teal),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.currency_rupee_rounded, size: 18),
                    label: const Text('Universal Pay (UPI)'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PaymentsScreen()),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lock_rounded,
                    size: 14,
                    color: isDark ? Colors.white38 : Colors.grey.shade500,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'End-to-end encrypted • Universal Chat Web v${AppConstants.appVersion}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white38 : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Floating Action Button corresponding to active tab
  Widget _buildFab() {
    final currentIndex = _tabController.index;
    if (currentIndex == 0) {
      // Chats Tab FABs:
      // 1. Universal AI Floating Circle on top
      // 2. Select Contact & Add by Mobile (+91)
      // 3. New Chat / Direct Message
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Universal AI Floating Circle
          const MetaAiFloatingCircle(),
          const SizedBox(height: 12),
          FloatingActionButton.small(
            heroTag: 'fab_contacts',
            backgroundColor: const Color(0xFF007AFF),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UsersListScreen()),
              );
            },
            tooltip: 'Select Contact & Add (+91) (कांटेक्ट्स)',
            child: const Icon(Icons.contacts_rounded, color: Colors.white),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'fab_chat',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UsersListScreen()),
              );
            },
            tooltip: 'New Chat / Direct Message (नया चैट)',
            child: const Icon(Icons.chat_rounded),
          ),
        ],
      );
    } else if (currentIndex == 1) {
      // Updates Tab FABs
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'edit_status',
            backgroundColor: const Color(0xFF25D366),
            onPressed: _showAddStatusDialog,
            tooltip: 'Type a Status',
            child: const Icon(Icons.edit_rounded, color: Colors.white),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'camera_status',
            onPressed: _showAddStatusDialog,
            tooltip: 'Post Status',
            child: const Icon(Icons.camera_alt_rounded),
          ),
        ],
      );
    } else if (currentIndex == 2) {
      // Communities Tab FAB
      return FloatingActionButton.extended(
        heroTag: 'fab_community',
        backgroundColor: AppColors.primary,
        onPressed: _showCreateCommunityDialog,
        icon: const Icon(Icons.group_add_rounded, color: Colors.white),
        label: const Text('New Community', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      );
    } else {
      // Calls Tab FAB
      return FloatingActionButton(
        onPressed: () => _startDirectCall(isVideo: false),
        tooltip: 'New Call',
        child: const Icon(Icons.add_call),
      );
    }
  }

  // 1. CHATS TAB with Modern Filter Chips
  Widget _buildChatsTab(UserModel currentUser, bool isDevBypass, bool isDark) {
    final chatProvider = context.watch<ChatProvider>();

    return Column(
      children: [
        // WhatsApp Modern Filter Chips Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          color: isDark ? const Color(0xFF121B22) : Colors.white,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All', 'all', isDark),
                const SizedBox(width: 8),
                _buildFilterChip('Unread', 'unread', isDark),
                const SizedBox(width: 8),
                _buildFilterChip('Favorites ⭐', 'favorites', isDark),
                const SizedBox(width: 8),
                _buildFilterChip('Groups 👥', 'groups', isDark),
                const SizedBox(width: 8),
                InkWell(
                  onTap: _showCreateQuickActionMenu,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF233138) : Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add, size: 18),
                  ),
                ),
                const SizedBox(width: 8),
                Tooltip(
                  message: 'Developer Diagnostics & Bypass',
                  child: InkWell(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (ctx) => const DevBypassSheet(),
                      );
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isDevBypass ? Colors.amber.withOpacity(0.2) : (isDark ? const Color(0xFF233138) : Colors.grey.shade200),
                        shape: BoxShape.circle,
                        border: isDevBypass ? Border.all(color: Colors.amber, width: 1.5) : null,
                      ),
                      child: Icon(
                        Icons.settings_suggest_rounded,
                        size: 18,
                        color: isDevBypass ? Colors.amber.shade700 : (isDark ? Colors.grey.shade300 : Colors.grey.shade700),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Sponsored Ad Banner (Free Tier only - disappears with Pro Subscription)
        if (!PaymentService.instance.isPremiumUser)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.cloud_upload_rounded, color: Colors.green, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Sponsored: 100GB Extra Cloud Backup & Unlimited AI',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5),
                      ),
                      Text(
                        'Upgrade to Universal Pro to remove ads & unlock all features.',
                        style: TextStyle(fontSize: 10.5, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
                    );
                  },
                  child: const Text('Upgrade Pro', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),

        // Chat stream
        Expanded(
          child: StreamBuilder<List<ChatModel>>(
            stream: chatProvider.getRecentChatsStream(
              currentUserId: currentUser.uid,
              isDevBypass: isDevBypass,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final allChats = snapshot.data ?? [];

              // Apply Filter Chips
              List<ChatModel> filteredByChip = allChats;
              if (_activeChatFilter == 'unread') {
                filteredByChip = allChats.where((c) => c.getUnreadCount(currentUser.uid) > 0).toList();
              } else if (_activeChatFilter == 'favorites') {
                filteredByChip = allChats.where((c) => c.isFavorite).toList();
              } else if (_activeChatFilter == 'groups') {
                filteredByChip = allChats.where((c) => c.isGroup).toList();
              }

              // Apply Search Query
              final filteredChats = _searchQuery.isEmpty
                  ? filteredByChip
                  : filteredByChip.where((c) {
                      final name = c.isGroup ? (c.groupName ?? '') : '';
                      return c.lastMessage.toLowerCase().contains(_searchQuery) ||
                          name.toLowerCase().contains(_searchQuery);
                    }).toList();

              if (filteredChats.isEmpty) {
                return Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'No ${_activeChatFilter == "all" ? "conversations" : _activeChatFilter} yet'
                              : 'No matching chats found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchQuery.isEmpty
                              ? 'Tap the message button to start chatting or create a group!'
                              : 'Try searching with a different keyword',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white38 : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.separated(
                itemCount: filteredChats.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  indent: 80,
                  color: isDark ? Colors.white10 : Colors.grey.shade200,
                ),
                itemBuilder: (context, index) {
                  final chat = filteredChats[index];

                  return ChatTile(
                    chat: chat,
                    onTap: () async {
                      if (chat.isGroup) {
                        _openChat(
                          UserModel(
                            uid: chat.chatId,
                            name: chat.groupName ?? 'Group',
                            email: '',
                            status: chat.groupDescription ?? '',
                            createdAt: DateTime.now(),
                          ),
                          chat,
                        );
                      } else {
                        final otherUserId = chat.getOtherUserId(currentUser.uid);
                        final otherUser = await chatProvider.getUserById(
                          otherUserId,
                          isDevBypass,
                        );
                        if (otherUser != null && context.mounted) {
                          _openChat(otherUser, null);
                        }
                      }
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String filterKey, bool isDark) {
    final isSelected = _activeChatFilter == filterKey;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeChatFilter = filterKey;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : (isDark ? const Color(0xFF1F2C34) : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
          ),
        ),
      ),
    );
  }

  // 2. UPDATES TAB (Status Stories + News Channels)
  Widget _buildUpdatesTab(UserModel currentUser, bool isDevBypass, bool isDark) {
    final chatProvider = context.watch<ChatProvider>();

    return ListView(
      children: [
        // My Status Tile
        ListTile(
          leading: Stack(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.primary,
                child: Text(
                  currentUser.name.isNotEmpty
                      ? currentUser.name[0].toUpperCase()
                      : 'M',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF25D366),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(2),
                  child: const Icon(
                    Icons.add,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          title: const Text(
            'My Status',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: const Text('Tap to add status update'),
          onTap: _showAddStatusDialog,
        ),

        // Status stream
        StreamBuilder<List<StatusModel>>(
          stream: chatProvider.getStatusStream(isDevBypass: isDevBypass),
          builder: (context, snapshot) {
            final statuses = snapshot.data ?? [];
            final recentStatuses = statuses.where((s) => !s.isViewed).toList();
            final viewedStatuses = statuses.where((s) => s.isViewed).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (recentStatuses.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                    child: Text(
                      'Recent updates',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ),
                  ...recentStatuses.map((status) {
                    return ListTile(
                      leading: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF25D366),
                            width: 2.5,
                          ),
                        ),
                        padding: const EdgeInsets.all(2.5),
                        child: CircleAvatar(
                          radius: 22,
                          backgroundColor: Color(status.backgroundColorHex),
                          child: Text(
                            status.userName.isNotEmpty
                                ? status.userName[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        status.userName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: Text(
                        DateFormatter.formatMessageTime(status.timestamp),
                        style: TextStyle(color: isDark ? Colors.white60 : Colors.black54),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => StatusViewScreen(
                              status: status,
                              onStatusCompleted: () {
                                chatProvider.markStatusViewed(
                                  status.statusId,
                                  isDevBypass: isDevBypass,
                                );
                              },
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ],

                if (viewedStatuses.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                    child: Text(
                      'Viewed updates',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ),
                  ...viewedStatuses.map((status) {
                    return ListTile(
                      leading: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? Colors.white30 : Colors.grey.shade400,
                            width: 2.0,
                          ),
                        ),
                        padding: const EdgeInsets.all(2.5),
                        child: CircleAvatar(
                          radius: 22,
                          backgroundColor: Color(status.backgroundColorHex),
                          child: Text(
                            status.userName.isNotEmpty
                                ? status.userName[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        status.userName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: Text(
                        DateFormatter.formatMessageTime(status.timestamp),
                        style: TextStyle(color: isDark ? Colors.white60 : Colors.black54),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => StatusViewScreen(status: status),
                          ),
                        );
                      },
                    );
                  }),
                ],
              ],
            );
          },
        ),

        const Divider(thickness: 6, height: 28),

        // Channels & News Updates Section
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Channels & News Feeds',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              Row(
                children: [
                  TextButton.icon(
                    style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Create Channel', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    onPressed: _showCreateChannelDialog,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Explore >',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Stay updated on topics you care about. Follow AI, Tech, and Security news.',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
        ),
        const SizedBox(height: 8),

        StreamBuilder<List<ChannelModel>>(
          stream: chatProvider.getChannelsStream(isDevBypass: isDevBypass),
          builder: (context, snapshot) {
            final channels = snapshot.data ?? [];
            return Column(
              children: channels.map((chan) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF007AFF).withOpacity(0.12),
                    child: Text(chan.avatar, style: const TextStyle(fontSize: 20)),
                  ),
                  title: Row(
                    children: [
                      Flexible(
                        child: Text(
                          chan.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      if (chan.isVerified) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.verified_rounded, size: 15, color: AppColors.primary),
                      ],
                    ],
                  ),
                  subtitle: Text(
                    chan.latestUpdate,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13, color: isDark ? Colors.white60 : Colors.black54),
                  ),
                  trailing: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      side: BorderSide(color: chan.isFollowing ? Colors.grey : AppColors.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () {
                      chatProvider.toggleChannelFollow(chan.channelId, isDevBypass: isDevBypass);
                    },
                    child: Text(
                      chan.isFollowing ? 'Following' : 'Follow',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: chan.isFollowing ? Colors.grey : AppColors.primary,
                      ),
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ChannelScreen(channel: chan)),
                    );
                  },
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  // 3. CALLS TAB with Voice & Video Separation
  Widget _buildCallsTab(UserModel currentUser, bool isDevBypass, bool isDark) {
    final chatProvider = context.watch<ChatProvider>();

    return Column(
      children: [
        // Voice vs Video Segment Filter
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          color: isDark ? const Color(0xFF121B22) : Colors.white,
          child: Row(
            children: [
              _buildCallFilterChip('All Calls', 'all', isDark),
              const SizedBox(width: 8),
              _buildCallFilterChip('📞 Voice Calls', 'voice', isDark),
              const SizedBox(width: 8),
              _buildCallFilterChip('📹 Video Calls', 'video', isDark),
            ],
          ),
        ),

        Expanded(
          child: StreamBuilder<List<CallModel>>(
            stream: chatProvider.getCallsStream(
              currentUserId: currentUser.uid,
              isDevBypass: isDevBypass,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final allCalls = snapshot.data ?? [];
              List<CallModel> filteredCalls = allCalls;
              if (_activeCallFilter == 'voice') {
                filteredCalls = allCalls.where((c) => !c.isVideo).toList();
              } else if (_activeCallFilter == 'video') {
                filteredCalls = allCalls.where((c) => c.isVideo).toList();
              }

              if (filteredCalls.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.phone_missed_rounded,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No ${_activeCallFilter == "all" ? "recent" : _activeCallFilter} calls',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap the call button below to start an HD voice or video call!',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white38 : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                itemCount: filteredCalls.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  indent: 80,
                  color: isDark ? Colors.white10 : Colors.grey.shade200,
                ),
                itemBuilder: (context, index) {
                  final call = filteredCalls[index];
                  final isMissed = call.isMissed;
                  final isOutgoing = call.isOutgoing;

                  IconData callIcon;
                  Color callColor;
                  if (isMissed) {
                    callIcon = Icons.call_missed_rounded;
                    callColor = Colors.redAccent;
                  } else if (isOutgoing) {
                    callIcon = Icons.call_made_rounded;
                    callColor = const Color(0xFF25D366);
                  } else {
                    callIcon = Icons.call_received_rounded;
                    callColor = const Color(0xFF25D366);
                  }

                  final durationText = call.durationSeconds > 0
                      ? ' (${(call.durationSeconds ~/ 60)}m ${(call.durationSeconds % 60)}s)'
                      : (isMissed ? ' (Missed)' : '');

                  return ListTile(
                    leading: CircleAvatar(
                      radius: 24,
                      backgroundColor: call.isVideo
                          ? const Color(0xFF007AFF).withOpacity(0.18)
                          : AppColors.primary.withOpacity(0.18),
                      child: Icon(
                        call.isVideo ? Icons.videocam_rounded : Icons.call_rounded,
                        color: call.isVideo ? const Color(0xFF007AFF) : AppColors.primary,
                        size: 22,
                      ),
                    ),
                    title: Text(
                      call.callerName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isMissed ? Colors.redAccent : null,
                      ),
                    ),
                    subtitle: Row(
                      children: [
                        Icon(callIcon, size: 16, color: callColor),
                        const SizedBox(width: 4),
                        Text(
                          '${DateFormatter.formatMessageTime(call.timestamp)}$durationText',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        call.isVideo ? Icons.videocam_rounded : Icons.call_rounded,
                        color: AppColors.primary,
                      ),
                      tooltip: call.isVideo ? 'Video Call' : 'Voice Call',
                      onPressed: () async {
                        final targetUser = await chatProvider.getUserById(
                          call.isOutgoing ? call.receiverId : call.callerId,
                          isDevBypass,
                        ) ?? UserModel(
                          uid: call.isOutgoing ? call.receiverId : call.callerId,
                          name: call.callerName,
                          email: '',
                          createdAt: DateTime.now(),
                        );

                        if (context.mounted) {
                          final dur = await Navigator.push<int>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CallScreen(
                                targetUser: targetUser,
                                isVideoCall: call.isVideo,
                              ),
                            ),
                          );

                          final callDuration = dur ?? 0;
                          await chatProvider.addCallRecord(
                            CallModel(
                              callId: 'call_${DateTime.now().millisecondsSinceEpoch}',
                              callerId: currentUser.uid,
                              receiverId: targetUser.uid,
                              callerName: targetUser.name,
                              timestamp: DateTime.now(),
                              durationSeconds: callDuration,
                              isVideo: call.isVideo,
                              isMissed: callDuration == 0,
                              isOutgoing: true,
                            ),
                            isDevBypass: isDevBypass,
                          );
                        }
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCallFilterChip(String label, String filterKey, bool isDark) {
    final isSelected = _activeCallFilter == filterKey;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeCallFilter = filterKey;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : (isDark ? const Color(0xFF1F2C34) : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
          ),
        ),
      ),
    );
  }

  void _showCreateCommunityDialog() {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            top: 24,
            left: 20,
            right: 20,
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
                      color: AppColors.primary.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.groups_rounded, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'New Community (नई कम्युनिटी)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Bring together related groups and send announcements to all members easily.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Community Name',
                  hintText: 'e.g. Neighborhood Network / Tech Club',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText: 'What is this community for?',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
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
                    final name = nameController.text.trim();
                    if (name.isNotEmpty) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('🎉 Community "$name" created successfully!'),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    }
                  },
                  child: const Text('Create Community', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 3. COMMUNITIES TAB (WhatsApp Style)
  Widget _buildCommunitiesTab(UserModel currentUser, bool isDevBypass, bool isDark) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        // Top Action: New Community
        ListTile(
          onTap: _showCreateCommunityDialog,
          leading: Stack(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2A3942) : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.groups_rounded, color: Colors.grey, size: 28),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 14),
                ),
              ),
            ],
          ),
          title: const Text('New Community (नई कम्युनिटी)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          subtitle: const Text('Organize groups & broadcast announcements', style: TextStyle(fontSize: 12, color: Colors.grey)),
        ),

        const Divider(height: 16, thickness: 8),

        // Community 1: Universal Global Tech & AI Community
        _buildCommunityCard(
          title: '🌐 Universal Global Tech & AI Community',
          members: '4,620 members',
          announcementText: '📢 Universal Announcements • v1.5.0 Release Live!',
          subGroups: [
            {'name': '🤖 Universal AI & Prompt Engineers', 'members': '1,420 members'},
            {'name': '💡 Mobile App Innovators & Builders', 'members': '890 members'},
            {'name': '🔒 CyberSecurity & E2EE Watchers', 'members': '2,310 members'},
          ],
          isDark: isDark,
        ),

        const Divider(height: 16, thickness: 8),

        // Community 2: Flutter & Dart Developers Network
        _buildCommunityCard(
          title: '🚀 Flutter & Dart Developers Network',
          members: '3,280 members',
          announcementText: '📢 Announcements • Material 3 UI Kit Released',
          subGroups: [
            {'name': '🎨 UI/UX & Widget Design', 'members': '1,150 members'},
            {'name': '⚡ State Management & Architecture', 'members': '940 members'},
          ],
          isDark: isDark,
        ),

        const Divider(height: 16, thickness: 8),

        // Community 3: Neighborhood & City Collaboration Hub
        _buildCommunityCard(
          title: '🏙️ City Collaboration & Neighborhood Hub',
          members: '1,850 members',
          announcementText: '📢 Local Bulletins & Event Alerts',
          subGroups: [
            {'name': '🛒 Community Marketplace & Deals', 'members': '720 members'},
            {'name': '🚗 City Carpool & Rideshare', 'members': '640 members'},
          ],
          isDark: isDark,
        ),

        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildCommunityCard({
    required String title,
    required String members,
    required String announcementText,
    required List<Map<String, String>> subGroups,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Community Header Tile
        ListTile(
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.aiPurple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(child: Text('🌐', style: TextStyle(fontSize: 24))),
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          subtitle: Text(members, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          trailing: IconButton(
            icon: const Icon(Icons.chevron_right_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CommunityScreen()),
              );
            },
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CommunityScreen()),
            );
          },
        ),

        // Loudspeaker Announcement Channel Tile
        ListTile(
          dense: true,
          contentPadding: const EdgeInsets.only(left: 32, right: 16),
          leading: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.campaign_rounded, color: AppColors.primary, size: 20),
          ),
          title: Text(announcementText, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
          subtitle: const Text('Tap to view official announcements', style: TextStyle(fontSize: 11, color: Colors.grey)),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CommunityScreen()),
            );
          },
        ),

        // Sub-Groups List
        ...subGroups.map((g) {
          return ListTile(
            dense: true,
            contentPadding: const EdgeInsets.only(left: 32, right: 16),
            leading: CircleAvatar(
              radius: 16,
              backgroundColor: isDark ? const Color(0xFF2A3942) : Colors.grey.shade200,
              child: const Icon(Icons.groups_rounded, size: 18, color: Colors.grey),
            ),
            title: Text(g['name']!, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
            subtitle: Text(g['members']!, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(
                    targetUser: UserModel(
                      uid: 'group_${g['name'].hashCode}',
                      name: g['name']!,
                      email: '',
                      createdAt: DateTime.now(),
                    ),
                    groupChat: ChatModel(
                      chatId: 'grp_${g['name'].hashCode}',
                      participants: ['current_user', 'user_1', 'user_2'],
                      isGroup: true,
                      groupName: g['name']!,
                    ),
                  ),
                ),
              );
            },
          );
        }),

        Padding(
          padding: const EdgeInsets.only(left: 32, top: 4, bottom: 8),
          child: TextButton.icon(
            icon: const Icon(Icons.add_rounded, size: 16),
            label: const Text('Add Group to Community', style: TextStyle(fontSize: 12)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GroupCreateScreen()),
              );
            },
          ),
        ),
      ],
    );
  }
}
