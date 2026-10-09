// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'dart:js';
import 'dart:js_util' as js_util;
import 'package:flutter/foundation.dart';

/// Web Speech Recognition Service using Browser Web Speech API
/// (webkitSpeechRecognition / SpeechRecognition)
class SpeechRecognitionService {
  SpeechRecognitionService._();
  static final SpeechRecognitionService instance = SpeechRecognitionService._();

  dynamic _recognitionInstance;
  bool _isListening = false;
  String _currentLanguage = 'hi-IN';

  bool get isListening => _isListening;
  String get currentLanguage => _currentLanguage;

  /// Checks if browser supports Web Speech Recognition
  bool get isSupported {
    try {
      return js_util.hasProperty(html.window, 'SpeechRecognition') ||
          js_util.hasProperty(html.window, 'webkitSpeechRecognition');
    } catch (_) {
      return false;
    }
  }

  /// Starts live microphone speech recognition
  Future<bool> startListening({
    String language = 'hi-IN',
    required void Function(String recognizedText, bool isFinal) onResult,
    required void Function(String error) onError,
    required void Function() onEnd,
  }) async {
    _currentLanguage = language;
    stopListening();

    try {
      final speechConstructor = js_util.getProperty(html.window, 'SpeechRecognition') ??
          js_util.getProperty(html.window, 'webkitSpeechRecognition');

      if (speechConstructor == null) {
        debugPrint('Web Speech Recognition API not available on this browser');
        onError('Speech recognition not supported in this browser. Please type or use Chrome/Edge.');
        return false;
      }

      final recognition = js_util.callConstructor(speechConstructor, []);
      _recognitionInstance = recognition;

      js_util.setProperty(recognition, 'continuous', true);
      js_util.setProperty(recognition, 'interimResults', true);
      js_util.setProperty(recognition, 'lang', language);

      js_util.setProperty(recognition, 'onstart', allowInterop((dynamic _) {
        _isListening = true;
        debugPrint('Web Speech Recognition started in $_currentLanguage');
      }));

      js_util.setProperty(recognition, 'onresult', allowInterop((dynamic event) {
        try {
          final results = js_util.getProperty(event, 'results');
          if (results == null) return;
          final int length = js_util.getProperty(results, 'length') ?? 0;

          String fullTranscript = '';
          bool isFinal = false;

          for (int i = 0; i < length; i++) {
            final resultItem = js_util.callMethod(results, 'item', [i]);
            if (resultItem != null) {
              final isFinalChunk = js_util.getProperty(resultItem, 'isFinal') == true;
              if (i == length - 1) {
                isFinal = isFinalChunk;
              }
              final firstAlternative = js_util.callMethod(resultItem, 'item', [0]);
              if (firstAlternative != null) {
                final transcript = js_util.getProperty(firstAlternative, 'transcript') ?? '';
                fullTranscript += '$transcript ';
              }
            }
          }

          final cleanTranscript = fullTranscript.trim();
          if (cleanTranscript.isNotEmpty) {
            onResult(cleanTranscript, isFinal);
          }
        } catch (e) {
          debugPrint('Error parsing speech recognition results: $e');
        }
      }));

      js_util.setProperty(recognition, 'onerror', allowInterop((dynamic event) {
        final err = js_util.getProperty(event, 'error')?.toString() ?? 'Speech recognition error';
        debugPrint('Speech recognition error: $err');
        _isListening = false;
        onError(err);
      }));

      js_util.setProperty(recognition, 'onend', allowInterop((dynamic _) {
        debugPrint('Speech recognition ended');
        _isListening = false;
        onEnd();
      }));

      js_util.callMethod(recognition, 'start', []);
      _isListening = true;
      return true;
    } catch (e) {
      debugPrint('Error starting Web Speech Recognition: $e');
      _isListening = false;
      onError(e.toString());
      return false;
    }
  }

  /// Stops listening gracefully
  void stopListening() {
    if (_recognitionInstance != null) {
      try {
        js_util.callMethod(_recognitionInstance, 'stop', []);
      } catch (_) {}
      _recognitionInstance = null;
    }
    _isListening = false;
  }

  /// Immediately cancels listening
  void cancelListening() {
    if (_recognitionInstance != null) {
      try {
        js_util.callMethod(_recognitionInstance, 'abort', []);
      } catch (_) {}
      _recognitionInstance = null;
    }
    _isListening = false;
  }
}
