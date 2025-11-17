# Android CI/CD Guide

## 🚀 GitHub Actions CI/CD đã được setup!

File `.github/workflows/android-ci.yml` đã được tạo với các tính năng:

### ✨ Features

1. **Tự động build khi push code**
   - Push lên `main` hoặc `develop` branch
   - Tạo Pull Request

2. **Build 2 loại APK**
   - Debug APK (cho testing)
   - Release APK (cho production)

3. **Build App Bundle (AAB)**
   - Chỉ build khi push lên `main`
   - Dùng để upload lên Google Play Store

4. **Tự động tạo Release**
   - Tạo GitHub Release với APK files
   - Version tự động từ `pubspec.yaml`

5. **Upload Artifacts**
   - Lưu APK/AAB files
   - Giữ 30 ngày

---

## 📋 Setup Instructions

### Bước 1: Enable GitHub Actions

1. Vào repository trên GitHub
2. Tab **Actions**
3. Enable workflows nếu chưa enable

### Bước 2: Push code

```bash
git add .
git commit -m "Add Android CI/CD"
git push origin main
```

### Bước 3: Xem build progress

1. Vào tab **Actions** trên GitHub
2. Xem workflow đang chạy
3. Đợi build hoàn thành (~5-10 phút)

### Bước 4: Download APK

**Cách 1: Từ Artifacts**
1. Vào workflow run
2. Scroll xuống **Artifacts**
3. Download `apk-builds-xxx.zip`

**Cách 2: Từ Releases**
1. Vào tab **Releases**
2. Download APK từ latest release

---

## 🎯 Manual Build Trigger

Bạn có thể trigger build thủ công:

1. Vào tab **Actions**
2. Chọn workflow **Android CI/CD**
3. Click **Run workflow**
4. Chọn build type (debug/release)
5. Click **Run workflow**

---

## 🔧 Local Build Commands

### Debug APK
```bash
flutter build apk --debug
```

### Release APK
```bash
flutter build apk --release
```

### Split APKs (smaller size)
```bash
flutter build apk --release --split-per-abi
```

### App Bundle (for Play Store)
```bash
flutter build appbundle --release
```

---

## 📦 Build Outputs

### APK Location
```
build/app/outputs/flutter-apk/
├── app-debug.apk           # Debug build
├── app-release.apk         # Release build (universal)
├── app-armeabi-v7a-release.apk  # ARM 32-bit
├── app-arm64-v8a-release.apk    # ARM 64-bit
└── app-x86_64-release.apk       # x86 64-bit
```

### AAB Location
```
build/app/outputs/bundle/release/
└── app-release.aab
```

---

## 🔐 Setup Signing (Optional)

Để build signed APK, cần setup keystore:

### Bước 1: Tạo Keystore

```bash
keytool -genkey -v -keystore android/app/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload
```

### Bước 2: Tạo key.properties

File `android/key.properties`:
```properties
storePassword=your_store_password
keyPassword=your_key_password
keyAlias=upload
storeFile=upload-keystore.jks
```

### Bước 3: Update build.gradle

File `android/app/build.gradle`:
```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    ...
    
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

### Bước 4: Add secrets to GitHub

1. Vào **Settings** → **Secrets and variables** → **Actions**
2. Add secrets:
   - `KEYSTORE_BASE64` - Base64 encoded keystore
   - `KEYSTORE_PASSWORD`
   - `KEY_PASSWORD`
   - `KEY_ALIAS`

Encode keystore:
```bash
base64 -i android/app/upload-keystore.jks | pbcopy
```

---

## 🎨 Customize Build

### Change App Name

File `android/app/src/main/AndroidManifest.xml`:
```xml
<application
    android:label="KDTD"
    ...>
```

### Change Package Name

File `android/app/build.gradle`:
```gradle
defaultConfig {
    applicationId "com.fidobox.kdtd"
    ...
}
```

### Change Version

File `pubspec.yaml`:
```yaml
version: 1.0.0+1
# Format: major.minor.patch+build_number
```

---

## 📊 Build Status Badge

Thêm badge vào README.md:

```markdown
![Android CI](https://github.com/YOUR_USERNAME/YOUR_REPO/workflows/Android%20CI%2FCD/badge.svg)
```

---

## 🐛 Troubleshooting

### Build fails với Gradle error
```bash
# Clean local build
flutter clean
cd android
./gradlew clean
cd ..
flutter pub get
```

### Out of memory
Thêm vào `android/gradle.properties`:
```properties
org.gradle.jvmargs=-Xmx4096m
```

### Multidex error
File `android/app/build.gradle`:
```gradle
defaultConfig {
    ...
    multiDexEnabled true
}
```

---

## 📱 Testing APK

### Install trên device
```bash
# Via ADB
adb install build/app/outputs/flutter-apk/app-release.apk

# Via Flutter
flutter install
```

### Test trên emulator
```bash
flutter run --release
```

---

## 🚀 Deploy to Play Store

### Bước 1: Build AAB
```bash
flutter build appbundle --release
```

### Bước 2: Upload
1. Vào [Google Play Console](https://play.google.com/console)
2. Chọn app
3. **Release** → **Production**
4. **Create new release**
5. Upload `app-release.aab`
6. Fill release notes
7. **Review release** → **Start rollout**

---

## 📈 Advanced: Auto Deploy to Play Store

Thêm vào workflow để tự động upload:

```yaml
- name: Upload to Play Store
  uses: r0adkll/upload-google-play@v1
  with:
    serviceAccountJsonPlainText: ${{ secrets.SERVICE_ACCOUNT_JSON }}
    packageName: com.fidobox.kdtd
    releaseFiles: build/app/outputs/bundle/release/app-release.aab
    track: internal
    status: completed
```

Setup:
1. Tạo Service Account trong Google Cloud Console
2. Download JSON key
3. Add vào GitHub Secrets: `SERVICE_ACCOUNT_JSON`

---

## ✅ Checklist

- [x] GitHub Actions workflow created
- [ ] Push code to trigger build
- [ ] Download APK from artifacts
- [ ] Test APK on device
- [ ] Setup signing (optional)
- [ ] Create GitHub Release
- [ ] Upload to Play Store (optional)

---

## 📞 Support

- GitHub Actions: https://docs.github.com/actions
- Flutter Build: https://docs.flutter.dev/deployment/android
- Play Store: https://support.google.com/googleplay/android-developer

---

## 🎉 Quick Start

```bash
# 1. Push code
git add .
git commit -m "Setup Android CI/CD"
git push origin main

# 2. Vào GitHub Actions tab
# 3. Đợi build xong
# 4. Download APK từ Artifacts hoặc Releases
# 5. Install và test!
```

Build sẽ tự động chạy mỗi khi bạn push code! 🚀
