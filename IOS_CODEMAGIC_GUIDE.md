# iOS IPA Build với Codemagic

## 🍎 iOS Workflows đã được cấu hình

File `codemagic.yaml` có 3 workflows cho iOS:

### 1. **ios-debug** - Debug IPA
- **Trigger**: Push lên branch `develop`
- **Instance**: Mac Mini M1
- **Signing**: Không cần (no-codesign)
- **Output**: `kdtd-debug-buildXXX.ipa`
- **Use case**: Testing nội bộ

### 2. **ios-testflight** - TestFlight IPA
- **Trigger**: Push lên `main` hoặc tag `ios-*`
- **Instance**: Mac Mini M1
- **Signing**: App Store Distribution
- **Output**: `kdtd-v1.0.0-release-buildXXX.ipa`
- **Auto upload**: TestFlight (Internal Testers)
- **Use case**: Beta testing

### 3. **ios-appstore** - App Store Release
- **Trigger**: Tag `appstore-*`
- **Instance**: Mac Mini M1
- **Signing**: App Store Distribution
- **Auto upload**: TestFlight + App Store
- **Use case**: Production release

---

## 📋 Setup Instructions

### Bước 1: Apple Developer Account

1. Đăng ký Apple Developer Program ($99/year)
2. URL: https://developer.apple.com/programs/

### Bước 2: Create App in App Store Connect

1. Vào [App Store Connect](https://appstoreconnect.apple.com)
2. Click **My Apps** → **+** → **New App**
3. Điền thông tin:
   - **Platform**: iOS
   - **Name**: KDTD
   - **Primary Language**: Vietnamese
   - **Bundle ID**: `com.fidobox.kdtd`
   - **SKU**: `kdtd-001`
4. Click **Create**

### Bước 3: Setup App Store Connect API Key

#### A. Tạo API Key

1. Vào **Users and Access** → **Keys** tab
2. Click **+** (Generate API Key)
3. Điền:
   - **Name**: Codemagic
   - **Access**: App Manager
4. Click **Generate**
5. Download API Key (`.p8` file)
6. Lưu lại:
   - **Issuer ID**
   - **Key ID**
   - **Key file content**

#### B. Add to Codemagic

1. Vào Codemagic dashboard
2. **Teams** → **Integrations**
3. Click **App Store Connect**
4. Add integration:
   - **Issuer ID**: Paste từ App Store Connect
   - **Key ID**: Paste từ App Store Connect
   - **Private Key**: Paste nội dung file `.p8`
5. Click **Save**

### Bước 4: Setup iOS Code Signing

#### Option A: Automatic Signing (Recommended)

1. Vào **App settings** → **Code signing identities**
2. Tab **iOS**
3. Enable **Automatic code signing**
4. Select **App Store Connect integration**
5. Codemagic sẽ tự động:
   - Tạo certificates
   - Tạo provisioning profiles
   - Manage signing

#### Option B: Manual Signing

1. Tạo certificates trong Apple Developer Portal:
   - **iOS Distribution Certificate**
   - **iOS Development Certificate**

2. Tạo Provisioning Profiles:
   - **App Store Distribution Profile**
   - **Development Profile**

3. Upload lên Codemagic:
   - Upload certificate (`.p12`)
   - Upload provisioning profile (`.mobileprovision`)
   - Nhập certificate password

### Bước 5: Configure Bundle Identifier

File `ios/Runner.xcodeproj/project.pbxproj`:
```
PRODUCT_BUNDLE_IDENTIFIER = com.fidobox.kdtd;
```

Hoặc trong Xcode:
1. Open `ios/Runner.xcworkspace`
2. Select **Runner** project
3. Select **Runner** target
4. Tab **Signing & Capabilities**
5. Set **Bundle Identifier**: `com.fidobox.kdtd`

### Bước 6: Update Info.plist

File `ios/Runner/Info.plist`:
```xml
<key>CFBundleDisplayName</key>
<string>KDTD</string>

<key>CFBundleIdentifier</key>
<string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>

<key>CFBundleVersion</key>
<string>$(FLUTTER_BUILD_NUMBER)</string>

<key>CFBundleShortVersionString</key>
<string>$(FLUTTER_BUILD_NAME)</string>
```

### Bước 7: Create Environment Variable Group

1. Vào **Teams** → **Environment variables**
2. Create group: `app_store_credentials`
3. Add variables:
   - `APP_STORE_APPLE_ID` = Your App ID (from App Store Connect)
   - `BUNDLE_ID` = com.fidobox.kdtd
4. Click **Save**

---

## 🚀 Trigger Builds

### Debug Build (no signing)
```bash
git checkout develop
git add .
git commit -m "iOS debug build"
git push origin develop
```

### TestFlight Build
```bash
git checkout main
git add .
git commit -m "iOS TestFlight release"
git push origin main

# Or with tag
git tag ios-1.0.0
git push origin ios-1.0.0
```

### App Store Build
```bash
git tag appstore-1.0.0
git push origin appstore-1.0.0
```

---

## 📦 Download IPA

### Từ Codemagic

1. Vào **Builds** tab
2. Click vào build đã hoàn thành
3. Tab **Artifacts**
4. Download IPA file

### Từ TestFlight

1. Vào [App Store Connect](https://appstoreconnect.apple.com)
2. **TestFlight** tab
3. Select build
4. Download hoặc test trên device

---

## 📱 Install IPA

### Via TestFlight (Recommended)

1. Install TestFlight app từ App Store
2. Nhận invite email
3. Accept invite
4. Install app từ TestFlight

### Via Xcode

```bash
# Connect iPhone
# Open Xcode → Window → Devices and Simulators
# Drag IPA file vào device
```

### Via Third-party Tools

- **Diawi**: https://www.diawi.com
- **TestFairy**: https://testfairy.com
- **AppCenter**: https://appcenter.ms

---

## 🔧 Troubleshooting

### Build fails: "No signing certificate"

**Solution:**
1. Verify Apple Developer Account active
2. Check App Store Connect integration
3. Enable automatic signing
4. Or upload certificates manually

### Build fails: "Provisioning profile not found"

**Solution:**
1. Create provisioning profile in Apple Developer Portal
2. Download và upload lên Codemagic
3. Or use automatic signing

### Build fails: "Pod install error"

**Solution:**
```bash
cd ios
rm -rf Pods Podfile.lock
pod cache clean --all
pod install --repo-update
```

### Build timeout

**Solution:**
- Increase `max_build_duration` to 90 or 120
- Mac instances có thể chậm hơn

### Certificate expired

**Solution:**
1. Renew certificate trong Apple Developer Portal
2. Download new certificate
3. Upload lên Codemagic
4. Rebuild

---

## 💰 Pricing

### Mac Instance Costs

- **Mac Mini M1**: $0.095/minute
- **Mac Pro**: $0.190/minute

### Example Costs

- Debug build (~10 min): $0.95
- Release build (~15 min): $1.43
- 10 builds/month: ~$14

### Free Tier

- 500 minutes/month (Linux only)
- Mac instances require paid plan

### Recommended Plan

- **Pro**: $99/month
  - Unlimited Mac minutes
  - Priority support
  - Advanced features

---

## 🎯 Best Practices

### 1. Use Automatic Signing

```yaml
environment:
  ios_signing:
    distribution_type: app_store
    bundle_identifier: com.fidobox.kdtd
```

### 2. Version Management

```yaml
--build-name=1.0.$BUILD_NUMBER
--build-number=$BUILD_NUMBER
```

### 3. TestFlight First

- Test với Internal Testers trước
- Sau đó External Testers
- Cuối cùng mới submit App Store

### 4. Incremental Builds

- Push nhỏ, build thường xuyên
- Catch bugs sớm
- Faster feedback

### 5. Use Tags for Releases

```bash
# TestFlight
git tag ios-1.0.0

# App Store
git tag appstore-1.0.0
```

---

## 📊 Build Status

### Add Badge to README

```markdown
[![Codemagic iOS](https://api.codemagic.io/apps/APP_ID/ios-testflight/status_badge.svg)](https://codemagic.io/apps/APP_ID/ios-testflight/latest_build)
```

---

## 🚀 Advanced Features

### 1. Multiple Schemes

```yaml
- name: Build specific scheme
  script: |
    flutter build ipa --release \
      --flavor production \
      --target lib/main_production.dart
```

### 2. Custom Export Options

Create `ios/ExportOptions.plist`:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>uploadBitcode</key>
    <false/>
    <key>uploadSymbols</key>
    <true/>
</dict>
</plist>
```

### 3. Firebase Distribution

```yaml
- name: Upload to Firebase
  script: |
    firebase appdistribution:distribute build/ios/ipa/*.ipa \
      --app $FIREBASE_IOS_APP_ID \
      --groups "ios-testers"
```

### 4. Slack Notifications

```yaml
publishing:
  slack:
    channel: '#ios-builds'
    notify:
      success: true
      failure: true
```

---

## ✅ Checklist

- [ ] Apple Developer Account ($99/year)
- [ ] App created in App Store Connect
- [ ] App Store Connect API Key created
- [ ] API Key added to Codemagic
- [ ] Code signing configured (automatic or manual)
- [ ] Bundle Identifier set correctly
- [ ] Info.plist configured
- [ ] Environment variables set
- [ ] Test build triggered
- [ ] IPA downloaded and tested
- [ ] TestFlight testers added
- [ ] Production build successful

---

## 📞 Support

- Codemagic iOS: https://docs.codemagic.io/yaml-code-signing/signing-ios/
- Apple Developer: https://developer.apple.com/support/
- App Store Connect: https://developer.apple.com/app-store-connect/
- TestFlight: https://developer.apple.com/testflight/

---

## 🎉 Quick Start

```bash
# 1. Setup Apple Developer Account
# 2. Create app in App Store Connect
# 3. Setup Codemagic integration
# 4. Configure signing

# 5. Trigger build
git checkout main
git tag ios-1.0.0
git push origin ios-1.0.0

# 6. Wait for build (~15 minutes)
# 7. Download IPA or test via TestFlight
# 8. Submit to App Store!
```

iOS IPA sẽ tự động build và upload lên TestFlight! 🚀
