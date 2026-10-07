import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chatspace/models/message_model.dart';
import 'package:chatspace/widgets/custom_button.dart';
import 'package:chatspace/widgets/custom_text_field.dart';
import 'package:chatspace/widgets/message_bubble.dart';

void main() {
  group('ChatSpace UI Widget Tests', () {
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
      expect(find.byIcon(Icons.visibility), findsOneWidget);

      // Tap visibility toggle icon
      await tester.tap(find.byIcon(Icons.visibility));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });

    testWidgets('MessageBubble renders message text, timestamp, and status icon',
        (WidgetTester tester) async {
      final message = MessageModel(
        messageId: 'msg_test_01',
        senderId: 'user_1',
        receiverId: 'user_2',
        text: 'Hello from ChatSpace Widget Test!',
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

      expect(find.text('Hello from ChatSpace Widget Test!'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
      expect(find.byIcon(Icons.done_all), findsOneWidget);
    });
  });
}
