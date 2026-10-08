import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chatspace/models/message_model.dart';
import 'package:chatspace/models/call_model.dart';
import 'package:chatspace/models/channel_model.dart';
import 'package:chatspace/models/status_model.dart';
import 'package:chatspace/models/business_model.dart';
import 'package:chatspace/models/ai_model.dart';
import 'package:chatspace/models/admin_model.dart';
import 'package:chatspace/widgets/custom_button.dart';
import 'package:chatspace/widgets/custom_text_field.dart';
import 'package:chatspace/widgets/message_bubble.dart';

void main() {
  group('Universal Chat App UI Widget & Model Tests', () {
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
        text: 'Testing Universal Chat App Status!',
        backgroundColorHex: 0xFF005C4B,
        timestamp: DateTime(2026, 10, 7, 15, 10),
        isViewed: false,
      );

      final map = status.toMap();
      expect(map['statusId'], equals('stat_101'));
      expect(map['text'], equals('Testing Universal Chat App Status!'));

      final restored = StatusModel.fromMap(map);
      expect(restored.userName, equals('Charlie'));
      expect(restored.backgroundColorHex, equals(0xFF005C4B));
      expect(restored.isViewed, isFalse);
    });

    test('ChannelModel serialization and properties', () {
      final now = DateTime(2026, 10, 7, 12, 0);
      final channel = ChannelModel(
        channelId: 'ch_news_01',
        name: 'Universal AI Feed',
        handle: '@universal_ai',
        description: 'Latest breakthroughs in Universal Chat AI',
        followersCount: 15400,
        isVerified: true,
        category: 'Tech & AI',
        isFollowing: true,
        latestUpdate: 'AI Assistant features launched.',
        timestamp: now,
      );

      final map = channel.toMap();
      expect(map['channelId'], equals('ch_news_01'));
      expect(map['name'], equals('Universal AI Feed'));
      expect(map['followersCount'], equals(15400));
      expect(map['isVerified'], isTrue);

      final restored = ChannelModel.fromMap(map);
      expect(restored.name, equals('Universal AI Feed'));
      expect(restored.category, equals('Tech & AI'));
      expect(restored.isFollowing, isTrue);
    });

    test('ProductModel and BusinessProfileModel serialization', () {
      final product = ProductModel(
        id: 'prod_101',
        name: 'Enterprise Cloud Chat Plan',
        price: 2499.0,
        currency: '₹',
        description: 'Unlimited team channels and encrypted storage.',
        imageUrl: 'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=500',
        inStock: true,
        category: 'Software',
      );

      final pMap = product.toMap();
      expect(pMap['id'], equals('prod_101'));
      expect(pMap['price'], equals(2499.0));

      final restoredProd = ProductModel.fromMap(pMap);
      expect(restoredProd.name, equals('Enterprise Cloud Chat Plan'));
      expect(restoredProd.currency, equals('₹'));
      expect(restoredProd.inStock, isTrue);

      final biz = BusinessProfileModel(
        businessId: 'biz_01',
        businessName: 'Universal Solutions Ltd.',
        category: 'AI & Telecommunications',
        description: 'Global communication infrastructure.',
        email: 'corp@universalchat.app',
        website: 'https://universalchat.app',
        address: 'Universal Cyber City, Tower 5',
        workingHours: 'Mon - Sun: 24/7',
        isVerified: true,
      );

      final bMap = biz.toMap();
      expect(bMap['businessName'], equals('Universal Solutions Ltd.'));
      expect(bMap['isVerified'], isTrue);

      final restoredBiz = BusinessProfileModel.fromMap(bMap);
      expect(restoredBiz.businessId, equals('biz_01'));
      expect(restoredBiz.workingHours, equals('Mon - Sun: 24/7'));
    });

    test('OrderModel serialization and status', () {
      final order = OrderModel(
        orderId: 'ord_901',
        customerName: 'Aarav Sharma',
        productName: 'Universal AI Pro License',
        amount: 4999.0,
        status: 'Delivered',
        timestamp: DateTime(2026, 10, 8, 10, 0),
      );

      final oMap = order.toMap();
      expect(oMap['orderId'], equals('ord_901'));
      expect(oMap['status'], equals('Delivered'));

      final restoredOrder = OrderModel.fromMap(oMap);
      expect(restoredOrder.customerName, equals('Aarav Sharma'));
      expect(restoredOrder.amount, equals(4999.0));
    });

    test('AiPromptModel serialization for all AI tools', () {
      final aiChat = AiPromptModel(
        id: 'ai_001',
        prompt: 'Translate message to Spanish',
        response: 'Hola, ¿cómo estás hoy?',
        timestamp: DateTime(2026, 10, 8, 11, 0),
        type: 'translate',
      );

      final aMap = aiChat.toMap();
      expect(aMap['type'], equals('translate'));
      expect(aMap['response'], equals('Hola, ¿cómo estás hoy?'));

      final restoredAi = AiPromptModel.fromMap(aMap);
      expect(restoredAi.prompt, equals('Translate message to Spanish'));
      expect(restoredAi.type, equals('translate'));
    });

    test('SystemMetricsModel and ModerationReportModel properties', () {
      final metrics = SystemMetricsModel(
        lastUpdated: DateTime.now(),
        serverUptimePercent: 99.99,
        averageLatencyMs: 18,
      );
      expect(metrics.serverUptimePercent, equals(99.99));
      expect(metrics.averageLatencyMs, equals(18));
      expect(metrics.reportedIssues, equals(3));

      final report = ModerationReportModel(
        reportId: 'rep_12',
        reportedUserId: 'u_spammer',
        reportedUserName: 'Spam Bot',
        reporterName: 'Kavita Verma',
        reason: 'Unsolicited advertising',
        status: 'Pending',
        timestamp: DateTime(2026, 10, 8, 12, 0),
      );

      final rMap = report.toMap();
      expect(rMap['reportedUserId'], equals('u_spammer'));
      expect(rMap['reason'], equals('Unsolicited advertising'));

      final restoredReport = ModerationReportModel.fromMap(rMap);
      expect(restoredReport.reportId, equals('rep_12'));
      expect(restoredReport.status, equals('Pending'));
    });
  });
}

