import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import '../screens/dev_bypass_sheet.dart';

/// Floating, draggable circular Developer Bypass widget
/// Prominently placed at the top or floating across screens.
/// Tapping opens the Developer Bypass & Full Inspection Hub.
class FloatingDevCircle extends StatefulWidget {
  final Offset initialPosition;

  const FloatingDevCircle({
    super.key,
    this.initialPosition = const Offset(20, 90),
  });

  @override
  State<FloatingDevCircle> createState() => _FloatingDevCircleState();
}

class _FloatingDevCircleState extends State<FloatingDevCircle> with SingleTickerProviderStateMixin {
  late Offset _position;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _position = widget.initialPosition;
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _openDevHub(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const DevBypassSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isBypassActive = authProvider.isDevBypass;

    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: Draggable(
        feedback: _buildCircle(isBypassActive, isDragging: true),
        childWhenDragging: Opacity(
          opacity: 0.3,
          child: _buildCircle(isBypassActive),
        ),
        onDragEnd: (details) {
          final screenSize = MediaQuery.of(context).size;
          // Clamp position within screen bounds
          final newX = details.offset.dx.clamp(12.0, screenSize.width - 68.0);
          final newY = details.offset.dy.clamp(60.0, screenSize.height - 120.0);
          setState(() {
            _position = Offset(newX, newY);
          });
        },
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: _buildCircle(isBypassActive),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCircle(bool isBypassActive, {bool isDragging = false}) {
    return GestureDetector(
      onTap: () => _openDevHub(context),
      child: Material(
        elevation: isDragging ? 12 : 8,
        shape: const CircleBorder(),
        shadowColor: isBypassActive ? Colors.cyanAccent.withOpacity(0.6) : Colors.amber.withOpacity(0.4),
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: isBypassActive
                  ? [
                      const Color(0xFF00E5FF),
                      const Color(0xFF00796B),
                      const Color(0xFF0B141A),
                    ]
                  : [
                      const Color(0xFFFFB300),
                      const Color(0xFFE65100),
                      const Color(0xFF1F2C34),
                    ],
              stops: const [0.2, 0.7, 1.0],
            ),
            border: Border.all(
              color: isBypassActive ? Colors.cyanAccent : Colors.amberAccent,
              width: 2.2,
            ),
            boxShadow: [
              BoxShadow(
                color: (isBypassActive ? Colors.cyanAccent : Colors.amber).withOpacity(0.45),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isBypassActive ? Icons.bolt_rounded : Icons.lock_open_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  const Text(
                    'DEV',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 3,
                right: 3,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isBypassActive ? AppColors.online : Colors.orangeAccent,
                    border: Border.all(color: Colors.white, width: 1.2),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// App Bar Action variant for static placement in headers
class AppBarDevCircleButton extends StatelessWidget {
  const AppBarDevCircleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isBypassActive = authProvider.isDevBypass;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Tooltip(
        message: 'Developer Bypass & Inspection Suite',
        child: InkWell(
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (ctx) => const DevBypassSheet(),
            );
          },
          borderRadius: BorderRadius.circular(24),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: isBypassActive
                    ? [const Color(0xFF00E5FF), const Color(0xFF004D40)]
                    : [const Color(0xFFFFB300), const Color(0xFFBF360C)],
              ),
              border: Border.all(
                color: isBypassActive ? Colors.cyanAccent : Colors.amberAccent,
                width: 1.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isBypassActive ? Colors.cyan : Colors.amber).withOpacity(0.5),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Center(
              child: Text(
                isBypassActive ? '⚡' : '🛠️',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
