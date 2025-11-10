# 🎯 Hệ Thống Đánh Giá Tự Động - Rule-Based Evaluation

## Tổng Quan

Hệ thống đánh giá tự động cho phép chấm điểm kết quả kiểm tra thiết bị một cách **thông minh** và **linh hoạt** dựa trên:

- ✅ **Rules JSON**: Quy tắc PASS/FAIL/SKIP cho 24 tests
- ✅ **Thresholds**: Ngưỡng có thể điều chỉnh (dBm, accuracy, ratio...)
- ✅ **Device Profiles**: Yêu cầu theo từng model máy (Samsung S21 Ultra yêu cầu S-Pen...)
- ✅ **Environment-Aware**: Hiểu quyền, dịch vụ, ROM quirks (MIUI/ColorOS)

## 🚀 Quick Start

### 1. File Structure đã được tạo

```
assets/
├── diag_rules.json              # Quy tắc cho 24 tests
└── diag_thresholds.json         # Ngưỡng & 9+ profiles

lib/diagnostics/model/
├── device_profile.dart          # ✅ Model profile
├── diag_environment.dart        # ✅ Model environment
├── diag_thresholds.dart         # ✅ Model thresholds
├── profile_manager.dart         # ✅ Profile loader
└── rule_evaluator.dart          # ✅ Evaluation engine

lib/diagnostics/examples/
└── rule_evaluation_example.dart # ✅ Usage examples

Docs/
├── RULE_BASED_EVALUATION_GUIDE.md      # Chi tiết hướng dẫn
└── RULE_EVALUATION_IMPLEMENTATION.md   # Tổng kết triển khai
```

### 2. Controller đã được tích hợp

Controller tự động:
1. Load device info → Tìm profile phù hợp
2. Build environment → Check permissions/services
3. Initialize evaluator → Sẵn sàng đánh giá
4. Run tests → Auto evaluate → Update status & reason

### 3. Chạy Test

```dart
// Trong controller
await controller.start();

// Xem kết quả chi tiết
controller.printTestResults();
```

## 📊 Ma Trận Đánh Giá

### WiFi Test
| Điều kiện | Kết quả | Lý do |
|-----------|---------|-------|
| Connected + có SSID | ✅ PASS | "Kết nối: MyWiFi" |
| Connected nhưng không SSID | ❌ FAIL | "Không đọc được SSID" |
| Không connected | ⊘ SKIP | "Không kết nối Wi-Fi" |
| Location OFF (MIUI) | ⊘ SKIP | "Vị trí chưa bật (cần cho SSID)" |

### Mobile Network Test
| Điều kiện | Kết quả | Lý do |
|-----------|---------|-------|
| dBm trong [-120, -40] | ✅ PASS | "Tín hiệu: -75 dBm" |
| dBm < -120 | ❌ FAIL | "Tín hiệu yếu: -125 dBm" |
| Không connected | ⊘ SKIP | "Không kết nối mạng di động" |
| Thiếu quyền phone_state | ⊘ SKIP | "Thiếu quyền READ_PHONE_STATE" |

### GPS Test
| Điều kiện | Kết quả | Lý do |
|-----------|---------|-------|
| Accuracy ≤ 50m | ✅ PASS | "Độ chính xác: 12.5m" |
| Accuracy > 50m | ❌ FAIL | "Độ chính xác kém: 75m" |
| Location Service OFF | ⊘ SKIP | "Dịch vụ vị trí chưa bật" |
| Thiếu quyền location | ⊘ SKIP | "Thiếu quyền vị trí" |

### S-Pen Test (Samsung)
| Điều kiện | Kết quả | Lý do |
|-----------|---------|-------|
| Profile yêu cầu + detected | ✅ PASS | "S-Pen hoạt động" |
| Profile yêu cầu + không detect | ❌ FAIL | "Thiết bị yêu cầu S-Pen nhưng không phát hiện" |
| Profile không yêu cầu | ⊘ SKIP | "Thiết bị không có S-Pen" |

## 🔧 Tùy Chỉnh

### Thay đổi ngưỡng

**File**: `assets/diag_thresholds.json`

```json
{
  "thresholds": {
    "mobile": {
      "dbm_min": -120,  // Tín hiệu yếu nhất
      "dbm_max": -40    // Tín hiệu mạnh nhất
    },
    "gps": {
      "accuracy_m_pass": 50  // Độ chính xác tối đa (m)
    },
    "touch": {
      "pass_ratio_min": 0.98  // 98% vùng phải OK
    }
  }
}
```

### Thêm profile mới

```json
{
  "requirements_by_profile": {
    "samsung_s23_ultra": {
      "require": ["nfc"],
      "spen": true,
      "bio": true,
      "secure_lock": false
    }
  }
}
```

### Xử lý ROM đặc biệt

```json
{
  "brand_quirks": {
    "xiaomi": {
      "wifi_requires_location": true,
      "bt_requires_location": true
    }
  }
}
```

## 📱 Profiles Được Hỗ Trợ

### Samsung (4 profiles)
- `samsung_s21` - NFC, Bio
- `samsung_s21_ultra` - **NFC, S-Pen**, Bio
- `samsung_note20_ultra` - **NFC, S-Pen**, Bio
- `samsung_a52` - NFC, Bio

### Xiaomi (2 profiles)
- `xiaomi_12` - NFC, Bio
- `xiaomi_redmi_note_11` - Bio

### OPPO
- `oppo_findx5` - Bio

### Apple
- `iphone_13` - NFC, Bio, **Secure Lock**

### Default
- Fallback cho thiết bị không xác định

## 🎨 Ví Dụ Sử Dụng

### Load Profile

```dart
final profileManager = await ProfileManager.getInstance();
final profile = profileManager.getProfile('SM-G998B', 'Samsung');
print('Profile: ${profile.name}'); // samsung_s21_ultra
print('S-Pen required: ${profile.sPen}'); // true
```

### Evaluate Test

```dart
final evaluator = await RuleEvaluator.create(
  profile: profile,
  environment: environment,
);

final result = evaluator.evaluate('wifi', {
  'connected': true,
  'ssid': 'MyWiFi',
});
// result = EvalResult.pass

final reason = evaluator.getReason('wifi', payload, result);
// reason = "Kết nối: MyWiFi"
```

### Check Brand Quirks

```dart
final manager = await ProfileManager.getInstance();
final needsLocation = manager.requiresLocationForWifi('xiaomi');
// true (MIUI cần Location để đọc SSID)
```

## 📚 Documentation

| File | Mô tả |
|------|-------|
| `RULE_BASED_EVALUATION_GUIDE.md` | Hướng dẫn đầy đủ, ma trận tiêu chí, thêm test mới |
| `RULE_EVALUATION_IMPLEMENTATION.md` | Tổng kết triển khai, checklist, next steps |
| `lib/diagnostics/examples/rule_evaluation_example.dart` | Code examples |

## ✨ Tính Năng Nổi Bật

### 1. Smart SKIP Logic
Không trừ điểm nếu:
- Thiếu quyền (có thể xin lại)
- Dịch vụ tắt (có thể bật)
- ROM chặn API (không phải lỗi thiết bị)
- Profile không yêu cầu (VD: NFC trên máy cũ)

### 2. Profile-Aware
- S21 Ultra **phải có** S-Pen → FAIL nếu không detect
- Redmi Note 11 **không cần** NFC → SKIP nếu không có
- iPhone **phải có** Secure Lock → FAIL nếu không bật

### 3. Brand-Specific Handling
- **MIUI**: Auto SKIP WiFi/BT nếu Location OFF (không phải lỗi)
- **ColorOS**: Tương tự MIUI + nearby devices permission
- **Samsung**: Normal behavior
- **iOS**: SKIP charging source (API không có)

### 4. Clear Reasons
Mỗi kết quả có lý do cụ thể:
- ✅ "Tín hiệu: -75 dBm" (thay vì chỉ "Pass")
- ❌ "Tín hiệu yếu: -125 dBm" (thay vì "Fail")
- ⊘ "MIUI: cần bật Vị trí để scan BT" (giải thích cụ thể)

## 🔍 Debugging

### View Loaded Profile

```dart
print('Profile: ${controller._profile?.name}');
print('Requires: ${controller._profile?.require}');
```

### Check Environment

```dart
print('Denied perms: ${controller._environment.deniedPerms}');
print('Location ON: ${controller._environment.locationServiceOn}');
```

### Test Evaluator

```dart
final result = controller._evaluator!.evaluate('wifi', testPayload);
print('Result: $result');
```

## 🚧 Next Steps (Optional)

1. **Remote Config** - Load từ Supabase
2. **ML Prediction** - Dự đoán lỗi dựa trên lịch sử
3. **PDF Export** - Xuất báo cáo có biểu đồ
4. **Custom Rules** - Admin tự định nghĩa rules qua UI
5. **Multi-language** - Hỗ trợ đa ngôn ngữ cho reasons

## 💡 Tips

- Rules & thresholds có thể update không cần build lại app (via remote config)
- Profile matching tự động normalize tên model (SM-G998B → s998b)
- Environment được update trước mỗi lần chạy → luôn fresh
- Fallback to simple pass/fail nếu evaluator fail

## 📞 Hỗ Trợ

Xem thêm:
- Ma trận đầy đủ: `RULE_BASED_EVALUATION_GUIDE.md`
- Chi tiết triển khai: `RULE_EVALUATION_IMPLEMENTATION.md`
- Code examples: `lib/diagnostics/examples/rule_evaluation_example.dart`

---

**Status**: ✅ Production Ready  
**Version**: 1.0.0  
**Tests Supported**: 24/24  
**Profiles**: 9+  
**Date**: 2025-11-10

