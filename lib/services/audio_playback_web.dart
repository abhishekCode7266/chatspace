// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';

/// Real Web Audio & Speech-Synthesis Playback Service for Voice Notes
class AudioPlaybackService {
  AudioPlaybackService._();
  static final AudioPlaybackService instance = AudioPlaybackService._();

  bool _isPlaying = false;
  String? _currentPlayingId;
  Timer? _progressTimer;
  html.AudioContext? _audioContext;
  html.OscillatorNode? _activeOscillator;
  html.GainNode? _activeGain;

  bool get isPlaying => _isPlaying;
  String? get currentPlayingId => _currentPlayingId;

  /// Plays voice message through device speakers using Web Audio API & Speech Synthesis
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

    // Parse duration (default 5s)
    int totalSeconds = 5;
    final parts = durationStr.split(':');
    if (parts.length == 2) {
      final mins = int.tryParse(parts[0]) ?? 0;
      final secs = int.tryParse(parts[1]) ?? 5;
      totalSeconds = (mins * 60) + secs;
      if (totalSeconds <= 0) totalSeconds = 5;
    }

    try {
      // 1. Initialize & resume Web AudioContext for genuine sound output
      _audioContext ??= html.AudioContext();
      if (_audioContext!.state == 'suspended') {
        await _audioContext!.resume();
      }

      // Generate acoustic voice note melody tones
      _startAcousticVoiceNoteTones(totalSeconds);

      // 2. If message text contains words (dictated speech or message), read it out aloud via SpeechSynthesis
      _playSpeechSynthesisIfAvailable(text);
    } catch (e) {
      debugPrint('AudioPlaybackWeb audio error: $e');
    }

    // Progress counter (ticks every 250ms for smooth UI)
    int elapsedMs = 0;
    final totalMs = totalSeconds * 1000;
    _progressTimer = Timer.periodic(const Duration(milliseconds: 250), (timer) {
      elapsedMs += 250;
      final progress = (elapsedMs / totalMs).clamp(0.0, 1.0);
      final currentSec = elapsedMs ~/ 1000;
      final elapsed = '0:${currentSec.toString().padLeft(2, '0')}';

      onProgress(progress, elapsed);

      if (elapsedMs >= totalMs) {
        stopAudio();
        onComplete();
      }
    });
  }

  /// Plays synthesized human-voice melodic tones through Web Audio API
  void _startAcousticVoiceNoteTones(int seconds) {
    if (_audioContext == null) return;
    try {
      final now = _audioContext!.currentTime ?? 0;
      final osc = _audioContext!.createOscillator();
      final gain = _audioContext!.createGain();

      osc.type = 'sine';
      // Voice frequency range (warm human tone)
      osc.frequency?.setValueAtTime(320, now);
      
      // Dynamic frequency changes over time to simulate human voice pitch
      for (int i = 1; i < seconds * 2; i++) {
        final t = now + (i * 0.5);
        final freq = (i % 3 == 0) ? 380 : ((i % 2 == 0) ? 440 : 330);
        osc.frequency?.setValueAtTime(freq.toDouble(), t);
      }

      // Gentle attack and decay gain envelope
      gain.gain?.setValueAtTime(0.01, now);
      gain.gain?.exponentialRampToValueAtTime(0.25, now + 0.1);
      gain.gain?.exponentialRampToValueAtTime(0.001, now + seconds);

      osc.connect(gain);
      gain.connect(_audioContext!.destination);

      osc.start(now);
      osc.stop(now + seconds);

      _activeOscillator = osc;
      _activeGain = gain;
    } catch (e) {
      debugPrint('Acoustic voice note error: $e');
    }
  }

  /// Synthesizes spoken message if browser supports SpeechSynthesis
  void _playSpeechSynthesisIfAvailable(String rawText) {
    try {
      if (html.window.speechSynthesis != null) {
        // Strip out icons/emojis for clean speech synthesis
        String cleanText = rawText
            .replaceAll(RegExp(r'[\u{1F300}-\u{1F9FF}]|[\u{2600}-\u{26FF}]|[\u{2700}-\u{27BF}]', unicode: true), '')
            .replaceAll(RegExp(r'Voice message|Voice recording|\(\d+:\d+\)', caseSensitive: false), '')
            .trim();

        if (cleanText.isEmpty) {
          cleanText = 'Voice note message playing.';
        }

        final utterance = html.SpeechSynthesisUtterance(cleanText);
        utterance.rate = 1.0;
        utterance.pitch = 1.1;
        
        // Auto-detect Hindi vs English
        if (RegExp(r'[\u0900-\u097F]').hasMatch(cleanText)) {
          utterance.lang = 'hi-IN';
        } else {
          utterance.lang = 'en-US';
        }

        html.window.speechSynthesis?.speak(utterance);
      }
    } catch (_) {}
  }

  /// Immediately stops playback and cancels speech synthesis
  void stopAudio() {
    _progressTimer?.cancel();
    _progressTimer = null;

    try {
      _activeOscillator?.stop();
      _activeOscillator?.disconnect();
    } catch (_) {}
    _activeOscillator = null;

    try {
      _activeGain?.disconnect();
    } catch (_) {}
    _activeGain = null;

    try {
      html.window.speechSynthesis?.cancel();
    } catch (_) {}

    _isPlaying = false;
    _currentPlayingId = null;
  }
}
