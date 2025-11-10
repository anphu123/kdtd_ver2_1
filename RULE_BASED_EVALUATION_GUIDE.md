# Hệ Thống Đánh Giá Tự Động (Rule-Based Evaluation)

## Tổng Quan

Hệ thống đánh giá tự động cho phép chấm điểm kết quả kiểm tra thiết bị dựa trên:
- **Rules JSON**: Quy tắc PASS/FAIL/SKIP cho từng test
- **Thresholds**: Ngưỡng đánh giá (dBm, accuracy, ratio...)
- **Device Profiles**: Yêu cầu theo từng model máy
- **Environment**: Trạng thái quyền, dịch vụ, ROM quirks

## Cấu Trúc File

```
assets/
├── diag_rules.json          # Quy tắc đánh giá từng test
└── diag_thresholds.json     # Ngưỡng & yêu cầu theo profile

lib/diagnostics/model/
├── device_profile.dart      # Model cho device profile
├── diag_environment.dart    # Trạng thái hệ thống
├── diag_thresholds.dart     # Model cho ngưỡng
├── profile_manager.dart     # Quản lý profiles
└── rule_evaluator.dart      # Engine đánh giá
```

## Cách Hoạt Động

### 1. Khởi Tạo (onInit)

```dart
// Controller tự động:
1. Load device info (brand, model, platform)
2. Tìm profile phù hợp từ ProfileManager
3. Cập nhật Environment (permissions, services)
4. Tạo RuleEvaluator
```

### 2. Chạy Test (start)

```dart
for each test:
  1. Chạy hàm test (run/interact)
  2. Thu thập payload vào info[code]
  3. Gọi evaluator.evaluate(code, payload)
  4. Nhận kết quả: PASS/FAIL/SKIP
  5. Cập nhật status & note
```

### 3. Đánh Giá (RuleEvaluator)

Mỗi test có logic riêng, ví dụ:

**WiFi Test:**
```dart
- SKIP: Nếu không kết nối WiFi
- SKIP: Nếu Location Service tắt (cần cho SSID)
- FAIL: Nếu kết nối nhưng không đọc được SSID
- PASS: Đọc được SSID
```

**Mobile Network:**
```dart
- SKIP: Nếu không kết nối mobile
- SKIP: Nếu thiếu quyền phone_state
- FAIL: Nếu dBm ngoài [-120, -40]
- PASS: Nếu dBm hợp lệ
```

**GPS:**
```dart
- SKIP: Location Service tắt
- SKIP: Thiếu quyền location
- FAIL: Accuracy > 50m
- PASS: Accuracy ≤ 50m
```

## Thêm Profile Mới

**Bước 1**: Thêm vào `assets/diag_thresholds.json`

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

**Bước 2**: ProfileManager tự động detect

```dart
// Tự động match theo tên model
// Normalize: "SM-S918B" → "s918b"
// Match partial: "s23" hoặc "s918"
```

## Tùy Chỉnh Ngưỡng

Sửa `thresholds` trong `diag_thresholds.json`:

```json
{
  "thresholds": {
    "mobile": {
      "dbm_min": -120,  // Tín hiệu yếu nhất chấp nhận
      "dbm_max": -40     // Tín hiệu mạnh nhất
    },
    "gps": {
      "accuracy_m_pass": 50,  // Độ chính xác tối đa (m)
      "timeout_sec": 8
    },
    "touch": {
      "pass_ratio_min": 0.98  // 98% vùng cảm ứng OK
    }
  }
}
```

## Brand Quirks (Đặc Thù Hãng)

Xử lý các ROM có hành vi khác biệt:

```json
{
  "brand_quirks": {
    "xiaomi": {
      "wifi_requires_location": true,    // MIUI cần Location để đọc SSID
      "bt_requires_location": true       // MIUI cần Location cho BT scan
    },
    "oppo": {
      "bt_requires_nearby_devices": true // ColorOS cần quyền riêng
    }
  }
}
```

## Thêm Test Mới

**Bước 1**: Thêm DiagStep vào controller

```dart
DiagStep(
  code: 'proximity',
  title: 'Cảm biến tiệm cận',
  kind: DiagKind.auto,
  run: _snapProximity,
),
```

**Bước 2**: Implement snapshot function

```dart
Future<bool> _snapProximity() async {
  info['proximity'] = await _getProximityInfo();
  return true;
}

Future<Map<String, dynamic>> _getProximityInfo() async {
  // Logic thu thập dữ liệu
  return {'available': true, 'distance': 5.0};
}
```

**Bước 3**: Thêm rule vào `diag_rules.json`

```json
{
  "proximity": {
    "pass": "available == true && distance != null",
    "fail": "available == false",
    "skip": "!required_by_profile('proximity')"
  }
}
```

**Bước 4**: Thêm evaluator vào `rule_evaluator.dart`

```dart
EvalResult evaluate(String code, Map<String, dynamic> payload) {
  switch (code) {
    // ...existing cases...
    case 'proximity':
      return _evalProximity(payload);
    // ...
  }
}

EvalResult _evalProximity(Map<String, dynamic> p) {
  final available = p['available'] == true;
  if (!available) return EvalResult.fail;
  
  final distance = p['distance'];
  if (distance == null) return EvalResult.fail;
  
  return EvalResult.pass;
}
```

**Bước 5**: Thêm reason text

```dart
String getReason(String code, Map<String, dynamic> payload, EvalResult result) {
  switch (code) {
    case 'proximity':
      if (result == EvalResult.fail) {
        return 'Cảm biến tiệm cận không hoạt động';
      }
      final distance = payload['distance'];
      return 'Khoảng cách: ${distance}cm';
    // ...
  }
}
```

## Ma Trận Tiêu Chí

| Code | PASS | FAIL | SKIP |
|------|------|------|------|
| `wifi` | Connected & có SSID | Connected nhưng không đọc SSID | Không kết nối / Location OFF |
| `mobile` | dBm [-120,-40] | dBm ngoài ngưỡng | Không kết nối / thiếu quyền |
| `gps` | Accuracy ≤ 50m | Accuracy > 50m | Location OFF / thiếu quyền |
| `nfc` | Available = true | Yêu cầu nhưng không có | Không yêu cầu & không có |
| `spen` | Detected = true (nếu yêu cầu) | Yêu cầu nhưng không có | Không yêu cầu |
| `bt` | Enabled & scan OK | Enabled nhưng scan fail | BT OFF / thiếu quyền |
| `touch` | Ratio ≥ 98% & no dead zones | Ratio < 98% hoặc có dead zones | - |

## Remote Config (Tương Lai)

Có thể load thresholds từ Supabase/Firebase:

```dart
// Trong ProfileManager
Future<void> _loadProfilesFromRemote() async {
  final response = await supabase
      .from('device_profiles')
      .select()
      .execute();
  
  // Parse & update _profiles
}
```

## Debug & Logging

Xem kết quả đánh giá:

```dart
// Trong controller
print('✅ Rule evaluator initialized for: ${_profile?.name}');
print('Device: $brand $modelName');
print('Environment: ${_environment.deniedPerms}');
```

Console output khi chạy test:
```
✅ Rule evaluator initialized for: samsung_s21_ultra
📱 Test: wifi
   Payload: {connected: true, ssid: "MyWiFi"}
   Result: PASS
   Reason: Kết nối: MyWiFi
```

## Troubleshooting

**Profile không match?**
- Check tên model trong `_normalizeModelName()`
- Thêm brand-specific default: `"samsung_default"`

**Test luôn SKIP?**
- Check permissions trong `_updateEnvironment()`
- Check brand quirks (MIUI/ColorOS)

**Threshold không apply?**
- Verify JSON syntax trong `diag_thresholds.json`
- Check `DiagThresholds.fromJson()` parsing

## Best Practices

1. **Luôn có fallback**: Nếu evaluator fail, vẫn dùng run result
2. **SKIP không phải lỗi**: Thiếu quyền/dịch vụ → SKIP, không FAIL
3. **Profile-aware**: Chỉ FAIL khi profile yêu cầu mà không đạt
4. **Clear reasons**: Note phải giải thích rõ tại sao PASS/FAIL/SKIP
5. **Async safety**: Update environment trước mỗi lần chạy

---

**Version**: 1.0  
**Last Updated**: 2025-11-10  
**Author**: KDTD Team

