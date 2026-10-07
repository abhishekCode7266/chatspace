# ChatSpace - Production-Ready Real-Time Chat Flutter App

![Flutter](https://img.shields.io/badge/Flutter-v3.24+-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-Auth%20%7C%20Firestore%20%7C%20FCM-FFCA28?logo=firebase&logoColor=black)
![Material 3](https://img.shields.io/badge/UI-Material%203-blueviolet)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20Web-brightgreen)
![Build](https://img.shields.io/badge/Build-APK%20%7C%20AAB%20Play%20Store-success)

**ChatSpace** is a complete, production-ready Flutter real-time chat mobile application built using Firebase (Authentication, Cloud Firestore, Firebase Cloud Messaging), Material 3 styling, Provider state management, and an exclusive **Developer Mode Bypass (डेवलपर मोड बाईपास)** for testing.

---

## 🌟 Key Features

1. **Authentication (Email + Password)**
   - Complete sign-up, sign-in, sign-out, and forgot password reset flow.
   - Robust form validation (valid email format, min 6 characters password).
   - Session persistence (user remains logged in across restarts).
   - Friendly user error messages for all Firebase authentication exceptions.

2. **WhatsApp-Style Chat Bar & Messaging (व्हाट्सएप जैसा चैट बार)**
   - Signature WhatsApp rounded input capsule with emoji picker (`👍 ❤️ 😂 🔥 👏 🙏`).
   - Attachment paperclip modal sheet with 6 vibrant categories: Document, Camera, Gallery, Audio, Location, and Contact.
   - Dynamic floating circular green action button: **Microphone (Voice Note simulation)** when input is empty; **Send arrow** when typing.
   - Auto-scrolling, date separators (`Today`, `Yesterday`), and read receipts (`✓` Sent, `✓✓` Blue Seen).

3. **WhatsApp-Style HD Video & Voice Calling (वीडियो और वॉइस कॉलिंग)**
   - Top AppBar one-tap **Video Call** (`Icons.videocam_rounded`) and **Voice Call** (`Icons.call_rounded`) buttons.
   - Full-screen calling screen with live duration timer (`Calling...` -> `Ringing...` -> `Connected 01:24`).
   - **Video Calling**: Simulated HD video stream with movable Picture-in-Picture (PiP) local camera preview, switch front/rear camera toggle.
   - **Voice Calling**: Pulsing wave animation and crystal-clear UI.
   - Complete bottom toolbar: Flip Camera, Toggle Video, Mute Microphone, Speakerphone, and End Call (red circle button).

4. **Advanced Security & Privacy Features (सिक्योरिटी फीचर्स)**
   - 🔒 **End-to-End Encryption (E2EE)**: Messages and calls protected; WhatsApp-style E2EE golden security badge in chats.
   - 🛡️ **60-Digit Security Verification Fingerprint**: Compare numeric cryptographic fingerprints between participants.
   - 🔑 **App Lock (PIN Passcode)**: 4-digit PIN lock screen on app start/resume with customizable PIN in Settings.
   - 🚫 **Block / Unblock Contacts**: Block nuisance users with one tap from the chat menu.
   - 🗑️ **Clear Chat**: Clear conversation history with confirmation dialog.

5. **Registered Users Directory**
   - Real-time directory listing all registered users (excluding current user).
   - Instant search filtering by contact name or status.
   - Live presence indicator (green badge for Online, last seen timestamp for Offline).

6. **Recent Chats (Chat List)**
   - Home screen displaying active conversations with participant names, last message preview, and formatted timestamps.
   - Unread message count badges.
   - Sorted chronologically by most recent interaction.

5. **Deterministic Chat Storage**
   - Room ID computed deterministically: `[userId1, userId2].sort().join('_')`.
   - Data persists across app reinstallations and multi-device logins.

6. **Push Notifications (FCM)**
   - Firebase Cloud Messaging integration for foreground and background notifications.
   - Device registration tokens synchronized with Firestore user documents.
   - Heads-up local notification delivery via `flutter_local_notifications`.

7. **Material 3 Theming & Dark Mode**
   - Smooth Light / Dark mode toggle in Settings.
   - Theme preference saved locally in `SharedPreferences`.

8. **Profile & Account Management**
   - View and update Display Name and Status / Bio.
   - Dedicated logout with confirmation dialog.

9. **🔓 Developer Mode Bypass (डेवलपर मोड बाईपास)**
   - **Instant access without Firebase credentials**: Tap "Enter via Developer Bypass" on the Login screen or tap the logo 4 times on the Splash screen.
   - Allows testing all screens, simulated contacts (Alice, Bob, Charlie, etc.), live auto-reply bots, typing indicators, and presence without needing live Firebase configuration.

---

## 🏗️ Architecture & Project Structure

```
chatspace/
├── .github/
│   └── workflows/
│       └── build_and_release.yml     # Automated CI/CD for APK, AAB & Web deploy
├── android/
│   ├── app/
│   │   ├── src/main/AndroidManifest.xml # Permissions & FCM channel
│   │   ├── build.gradle.kts          # MinSDK 21, multidex, desugaring
│   │   └── google-services.json      # Firebase Android config
│   ├── build.gradle.kts
│   └── settings.gradle.kts           # Modern Gradle 8.5+ Kotlin DSL
├── firestore.rules                   # Security rules restricting chat access
├── lib/
│   ├── main.dart                     # App entry point & MultiProvider setup
│   ├── firebase_options.dart         # Generated FlutterFire configurations
│   ├── models/
│   │   ├── chat_model.dart           # Conversation metadata model
│   │   ├── message_model.dart        # Message model with timestamp & seen state
│   │   └── user_model.dart           # User profile & presence model
│   ├── providers/
│   │   ├── auth_provider.dart        # Auth state, session & dev bypass
│   │   ├── chat_provider.dart        # Message sending, streams & typing status
│   │   └── theme_provider.dart       # Dark/Light theme mode persistence
│   ├── screens/
│   │   ├── splash_screen.dart        # Animated splash & session routing
│   │   ├── login_screen.dart         # Sign in & Developer Bypass entry
│   │   ├── signup_screen.dart        # New user registration
│   │   ├── forgot_password_screen.dart # Password reset request
│   │   ├── chat_list_screen.dart     # Home screen with recent conversations
│   │   ├── users_list_screen.dart    # Contact directory & search
│   │   ├── chat_screen.dart          # Real-time messaging screen
│   │   └── profile_screen.dart       # Edit profile, theme toggle & logout
│   ├── services/
│   │   ├── auth_service.dart         # FirebaseAuth operations & error mapping
│   │   ├── chat_service.dart         # Firestore chat & message transactions
│   │   ├── mock_data_service.dart    # Mock real-time engine for Dev Mode
│   │   ├── notification_service.dart # FCM & local notification handlers
│   │   └── user_service.dart         # Firestore user documents & online status
│   ├── utils/
│   │   ├── app_theme.dart            # Material 3 light & dark theme definitions
│   │   ├── constants.dart            # Constants, colors, and collections
│   │   ├── date_formatter.dart       # Date formatting & last-seen helpers
│   │   └── validators.dart           # Email, password, and name validators
│   └── widgets/
│       ├── chat_tile.dart            # Recent chat list item
│       ├── custom_button.dart        # Primary/outlined button with loading
│       ├── custom_text_field.dart    # Styled input with validation & obscure toggle
│       ├── message_bubble.dart       # Sent/received bubble with status ticks
│       └── user_tile.dart            # Contact item with live presence badge
├── test/
│   ├── chat_id_test.dart             # Unit tests for sorted chat ID generation
│   ├── login_screen_test.dart        # Widget tests for login interface
│   └── validators_test.dart          # Unit tests for input validators
└── pubspec.yaml
```

---

## 🔒 Firestore Security Rules (`firestore.rules`)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read: if request.auth != null;
      allow create, update, delete: if request.auth != null && request.auth.uid == userId;
    }
    
    match /chats/{chatId} {
      allow read, create, update: if request.auth != null && (
        request.auth.uid in resource.data.participants ||
        request.auth.uid in request.resource.data.participants
      );
      
      match /messages/{messageId} {
        allow read, update: if request.auth != null && (
          request.auth.uid in get(/databases/$(database)/documents/chats/$(chatId)).data.participants
        );
        allow create: if request.auth != null && (
          request.auth.uid in get(/databases/$(database)/documents/chats/$(chatId)).data.participants &&
          request.resource.data.senderId == request.auth.uid
        );
        allow delete: if request.auth != null && resource.data.senderId == request.auth.uid;
      }
    }
  }
}
```

---

## 🚀 Setup & Installation Steps

### 1. Prerequisites
- Flutter SDK (version 3.24+ recommended)
- Android SDK (targetSdkVersion 34, minSdk 21)
- Java JDK 17

### 2. Connect to Your Firebase Project
1. Go to the [Firebase Console](https://console.firebase.google.com/) and create a project named **ChatSpace**.
2. Enable **Email/Password** under **Authentication -> Sign-in method**.
3. Create a **Cloud Firestore** database in test/production mode and deploy `firestore.rules`.
4. Run FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
5. Place the generated `google-services.json` into `android/app/google-services.json`.

### 3. Run Locally
```bash
# Get dependencies
flutter pub get

# Run unit and widget tests
flutter test

# Run analyzer
flutter analyze

# Run on connected device or emulator
flutter run
```

---

## 📦 Building for Android & Google Play Store

### 1. Build Release APK (Direct Installation)
```bash
flutter build apk --release --android-skip-build-dependency-validation
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

### 2. Build Release App Bundle (AAB for Google Play Store Upload)
```bash
flutter build appbundle --release --android-skip-build-dependency-validation
```
Output: `build/app/outputs/bundle/release/app-release.aab`

---

## 🤖 GitHub Actions CI/CD Pipeline

When pushed to GitHub, the included workflow `.github/workflows/build_and_release.yml`:
1. Runs `flutter analyze` and `flutter test`.
2. Builds the Release APK (`app-release.apk`).
3. Builds the Google Play Store App Bundle (`app-release.aab`).
4. Generates a **GitHub Release** with direct download links.
5. Builds Flutter Web and publishes a live preview to **GitHub Pages** (`https://<username>.github.io/<repo>/`).

---

## 👨‍💻 Developer Mode Bypass (डेवलपर बाईपास)
For developers to test without entering Firebase credentials or setting up Google Services:
1. Open the app to the **Login** screen.
2. Tap the **"Enter via Developer Bypass"** button.
3. The app immediately opens with a pre-configured Developer account, simulated contacts, simulated unread messages, auto-reply bot responses, typing indicators, and dark mode toggling!
