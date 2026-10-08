import 'package:flutter/material.dart';
import '../services/security_service.dart';
import '../utils/constants.dart';
import 'app_lock_screen.dart';

/// Privacy & Security Management Screen
class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  String _lastSeenPrivacy = 'Everyone';
  String _profilePhotoPrivacy = 'My Contacts';
  String _statusPrivacy = 'My Contacts';
  bool _readReceipts = true;
  String _disappearingDefault = 'Off';
  bool _twoStepVerification = true;
  bool _biometricLock = true;
  bool _pinLockEnabled = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final blockedUsers = SecurityService.instance.blockedUserIds;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy & Security', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // Security Header Banner
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryDark.withOpacity(0.3),
                  AppColors.primary.withOpacity(0.15),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withOpacity(0.4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.security_rounded, color: AppColors.primaryLight, size: 36),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Military-Grade Encryption Active', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      SizedBox(height: 2),
                      Text('AES-256 GCM cryptographically seals all messages, voice & video calls.', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),
          _buildSectionHeader('Privacy Controls'),

          ListTile(
            title: const Text('Last Seen & Online'),
            subtitle: Text(_lastSeenPrivacy),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _showPicker(
              'Last Seen & Online',
              ['Everyone', 'My Contacts', 'Nobody'],
              _lastSeenPrivacy,
              (v) => setState(() => _lastSeenPrivacy = v),
            ),
          ),
          ListTile(
            title: const Text('Profile Photo'),
            subtitle: Text(_profilePhotoPrivacy),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _showPicker(
              'Profile Photo',
              ['Everyone', 'My Contacts', 'Nobody'],
              _profilePhotoPrivacy,
              (v) => setState(() => _profilePhotoPrivacy = v),
            ),
          ),
          ListTile(
            title: const Text('Status Stories Privacy'),
            subtitle: Text(_statusPrivacy),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _showPicker(
              'Status Privacy',
              ['My Contacts', 'My Contacts Except...', 'Only Share With...'],
              _statusPrivacy,
              (v) => setState(() => _statusPrivacy = v),
            ),
          ),
          SwitchListTile(
            title: const Text('Read Receipts'),
            subtitle: const Text('If turned off, you won\'t send or receive read receipts (blue ticks)', style: TextStyle(fontSize: 12)),
            value: _readReceipts,
            activeColor: AppColors.primary,
            onChanged: (val) => setState(() => _readReceipts = val),
          ),
          ListTile(
            title: const Text('Default Message Timer'),
            subtitle: Text('Disappearing messages: $_disappearingDefault'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _showPicker(
              'Default Disappearing Timer',
              ['24 Hours', '7 Days', '90 Days', 'Off'],
              _disappearingDefault,
              (v) => setState(() => _disappearingDefault = v),
            ),
          ),

          const Divider(),
          _buildSectionHeader('Security & App Lock'),

          SwitchListTile(
            title: const Text('App Lock (4-Digit PIN)'),
            subtitle: const Text('Require 4-digit PIN to unlock Universal Chat on launch', style: TextStyle(fontSize: 12)),
            value: _pinLockEnabled,
            activeColor: AppColors.primary,
            onChanged: (val) => setState(() => _pinLockEnabled = val),
          ),
          SwitchListTile(
            title: const Text('Biometric / Fingerprint Unlock'),
            subtitle: const Text('Use fingerprint or Face ID to open app instantly', style: TextStyle(fontSize: 12)),
            value: _biometricLock,
            activeColor: AppColors.primary,
            onChanged: (val) => setState(() => _biometricLock = val),
          ),
          SwitchListTile(
            title: const Text('Two-Step Verification (2FA)'),
            subtitle: const Text('Extra 6-digit PIN required when registering your phone number', style: TextStyle(fontSize: 12)),
            value: _twoStepVerification,
            activeColor: AppColors.primary,
            onChanged: (val) => setState(() => _twoStepVerification = val),
          ),
          ListTile(
            leading: const Icon(Icons.lock_reset_rounded, color: AppColors.primary),
            title: const Text('Change Security PIN'),
            subtitle: const Text('Default PIN is 1234'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AppLockScreen(
                    onUnlocked: () => Navigator.pop(context),
                  ),
                ),
              );
            },
          ),

          const Divider(),
          _buildSectionHeader('Blocked Contacts'),

          ListTile(
            leading: const Icon(Icons.block_rounded, color: Colors.redAccent),
            title: const Text('Blocked Users'),
            subtitle: Text('${blockedUsers.length} contacts blocked'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              _showBlockedUsersDialog(blockedUsers);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AppColors.primaryLight,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  void _showPicker(String title, List<String> options, String current, Function(String) onSelect) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            ...options.map((opt) => RadioListTile<String>(
                  title: Text(opt),
                  value: opt,
                  groupValue: current,
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    if (val != null) {
                      onSelect(val);
                      Navigator.pop(ctx);
                    }
                  },
                )),
          ],
        ),
      ),
    );
  }

  void _showBlockedUsersDialog(Set<String> blockedUsers) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Blocked Contacts'),
        content: blockedUsers.isEmpty
            ? const Text('You have not blocked any contacts.')
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: blockedUsers
                    .map((id) => ListTile(
                          title: Text(id),
                          trailing: TextButton(
                            onPressed: () {
                              SecurityService.instance.unblockUser(id);
                              setState(() {});
                              Navigator.pop(ctx);
                            },
                            child: const Text('Unblock', style: TextStyle(color: Colors.red)),
                          ),
                        ))
                    .toList(),
              ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }
}
