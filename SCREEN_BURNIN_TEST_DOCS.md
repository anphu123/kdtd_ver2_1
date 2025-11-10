# 🖥️ Screen Burn-In & Dead Pixel Test - Documentation

## Tổng Quan

**Screen Burn-In Test** là tính năng kiểm tra màn hình để phát hiện:
- ✅ **Sọc dọc/ngang** (vertical/horizontal lines)
- ✅ **Vết ám** (burn-in, ghost image)
- ✅ **Pixel chết** (dead pixels, stuck pixels)
- ✅ **Màu không đều** (uneven color distribution)

## 📱 Cách Hoạt Động

### 1. Hiển Thị Màu Đơn Sắc

Test hiển thị **9 màu đơn sắc** lần lượt:

| Màu | Kiểm Tra |
|-----|----------|
| 🖤 **Đen (Black)** | Pixel sáng bất thường, điểm sáng |
| ⚪ **Trắng (White)** | Pixel tối, vết ám, burn-in |
| 🔴 **Đỏ (Red)** | Kênh màu đỏ, dead red pixels |
| 🟢 **Xanh lá (Green)** | Kênh màu xanh lá, dead green pixels |
| 🔵 **Xanh dương (Blue)** | Kênh màu xanh dương, dead blue pixels |
| ⚫ **Xám (Gray)** | Độ đồng đều, gradient issues |
| 🟡 **Vàng (Yellow)** | Màu ấm, color bleeding |
| 🔵 **Cyan** | Màu lạnh, tint issues |
| 🟣 **Magenta** | Màu hồng, purple tint |

### 2. Chế Độ Kiểm Tra

**Manual Mode (Mặc định):**
- Người dùng vuốt/nhấn nút để chuyển màu
- Quan sát kỹ từng màu

**Auto Mode:**
- Tự động chuyển màu mỗi 2 giây
- Nhấn "Tạm dừng" để dừng lại

### 3. Đánh Giá Kết Quả

Người dùng xác nhận:
- ✅ **"Không có vấn đề"** → PASS
- ❌ **"Có vấn đề"** → FAIL (có sọc ám/vết cháy)

## 🎨 UI/UX Features

### Controls (Top)
- **Tiêu đề màu hiện tại** + mô tả
- **Progress**: "3/9" (màu thứ mấy)
- **Buttons**:
  - ◀ Trước
  - ▶ Sau  
  - ▶️ Tự động / ⏸ Tạm dừng

### Visual Feedback
- Màu text tự động đổi (trắng/đen) tùy màu nền
- Overlay mờ để buttons vẫn nhìn thấy
- Immersive mode (full screen, ẩn status bar)

### Result Buttons (Bottom)
- ⚠️ **Có vấn đề** (Red) → FAIL
- ✅ **Không có vấn đề** (Green) → PASS
- 🔙 **Quay lại** → Cancel (null)

## 📊 Integration

### Controller
```dart
DiagStep(
  code: 'screen',
  title: 'Sọc ám màn hình',
  kind: DiagKind.manual,
  interact: _openScreenBurnInTest,
),
```

### Evaluator
```dart
EvalResult _evalScreen(Map<String, dynamic> p) {
  final hasIssue = p['hasIssue'] == true;
  if (hasIssue) return EvalResult.fail;
  return EvalResult.pass;
}
```

### Rules (JSON)
```json
{
  "screen": {
    "pass": "hasIssue == false",
    "fail": "hasIssue == true"
  }
}
```

## 🔍 Cách Phát Hiện Vấn Đề

### Sọc Dọc/Ngang
- **Hiện tượng**: Đường thẳng chạy dọc/ngang màn hình
- **Kiểm tra tốt nhất**: Màu **trắng** hoặc **xám**
- **Nguyên nhân**: Lỗi driver màn hình, kết nối flex cable

### Vết Ám (Burn-In)
- **Hiện tượng**: Hình ảnh cũ còn lưu lại mờ mờ
- **Kiểm tra tốt nhất**: Màu **trắng** hoặc **đen**
- **Nguyên nhân**: OLED aging (thường ở thanh điều hướng, keyboard)

### Pixel Chết
- **Hiện tượng**: Điểm nhỏ không đổi màu
- **Stuck pixel**: Luôn sáng (thường xanh/đỏ)
- **Dead pixel**: Luôn tối
- **Kiểm tra**: Tất cả các màu (đỏ/xanh/đen/trắng)

### Màu Không Đều
- **Hiện tượng**: Vùng sáng/tối không đồng đều
- **Kiểm tra tốt nhất**: Màu **xám**
- **Nguyên nhân**: Backlight bleeding, panel uniformity

## 📈 Statistics

### Pass/Fail Criteria

| Kết quả | Điều kiện | Note |
|---------|-----------|------|
| ✅ PASS | Không phát hiện vấn đề | Màn hình OK |
| ❌ FAIL | Có sọc/ám/pixel chết | Cần thay màn hình |
| ⊘ SKIP | N/A | Test này không skip |

## 🎯 Best Practices

### Cho Người Kiểm Tra
1. **Môi trường**: Phòng tối, ánh sáng vừa phải
2. **Thời gian**: Dành 5-10 giây/màu để quan sát kỹ
3. **Góc nhìn**: Nhìn thẳng + nghiêng để phát hiện tint
4. **Focus**: Chú ý vào:
   - Các góc màn hình
   - Khu vực thanh trạng thái (thường burn-in)
   - Khu vực phím điều hướng

### Cho Developer
1. **Immersive Mode**: Luôn bật để test toàn màn hình
2. **Auto Mode**: Hữu ích cho demo/quick check
3. **Color Order**: Bắt đầu từ đen → trắng → màu sắc
4. **Timeout**: Không có (người dùng tự quyết định)

## 🔧 Customization

### Thêm Màu Mới
```dart
final List<ScreenTestColor> _testColors = [
  // Existing colors...
  ScreenTestColor('Orange', Colors.orange, '🔍 Test warm tones'),
];
```

### Thay Đổi Auto Timer
```dart
_autoTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
  _nextColor();
});
```

### Thêm Pattern Test
Có thể thêm pattern (checkerboard, gradient) để test thêm:
```dart
// In future: add pattern mode
enum TestMode { solidColor, checkerboard, gradient }
```

## 📊 Example Results

### Pass Example
```
User saw all 9 colors
No lines, no burn-in, no dead pixels
Confirmed: "Không có vấn đề"
→ Result: PASS
→ Reason: "Màn hình không có sọc ám"
```

### Fail Example
```
User saw vertical line on white screen
Confirmed: "Có vấn đề"
→ Result: FAIL
→ Reason: "Phát hiện sọc ám/vết cháy màn hình"
```

## 🚀 Future Enhancements

### V2.0 (Optional)
- [ ] Pattern test (checkerboard, gradient)
- [ ] Dead pixel counter (tap to mark)
- [ ] Screenshot comparison (before/after)
- [ ] Heat map của vùng có vấn đề

### V3.0 (Advanced)
- [ ] AI detection (auto detect lines/burn-in)
- [ ] Camera photo + image processing
- [ ] Compare with reference image
- [ ] Generate detailed report with images

## 🎓 Education

### What Users See
```
┌─────────────────────────────────┐
│ Trắng (White)                   │
│ 🔍 Kiểm tra pixel tối, vết ám   │
│ 3/9                             │
├─────────────────────────────────┤
│ [◀ Trước] [⏸ Tạm dừng] [Sau ▶] │
└─────────────────────────────────┘

          [Toàn màn trắng]
          
     Quan sát kỹ màn hình
     Tìm sọc, vết ám, pixel...

┌─────────────────────────────────┐
│ ⚠️ Nếu có sọc/ám → "Có vấn đề"  │
│ ✅ Nếu OK → "Không có vấn đề"    │
├─────────────────────────────────┤
│ [⚠️ Có vấn đề] [✅ Không có VĐ]  │
│      [Quay lại]                 │
└─────────────────────────────────┘
```

## 📞 Support

### Common Issues

**Q: Auto mode quá nhanh?**  
A: Adjust timer từ 2s → 3s trong `_startAutoMode()`

**Q: Màu không đủ?**  
A: Thêm màu vào `_testColors` list

**Q: Cần test pattern?**  
A: Future enhancement, chưa implement

**Q: Làm sao detect tự động?**  
A: Cần AI/ML, V3.0 feature

---

**Created**: 2025-11-10  
**Version**: 1.0.0  
**Status**: ✅ Production Ready  
**Test Count**: 25/25 (added screen test)

