import 'package:flutter/material.dart';

/// WhatsApp Chat Theme Wallpaper Definition
class ChatThemeWallpaper {
  final String id;
  final String name;
  final String hindiName;
  final Color primaryColor;
  final List<Color> gradientColors;
  final bool hasDoodle;

  const ChatThemeWallpaper({
    required this.id,
    required this.name,
    required this.hindiName,
    required this.primaryColor,
    required this.gradientColors,
    this.hasDoodle = true,
  });
}

class ChatWallpapers {
  static const List<ChatThemeWallpaper> allWallpapers = [
    ChatThemeWallpaper(
      id: 'default',
      name: 'WhatsApp Classic',
      hindiName: 'व्हाट्सएप क्लासिक',
      primaryColor: Color(0xFF00A884),
      gradientColors: [Color(0xFFEFEAE2), Color(0xFFE6E0D6)],
      hasDoodle: true,
    ),
    ChatThemeWallpaper(
      id: 'dark_doodle',
      name: 'Dark Doodle',
      hindiName: 'डार्क डूडल',
      primaryColor: Color(0xFF111B21),
      gradientColors: [Color(0xFF111B21), Color(0xFF0C1317)],
      hasDoodle: true,
    ),
    ChatThemeWallpaper(
      id: 'emerald',
      name: 'Emerald Forest',
      hindiName: 'एमराल्ड ग्रीन',
      primaryColor: Color(0xFF064E3B),
      gradientColors: [Color(0xFF064E3B), Color(0xFF022C22)],
      hasDoodle: true,
    ),
    ChatThemeWallpaper(
      id: 'midnight',
      name: 'Midnight Sky',
      hindiName: 'मिडनाइट ब्लू',
      primaryColor: Color(0xFF1E1B4B),
      gradientColors: [Color(0xFF1E1B4B), Color(0xFF0F172A)],
      hasDoodle: true,
    ),
    ChatThemeWallpaper(
      id: 'sunset',
      name: 'Sunset Amber',
      hindiName: 'सनसेट अंबर',
      primaryColor: Color(0xFFB45309),
      gradientColors: [Color(0xFF451A03), Color(0xFF78350F)],
      hasDoodle: true,
    ),
    ChatThemeWallpaper(
      id: 'cyberpunk',
      name: 'Cyberpunk Neon',
      hindiName: 'नियॉन पर्पल',
      primaryColor: Color(0xFF7C3AED),
      gradientColors: [Color(0xFF311042), Color(0xFF130324)],
      hasDoodle: true,
    ),
    ChatThemeWallpaper(
      id: 'rose',
      name: 'Rose Romance',
      hindiName: 'सॉफ्ट रोज़',
      primaryColor: Color(0xFFBE185D),
      gradientColors: [Color(0xFF881337), Color(0xFF4C0519)],
      hasDoodle: true,
    ),
    ChatThemeWallpaper(
      id: 'clean_slate',
      name: 'Clean Minimalist',
      hindiName: 'क्लीन स्लेट',
      primaryColor: Color(0xFF334155),
      gradientColors: [Color(0xFF1E293B), Color(0xFF0F172A)],
      hasDoodle: false,
    ),
  ];

  static ChatThemeWallpaper getById(String id) {
    return allWallpapers.firstWhere(
      (w) => w.id == id,
      orElse: () => allWallpapers.first,
    );
  }
}

/// Widget providing WhatsApp Doodle pattern and theme background
class ChatWallpaperBackground extends StatelessWidget {
  final String wallpaperId;
  final bool isDark;
  final Widget child;

  const ChatWallpaperBackground({
    super.key,
    required this.wallpaperId,
    required this.isDark,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final wallpaper = ChatWallpapers.getById(wallpaperId);

    List<Color> colors;
    if (wallpaperId == 'default') {
      colors = isDark
          ? const [Color(0xFF111B21), Color(0xFF0B141A)]
          : const [Color(0xFFEFEAE2), Color(0xFFE5DDD5)];
    } else {
      colors = wallpaper.gradientColors;
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          if (wallpaper.hasDoodle)
            Positioned.fill(
              child: CustomPaint(
                painter: _WhatsAppDoodlePainter(isDark: isDark),
              ),
            ),
          child,
        ],
      ),
    );
  }
}

/// Custom painter for iconic subtle WhatsApp background doodles
class _WhatsAppDoodlePainter extends CustomPainter {
  final bool isDark;

  _WhatsAppDoodlePainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withOpacity(isDark ? 0.035 : 0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    const double stepX = 70.0;
    const double stepY = 70.0;

    int colIndex = 0;
    for (double x = 15; x < size.width; x += stepX) {
      int rowIndex = 0;
      for (double y = 20; y < size.height; y += stepY) {
        final iconType = (colIndex + rowIndex) % 8;
        _drawDoodleItem(canvas, Offset(x, y), iconType, paint);
        rowIndex++;
      }
      colIndex++;
    }
  }

  void _drawDoodleItem(Canvas canvas, Offset center, int type, Paint paint) {
    switch (type) {
      case 0:
        // Chat bubble
        final r = RRect.fromRectAndRadius(
          Rect.fromCenter(center: center, width: 22, height: 16),
          const Radius.circular(5),
        );
        canvas.drawRRect(r, paint);
        // little tail
        canvas.drawLine(
          Offset(center.dx - 4, center.dy + 8),
          Offset(center.dx - 8, center.dy + 12),
          paint,
        );
        break;
      case 1:
        // Coffee Cup
        canvas.drawRect(
          Rect.fromCenter(center: center, width: 14, height: 14),
          paint,
        );
        canvas.drawArc(
          Rect.fromCircle(center: Offset(center.dx + 8, center.dy), radius: 5),
          -1.57,
          3.14,
          false,
          paint,
        );
        break;
      case 2:
        // Heart
        final path = Path();
        path.moveTo(center.dx, center.dy + 7);
        path.cubicTo(center.dx - 12, center.dy - 4, center.dx - 6, center.dy - 12, center.dx, center.dy - 6);
        path.cubicTo(center.dx + 6, center.dy - 12, center.dx + 12, center.dy - 4, center.dx, center.dy + 7);
        canvas.drawPath(path, paint);
        break;
      case 3:
        // Musical note
        canvas.drawCircle(Offset(center.dx - 4, center.dy + 5), 3, paint);
        canvas.drawLine(Offset(center.dx - 1, center.dy + 5), Offset(center.dx - 1, center.dy - 7), paint);
        canvas.drawLine(Offset(center.dx - 1, center.dy - 7), Offset(center.dx + 6, center.dy - 4), paint);
        break;
      case 4:
        // Clock
        canvas.drawCircle(center, 9, paint);
        canvas.drawLine(center, Offset(center.dx, center.dy - 5), paint);
        canvas.drawLine(center, Offset(center.dx + 4, center.dy), paint);
        break;
      case 5:
        // Star
        canvas.drawCircle(center, 2, paint);
        canvas.drawLine(Offset(center.dx - 7, center.dy), Offset(center.dx + 7, center.dy), paint);
        canvas.drawLine(Offset(center.dx, center.dy - 7), Offset(center.dx, center.dy + 7), paint);
        break;
      case 6:
        // Camera icon
        final r2 = RRect.fromRectAndRadius(
          Rect.fromCenter(center: center, width: 18, height: 14),
          const Radius.circular(3),
        );
        canvas.drawRRect(r2, paint);
        canvas.drawCircle(center, 4, paint);
        break;
      case 7:
        // Smiley
        canvas.drawCircle(center, 8, paint);
        canvas.drawCircle(Offset(center.dx - 3, center.dy - 2), 1, paint);
        canvas.drawCircle(Offset(center.dx + 3, center.dy - 2), 1, paint);
        canvas.drawArc(
          Rect.fromCircle(center: Offset(center.dx, center.dy + 1), radius: 4),
          0.2,
          2.74,
          false,
          paint,
        );
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _WhatsAppDoodlePainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
