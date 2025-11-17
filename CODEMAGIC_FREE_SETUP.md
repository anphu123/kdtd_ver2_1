# Hướng dẫn cấu hình Codemagic Free

## 📊 Gói Free của Codemagic
- **500 phút build/tháng** miễn phí
- **1 build đồng thời**
- **Mac mini M2** (mặc định)
- **3GB cache** mỗi build
- **120 phút** tối đa mỗi build

## 🎯 Chiến lược tiết kiệm phút build

### 1. Chọn file cấu hình phù hợp

**Option A: `codemagic-free.yaml`** (Khuyến nghị cho Free)
- Chỉ build khi tạo **tag** (release)
- Tách riêng Android và iOS workflows
- Có cache đầy đủ
- Giới hạn thời gian 45 phút/build
- Quick test cho PR (chỉ 10-15 phút)

**Option B: `codemagic.yaml`** (Đầy đủ tính năng)
- Build nhiều trigger hơn (push, PR, tag)
- Phù hợp khi nâng cấp lên gói trả phí

### 2. Cách sử dụng

#### Bước 1: Chọn file cấu hình
```bash
# Dùng file free (khuyến nghị)
cp codemagic-free.yaml codemagic.yaml

# Hoặc giữ nguyên file hiện tại nếu muốn
```

#### Bước 2: Commit và push
```bash
git add codemagic.yaml
git commit -m "Add Codemagic CI/CD config"
git push origin main
```

#### Bước 3: Kết nối Codemagic
1. Truy cập https://codemagic.io/
2. Đăng nhập bằng GitHub/GitLab/Bitbucket
3. Chọn repository của bạn
4. Codemagic sẽ tự động phát hiện file `codemagic.yaml`

### 3. Cấu hình trên Codemagic Dashboard

#### Android Signing
1. Vào **App settings** → **Code signing**
2. Upload file **keystore** (.jks hoặc .keystore)
3. Điền thông tin:
   - Keystore password
   - Key alias
   - Key password
4. Đặt tên reference: `keystore_reference`

#### Google Play Publishing
1. Tạo **Service Account** trên Google Cloud Console
2. Download file JSON credentials
3. Upload vào Codemagic → **Google Play**
4. Thêm vào Environment group: `google_play`

#### iOS Signing (nếu cần)
1. Kết nối **App Store Connect** integration
2. Codemagic sẽ tự động quản lý certificates
3. Hoặc upload manual certificates

#### Environment Variables
Vào **Environment variables** và thêm:
- `GCLOUD_SERVICE_ACCOUNT_CREDENTIALS` (cho Google Play)
- Các biến khác nếu cần

### 4. Trigger Builds

#### Với `codemagic-free.yaml`:
```bash
# Tạo tag để trigger build
git tag v1.0.0
git push origin v1.0.0

# Build Android
git tag v1.0.0-android
git push origin v1.0.0-android

# Build iOS
git tag v1.0.0-ios
git push origin v1.0.0-ios
```

#### Test trước khi release:
- Tạo Pull Request → Chạy `quick-test` workflow (10-15 phút)
- Không tốn nhiều phút cho việc test

## 💡 Tips tiết kiệm phút build

### ✅ Nên làm:
- Chỉ build khi **thực sự cần** (dùng tag)
- Bật **cache** cho Flutter, Gradle, CocoaPods
- Giới hạn **max_build_duration** (45 phút)
- Dùng **cancel_previous_builds: true**
- Tách riêng Android/iOS workflows
- Chỉ build 1 platform mỗi lần

### ❌ Không nên:
- Build mọi push lên mọi branch
- Build cả Android + iOS cùng lúc
- Chạy quá nhiều test cases
- Build debug + release cùng lúc
- Để build chạy quá 60 phút

## 📈 Theo dõi Usage

1. Vào **Team settings** → **Billing**
2. Xem **Build minutes used** trong tháng
3. Nếu gần hết 500 phút:
   - Giảm số lần build
   - Tối ưu thêm cache
   - Xóa bớt steps không cần thiết

## 🔄 Ước tính thời gian build

Với cấu hình tối ưu:
- **Android AAB**: 8-12 phút
- **iOS IPA**: 15-20 phút
- **Quick test**: 5-10 phút

→ Với 500 phút/tháng:
- ~40 builds Android
- ~25 builds iOS
- ~50-100 quick tests

## 🚀 Nâng cấp sau này

Khi cần build nhiều hơn, có thể:
1. Nâng cấp lên **Pay-as-you-go** ($0.038/phút)
2. Hoặc gói **Professional** ($99/tháng, 3000 phút)
3. Chuyển sang dùng file `codemagic.yaml` đầy đủ

## 📞 Hỗ trợ

- Docs: https://docs.codemagic.io/
- Pricing: https://codemagic.io/pricing/
- Support: support@codemagic.io
