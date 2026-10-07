import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/chat_model.dart';
import '../models/call_model.dart';
import '../models/status_model.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../utils/constants.dart';
import '../utils/date_formatter.dart';
import '../widgets/chat_tile.dart';
import 'chat_screen.dart';
import 'call_screen.dart';
import 'profile_screen.dart';
import 'users_list_screen.dart';
import 'status_view_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
    int selectedColor = 0xFF005C4B;
    final colorOptions = [
      0xFF005C4B,
      0xFF128C7E,
      0xFF075E54,
      0xFF5856D6,
      0xFFFF2D55,
      0xFFFF9500,
      0xFF5856D6,
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Create Status Update',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 14),
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
                        hintText: 'Type a status...',
                        hintStyle: TextStyle(color: Colors.white70),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Background color picker
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
                  const SizedBox(height: 16),
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
                      label: const Text('Post Status', style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: () {
                        final text = textController.text.trim();
                        if (text.isEmpty) return;
                        final auth = context.read<AuthProvider>();
                        final chat = context.read<ChatProvider>();
                        final user = auth.currentUser;
                        if (user != null) {
                          chat.addStatus(
                            StatusModel(
                              statusId: 'status_${DateTime.now().millisecondsSinceEpoch}',
                              userId: user.uid,
                              userName: user.name,
                              text: text,
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
                            content: Text('Status update posted!'),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                      },
                    ),
                  ),
                ],
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
                      isVideo ? 'Start Video Call' : 'Start Voice Call',
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

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final chatProvider = context.watch<ChatProvider>();
    final currentUser = authProvider.currentUser;
    final isDevBypass = authProvider.isDevBypass;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
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
                  hintText: 'Search...',
                  hintStyle: TextStyle(color: Colors.white60),
                  border: InputBorder.none,
                ),
              )
            : Row(
                children: [
                  Text(AppConstants.appName),
                  if (isDevBypass) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade700,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'DEV BYPASS',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close_rounded : Icons.search_rounded),
            tooltip: _isSearching ? 'Close Search' : 'Search',
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _searchController.clear();
                  _searchQuery = '';
                }
                _isSearching = !_isSearching;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.people_alt_rounded),
            tooltip: 'Contacts',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UsersListScreen()),
              );
            },
          ),
          PopupMenuButton<String>(
            tooltip: 'More options',
            onSelected: (val) {
              if (val == 'settings') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              } else if (val == 'contacts') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UsersListScreen()),
                );
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
              const PopupMenuItem(
                value: 'contacts',
                child: Row(
                  children: [
                    Icon(Icons.person_add_rounded, size: 20),
                    SizedBox(width: 12),
                    Text('New Contact'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings_rounded, size: 20),
                    SizedBox(width: 12),
                    Text('Settings & Profile'),
                  ],
                ),
              ),
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
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3.0,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
          tabs: const [
            Tab(text: 'CHATS'),
            Tab(text: 'STATUS'),
            Tab(text: 'CALLS'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Developer Mode Banner if active
          if (isDevBypass)
            Container(
              width: double.infinity,
              color: Colors.amber.shade100,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              child: Row(
                children: [
                  Icon(Icons.admin_panel_settings_rounded, size: 18, color: Colors.amber.shade900),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Developer Mode Active (बाईपास चालू है): Instant real-time simulation enabled.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.amber.shade900,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // Tab views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildChatsTab(currentUser, isDevBypass, isDark),
                _buildStatusTab(currentUser, isDevBypass, isDark),
                _buildCallsTab(currentUser, isDevBypass, isDark),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFab(),
    );
  }

  // Floating Action Button corresponding to active tab
  Widget _buildFab() {
    final currentIndex = _tabController.index;
    if (currentIndex == 0) {
      // Chats Tab FAB
      return FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const UsersListScreen()),
          );
        },
        tooltip: 'New Chat',
        child: const Icon(Icons.chat_rounded),
      );
    } else if (currentIndex == 1) {
      // Status Tab FAB
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
            tooltip: 'Camera Status',
            child: const Icon(Icons.camera_alt_rounded),
          ),
        ],
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

  // 1. CHATS TAB
  Widget _buildChatsTab(UserModel currentUser, bool isDevBypass, bool isDark) {
    final chatProvider = context.watch<ChatProvider>();

    return StreamBuilder<List<ChatModel>>(
      stream: chatProvider.getRecentChatsStream(
        currentUserId: currentUser.uid,
        isDevBypass: isDevBypass,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final chats = snapshot.data ?? [];
        final filteredChats = _searchQuery.isEmpty
            ? chats
            : chats.where((c) {
                return c.lastMessage.toLowerCase().contains(_searchQuery);
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
                        ? 'No conversations yet'
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
                        ? 'Tap the chat button below to start messaging!'
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
            final otherUserId = chat.getOtherUserId(currentUser.uid);

            return ChatTile(
              chat: chat,
              onTap: () async {
                final otherUser = await chatProvider.getUserById(
                  otherUserId,
                  isDevBypass,
                );
                if (otherUser != null && context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        targetUser: otherUser,
                      ),
                    ),
                  );
                }
              },
            );
          },
        );
      },
    );
  }

  // 2. STATUS TAB
  Widget _buildStatusTab(UserModel currentUser, bool isDevBypass, bool isDark) {
    final chatProvider = context.watch<ChatProvider>();

    return StreamBuilder<List<StatusModel>>(
      stream: chatProvider.getStatusStream(isDevBypass: isDevBypass),
      builder: (context, snapshot) {
        final statuses = snapshot.data ?? [];
        final recentStatuses = statuses.where((s) => !s.isViewed).toList();
        final viewedStatuses = statuses.where((s) => s.isViewed).toList();

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

            // Recent Updates Section
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

            // Viewed Updates Section
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
    );
  }

  // 3. CALLS TAB
  Widget _buildCallsTab(UserModel currentUser, bool isDevBypass, bool isDark) {
    final chatProvider = context.watch<ChatProvider>();

    return StreamBuilder<List<CallModel>>(
      stream: chatProvider.getCallsStream(
        currentUserId: currentUser.uid,
        isDevBypass: isDevBypass,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final calls = snapshot.data ?? [];

        if (calls.isEmpty) {
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
                  'No recent calls',
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

        return ListView(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
              child: Text(
                'Recent',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
            ),
            ...calls.map((call) {
              final isMissed = call.isMissed;
              final isOutgoing = call.isOutgoing;

              // Arrow icon & color
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
                  backgroundColor: AppColors.primary,
                  child: Text(
                    call.callerName.isNotEmpty
                        ? call.callerName[0].toUpperCase()
                        : 'C',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
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
            }),
          ],
        );
      },
    );
  }
}
