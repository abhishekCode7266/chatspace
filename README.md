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
- 📦 **Download Android APK (Direct Install)**: [GitHub Releases - app-release.apk (v1.8.1)](https://github.com/abhishekCode7266/chatspace/releases/download/v1.8.1/app-release.apk)
- 🏬 **Google Play Store App Bundle**: [GitHub Releases - app-release.aab (v1.8.1)](https://github.com/abhishekCode7266/chatspace/releases/download/v1.8.1/app-release.aab)
- 🎨 **Google Play Store 512x512 High-Res Icon**: `playstore_assets/universal_chat_icon_512.jpg`

---

## 🌟 Core Highlights & Feature Matrix (v1.8.1)

### 1. 📸 Live Camera & Selfie Face Capture (कैमरा डायरेक्ट फोटो खींचे)
- **Direct Live Webcam & Camera Viewfinder**: WebRTC camera stream accessing user's real hardware camera / webcam with live viewfinder display.
- **Selfie Flip & Front/Rear Switching**: Effortlessly flip between front selfie view and rear HD environment view.
- **Canvas Shutter Snapshot**: Captures live video frame onto an HTML canvas with camera shutter acoustic sound effect, exporting as Base64 JPEG data URL sent straight to the chat.

### 2. 🎙️ Real Audible Voice Note Playback (माइक व असली आवाज़ प्लेबैक)
- **Authentic Speaker Output**: Voice notes produce genuine audible sound through device speakers using Web Audio API and Speech Synthesis.
- **Animated Audio Waveforms & Stopwatch**: Jumping waveform heights and synchronized `0:01 / 0:14` elapsed counter with auto-reset upon completion.

### 3. 🎨 WhatsApp Wallpapers & Chat Themes (थीम इमेज व वॉलपेपर)
- **8 Curated Themes**: WhatsApp Classic, Dark Doodle, Emerald Forest, Midnight Sky, Sunset Amber, Cyberpunk Neon, Rose Romance, and Clean Slate.
- **Custom WhatsApp Doodle Painter**: Draws iconic repeating doodle art (chat bubbles, coffee cups, hearts, stars, cameras, clocks).
- **Dedicated Themes Drawer Tab**: 4th tab in the drawer next to Emojis, GIFs, and Stickers for 1-tap wallpaper changes.

### 4. ⌨️ Keypad Autofocus & Quick Phrases (कीपैड व तुरंत जवाब)
- **कीपैड (Keyboard)**: Closes drawers and immediately requests keyboard focus on the message bar.
- **1-Tap Quick Replies**: Quick phrase chips (`नमस्ते!`, `हाँ, बिल्कुल`, `धन्यवाद!`, `How are you?`, `OK, done!`).

### 5. 🌐 In-Chat Multilingual Translation (12 भाषाओं में अनुवाद)
- **Bilingual & Multilingual Translations**: Instant translations between Hindi, English, Spanish, French, German, Arabic, Bengali, Marathi, Tamil, Telugu, Gujarati, and Urdu.
- **Live Outgoing Auto-Translate Toggle**: Automatically translates outgoing chat text before dispatch.

### 6. 🏦 All Indian & Global Banks Ecosystem (सभी 65+ भारतीय और अंतरराष्ट्रीय बैंक)
- **Comprehensive Bank Catalog**: Searchable list with tabs (`All`, `Popular ⭐`, `Indian 🇮🇳`, `International 🌐`) featuring 65+ banks:
  - **Indian Banks**: State Bank of India (SBI), HDFC Bank, ICICI Bank, Punjab National Bank (PNB), Bank of Baroda, Axis Bank, Kotak Mahindra Bank, Canara Bank, Union Bank of India, Bank of India, Indian Bank, IndusInd Bank, Yes Bank, IDBI Bank, Central Bank, UCO Bank, Federal Bank, Bandhan Bank, Paytm Payments Bank, Airtel Payments Bank, Jio Payments Bank, etc.
  - **International Banks**: JPMorgan Chase, Bank of America, Wells Fargo, Citibank, HSBC Global, Barclays UK, BNP Paribas, Deutsche Bank, UBS Switzerland, DBS Bank Singapore, Standard Chartered, Royal Bank of Canada (RBC), Santander, etc.
- **Add Bank Form**: Account number, confirm account, IFSC / SWIFT code validation, account holder name, and account type (Savings, Current, NRI/NRO).
- **Full Bank Card Management Menu**:
  - **Check Balance**: Enter 4-digit UPI PIN (Default: `1234`) for instant balance display.
  - **Change UPI PIN**: Update current PIN to a new 4-digit PIN.
  - **Reset UPI PIN**: 6-digit OTP verification (Default: `123456`) to reset forgotten PIN.
  - **Set Primary / Default**: Assign default bank for sending and receiving payments.
  - **Switch Payment Provider**: Toggle between NPCI UPI 2.0 Network, PhonePe Infrastructure Stack, and Google Pay Core Engine.
  - **Link UPI Number**: Link 10-digit mobile number as UPI ID.
  - **Invite & Earn ₹201**: Referral rewards for onboarding friends.
  - **24/7 Helpline & Remove Bank Account**.

### 2. 📸 Real Device Camera Photo Capture
- **Real Device Hardware Camera & Gallery**: Uses `image_picker` to take live photos on mobile phones or laptop webcams, or select existing gallery images.
- **Base64 Data URL Image Memory Rendering**: Photos are encoded into memory data URLs and displayed in chat bubbles (`MessageBubble`) and full-screen preview (`MediaPreviewScreen`) with zero server upload bottleneck.

### 3. 🎙️ WhatsApp-Style Live Mic Recording & Voice Dictation
- **In-Bar Live Recording Experience**: Tapping the microphone switches the input bar to live recording mode with:
  - Pulsing red recording dot 🔴.
  - Live recording stopwatch timer (`00:01`, `00:02`, `00:03`).
  - Real-time animated audio waveforms.
  - Trash can 🗑️ button to discard recording.
  - Send button ➤ to transmit voice note immediately.
- **Speech Dictation (बोलकर लिखें)**: Dedicated dictation button to convert spoken voice to text.

### 4. 😀 186 Categorized Emojis, 50 GIFs, 50 Stickers & Keyboard Switcher
- **5 Emoji Categories (186 total)**:
  - Smileys & Emotions (48)
  - Gestures & People (36)
  - Hearts & Love (26)
  - Food & Drinks (36)
  - Nature & Travel (40)
- **Dedicated Keyboard (कीपैड) Switcher**: ⌨️ button in the drawer header and input bar to instantly toggle back to typing.
- **50 Reaction GIFs & 50 Custom Stickers**.

### 5. 🔝 Top Bar & Filter Quick Create Menu
- **AppBar Actions**: Camera button 📷, Rupee circular button (₹), QR Scanner, Search, and 3-dot menu.
- **Filter Pills**: `All`, `Unread`, `Favorites ⭐`, `Groups 👥`, and Quick Action `+` button opening a creation menu (New Group, New Channel, New Community).

### 6. ⏰ Scheduled Messages & 📢 Channels
- **Schedule Messages (शेड्यूल्ड मैसेज)**: Set future dispatch times for automated delivery.
- **Broadcast Channels (चैनल्स)**: Create public broadcast channels with follower stats and announcement feed.

### 7. 🎬 3-4 Minute AI Animation Video Generator (एनीमेशन वीडियो जनरेटर)
- **AI Animation Studio**: Generates 3-4 minute narrative video concepts with 4-scene narrative breakdown, style presets (`3D Pixar Animated Cartoon`, `Anime 2D Cinema`, `Cyberpunk Sci-Fi 3D`, `Stop-Motion Clay`), 16:9 simulated video player with play/pause scrubber, and 1-tap chat share.

### 8. 🌐 Universal Multilingual Translator
- **30+ Global & Regional Languages**: Instant translation across Hindi, English, Spanish, French, German, Japanese, Chinese, Arabic, Russian, Bengali, Marathi, Telugu, Tamil, Gujarati, Urdu, Punjabi, etc.

### 9. 💸 Google Pay & PhonePe Unified Payments Ecosystem (पेमेंट्स, रिचार्ज व बिल भुगतान)
- **Scan Any UPI QR Code**: Scan any peer or merchant UPI QR code with interactive simulated scanning laser viewfinder.
- **Pay to Mobile Number**: Transfer money directly to 10-digit mobile numbers with instant bank UPI deduction and receipt.
- **Receive Money QR (पैसे प्राप्त करें)**: Generate personal UPI QR codes with custom requested amount, share options, and simulated instant payment credit notification.
- **View Account Balance**: Secure PIN verification (default test-drive PIN: `1234`) with instant balance display.
- **Recharges & Utilities Suite**:
  - **Mobile Recharge**: Jio, Airtel, Vi, BSNL with plans up to ₹2999.
  - **Electricity Bill**: UPPCL, BSES Yamuna, BESCOM, Tata Power.
  - **FASTag Recharge**: Instant highway toll tag wallet recharge.
  - **Metro QR Tickets**: Delhi Metro (DMRC), Mumbai Metro (MMRDA), Namma Metro Bangalore with live animated digital QR gate pass!
  - **Cable DTH, Credit Card Bill, Loan EMI Repayment, Travel & Movie Tickets**.
- **Transaction History & Digital Receipts**: Filter transactions by `All`, `Paid`, `Received`, `Recharge`, and `Bills` with full shareable digital receipt view and 24/7 Help & Support.

### 10. 🏛️ Communities Section (कम्युनिटीज)
- **Top 4-Tab Navigation**: `CHATS`, `UPDATES`, `COMMUNITIES`, `CALLS`.
- **Create Communities**: Create custom organization or neighborhood communities with topic tags.
- **Official Announcement Channels**: Megaphone / loudspeaker broadcast channel for verified community-wide broadcasts.
- **Sub-Groups**: Nested interest sub-groups with 1-tap direct chat launch.

### 3. 📸 WhatsApp-Style In-Chat Camera & Voice Dictation
- **In-App Camera Viewfinder**: Front selfie / rear camera preview with flash toggle and circular shutter button to capture & send photos instantly.
- **Voice Dictation / Speech-to-Text (बोलकर चैट लिखें)**: Real-time speech dictation dialog with animated microphone, waveforms, and 1-tap insert or send.
- **Emoji, GIF & Sticker 3-Tab Drawer**: Comprehensive drawer containing categorized emojis, trending reaction GIFs, and animated sticker packs.
- **10-Item Attachment Bottom Sheet**: Document, Camera, Gallery, Audio, Location, Contact, Poll (वोटिंग), Payment (पेमेंट), Event, and Meta AI Suite.
- **WhatsApp Three-Dot Menu**: View Contact / Group Info, Media Links & Docs, In-chat search, Mute notifications, Disappearing messages, Wallpaper changer, and Strict E2EE Fingerprint.

### 4. 🟣 Meta AI Floating Assistant Circle (WhatsApp Style)
- **WhatsApp-Style Circular AI Placement**: Iridescent glowing ring button located on the right-hand side directly above the `New Chat` floating action button.
- **1-Tap Quick Launch**: Opens the **Universal Meta AI Assistant** with `/imagine` 3D image generator, suggested prompt chips, and multi-turn chat.
- **Inline Chat AI Action**: Tap the Meta AI icon in the chat input bar to generate instant replies and imagery within any conversation.

### 5. 💳 WhatsApp Pay & UPI In-Chat Payments (पेमेंट्स व बैंक खाते)
- **In-Chat UPI Transfers**: Send and request money directly inside any 1-to-1 conversation via the attachment menu.
- **Rich UPI Payment Cards**: Displays payment cards with green checkmarks, INR amount, notes, and transaction IDs embedded in chat bubbles.
- **Payments Center (`PaymentsScreen`)**: Link bank accounts (State Bank of India, HDFC Bank, Paytm Payments Bank), check real-time account balances, view full transaction history, and generate receipts.
- **Secure 4-Digit UPI PIN**: Bank-grade PIN authentication (default test-drive PIN: `1234`).

### 6. 📲 WhatsApp-Style QR Code System (क्यूआर कोड)
- **Personal Profile QR (`My Code`)**: High-resolution custom matrix QR code displaying user avatar and UPI ID. Share or scan to instantly start a 1-to-1 chat.
- **Group Invite QR**: Dedicated QR code for group chats and channels. Scan to join groups immediately.
- **Live Laser Camera Scanner**: Viewfinder with animated green laser scanning line and instant 1-tap recognition for users, groups, and payments.

### 7. ⭐ Freemium AI & Premium Cloud Subscriptions
- **Daily Quota Management**: 15 free Meta AI queries per day for standard users. Exceeding the quota triggers an upgrade prompt.
- **Universal Pro (₹199/mo)**: 100GB extra cloud storage, unlimited Meta AI + `/imagine` generation, verified gold star badge ⭐, and 100% ad-free experience.
- **Business Enterprise (₹699/mo)**: 1TB cloud storage, automated customer service bot, catalog boost, and verified green business badge ✅.
- **Storage Progress Bar & In-App Upgrade**: Track cloud storage usage and upgrade in 1-tap via simulated UPI payment.

### 8. ⚡ Floating Developer Circle Bypass (छोटा सा गोला)
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
│   │   ├── message_model.dart       # Rich media, voice, replies, pins, edits & payments
│   │   ├── payment_model.dart       # Bank accounts, UPI transactions & subscription plans
│   │   ├── status_model.dart        # WhatsApp-style status story model
│   │   └── user_model.dart          # User profile model
│   ├── providers/
│   │   ├── auth_provider.dart       # Authentication & Developer Bypass state
│   │   ├── chat_provider.dart       # Messages, channels, calls, filters & AI
│   │   └── theme_provider.dart      # Dark / Light Material 3 theme mode
│   ├── screens/
│   │   ├── admin_dashboard_screen.dart   # Admin Command Center & Telemetry
│   │   ├── ai_assistant_screen.dart      # Universal AI Suite & Meta AI /imagine
│   │   ├── app_lock_screen.dart          # 4-Digit PIN passcode lock screen
│   │   ├── backup_sync_screen.dart       # Cloud Backup & Restore Hub
│   │   ├── business_profile_screen.dart  # Business Hub & Product Catalog
│   │   ├── call_screen.dart              # 1-to-1 Fullscreen HD Call UI
│   │   ├── channel_screen.dart           # Broadcast channel feed viewer
│   │   ├── chat_list_screen.dart         # 3-Tab UI + Filter Chips + Floating Circle
│   │   ├── chat_screen.dart              # E2EE Chat UI with replies, attachments & UPI pay
│   │   ├── community_screen.dart         # Community announcement channel
│   │   ├── dev_bypass_sheet.dart         # Developer Bypass Inspection Sheet
│   │   ├── group_call_screen.dart        # Multi-participant 2x2 video grid
│   │   ├── group_create_screen.dart      # Pick members & create new group chat
│   │   ├── linked_devices_screen.dart    # Web/Desktop QR sync management
│   │   ├── login_screen.dart             # Login + Developer Bypass action
│   │   ├── media_preview_screen.dart     # Fullscreen photo/video zoom viewer
│   │   ├── payments_screen.dart          # WhatsApp Pay & Paytm UPI Payments Center
│   │   ├── privacy_security_screen.dart  # App Lock, Biometrics & 2FA
│   │   ├── profile_screen.dart           # User profile & settings
│   │   ├── qr_code_share_screen.dart     # Personal & Group QR Code Hub with Live Scanner
│   │   ├── search_screen.dart            # Global Search Hub with filters
│   │   ├── signup_screen.dart            # Account registration
│   │   ├── splash_screen.dart            # Animated splash with secret bypass tap
│   │   ├── starred_messages_screen.dart  # Starred/Bookmarked messages repository
│   │   ├── status_view_screen.dart       # Story viewer with 5s animated progress bar
│   │   ├── subscription_screen.dart      # Universal Pro & Extra Cloud Storage Hub
│   │   └── users_list_screen.dart        # Contact directory
│   ├── services/
│   │   ├── auth_service.dart        # Firebase Auth integration
│   │   ├── chat_service.dart        # Cloud Firestore chat & message streams
│   │   ├── encryption_service.dart  # AES-256 E2EE cipher & fingerprint generator
│   │   ├── mock_data_service.dart   # Developer Bypass simulation engine
│   │   ├── notification_service.dart# Push notification handler (FCM)
│   │   ├── payment_service.dart     # Bank UPI transactions & Freemium AI quota engine
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
│       ├── message_bubble.dart      # Bubble with photos, videos, docs, audio & UPI cards
│       ├── meta_ai_circle.dart      # WhatsApp Meta AI Iridescent Circular Ring
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
