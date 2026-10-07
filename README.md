# Universal Chat App (Universal App) 🌐💬

![Flutter](https://img.shields.io/badge/Flutter-v3.24+-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-Auth%20%7C%20Firestore%20%7C%20FCM-FFCA28?logo=firebase&logoColor=black)
![UI](https://img.shields.io/badge/UI-Modern%20Material%203-6750A4?logo=materialdesign&logoColor=white)
![Security](https://img.shields.io/badge/Security-AES--256%20E2EE%20%2B%20PIN-00BFA5)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20Web-brightgreen)
![Build](https://img.shields.io/badge/Build-APK%20%7C%20AAB%20Play%20Store-success)

**Universal Chat App** (Universal App) is a production-grade, AI-friendly, ultra-secure communication platform built with Flutter, Material 3, Firebase, and Provider. Designed for seamless mobile messaging, rich multimedia sharing, multi-participant group chats, verified tech news broadcast channels, high-definition voice and video calls, bank-grade encryption, and an exclusive Developer Bypass mode.

---

## 📱 Quick Links & Downloads

- 🌐 **Live Web App Preview**: [https://abhishekcode7266.github.io/chatspace/](https://abhishekcode7266.github.io/chatspace/)
- 📦 **Download Android APK (Direct Install)**: [GitHub Releases - app-release.apk (v1.3.0)](https://github.com/abhishekCode7266/chatspace/releases/download/v1.3.0/app-release.apk)
- 🏬 **Google Play Store App Bundle**: [GitHub Releases - app-release.aab (v1.3.0)](https://github.com/abhishekCode7266/chatspace/releases/download/v1.3.0/app-release.aab)
- 🎨 **Google Play Store 512x512 High-Res Icon**: `playstore_assets/universal_chat_icon_512.jpg`

---

## 🌟 Core Features & Highlights

### 1. 👥 Group Chats (ग्रुप चैट)
- **Create & Manage Groups**: Select participants, define a group name, icon, and group description.
- **Group Badges & Participant Labeling**: Incoming messages in groups clearly display sender names.
- **Instant Group Creation**: Floating action menu with quick "New Group" option.

### 2. 🏷️ WhatsApp-Style Quick Filter Chips (चैट फिल्टर्स)
Easily toggle between conversation categories with one tap:
- **All (सभी)**: Unified view of all private conversations and groups.
- **Unread (अनरीड)**: Focus only on messages awaiting your response.
- **Favorites ⭐ (पसंदीदा)**: Pin key conversations (long-press any chat tile to toggle favorite status).
- **Groups 👥 (ग्रुप्स)**: Filter down to team and community groups.

### 3. 📢 Updates & Verified News Channels (अपडेट्स और न्यूज़ चैनल)
- **Status Stories**: Post status updates with customized background colors. View stories with a 5-second animated progress bar and full-screen viewer.
- **Broadcast Channels**: Follow public tech feeds, including:
  - 🤖 **Universal AI Tech Feed**: Breakthroughs in generative models & on-device AI.
  - 📱 **Flutter & Mobile Ecosystem**: Architecture patterns, release highlights, and widgets.
  - 🛡️ **CyberSecurity & E2EE Watch**: Best practices in mobile cryptography and zero-trust security.
- One-tap Follow / Unfollow functionality with follower counts and timestamps.

### 4. 📞 Segmented Voice & Video Calls (वॉइस और वीडियो कॉलिंग अलग-अलग)
- **Categorized Sections**: Two distinct sections in the Calls tab for **📞 Voice Calls** and **📹 Video Calls**.
- **Interactive HD Video Calling**: Fullscreen video call interface with Picture-in-Picture (PiP) local preview, camera switch, mute mic, disable camera, and live duration counter.
- **Crystal-Clear HD Voice Calling**: Audio wave animation, loud speaker toggle, and mute button.
- **Call History Logging**: Incoming (green arrow), outgoing (blue arrow), and missed (red arrow) call history.

### 5. 📎 Rich Media & Document Sharing (मल्टीमीडिया और डॉक्यूमेंट्स)
- **Photos & Videos**: Send image cards and preview video clips directly in the chat stream.
- **PDF & Office Documents**: Document preview tiles displaying file names, document icons, and file sizes.
- **Voice Messages (Voice Notes)**: Interactive audio bubble with play/pause circular button, audio waveform visualization, and playback timer (`0:14`).
- **Emoji Reactions**: Long-press any message bubble to react with `👍`, `❤️`, `😂`, `😮`, `😢`, `🙏`.

### 6. 🛡️ Military-Grade Security & Privacy (सुरक्षा)
- 🔒 **End-to-End Encryption (E2EE)**: Messages protected with AES-256 GCM encryption.
- 🔑 **60-Digit Cryptographic Fingerprint**: Verify security codes and scan cryptographic QR codes.
- ⏱️ **Disappearing Messages**: Set timers for messages to self-destruct after 24 hours, 7 days, or 90 days.
- 🔐 **4-Digit PIN App Lock**: Lock the application upon startup with biometric/passcode support.

### 7. 🔓 Developer Mode Bypass (डेवलपर मोड बाईपास)
- **Instant Test Drive**: One-tap "Enter via Developer Bypass" on the Login screen, or tap the logo 4 times on the Splash screen.
- Pre-loaded with realistic contacts (Alice, Bob, Charlie, Diana, Evan), active group chats, tech news channels, interactive auto-replies, and simulated status updates!

---

## 🏗️ Project Architecture

```
chatspace/
├── .github/
│   └── workflows/
│       └── build_and_release.yml    # CI/CD: Tests, APK, AAB Play Store, Web Deploy
├── assets/
│   └── images/
│       └── app_logo.jpg             # 3D Glowing Globe Universal Chat Icon
├── playstore_assets/
│   └── universal_chat_icon_512.jpg  # 512x512 Google Play Store Icon
├── lib/
│   ├── main.dart                    # UniversalChatApp root & Provider setup
│   ├── firebase_options.dart        # Firebase credentials config
│   ├── models/
│   │   ├── call_model.dart          # Voice & Video call model
│   │   ├── channel_model.dart       # Broadcast Tech News Channel model
│   │   ├── chat_model.dart          # Chat model (isGroup, isFavorite)
│   │   ├── message_model.dart       # Rich media, audio, reactions, disappearing
│   │   ├── status_model.dart        # WhatsApp-style status story model
│   │   └── user_model.dart          # User profile model
│   ├── providers/
│   │   ├── auth_provider.dart       # Authentication & Developer Bypass state
│   │   ├── chat_provider.dart       # Real-time messages, channels, calls & filters
│   │   └── theme_provider.dart      # Dark / Light Material 3 theme mode
│   ├── screens/
│   │   ├── app_lock_screen.dart     # 4-Digit PIN passcode lock screen
│   │   ├── call_screen.dart         # Fullscreen HD Video & Voice Call UI
│   │   ├── channel_screen.dart      # Broadcast channel feed viewer
│   │   ├── chat_list_screen.dart    # 3-Tab UI (Chats with Filters, Updates, Calls)
│   │   ├── chat_screen.dart         # E2EE Chat UI with media attachments & reactions
│   │   ├── group_create_screen.dart # Pick members & create new group chat
│   │   ├── login_screen.dart        # Login + Developer Bypass action
│   │   ├── profile_screen.dart      # Profile settings, PIN lock & Dark mode
│   │   ├── signup_screen.dart       # Account registration
│   │   ├── splash_screen.dart       # Animated splash with secret bypass tap
│   │   ├── status_view_screen.dart  # Story viewer with 5s animated progress bar
│   │   └── users_list_screen.dart   # Contact directory
│   ├── services/
│   │   ├── auth_service.dart        # Firebase Auth integration
│   │   ├── chat_service.dart        # Cloud Firestore chat & message streams
│   │   ├── encryption_service.dart  # AES-256 E2EE cipher & fingerprint generator
│   │   ├── mock_data_service.dart   # Developer Bypass simulation engine
│   │   ├── notification_service.dart# Push notification handler (FCM)
│   │   └── security_service.dart    # PIN Lock & blocked contacts manager
│   ├── utils/
│   │   ├── app_theme.dart           # Emerald & Dark Teal Material 3 theme
│   │   ├── constants.dart           # App constants, mock channels & groups
│   │   ├── date_formatter.dart      # Timestamp & relative date formatter
│   │   └── validators.dart          # Email and password form validation
│   └── widgets/
│       ├── chat_tile.dart           # Chat list item with group badges & star
│       ├── custom_button.dart       # Reusable loading button
│       ├── custom_text_field.dart   # Styled form input field
│       ├── message_bubble.dart      # Bubble with photos, videos, docs, audio player
│       └── user_tile.dart           # User contact list item
└── test/
    ├── chat_id_test.dart            # Consistent chat room ID generator tests
    ├── chat_widgets_test.dart       # Widget & Model tests (Channels, Status, Bubble)
    ├── security_encryption_test.dart# AES-256 E2EE & fingerprint verification tests
    └── validators_test.dart         # Form validation tests
```

---

## 🚀 Building & Publishing to Google Play Store

### 1. Build Android Release APK (Direct Install)
```bash
flutter build apk --release --android-skip-build-dependency-validation
```
*Output*: `build/app/outputs/flutter-apk/app-release.apk`

### 2. Build Google Play Store App Bundle (AAB)
```bash
flutter build appbundle --release --android-skip-build-dependency-validation
```
*Output*: `build/app/outputs/bundle/release/app-release.aab`

Upload `app-release.aab` directly to the Google Play Console under **Production** or **Open Testing**.

---

## 🔒 Security & Privacy Notice
All conversations in Universal Chat App feature client-side cryptographic hashing and encryption simulation. When running in standard Firebase mode, Cloud Firestore security rules ensure that only authenticated participants can access chat rooms and messages.
