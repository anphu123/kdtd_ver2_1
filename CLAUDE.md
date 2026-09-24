# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

Ứng dụng Flutter kiểm định phần cứng điện thoại tại quầy, phục vụ chương trình
thu cũ đổi mới / nâng cấp iPhone của **PVI Insurance**. Kỹ thuật viên chạy app
trên máy cửa hàng, kiểm định máy của khách, chấm Loại 1–5, rồi chốt đổi máy.

Giao tiếp, comment trong code và commit message đều dùng **tiếng Việt**.

## Lệnh thường dùng

```bash
flutter analyze                       # bắt buộc sạch trước khi commit
flutter test                          # toàn bộ test
flutter test test/widget_test.dart    # một file
flutter test --plain-name "tên test"  # một test cụ thể
dart format lib/ test/

flutter run                           # chạy dev
flutter build ios --release --no-codesign   # kiểm tra bản release biên dịch được, không cần cert
```

Sinh code (**bắt buộc chạy lại sau khi sửa file tương ứng**):

```bash
# Sau khi thêm/sửa key trong assets/translations/*.json
dart run easy_localization:generate -S assets/translations -f keys -o locale_keys.g.dart -O lib/generated

# Sau khi thêm asset mới vào pubspec.yaml (sinh lib/gen/assets.gen.dart)
dart run build_runner build --delete-conflicting-outputs
```

Phát hành TestFlight: xem [docs/TESTFLIGHT.md](docs/TESTFLIGHT.md) và
`scripts/testflight.sh`. Bundle ID `pvi.check`, team `99C7YYT558`
(Rentino Joint Stock Company).

## Kiến trúc

### GetX theo module

Mỗi màn là một thư mục trong `lib/app/modules/<tên>/` gồm
`<tên>_controller.dart` + `<tên>_page.dart` + `<tên>_binding.dart`.

**Toàn bộ nghiệp vụ sống trong controller; page là UI thuần** chỉ đọc field
`.obs` qua `Obx` và gọi method của controller. Không đặt logic, không giữ
`TextEditingController`, không gọi service trong page. Widget cần `vsync` thì
tách một `StatefulWidget` con **nhận controller qua constructor** (xem
`MicTestPage`, `EarpieceTestPage`) — đừng tra cứu lại bằng `Get.find` bên
trong `Obx`, vì controller có thể đã bị `Get.delete` trong lúc dialog chạy
animation đóng.

Route khai báo tập trung ở `lib/app/routes/app_pages.dart` qua helper `_page()`
— helper này gắn sẵn `curve`/`transitionDuration`; tạo `GetPage` trực tiếp là
rơi về `Curves.linear`.

### Ba tầng dữ liệu kiểm định

1. **Thu thập** — `lib/app/data/services/`
   - `device_info_helper.dart`: OS, model, RAM, ROM qua MethodChannel
     `com.fidobox/diagnostics` (Android: `MainActivity.kt`, iOS:
     `AppDelegate.swift`).
   - `device_hardware_service.dart`: pin, Wi-Fi, Bluetooth, NFC, cảm biến, GPS.

2. **Chấm điểm** — `rule_evaluator.dart` nạp **`assets/diag_rules.json`**
   (biểu thức pass/fail/skip dạng chuỗi, có hàm `exists()`, `perm_denied()`,
   `is_miui()`, `location_service_on()`) và `assets/diag_thresholds.json`.
   **Sửa tiêu chí pass/fail thì sửa JSON, không sửa Dart.**

3. **Phân loại** — `diagnostic_grade_service.dart`: bất kỳ Function Check nào
   `failed` → **Loại 5**; ngược lại lấy theo Question Check. Chỉ Loại 1–2 mới
   đủ điều kiện nâng cấp (`UpgradeProgramConstants.maxEligibleType`).

### Luồng màn hình

```
Welcome → Trang chủ → Nhập serial → Cấp quyền → Xác nhận cấu hình
        → Hướng dẫn chuẩn bị → Test Runner → Question Check
        → Kết quả → Mã nhân viên → Chúc mừng
```

`TestRunnerController` là trái tim: dựng danh sách `DiagStep` chia theo
`DiagPhase` (critical / connectivity / sensors / hardware / screen), chạy tuần
tự, bước cần thao tác tay thì mở dialog qua hàm `interact`.

Hằng số nghiệp vụ nằm rải trong `lib/app/core/constants/` — ngưỡng, thời lượng,
serial hợp lệ. Đừng hard-code số trong widget.

## Cạm bẫy đã gặp

**Simulator không chạy được các bài phần cứng.** Bluetooth, phím âm lượng, loa
trong, cảm biến tiệm cận, mic đều trả `false` trên iOS Simulator vì không có
phần cứng — đó **không phải bug**. Phải nghiệm thu trên máy thật. Khi người
dùng báo một bài test fail, hỏi họ đang chạy máy ảo hay máy thật trước khi đi
sửa code.

**`Get.dialog` mặc định bọc child trong `SafeArea`**, làm `Dialog.fullscreen`
co lại và chừa trống dải tai thỏ. Bài test cảm ứng cần phủ 100% màn hình →
phải truyền `useSafeArea: false`.

**Không gọi `Get.snackbar` từ trong một `Get.dialog`.** Snackbar không tìm thấy
`Overlay` nhưng vẫn vào hàng đợi với `_controller` chưa khởi tạo, khiến **mọi**
`Get.back()` sau đó ném `LateInitializationError` và dialog kẹt vĩnh viễn. Hiện
lỗi bằng một field `.obs` ngay trong dialog.

**`finish()` của các controller test phải có cờ chặn gọi lặp** + kiểm tra
`Get.isDialogOpen`, vì timer tự động và nút bấm tay có thể cùng kích hoạt.

**`BytesSource` của audioplayers hỏng trên iOS/macOS** — nó ghi bytes ra file
tạm không có phần mở rộng nên AVPlayer không đoán được định dạng. Dùng
`WavToneGenerator.sineWaveFile()` (ghi file `.wav`) + `DeviceFileSource`.

**EventChannel `com.fidobox/diagnostics_keyevents` chỉ được `listen` MỘT lần.**
Native chỉ giữ một `eventSink`; listen lần hai chiếm sink của lần một, và khi
nó cancel thì native chạy `onCancel` tắt luôn bộ quan sát âm lượng.
`KeysTestController` phát lại qua một `StreamController` nội bộ.

**iOS không đọc được free RAM**, chỉ có tổng. RAM/ROM làm tròn **lên** mốc
chuẩn (`roundUpToStandardGb`) vì dung lượng thô luôn thấp hơn số quảng cáo
(128GB thật ra ~119GiB). Đọc không được thì hiện `N/A` — **không bịa số mặc
định**, đây là app kiểm định.

**Quyền trên iOS:** `permission_handler` biên dịch mỗi quyền sau một macro,
mặc định tắt hết. Block `post_install` trong `ios/Podfile` bật thủ công từng
cái — thêm quyền mới phải thêm macro ở đó, không thì `request()` trả `denied`
ngay mà không hiện hộp thoại.

## Quy ước

- Commit message tiếng Việt, dạng `type(scope): mô tả`. **Không thêm dòng
  `Co-Authored-By`.**
- Mọi chuỗi hiển thị đi qua `LocaleKeys.<key>.trans()`, khai báo song song ở
  `assets/translations/vi.json` và `en.json`.
- Màu và kiểu chữ lấy từ `AppColors` / `AppTextStyles`, không viết `Color(0x…)`
  trong widget. Kích thước dùng `flutter_screenutil` (`.w .h .r .sp`,
  designSize 375×812).
- Băng "THỬ NGHIỆM" đang **bật mặc định** (`BuildFlags.showTestBanner`). Phát
  hành thật phải đổi `defaultValue` thành `false` — Xcode archive không đọc
  `--dart-define`.
