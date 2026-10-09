import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../utils/constants.dart';
import 'chat_screen.dart';
import 'group_create_screen.dart';
import 'qr_code_share_screen.dart';

class UsersListScreen extends StatefulWidget {
  const UsersListScreen({super.key});

  @override
  State<UsersListScreen> createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UsersListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _contactsPermissionGranted = false;
  bool _hasAskedPermission = false;

  @override
  void initState() {
    super.initState();
    _checkContactsPermission();
  }

  Future<void> _checkContactsPermission() async {
    final prefs = await SharedPreferences.getInstance();
    final asked = prefs.getBool('contacts_permission_asked') ?? false;
    final granted = prefs.getBool('contacts_permission_granted') ?? false;

    setState(() {
      _hasAskedPermission = asked;
      _contactsPermissionGranted = granted;
    });

    if (!asked && mounted) {
      // Prompt user on first access
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _promptContactsPermission();
      });
    }
  }

  void _promptContactsPermission() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: const CircleAvatar(
          radius: 28,
          backgroundColor: Color(0xFFE8F5E9),
          child: Icon(Icons.contacts_rounded, color: AppColors.primary, size: 30),
        ),
        title: const Text(
          'Allow Universal Chat to access contacts?',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        content: const Text(
          'Universal Chat uses your contacts to find friends who are already using the app, synchronize your address book, and allow direct contact messaging. Your contacts stay private and safe.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: Colors.grey, height: 1.4),
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('contacts_permission_asked', true);
              await prefs.setBool('contacts_permission_granted', false);
              setState(() {
                _hasAskedPermission = true;
                _contactsPermissionGranted = false;
              });
            },
            child: const Text('Don\'t Allow', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('contacts_permission_asked', true);
              await prefs.setBool('contacts_permission_granted', true);
              setState(() {
                _hasAskedPermission = true;
                _contactsPermissionGranted = true;
              });
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✓ Contacts permission granted! Address book synced.'),
                    backgroundColor: AppColors.primary,
                  ),
                );
              }
            },
            child: const Text('Allow Access (अनुमति दें)'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddByMobileDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.person_add_alt_1_rounded, color: AppColors.primary),
            SizedBox(width: 10),
            Text('Add by Mobile Number', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter 10-digit mobile number to connect and start 1-to-1 chat instantly:',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Contact Name',
                  hintText: 'e.g. Rahul Sharma',
                  prefixIcon: Icon(Icons.badge_rounded, size: 20),
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                decoration: const InputDecoration(
                  labelText: '10-Digit Mobile Number',
                  prefixText: '+91 ',
                  prefixIcon: Icon(Icons.phone_android_rounded, size: 20),
                  border: OutlineInputBorder(),
                  isDense: true,
                  counterText: '',
                ),
                validator: (v) {
                  if (v == null || v.trim().length != 10) {
                    return 'Enter valid 10-digit number';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                final chatProvider = context.read<ChatProvider>();
                final name = nameCtrl.text.trim();
                final phone = phoneCtrl.text.trim();

                final newUser = chatProvider.addContactByPhone(
                  name: name,
                  phone: '+91 $phone',
                  status: 'Hey there! I am using Universal Chat.',
                );

                Navigator.pop(ctx);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(targetUser: newUser),
                  ),
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('✓ Connected with $name (+91 $phone)!'),
                    backgroundColor: AppColors.primary,
                  ),
                );
              }
            },
            child: const Text('Add & Chat'),
          ),
        ],
      ),
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
        title: const Text('Select Contact (संपर्क चुनें)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner_rounded),
            tooltip: 'Scan QR Code',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const QrCodeShareScreen(initialTabIndex: 1)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_rounded),
            tooltip: 'Add by Phone Number',
            onPressed: () => _showAddByMobileDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Permission Status Banner
          if (!_contactsPermissionGranted && _hasAskedPermission)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.contacts_outlined, color: Colors.amber.shade800, size: 20),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Contacts permission not granted. You can still add by phone number.',
                      style: TextStyle(fontSize: 12, color: Colors.black87),
                    ),
                  ),
                  TextButton(
                    onPressed: _promptContactsPermission,
                    child: const Text('Grant', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              ),
            )
          else if (_contactsPermissionGranted)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 6, 16, 2),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: const [
                  Icon(Icons.check_circle_rounded, color: Colors.green, size: 14),
                  SizedBox(width: 6),
                  Text('Address Book Synced • Contacts Permission Active', style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.w600)),
                ],
              ),
            ),

          // Search contact field
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.trim().toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search contacts by name or phone...',
                prefixIcon: const Icon(Icons.search_rounded, size: 22),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                filled: true,
                fillColor: isDark ? AppColors.darkSurface : Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Quick Action Tiles
          if (_searchQuery.isEmpty) ...[
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFF007AFF),
                child: Icon(Icons.group_add_rounded, color: Colors.white, size: 22),
              ),
              title: const Text('New Group (नया ग्रुप)', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Group chat with friends and colleagues'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const GroupCreateScreen()));
              },
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFF25D366),
                child: Icon(Icons.phone_android_rounded, color: Colors.white, size: 22),
              ),
              title: const Text('Add by Mobile Number (नंबर से जोड़ें)', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Directly enter +91 mobile number to chat'),
              onTap: () => _showAddByMobileDialog(context),
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFF9C27B0),
                child: Icon(Icons.qr_code_2_rounded, color: Colors.white, size: 22),
              ),
              title: const Text('My Contact QR Code (मेरा क्यूआर कोड)', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Share your private QR code to connect'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const QrCodeShareScreen(initialTabIndex: 0)));
              },
            ),
            const Divider(height: 1),
          ],

          // Stream of users
          Expanded(
            child: StreamBuilder<List<UserModel>>(
              stream: chatProvider.getUsersStream(
                currentUserId: currentUser.uid,
                isDevBypass: isDevBypass,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading users: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                final users = snapshot.data ?? [];

                final filteredUsers = _searchQuery.isEmpty
                    ? users
                    : users.where((u) {
                        final phone = u.phone ?? '';
                        return u.name.toLowerCase().contains(_searchQuery) ||
                            u.status.toLowerCase().contains(_searchQuery) ||
                            phone.contains(_searchQuery);
                      }).toList();

                if (filteredUsers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_search_rounded,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'No other contacts found'
                              : 'No contacts match "$_searchQuery"',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(Icons.person_add_alt_1_rounded),
                          label: const Text('Add by Mobile Number'),
                          onPressed: () => _showAddByMobileDialog(context),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: filteredUsers.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    indent: 76,
                    color: isDark ? Colors.white10 : Colors.grey.shade200,
                  ),
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    return ListTile(
                      leading: Stack(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: AppColors.primary,
                            child: Text(
                              user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          if (user.isOnline)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isDark ? const Color(0xFF1F2C34) : Colors.white,
                                    width: 2.5,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      title: Text(
                        user.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: Text(
                        user.phone != null ? '${user.phone} • ${user.status}' : user.status,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.primary),
                        tooltip: 'Start Chat',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(targetUser: user),
                            ),
                          );
                        },
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatScreen(targetUser: user),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
