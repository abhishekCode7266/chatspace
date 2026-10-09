import 'dart:async';

/// Non-web fallback implementation of AudioPlaybackService
class AudioPlaybackService {
  AudioPlaybackService._();
  static final AudioPlaybackService instance = AudioPlaybackService._();

  bool _isPlaying = false;
  String? _currentPlayingId;
  Timer? _playbackTimer;

  bool get isPlaying => _isPlaying;
  String? get currentPlayingId => _currentPlayingId;

  Future<void> playAudioMessage({
    required String messageId,
    required String text,
    required String durationStr,
    required void Function(double progress, String elapsed) onProgress,
    required void Function() onComplete,
  }) async {
    stopAudio();

    _isPlaying = true;
    _currentPlayingId = messageId;
    onProgress(0.1, '0:01');
  }

  void stopAudio() {
    _isPlaying = false;
    _currentPlayingId = null;
  }
}
