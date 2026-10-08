import 'package:flutter/material.dart';
import '../models/message_model.dart';
import '../screens/media_preview_screen.dart';
import '../utils/constants.dart';
import '../utils/date_formatter.dart';

class MessageBubble extends StatefulWidget {
  final MessageModel message;
  final bool isMe;
  final bool showDateSeparator;
  final String? dateSeparatorText;
  final bool isGroupChat;
  final void Function(String emoji)? onReactionSelected;
  final void Function(MessageModel message)? onReply;
  final void Function(MessageModel message)? onForward;
  final void Function(MessageModel message)? onPin;
  final void Function(MessageModel message)? onStar;
  final void Function(MessageModel message)? onEdit;
  final void Function(MessageModel message, bool everyone)? onDelete;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.showDateSeparator = false,
    this.dateSeparatorText,
    this.isGroupChat = false,
    this.onReactionSelected,
    this.onReply,
    this.onForward,
    this.onPin,
    this.onStar,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  bool _isPlayingAudio = false;

  void _showContextMenu(BuildContext context) {
    final message = widget.message;
    final isMe = widget.isMe;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Emoji reaction row
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: ['👍', '❤️', '😂', '😮', '😢', '🙏'].map((emoji) {
                  return InkWell(
                    onTap: () {
                      Navigator.pop(ctx);
                      widget.onReactionSelected?.call(emoji);
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Text(emoji, style: const TextStyle(fontSize: 26)),
                    ),
                  );
                }).toList(),
              ),
            ),
            const Divider(height: 1),

            // Actions list
            ListTile(
              leading: const Icon(Icons.reply_rounded, color: AppColors.primary),
              title: const Text('Reply'),
              onTap: () {
                Navigator.pop(ctx);
                widget.onReply?.call(message);
              },
            ),
            ListTile(
              leading: const Icon(Icons.forward_rounded, color: Colors.blueAccent),
              title: const Text('Forward'),
              onTap: () {
                Navigator.pop(ctx);
                widget.onForward?.call(message);
              },
            ),
            ListTile(
              leading: Icon(
                message.isStarred ? Icons.star_rounded : Icons.star_border_rounded,
                color: Colors.amber,
              ),
              title: Text(message.isStarred ? 'Unstar Message' : 'Star Message'),
              onTap: () {
                Navigator.pop(ctx);
                widget.onStar?.call(message);
              },
            ),
            ListTile(
              leading: Icon(
                message.isPinned ? Icons.push_pin_outlined : Icons.push_pin_rounded,
                color: Colors.deepOrange,
              ),
              title: Text(message.isPinned ? 'Unpin Message' : 'Pin Message to Top'),
              onTap: () {
                Navigator.pop(ctx);
                widget.onPin?.call(message);
              },
            ),
            if (isMe && !message.isDeletedForEveryone && message.messageType == 'text')
              ListTile(
                leading: const Icon(Icons.edit_rounded, color: Colors.teal),
                title: const Text('Edit Message'),
                onTap: () {
                  Navigator.pop(ctx);
                  widget.onEdit?.call(message);
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
              title: const Text('Delete Message'),
              onTap: () {
                Navigator.pop(ctx);
                _showDeleteDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Message?'),
        content: const Text('Do you want to delete this message for yourself or for everyone?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              widget.onDelete?.call(widget.message, false);
            },
            child: const Text('Delete for Me'),
          ),
          if (widget.isMe)
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.pop(ctx);
                widget.onDelete?.call(widget.message, true);
              },
              child: const Text('Delete for Everyone', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final message = widget.message;
    final isMe = widget.isMe;

    if (message.isDeletedForMe) return const SizedBox.shrink();

    final Color bubbleColor = isMe
        ? (isDark ? AppColors.darkSentBubble : AppColors.lightSentBubble)
        : (isDark ? AppColors.darkReceivedBubble : AppColors.lightReceivedBubble);

    final Color textColor = isMe
        ? (isDark ? Colors.white : Colors.black87)
        : (isDark ? Colors.white70 : Colors.black87);

    final Color timeColor = isDark ? Colors.white60 : Colors.black54;

    return Column(
      children: [
        if (widget.showDateSeparator && widget.dateSeparatorText != null)
          _buildDateSeparator(context, isDark),
        Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: GestureDetector(
            onLongPress: () => _showContextMenu(context),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.84,
                  ),
                  margin: EdgeInsets.only(
                    top: 3,
                    bottom: message.reaction != null ? 14 : 3,
                    left: isMe ? 44 : 8,
                    right: isMe ? 8 : 44,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isMe ? 16 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Forwarded Header
                      if (message.forwardCount > 0)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.forward_rounded, size: 13, color: Colors.grey),
                              SizedBox(width: 4),
                              Text('Forwarded', style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.grey)),
                            ],
                          ),
                        ),

                      // Group sender name
                      if (!isMe && widget.isGroupChat && message.senderName != null) ...[
                        Text(
                          message.senderName!,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: _getSenderColor(message.senderName!),
                          ),
                        ),
                        const SizedBox(height: 3),
                      ],

                      // Quoted Reply Banner
                      if (message.replyToText != null)
                        _buildQuotedReplyBox(message, isDark),

                      // Message Content according to type
                      if (message.isDeletedForEveryone)
                        _buildDeletedContent(textColor, timeColor)
                      else if (message.paymentAmount != null || message.messageType == 'payment')
                        _buildPaymentContent(textColor, timeColor, isDark)
                      else if (message.messageType == 'audio')
                        _buildVoiceNoteContent(textColor, timeColor, isDark)
                      else if (message.messageType == 'image')
                        _buildImageContent(textColor, timeColor, isDark)
                      else if (message.messageType == 'video')
                        _buildVideoContent(textColor, timeColor, isDark)
                      else if (message.messageType == 'document')
                        _buildDocumentContent(textColor, timeColor, isDark)
                      else if (message.messageType == 'location')
                        _buildLocationContent(textColor, timeColor, isDark)
                      else if (message.messageType == 'contact')
                        _buildContactContent(textColor, timeColor, isDark)
                      else if (message.messageType == 'sticker')
                        _buildStickerContent(timeColor)
                      else
                        _buildTextContent(textColor, timeColor),
                    ],
                  ),
                ),

                // Reaction emoji pill badge
                if (message.reaction != null)
                  Positioned(
                    bottom: 0,
                    right: isMe ? 18 : null,
                    left: !isMe ? 18 : null,
                    child: GestureDetector(
                      onTap: () => _showContextMenu(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF233138) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? Colors.white12 : Colors.grey.shade300,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          message.reaction!,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuotedReplyBox(MessageModel message, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? Colors.black26 : Colors.black12,
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(
            color: widget.isMe ? AppColors.primaryLight : AppColors.primary,
            width: 3.5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message.replyToSender ?? 'Replying',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
              color: widget.isMe ? AppColors.primaryLight : AppColors.primary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            message.replyToText ?? '',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildDeletedContent(Color textColor, Color timeColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.block_rounded, size: 15, color: Colors.grey),
        const SizedBox(width: 6),
        const Text(
          'This message was deleted',
          style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(width: 8),
        _buildTimeStatusRow(timeColor),
      ],
    );
  }

  Color _getSenderColor(String name) {
    final colors = [
      const Color(0xFFE91E63),
      const Color(0xFF9C27B0),
      const Color(0xFF2196F3),
      const Color(0xFF009688),
      const Color(0xFFFF9800),
      const Color(0xFF3F51B5),
    ];
    return colors[name.hashCode.abs() % colors.length];
  }

  Widget _buildTextContent(Color textColor, Color timeColor) {
    return Wrap(
      alignment: WrapAlignment.end,
      crossAxisAlignment: WrapCrossAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 6, bottom: 2),
          child: Text(
            widget.message.text,
            style: TextStyle(
              color: textColor,
              fontSize: 15.5,
              height: 1.3,
            ),
          ),
        ),
        if (widget.message.isEdited)
          const Padding(
            padding: EdgeInsets.only(right: 4, bottom: 2),
            child: Text(
              '(edited)',
              style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: Colors.grey),
            ),
          ),
        _buildTimeStatusRow(timeColor),
      ],
    );
  }

  Widget _buildLocationContent(Color textColor, Color timeColor, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          height: 120,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.green.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.green.withOpacity(0.4)),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_on_rounded, size: 40, color: Colors.redAccent),
                const SizedBox(height: 4),
                Text(
                  widget.message.locationName ?? 'Live Location Shared',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                Text(
                  widget.message.locationCoords ?? '28.6139° N, 77.2090° E',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Tap to view map', style: TextStyle(fontSize: 11, color: AppColors.primary)),
            _buildTimeStatusRow(timeColor),
          ],
        ),
      ],
    );
  }

  Widget _buildContactContent(Color textColor, Color timeColor, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.blue.shade50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: AppColors.primary,
                child: Icon(Icons.person_rounded, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.message.contactName ?? 'Shared Contact',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text(
                      widget.message.contactPhone ?? '+91 98765 43210',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Contact Card', style: TextStyle(fontSize: 11, color: Colors.grey)),
            _buildTimeStatusRow(timeColor),
          ],
        ),
      ],
    );
  }

  Widget _buildStickerContent(Color timeColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Center(
          child: Text('🎉', style: TextStyle(fontSize: 64)),
        ),
        _buildTimeStatusRow(timeColor),
      ],
    );
  }

  Widget _buildImageContent(Color textColor, Color timeColor, bool isDark) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MediaPreviewScreen(
              title: widget.message.fileName ?? 'Photo Preview',
              imagePath: widget.message.mediaUrl ?? 'assets/images/app_logo.jpg',
              senderName: widget.message.senderName ?? 'User',
              timestamp: widget.message.timestamp,
              mediaType: 'image',
              fileSize: widget.message.fileSize ?? '1.8 MB',
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF2A3942), const Color(0xFF1E2A30)]
                      : [const Color(0xFFE1F5FE), const Color(0xFFB3E5FC)],
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    widget.message.mediaUrl ?? 'assets/images/app_logo.jpg',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 180,
                    errorBuilder: (ctx, err, stack) => Icon(
                      Icons.image_rounded,
                      size: 64,
                      color: isDark ? Colors.white30 : Colors.blue.shade200,
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.photo_camera, size: 12, color: Colors.white),
                          SizedBox(width: 4),
                          Text('Photo', style: TextStyle(color: Colors.white, fontSize: 11)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (widget.message.text.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(widget.message.text, style: TextStyle(color: textColor, fontSize: 14)),
          ],
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [_buildTimeStatusRow(timeColor)],
          ),
        ],
      ),
    );
  }

  Widget _buildVideoContent(Color textColor, Color timeColor, bool isDark) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MediaPreviewScreen(
              title: widget.message.fileName ?? 'Video Clip',
              imagePath: widget.message.mediaUrl ?? 'assets/images/app_logo.jpg',
              senderName: widget.message.senderName ?? 'User',
              timestamp: widget.message.timestamp,
              mediaType: 'video',
              fileSize: widget.message.fileSize ?? '8.4 MB',
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 170,
              width: double.infinity,
              color: isDark ? const Color(0xFF1E293B) : Colors.black87,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 32),
                  ),
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        widget.message.fileSize ?? '0:32 • 8.4 MB',
                        style: const TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [_buildTimeStatusRow(timeColor)],
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentContent(Color textColor, Color timeColor, bool isDark) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MediaPreviewScreen(
              title: widget.message.fileName ?? 'Document.pdf',
              senderName: widget.message.senderName ?? 'User',
              timestamp: widget.message.timestamp,
              mediaType: 'document',
              fileSize: widget.message.fileSize ?? '4.2 MB',
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.picture_as_pdf_rounded, color: Colors.redAccent, size: 36),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.message.fileName ?? 'Universal_Document.pdf',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      Text(
                        widget.message.fileSize ?? '4.2 MB • PDF',
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.download_rounded, color: AppColors.primary, size: 20),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [_buildTimeStatusRow(timeColor)],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentContent(Color textColor, Color timeColor, bool isDark) {
    final amount = widget.message.paymentAmount ?? 0.0;
    final status = widget.message.paymentStatus ?? 'SUCCESS';
    final isSuccess = status == 'SUCCESS';
    final note = widget.message.paymentNote ?? widget.message.text;
    final txnId = widget.message.paymentTxnId ?? 'UPI20261008001';

    return Container(
      width: 250,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D1418) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSuccess ? Colors.green.withOpacity(0.5) : Colors.amber.withOpacity(0.5),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSuccess ? Colors.green.shade600 : Colors.amber.shade700,
                ),
                child: Icon(
                  isSuccess ? Icons.check_rounded : Icons.access_time_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isSuccess ? 'Payment Completed' : 'Payment Pending',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12.5,
                    color: isSuccess ? Colors.green : Colors.amber,
                  ),
                ),
              ),
              const Text(
                'UPI',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: AppColors.primary,
            ),
          ),
          if (note.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              note,
              style: TextStyle(fontSize: 13, color: textColor),
            ),
          ],
          const SizedBox(height: 8),
          const Divider(height: 12),
          Row(
            children: [
              const Icon(Icons.receipt_long_rounded, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  txnId,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [_buildTimeStatusRow(timeColor)],
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceNoteContent(Color textColor, Color timeColor, bool isDark) {
    final duration = widget.message.audioDuration ?? '0:14';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () => setState(() => _isPlayingAudio = !_isPlayingAudio),
              borderRadius: BorderRadius.circular(24),
              child: Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isPlayingAudio ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                height: 28,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [14, 22, 18, 26, 12, 28, 20, 16, 24, 18, 22, 14, 20, 12].map((height) {
                    return Container(
                      width: 3,
                      height: height.toDouble(),
                      decoration: BoxDecoration(
                        color: _isPlayingAudio ? AppColors.primaryLight : (isDark ? Colors.white38 : Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.mic_rounded, color: AppColors.primaryLight, size: 18),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(duration, style: TextStyle(fontSize: 11, color: timeColor)),
            _buildTimeStatusRow(timeColor),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeStatusRow(Color timeColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.message.isPinned) ...[
          const Icon(Icons.push_pin_rounded, size: 12, color: Colors.deepOrange),
          const SizedBox(width: 3),
        ],
        if (widget.message.isStarred) ...[
          const Icon(Icons.star_rounded, size: 12, color: Colors.amber),
          const SizedBox(width: 3),
        ],
        Text(
          DateFormatter.formatTimestamp(widget.message.timestamp),
          style: TextStyle(fontSize: 11, color: timeColor),
        ),
        if (widget.isMe) ...[
          const SizedBox(width: 4),
          Icon(
            widget.message.isSeen ? Icons.done_all : Icons.done,
            size: 16,
            color: widget.message.isSeen ? AppColors.seenTick : AppColors.sentTick,
          ),
        ],
      ],
    );
  }

  Widget _buildDateSeparator(BuildContext context, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2C34) : const Color(0xFFEFEFEF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        widget.dateSeparatorText!,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white70 : Colors.black54,
        ),
      ),
    );
  }
}
