# Local Build Guide

This guide covers how to build the application locally on your machine.

## 📱 iOS Build (macOS Only)

**Requirements**:
-   macOS
-   Xcode (latest stable)
-   CocoaPods (`sudo gem install cocoapods`)

### Setup
```bash
cd ios
pod install
cd ..
```

### Build Commands

**Debug (No Signing)**:
Run on simulator or device for testing.
```bash
flutter build ios --debug --no-codesign
```

**Release (Signed)**:
Requires an Apple Developer Account and valid signing certificates configured in Xcode.
```bash
# Build IPA for distribution
flutter build ipa --release

# Or build .app bundle
flutter build ios --release
```

**Common Issues**:
-   **Pod install failed**: Try `cd ios && rm -rf Pods Podfile.lock && pod install --repo-update`.
-   **Signing errors**: Open `ios/Runner.xcworkspace` in Xcode and check the "Signing & Capabilities" tab.

---

## 🤖 Android Build

**Requirements**:
-   Android SDK
-   Java JDK (11 or 17 recommended)

### Build Commands

**Debug APK**:
```bash
flutter build apk --debug
```

**Release APK**:
```bash
flutter build apk --release
```

**Split APK (Per Architecture)**:
Reduces file size by creating separate APKs for arm64, arm-v7a, etc.
```bash
flutter build apk --release --split-per-abi
```

**App Bundle (AAB)**:
Required for Google Play Store upload.
```bash
flutter build appbundle --release
```

### Signing
To build a signed release APK locally:
1.  Generate a keystore (`keytool ...`).
2.  Create `android/key.properties` with your passwords.
3.  Ensure `android/app/build.gradle` is configured to read from `key.properties`.

---

## 🏃 Run Commands

Run on a connected device or simulator:

```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device_id>

# Run in release mode (faster performance, closer to prod)
flutter run --release
```
