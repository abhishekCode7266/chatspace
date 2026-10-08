import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Fullscreen Media Preview Screen
/// Supports Photos, Videos, and Document previews with download & share
class MediaPreviewScreen extends StatefulWidget {
  final String title;
  final String? imagePath;
  final String senderName;
  final DateTime timestamp;
  final String mediaType; // 'image', 'video', 'document'
  final String? fileSize;

  const MediaPreviewScreen({
    super.key,
    required this.title,
    this.imagePath,
    this.senderName = 'Alice Johnson',
    required this.timestamp,
    this.mediaType = 'image',
    this.fileSize = '2.4 MB',
  });

  @override
  State<MediaPreviewScreen> createState() => _MediaPreviewScreenState();
}

class _MediaPreviewScreenState extends State<MediaPreviewScreen> {
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  bool _isStarred = false;

  void _downloadFile() {
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
    });

    Future.delayed(const Duration(milliseconds: 300), () => setState(() => _downloadProgress = 0.35));
    Future.delayed(const Duration(milliseconds: 700), () => setState(() => _downloadProgress = 0.75));
    Future.delayed(const Duration(milliseconds: 1100), () {
      if (!mounted) return;
      setState(() {
        _isDownloading = false;
        _downloadProgress = 1.0;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✓ ${widget.title} saved to device Gallery / Downloads!'),
          backgroundColor: AppColors.primary,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.7),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title, style: const TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold)),
            Text(
              '${widget.senderName} • ${widget.fileSize ?? ""}',
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(_isStarred ? Icons.star_rounded : Icons.star_border_rounded, color: Colors.amber),
            tooltip: 'Star Media',
            onPressed: () {
              setState(() => _isStarred = !_isStarred);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(_isStarred ? 'Media starred' : 'Media unstarred')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_rounded, color: Colors.white),
            tooltip: 'Share',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Media share link generated!')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.download_rounded, color: Colors.white),
            tooltip: 'Download',
            onPressed: _isDownloading ? null : _downloadFile,
          ),
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Media Viewer (Interactive zoom)
          Center(
            child: InteractiveViewer(
              minScale: 0.8,
              maxScale: 4.0,
              child: widget.imagePath != null
                  ? Image.asset(
                      widget.imagePath!,
                      fit: BoxFit.contain,
                      errorBuilder: (ctx, err, stack) => const Icon(Icons.broken_image, size: 80, color: Colors.white38),
                    )
                  : Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            widget.mediaType == 'document' ? Icons.description_rounded : Icons.videocam_rounded,
                            size: 72,
                            color: AppColors.primaryLight,
                          ),
                          const SizedBox(height: 16),
                          Text(widget.title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(widget.fileSize ?? 'Ready for preview', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ),
            ),
          ),

          // Download Progress Bar
          if (_isDownloading)
            Positioned(
              bottom: 40,
              left: 40,
              right: 40,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withOpacity(0.5)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Downloading file... ${(_downloadProgress * 100).toInt()}%', style: const TextStyle(color: Colors.white, fontSize: 13)),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(value: _downloadProgress, color: AppColors.primaryLight),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
