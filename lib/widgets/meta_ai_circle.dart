import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../screens/ai_assistant_screen.dart';

/// WhatsApp / Meta AI style animated circular button
/// Positioned on the right-hand side above the FloatingActionButton.
/// Tapping launches the Universal Meta AI Companion with /imagine image generation.
class MetaAiFloatingCircle extends StatefulWidget {
  final VoidCallback? onTap;

  const MetaAiFloatingCircle({
    super.key,
    this.onTap,
  });

  @override
  State<MetaAiFloatingCircle> createState() => _MetaAiFloatingCircleState();
}

class _MetaAiFloatingCircleState extends State<MetaAiFloatingCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  void _openMetaAi(BuildContext context) {
    if (widget.onTap != null) {
      widget.onTap!();
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AiAssistantScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Tooltip(
      message: 'Universal AI Companion (यूनिवर्सल एआई)',
      child: GestureDetector(
        onTap: () => _openMetaAi(context),
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark ? const Color(0xFF1F2C34) : Colors.white,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF007AFF).withOpacity(0.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: const Color(0xFFE040FB).withOpacity(0.25),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: AnimatedBuilder(
            animation: _rotationController,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Rotating Iridescent Meta AI Ring Border
                  Transform.rotate(
                    angle: _rotationController.value * 2 * math.pi,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: SweepGradient(
                          colors: [
                            Color(0xFF00C6FF), // Cyan
                            Color(0xFF0072FF), // Blue
                            Color(0xFF8E2DE2), // Purple
                            Color(0xFFF10086), // Magenta / Pink
                            Color(0xFFFF8008), // Orange
                            Color(0xFF00C6FF), // Loop back
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Center circular cutout like WhatsApp's Meta AI icon
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark ? const Color(0xFF111B21) : Colors.white,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.circle_outlined,
                        size: 24,
                        color: Color(0xFF007AFF),
                      ),
                    ),
                  ),

                  // AI Sparkle badge
                  Positioned(
                    top: 5,
                    right: 5,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF00E5FF),
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        size: 9,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Mini inline icon variant for Chat Input Bar
class MetaAiChatAction extends StatelessWidget {
  final VoidCallback onTap;

  const MetaAiChatAction({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Ask Universal AI / Imagine',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [
                Color(0xFF00C6FF),
                Color(0xFF0072FF),
                Color(0xFF8E2DE2),
                Color(0xFFF10086),
              ],
            ).createShader(bounds),
            child: const Icon(
              Icons.circle_outlined,
              size: 24,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

typedef UniversalAiFloatingCircle = MetaAiFloatingCircle;
