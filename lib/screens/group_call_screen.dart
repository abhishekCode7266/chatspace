import 'dart:async';
import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Group Voice & Video Calling Screen with Multi-Participant Grid
class GroupCallScreen extends StatefulWidget {
  final String groupName;
  final List<String> participantNames;
  final bool isVideo;

  const GroupCallScreen({
    super.key,
    required this.groupName,
    this.participantNames = const [
      'Alice Johnson',
      'Bob Smith',
      'Charlie Dev',
      'Diana Prince',
    ],
    this.isVideo = true,
  });

  @override
  State<GroupCallScreen> createState() => _GroupCallScreenState();
}

class _GroupCallScreenState extends State<GroupCallScreen> {
  bool _isMicMuted = false;
  bool _isCameraOff = false;
  bool _isFrontCamera = true;
  bool _isSpeakerOn = true;
  bool _isScreenSharing = false;
  int _callDurationSeconds = 0;
  Timer? _callTimer;

  // Track who is actively speaking
  int _activeSpeakerIndex = 0;
  Timer? _speakerCycleTimer;

  @override
  void initState() {
    super.initState();
    _startCallTimer();
    _startSpeakerCycleTimer();
  }

  void _startCallTimer() {
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _callDurationSeconds++;
        });
      }
    });
  }

  void _startSpeakerCycleTimer() {
    _speakerCycleTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted && widget.participantNames.isNotEmpty) {
        setState(() {
          _activeSpeakerIndex = (_activeSpeakerIndex + 1) % widget.participantNames.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _callTimer?.cancel();
    _speakerCycleTimer?.cancel();
    super.dispose();
  }

  String _formatDuration(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Column(
          children: [
            // Header Bar
            _buildHeader(),

            // Video/Voice Participant Grid
            Expanded(
              child: widget.isVideo ? _buildVideoGrid() : _buildVoiceGrid(),
            ),

            // In-call Control Deck
            _buildControlDeck(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        border: const Border(bottom: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.isVideo ? Icons.videocam_rounded : Icons.phone_in_talk_rounded,
                  color: AppColors.primaryLight,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.groupName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.greenAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'HD Encrypted • ${_formatDuration(_callDurationSeconds)}',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white70),
            tooltip: 'Invite participant',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Participant invite link copied to clipboard!')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVideoGrid() {
    final participants = widget.participantNames;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        itemCount: participants.length + 1, // +1 for "You"
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 0.95,
        ),
        itemBuilder: (context, index) {
          if (index == participants.length) {
            // Local User (You)
            return _buildParticipantTile(
              name: 'You (Host)',
              avatarLetter: 'Y',
              isLocal: true,
              isSpeaking: false,
              isCameraMuted: _isCameraOff,
              tileColor: const Color(0xFF1E293B),
            );
          }

          final name = participants[index];
          final isSpeaking = index == _activeSpeakerIndex;
          return _buildParticipantTile(
            name: name,
            avatarLetter: name.isNotEmpty ? name[0] : 'U',
            isLocal: false,
            isSpeaking: isSpeaking,
            isCameraMuted: false,
            tileColor: Color(0xFF1E293B + (index * 0x050505)),
          );
        },
      ),
    );
  }

  Widget _buildVoiceGrid() {
    final participants = widget.participantNames;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 20,
          runSpacing: 24,
          alignment: WrapAlignment.center,
          children: [
            _buildVoiceAvatarTile(name: 'You (Host)', isSpeaking: false),
            ...participants.map((name) {
              final isSpeaking = participants.indexOf(name) == _activeSpeakerIndex;
              return _buildVoiceAvatarTile(name: name, isSpeaking: isSpeaking);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceAvatarTile({required String name, required bool isSpeaking}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            if (isSpeaking)
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryLight, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryLight.withOpacity(0.5),
                      blurRadius: 16,
                      spreadRadius: 4,
                    ),
                  ],
                ),
              ),
            CircleAvatar(
              radius: 40,
              backgroundColor: const Color(0xFF334155),
              child: Text(
                name.isNotEmpty ? name[0] : 'U',
                style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            if (isSpeaking)
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.mic, color: Colors.white, size: 14),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: TextStyle(
            color: isSpeaking ? Colors.greenAccent : Colors.white70,
            fontSize: 13,
            fontWeight: isSpeaking ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildParticipantTile({
    required String name,
    required String avatarLetter,
    required bool isLocal,
    required bool isSpeaking,
    required bool isCameraMuted,
    required Color tileColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: tileColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSpeaking
              ? AppColors.primaryLight
              : (isLocal ? Colors.cyanAccent.withOpacity(0.6) : Colors.white10),
          width: isSpeaking ? 2.5 : 1,
        ),
        boxShadow: isSpeaking
            ? [
                BoxShadow(
                  color: AppColors.primaryLight.withOpacity(0.4),
                  blurRadius: 12,
                  spreadRadius: 2,
                )
              ]
            : null,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background simulation or Camera feed
          if (!isCameraMuted)
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    tileColor.withOpacity(0.8),
                    const Color(0xFF0F172A),
                  ],
                ),
              ),
            ),

          // Center Avatar if camera off or simulated participant
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: isLocal ? Colors.cyan.shade800 : Colors.indigo.shade700,
                child: Text(
                  avatarLetter,
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              if (isCameraMuted) ...[
                const SizedBox(height: 6),
                const Text(
                  'Camera Off',
                  style: TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ],
            ],
          ),

          // Bottom label
          Positioned(
            left: 8,
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    isSpeaking ? Icons.mic : (isLocal && _isMicMuted ? Icons.mic_off : Icons.mic_none),
                    color: isSpeaking ? Colors.greenAccent : (isLocal && _isMicMuted ? Colors.red : Colors.white70),
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Speaking pulse badge
          if (isSpeaking)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('Speaking', style: TextStyle(color: Colors.white, fontSize: 9)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildControlDeck() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: Colors.white10),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 16, offset: Offset(0, -4)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Mute Mic
          _buildActionButton(
            icon: _isMicMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
            color: _isMicMuted ? Colors.redAccent : Colors.white24,
            tooltip: _isMicMuted ? 'Unmute' : 'Mute',
            onTap: () {
              setState(() {
                _isMicMuted = !_isMicMuted;
              });
            },
          ),

          // Camera On/Off
          if (widget.isVideo)
            _buildActionButton(
              icon: _isCameraOff ? Icons.videocam_off_rounded : Icons.videocam_rounded,
              color: _isCameraOff ? Colors.redAccent : Colors.white24,
              tooltip: _isCameraOff ? 'Turn Camera On' : 'Turn Camera Off',
              onTap: () {
                setState(() {
                  _isCameraOff = !_isCameraOff;
                });
              },
            ),

          // Flip Camera
          if (widget.isVideo)
            _buildActionButton(
              icon: Icons.flip_camera_ios_rounded,
              color: Colors.white24,
              tooltip: 'Switch Camera',
              onTap: () {
                setState(() {
                  _isFrontCamera = !_isFrontCamera;
                });
              },
            ),

          // Speaker / Earpiece toggle
          _buildActionButton(
            icon: _isSpeakerOn ? Icons.volume_up_rounded : Icons.hearing_rounded,
            color: _isSpeakerOn ? AppColors.primary : Colors.white24,
            tooltip: _isSpeakerOn ? 'Speaker' : 'Earpiece',
            onTap: () {
              setState(() {
                _isSpeakerOn = !_isSpeakerOn;
              });
            },
          ),

          // Screen Share toggle
          if (widget.isVideo)
            _buildActionButton(
              icon: Icons.screen_share_rounded,
              color: _isScreenSharing ? Colors.cyanAccent : Colors.white24,
              tooltip: 'Share Screen',
              onTap: () {
                setState(() {
                  _isScreenSharing = !_isScreenSharing;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_isScreenSharing ? 'Screen sharing active' : 'Screen sharing stopped'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            ),

          // End Call (Red button)
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(32),
            child: Container(
              width: 54,
              height: 54,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.redAccent, blurRadius: 12, spreadRadius: 1),
                ],
              ),
              child: const Icon(Icons.call_end_rounded, color: Colors.white, size: 28),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}
