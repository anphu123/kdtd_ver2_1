# Đẩy app lên TestFlight

Toàn bộ việc dựng và nộp build nằm trong một script duy nhất:

```bash
./scripts/testflight.sh          # build number lấy từ pubspec.yaml
./scripts/testflight.sh 7        # chỉ định build number
BUILD_ONLY=1 ./scripts/testflight.sh   # chỉ dựng IPA, không upload
```

Script chỉ dùng công cụ sẵn có của Xcode (`xcrun altool`), **không cần cài
fastlane** hay Ruby gem nào — máy đang chạy Ruby 2.6 hệ thống, cài gem vào đó
phải `sudo` và dễ vỡ.

Trước khi chạy được, còn **3 việc bắt buộc phải làm thủ công một lần**. Script
sẽ dừng lại kèm hướng dẫn nếu thiếu bất kỳ bước nào.

---

## 1. Đăng ký App ID + tạo app record

Bundle ID đã đặt sẵn trong project: **`pvi.check`**
(target test: `pvi.check.RunnerTests`). Không cần sửa gì trong Xcode nữa.

Việc còn lại trên web:

1. [developer.apple.com → Identifiers](https://developer.apple.com/account/resources/identifiers/list)
   → **+** → **App IDs** → **App** → Bundle ID chọn **Explicit**, nhập
   `pvi.check`, Description đặt gì cũng được.
2. [App Store Connect → Apps](https://appstoreconnect.apple.com/apps) → **+**
   → **New App**:
   - Platform: **iOS**
   - Bundle ID: chọn `pvi.check` vừa đăng ký
   - Name: tên hiển thị trên store (phải là duy nhất toàn App Store)
   - SKU: mã nội bộ tuỳ ý, vd `PVI-CHECK-001`

> Nếu portal báo `pvi.check` đã có người đăng ký (namespace ngắn, không theo
> reverse-DNS nên dễ trùng), đổi sang `vn.pvi.check` rồi chạy:
> ```bash
> sed -i '' 's/pvi\.check/vn.pvi.check/g' ios/Runner.xcodeproj/project.pbxproj
> ```

## 2. Chứng chỉ phân phối

Team: **Rentino Joint Stock Company**, Team ID **`99C7YYT558`** — đã đặt sẵn
trong `project.pbxproj` và `ios/ExportOptions.plist`.

> Đừng nhầm `AWJ2P935D5` hay `74GAQ5K774` là Team ID. Đó là mã **cá nhân** của
> developer nằm trong tên chứng chỉ (`Apple Development: Huan Phung (AWJ2P935D5)`).
> Team ID thật nằm ở trường **OU**, xem bằng:
> ```bash
> security find-certificate -a -c "Apple Development" -p | openssl x509 -noout -subject
> ```
> Đặt nhầm mã cá nhân vào `DEVELOPMENT_TEAM` sẽ ra lỗi `No Account for Team`.

Cách nhanh nhất là để **Xcode tự tạo** chứng chỉ Apple Distribution khi archive:
`Product → Archive → Distribute App → TestFlight & App Store`, giữ nguyên
"Automatically manage signing".

Lưu ý chứng chỉ `Apple Development: huanpv@rentino.vn (74GAQ5K774)` trên máy này
**đã bị thu hồi** (`CSSMERR_TP_CERT_REVOKED`) — không dùng được nữa, bỏ qua nó.

## 3. Tạo App Store Connect API key

Đây là cách upload không cần nhập mật khẩu / mã 2FA mỗi lần.

[App Store Connect → Users and Access → Integrations → App Store Connect API](https://appstoreconnect.apple.com/access/integrations/api)
→ **+** → role **App Manager** → tải file `AuthKey_XXXXXXXX.p8`.

> File `.p8` **chỉ tải được đúng một lần**. Cất kỹ, đừng commit vào git
> (`.gitignore` đã chặn sẵn `*.p8`).

Khai báo 3 biến môi trường (thêm vào `~/.zshrc` cho tiện):

```bash
export ASC_KEY_ID="XXXXXXXX"                       # Key ID
export ASC_ISSUER_ID="xxxxxxxx-xxxx-xxxx-..."      # Issuer ID (UUID)
export ASC_KEY_PATH="$HOME/keys/AuthKey_XXXXXXXX.p8"
```

---

## Mỗi lần phát hành

1. **Tăng build number** trong [`pubspec.yaml`](../pubspec.yaml) — phần sau dấu
   `+` của `version: 1.0.0+1`. Apple từ chối build trùng số. Hoặc truyền thẳng:
   `./scripts/testflight.sh 7`.
2. Commit code trước khi build, để biết build đó ứng với commit nào.
3. Chạy `./scripts/testflight.sh`.
4. Apple xử lý 5–30 phút. Theo dõi ở **App Store Connect → TestFlight**.

Lần nộp đầu tiên sẽ bị hỏi thêm **Export Compliance** (app có dùng mã hoá
không) ngay trên web trước khi phát cho tester.

## Kiểm tra nhanh không cần ký

Muốn biết bản release có biên dịch được không mà chưa cần cert:

```bash
flutter build ios --release --no-codesign
```
