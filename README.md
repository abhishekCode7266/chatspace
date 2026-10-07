# WhatsChat - WhatsApp-like Flutter Messaging & HD Calling App

![Flutter](https://img.shields.io/badge/Flutter-v3.24+-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-Auth%20%7C%20Firestore%20%7C%20FCM-FFCA28?logo=firebase&logoColor=black)
![UI](https://img.shields.io/badge/UI-WhatsApp%203--Tab%20Style-25D366?logo=whatsapp&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20Web-brightgreen)
![Build](https://img.shields.io/badge/Build-APK%20%7C%20AAB%20Play%20Store-success)

**WhatsChat** is a production-ready, feature-rich messaging and calling mobile application built with Flutter, Material 3, Firebase, and Provider. It replicates the core WhatsApp experience with a **3-tab layout (Chats, Status, Calls)**, **HD Voice & Video Calling**, **Status Story viewer with 5-second auto-progression**, **Message Reactions**, **Voice Note Audio Player**, **End-to-End Encryption (E2EE)**, and an exclusive **Developer Mode Bypass (डेवलपर मोड बाईपास)** for testing.

---

## 📱 Quick Links & Downloads

- 🌐 **Live Web Demo**: [https://abhishekcode7266.github.io/chatspace/](https://abhishekcode7266.github.io/chatspace/)
- 📦 **Download Android APK**: [GitHub Releases - app-release.apk](https://github.com/abhishekCode7266/chatspace/releases/latest)
- 🏬 **Google Play Store App Bundle**: [GitHub Releases - app-release.aab](https://github.com/abhishekCode7266/chatspace/releases/latest)
- 🎨 **Play Store Official Logo (512x512)**: `playstore_assets/whatschat_icon_512.jpg`

---

## 🌟 Core Features

### 1. WhatsApp 3-Tab Architecture (व्हाट्सएप 3-टैब लेआउट)
- **CHATS**: Recent conversation list with user avatars, unread message badges, last message previews, search filter, and floating new chat button.
- **STATUS**: 
  - "My Status" card with "+" badge to post new status updates with customizable background colors and text.
  - "Recent updates" ringed in WhatsApp emerald green for unviewed stories.
  - "Viewed updates" ringed in grey.
  - **Full-Screen Status Viewer**: WhatsApp-style story screen with 5-second animated top progress bar, auto-advancement, pause on touch, and instant reply box.
- **CALLS**: Complete call logs with incoming/outgoing/missed arrow indicators, timestamps, call durations, and 1-tap quick buttons to launch HD Voice or Video calls.

### 2. HD Voice & Video Calling (वॉइस और वीडियो कॉलिंग)
- **HD Video Call**: High-definition video calling with Picture-in-Picture (PiP) local camera preview, camera flip (front/back), camera mute, mic mute, speaker toggle, and live duration timer.
- **Crystal-Clear Voice Call**: Voice calling mode with audio wave visualizer and call controls.
- **Automatic Call Logging**: Every call is automatically recorded in the Calls tab history with accurate timestamps and duration.

### 3. WhatsApp Chat Bar & Message Reactions
- **Message Reactions (रिएक्शन)**: Long press any message bubble to trigger the WhatsApp reaction picker (`👍 ❤️ 😂 😮 😢 🙏`) with real-time reaction badge pill displayed on the bubble.
- **Voice Note Audio Player (ऑडियो प्लेयर)**: Dedicated audio message bubble with circular Play/Pause toggle, audio waveform visualizer, and duration indicator (`0:14`).
- **Signature Chat Bar**: Rounded input pill with emoji picker, attachment clip bottom sheet (Documents, Camera, Gallery, Audio, Location, Contact), and dynamic Mic/Send action button.
- **Status Indicators**: Single tick (`✓`) for sent, double blue ticks (`✓✓`) for seen.

### 4. Advanced Security & Privacy (सिक्योरिटी)
- 🔒 **End-to-End Encryption (E2EE)**: Cryptographic protection for all messages and calls.
- 🛡️ **60-Digit Cryptographic Verification Code**: Compare 60-digit security fingerprints between chat participants.
- 🔑 **PIN App Lock**: 4-digit passcode lock on startup with custom PIN changer in Settings.
- 🚫 **Block/Unblock Contacts**: Block nuisance users with 1-tap.

### 5. 🔓 Developer Mode Bypass (डेवलपर मोड बाईपास)
- **Instant access without Firebase credentials**: Tap "Enter via Developer Bypass" on the Login screen, or tap the logo 4 times on the Splash screen.
- Allows testing all screens, simulated contacts (Alice, Bob, Charlie, Diana, Evan), real-time message replies, status stories, and call logs!

---

## 🏗️ Project Structure

```
chatspace/
├── .github/
│   └── workflows/
│       └── build_and_release.yml    # CI/CD: Tests, APK, AAB, Web deploy & Release
├── assets/
│   └── images/
│       └── app_logo.jpg             # 3D WhatsChat official logo
├── playstore_assets/
│   └── whatschat_icon_512.jpg       # Google Play Store 512x512 High-Res Icon
├── lib/
│   ├── main.dart                    # App root & MultiProvider configuration
│   ├── firebase_options.dart        # Platform-specific Firebase credentials
│   ├── models/
│   │   ├── call_model.dart          # Video & voice call history model
│   │   ├── chat_model.dart          # Chat conversation model
│   │   ├── message_model.dart       # Message bubble model (reactions & audio)
│   │   ├── status_model.dart        # WhatsApp status story model
│   │   └── user_model.dart          # User profile model
│   ├── providers/
│   │   ├── auth_provider.dart       # Firebase Auth & developer bypass state
│   │   ├── chat_provider.dart       # Real-time messages, calls, status & reactions
│   │   └── theme_provider.dart      # Dark/Light theme toggle persistence
│   ├── screens/
│   │   ├── app_lock_screen.dart     # 4-digit PIN Passcode screen
│   │   ├── call_screen.dart         # Fullscreen HD Video & Voice Call screen
│   │   ├── chat_list_screen.dart    # WhatsApp 3-Tab HomeScreen (Chats/Status/Calls)
│   │   ├── chat_screen.dart         # Chat view with reactions, audio & E2EE banner
│   │   ├── forgot_password_screen.dart # Email password reset
│   │   ├── login_screen.dart        # Login + Developer Bypass button
│   │   ├── profile_screen.dart      # Profile, PIN lock & Dark mode settings
│   │   ├── signup_screen.dart       # User registration
│   │   ├── splash_screen.dart       # Animated splash with secret bypass tap
│   │   ├── status_view_screen.dart  # WhatsApp story viewer with 5s progress bar
│   │   └── users_list_screen.dart   # Registered contacts directory
│   ├── services/
│   │   ├── auth_service.dart        # Firebase Authentication service
│   │   ├── chat_service.dart        # Cloud Firestore messaging service
│   │   ├── encryption_service.dart  # AES-256 E2EE cipher & fingerprint generator
│   │   ├── mock_data_service.dart   # Developer Bypass mock data engine
│   │   ├── notification_service.dart# FCM & local notifications
│   │   ├── security_service.dart    # PIN Lock & blocked users management
│   │   └── user_service.dart        # Firestore user directory service
│   ├── utils/
│   │   ├── app_theme.dart           # WhatsApp Emerald Light & Dark theme definitions
│   │   ├── constants.dart           # AppConstants & AppColors
│   │   ├── date_formatter.dart      # Timestamps and date separators
│   │   └── validators.dart          # Form input validation rules
│   └── widgets/
│       ├── chat_tile.dart           # Recent chat tile widget
│       ├── custom_button.dart       # Styled button with loading state
│       ├── custom_text_field.dart   # Form text field with password visibility
│       ├── message_bubble.dart      # Message bubble with reactions & audio player
│       └── user_tile.dart           # Contact user tile widget
└── test/
    ├── chat_id_test.dart            # Deterministic chat room ID test
    ├── chat_widgets_test.dart       # Widget tests (MessageBubble, reactions, audio, models)
    ├── security_encryption_test.dart# Encryption, fingerprint & PIN lock tests
    └── validators_test.dart         # Email, password & form validation tests
```

---

## 🚀 How to Run Locally

### 1. Prerequisites
- Flutter SDK (v3.24+ recommended)
- Android Studio / VS Code

### 2. Clone & Install
```bash
git clone https://github.com/abhishekCode7266/chatspace.git
cd chatspace
flutter pub get
```

### 3. Run Unit & Widget Tests
```bash
flutter test
```

### 4. Build Android Release APK & Play Store Bundle
```bash
# Build Android APK
flutter build apk --release

# Build Google Play Store App Bundle (.aab)
flutter build appbundle --release
```

---

## 📄 License
This project is open-source and free for personal, commercial, and educational use.
