import 'package:flutter/foundation.dart';

/// Stub implementation of SpeechRecognitionService for non-web and VM test environments
class SpeechRecognitionService {
  SpeechRecognitionService._();
  static final SpeechRecognitionService instance = SpeechRecognitionService._();

  bool _isListening = false;
  bool get isSupported => false;
  bool get isListening => _isListening;

  Future<bool> startListening({
    String language = 'hi-IN',
    required void Function(String recognizedText, bool isFinal) onResult,
    required void Function(String error) onError,
    required void Function() onEnd,
  }) async {
    _isListening = true;
    debugPrint('SpeechRecognitionStub: Started simulated speech dictation ($language)');
    // Synchronously provide test recognition for unit tests
    onResult('नमस्ते! यह एक टेस्ट वॉयस मैसेज है।', true);
    _isListening = false;
    onEnd();
    return true;
  }

  void stopListening() {
    _isListening = false;
  }

  void cancelListening() {
    _isListening = false;
  }
}
