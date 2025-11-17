# Codemagic CI/CD Setup Guide

## 🚀 Cấu hình Codemagic cho Android APK

File `codemagic.yaml` đã được cấu hình với 3 workflows:

### 1. **android-debug** - Debug APK
- Trigger: Push lên branch `develop`
- Build: Debug APK
- Output: `kdtd-v1.0.0-debug-buildXXX.apk`

### 2. **android-release** - Release APK
- Trigger: Push lên branch `main` hoặc tag `v*`
- Build: Release APK (Universal + Split per ABI)
- Output: 
  - `kdtd-v1.0.0-release-universal.apk`
  - `kdtd-v1.0.0-release-arm64-v8a.apk`
  - `kdtd-v1.0.0-release-armeabi-v7a.apk`
  - `kdtd-v1.0.0-release-x86_64.apk`

### 3. **android-appbundle** - App Bundle (AAB)
- Trigger: Tag `release-*`
- Build: App Bundle cho Google Play Store
- Auto upload lên Play Store (Internal track)

---

## 📋 Setup Instructions

### Bước 1: Đăng ký Codemagic

1. Truy cập: https://codemagic.io
2. Sign up với GitHub/GitLab/Bitbucket
3. Free tier: 500 build minutes/month

### Bước 2: Add Application

1. Click **Add application**
2. Chọn repository: `kdtd_ver2_1`
3. Select project type: **Flutter**
4. Click **Finish**

### Bước 3: Configure Workflows

Codemagic sẽ tự động detect file `codemagic.yaml`

1. Vào **App settings**
2. Tab **Workflow editor**
3. Verify 3 workflows đã được load

### Bước 4: Setup Android Signing (Cho Release builds)

#### A. Tạo Keystore (nếu chưa có)

```bash
keytool -genkey -v -keystore upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload \
  -storepass your_store_password \
  -keypass your_key_password
```

#### B. Upload Keystore lên Codemagic

1. Vào **App settings** → **Code signing identities**
2. Tab **Android**
3. Click **Upload keystore**
4. Upload file `upload-keystore.jks`
5. Điền thông tin:
   - **Keystore password**: `your_store_password`
   - **Key alias**: `upload`
   - **Key password**: `your_key_password`
6. Click **Save**

#### C. Create Environment Variable Group

1. Vào **Teams** → **Environment variables**
2. Click **Add variable group**
3. Tên: `android_credentials`
4. Add variables:
   - `CM_KEYSTORE_PASSWORD` = your_store_password
   - `CM_KEY_PASSWORD` = your_key_password
   - `CM_KEY_ALIAS` = upload
5. Click **Save**

### Bước 5: Setup Google Play (Optional - cho AAB workflow)

#### A. Tạo Service Account

1. Vào [Google Cloud Console](https://console.cloud.google.com)
2. Create new project hoặc select existing
3. Enable **Google Play Android Developer API**
4. Create **Service Account**
5. Download JSON key

#### B. Add Service Account to Play Console

1. Vào [Google Play Console](https://play.google.com/console)
2. **Setup** → **API access**
3. Link service account
4. Grant permissions: **Release manager**

#### C. Add to Codemagic

1. Vào **Teams** → **Environment variables**
2. Create group: `google_play`
3. Add variable:
   - `GCLOUD_SERVICE_ACCOUNT_CREDENTIALS`
   - Value: Paste nội dung JSON key
   - Type: **Secure**
4. Click **Save**

### Bước 6: Configure Email Notifications

1. Vào **App settings** → **Notifications**
2. Add email: `dev@fidobox.com`
3. Enable notifications for:
   - Build success
   - Build failure

### Bước 7: Setup Slack (Optional)

1. Create Slack webhook
2. Add to environment variables:
   - `SLACK_WEBHOOK_URL`
3. Update `codemagic.yaml` với webhook URL

---

## 🎯 Trigger Builds

### Auto Trigger

**Debug Build:**
```bash
git checkout develop
git add .
git commit -m "Update feature"
git push origin develop
```

**Release Build:**
```bash
git checkout main
git add .
git commit -m "Release v1.0.0"
git push origin main
```

**App Bundle:**
```bash
git tag release-1.0.0
git push origin release-1.0.0
```

### Manual Trigger

1. Vào Codemagic dashboard
2. Select workflow
3. Click **Start new build**
4. Select branch/tag
5. Click **Start build**

---

## 📦 Download APK

### Từ Codemagic

1. Vào **Builds** tab
2. Click vào build đã hoàn thành
3. Tab **Artifacts**
4. Download APK files

### Từ Email

- Nhận email notification
- Click link download trong email

---

## 🔧 Customize Workflows

### Change Build Number

Edit `codemagic.yaml`:
```yaml
--build-name=1.0.$BUILD_NUMBER
--build-number=$BUILD_NUMBER
```

### Add Environment Variables

```yaml
environment:
  vars:
    MY_VARIABLE: "value"
    API_URL: "https://api.example.com"
```

### Add Build Steps

```yaml
scripts:
  - name: Custom step
    script: |
      echo "Running custom script"
      # Your commands here
```

### Change Instance Type

```yaml
instance_type: linux_x2      # Standard (Free)
# instance_type: mac_mini_m1  # Mac (Paid)
# instance_type: linux_x4     # Larger (Paid)
```

---

## 📊 Build Status Badge

Thêm vào README.md:

```markdown
[![Codemagic build status](https://api.codemagic.io/apps/APP_ID/status_badge.svg)](https://codemagic.io/apps/APP_ID/latest_build)
```

Replace `APP_ID` với ID từ Codemagic dashboard.

---

## 🐛 Troubleshooting

### Build fails với "Keystore not found"

**Solution:**
1. Verify keystore đã upload
2. Check environment variable group đã link với workflow
3. Verify keystore reference name trong `codemagic.yaml`

### Build fails với "Gradle error"

**Solution:**
Add vào `android/gradle.properties`:
```properties
org.gradle.jvmargs=-Xmx4096m
org.gradle.daemon=false
```

### Build timeout

**Solution:**
1. Increase `max_build_duration` trong workflow
2. Hoặc upgrade instance type

### Permission denied

**Solution:**
Add execute permission:
```yaml
- name: Make gradlew executable
  script: chmod +x android/gradlew
```

---

## 💰 Pricing

### Free Tier
- 500 build minutes/month
- Linux instances
- Unlimited apps
- Email notifications

### Pro Tier ($99/month)
- Unlimited build minutes
- Mac instances (for iOS)
- Priority support
- Advanced features

### Teams ($299/month)
- Everything in Pro
- Multiple team members
- SSO
- Advanced analytics

---

## 🚀 Advanced Features

### 1. Firebase App Distribution

Uncomment trong workflow:
```yaml
- name: Upload to Firebase
  script: |
    firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
      --app $FIREBASE_APP_ID \
      --groups "testers"
```

Setup:
1. Install Firebase CLI
2. Add `FIREBASE_APP_ID` to environment variables
3. Add Firebase token

### 2. Automatic Version Increment

Add script:
```yaml
- name: Increment version
  script: |
    VERSION=$(grep '^version:' pubspec.yaml | cut -d ' ' -f 2)
    NEW_VERSION=$(echo $VERSION | awk -F. '{$NF = $NF + 1;} 1' | sed 's/ /./g')
    sed -i "s/version: $VERSION/version: $NEW_VERSION/" pubspec.yaml
```

### 3. Run Tests Before Build

```yaml
- name: Run integration tests
  script: |
    flutter drive --target=test_driver/app.dart
```

### 4. Code Coverage

```yaml
- name: Generate coverage
  script: |
    flutter test --coverage
    genhtml coverage/lcov.info -o coverage/html
```

---

## 📱 Testing APK

### Install via ADB

```bash
adb install path/to/app-release.apk
```

### Share via Link

1. Upload APK to cloud storage
2. Share link với testers
3. Testers download và install

### Firebase App Distribution

- Automatic distribution
- Tester management
- Release notes
- Analytics

---

## ✅ Checklist

- [ ] Codemagic account created
- [ ] Repository connected
- [ ] Workflows configured
- [ ] Keystore uploaded (for release)
- [ ] Environment variables set
- [ ] Email notifications configured
- [ ] Test build triggered
- [ ] APK downloaded and tested
- [ ] Google Play setup (for AAB)
- [ ] Production build successful

---

## 📞 Support

- Codemagic Docs: https://docs.codemagic.io
- Community: https://community.codemagic.io
- Support: support@codemagic.io
- Status: https://status.codemagic.io

---

## 🎉 Quick Start

```bash
# 1. Push codemagic.yaml
git add codemagic.yaml
git commit -m "Add Codemagic CI/CD"
git push origin main

# 2. Setup Codemagic
# - Sign up at codemagic.io
# - Add repository
# - Upload keystore
# - Configure environment variables

# 3. Trigger build
git checkout develop
git push origin develop

# 4. Download APK from Codemagic dashboard
# 5. Test and deploy!
```

Build tự động mỗi khi push code! 🚀
