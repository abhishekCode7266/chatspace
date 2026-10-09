import 'package:flutter_test/flutter_test.dart';
import 'package:chatspace/services/translation_service.dart';
import 'package:chatspace/services/audio_playback_service.dart';
import 'package:chatspace/services/camera_capture_service.dart';
import 'package:chatspace/widgets/chat_wallpaper_background.dart';

void main() {
  group('TranslationService Tests', () {
    final service = TranslationService.instance;

    test('Supported languages list contains all 12 key languages', () {
      final codes = TranslationService.supportedLanguages.map((l) => l.code).toList();
      expect(codes, containsAll(['hi', 'en', 'es', 'fr', 'de', 'ar', 'bn', 'mr', 'ta', 'te', 'gu', 'ur']));
      expect(TranslationService.supportedLanguages.length, equals(12));
    });

    test('Translates common English phrases to Hindi accurately', () async {
      final resHello = await service.translateText('Hello', targetLanguageCode: 'hi');
      expect(resHello, equals('नमस्ते!'));

      final resHow = await service.translateText('How are you', targetLanguageCode: 'hi');
      expect(resHow, equals('आप कैसे हैं?'));

      final resThanks = await service.translateText('Thank you', targetLanguageCode: 'hi');
      expect(resThanks, equals('बहुत-बहुत धन्यवाद!'));
    });

    test('Translates common English phrases to Spanish, French, and German', () async {
      final resEs = await service.translateText('Hello', targetLanguageCode: 'es');
      expect(resEs, equals('¡Hola!'));

      final resFr = await service.translateText('Hello', targetLanguageCode: 'fr');
      expect(resFr, equals('Bonjour!'));

      final resDe = await service.translateText('Hello', targetLanguageCode: 'de');
      expect(resDe, equals('Hallo!'));
    });

    test('Translates Hindi phrases to English', () async {
      final res = await service.translateText('नमस्ते', targetLanguageCode: 'en');
      expect(res, contains('Hello'));
    });

    test('Handles empty and whitespace text safely', () async {
      final empty = await service.translateText('   ', targetLanguageCode: 'hi');
      expect(empty, isEmpty);
    });
  });

  group('AudioPlaybackService Tests', () {
    final audio = AudioPlaybackService.instance;

    test('Audio service starts with isPlaying false', () {
      expect(audio.isPlaying, isFalse);
      expect(audio.currentPlayingId, isNull);
    });

    test('Audio service stopAudio resets state cleanly', () {
      audio.stopAudio();
      expect(audio.isPlaying, isFalse);
      expect(audio.currentPlayingId, isNull);
    });

    test('Audio service playAudioMessage sets isPlaying true and triggers progress', () async {
      double prog = 0.0;
      await audio.playAudioMessage(
        messageId: 'test_msg',
        text: 'hello',
        durationStr: '0:14',
        onProgress: (p, el) {
          prog = p;
        },
        onComplete: () {},
      );
      expect(audio.isPlaying, isTrue);
      expect(audio.currentPlayingId, equals('test_msg'));
      expect(prog, greaterThan(0.0));
      audio.stopAudio();
      expect(audio.isPlaying, isFalse);
    });
  });

  group('CameraCaptureService Tests', () {
    final camera = CameraCaptureService.instance;

    test('CameraCaptureService provides safe defaults on non-web VM', () {
      expect(camera.isWebLiveCameraSupported, isFalse);
    });

    test('disposeCamera runs safely without throwing', () {
      expect(() => camera.disposeCamera(), returnsNormally);
    });
  });

  group('ChatWallpapers Tests', () {
    test('Contains all 8 themes including WhatsApp Classic and Dark Doodle', () {
      expect(ChatWallpapers.allWallpapers.length, equals(8));
      final ids = ChatWallpapers.allWallpapers.map((w) => w.id).toList();
      expect(ids, containsAll([
        'default',
        'dark_doodle',
        'emerald',
        'midnight',
        'sunset',
        'cyberpunk',
        'rose',
        'clean_slate',
      ]));
    });

    test('getById returns matching wallpaper or fallback', () {
      final def = ChatWallpapers.getById('default');
      expect(def.name, equals('WhatsApp Classic'));
      expect(def.hasDoodle, isTrue);

      final dark = ChatWallpapers.getById('dark_doodle');
      expect(dark.name, equals('Dark Doodle'));

      final unknown = ChatWallpapers.getById('unknown_id');
      expect(unknown.id, equals('default'));
    });
  });
}
