import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:chatspace/providers/auth_provider.dart';
import 'package:chatspace/providers/chat_provider.dart';
import 'package:chatspace/providers/theme_provider.dart';
import 'package:chatspace/screens/login_screen.dart';
import 'package:chatspace/widgets/custom_button.dart';
import 'package:chatspace/widgets/custom_text_field.dart';

void main() {
  testWidgets('LoginScreen renders email, password, login button, and dev bypass',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => ChatProvider()),
        ],
        child: const MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Title & Tagline
    expect(find.text('Welcome to ChatSpace'), findsOneWidget);

    // Verify TextFields
    expect(find.byType(CustomTextField), findsNWidgets(2));
    expect(find.text('Email address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);

    // Verify Buttons
    expect(find.byType(CustomButton), findsNWidgets(2));
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Enter via Developer Bypass'), findsOneWidget);

    // Verify Sign Up link
    expect(find.text('Sign Up'), findsOneWidget);
  });
}
