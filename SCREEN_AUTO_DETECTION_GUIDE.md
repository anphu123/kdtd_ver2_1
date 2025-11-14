# 🖥️ Hướng dẫn Tự động phát hiện lỗi màn hình

## 🎯 Mục tiêu
Tự động phát hiện lỗi màn hình (dead pixel, chảy mực, burn-in) mà không cần user báo thủ công.

---

## 🔬 Phương pháp phát hiện

### Option 1: Sử dụng Camera (Khuyến nghị)

#### Nguyên lý:
```
1. Hiển thị màu test trên màn hình
2. Dùng camera selfie chụp màn hình
3. Phân tích ảnh để tìm lỗi
4. So sánh với pattern chuẩn
```

#### Implementation:

```dart
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;

Future<List<ScreenDefect>> _autoAnalyzeScreen() async {
  final defects = <ScreenDefect>[];
  
  // 1. Chụp màn hình bằng camera selfie
  final cameras = await availableCameras();
  final frontCamera = cameras.firstWhere(
    (c) => c.lensDirection == CameraLensDirection.front,
  );
  
  final controller = CameraController(
    frontCamera,
    ResolutionPreset.high,
  );
  
  await controller.initialize();
  final image = await controller.takePicture();
  await controller.dispose();
  
  // 2. Load và phân tích ảnh
  final bytes = await File(image.path).readAsBytes();
  final decodedImage = img.decodeImage(bytes);
  
  if (decodedImage != null) {
    // 3. Phân tích từng pixel
    defects.addAll(_analyzePixels(decodedImage));
  }
  
  return defects;
}

List<ScreenDefect> _analyzePixels(img.Image image) {
  final defects = <ScreenDefect>[];
  final expectedColor = _getCurrentTestColor();
  
  // Scan từng pixel
  for (int y = 0; y < image.height; y++) {
    for (int x = 0; x < image.width; x++) {
      final pixel = image.getPixel(x, y);
      
      // So sánh với màu mong đợi
      if (!_isColorMatch(pixel, expectedColor)) {
        defects.add(ScreenDefect(
          type: 'Pixel lỗi',
          position: Point(x, y),
          expectedColor: expectedColor,
          actualColor: pixel,
        ));
      }
    }
  }
  
  return defects;
}

bool _isColorMatch(int pixel, Color expected, {double tolerance = 0.05}) {
  final r = img.getRed(pixel);
  final g = img.getGreen(pixel);
  final b = img.getBlue(pixel);
  
  final dr = (r - expected.red).abs() / 255.0;
  final dg = (g - expected.green).abs() / 255.0;
  final db = (b - expected.blue).abs() / 255.0;
  
  return (dr + dg + db) / 3 < tolerance;
}
```

---

### Option 2: Sử dụng Brightness Sensor

#### Nguyên lý:
```
1. Hiển thị màu sáng/tối
2. Đo độ sáng bằng light sensor
3. So sánh với giá trị mong đợi
4. Phát hiện vùng tối/sáng bất thường
```

#### Implementation:

```dart
import 'package:sensors_plus/sensors_plus.dart';

Future<bool> _detectBrightnessAnomaly() async {
  final readings = <double>[];
  
  // Đọc sensor trong 2 giây
  await for (final event in lightSensorEventStream()) {
    readings.add(event.illuminance);
    if (readings.length >= 20) break;
  }
  
  // Tính trung bình và độ lệch chuẩn
  final avg = readings.reduce((a, b) => a + b) / readings.length;
  final variance = readings
      .map((v) => (v - avg) * (v - avg))
      .reduce((a, b) => a + b) / readings.length;
  final stdDev = sqrt(variance);
  
  // Nếu độ lệch chuẩn cao → có vùng sáng/tối bất thường
  return stdDev > 50; // Threshold cần điều chỉnh
}
```

---

### Option 3: Machine Learning (Advanced)

#### Sử dụng TensorFlow Lite:

```yaml
dependencies:
  tflite_flutter: ^0.10.0
```

```dart
import 'package:tflite_flutter/tflite_flutter.dart';

class ScreenDefectDetector {
  Interpreter? _interpreter;
  
  Future<void> loadModel() async {
    _interpreter = await Interpreter.fromAsset('screen_defect_model.tflite');
  }
  
  Future<List<ScreenDefect>> detectDefects(img.Image screenImage) async {
    // 1. Preprocess image
    final input = _preprocessImage(screenImage);
    
    // 2. Run inference
    final output = List.filled(1 * 10, 0).reshape([1, 10]);
    _interpreter!.run(input, output);
    
    // 3. Parse results
    return _parseDetections(output);
  }
  
  List<List<List<List<double>>>> _preprocessImage(img.Image image) {
    // Resize to 224x224
    final resized = img.copyResize(image, width: 224, height: 224);
    
    // Normalize to [0, 1]
    final input = List.generate(
      1,
      (_) => List.generate(
        224,
        (y) => List.generate(
          224,
          (x) {
            final pixel = resized.getPixel(x, y);
            return [
              img.getRed(pixel) / 255.0,
              img.getGreen(pixel) / 255.0,
              img.getBlue(pixel) / 255.0,
            ];
          },
        ),
      ),
    );
    
    return input;
  }
}
```

---

## 🛠️ Implementation Steps

### Bước 1: Thêm dependencies

```yaml
dependencies:
  camera: ^0.11.0
  image: ^4.0.0
  sensors_plus: ^4.0.0
  # Optional: ML
  tflite_flutter: ^0.10.0
```

### Bước 2: Request permissions

```xml
<!-- Android: android/app/src/main/AndroidManifest.xml -->
<uses-permission android:name="android.permission.CAMERA"/>
```

```xml
<!-- iOS: ios/Runner/Info.plist -->
<key>NSCameraUsageDescription</key>
<string>Cần camera để phát hiện lỗi màn hình</string>
```

### Bước 3: Update ScreenDefectDetectionPage

```dart
void _autoAnalyzeScreen() async {
  try {
    // Chụp màn hình
    final image = await _captureScreen();
    
    // Phân tích
    final defects = await _analyzeImage(image);
    
    // Nếu có lỗi → tự động báo
    if (defects.isNotEmpty) {
      for (var defect in defects) {
        _reportDefect(defect);
      }
    }
  } catch (e) {
    print('Error auto-analyzing screen: $e');
  }
}
```

---

## 📊 Thuật toán phát hiện

### Dead Pixel Detection:

```dart
bool isDeadPixel(int pixel, Color testColor) {
  // Dead pixel = pixel đen khi test màu sáng
  if (testColor.computeLuminance() > 0.5) {
    final luminance = (
      img.getRed(pixel) * 0.299 +
      img.getGreen(pixel) * 0.587 +
      img.getBlue(pixel) * 0.114
    ) / 255.0;
    
    return luminance < 0.1; // Quá tối
  }
  return false;
}
```

### Bright Pixel Detection:

```dart
bool isBrightPixel(int pixel, Color testColor) {
  // Bright pixel = pixel sáng khi test màu tối
  if (testColor.computeLuminance() < 0.5) {
    final luminance = (
      img.getRed(pixel) * 0.299 +
      img.getGreen(pixel) * 0.587 +
      img.getBlue(pixel) * 0.114
    ) / 255.0;
    
    return luminance > 0.9; // Quá sáng
  }
  return false;
}
```

### Burn-in Detection:

```dart
bool hasBurnIn(img.Image grayImage) {
  // Tìm vùng có độ sáng khác biệt
  final histogram = List.filled(256, 0);
  
  for (int y = 0; y < grayImage.height; y++) {
    for (int x = 0; x < grayImage.width; x++) {
      final pixel = grayImage.getPixel(x, y);
      final gray = img.getRed(pixel);
      histogram[gray]++;
    }
  }
  
  // Nếu có nhiều peak → có burn-in
  final peaks = _findPeaks(histogram);
  return peaks.length > 2;
}
```

---

## 🎯 Accuracy Improvement

### 1. Calibration:
```dart
// Chụp ảnh chuẩn trước khi test
final referenceImage = await _captureReference();

// So sánh với ảnh test
final diff = _compareImages(referenceImage, testImage);
```

### 2. Multiple Captures:
```dart
// Chụp nhiều lần để giảm noise
final images = <img.Image>[];
for (int i = 0; i < 3; i++) {
  images.add(await _captureScreen());
  await Future.delayed(Duration(milliseconds: 100));
}

// Lấy trung bình
final avgImage = _averageImages(images);
```

### 3. Adaptive Threshold:
```dart
// Điều chỉnh threshold theo điều kiện ánh sáng
final ambientLight = await _getAmbientLight();
final threshold = _calculateThreshold(ambientLight);
```

---

## ⚠️ Limitations

### Hiện tại (Manual):
- ✅ Nhanh, đơn giản
- ✅ Không cần camera
- ❌ Phụ thuộc user
- ❌ Có thể bỏ sót

### Tương lai (Auto):
- ✅ Tự động 100%
- ✅ Chính xác cao
- ❌ Cần camera tốt
- ❌ Phức tạp hơn
- ❌ Tốn thời gian xử lý

---

## 🚀 Roadmap

### Phase 1 (Current):
- [x] Manual detection với user báo lỗi
- [x] 6 màu test cơ bản
- [x] UI/UX tốt

### Phase 2 (Next):
- [ ] Camera capture
- [ ] Basic image analysis
- [ ] Dead pixel detection
- [ ] Bright pixel detection

### Phase 3 (Future):
- [ ] ML model training
- [ ] Burn-in detection
- [ ] Color accuracy test
- [ ] Response time test

---

## 📝 Notes

**Để implement auto-detection thật:**

1. Uncomment code trong `_autoAnalyzeScreen()`
2. Implement camera capture
3. Implement image analysis
4. Test và tune threshold
5. Train ML model (optional)

**Hiện tại:**
- App vẫn hoạt động với manual detection
- User nhấn "Báo lỗi" nếu thấy vấn đề
- Đủ chính xác cho hầu hết trường hợp

**Tương lai:**
- Khi có camera tốt + ML model
- Có thể tự động 100%
- Tăng độ chính xác lên 95%+
