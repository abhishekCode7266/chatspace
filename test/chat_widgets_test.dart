import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chatspace/models/message_model.dart';
import 'package:chatspace/models/call_model.dart';
import 'package:chatspace/models/status_model.dart';
import 'package:chatspace/widgets/custom_button.dart';
import 'package:chatspace/widgets/custom_text_field.dart';
import 'package:chatspace/widgets/message_bubble.dart';

void main() {
  group('WhatsChat UI Widget & Model Tests', () {
    testWidgets('CustomButton displays text and triggers callback',
        (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Send Message',
              onPressed: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Send Message'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      await tester.tap(find.byType(CustomButton));
      expect(tapped, isTrue);
    });

    testWidgets('CustomButton displays loading spinner when isLoading is true',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Submit',
              isLoading: true,
              onPressed: null,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('CustomTextField renders with hint and toggles password visibility',
        (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              controller: controller,
              hintText: 'Enter Password',
              isPassword: true,
            ),
          ),
        ),
      );

      expect(find.text('Enter Password'), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);

      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets('MessageBubble renders message text, timestamp, and status icon',
        (WidgetTester tester) async {
      final message = MessageModel(
        messageId: 'msg_test_01',
        senderId: 'user_1',
        receiverId: 'user_2',
        text: 'Hello from WhatsChat Widget Test!',
        timestamp: DateTime(2026, 10, 7, 14, 30),
        isSeen: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(
              message: message,
              isMe: true,
              showDateSeparator: true,
              dateSeparatorText: 'Today',
            ),
          ),
        ),
      );

      expect(find.text('Hello from WhatsChat Widget Test!'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
      expect(find.byIcon(Icons.done_all), findsOneWidget);
    });

    testWidgets('MessageBubble renders reaction badge when reaction is present',
        (WidgetTester tester) async {
      final message = MessageModel(
        messageId: 'msg_test_02',
        senderId: 'user_1',
        receiverId: 'user_2',
        text: 'Message with WhatsApp reaction ❤️',
        timestamp: DateTime(2026, 10, 7, 14, 32),
        isSeen: true,
        reaction: '❤️',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(
              message: message,
              isMe: true,
            ),
          ),
        ),
      );

      expect(find.text('❤️'), findsOneWidget);
    });

    testWidgets('MessageBubble renders voice note waveform and duration for audio messages',
        (WidgetTester tester) async {
      final audioMsg = MessageModel(
        messageId: 'msg_test_03',
        senderId: 'user_2',
        receiverId: 'user_1',
        text: 'Voice note (0:14)',
        timestamp: DateTime(2026, 10, 7, 14, 35),
        isSeen: true,
        messageType: 'audio',
        audioDuration: '0:14',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(
              message: audioMsg,
              isMe: false,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
      expect(find.byIcon(Icons.mic_rounded), findsOneWidget);
      expect(find.text('0:14'), findsOneWidget);

      // Tap play button
      await tester.tap(find.byIcon(Icons.play_arrow_rounded));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.pause_rounded), findsOneWidget);
    });

    test('CallModel serialization and properties', () {
      final call = CallModel(
        callId: 'call_101',
        callerId: 'u1',
        receiverId: 'u2',
        callerName: 'Alice',
        timestamp: DateTime(2026, 10, 7, 15, 0),
        durationSeconds: 120,
        isVideo: true,
        isMissed: false,
        isOutgoing: true,
      );

      final map = call.toMap();
      expect(map['callId'], equals('call_101'));
      expect(map['isVideo'], isTrue);
      expect(map['durationSeconds'], equals(120));

      final restored = CallModel.fromMap(map);
      expect(restored.callId, equals('call_101'));
      expect(restored.callerName, equals('Alice'));
      expect(restored.isVideo, isTrue);
    });

    test('StatusModel serialization and properties', () {
      final status = StatusModel(
        statusId: 'stat_101',
        userId: 'u1',
        userName: 'Charlie',
        text: 'Testing WhatsChat Status!',
        backgroundColorHex: 0xFF005C4B,
        timestamp: DateTime(2026, 10, 7, 15, 10),
        isViewed: false,
      );

      final map = status.toMap();
      expect(map['statusId'], equals('stat_101'));
      expect(map['text'], equals('Testing WhatsChat Status!'));

      final restored = StatusModel.fromMap(map);
      expect(restored.userName, equals('Charlie'));
      expect(restored.backgroundColorHex, equals(0xFF005C4B));
      expect(restored.isViewed, isFalse);
    });
  });
}
