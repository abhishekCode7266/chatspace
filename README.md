# Universal Chat App (Universal App) 🌐💬🤖

![Flutter](https://img.shields.io/badge/Flutter-v3.24+-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-Auth%20%7C%20Firestore%20%7C%20FCM-FFCA28?logo=firebase&logoColor=black)
![UI](https://img.shields.io/badge/UI-Modern%20Material%203-6750A4?logo=materialdesign&logoColor=white)
![Security](https://img.shields.io/badge/Security-AES--256%20E2EE%20%2B%20PIN%20%2B%202FA-00BFA5)
![AI](https://img.shields.io/badge/AI-Universal%20AI%20Suite-00E5FF?logo=openai&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20Web%20%7C%20iOS%20%7C%20Desktop-brightgreen)
![Build](https://img.shields.io/badge/Build-APK%20%7C%20AAB%20Play%20Store-success)

**Universal Chat App** (Universal App) is an enterprise-grade, AI-powered, ultra-secure communication platform built with Flutter, Material 3, Firebase, and Provider. Designed for seamless mobile messaging, rich multimedia sharing, multi-participant group chats, verified tech news broadcast channels, group voice and video calls, bank-grade encryption, business e-commerce hub, real-time admin telemetry, and an exclusive draggable **Floating Developer Circle Bypass (छोटा सा गोला)**.

---

## 📱 Quick Links & Downloads

- 🌐 **Live Web App Preview**: [https://abhishekcode7266.github.io/chatspace/](https://abhishekcode7266.github.io/chatspace/)
- 📦 **Download Android APK (Direct Install)**: [GitHub Releases - app-release.apk (v1.4.0)](https://github.com/abhishekCode7266/chatspace/releases/download/v1.4.0/app-release.apk)
- 🏬 **Google Play Store App Bundle**: [GitHub Releases - app-release.aab (v1.4.0)](https://github.com/abhishekCode7266/chatspace/releases/download/v1.4.0/app-release.aab)
- 🎨 **Google Play Store 512x512 High-Res Icon**: `playstore_assets/universal_chat_icon_512.jpg`

---

## 🌟 Core Highlights & Feature Matrix

### 1. ⚡ Floating Developer Circle Bypass (छोटा सा गोला)
- **Draggable Pulsating Floating Badge (`FloatingDevCircle`)**: A small glowing circular badge floating on top of all screens with continuous pulse animation.
- **1-Tap Developer Suite**: Tapping the circle opens the **Developer Bypass & Inspection Suite** sheet.
- **Instant Security Bypass**: Bypass authentication, OTP, and PIN locks in 1-tap for lightning-fast testing and demonstration.
- **Simulation Tools**: Switch mock personas (Alice, Bob, Charlie), reset PIN, clear/restore mock databases, and trigger simulated incoming messages.

### 2. 🤖 Optimal Universal AI Suite
Access the dedicated AI Suite via the Top Bar or AppBar action with 5 intelligent tools:
- **AI Chat Assistant**: Multi-turn generative AI companion for instant question answering and productivity.
- **Message Summarizer**: Condenses long chat transcripts, threads, or meeting notes into structured action points.
- **Real-Time Language Translator**: Fast translation across English, Hindi, Spanish, French, German, Arabic, Chinese, and Japanese.
- **3D AI Image Generation**: Generates 3D futuristic graphics, avatar concepts, and UI mockups from text prompts.
- **Document & PDF Analysis**: Intelligent keyword and structure extraction from enterprise documents.

### 3. 👥 Multi-Participant Group Voice & Video Calls
- **HD Video Calling**: Full-screen video call with Picture-in-Picture (PiP) local preview.
- **Group Video Grid (`GroupCallScreen`)**: Responsive 2x2 grid layout supporting multiple participants with active speaker glow highlights.
- **Interactive Call Controls**: Mute/unmute microphone, switch front/rear cameras, screen sharing simulation, and speaker/earpiece audio routing.
- **Segmented History**: Distinct views and filters for **Voice Calls** and **Video Calls** with timestamps and duration counters.

### 4. 💼 Business Platform & Commerce Hub
- **Verified Business Profile**: Official business profile with address, opening hours, verified badge, email, and website.
- **Product Catalog**: Showcase products with high-resolution imagery, descriptions, and INR (₹) pricing.
- **Customer Quick-Order**: In-chat ordering workflow allowing customers to order products directly.
- **Automated Messaging**: Customizable automatic greeting messages and away replies.

### 5. 🛡️ Admin Command Center & Moderation Panel
- **Real-Time System Telemetry**: Live cards tracking total registered users, active online users, active groups, total messages sent, server uptime (99.98%), and average network latency (24ms).
- **User Management & Bans**: View registered accounts with 1-click ban/unban moderation controls.
- **Spam & Abuse Moderation**: Review reported incidents and automated spam detection flags.
- **Global Broadcast Tool**: Dispatch platform-wide announcements to all connected users instantly.

### 6. 💬 Next-Gen Advanced Messaging
- **Quoted Replies**: Swipe or tap to reply with quoted message previews.
- **Message Editing & Deletion**: Edit sent messages (with `(edited)` indicator) or delete for me / everyone.
- **Pinned Messages**: Pin essential messages to the top banner of the chat room.
- **Starred / Bookmarked Messages**: Dedicated repository screen for saved messages.
- **Interactive Voice Notes**: Waveform visualization, play/pause controls, and duration counters.
- **Rich Media & File Sharing**: Full-screen photo/video viewer with pinch-to-zoom, download progress, PDF documents, location cards, and contact vCards.
- **Emoji Reactions**: Express reactions (`👍`, `❤️`, `😂`, `😮`, `😢`, `🙏`).

### 7. 💻 Linked Devices & Multi-Device Sync
- Manage active sessions across Web and Desktop.
- Integrated camera QR code scanner simulation for 1-tap device pairing.
- Remote logout from all secondary devices.

### 8. ☁️ Cloud Backup & Storage Sync
- Real-time backup size calculation (Chats, Media, Settings).
- Animated Google Drive / Cloud sync progress indicator.
- 1-tap Restore and Auto-Backup frequency settings (Daily, Weekly, Monthly).

### 9. 🔒 Bank-Grade Privacy & Security
- **End-to-End Encryption (E2EE)**: Messages protected with AES-256 GCM cryptographic cipher.
- **60-Digit Cryptographic Fingerprint**: Security code verification with QR code sharing.
- **App Lock**: 4-digit PIN passcode lock with biometric fingerprint/face authentication toggle.
- **Two-Step Verification (2FA)**: Additional security layer for account registration.
- **Disappearing Messages**: Configurable message lifetimes (24 hours, 7 days, 90 days).

### 10. 🔍 Global Search Hub
- Unified search engine with category filter chips: `All`, `Users`, `Groups`, `Media`, `Documents`, `Audio`, `Links`.
- Date range picker to filter search results by timestamp.

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
│   │   ├── admin_model.dart         # System metrics & moderation reports
│   │   ├── ai_model.dart            # AI prompts, tools & responses
│   │   ├── business_model.dart      # Business profile, products & orders
│   │   ├── call_model.dart          # Voice, Video & Group call model
│   │   ├── channel_model.dart       # Broadcast Tech News Channel model
│   │   ├── chat_model.dart          # Chat model (groups, pinned, favorites, AI)
│   │   ├── message_model.dart       # Rich media, voice, replies, pins, edits
│   │   ├── status_model.dart        # WhatsApp-style status story model
│   │   └── user_model.dart          # User profile model
│   ├── providers/
│   │   ├── auth_provider.dart       # Authentication & Developer Bypass state
│   │   ├── chat_provider.dart       # Messages, channels, calls, filters & AI
│   │   └── theme_provider.dart      # Dark / Light Material 3 theme mode
│   ├── screens/
│   │   ├── admin_dashboard_screen.dart   # Admin Command Center & Telemetry
│   │   ├── ai_assistant_screen.dart      # Universal AI Suite (5 Tools)
│   │   ├── app_lock_screen.dart          # 4-Digit PIN passcode lock screen
│   │   ├── backup_sync_screen.dart       # Cloud Backup & Restore Hub
│   │   ├── business_profile_screen.dart  # Business Hub & Product Catalog
│   │   ├── call_screen.dart              # 1-to-1 Fullscreen HD Call UI
│   │   ├── channel_screen.dart           # Broadcast channel feed viewer
│   │   ├── chat_list_screen.dart         # 3-Tab UI + Filter Chips + Floating Circle
│   │   ├── chat_screen.dart              # E2EE Chat UI with replies & attachments
│   │   ├── community_screen.dart         # Community announcement channel
│   │   ├── dev_bypass_sheet.dart         # Developer Bypass Inspection Sheet
│   │   ├── group_call_screen.dart        # Multi-participant 2x2 video grid
│   │   ├── group_create_screen.dart      # Pick members & create new group chat
│   │   ├── linked_devices_screen.dart    # Web/Desktop QR sync management
│   │   ├── login_screen.dart             # Login + Developer Bypass action
│   │   ├── media_preview_screen.dart     # Fullscreen photo/video zoom viewer
│   │   ├── privacy_security_screen.dart  # App Lock, Biometrics & 2FA
│   │   ├── profile_screen.dart           # User profile & settings
│   │   ├── search_screen.dart            # Global Search Hub with filters
│   │   ├── signup_screen.dart            # Account registration
│   │   ├── splash_screen.dart            # Animated splash with secret bypass tap
│   │   ├── starred_messages_screen.dart  # Starred/Bookmarked messages repository
│   │   ├── status_view_screen.dart       # Story viewer with 5s animated progress bar
│   │   └── users_list_screen.dart        # Contact directory
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
│       ├── floating_dev_circle.dart # Draggable pulsating developer bypass button
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
