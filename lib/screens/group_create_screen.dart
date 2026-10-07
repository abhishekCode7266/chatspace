import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../utils/constants.dart';
import 'chat_screen.dart';

class GroupCreateScreen extends StatefulWidget {
  const GroupCreateScreen({super.key});

  @override
  State<GroupCreateScreen> createState() => _GroupCreateScreenState();
}

class _GroupCreateScreenState extends State<GroupCreateScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final Set<String> _selectedUserIds = {};
  bool _isCreating = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _handleCreateGroup() async {
    final groupName = _nameController.text.trim();
    if (groupName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a group name'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (_selectedUserIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one participant'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      _isCreating = true;
    });

    final authProvider = context.read<AuthProvider>();
    final chatProvider = context.read<ChatProvider>();
    final currentUserId = authProvider.currentUser?.uid ?? '';

    final group = await chatProvider.createGroup(
      groupName: groupName,
      groupDescription: _descController.text.trim().isEmpty
          ? 'Universal Chat Group'
          : _descController.text.trim(),
      participantIds: _selectedUserIds.toList(),
      adminId: currentUserId,
      isDevBypass: authProvider.isDevBypass,
    );

    if (mounted) {
      setState(() {
        _isCreating = false;
      });
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            targetUser: UserModel(
              uid: group.chatId,
              name: group.groupName ?? 'Group',
              email: '',
              status: group.groupDescription ?? '',
              createdAt: DateTime.now(),
            ),
            groupChat: group,
          ),
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

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('New Group', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(
              '${_selectedUserIds.length} participant(s) selected',
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Group Details Section
          Container(
            padding: const EdgeInsets.all(16),
            color: isDark ? const Color(0xFF1F2C34) : Colors.white,
            child: Row(
              children: [
                // Group Avatar Icon
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: const Color(0xFF007AFF).withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: Color(0xFF007AFF), size: 26),
                ),
                const SizedBox(width: 14),
                // Group Name and Desc Input
                Expanded(
                  child: Column(
                    children: [
                      TextField(
                        controller: _nameController,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        decoration: const InputDecoration(
                          hintText: 'Group Subject / Name',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const Divider(height: 1),
                      TextField(
                        controller: _descController,
                        style: const TextStyle(fontSize: 13),
                        decoration: const InputDecoration(
                          hintText: 'Group Description (optional)',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(top: 4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  'Select Participants',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),

          // Contacts List
          Expanded(
            child: StreamBuilder<List<UserModel>>(
              stream: chatProvider.getUsersStream(
                currentUserId: currentUserId,
                isDevBypass: isDevBypass,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final users = snapshot.data ?? [];
                if (users.isEmpty) {
                  return const Center(child: Text('No contacts found'));
                }

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final isSelected = _selectedUserIds.contains(user.uid);

                    return CheckboxListTile(
                      value: isSelected,
                      activeColor: AppColors.primary,
                      onChanged: (checked) {
                        setState(() {
                          if (checked == true) {
                            _selectedUserIds.add(user.uid);
                          } else {
                            _selectedUserIds.remove(user.uid);
                          }
                        });
                      },
                      secondary: CircleAvatar(
                        backgroundColor: AppColors.primary,
                        child: Text(
                          user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(user.status, maxLines: 1, overflow: TextOverflow.ellipsis),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isCreating ? null : _handleCreateGroup,
        tooltip: 'Create Group',
        backgroundColor: AppColors.primary,
        child: _isCreating
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : const Icon(Icons.check_rounded, color: Colors.white),
      ),
    );
  }
}
