# iOS Build Guide

## ⚠️ Yêu cầu

**iOS chỉ có thể build trên macOS**. Bạn có các lựa chọn:

1. **Sử dụng macOS** (máy Mac hoặc Hackintosh)
2. **Sử dụng CI/CD** (Codemagic, GitHub Actions, Bitrise)
3. **Thuê Mac Cloud** (MacStadium, AWS Mac instances)

---

## 🍎 Option 1: Build trên macOS

### Bước 1: Cài đặt môi trường

```bash
# Install Xcode từ App Store
# Hoặc download từ: https://developer.apple.com/xcode/

# Install Xcode Command Line Tools
xcode-select --install

# Install CocoaPods
sudo gem install cocoapods

# Verify Flutter
flutter doctor
```

### Bước 2: Cấu hình iOS

```bash
# Navigate to project
cd /path/to/kdtd_ver2_1

# Get dependencies
flutter pub get

# Install iOS pods
cd ios
pod install
cd ..
```

### Bước 3: Cấu hình Signing

1. Mở Xcode:
```bash
open ios/Runner.xcworkspace
```

2. Trong Xcode:
   - Select **Runner** project
   - Select **Runner** target
   - Tab **Signing & Capabilities**
   - Chọn **Team** (Apple Developer Account)
   - Đổi **Bundle Identifier**: `com.fidobox.kdtd`

### Bước 4: Build

#### A. Build Debug (không cần signing)
```bash
flutter build ios --debug --no-codesign
```

#### B. Build Release (cần Apple Developer Account)
```bash
# Build IPA
flutter build ipa --release

# Hoặc build iOS app
flutter build ios --release
```

#### C. Run trên Simulator
```bash
# List simulators
flutter emulators

# Run
flutter run -d "iPhone 15 Pro"
```

#### D. Run trên Device
```bash
# Connect iPhone qua USB
# Trust computer trên iPhone

# List devices
flutter devices

# Run
flutter run -d <device-id>
```

### Bước 5: Archive & Upload

1. Trong Xcode:
   - **Product** → **Archive**
   - Chờ build xong
   - Click **Distribute App**
   - Chọn **App Store Connect**
   - Upload

2. Hoặc dùng command line:
```bash
# Build IPA
flutter build ipa --release

# Upload với Transporter app
# Hoặc dùng altool
xcrun altool --upload-app \
  --type ios \
  --file build/ios/ipa/*.ipa \
  --username "your@email.com" \
  --password "app-specific-password"
```

---

## ☁️ Option 2: Build với Codemagic (Recommended)

### Bước 1: Setup Codemagic

1. Đăng ký: https://codemagic.io
2. Connect repository (GitHub/GitLab/Bitbucket)
3. Add project

### Bước 2: Cấu hình codemagic.yaml

File `codemagic.yaml` đã có sẵn trong project:

```yaml
workflows:
  ios-workflow:
    name: iOS Build
    instance_type: mac_mini_m1
    environment:
      ios_signing:
        distribution_type: app_store
        bundle_identifier: com.fidobox.kdtd
      flutter: stable
      xcode: latest
    scripts:
      - flutter pub get
      - flutter build ipa --release
    artifacts:
      - build/ios/ipa/*.ipa
```

### Bước 3: Setup Signing

1. Trong Codemagic dashboard:
   - Go to **App settings**
   - **iOS code signing**
   - Upload certificates & provisioning profiles

2. Hoặc dùng automatic signing:
   - Connect App Store Connect API key
   - Codemagic tự động manage certificates

### Bước 4: Build

1. Push code lên repository:
```bash
git add .
git commit -m "Ready for iOS build"
git push origin main
```

2. Codemagic tự động build
3. Download IPA từ artifacts

---

## 🔧 Option 3: GitHub Actions

### Tạo workflow file

`.github/workflows/ios.yml`:

```yaml
name: iOS Build

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: macos-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.29.3'
        channel: 'stable'
    
    - name: Install dependencies
      run: flutter pub get
    
    - name: Install pods
      run: |
        cd ios
        pod install
    
    - name: Build iOS
      run: flutter build ios --release --no-codesign
    
    - name: Upload artifact
      uses: actions/upload-artifact@v3
      with:
        name: ios-build
        path: build/ios/iphoneos/Runner.app
```

---

## 📋 Cấu hình iOS chi tiết

### Info.plist (ios/Runner/Info.plist)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDisplayName</key>
    <string>KDTD</string>
    
    <key>CFBundleIdentifier</key>
    <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
    
    <key>CFBundleVersion</key>
    <string>$(FLUTTER_BUILD_NUMBER)</string>
    
    <key>CFBundleShortVersionString</key>
    <string>$(FLUTTER_BUILD_NAME)</string>
    
    <!-- Permissions -->
    <key>NSCameraUsageDescription</key>
    <string>Cần camera để kiểm tra chức năng chụp ảnh</string>
    
    <key>NSMicrophoneUsageDescription</key>
    <string>Cần microphone để kiểm tra âm thanh</string>
    
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>Cần vị trí để kiểm tra GPS</string>
    
    <key>NSBluetoothAlwaysUsageDescription</key>
    <string>Cần Bluetooth để kiểm tra kết nối</string>
    
    <key>NFCReaderUsageDescription</key>
    <string>Cần NFC để kiểm tra chức năng NFC</string>
    
    <key>NSPhotoLibraryUsageDescription</key>
    <string>Cần truy cập thư viện ảnh</string>
    
    <key>NSMotionUsageDescription</key>
    <string>Cần cảm biến chuyển động</string>
</dict>
</plist>
```

### Podfile (ios/Podfile)

```ruby
platform :ios, '12.0'

target 'Runner' do
  use_frameworks!
  use_modular_headers!

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
    end
  end
end
```

---

## 🚀 Build Commands Summary

```bash
# Debug build (no signing)
flutter build ios --debug --no-codesign

# Release build
flutter build ios --release

# Build IPA for distribution
flutter build ipa --release

# Run on simulator
flutter run -d "iPhone 15 Pro"

# Run on device
flutter run -d <device-id>

# Clean build
flutter clean
cd ios
pod deintegrate
pod install
cd ..
flutter build ios --release
```

---

## 🔍 Troubleshooting

### 1. Pod install fails
```bash
cd ios
rm -rf Pods
rm Podfile.lock
pod cache clean --all
pod install --repo-update
```

### 2. Signing error
- Kiểm tra Bundle Identifier
- Verify Apple Developer Account
- Check certificates trong Xcode
- Update provisioning profiles

### 3. Build fails
```bash
# Clean everything
flutter clean
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
flutter pub get
flutter build ios --release
```

### 4. Permission errors
- Kiểm tra Info.plist có đầy đủ usage descriptions
- Verify capabilities trong Xcode

---

## 📱 Testing

### TestFlight
1. Upload IPA lên App Store Connect
2. Add internal/external testers
3. Distribute build
4. Testers install qua TestFlight app

### Ad-hoc Distribution
1. Create Ad-hoc provisioning profile
2. Build với profile đó
3. Distribute IPA file
4. Install qua Xcode hoặc third-party tools

---

## 📊 Recommended: Sử dụng Codemagic

**Ưu điểm:**
- ✅ Không cần Mac
- ✅ Tự động build
- ✅ Tự động signing
- ✅ Upload lên App Store
- ✅ Free tier available

**Setup:**
1. Sign up: https://codemagic.io
2. Connect repo
3. Configure signing
4. Push code → Auto build

**Pricing:**
- Free: 500 build minutes/month
- Pro: $99/month unlimited

---

## 📞 Support

- Apple Developer: https://developer.apple.com
- Codemagic: https://docs.codemagic.io
- Flutter iOS: https://docs.flutter.dev/deployment/ios

---

## ✅ Checklist

- [ ] Có Apple Developer Account ($99/year)
- [ ] Có macOS hoặc CI/CD setup
- [ ] Đã cấu hình Bundle Identifier
- [ ] Đã thêm permissions vào Info.plist
- [ ] Đã setup signing certificates
- [ ] Đã test trên simulator/device
- [ ] Đã tạo App Store listing
- [ ] Đã upload build lên TestFlight
- [ ] Đã test với testers
- [ ] Ready to submit for review
