import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Cloud Backup & Chat Restore Screen
class BackupSyncScreen extends StatefulWidget {
  const BackupSyncScreen({super.key});

  @override
  State<BackupSyncScreen> createState() => _BackupSyncScreenState();
}

class _BackupSyncScreenState extends State<BackupSyncScreen> {
  bool _isBackingUp = false;
  double _backupProgress = 0.0;
  String _lastBackupTime = 'Today, 04:30 AM';
  String _backupSize = '148 MB';
  String _autoBackupFrequency = 'Daily';
  bool _includeVideos = true;
  bool _endToEndEncryptedBackup = true;

  void _runBackup() {
    setState(() {
      _isBackingUp = true;
      _backupProgress = 0.0;
    });

    // Simulate progress
    Future.delayed(const Duration(milliseconds: 300), () => _updateProgress(0.25));
    Future.delayed(const Duration(milliseconds: 700), () => _updateProgress(0.60));
    Future.delayed(const Duration(milliseconds: 1100), () => _updateProgress(0.85));
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() {
        _isBackingUp = false;
        _backupProgress = 1.0;
        _lastBackupTime = 'Just now';
        _backupSize = '152 MB';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('☁️ Cloud Backup complete! Encrypted with AES-256.'),
          backgroundColor: AppColors.primary,
        ),
      );
    });
  }

  void _updateProgress(double val) {
    if (mounted) {
      setState(() {
        _backupProgress = val;
      });
    }
  }

  void _runRestore() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restore Chats from Cloud?'),
        content: Text('Restore latest backup ($_lastBackupTime, $_backupSize)? Your local messages will be updated.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All chats and media successfully restored!')),
              );
            },
            child: const Text('Restore Now', style: TextStyle(color: Colors.white)),
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
        title: const Text('Chat Backup & Cloud Sync', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.cloud_done_rounded, color: AppColors.primary, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Last Backup', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text('$_lastBackupTime • Total Size: $_backupSize', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (_isBackingUp) ...[
                    const SizedBox(height: 16),
                    LinearProgressIndicator(value: _backupProgress, color: AppColors.primaryLight),
                    const SizedBox(height: 6),
                    Text('Encrypting & uploading... ${(_backupProgress * 100).toInt()}%', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isBackingUp ? null : _runBackup,
                          icon: const Icon(Icons.backup_rounded),
                          label: const Text('Back Up Now'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton.icon(
                        onPressed: _runRestore,
                        icon: const Icon(Icons.restore_rounded),
                        label: const Text('Restore'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Text('Backup Settings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),

            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('End-to-End Encrypted Backup'),
                    subtitle: const Text('Protect your cloud backup with a custom encryption key', style: TextStyle(fontSize: 12)),
                    value: _endToEndEncryptedBackup,
                    activeColor: AppColors.primary,
                    onChanged: (val) => setState(() => _endToEndEncryptedBackup = val),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Back up to Cloud Drive'),
                    subtitle: Text('Schedule: $_autoBackupFrequency'),
                    trailing: DropdownButton<String>(
                      value: _autoBackupFrequency,
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(value: 'Daily', child: Text('Daily')),
                        DropdownMenuItem(value: 'Weekly', child: Text('Weekly')),
                        DropdownMenuItem(value: 'Monthly', child: Text('Monthly')),
                        DropdownMenuItem(value: 'Off', child: Text('Off')),
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => _autoBackupFrequency = v);
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Include Videos'),
                    subtitle: const Text('Back up video clips sent and received in chats', style: TextStyle(fontSize: 12)),
                    value: _includeVideos,
                    activeColor: AppColors.primary,
                    onChanged: (val) => setState(() => _includeVideos = val),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
