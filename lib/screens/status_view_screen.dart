import 'package:flutter/material.dart';
import '../models/status_model.dart';
import '../utils/date_formatter.dart';

class StatusViewScreen extends StatefulWidget {
  final StatusModel status;
  final VoidCallback? onStatusCompleted;

  const StatusViewScreen({
    super.key,
    required this.status,
    this.onStatusCompleted,
  });

  @override
  State<StatusViewScreen> createState() => _StatusViewScreenState();
}

class _StatusViewScreenState extends State<StatusViewScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  final TextEditingController _replyController = TextEditingController();
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onStatusCompleted?.call();
        if (mounted) {
          Navigator.pop(context);
        }
      }
    });

    _progressController.forward();
  }

  @override
  void dispose() {
    _progressController.dispose();
    _replyController.dispose();
    super.dispose();
  }

  void _pause() {
    if (!_isPaused) {
      _progressController.stop();
      _isPaused = true;
    }
  }

  void _resume() {
    if (_isPaused) {
      _progressController.forward();
      _isPaused = false;
    }
  }

  void _sendReply() {
    final text = _replyController.text.trim();
    if (text.isEmpty) return;
    _replyController.clear();
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reply sent to ${widget.status.userName}!'),
        backgroundColor: const Color(0xFF00A884),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = Color(widget.status.backgroundColorHex);

    return Scaffold(
      backgroundColor: bgColor,
      body: GestureDetector(
        onTapDown: (_) => _pause(),
        onTapUp: (_) => _resume(),
        onTapCancel: () => _resume(),
        child: SafeArea(
          child: Stack(
            children: [
              // Status Content (Photo, Video, Link, or Text)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Builder(
                    builder: (context) {
                      final isPhoto = widget.status.statusType == 'photo' ||
                          (widget.status.mediaUrl != null &&
                              (widget.status.mediaUrl!.contains('.jpg') ||
                                  widget.status.mediaUrl!.contains('.png') ||
                                  widget.status.mediaUrl!.contains('.jpeg') ||
                                  widget.status.mediaUrl!.contains('images.unsplash.com')));
                      final isVideo = widget.status.statusType == 'video';
                      final text = widget.status.text;
                      final hasUrl = text.contains('http://') || text.contains('https://');

                      if (isPhoto && widget.status.mediaUrl != null) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                constraints: const BoxConstraints(maxHeight: 460),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: Colors.black26,
                                ),
                                child: Image.network(
                                  widget.status.mediaUrl!,
                                  fit: BoxFit.contain,
                                  loadingBuilder: (ctx, child, progress) {
                                    if (progress == null) return child;
                                    return const Padding(
                                      padding: EdgeInsets.all(40),
                                      child: CircularProgressIndicator(color: Colors.white),
                                    );
                                  },
                                  errorBuilder: (ctx, err, stack) => const Padding(
                                    padding: EdgeInsets.all(40),
                                    child: Icon(Icons.broken_image_rounded, color: Colors.white70, size: 48),
                                  ),
                                ),
                              ),
                            ),
                            if (widget.status.caption != null && widget.status.caption!.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  widget.status.caption!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ] else if (widget.status.text.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  widget.status.text,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ],
                        );
                      }

                      if (isVideo) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              constraints: const BoxConstraints(maxHeight: 420),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.black45,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white24, width: 1.5),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.redAccent,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Row(
                                          children: [
                                            Icon(Icons.videocam_rounded, color: Colors.white, size: 14),
                                            SizedBox(width: 4),
                                            Text('SHORT VIDEO • 0:15', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  Container(
                                    width: 72,
                                    height: 72,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withOpacity(0.2),
                                      border: Border.all(color: Colors.white, width: 2),
                                    ),
                                    child: Icon(
                                      _isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    widget.status.text,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  if (widget.status.caption != null && widget.status.caption!.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      widget.status.caption!,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        );
                      }

                      // Text and Link Status
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.status.text,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                              letterSpacing: 0.3,
                            ),
                          ),
                          if (hasUrl) ...[
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.white54),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.link_rounded, color: Colors.white, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Shared Web Link 🌐',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                ),
              ),

              // Top Controls & User Header
              Positioned(
                top: 8,
                left: 12,
                right: 12,
                child: Column(
                  children: [
                    // Animated Progress Bar (5s auto progress)
                    AnimatedBuilder(
                      animation: _progressController,
                      builder: (context, child) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: _progressController.value,
                            backgroundColor: Colors.white30,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                            minHeight: 3,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    // User info row
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.white24,
                          child: Text(
                            widget.status.userName.isNotEmpty
                                ? widget.status.userName[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.status.userName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                DateFormatter.formatMessageTime(
                                  widget.status.timestamp,
                                ),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Bottom Reply Field
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.black38,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: TextField(
                          controller: _replyController,
                          onTap: _pause,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: 'Reply...',
                            hintStyle: TextStyle(color: Colors.white60),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFF00A884),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.send_rounded, color: Colors.white),
                        onPressed: _sendReply,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
