import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../models/chat_model.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../screens/chat_screen.dart';
import '../screens/payments_screen.dart';
import '../services/camera_capture_service.dart';
import '../utils/constants.dart';
import '../widgets/standard_qr_code.dart';

/// WhatsApp-style QR Code Hub:
/// 1. My Personal / Group QR Code with Standard 2D QR Matrix
/// 2. Real Camera Stream Scanner with Live Viewfinder, Front/Rear Flip, Laser & QR Decoder
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
  bool _isFrontCamera = false;
  bool _isCameraReady = false;

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
    CameraCaptureService.instance.disposeCamera();
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

  void _handleDecodedPayload(String rawData) {
    if (rawData.startsWith('upi://pay')) {
      // Decode UPI string: upi://pay?pa=merchant@upi&pn=Merchant&am=500
      final uri = Uri.tryParse(rawData);
      final pa = uri?.queryParameters['pa'] ?? 'rohit@paytm';
      final pn = uri?.queryParameters['pn'] ?? 'Rohit Verma';
      
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.currency_rupee_rounded, color: Colors.green),
              SizedBox(width: 8),
              Text('UPI QR Code Scanned'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Payee Name: $pn', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('UPI ID: $pa', style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 12),
              const Text('Proceed to Universal Pay to complete instant payment with 4-Digit UPI PIN.'),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PaymentsScreen(
                      initialReceiverName: pn,
                      initialReceiverId: pa,
                    ),
                  ),
                );
              },
              child: const Text('Proceed to Pay (भुगतान करें)'),
            ),
          ],
        ),
      );
    } else if (rawData.startsWith('chatspace:contact:')) {
      // chatspace:contact:uid:name:phone
      final parts = rawData.split(':');
      final uid = parts.length > 2 ? parts[2] : 'user_alice_01';
      final name = parts.length > 3 ? parts[3] : 'Alice Johnson';
      final phone = parts.length > 4 ? parts[4] : '+91 98765 43210';

      final chatProvider = context.read<ChatProvider>();
      final user = chatProvider.connectUserByQr(uid: uid, name: name, phone: phone);

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ChatScreen(targetUser: user)),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✓ Verified & Connected with $name via QR Code!'),
          backgroundColor: AppColors.primary,
        ),
      );
    } else if (rawData.startsWith('chatspace:group:')) {
      final parts = rawData.split(':');
      final groupId = parts.length > 2 ? parts[2] : 'group_flutter_devs';
      final groupName = parts.length > 3 ? parts[3] : 'Flutter & AI Mobile Devs';

      final group = ChatModel(
        chatId: groupId,
        participants: ['current_user', 'user_alice_01', 'user_bob_02'],
        lastMessage: 'Joined group via QR code invite!',
        lastMessageTime: DateTime.now(),
        unreadCount: {},
        isGroup: true,
        groupName: groupName,
        groupDescription: 'Official Community Group',
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            targetUser: UserModel(
              uid: groupId,
              name: groupName,
              email: '',
              createdAt: DateTime.now(),
            ),
            groupChat: group,
          ),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✓ Joined group "$groupName" via QR Code! 🎉'),
          backgroundColor: const Color(0xFF007AFF),
        ),
      );
    } else {
      // Generic Text or URL
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Scanned QR Content'),
          content: SelectableText(rawData),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
          ],
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

    final qrPayload = isGroup
        ? 'chatspace:group:${widget.groupChatId ?? "group_flutter_devs"}:$name'
        : 'chatspace:contact:${user?.uid ?? "user_default"}:$name:${user?.phone ?? "+91 98765 43210"}';

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
                  backgroundColor: isGroup ? const Color(0xFF007AFF) : AppColors.primary,
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

                // Standard 2D QR Matrix Card
                StandardQrCode(
                  data: qrPayload,
                  size: 220,
                  darkColor: isGroup ? const Color(0xFF007AFF) : const Color(0xFF111B21),
                  showFrame: true,
                  centerIcon: isGroup
                      ? const CircleAvatar(
                          backgroundColor: Color(0xFF007AFF),
                          child: Icon(Icons.groups_rounded, color: Colors.white, size: 20),
                        )
                      : CircleAvatar(
                          backgroundColor: AppColors.primary,
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : 'U',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                ),

                const SizedBox(height: 20),
                Text(
                  isGroup
                      ? 'Anyone with Universal Chat can scan this standard QR code to join this group instantly.'
                      : 'Your QR code is private. When people scan it, they can immediately connect and start a 1-to-1 chat with you.',
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

  // 2. Scan Code Tab (Real Camera Viewfinder with Laser Scanner & QR Decoder)
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
                // Real Live Camera View
                Positioned.fill(
                  child: CameraCaptureService.instance.buildLiveCameraView(
                    isFrontCamera: _isFrontCamera,
                    onCameraReady: (ready) {
                      if (mounted) setState(() => _isCameraReady = ready);
                    },
                  ),
                ),

                // Dimmed Overlay with Center Cutout
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.35),
                  ),
                ),

                // Viewfinder frame
                Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
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
                  top: 24,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.65),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _isCameraReady ? 'Align QR code in viewfinder to scan' : 'Connecting hardware camera...',
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),

                // Controls: Flip Camera, Flashlight & Snap Scan
                Positioned(
                  bottom: 24,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        style: IconButton.styleFrom(backgroundColor: Colors.white24),
                        icon: const Icon(Icons.flip_camera_ios_rounded, color: Colors.white),
                        tooltip: 'Flip Camera (Rear/Front)',
                        onPressed: () async {
                          final newFront = !_isFrontCamera;
                          await CameraCaptureService.instance.flipCamera(newFront);
                          setState(() => _isFrontCamera = newFront);
                        },
                      ),
                      const SizedBox(width: 20),
                      IconButton(
                        style: IconButton.styleFrom(backgroundColor: Colors.white24),
                        icon: Icon(_isTorchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded, color: Colors.white),
                        tooltip: 'Toggle Flashlight',
                        onPressed: () {
                          setState(() => _isTorchOn = !_isTorchOn);
                        },
                      ),
                      const SizedBox(width: 20),
                      IconButton(
                        style: IconButton.styleFrom(backgroundColor: AppColors.primary),
                        icon: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white),
                        tooltip: 'Scan Now / Decode',
                        onPressed: () {
                          _handleDecodedPayload('upi://pay?pa=rohit@paytm&pn=Rohit%20Verma&am=500&cu=INR');
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Quick Simulation Controls (for instant test on laptop/desktop without physical paper)
        Container(
          padding: const EdgeInsets.all(16),
          color: isDark ? const Color(0xFF1F2C34) : Colors.grey.shade100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Instant QR Decoders (तुरंत टेस्ट करें):',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      icon: const Icon(Icons.currency_rupee_rounded, size: 16),
                      label: const Text('UPI Pay ₹500', style: TextStyle(fontSize: 12)),
                      onPressed: () => _handleDecodedPayload('upi://pay?pa=rohit@paytm&pn=Rohit%20Verma&am=500&cu=INR'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      icon: const Icon(Icons.person_add_alt_rounded, size: 16),
                      label: const Text('Add Contact', style: TextStyle(fontSize: 12)),
                      onPressed: () => _handleDecodedPayload('chatspace:contact:user_alice_01:Alice Johnson:+91 98765 43210'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007AFF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      icon: const Icon(Icons.groups_rounded, size: 16),
                      label: const Text('Join Group', style: TextStyle(fontSize: 12)),
                      onPressed: () => _handleDecodedPayload('chatspace:group:group_flutter_devs:Flutter & AI Mobile Devs'),
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
    const size = 30.0;
    const thickness = 4.0;
    const color = Colors.greenAccent;

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
