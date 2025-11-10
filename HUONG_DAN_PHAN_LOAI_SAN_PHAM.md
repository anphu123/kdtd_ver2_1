# 📊 HƯỚNG DẪN PHÂN LOẠI SẢN PHẨM - KDTD

## 📖 Mục Lục
1. [Tổng Quan Hệ Thống Phân Loại](#tổng-quan-hệ-thống-phân-loại)
2. [Công Thức Tính Điểm](#công-thức-tính-điểm)
3. [Tiêu Chí Chi Tiết Từng Loại](#tiêu-chí-chi-tiết-từng-loại)
4. [Ma Trận Đánh Giá](#ma-trận-đánh-giá)
5. [Ví Dụ Thực Tế](#ví-dụ-thực-tế)
6. [Bảng Giá Tham Khảo](#bảng-giá-tham-khảo)
7. [Trường Hợp Đặc Biệt](#trường-hợp-đặc-biệt)

---

## 🎯 Tổng Quan Hệ Thống Phân Loại

### Mục Đích
Hệ thống phân loại KDTD giúp:
- ✅ **Khách quan hóa** việc định giá máy cũ
- ✅ **Chuẩn hóa** quy trình thu mua
- ✅ **Minh bạch** cho khách hàng
- ✅ **Tối ưu** lợi nhuận kinh doanh

### Quy Trình Tổng Quát

```
Test Thiết Bị (25 tests)
        │
        ▼
Tính Điểm (0-100)
        │
        ▼
Phân Loại (Loại 1-5)
        │
        ▼
Định Giá (% giá mới)
        │
        ▼
Quyết Định Thu Mua
```

---

## 🔢 Công Thức Tính Điểm

### 1. Công Thức Cơ Bản

```
Điểm = (PASS_COUNT × 100) / TOTAL_TESTS
```

**Trong đó:**
- `PASS_COUNT`: Số test PASS
- `TOTAL_TESTS`: Tổng số test (25 tests)

**Ví dụ:**
```
20 PASS / 25 tests = 80 điểm
```

---

### 2. Công Thức Có Trọng Số (Advanced)

```
Điểm = Σ(Test_i × Weight_i) / Σ(Weight_i)
```

#### Bảng Trọng Số

| Test Category | Weight | Lý Do |
|---------------|--------|-------|
| **Camera** | 3.0 | Quan trọng nhất, dễ hỏng |
| **Touch/Screen** | 3.0 | Ảnh hưởng trải nghiệm |
| **Battery** | 2.5 | Chi phí thay cao |
| **Speaker/Mic** | 2.0 | Thường xuyên hỏng |
| **Mobile Signal** | 2.0 | Liên quan phần cứng |
| **WiFi** | 1.5 | Quan trọng vừa |
| **RAM/ROM** | 1.5 | Thông số cơ bản |
| **Sensors** | 1.0 | Ít khi hỏng |
| **NFC** | 0.5 | Không quan trọng |

#### Ví Dụ Tính Có Trọng Số

```
Camera PASS    → 3.0 × 1 = 3.0
Touch PASS     → 3.0 × 1 = 3.0
Battery PASS   → 2.5 × 1 = 2.5
Speaker FAIL   → 2.0 × 0 = 0.0
Mobile SKIP    → 2.0 × 0.5 = 1.0 (SKIP = 50%)
WiFi PASS      → 1.5 × 1 = 1.5
...

Tổng = 35.5 / 40 = 88.75 điểm
```

---

### 3. Điều Chỉnh Theo Tier (Cấp Máy)

```
Final_Score = Base_Score × Tier_Multiplier
```

#### Tier Multipliers

| Tier | Máy | Multiplier | Lý Do |
|------|-----|------------|-------|
| 1 | Flagship cao cấp | 1.0 | Yêu cầu hoàn hảo |
| 2 | Flagship 1-2 năm | 0.95 | Chấp nhận lỗi nhỏ |
| 3 | Mid-range mới | 0.90 | Yêu cầu thấp hơn |
| 4 | Mid-range cũ | 0.85 | Dễ dãi hơn |
| 5 | Entry-level | 0.80 | Chỉ cần hoạt động |

**Ví dụ:**
```
Samsung S21 Ultra (Tier 1):
Base = 85 → Final = 85 × 1.0 = 85 điểm

Xiaomi Redmi Note 10 (Tier 3):
Base = 85 → Final = 85 × 0.9 = 76.5 điểm
```

---

## 📋 Tiêu Chí Chi Tiết Từng Loại

### 🏆 LOẠI 1: XUẤT SẮC (90-100 điểm)

#### Điều Kiện
- ✅ **Điểm tối thiểu:** 90/100
- ✅ **PASS:** ≥ 23/25 tests
- ✅ **FAIL:** ≤ 1 test (lỗi nhẹ)
- ✅ **SKIP:** ≤ 1 test

#### Yêu Cầu Chi Tiết

| Category | Yêu Cầu |
|----------|---------|
| 📷 **Camera** | Tất cả lens hoạt động, không mờ, không rung |
| 👆 **Touch** | 100% màn hình, không vùng chết |
| 🖥️ **Screen** | Không sọc, không ám, không pixel chết |
| 🔋 **Battery** | ≥ 80% health, không sụt pin |
| 📡 **Signal** | Mobile ≥ -75 dBm, WiFi ổn định |
| 🔊 **Audio** | Speaker/Mic/Earpiece rõ ràng |
| ⚙️ **Sensors** | Accel, Gyro, GPS chính xác |
| 💾 **Storage** | ROM ≥ 90% free space |

#### Ngoại Hình
- ✅ Không trầy xước
- ✅ Không móp méo
- ✅ Màn hình không vết
- ✅ Khung viền nguyên zin

#### Định Giá
```
Giá thu = 90-100% giá mới
Ví dụ: S21 Ultra mới 15 triệu
       → Thu 13.5 - 15 triệu
```

#### Ghi Chú
- 🎯 **Target:** Máy like new, bán lại giá cao
- 💰 **Lợi nhuận:** Thấp (5-10%) nhưng dễ bán
- ⏱️ **Thời gian bán:** 1-3 ngày

---

### 🥈 LOẠI 2: TỐT (75-89 điểm)

#### Điều Kiện
- ✅ **Điểm:** 75-89
- ✅ **PASS:** 19-22/25 tests
- ✅ **FAIL:** 2-3 tests (lỗi nhẹ-vừa)
- ✅ **SKIP:** ≤ 3 tests

#### Cho Phép Lỗi

| Lỗi Nhẹ (OK) | Lỗi Vừa (Cân nhắc) | Lỗi Nặng (KHÔNG) |
|--------------|-------------------|------------------|
| ○ NFC không có | ✗ 1 lens camera mờ | ✗✗ Touch vùng chết lớn |
| ○ S-Pen skip | ✗ Speaker hơi nhỏ | ✗✗ Screen burn-in nặng |
| ○ SIM 1 slot | ✗ Mobile yếu (-85 dBm) | ✗✗ Battery < 70% |
| ○ Vân tay chậm | ✗ Mic hơi méo | ✗✗ Camera chính hỏng |

#### Ví Dụ Lỗi Chấp Nhận Được
```
✓ Camera chính OK, ultra-wide hơi mờ
✓ Touch 98% (2% góc không quan trọng)
✓ Battery 78% (vẫn dùng được)
✓ Speaker hơi nhỏ nhưng rõ
```

#### Định Giá
```
Giá thu = 70-89% giá mới
Ví dụ: S21 Ultra mới 15 triệu
       → Thu 10.5 - 13.4 triệu
       
Điều chỉnh:
- 75-79 điểm → 70-75%
- 80-84 điểm → 76-82%
- 85-89 điểm → 83-89%
```

#### Ghi Chú
- 🎯 **Target:** Máy đẹp, sử dụng tốt
- 💰 **Lợi nhuận:** Vừa (10-20%)
- ⏱️ **Thời gian bán:** 3-7 ngày

---

### 🥉 LOẠI 3: KHÁ (60-74 điểm)

#### Điều Kiện
- ⚠️ **Điểm:** 60-74
- ⚠️ **PASS:** 15-18/25 tests
- ⚠️ **FAIL:** 4-6 tests
- ⚠️ **SKIP:** ≤ 4 tests

#### Lỗi Điển Hình

| Hardware | Lỗi Cho Phép |
|----------|--------------|
| 📷 Camera | 1-2 lens mờ/không hoạt động |
| 👆 Touch | 5-10% vùng chết (góc) |
| 🖥️ Screen | Sọc nhẹ hoặc ám nhẹ (không ảnh hưởng) |
| 🔋 Battery | 65-75% health |
| 📡 Signal | Mobile -85 đến -95 dBm |
| 🔊 Speaker | Nhỏ hoặc méo nhẹ |

#### Tình Trạng Ngoại Hình
- ⚠️ Trầy xước nhẹ-vừa
- ⚠️ Móp góc nhẹ
- ⚠️ Màn hình vết nhỏ (không ảnh hưởng)

#### Định Giá
```
Giá thu = 50-69% giá mới
Ví dụ: S21 Ultra mới 15 triệu
       → Thu 7.5 - 10.3 triệu
       
Điều chỉnh:
- 60-64 điểm → 50-55%
- 65-69 điểm → 56-62%
- 70-74 điểm → 63-69%
```

#### Chiến Lược
- 🔧 **Sửa nhẹ** (thay lens, pin) → lên Loại 2
- 💰 **Lợi nhuận:** Cao (20-30%) nếu sửa
- ⏱️ **Thời gian bán:** 1-2 tuần

---

### ⚠️ LOẠI 4: TRUNG BÌNH (40-59 điểm)

#### Điều Kiện
- ❌ **Điểm:** 40-59
- ❌ **PASS:** 10-14/25 tests
- ❌ **FAIL:** 7-10 tests
- ❌ **SKIP:** > 5 tests

#### Lỗi Nhiều

| Hardware | Tình Trạng |
|----------|------------|
| 📷 Camera | 2-3 lens lỗi, hoặc camera chính mờ |
| 👆 Touch | 10-20% vùng chết |
| 🖥️ Screen | Sọc nhiều, ám rõ, burn-in |
| 🔋 Battery | 50-64% health, sụt nhanh |
| 📡 Signal | Mobile < -95 dBm, WiFi không ổn |
| 🔊 Audio | Loa/mic hỏng 1 bên |

#### Tình Trạng
- ❌ Trầy xước nhiều
- ❌ Móp méo rõ
- ❌ Màn hình nứt nhỏ (không ảnh hưởng touch)

#### Định Giá
```
Giá thu = 30-49% giá mới
Ví dụ: S21 Ultra mới 15 triệu
       → Thu 4.5 - 7.3 triệu
```

#### Chiến Lược
- 🔧 **Cần sửa nhiều** (màn hình, camera, pin)
- 💰 **Lợi nhuận:** Cao (30-50%) sau sửa
- ⏱️ **Thời gian:** Sửa 1 tuần + Bán 2-3 tuần
- 🎯 **Target:** Phân khúc giá rẻ

---

### 🔴 LOẠI 5: KÉM (0-39 điểm)

#### Điều Kiện
- 🚫 **Điểm:** 0-39
- 🚫 **PASS:** < 10/25 tests
- 🚫 **FAIL:** > 10 tests
- 🚫 Lỗi nghiêm trọng

#### Lỗi Nghiêm Trọng

| Lỗi | Mức Độ |
|-----|--------|
| 📷 Camera chính hỏng hoàn toàn | 🔴 Nghiêm trọng |
| 👆 Touch không hoạt động 50%+ | 🔴 Nghiêm trọng |
| 🖥️ Screen burn-in nặng/nứt | 🔴 Nghiêm trọng |
| 🔋 Battery < 50%, sụt cực nhanh | 🔴 Nghiêm trọng |
| 📡 Không nhận SIM/WiFi | 🔴 Nghiêm trọng |
| 🔊 Không có âm thanh | 🔴 Nghiêm trọng |

#### Định Giá
```
Giá thu = 10-29% giá mới
Ví dụ: S21 Ultra mới 15 triệu
       → Thu 1.5 - 4.3 triệu
```

#### Chiến Lược
- 🔧 **Tháo linh kiện** bán lẻ
- 💰 **Lợi nhuận:** Thấp hoặc hòa vốn
- ⏱️ **Không bán nguyên máy**
- 🎯 **Target:** Nguồn linh kiện thay thế

#### Quyết Định
```
Thu máy nếu:
├─ Giá thu < 20% giá mới
├─ Có kênh tiêu thụ linh kiện
└─ Model phổ biến (dễ bán linh kiện)

KHÔNG thu nếu:
├─ Máy cũ > 3 năm
├─ Model ít người dùng
└─ Chi phí sửa > giá bán
```

---

## 📊 Ma Trận Đánh Giá

### Bảng Tổng Hợp

| Loại | Điểm | PASS | FAIL | SKIP | % Giá | Lợi Nhuận | Thời Gian Bán |
|------|------|------|------|------|-------|-----------|---------------|
| 🏆 Loại 1 | 90-100 | ≥23 | ≤1 | ≤1 | 90-100% | 5-10% | 1-3 ngày |
| 🥈 Loại 2 | 75-89 | 19-22 | 2-3 | ≤3 | 70-89% | 10-20% | 3-7 ngày |
| 🥉 Loại 3 | 60-74 | 15-18 | 4-6 | ≤4 | 50-69% | 20-30% | 1-2 tuần |
| ⚠️ Loại 4 | 40-59 | 10-14 | 7-10 | >5 | 30-49% | 30-50% | 3-4 tuần |
| 🔴 Loại 5 | 0-39 | <10 | >10 | - | 10-29% | 0-10% | Tháo linh kiện |

### Ma Trận Quyết Định

```
                    Lỗi Phần Cứng
                    │
        ┌───────────┼───────────┐
        │           │           │
    Không lỗi   Lỗi nhẹ    Lỗi nặng
        │           │           │
        ▼           ▼           ▼
    ┌───────┐   ┌───────┐   ┌───────┐
    │Loại 1 │   │Loại 2 │   │Loại 3 │
    │90-100 │   │75-89  │   │60-74  │
    └───┬───┘   └───┬───┘   └───┬───┘
        │           │           │
        └───────────┼───────────┘
                    │
            Check Ngoại Hình
                    │
        ┌───────────┼───────────┐
        │           │           │
      Đẹp       Trầy xước    Móp/nứt
        │           │           │
        ▼           ▼           ▼
    Giữ nguyên  -5 điểm    -10 điểm
     loại         ↓           ↓
              Xuống 1 cấp  Xuống 2 cấp
```

---

## 💡 Ví Dụ Thực Tế

### Case 1: Samsung S21 Ultra - Loại 1

**Test Results:**
```
✓ OS/Model      PASS "Android 13, S21 Ultra"
✓ Battery       PASS "92%, health tốt"
✓ Mobile        PASS "-65 dBm, mạnh"
✓ WiFi          PASS "Connected, tốc độ cao"
✓ RAM           PASS "12 GB"
✓ ROM           PASS "256 GB, 200 GB free"
✓ Bluetooth     PASS "Scan OK"
○ NFC           SKIP "Chưa bật"
✓ SIM           PASS "Dual SIM OK"
✓ Sensors       PASS "Accel, Gyro OK"
✓ GPS           PASS "Accuracy 5m"
✓ Charging      PASS "USB-C, Fast charge"
✓ Lock          PASS "Secure"
✓ S-Pen         PASS "Detected"
✓ Bio           PASS "Ultrasonic fingerprint"
✓ Vibration     PASS "Haptic rõ"
✓ Camera        PASS "4 lens đều rõ, chụp OK"
✓ Touch         PASS "100%"
✓ Screen        PASS "Không sọc, không ám"
✓ Speaker       PASS "To, rõ"
✓ Mic           PASS "Thu rõ"
✓ Earpiece      PASS "Nghe rõ"
✓ Keys          PASS "Vol+, Vol-, Power OK"
✓ Vibration2    PASS "Confirm rung"
```

**Tính Điểm:**
```
PASS: 23/24 tests (NFC skip vì chưa bật)
Điểm = 23/24 × 100 = 95.8 ≈ 96 điểm
```

**Phân Loại:**
```
96 điểm → LOẠI 1
```

**Ngoại Hình:**
```
- Không trầy
- Không móp
- Màn hình nguyên
→ Giữ nguyên Loại 1
```

**Định Giá:**
```
Giá mới: 15,000,000 VNĐ
96 điểm → 96% giá mới
Giá thu = 15,000,000 × 96% = 14,400,000 VNĐ

Điều chỉnh:
- Machine like-new → +200k
- Full box, phụ kiện → +300k
→ Giá cuối: 14,900,000 VNĐ
```

---

### Case 2: iPhone 13 Pro - Loại 2

**Test Results:**
```
✓ OS/Model      PASS "iOS 17, iPhone 13 Pro"
✓ Battery       PASS "81%, OK"
✓ Mobile        PASS "-72 dBm"
✓ WiFi          PASS "Connected"
✓ RAM           PASS "6 GB"
✓ ROM           PASS "128 GB, 50 GB free"
✓ Bluetooth     PASS "OK"
✓ NFC           PASS "Available"
✓ SIM           PASS "Single SIM OK"
✓ Sensors       PASS "All OK"
✓ GPS           PASS "Accuracy 8m"
○ Charging      SKIP "iOS không đọc source"
✓ Lock          PASS "FaceID"
✗ Bio           FAIL "Touch ID không có (bình thường)"
✓ Vibration     PASS "Taptic engine OK"
✓ Camera        PASS "3 lens rõ, nhưng tele hơi mờ"
✓ Touch         PASS "100%"
✓ Screen        PASS "Không sọc"
✗ Speaker       FAIL "Loa dưới hơi nhỏ"
✓ Mic           PASS "OK"
✓ Earpiece      PASS "OK"
✓ Keys          PASS "Vol, Power OK"
✓ Vibration2    PASS "OK"
```

**Tính Điểm:**
```
PASS: 19/25 tests
FAIL: 2 (Bio skip do iOS, Speaker nhỏ)
SKIP: 1 (Charging)

Điểm = 19/25 × 100 = 76 điểm

Điều chỉnh:
- Camera tele mờ → -2 điểm
- Speaker nhỏ → -2 điểm
→ Final: 72 điểm
```

**Phân Loại:**
```
72 điểm → GẦN Loại 3
Nhưng vì:
- Flagship cao cấp
- Lỗi nhẹ, có thể sửa
→ GIỮ LOẠI 2 (thấp)
```

**Định Giá:**
```
Giá mới: 23,000,000 VNĐ
72 điểm → 72% giá mới (ranh giới)

Giá thu = 23,000,000 × 70% = 16,100,000 VNĐ

Điều chỉnh:
- Loa nhỏ (có thể sửa) → -500k
- Tele mờ (lau lens?) → -300k
→ Giá cuối: 15,300,000 VNĐ
```

---

### Case 3: Xiaomi Redmi Note 10 - Loại 3

**Test Results:**
```
✓ OS/Model      PASS "MIUI 14, Redmi Note 10"
✗ Battery       FAIL "68%, health kém"
✗ Mobile        FAIL "-88 dBm, yếu"
✓ WiFi          PASS "OK"
✓ RAM           PASS "6 GB"
✓ ROM           PASS "128 GB"
✓ Bluetooth     PASS "OK"
○ NFC           SKIP "Model không có"
✓ SIM           PASS "Dual OK"
✓ Sensors       PASS "OK"
✓ GPS           PASS "OK"
✓ Charging      PASS "USB-C"
✓ Lock          PASS "Pattern"
✓ Bio           PASS "Side fingerprint"
✓ Vibration     PASS "OK"
✗ Camera        FAIL "Ultra-wide không hoạt động"
✓ Touch         PASS "97% (3% góc dưới trái)"
✗ Screen        FAIL "Sọc nhẹ 2 vệt"
✓ Speaker       PASS "OK"
✓ Mic           PASS "OK"
✓ Earpiece      PASS "OK"
✓ Keys          PASS "OK"
✓ Vibration2    PASS "OK"
```

**Tính Điểm:**
```
PASS: 17/25 tests
FAIL: 4 (Battery, Mobile, Camera, Screen)
SKIP: 1 (NFC)

Điểm = 17/25 × 100 = 68 điểm
```

**Phân Loại:**
```
68 điểm → LOẠI 3
```

**Ngoại Hình:**
```
- Trầy xước vừa
- Góc bị móp nhẹ
→ -3 điểm → 65 điểm (vẫn Loại 3)
```

**Định Giá:**
```
Giá mới: 4,500,000 VNĐ
65 điểm → 60% giá mới

Giá thu = 4,500,000 × 60% = 2,700,000 VNĐ

Điều chỉnh:
- Battery yếu (cần thay) → -300k
- Camera ultra-wide hỏng → -200k
- Screen sọc → -200k
→ Giá cuối: 2,000,000 VNĐ

Chiến lược:
- Thay pin: 500k
- Lau lens camera: 0k (tự làm)
→ Cost: 500k
→ Sau sửa: Loại 3 cao (70 điểm)
→ Bán: 3,200,000 VNĐ
→ Lợi nhuận: 700k (35%)
```

---

### Case 4: OPPO A57 - Loại 4

**Test Results:**
```
✓ OS/Model      PASS "ColorOS, A57"
✗ Battery       FAIL "52%, sụt nhanh"
✗ Mobile        FAIL "Không nhận SIM"
✗ WiFi          FAIL "Ngắt kết nối liên tục"
✓ RAM           PASS "4 GB"
✓ ROM           PASS "64 GB"
○ Bluetooth     SKIP "Không bật được"
○ NFC           SKIP "Không có"
✗ SIM           FAIL "Không nhận cả 2 slot"
✓ Sensors       PASS "Gyro OK, Accel hơi lệch"
✗ GPS           FAIL "Không fix"
✓ Charging      PASS "Micro USB"
✓ Lock          PASS "PIN"
✗ Bio           FAIL "Vân tay không hoạt động"
✓ Vibration     PASS "OK"
✗ Camera        FAIL "Main mờ, selfie OK"
✗ Touch         FAIL "15% vùng chết góc phải"
✗ Screen        FAIL "Burn-in logo, sọc nhiều"
✓ Speaker       PASS "Nhỏ nhưng OK"
✓ Mic           PASS "OK"
✗ Earpiece      FAIL "Không nghe"
✓ Keys          PASS "OK"
✓ Vibration2    PASS "OK"
```

**Tính Điểm:**
```
PASS: 11/25 tests
FAIL: 10
SKIP: 2

Điểm = 11/25 × 100 = 44 điểm
```

**Phân Loại:**
```
44 điểm → LOẠI 4
```

**Định Giá:**
```
Giá mới: 3,500,000 VNĐ
44 điểm → 40% giá mới

Giá thu = 3,500,000 × 40% = 1,400,000 VNĐ

Điều chỉnh:
- Lỗi nhiều nghiêm trọng → -500k
→ Giá cuối: 900,000 VNĐ

Quyết định:
❌ KHÔNG NÊN THU
Lý do:
- SIM không nhận → Lỗi mainboard
- Touch vùng chết → Cần thay màn
- Screen burn-in → Không sửa được
→ Chi phí sửa > Giá bán
```

---

### Case 5: Galaxy S20 - Loại 5

**Test Results:**
```
✓ OS/Model      PASS "S20, Android 13"
✗ Battery       FAIL "38%, phồng nhẹ"
✗ Mobile        FAIL "Không sóng"
✗ WiFi          FAIL "Không bật được"
✓ RAM           PASS "8 GB"
✓ ROM           PASS "128 GB"
✗ Bluetooth     FAIL "Không hoạt động"
✓ NFC           PASS "OK"
✗ SIM           FAIL "Không nhận"
✗ Sensors       FAIL "Tất cả không hoạt động"
✗ GPS           FAIL "Không có"
✓ Charging      PASS "Sạc được nhưng chậm"
✓ Lock          PASS "Pattern"
✗ Bio           FAIL "Vân tay hỏng"
✗ Vibration     FAIL "Không rung"
✗ Camera        FAIL "Tất cả lens đều đen"
✗ Touch         FAIL "50% không hoạt động"
✗ Screen        FAIL "Nứt toàn màn hình"
✗ Speaker       FAIL "Không có tiếng"
✗ Mic           FAIL "Không thu"
✗ Earpiece      FAIL "Không có"
✓ Keys          PASS "OK"
✗ Vibration2    FAIL "Không rung"
```

**Tính Điểm:**
```
PASS: 6/25 tests
FAIL: 16
SKIP: 0

Điểm = 6/25 × 100 = 24 điểm
```

**Phân Loại:**
```
24 điểm → LOẠI 5
```

**Định Giá:**
```
Giá mới: 12,000,000 VNĐ
24 điểm → 20% giá mới

Giá thu = 12,000,000 × 20% = 2,400,000 VNĐ

Điều chỉnh:
- Lỗi mainboard (nhiều lỗi nghiêm trọng) → -1,500k
- Màn hình nứ��� → -500k
- Battery phồng → -200k
→ Giá cuối: 200,000 VNĐ

Quyết định:
✅ THU ĐỂ THÁO LINH KIỆN
Giá trị linh kiện:
- Camera module: 500k
- Mainboard (sửa được): 800k
- Ram: 200k
- Pin (mới): 300k
→ Tổng giá trị: ~1,800k
→ Thu 200k → Lãi 1,600k nếu bán được linh kiện
```

---

## 💰 Bảng Giá Tham Khảo

### Flagship (Tier 1)

| Model | Giá Mới | Loại 1 | Loại 2 | Loại 3 | Loại 4 | Loại 5 |
|-------|---------|--------|--------|--------|--------|--------|
| **Samsung S23 Ultra** | 25M | 22.5M | 17.5M | 13M | 7.5M | 2.5M |
| **iPhone 14 Pro Max** | 30M | 27M | 21M | 15M | 9M | 3M |
| **Samsung S21 Ultra** | 15M | 13.5M | 10.5M | 7.5M | 4.5M | 1.5M |
| **iPhone 13 Pro** | 23M | 20.7M | 16.1M | 11.5M | 6.9M | 2.3M |

### Mid-Range (Tier 3)

| Model | Giá Mới | Loại 1 | Loại 2 | Loại 3 | Loại 4 | Loại 5 |
|-------|---------|--------|--------|--------|--------|--------|
| **Xiaomi Redmi Note 12** | 5M | 4.5M | 3.5M | 2.5M | 1.5M | 500k |
| **OPPO Reno 8** | 8M | 7.2M | 5.6M | 4M | 2.4M | 800k |
| **Realme 10 Pro** | 6M | 5.4M | 4.2M | 3M | 1.8M | 600k |

### Entry-Level (Tier 5)

| Model | Giá Mới | Loại 1 | Loại 2 | Loại 3 | Loại 4 | Loại 5 |
|-------|---------|--------|--------|--------|--------|--------|
| **Xiaomi Redmi A1** | 2M | 1.8M | 1.4M | 1M | 600k | 200k |
| **OPPO A57** | 3.5M | 3.1M | 2.4M | 1.7M | 1M | 350k |

---

## 🎯 Trường Hợp Đặc Biệt

### 1. Máy Có Lỗi Mainboard

```
Triệu chứng:
- WiFi/BT không bật được
- SIM không nhận
- Nhiều sensor FAIL

Quyết định:
❌ KHÔNG THU (hoặc giá rất thấp)
Lý do: Chi phí sửa mainboard > giá máy

Ngoại lệ:
✅ Thu nếu:
  - Flagship cao cấp
  - Mainboard rẻ (< 2M)
  - Có kênh sửa uy tín
```

### 2. Máy Screen Burn-in Nặng

```
Đánh giá:
- Burn-in nhẹ → -5 điểm
- Burn-in vừa → -10 điểm
- Burn-in nặng → -15 điểm

Chiến lược:
- Flagship → Thay màn (nếu giá OK)
- Mid-range → Giảm giá bán
- Entry → KHÔNG thu
```

### 3. Máy Battery Phồng

```
🚨 CẢNH BÁO AN TOÀN

Quyết định:
❌ TUYỆT ĐỐI KHÔNG THU nếu:
  - Pin phồng > 3mm
  - Có dấu hiệu cháy nổ
  - Máy bị biến dạng

⚠️ Thu với giá cực thấp nếu:
  - Pin phồng nhẹ (< 2mm)
  - Có thể thay pin ngay
  - Giá thu < 20% giá mới
```

### 4. Máy Có iCloud/FRP Lock

```
iOS (iCloud):
❌ TUYỆT ĐỐI KHÔNG THU
Lý do: Không thể mở khóa

Android (FRP):
⚠️ Cân nhắc thu nếu:
  - Biết cách bypass (không khuyến khích)
  - Giá thu < 10% giá mới
  - Chỉ lấy linh kiện
```

### 5. Máy Ngâm Nước

```
Đánh giá:
1. Kiểm tra indicators:
   - Còn trắng → OK
   - Đã đỏ → Ngâm nước

2. Test kỹ:
   - Tất cả 25 tests
   - Đặc biệt: Camera (mờ), Speaker (méo)

3. Quyết định:
   - Indicators trắng + All PASS → Loại bình thường
   - Indicators đỏ + PASS → -10 điểm (rủi ro cao)
   - Indicators đỏ + FAIL → Giá linh kiện
```

---

## 📋 Checklist Phân Loại

### Bước 1: Chạy Test (5-10 phút)
```
☐ Chạy Auto Suite (8s)
☐ Test Camera (30s)
☐ Test Touch (15s)
☐ Test Screen (30s)
☐ Test Speaker/Mic/Ear (20s)
☐ Các test còn lại (2 phút)
```

### Bước 2: Tính Điểm (1 phút)
```
☐ Đếm PASS/FAIL/SKIP
☐ Tính điểm cơ bản (PASS/TOTAL × 100)
☐ Điều chỉnh theo trọng số (nếu cần)
☐ Xác định Loại (1-5)
```

### Bước 3: Kiểm Tra Ngoại Hình (2 phút)
```
☐ Mặt trước: Trầy, nứt?
☐ Mặt sau: Móp, vỡ?
☐ Cạnh viền: Phai màu, bong tróc?
☐ Camera: Kính bị xước?
☐ Điều chỉnh điểm nếu cần
```

### Bước 4: Định Giá (1 phút)
```
☐ Tra giá mới (market price)
☐ Tính % theo loại
☐ Điều chỉnh theo lỗi cụ thể
☐ So sánh với giá thị trường
☐ Quyết định giá thu cuối
```

### Bước 5: Quyết Định (30s)
```
☐ Thu → Nhập kho
☐ Không thu → Từ chối lịch sự
☐ Cân nhắc → Hỏi manager
```

---

## 🎓 Tips Chuyên Nghiệp

### 1. Đàm Phán Với Khách
```
✅ DÙO:
- Giải thích rõ lỗi
- Show kết quả test
- Minh bạch bảng giá

❌ KHÔNG:
- Chê máy quá mức
- Áp giá không công bằng
- Hứa hẹn không giữ lời
```

### 2. Tối Ưu Lợi Nhuận
```
Loại 1-2:
→ Bán nhanh, lợi nhuận thấp (5-15%)

Loại 3:
→ Sửa nhẹ, lợi nhuận vừa (20-30%)

Loại 4:
→ Sửa nặng hoặc bán phụ kiện (30-50%)

Loại 5:
→ Tháo linh kiện (vary)
```

### 3. Quản Lý Rủi Ro
```
Flagship:
- Giá cao → Kiểm tra kỹ
- Có thể yêu cầu test lại
- Check imei, nguồn gốc

Mid-range:
- Giá vừa → Test chuẩn
- Chấp nhận rủi ro nhỏ

Entry:
- Giá thấp → Test nhanh
- Không đầu tư sửa chữa
```

---

## 📞 Hỗ Trợ

**Hotline:** 1900-xxxx  
**Email:** pricing@kdtd.vn  
**Telegram:** @kdtd_pricing

---

**Phiên bản:** 2.1.0  
**Cập nhật:** 10/11/2025  
**Tác giả:** KDTD Team

