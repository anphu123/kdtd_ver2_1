# Debug Print Guide - Auto Diagnostics

## Tổng quan
Đã thêm các câu lệnh print debug chi tiết vào quá trình kiểm định tự động để theo dõi:
- Luồng thực thi của từng test
- Dữ liệu thu thập được
- Kết quả đánh giá từ Rule Evaluator
- Lý do pass/fail cho mỗi test

## Các thay đổi đã thực hiện

### 1. Auto Diagnostics Controller (`auto_diagnostics_controller.dart`)

#### A. Phương thức `start()` - Luồng chính
Thêm debug prints cho:
- **Khởi đầu quá trình**: Hiển thị thời gian bắt đầu
- **Khởi tạo Rule Evaluator**: Trạng thái và thông tin profile
- **Cập nhật môi trường**: Permissions, location service
- **Từng test được chạy**:
  - Tên và loại test (Auto/Manual)
  - Kết quả thực thi (SUCCESS/FAILED)
  - Dữ liệu thu thập được (payload)
  - Kết quả đánh giá từ Rule Evaluator
  - Lý do pass/fail/skip
  - Trạng thái cuối cùng
- **Tổng kết cuối**: Điểm số, số lượng pass/fail/skip

**Ví dụ output:**
```
╔════════════════════════════════════════════════════════════╗
║       BẮT ĐẦU QUÁ TRÌNH KIỂM ĐỊNH TỰ ĐỘNG                 ║
╚════════════════════════════════════════════════════════════╝
⏰ Thời gian: 2025-11-11 10:30:45.123

🔧 Khởi tạo Rule Evaluator...
✅ Rule Evaluator đã sẵn sàng
   ├─ Device Profile: Samsung Galaxy S21
   ├─ Platform: android
   └─ Brand: samsung

🔄 Cập nhật môi trường...
   ├─ Location Service: ON
   ├─ Granted Perms: 5
   └─ Denied Perms: 0

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔍 Test: battery - Pin & Sạc
   ├─ Type: Auto
   ├─ Đang chạy test tự động...
   ├─ Kết quả thực thi: SUCCESS
   ├─ Dữ liệu thu thập: {level: 85, state: charging}
      [RuleEval] Evaluating: battery
      [RuleEval] Payload: {level: 85, state: charging}
      [RuleEval] Result: PASS
   ├─ Rule Evaluation: PASS
   ├─ Lý do: Mức pin: 85%
   └─ ✅ Status: PASSED

🔍 Test: wifi - Wi-Fi (SSID)
   ├─ Type: Auto
   ├─ Đang chạy test tự động...
   ├─ Kết quả thực thi: SUCCESS
   ├─ Dữ liệu thu thập: {connected: true, ssid: "MyWiFi"}
      [RuleEval] Evaluating: wifi
      [RuleEval] Payload: {connected: true, ssid: "MyWiFi"}
      [RuleEval] Result: PASS
   ├─ Rule Evaluation: PASS
   ├─ Lý do: Kết nối: MyWiFi
   └─ ✅ Status: PASSED

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 KẾT QUẢ CUỐI CÙNG:
   ├─ Tổng số test: 25
   ├─ ✅ Passed: 20
   ├─ ❌ Failed: 3
   ├─ ⊝ Skipped: 2
   ├─ 📈 Điểm số: 80/100
   └─ 🏆 Xếp loại: Loại 2
```

#### B. Phương thức `_initializeEvaluator()`
Thêm debug prints cho:
- Quá trình khởi tạo
- Thông tin thiết bị (brand, model, platform)
- Profile được load
- Thông tin cấu hình profile (tier, features)

#### C. Phương thức `printTestResults()` - Được gọi tự động
In báo cáo chi tiết định dạng đẹp:
- Thông tin thiết bị (Model, Hãng, Platform, IMEI)
- Thông tin phần cứng (RAM, ROM)
- Tổng kết kết quả
- Chi tiết từng test với status icon

### 2. Rule Evaluator (`rule_evaluator.dart`)

#### Phương thức `evaluate()`
Thêm debug prints cho:
- Test đang được đánh giá
- Payload nhận được
- Kết quả đánh giá (PASS/FAIL/SKIP)

**Ví dụ output:**
```
      [RuleEval] Evaluating: battery
      [RuleEval] Payload: {level: 85, state: charging}
      [RuleEval] Result: PASS
```

### 3. Auto Diagnostics View (`auto_diagnostics_view.dart`)

#### Floating Action Button
Thêm nút "Print Results" để:
- Xuất hiện sau khi có test được hoàn thành
- Cho phép in báo cáo chi tiết ra console bất cứ lúc nào
- Icon: 🖨️ Print
- Tooltip: "In kết quả ra console"

## Cách sử dụng

### 1. Chạy ứng dụng
```bash
flutter run
```

### 2. Xem console output
- Mở tab "Run" hoặc "Debug Console" trong IDE
- Khi bắt đầu diagnostics, sẽ thấy dòng print chi tiết
- Theo dõi từng bước test được thực hiện

### 3. In báo cáo chi tiết
Có 2 cách:
- **Tự động**: Sau khi hoàn thành tất cả test, báo cáo sẽ tự động in ra
- **Thủ công**: Nhấn nút "Print Results" (FAB) để in lại bất cứ lúc nào

### 4. Phân tích kết quả

#### Tại sao test PASS?
Xem dòng:
```
   ├─ Dữ liệu thu thập: {...}
   ├─ Rule Evaluation: PASS
   ├─ Lý do: [mô tả cụ thể]
```

#### Tại sao test FAIL?
Xem dòng:
```
   ├─ Dữ liệu thu thập: {...}
   ├─ Rule Evaluation: FAIL
   ├─ Lý do: [mô tả cụ thể tại sao fail]
```

#### Tại sao test SKIP?
Xem dòng:
```
   ├─ Rule Evaluation: SKIP
   ├─ Lý do: [lý do skip, vd: thiếu quyền, không áp dụng cho thiết bị này]
```

## Các trường hợp đặc biệt

### Fallback Logic
Nếu không có Rule Evaluator hoặc không có dữ liệu, sẽ thấy:
```
   ├─ Sử dụng fallback logic (không có evaluator hoặc data)
   └─ ✅ Status: PASSED (fallback)
```

### Lỗi khi thực thi test
```
   ├─ ❌ Lỗi: [chi tiết lỗi]
   └─ Status: FAILED
```

### Test bị skip do không có hàm
```
   ├─ ⚠️  Không có hàm thực thi
   └─ Status: SKIPPED
```

## Icons sử dụng

- ✅ PASSED
- ❌ FAILED
- ⊝ SKIPPED
- 🔧 Đang khởi tạo
- 🔄 Đang cập nhật
- 🔍 Đang test
- 📊 Kết quả
- 🏆 Xếp loại
- 📈 Điểm số
- ⏰ Thời gian

## Lợi ích

1. **Debug dễ dàng**: Biết chính xác test nào fail và tại sao
2. **Theo dõi luồng**: Hiểu rõ quá trình thực thi
3. **Phân tích dữ liệu**: Xem dữ liệu thực tế được thu thập
4. **Kiểm tra logic**: Xác nhận Rule Evaluator hoạt động đúng
5. **Báo cáo đẹp**: Format output dễ đọc và chuyên nghiệp

## Tắt debug prints (nếu cần)

Để tắt debug prints trong production:
1. Tìm tất cả `print('` trong file
2. Thay bằng `debugPrint('` hoặc comment lại
3. Hoặc wrap trong `if (kDebugMode) { print(...); }`

## Ví dụ phân tích cụ thể

### Trường hợp 1: WiFi test PASS
```
🔍 Test: wifi - Wi-Fi (SSID)
   ├─ Type: Auto
   ├─ Đang chạy test tự động...
   ├─ Kết quả thực thi: SUCCESS
   ├─ Dữ liệu thu thập: {connected: true, ssid: "MyWiFi"}
      [RuleEval] Evaluating: wifi
      [RuleEval] Payload: {connected: true, ssid: "MyWiFi"}
      [RuleEval] Result: PASS
   ├─ Rule Evaluation: PASS
   ├─ Lý do: Kết nối: MyWiFi
   └─ ✅ Status: PASSED
```

**Phân tích**: 
- Test chạy thành công (SUCCESS)
- Có kết nối WiFi (connected: true)
- Đọc được SSID ("MyWiFi")
- Rule Evaluator đánh giá PASS vì có kết nối
- Lý do: "Kết nối: MyWiFi"

### Trường hợp 2: NFC test SKIP
```
🔍 Test: nfc - NFC
   ├─ Type: Auto
   ├─ Đang chạy test tự động...
   ├─ Kết quả thực thi: SUCCESS
   ├─ Dữ liệu thu thập: {available: false}
      [RuleEval] Evaluating: nfc
      [RuleEval] Payload: {available: false}
      [RuleEval] Result: SKIP
   ├─ Rule Evaluation: SKIP
   ├─ Lý do: Thiết bị không có NFC
   └─ ⊝ Status: SKIPPED
```

**Phân tích**:
- Test chạy thành công (SUCCESS)
- NFC không khả dụng (available: false)
- Rule Evaluator đánh giá SKIP vì thiết bị không có NFC
- Đây là hành vi mong đợi, không phải lỗi

### Trường hợp 3: GPS test FAIL
```
🔍 Test: gps - GPS (accuracy)
   ├─ Type: Auto
   ├─ Đang chạy test tự động...
   ├─ Kết quả thực thi: SUCCESS
   ├─ Dữ liệu thu thập: {accuracy: 150.5, enabled: true}
      [RuleEval] Evaluating: gps
      [RuleEval] Payload: {accuracy: 150.5, enabled: true}
      [RuleEval] Result: FAIL
   ├─ Rule Evaluation: FAIL
   ├─ Lý do: Độ chính xác quá thấp: 150.5m (yêu cầu < 50m)
   └─ ❌ Status: FAILED
```

**Phân tích**:
- Test chạy thành công (SUCCESS)
- GPS bật (enabled: true)
- Nhưng độ chính xác 150.5m > ngưỡng 50m
- Rule Evaluator đánh giá FAIL
- Lý do cụ thể: độ chính xác không đủ tốt

---

**Tạo ngày**: 11/11/2025
**Phiên bản**: 1.0
**Tác giả**: Auto-generated documentation

