# ChatSpace - Mobile App Demo Video Script

**Duration**: ~90 seconds  
**Format**: Screen recording (or side-by-side two phone screens) + voiceover or captions  

---

### Scene 1: App Launch & Authentication (0:00 - 0:18)
- **Visual**: App launches on Device 1 with smooth splash animation showing the teal ChatSpace icon and tagline *"Instant, Secure & Real-Time Messaging"*.
- **Action**: User taps "Sign Up", enters Name ("Rajnesh"), Email ("rajnesh@example.com"), Password ("secret123"), and confirms password. Taps "Create Account".
- **Visual Result**: Smooth loading spinner -> Success notification banner -> Transits immediately to the home screen.
- **Narrator/Caption**: *"Welcome to ChatSpace! Clean sign-up with email validation and persistent Firebase Authentication."*

---

### Scene 2: Registered Users Directory & Search (0:18 - 0:32)
- **Visual**: Empty chat home screen displays an invitation card. User taps the floating message button in the bottom right corner.
- **Action**: "Select Contact" screen opens showing all active registered contacts with their current status and online badges. User types "Alice" in the search box; list filters instantly in real time.
- **Narrator/Caption**: *"Browse all registered users in real time. Search instantly by name and see live online/offline indicators with last-seen timestamps."*

---

### Scene 3: One-to-One Real-Time Messaging (0:32 - 0:50)
- **Visual**: User taps on "Alice Johnson" to open the chat room.
- **Action**: Chat screen opens showing Alice's avatar and "Online" in the header. Date separator "Today" appears. User types *"Hello Alice! Testing our new Flutter ChatSpace build 🚀"* and taps the send button.
- **Visual Result**: Message bubble snaps smoothly into place on the right with a green container, timestamp, and single tick (`✓`). The list auto-scrolls down.
- **Narrator/Caption**: *"Instant message sending with automatic date grouping, responsive chat bubbles, and auto-scrolling."*

---

### Scene 4: Two-Device Reply & Seen Status (0:50 - 1:08)
- **Visual**: Side-by-side view with Device 2 (or simulated bot in Developer Bypass Mode).
- **Action**: Alice opens the chat room. Instantly, Device 1's single tick changes to double blue ticks (`✓✓`).
- **Visual**: Device 1's header status changes from "Online" to italicized *"typing..."*.
- **Visual**: Alice sends: *"Hey! The real-time Firestore sync is incredibly fast and responsive! ✨"*. Device 1 receives the grey bubble on the left in real time without refreshing.
- **Narrator/Caption**: *"Live Firestore snapshot synchronization, typing indicators, and read receipts in real time."*

---

### Scene 5: Push Notifications & Recent Chats (1:08 - 1:20)
- **Visual**: User presses home button to put ChatSpace into background on Device 1. Alice sends: *"Check your push notification!"*.
- **Visual Result**: A heads-up push notification banner appears from ChatSpace at the top of the Android screen. Tapping the banner re-opens the conversation directly.
- **Visual**: User navigates back to the Home screen showing the recent chat with Alice, last message snippet, time, and unread badge.
- **Narrator/Caption**: *"Foreground and background notifications powered by Firebase Cloud Messaging (FCM)."*

---

### Scene 6: Profile & Material 3 Dark Mode (1:20 - 1:35)
- **Visual**: User navigates to Profile & Settings screen.
- **Action**: User taps the Dark Mode switch. The entire interface seamlessly transitions into high-contrast dark theme (`#121B22` / `#1F2C34` / `#005C4B`). User edits bio to *"Building production Flutter apps!"* and saves.
- **Visual Result**: SharedPreferences saves dark theme permanently. App shows "DEV BYPASS" badge or full Firebase user stats.
- **Narrator/Caption**: *"Customizable profile and gorgeous Material 3 dark mode persisted across launches. ChatSpace: Production-ready and Play Store ready!"*
