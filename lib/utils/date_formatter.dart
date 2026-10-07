import 'package:intl/intl.dart';

class DateFormatter {
  /// Format message bubble timestamp (e.g., '10:30 AM')
  static String formatMessageTime(DateTime dateTime) {
    return DateFormat('h:mm a').format(dateTime);
  }

  /// Format date separator for message grouping (e.g., 'Today', 'Yesterday', 'October 5, 2026')
  static String formatDateSeparator(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      return 'Today';
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else if (now.difference(messageDate).inDays < 7) {
      return DateFormat('EEEE').format(dateTime); // e.g. Monday
    } else {
      return DateFormat('MMMM d, yyyy').format(dateTime);
    }
  }

  /// Format time displayed on recent chat list tiles
  static String formatChatListTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      return DateFormat('h:mm a').format(dateTime);
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else if (now.difference(messageDate).inDays < 7) {
      return DateFormat('E').format(dateTime); // e.g. Mon, Tue
    } else {
      return DateFormat('dd/MM/yy').format(dateTime);
    }
  }

  /// Format user last seen status (e.g., 'Online', 'Last seen just now', 'Last seen yesterday at 4:10 PM')
  static String formatLastSeen({required bool isOnline, DateTime? lastSeen}) {
    if (isOnline) {
      return 'Online';
    }
    if (lastSeen == null) {
      return 'Offline';
    }

    final now = DateTime.now();
    final diff = now.difference(lastSeen);

    if (diff.inSeconds < 60) {
      return 'Last seen just now';
    } else if (diff.inMinutes < 60) {
      return 'Last seen ${diff.inMinutes}m ago';
    } else if (diff.inHours < 24 && now.day == lastSeen.day) {
      return 'Last seen today at ${DateFormat('h:mm a').format(lastSeen)}';
    } else if (diff.inHours < 48 && now.subtract(const Duration(days: 1)).day == lastSeen.day) {
      return 'Last seen yesterday at ${DateFormat('h:mm a').format(lastSeen)}';
    } else {
      return 'Last seen ${DateFormat('MMM d, h:mm a').format(lastSeen)}';
    }
  }
}
