import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Linked Devices Screen (Multi-Device Sync & Web/Desktop Session Management)
class LinkedDevicesScreen extends StatefulWidget {
  const LinkedDevicesScreen({super.key});

  @override
  State<LinkedDevicesScreen> createState() => _LinkedDevicesScreenState();
}

class _LinkedDevicesScreenState extends State<LinkedDevicesScreen> {
  final List<Map<String, dynamic>> _activeDevices = [
    {
      'id': 'dev_win_01',
      'name': 'Windows 11 PC (Chrome)',
      'location': 'New Delhi, India',
      'lastActive': 'Active now',
      'isCurrent': false,
      'icon': Icons.laptop_windows_rounded,
    },
    {
      'id': 'dev_mac_02',
      'name': 'MacBook Pro (Safari Web)',
      'location': 'Mumbai, India',
      'lastActive': 'Today at 09:42 AM',
      'isCurrent': false,
      'icon': Icons.laptop_mac_rounded,
    },
    {
      'id': 'dev_tab_03',
      'name': 'iPad Pro (Universal Web App)',
      'location': 'Bengaluru, India',
      'lastActive': 'Yesterday at 07:15 PM',
      'isCurrent': false,
      'icon': Icons.tablet_mac_rounded,
    },
  ];

  void _showScanQrDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Scan QR Code'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary, width: 2),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.qr_code_scanner_rounded, size: 140, color: Colors.black87),
                  Container(
                    width: 170,
                    height: 2,
                    color: Colors.redAccent,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Visit web.universalchat.app on your desktop and scan the QR code to link.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _activeDevices.insert(0, {
                  'id': 'dev_new_${DateTime.now().millisecondsSinceEpoch}',
                  'name': 'Linux Desktop (Firefox)',
                  'location': 'Local Network',
                  'lastActive': 'Active now',
                  'isCurrent': false,
                  'icon': Icons.desktop_windows_rounded,
                });
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('New desktop session linked successfully!')),
              );
            },
            child: const Text('Simulate Scan Link', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _logoutAllDevices() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log out from all devices?'),
        content: const Text('This will instantly invalidate all active Web and Desktop sessions.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _activeDevices.clear();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logged out from all remote devices.')),
              );
            },
            child: const Text('Log Out All', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Linked Devices', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Hero graphic
            Center(
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.devices_other_rounded, size: 56, color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Use Universal Chat on Web, Desktop & Other Devices',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'All linked devices are protected by multi-device end-to-end encryption.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // Link Device Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _showScanQrDialog,
                icon: const Icon(Icons.qr_code_scanner_rounded),
                label: const Text('Link a Device (Scan QR)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),

            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Device Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                if (_activeDevices.isNotEmpty)
                  TextButton(
                    onPressed: _logoutAllDevices,
                    child: const Text('Log out from all', style: TextStyle(color: Colors.red, fontSize: 12)),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            if (_activeDevices.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                child: const Center(
                  child: Text('No active linked devices.', style: TextStyle(color: Colors.grey)),
                ),
              )
            else
              ..._activeDevices.map((dev) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.grey.shade100,
                      child: Icon(dev['icon'] as IconData, color: AppColors.primary),
                    ),
                    title: Text(dev['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text('${dev['location']} • ${dev['lastActive']}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.logout_rounded, size: 20, color: Colors.redAccent),
                      tooltip: 'Disconnect session',
                      onPressed: () {
                        setState(() {
                          _activeDevices.remove(dev);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Disconnected ${dev['name']}')),
                        );
                      },
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
