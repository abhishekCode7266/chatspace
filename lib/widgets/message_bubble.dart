import 'package:flutter/material.dart';
import '../models/message_model.dart';
import '../utils/constants.dart';
import '../utils/date_formatter.dart';

class MessageBubble extends StatefulWidget {
  final MessageModel message;
  final bool isMe;
  final bool showDateSeparator;
  final String? dateSeparatorText;
  final void Function(String emoji)? onReactionSelected;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.showDateSeparator = false,
    this.dateSeparatorText,
    this.onReactionSelected,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  bool _isPlayingAudio = false;

  void _showReactionMenu(BuildContext context) {
    if (widget.onReactionSelected == null) return;

    final RenderBox? overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox?;
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || overlay == null) return;

    final position = renderBox.localToGlobal(Offset.zero, ancestor: overlay);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final emojis = ['👍', '❤️', '😂', '😮', '😢', '🙏'];

    showDialog(
      context: context,
      barrierColor: Colors.black26,
      builder: (ctx) {
        return Stack(
          children: [
            Positioned(
              left: widget.isMe
                  ? (position.dx - 120).clamp(16.0, overlay.size.width - 240)
                  : position.dx.clamp(16.0, overlay.size.width - 240),
              top: (position.dy - 60).clamp(60.0, overlay.size.height - 100),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF233138) : Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: emojis.map((emoji) {
                      final isSelected = widget.message.reaction == emoji;
                      return InkWell(
                        onTap: () {
                          Navigator.pop(ctx);
                          widget.onReactionSelected!(emoji);
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark ? Colors.white12 : Colors.grey.shade200)
                                : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            emoji,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final message = widget.message;
    final isMe = widget.isMe;

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
            onLongPress: () => _showReactionMenu(context),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.82,
                  ),
                  margin: EdgeInsets.only(
                    top: 3,
                    bottom: message.reaction != null ? 14 : 3,
                    left: isMe ? 48 : 8,
                    right: isMe ? 8 : 48,
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
                  child: message.messageType == 'audio'
                      ? _buildVoiceNoteContent(textColor, timeColor, isDark)
                      : _buildTextContent(textColor, timeColor),
                ),
                // Reaction emoji pill badge (WhatsApp style)
                if (message.reaction != null)
                  Positioned(
                    bottom: 0,
                    right: isMe ? 18 : null,
                    left: !isMe ? 18 : null,
                    child: GestureDetector(
                      onTap: () => _showReactionMenu(context),
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
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              DateFormatter.formatMessageTime(widget.message.timestamp),
              style: TextStyle(
                fontSize: 11,
                color: timeColor,
              ),
            ),
            if (widget.isMe) ...[
              const SizedBox(width: 4),
              Icon(
                widget.message.isSeen ? Icons.done_all : Icons.done,
                size: 15,
                color: widget.message.isSeen
                    ? AppColors.seenTick
                    : AppColors.sentTick,
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildVoiceNoteContent(Color textColor, Color timeColor, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Play / Pause Circular Button
            GestureDetector(
              onTap: () {
                setState(() {
                  _isPlayingAudio = !_isPlayingAudio;
                });
              },
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: widget.isMe ? AppColors.primary : AppColors.secondary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isPlayingAudio ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Simulated Audio Waveform
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: List.generate(22, (index) {
                      final heights = [
                        8.0, 14.0, 20.0, 10.0, 16.0, 24.0, 12.0, 18.0, 22.0,
                        15.0, 26.0, 18.0, 12.0, 22.0, 16.0, 10.0, 20.0, 14.0,
                        24.0, 16.0, 12.0, 8.0,
                      ];
                      final isPlayed = _isPlayingAudio && index < 12;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 1.2),
                        width: 2.5,
                        height: heights[index % heights.length],
                        decoration: BoxDecoration(
                          color: isPlayed
                              ? AppColors.accent
                              : (isDark ? Colors.white38 : Colors.black38),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _isPlayingAudio ? '0:06' : (widget.message.audioDuration ?? '0:14'),
                        style: TextStyle(
                          fontSize: 11,
                          color: timeColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Icon(
                        Icons.mic_rounded,
                        size: 14,
                        color: AppColors.accent,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              DateFormatter.formatMessageTime(widget.message.timestamp),
              style: TextStyle(
                fontSize: 11,
                color: timeColor,
              ),
            ),
            if (widget.isMe) ...[
              const SizedBox(width: 4),
              Icon(
                widget.message.isSeen ? Icons.done_all : Icons.done,
                size: 15,
                color: widget.message.isSeen
                    ? AppColors.seenTick
                    : AppColors.sentTick,
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildDateSeparator(BuildContext context, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E282E) : const Color(0xFFE1E4E8),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        widget.dateSeparatorText!,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white70 : Colors.black87,
        ),
      ),
    );
  }
}
