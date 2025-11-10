# 📱 HƯỚNG DẪN SỬ DỤNG ỨNG DỤNG KDTD - KIỂM ĐỊNH THIẾT BỊ

## 📖 Mục Lục
1. [Giới Thiệu](#giới-thiệu)
2. [Cài Đặt & Khởi Động](#cài-đặt--khởi-động)
3. [Luồng Sử Dụng Chi Tiết](#luồng-sử-dụng-chi-tiết)
4. [Các Tính Năng Chính](#các-tính-năng-chính)
5. [Hướng Dẫn Từng Bước](#hướng-dẫn-từng-bước)
6. [Đọc Kết Quả](#đọc-kết-quả)
7. [Xử Lý Sự Cố](#xử-lý-sự-cố)

---

## 🎯 Giới Thiệu

**KDTD (Kiểm Định Thiết Bị)** là ứng dụng kiểm tra phần cứng điện thoại tự động và thủ công, giúp đánh giá tình trạng thiết bị một cách toàn diện.

### Ứng Dụng Cho Ai?
- 🏪 **Cửa hàng thu cũ đổi mới** - Kiểm tra máy khách hàng mang đến
- 🔧 **Thợ sửa chữa** - Chẩn đoán lỗi nhanh
- 💰 **Người mua máy cũ** - Kiểm tra trước khi mua
- 📦 **Kho bãi** - Phân loại hàng thu về

### Lợi Ích
- ✅ Tiết kiệm thời gian (5-10 phút/máy thay vì 30 phút)
- ✅ Chính xác, khách quan (không phụ thuộc kinh nghiệm)
- ✅ Báo cáo chi tiết (in được, lưu được)
- ✅ Phân loại tự động (Loại 1-5)

---

## 📲 Cài Đặt & Khởi Động

### Bước 1: Cài Đặt Ứng Dụng
```
1. Tải file APK từ link được cung cấp
2. Bật "Cài đặt từ nguồn không xác định"
3. Cài đặt ứng dụng
4. Mở ứng dụng lần đầu
```

### Bước 2: Cấp Quyền
Khi mở lần đầu, app sẽ yêu cầu các quyền:

| Quyền | Mục Đích | Bắt Buộc? |
|-------|----------|-----------|
| 📷 **Camera** | Test camera trước/sau | ✅ Bắt buộc |
| 🎤 **Microphone** | Test micro | ✅ Bắt buộc |
| 📍 **Location** | Test GPS, WiFi SSID | ⚠️ Nên cấp |
| 📞 **Phone** | Đọc SIM, tín hiệu | ⚠️ Nên cấp |
| 🔵 **Bluetooth** | Test Bluetooth | ⚠️ Nên cấp |

**💡 Lưu ý:** Bấm "Cho phép" tất cả để test đầy đủ!

### Bước 3: Màn Hình Chào Mừng
```
┌─────────────────────────────┐
│   🎯 KDTD - Kiểm Định       │
│      Thiết Bị Di Động       │
│                             │
│   [Bắt Đầu Kiểm Tra]       │
└─────────────────────────────┘
```

---

## 🔄 Luồng Sử Dụng Chi Tiết

### Sơ Đồ Tổng Quan

```
START
  │
  ▼
┌─────────────────┐
│ Mở App          │
└────────┬────────┘
         │
         ▼
┌─────────────────┐      ❌ Từ chối
│ Cấp Quyền?      │─────────────▶ Test bị giới hạn
└────────┬────────┘
         │ ✅ Đồng ý
         ▼
┌─────────────────┐
│ Màn Hình Chính  │◀───┐
│ (Device Info)   │    │
└────────┬────────┘    │
         │             │
         ▼             │
┌─────────────────┐    │
│ Chọn Chức Năng  │    │
└────────┬────────┘    │
         │             │
    ┌────┴────┐        │
    ▼         ▼        │
┌─────┐   ┌──────┐    │
│Auto │   │Manual│    │
│Suite│   │Tests │    │
└──┬──┘   └───┬──┘    │
   │          │        │
   │          ▼        │
   │    ┌─────────┐   │
   │    │Touch    │   │
   │    │Camera   │   │
   │    │Speaker  │   │
   │    │...      │   │
   │    └────┬────┘   │
   │         │        │
   └────┬────┘        │
        │             │
        ▼             │
   ┌─────────┐       │
   │ Kết Quả │       │
   └────┬────┘       │
        │            │
   ┌────┴─────┐     │
   ▼          ▼      │
┌─────┐  ┌──────┐   │
│In   │  │Xem   │   │
│Báo  │  │Chi   │   │
│Cáo  │  │Tiết  │   │
└─────┘  └───┬──┘   │
             │      │
             └──────┘ (Test lại)
```

---

## 🏠 Các Tính Năng Chính

### 1. **Màn Hình Chính (Device Info)**

```
╔═══════════════════════════════════════╗
║  📱 Samsung Galaxy S21 Ultra         ║
║      Samsung Series                   ║
║                                       ║
║         ⭕ 0%                         ║
║       25 tests                        ║
║                                       ║
║  ✓ Pass: 0  ✗ Fail: 0  ○ Skip: 0   ║
╚═══════════════════════════════════════╝

╔═══════════════════════════════════════╗
║ 💾 RAM: 8 GB                         ║
║ 💽 Storage: 45 GB free / 128 GB      ║
║ 🔋 Battery: 85%                      ║
╚═══════════════════════════════════════╝
```

**Thông tin hiển thị:**
- Tên máy & hãng
- % hoàn thành
- Số test PASS/FAIL/SKIP
- RAM, ROM, Pin hiện tại

---

### 2. **Auto Suite (Tự Động)**

```
╔═══════════════════════════════════════╗
║ 🤖 Auto Suite                        ║
║                                       ║
║ Chạy tất cả kiểm tra tự động         ║
║ không cần thao tác tay               ║
║                                       ║
║  [▶ Start All Automated Tests]       ║
╚═══════════════════════════════════════╝
```

**17 Tests Tự Động:**
- ✅ OS/Model - Đọc thông tin hệ điều hành
- ✅ Battery - Kiểm tra pin
- ✅ Mobile Network - Tín hiệu mạng (dBm)
- ✅ WiFi - Kết nối WiFi & SSID
- ✅ RAM - Dung lượng RAM
- ✅ ROM - Bộ nhớ trong
- ✅ Bluetooth - Quét BT
- ✅ NFC - Kiểm tra NFC
- ✅ SIM - Số khe SIM
- ✅ Sensors - Cảm biến (gia tốc, con quay)
- ✅ GPS - Độ chính xác vị trí
- ✅ Charging - Nguồn sạc
- ✅ Headphone Jack - Cổng tai nghe
- ✅ Screen Lock - Khóa màn hình
- ✅ S-Pen - Bút S-Pen (Samsung)
- ✅ Biometric - Vân tay/FaceID
- ✅ Vibration - Rung

---

### 3. **Manual Tests (Thủ Công)**

```
╔═══════════════════════════════════════╗
║ 👆 Manual Tests                      ║
╠═══════════════════════════════════════╣
║ [📷] Camera Test        [○ WAIT] ▶  ║
║ [👆] Touch Test         [○ WAIT] ▶  ║
║ [🖥️] Screen Burn-in     [○ WAIT] ▶  ║
║ [🔊] Speaker Test       [○ WAIT] ▶  ║
║ [🎤] Microphone Test    [○ WAIT] ▶  ║
║ [👂] Earpiece Test      [○ WAIT] ▶  ║
║ [⌨️] Physical Keys      [○ WAIT] ▶  ║
║ [📳] Vibration          [○ WAIT] ▶  ║
╚═══════════════════════════════════════╝
```

**8 Tests Thủ Công:**
- 📷 **Camera** - Test camera trước/sau, chụp ảnh
- 👆 **Touch** - Test cảm ứng toàn màn hình
- 🖥️ **Screen** - Kiểm tra sọc ám màn hình
- 🔊 **Speaker** - Test loa ngoài
- 🎤 **Mic** - Test micro
- 👂 **Earpiece** - Test loa thoại
- ⌨️ **Keys** - Test nút nguồn, âm lượng
- 📳 **Vibration** - Test rung

---

## 📝 Hướng Dẫn Từng Bước

### 🤖 Cách Chạy Auto Suite

**Bước 1:** Nhấn nút **"Start All Automated Tests"**

```
[▶ Start All Automated Tests]
         ↓
[⏳ Running...] (nút disable)
```

**Bước 2:** App tự động chạy 17 tests (5-10 giây)

```
Test 1/17: OS/Model    [⟳ RUN]  → [✓ PASS] "Android 13, Samsung S21"
Test 2/17: Battery     [⟳ RUN]  → [✓ PASS] "Level: 85%"
Test 3/17: WiFi        [⟳ RUN]  → [✓ PASS] "Connected: MyWiFi"
Test 4/17: Mobile      [⟳ RUN]  → [○ SKIP] "No SIM"
...
Test 17/17: Vibration  [⟳ RUN]  → [✓ PASS] "Rung OK"
```

**Bước 3:** Xem kết quả

```
╔═══════════════════════════════════════╗
║  Progress: 68% (17/25 tests)         ║
║  ✓ Pass: 14  ✗ Fail: 1  ○ Skip: 2   ║
╚═══════════════════════════════════════╝
```

**💡 Lưu ý:**
- Auto tests chạy **không cần thao tác**
- Nếu có test FAIL → hiện nguyên nhân
- Nếu SKIP → thiếu quyền hoặc không hỗ trợ

---

### 👆 Cách Chạy Manual Tests

#### Test 1: Camera 📷

**Bước 1:** Nhấn vào **[📷 Camera Test]**

**Bước 2:** Màn hình test camera hiện ra

```
┌─────────────────────────────────┐
│ 📷 Camera & Flash Test          │
│ 1/4 cameras                     │
├─────────────────────────────────┤
│                                 │
│    [Camera Preview Live]        │
│                                 │
├─────────────────────────────────┤
│ ⚠️ Shake: Ổn định              │
│ 💡 Brightness: Normal           │
├─────────────────────────────────┤
│ [◀ Trước] [⏸ Dừng] [Sau ▶]    │
│                                 │
│      [⚪ Chụp Ảnh]             │
│                                 │
│ [❌ Có vấn đề] [✅ OK]          │
└─────────────────────────────────┘
```

**Bước 3:** Thao tác
1. Xem preview camera → Có rõ không?
2. Nhấn **"Sau ▶"** để chuyển camera (1→2→3→4)
3. Nhấn **⚪ Chụp Ảnh** để test chụp
4. Kiểm tra:
   - ✅ Hình rõ, không mờ
   - ✅ Không bị che
   - ✅ Không rung
   - ✅ Flash sáng (nếu có)

**Bước 4:** Kết luận
- Nếu **tất cả OK** → Nhấn **[✅ OK]**
- Nếu **có vấn đề** → Nhấn **[❌ Có vấn đề]**

**Kết quả:**
```
[📷] Camera Test  [✓ PASS] "Đã chụp 3 ảnh"
```

---

#### Test 2: Touch 👆

**Bước 1:** Nhấn **[👆 Touch Test]**

**Bước 2:** Màn hình lưới 8x8 (64 ô)

```
┌─────────────────────────────────┐
│ 👆 Touch Test                   │
│ Progress: 0/64 (0%)             │
├───────────��─────────────────────┤
│ ┌─┬─┬─┬─┬─┬─┬─┬─┐              │
│ │ │ │ │ │ │ │ │ │              │
│ ├─┼─┼─┼─┼─┼─┼─┼─┤              │
│ │ │ │ │ │ │ │ │ │              │
│ ├─┼─┼─┼─┼─┼─┼─┼─┤              │
│ │ │ │ │ │ │ │ │ │              │
│ └─┴─┴─┴─┴─┴─┴─┴─┘              │
├─────────────────────────────────┤
│ Chạm vào tất cả các ô           │
│ Ô xanh = đã chạm                │
│ Ô trắng = chưa chạm             │
└─────────────────────────────────┘
```

**Bước 3:** Vuốt ngón tay khắp màn hình

```
Chưa chạm → [⬜] Trắng
Đã chạm   → [🟦] Xanh
```

**Bước 4:** Kết quả tự động

```
Progress: 64/64 (100%)
✓ Không có vùng chết
→ PASS
```

**Nếu có vùng chết:**
```
Progress: 60/64 (93.75%)
⚠️ 4 ô không hoạt động (góc trên phải)
→ FAIL
```

---

#### Test 3: Screen Burn-in 🖥️

**Bước 1:** Nhấn **[🖥️ Screen Burn-in]**

**Bước 2:** Màn hình hiện màu đơn sắc

```
┌─────────────────────────────────┐
│ Đen (Black) 1/9                 │
│ 🔍 Tìm pixel sáng bất thường    │
├─────────────────────────────────┤
│                                 │
│     [Toàn màn đen]              │
│                                 │
├─────────────────────────────────┤
│ [◀ Trước] [▶ Sau] [⏸ Dừng]    │
│                                 │
│ [⚠️ Có vấn đề] [✅ OK]          │
└─────────────────────────────────┘
```

**Bước 3:** Quan sát từng màu

| Màu | Tìm Gì? |
|-----|---------|
| 🖤 Đen | Pixel sáng, điểm sáng |
| ⚪ Trắng | Vết ám, burn-in, sọc |
| 🔴 Đỏ | Kênh màu đỏ lỗi |
| 🟢 Xanh lá | Kênh xanh lỗi |
| 🔵 Xanh dương | Kênh xanh dương lỗi |
| ⚫ Xám | Độ đồng đều |
| 🟡 Vàng | Color bleeding |
| 🔵 Cyan | Tint issues |
| 🟣 Magenta | Purple tint |

**Bước 4:** Nhấn **"Sau ▶"** để chuyển màu (1→9)

**Bước 5:** Kết luận
- Thấy **sọc/ám/vết** → [⚠️ Có vấn đề]
- **Không thấy** → [✅ OK]

---

#### Test 4: Speaker 🔊

**Bước 1:** Nhấn **[🔊 Speaker Test]**

**Bước 2:** App phát âm thanh "beep-beep"

```
┌─────────────────────────────────┐
│ 🔊 Speaker Test                 │
├─────────────────────────────────┤
│   ♪♫ Beep-Beep ♫♪               │
│                                 │
│   Bạn có nghe thấy?             │
│   Âm thanh to, rõ?              │
├─────────────────────────────────┤
│ [❌ Không nghe] [✅ Nghe rõ]    │
└─────────────────────────────────┘
```

**Bước 3:** Lắng nghe
- ✅ **Nghe rõ, to** → Nhấn [✅ Nghe rõ]
- ❌ **Không nghe/nhỏ/méo** → Nhấn [❌ Không nghe]

---

#### Test 5: Microphone 🎤

**Bước 1:** Nhấn **[🎤 Microphone Test]**

**Bước 2:** Nói vào micro

```
┌─────────────────────────────────┐
│ 🎤 Microphone Test              │
├─────────────────────────────────┤
│  🔴 Recording...                │
│                                 │
│  ████████░░░░░░░░░░ -15 dBFS   │
│  Amplitude                      │
│                                 │
│  Hãy nói: "Xin chào 1 2 3"     │
├─────────────────────────────────┤
│  [⏹ Dừng & Phát Lại]           │
└─────────────────────────────────┘
```

**Bước 3:** Thao tác
1. Nói vào micro: "Xin chào 1 2 3"
2. Nhìn thanh Amplitude → có nhảy không?
3. Nhấn **[⏹ Dừng & Phát Lại]**
4. Nghe lại → giọng có rõ?

**Bước 4:** Kết luận
```
[✅ Nghe rõ giọng] hoặc [❌ Không nghe/méo]
```

---

#### Test 6: Earpiece 👂

**Bước 1:** Nhấn **[👂 Earpiece Test]**

**Bước 2:** Đưa máy lên tai (như nghe điện thoại)

```
┌─────────────────────────────────┐
│ 👂 Earpiece Test                │
├─────────────────────────────────┤
│  📞 Đặt máy lên tai              │
│     (như nghe điện thoại)       │
│                                 │
│  ♪ Tone phát qua loa thoại ♪   │
├─────────────────────────────────┤
│ [❌ Không nghe] [✅ Nghe rõ]    │
└─────────────────────────────────┘
```

**💡 Lưu ý:** Loa thoại khác loa ngoài!

---

#### Test 7: Physical Keys ⌨️

**Bước 1:** Nhấn **[⌨️ Physical Keys]**

**Bước 2:** Dialog hiện ra

```
┌─────────────────────────────────┐
│ ⌨️ Test Phím Vật Lý             │
├─────────────────────────────────┤
│  Hãy nhấn:                      │
│  • Phím Âm Lượng (+/-)          │
│  • Phím Nguồn (Power)           │
│                                 │
│  Tất cả phím hoạt động bình     │
│  thường?                        │
├─────────────────────────────────┤
│ [❌ Không] [✅ Có]              │
└─────────────────────────────────┘
```

**Bước 3:** Nhấn thử từng nút → Chọn kết quả

---

## 📊 Đọc Kết Quả

### 1. Status Icons (Biểu Tượng Trạng Thái)

| Icon | Trạng thái | Màu | Ý nghĩa |
|------|-----------|-----|---------|
| ○ | WAIT | Xám | Chưa chạy |
| ⟳ | RUN | Xanh dương | Đang chạy |
| ✓ | PASS | Xanh lá | Đạt |
| ✗ | FAIL | Đỏ | Lỗi |
| ○ | SKIP | Cam | Bỏ qua |

### 2. Màn Hình Kết Quả

```
╔═══════════════════════════════════════╗
║  Progress: 100% (25/25 tests)        ║
║                                       ║
║  ✓ Pass: 20  ✗ Fail: 3  ○ Skip: 2   ║
║                                       ║
║  Điểm: 80/100                        ║
║  Xếp Loại: LOẠI 2                    ║
╚═══════════════════════════════════════╝

Chi tiết:
┌─────────────────────────────────────┐
│ ✓ OS/Model         "Samsung S21"    │
│ ✓ Battery          "85%"            │
│ ✓ WiFi             "MyWiFi"         │
│ ✗ Mobile           "Yếu: -95 dBm"   │
│ ✓ RAM              "8 GB"           │
│ ✗ Camera           "Lens 2 bị mờ"   │
│ ○ NFC              "Không hỗ trợ"   │
│ ...                                  │
└─────────────────────────────────────┘

[🖨️ In Báo Cáo] [🔄 Test Lại]
```

### 3. Bảng Phân Loại

| Điểm | Loại | Ý Nghĩa | Giá Dự Kiến |
|------|------|---------|-------------|
| 90-100 | **Loại 1** | Xuất sắc, như mới | 90-100% giá mới |
| 75-89 | **Loại 2** | Tốt, ít lỗi | 70-89% |
| 60-74 | **Loại 3** | Khá, dùng được | 50-69% |
| 40-59 | **Loại 4** | Trung bình, nhiều lỗi | 30-49% |
| 0-39 | **Loại 5** | Kém, cần sửa | 10-29% |

### 4. Giải Thích Lỗi Thường Gặp

| Lỗi | Nguyên Nhân | Cách Khắc Phục |
|-----|-------------|----------------|
| ✗ WiFi FAIL | Thiếu quyền Location | Bật Location, cấp quyền |
| ○ Mobile SKIP | Không có SIM | Lắp SIM để test |
| ✗ Camera FAIL | Lens bị mờ/bẩn | Lau lens, kiểm tra |
| ✗ Touch FAIL | Vùng chết | Màn hình cần sửa |
| ○ NFC SKIP | Máy không hỗ trợ | Bình thường (model không có) |
| ✗ Speaker FAIL | Loa hỏng | Cần thay loa |

---

## 🎓 Tips & Tricks

### ✅ Để Đạt Điểm Cao

1. **Cấp đủ quyền** - Tránh SKIP do thiếu quyền
2. **Bật Location** - Cần cho WiFi SSID (MIUI/ColorOS)
3. **Lắp SIM** - Test Mobile network & SIM slots
4. **Bật NFC** (nếu có) - Test NFC
5. **Sạch lens camera** - Tránh FAIL do bẩn
6. **Màn hình sạch** - Touch test chính xác hơn
7. **Không rung** - Camera test tốt hơn
8. **Môi trường yên tĩnh** - Mic test chính xác

### ⚠️ Lưu Ý Với Từng Hãng

**Samsung:**
- S-Pen test chỉ có trên Note/S21 Ultra/S22 Ultra
- DeX mode không ảnh hưởng

**Xiaomi (MIUI):**
- **BẮT BUỘC** bật Location để đọc WiFi SSID
- Permission phức tạp hơn → cấp thủ công

**OPPO (ColorOS):**
- Tương tự MIUI
- Cần vào **App Permissions** bật thủ công

**iPhone:**
- Charging source không đọc được (iOS hạn chế)
- Một số test SKIP là bình thường

---

## 🔧 Xử Lý Sự Cố

### Lỗi 1: App Không Mở
```
Triệu chứng: Tap icon không phản hồi
Nguyên nhân: App crash hoặc chưa cài đúng
Giải pháp:
  1. Gỡ app
  2. Khởi động lại máy
  3. Cài lại app
  4. Bật "Install from unknown sources"
```

### Lỗi 2: Test Bị Treo
```
Triệu chứng: Test chạy mãi không xong
Nguyên nhân: Timeout hoặc sensor không phản hồi
Giải pháp:
  1. Nhấn nút Back
  2. Nhấn "Test Lại"
  3. Nếu vẫn treo → Force stop app
```

### Lỗi 3: Camera Đen
```
Triệu chứng: Màn hình đen khi test camera
Nguyên nhân: Quyền camera bị chặn
Giải pháp:
  1. Vào Settings → Apps → KDTD
  2. Permissions → Camera → Allow
  3. Test lại
```

### Lỗi 4: WiFi SSID Không Đọc
```
Triệu chứng: WiFi FAIL "Cannot read SSID"
Nguyên nhân: 
  - Android 10+: Cần Location ON
  - MIUI/ColorOS: Cần Location permission
Giải pháp:
  1. Bật Location (GPS)
  2. Cấp quyền Location cho app
  3. Test lại
```

### Lỗi 5: Tất Cả Test SKIP
```
Triệu chứng: Mọi test đều SKIP
Nguyên nhân: Chưa cấp quyền
Giải pháp:
  1. Gỡ app
  2. Cài lại
  3. Cấp TẤT CẢ quyền khi app hỏi
```

---

## 📞 Hỗ Trợ

### Liên Hệ
- 📧 Email: support@kdtd.vn
- 📱 Hotline: 1900-xxxx
- 💬 Telegram: @kdtd_support

### FAQ (Câu Hỏi Thường Gặp)

**Q: App có cần Internet không?**  
A: Không! Tất cả test chạy offline.

**Q: App có lưu dữ liệu không?**  
A: Chỉ lưu local, không upload lên server.

**Q: Một lần test mất bao lâu?**  
A: 5-10 phút (tùy số test manual).

**Q: Có thể bỏ qua test nào không?**  
A: Có! Manual tests có thể skip. Auto tests chạy hết.

**Q: Điểm có chính xác không?**  
A: Chính xác 90-95%. Tùy thuộc hardware detection của Android.

**Q: Máy loại 5 có bán được không?**  
A: Được, nhưng giá thấp (10-30% giá mới).

---

## 📋 Checklist Kiểm Tra Nhanh

### Trước Khi Test
```
☐ Sạc pin > 20%
☐ Lắp SIM (nếu có)
☐ Bật WiFi, Bluetooth, Location
☐ Cấp đủ quyền cho app
☐ Lau sạch lens camera
☐ Lau sạch màn hình
```

### Trong Khi Test
```
☐ Giữ máy ổn định (camera test)
☐ Vuốt đầy đủ màn hình (touch test)
☐ Quan sát kỹ từng màu (screen test)
☐ Nghe kỹ từng loa (speaker/ear test)
☐ Nói rõ ràng (mic test)
```

### Sau Khi Test
```
☐ Kiểm tra số PASS/FAIL
☐ Đọc lý do FAIL (nếu có)
☐ In/lưu báo cáo
☐ Định giá dựa trên loại
```

---

**Chúc bạn sử dụng app hiệu quả! 🎉**

*Phiên bản: 2.1.0 | Cập nhật: 10/11/2025*

