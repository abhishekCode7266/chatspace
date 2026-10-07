import 'package:flutter/material.dart';
import '../models/message_model.dart';
import '../utils/constants.dart';
import '../utils/date_formatter.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;
  final bool showDateSeparator;
  final String? dateSeparatorText;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.showDateSeparator = false,
    this.dateSeparatorText,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color bubbleColor = isMe
        ? (isDark ? AppColors.darkSentBubble : AppColors.lightSentBubble)
        : (isDark ? AppColors.darkReceivedBubble : AppColors.lightReceivedBubble);

    final Color textColor = isMe
        ? (isDark ? Colors.white : Colors.black87)
        : (isDark ? Colors.white70 : Colors.black87);

    final Color timeColor = isDark ? Colors.white60 : Colors.black54;

    return Column(
      children: [
        if (showDateSeparator && dateSeparatorText != null)
          _buildDateSeparator(context, isDark),
        Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.78,
            ),
            margin: EdgeInsets.only(
              top: 3,
              bottom: 3,
              left: isMe ? 48 : 8,
              right: isMe ? 8 : 48,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
            child: Wrap(
              alignment: WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 6, bottom: 2),
                  child: Text(
                    message.text,
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
                      DateFormatter.formatMessageTime(message.timestamp),
                      style: TextStyle(
                        fontSize: 11,
                        color: timeColor,
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 4),
                      Icon(
                        message.isSeen ? Icons.done_all : Icons.done,
                        size: 15,
                        color: message.isSeen
                            ? AppColors.seenTick
                            : AppColors.sentTick,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
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
        dateSeparatorText!,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white70 : Colors.black87,
        ),
      ),
    );
  }
}
