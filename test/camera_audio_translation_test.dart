import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chatspace/services/translation_service.dart';
import 'package:chatspace/services/audio_playback_service.dart';
import 'package:chatspace/services/camera_capture_service.dart';
import 'package:chatspace/services/speech_recognition_service.dart';
import 'package:chatspace/services/mock_data_service.dart';
import 'package:chatspace/widgets/chat_wallpaper_background.dart';
import 'package:chatspace/widgets/standard_qr_code.dart';

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

  group('StandardQrCode Tests', () {
    testWidgets('StandardQrCode renders with custom dimensions', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: StandardQrCode(
                data: 'upi://pay?pa=chatspace@upi&pn=UniversalChat&am=100',
                size: 180,
                showFrame: true,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(StandardQrCode), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });
  });

  group('SpeechRecognitionService Tests', () {
    test('SpeechRecognitionService VM stub reports not supported', () {
      final speech = SpeechRecognitionService.instance;
      expect(speech.isSupported, isFalse);
      expect(speech.isListening, isFalse);
    });

    test('SpeechRecognitionService start and stop run safely on VM', () {
      final speech = SpeechRecognitionService.instance;
      expect(() => speech.startListening(
        onResult: (text, isFinal) {},
        onError: (err) {},
        onEnd: () {},
      ), returnsNormally);
      expect(() => speech.stopListening(), returnsNormally);
    });
  });

  group('MockDataService Contact & QR Tests', () {
    test('addContactByPhone adds contact with valid phone number', () {
      final mock = MockDataService.instance;
      final newContact = mock.addContactByPhone(
        name: 'Priya Sharma',
        phone: '+91 98765 12345',
      );

      expect(newContact.name, equals('Priya Sharma'));
      expect(newContact.phone, equals('+91 98765 12345'));
      expect(mock.mockUsers.any((u) => u.phone == '+91 98765 12345'), isTrue);
    });

    test('connectUserByQr connects and returns user model', () {
      final mock = MockDataService.instance;
      final connected = mock.connectUserByQr(
        uid: 'user_qr_test_99',
        name: 'Vikram Malhotra',
        phone: '+91 98220 54321',
      );

      expect(connected.uid, equals('user_qr_test_99'));
      expect(connected.name, equals('Vikram Malhotra'));
      expect(connected.phone, equals('+91 98220 54321'));
      expect(mock.mockUsers.any((u) => u.uid == 'user_qr_test_99'), isTrue);
    });
  });
}
