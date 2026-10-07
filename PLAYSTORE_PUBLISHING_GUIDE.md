# Google Play Store Publishing Guide for ChatSpace

This guide provides the exact, production-ready steps to publish **ChatSpace** to the **Google Play Console**.

---

## 1. Prerequisites Checklist
- [x] Google Play Developer Account registered ($25 one-time registration fee)
- [x] Flutter SDK installed with Android targetSdk 34 (Android 14+)
- [x] Production Release App Bundle (`.aab`) generated
- [x] Keystore signing configured
- [x] Privacy Policy URL & App Support details

---

## 2. Generating a Production Upload Keystore

Run the following command in PowerShell / Terminal:

```powershell
keytool -genkey -v -keystore C:\Users\Rajnesh\upload-keystore.jks `
  -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 `
  -alias upload
```

Keep your keystore password safe.

---

## 3. Configuring Keystore in Android

Create `android/key.properties` (do not commit to public Git):

```properties
storePassword=YourKeystorePassword
keyPassword=YourKeyPassword
keyAlias=upload
storeFile=C:/Users/Rajnesh/upload-keystore.jks
```

Update `android/app/build.gradle.kts`:

```kotlin
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    ...
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            ...
        }
    }
}
```

---

## 4. Build Production Android App Bundle (AAB)

Run:
```bash
flutter build appbundle --release --android-skip-build-dependency-validation
```

Output location:
`build/app/outputs/bundle/release/app-release.aab`

---

## 5. Google Play Console Setup

1. **Create New App**:
   - App Name: `ChatSpace`
   - Default Language: English (United States)
   - App or Game: App
   - Free or Paid: Free

2. **Data Safety Questionnaire**:
   - **Personal Info**: Name, Email (for Firebase Authentication & account creation)
   - **Messages**: In-app messages (for real-time messaging between chat participants)
   - **Device or other IDs**: FCM token (for push notification delivery)
   - **Security Practices**: Data is encrypted in transit (HTTPS / TLS 1.3), users can request data deletion.

3. **Target Audience and Content**:
   - Age Rating: 13+ (Social / Communication)
   - Ads: No ads

4. **Store Listing Assets**:
   - **Short description** (max 80 chars): *Fast, secure, real-time messaging with push alerts and modern dark theme.*
   - **Full description**: Complete overview of real-time communication, contact list, online status, and messaging features.
   - **App Icon**: 512 x 512 px PNG (32-bit)
   - **Feature Graphic**: 1024 x 500 px PNG/JPEG
   - **Phone Screenshots**: Minimum 2 screenshots (1080 x 1920 px or 1080 x 2400 px)

5. **Release Track**:
   - Navigate to **Production** (or **Closed Testing**).
   - Click **Create new release**.
   - Upload `app-release.aab`.
   - Enter Release Name: `1.0.0 (Initial Production Release)`.
   - Review and rollout!
