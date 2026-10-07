import 'dart:async';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

class CallScreen extends StatefulWidget {
  final UserModel targetUser;
  final bool isVideoCall;

  const CallScreen({
    super.key,
    required this.targetUser,
    required this.isVideoCall,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> with TickerProviderStateMixin {
  late bool _isVideo;
  bool _isMuted = false;
  bool _isCameraOff = false;
  bool _isSpeakerOn = true;
  bool _isFrontCamera = true;
  String _callStatus = 'Calling...';
  bool _isConnected = false;

  int _callSeconds = 0;
  Timer? _timer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _isVideo = widget.isVideoCall;

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Simulate WhatsApp call connection lifecycle
    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _callStatus = 'Ringing...';
      });
    });

    Timer(const Duration(seconds: 4), () {
      if (!mounted) return;
      setState(() {
        _callStatus = 'Connected';
        _isConnected = true;
      });
      _startCallTimer();
    });
  }

  void _startCallTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _callSeconds++;
      });
    });
  }

  String _formatCallDuration(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _endCall() {
    _timer?.cancel();
    _pulseController.dispose();
    Navigator.pop(context, _callSeconds);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101D25),
      body: SafeArea(
        child: Stack(
          children: [
            // Video Background or Voice Call Background
            if (_isVideo && !_isCameraOff)
              _buildVideoBackground()
            else
              _buildVoiceBackground(),

            // Header: Target User Info & Call Status
            Positioned(
              top: 24,
              left: 20,
              right: 20,
              child: Column(
                children: [
                  // End-to-End Encrypted Notice
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock_rounded, color: Colors.white70, size: 13),
                        SizedBox(width: 6),
                        Text(
                          'End-to-End Encrypted',
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.targetUser.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _isConnected
                        ? _formatCallDuration(_callSeconds)
                        : _callStatus,
                    style: TextStyle(
                      color: _isConnected ? const Color(0xFF25D366) : Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // PiP Local Camera Preview (For Video Calls)
            if (_isVideo && !_isCameraOff)
              Positioned(
                top: 120,
                right: 20,
                child: Container(
                  width: 105,
                  height: 155,
                  decoration: BoxDecoration(
                    color: const Color(0xFF233138),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white24, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Stack(
                      children: [
                        // Simulated Front Camera feed
                        Container(
                          color: const Color(0xFF1A2A33),
                          child: Center(
                            child: Icon(
                              _isFrontCamera
                                  ? Icons.person_rounded
                                  : Icons.landscape_rounded,
                              size: 48,
                              color: Colors.white38,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 6,
                          left: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _isFrontCamera ? 'Front' : 'Rear',
                              style: const TextStyle(color: Colors.white, fontSize: 10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Bottom Action Controls (WhatsApp Call Bar)
            Positioned(
              bottom: 36,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F2C34).withOpacity(0.92),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Flip Camera (if video call)
                    if (_isVideo)
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _isFrontCamera = !_isFrontCamera;
                          });
                        },
                        icon: const Icon(Icons.flip_camera_ios_rounded, color: Colors.white),
                        tooltip: 'Switch Camera',
                      ),

                    // Camera On/Off (if video call)
                    if (_isVideo)
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _isCameraOff = !_isCameraOff;
                          });
                        },
                        icon: Icon(
                          _isCameraOff ? Icons.videocam_off_rounded : Icons.videocam_rounded,
                          color: _isCameraOff ? Colors.redAccent : Colors.white,
                        ),
                        tooltip: 'Toggle Video',
                      ),

                    // Mic Mute / Unmute
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _isMuted = !_isMuted;
                        });
                      },
                      icon: Icon(
                        _isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                        color: _isMuted ? Colors.redAccent : Colors.white,
                      ),
                      tooltip: 'Mute Microphone',
                    ),

                    // Speakerphone Toggle
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _isSpeakerOn = !_isSpeakerOn;
                        });
                      },
                      icon: Icon(
                        _isSpeakerOn ? Icons.volume_up_rounded : Icons.volume_down_rounded,
                        color: _isSpeakerOn ? const Color(0xFF25D366) : Colors.white70,
                      ),
                      tooltip: 'Speaker',
                    ),

                    // End Call (Red Circular Button)
                    GestureDetector(
                      onTap: _endCall,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.call_end_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceBackground() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: _pulseAnimation,
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.12),
              ),
              child: CircleAvatar(
                radius: 72,
                backgroundColor: AppColors.primary,
                child: Text(
                  widget.targetUser.name.isNotEmpty
                      ? widget.targetUser.name[0].toUpperCase()
                      : 'U',
                  style: const TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 36),
          if (!_isConnected)
            const Text(
              'Connecting with ChatSpace peer network...',
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
        ],
      ),
    );
  }

  Widget _buildVideoBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 64,
              backgroundColor: Colors.white12,
              child: Text(
                widget.targetUser.name.isNotEmpty
                    ? widget.targetUser.name[0].toUpperCase()
                    : 'U',
                style: const TextStyle(
                  fontSize: 54,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF25D366),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Live HD Video Stream (WebRTC / Peer-to-Peer)',
                    style: TextStyle(color: Colors.white, fontSize: 13),
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
