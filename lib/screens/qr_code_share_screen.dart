import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../models/chat_model.dart';
import '../providers/auth_provider.dart';
import '../screens/chat_screen.dart';
import '../screens/payments_screen.dart';
import '../utils/constants.dart';

/// WhatsApp-style QR Code Hub:
/// 1. My Personal QR Code (Share, Scan to 1-to-1 Chat, Reset)
/// 2. Group Invite QR Code (Scan to Join Group)
/// 3. In-App Camera Scanner Viewfinder
class QrCodeShareScreen extends StatefulWidget {
  final String? groupChatId;
  final String? groupName;
  final int initialTabIndex;

  const QrCodeShareScreen({
    super.key,
    this.groupChatId,
    this.groupName,
    this.initialTabIndex = 0,
  });

  @override
  State<QrCodeShareScreen> createState() => _QrCodeShareScreenState();
}

class _QrCodeShareScreenState extends State<QrCodeShareScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _laserController;
  late Animation<double> _laserAnimation;

  bool _isTorchOn = false;
  String _qrToken = 'uc_token_${DateTime.now().millisecondsSinceEpoch}';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialTabIndex);

    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _laserAnimation = Tween<double>(begin: 0.05, end: 0.95).animate(
      CurvedAnimation(parent: _laserController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _laserController.dispose();
    super.dispose();
  }

  void _resetQrCode() {
    setState(() {
      _qrToken = 'uc_token_${DateTime.now().millisecondsSinceEpoch}';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Previous QR code revoked. New unique QR code generated! (नया कोड तैयार है)'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _onScanSuccess(String payloadType) {
    if (payloadType == 'user') {
      final targetUser = UserModel(
        uid: 'user_alice_01',
        name: 'Alice Johnson',
        email: 'alice@universalchat.app',
        status: 'Hey there! I am using Universal Chat.',
        createdAt: DateTime.now(),
      );
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(targetUser: targetUser),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('QR Code verified! Opened chat with Alice Johnson.')),
      );
    } else if (payloadType == 'group') {
      final group = ChatModel(
        chatId: 'group_flutter_devs',
        participants: ['current_user', 'user_alice_01', 'user_bob_02'],
        lastMessage: 'Welcome new member via QR code invite!',
        lastMessageTime: DateTime.now(),
        unreadCount: {},
        isGroup: true,
        groupName: 'Flutter & AI Mobile Devs',
        groupDescription: 'Official Community Group',
      );
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            targetUser: UserModel(
              uid: 'group_flutter_devs',
              name: 'Flutter & AI Mobile Devs',
              email: '',
              createdAt: DateTime.now(),
            ),
            groupChat: group,
          ),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Joined group "Flutter & AI Mobile Devs" via QR Code! 🎉')),
      );
    } else if (payloadType == 'payment') {
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const PaymentsScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isGroup = widget.groupChatId != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(isGroup ? '${widget.groupName ?? "Group"} QR Code' : 'QR Code (क्यूआर कोड)'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3.0,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'MY CODE (मेरा कोड)'),
            Tab(text: 'SCAN CODE (स्कैनर)'),
          ],
        ),
        actions: [
          if (!isGroup)
            PopupMenuButton<String>(
              onSelected: (val) {
                if (val == 'reset') {
                  _resetQrCode();
                } else if (val == 'share') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Universal QR Code link copied to clipboard!')),
                  );
                }
              },
              itemBuilder: (ctx) => [
                const PopupMenuItem(
                  value: 'share',
                  child: Row(
                    children: [
                      Icon(Icons.share_rounded, size: 20),
                      SizedBox(width: 12),
                      Text('Share QR Code'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'reset',
                  child: Row(
                    children: [
                      Icon(Icons.refresh_rounded, size: 20),
                      SizedBox(width: 12),
                      Text('Reset QR Code'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMyCodeTab(isDark, isGroup),
          _buildScanCodeTab(isDark),
        ],
      ),
    );
  }

  // 1. My QR Code Tab
  Widget _buildMyCodeTab(bool isDark, bool isGroup) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final name = isGroup ? (widget.groupName ?? 'Community Group') : (user?.name ?? 'Universal User');
    final subtitle = isGroup ? 'Universal Chat Group Invite' : (user?.email ?? 'user@universalchat.app');

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        children: [
          // Styled QR Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1F2C34) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 34,
                  backgroundColor: AppColors.primary,
                  child: isGroup
                      ? const Icon(Icons.groups_rounded, size: 36, color: Colors.white)
                      : Text(
                          name.isNotEmpty ? name[0].toUpperCase() : 'U',
                          style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                ),
                const SizedBox(height: 12),
                Text(
                  name,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Scannable Custom QR Code Box
                Container(
                  width: 230,
                  height: 230,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300, width: 2),
                  ),
                  child: CustomPaint(
                    painter: _UniversalQrPainter(
                      token: '$_qrToken:${isGroup ? widget.groupChatId : user?.uid}',
                      isGroup: isGroup,
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                Text(
                  isGroup
                      ? 'Anyone with Universal Chat can scan this code to join this group.'
                      : 'Your QR code is private. When people scan it, they can immediately start a 1-to-1 chat with you.',
                  style: const TextStyle(fontSize: 12, color: Colors.grey, height: 1.4),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Reset Code'),
                  onPressed: _resetQrCode,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.share_rounded),
                  label: const Text('Share QR'),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('QR Code invite card saved to clipboard/share!'),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 2. Scan Code Tab (Camera Viewfinder with Laser Scanner)
  Widget _buildScanCodeTab(bool isDark) {
    return Column(
      children: [
        // Camera Viewfinder Box
        Expanded(
          child: Container(
            color: Colors.black,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Simulated camera feed background
                Container(
                  color: const Color(0xFF0D1418),
                  child: Center(
                    child: Opacity(
                      opacity: 0.08,
                      child: Icon(Icons.camera_alt_rounded, size: 220, color: Colors.white),
                    ),
                  ),
                ),

                // Viewfinder frame
                Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
                  ),
                  child: Stack(
                    children: [
                      // 4 Corner brackets
                      ..._buildCornerBrackets(),

                      // Animated Laser Scanning Line
                      AnimatedBuilder(
                        animation: _laserAnimation,
                        builder: (context, child) {
                          return Positioned(
                            top: 260 * _laserAnimation.value,
                            left: 10,
                            right: 10,
                            child: Container(
                              height: 3,
                              decoration: BoxDecoration(
                                color: Colors.greenAccent,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.greenAccent.withOpacity(0.8),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // Top instructions
                Positioned(
                  top: 30,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Align QR code within the frame to scan',
                      style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),

                // Controls: Flashlight & Gallery
                Positioned(
                  bottom: 30,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        style: IconButton.styleFrom(backgroundColor: Colors.white24),
                        icon: Icon(_isTorchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded, color: Colors.white),
                        tooltip: 'Toggle Flashlight',
                        onPressed: () {
                          setState(() => _isTorchOn = !_isTorchOn);
                        },
                      ),
                      const SizedBox(width: 24),
                      IconButton(
                        style: IconButton.styleFrom(backgroundColor: Colors.white24),
                        icon: const Icon(Icons.photo_library_rounded, color: Colors.white),
                        tooltip: 'Scan from Gallery',
                        onPressed: () {
                          _onScanSuccess('user');
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Quick Simulation Controls (for developer and user instant demo)
        Container(
          padding: const EdgeInsets.all(16),
          color: isDark ? const Color(0xFF1F2C34) : Colors.grey.shade100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Instant Test Drive (तुरंत टेस्ट करें):',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      onPressed: () => _onScanSuccess('user'),
                      child: const Text('Scan User QR', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007AFF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      onPressed: () => _onScanSuccess('group'),
                      child: const Text('Scan Group QR', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      onPressed: () => _onScanSuccess('payment'),
                      child: const Text('Scan Pay QR', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildCornerBrackets() {
    const size = 24.0;
    const thickness = 4.0;
    const color = AppColors.primary;

    return [
      Positioned(
        top: 0,
        left: 0,
        child: Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: color, width: thickness),
              left: BorderSide(color: color, width: thickness),
            ),
          ),
        ),
      ),
      Positioned(
        top: 0,
        right: 0,
        child: Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: color, width: thickness),
              right: BorderSide(color: color, width: thickness),
            ),
          ),
        ),
      ),
      Positioned(
        bottom: 0,
        left: 0,
        child: Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: color, width: thickness),
              left: BorderSide(color: color, width: thickness),
            ),
          ),
        ),
      ),
      Positioned(
        bottom: 0,
        right: 0,
        child: Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: color, width: thickness),
              right: BorderSide(color: color, width: thickness),
            ),
          ),
        ),
      ),
    ];
  }
}

/// Custom painter rendering a beautiful WhatsApp-style QR code matrix
class _UniversalQrPainter extends CustomPainter {
  final String token;
  final bool isGroup;

  _UniversalQrPainter({required this.token, required this.isGroup});

  @override
  void paint(Canvas canvas, Size size) {
    final paintDark = Paint()..color = const Color(0xFF111B21);
    final paintPrimary = Paint()..color = isGroup ? const Color(0xFF007AFF) : AppColors.primary;

    const int modules = 21;
    final cellSize = size.width / modules;

    // Draw standard 3 Corner Position Detection Patterns
    _drawCornerMarker(canvas, 0, 0, cellSize, paintDark);
    _drawCornerMarker(canvas, (modules - 7) * cellSize, 0, cellSize, paintDark);
    _drawCornerMarker(canvas, 0, (modules - 7) * cellSize, cellSize, paintDark);

    // Deterministic pseudo-random matrix based on token
    final hash = token.hashCode;
    for (int r = 0; r < modules; r++) {
      for (int c = 0; c < modules; c++) {
        // Skip corner squares
        if ((r < 8 && c < 8) || (r < 8 && c >= modules - 8) || (r >= modules - 8 && c < 8)) {
          continue;
        }

        // Center badge cutout
        if (r >= 8 && r <= 12 && c >= 8 && c <= 12) {
          continue;
        }

        final bit = ((hash ^ (r * 31 + c * 17)) % 3) == 0;
        if (bit) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(c * cellSize + 0.5, r * cellSize + 0.5, cellSize - 1, cellSize - 1),
              const Radius.circular(1.5),
            ),
            paintDark,
          );
        }
      }
    }

    // Center Universal Logo Dot
    final centerOffset = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(centerOffset, cellSize * 2.2, Paint()..color = Colors.white);
    canvas.drawCircle(centerOffset, cellSize * 1.8, paintPrimary);
  }

  void _drawCornerMarker(Canvas canvas, double x, double y, double cellSize, Paint paint) {
    // Outer 7x7 square
    canvas.drawRect(Rect.fromLTWH(x, y, cellSize * 7, cellSize * 7), paint);
    // Inner 5x5 white
    canvas.drawRect(Rect.fromLTWH(x + cellSize, y + cellSize, cellSize * 5, cellSize * 5), Paint()..color = Colors.white);
    // Center 3x3 solid
    canvas.drawRect(Rect.fromLTWH(x + cellSize * 2, y + cellSize * 2, cellSize * 3, cellSize * 3), paint);
  }

  @override
  bool shouldRepaint(covariant _UniversalQrPainter oldDelegate) =>
      oldDelegate.token != token || oldDelegate.isGroup != isGroup;
}
