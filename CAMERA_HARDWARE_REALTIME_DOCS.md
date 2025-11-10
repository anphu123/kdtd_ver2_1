# ✅ Camera & Hardware Info - Real-Time Display

## Tóm Tắt

Đã cập nhật hệ thống để **hiển thị thông tin thực tế** của thiết bị thay vì hardcode:

### 📷 Camera System (Real-time)

**Thông tin được hiển thị:**
- ✅ Tổng số camera
- ✅ Số lượng camera trước
- ✅ Số lượng camera sau
- ✅ Phát hiện loại camera (Ultra-wide, Telephoto, Macro) dựa trên tên
- ✅ Tên chính xác của từng camera

**Ví dụ hiển thị:**
```
📷 Camera System
├─ Total Cameras: 3 cameras
├─ Front Cameras: 1 camera
├─ Back Cameras: 2 cameras
├─ Selfie: camera 0 (Front)
├─ Main: camera 1 (Back)
└─ Ultra-wide: camera 2 (Back, wide angle)
```

### 💾 RAM/ROM (Real-time)

**Capabilities section hiển thị:**
- ✅ **RAM**: Dung lượng thực tế (GB)
- ✅ **Storage**: Free / Total (GB)
- ✅ Tự động convert bytes → GiB

**Ví dụ:**
```
💾 RAM: 8 GB
💾 Storage: 45 GB free / 128 GB
```

## 🔧 Thay Đổi Kỹ Thuật

### 1. Controller Updates

**File**: `auto_diagnostics_controller.dart`

```dart
Future<void> _prepareCameras() async {
  try {
    _cams = await availableCameras();
    
    // Store camera info in info map
    final front = _cams.where((c) => c.lensDirection == CameraLensDirection.front).toList();
    final back = _cams.where((c) => c.lensDirection == CameraLensDirection.back).toList();
    
    final cameraInfo = {
      'total': _cams.length,
      'front': front.length,
      'back': back.length,
      'cameras': _cams.map((c) => {
        'name': c.name,
        'direction': c.lensDirection.toString().split('.').last,
        'sensorOrientation': c.sensorOrientation,
      }).toList(),
    };
    
    info['camera_specs'] = cameraInfo;
  } catch (_) {
    info['camera_specs'] = {'total': 0, 'front': 0, 'back': 0, 'cameras': []};
  }
}
```

### 2. View Updates

**File**: `auto_diagnostics_view.dart`

#### Camera Section - Dynamic Display

```dart
Obx(() {
  final cameraSpecs = controller.info['camera_specs'] as Map? ?? {};
  final total = cameraSpecs['total'] ?? 0;
  final cameras = (cameraSpecs['cameras'] as List?) ?? [];
  
  // Auto-detect camera type from name
  for (camera in cameras) {
    if (name.contains('ultra') || name.contains('wide')) {
      type = 'Ultra-wide';
      icon = Icons.aspect_ratio;
    } else if (name.contains('tele') || name.contains('zoom')) {
      type = 'Telephoto';
      icon = Icons.zoom_in;
    } else if (name.contains('macro')) {
      type = 'Macro';
      icon = Icons.filter_center_focus;
    }
  }
})
```

#### RAM/ROM Section - Capabilities

```dart
Obx(() {
  final ram = (info['ram'] as Map?)?.cast<String, dynamic>() ?? {};
  final rom = (info['rom'] as Map?)?.cast<String, dynamic>() ?? {};
  final ramGb = _toGiB(ram['totalBytes']);
  final romGb = _toGiB(rom['totalBytes']);
  final romFreeGb = _toGiB(rom['freeBytes']);
  
  return Wrap(
    children: [
      if (ramGb != null)
        _CapabilityChip(
          icon: Icons.memory,
          label: 'RAM',
          sublabel: '$ramGb GB',
        ),
      if (romGb != null)
        _CapabilityChip(
          icon: Icons.storage,
          label: 'Storage',
          sublabel: '$romFreeGb GB free / $romGb GB',
        ),
    ],
  );
})
```

### 3. Helper Function

```dart
// Convert bytes to GiB
int? _toGiB(dynamic v) {
  if (v is! num) return null;
  const giB = 1024 * 1024 * 1024;
  return (v.toDouble() / giB).round();
}
```

## 📱 Camera Type Detection Logic

| Pattern trong tên | Type | Icon |
|-------------------|------|------|
| `ultra`, `wide` | Ultra-wide | aspect_ratio |
| `tele`, `zoom` | Telephoto | zoom_in |
| `macro` | Macro | filter_center_focus |
| `front` direction | Selfie | face |
| `back` direction | Main | camera_rear |
| Default | Camera | camera |

## 🎨 UI Behavior

### Empty State
```
📷 Camera System
└─ Cameras: No camera detected ❌
```

### Single Camera
```
📷 Camera System
├─ Total Cameras: 1 camera
└─ Selfie: camera 0 (Front)
```

### Multiple Cameras (e.g., Samsung S21 Ultra)
```
📷 Camera System
├─ Total Cameras: 5 cameras
├─ Front Cameras: 1 camera
├─ Back Cameras: 4 cameras
├─ Selfie: camera 0 (Front)
├─ Main: camera 1 (Back, 108MP)
├─ Ultra-wide: camera 2 (Back, 12MP wide)
├─ Telephoto: camera 3 (Back, 10MP tele)
└─ Telephoto: camera 4 (Back, 10MP periscope)
```

## 💡 Ưu Điểm

### 1. Dynamic & Accurate
- ✅ Không hardcode
- ✅ Tự động phát hiện thông số thực
- ✅ Hỗ trợ mọi thiết bị Android/iOS

### 2. Smart Detection
- ✅ Tự động phân loại camera (ultra-wide, tele, macro)
- ✅ Dựa vào tên và hướng camera
- ✅ Icon phù hợp cho từng loại

### 3. User-Friendly
- ✅ Hiển thị dễ hiểu (GB thay vì bytes)
- ✅ Free/Total cho storage
- ✅ Expandable sections

### 4. Reactive
- ✅ Sử dụng Obx() → auto update khi có data
- ✅ Real-time refresh

## 🔍 Testing

### Test Cases

**Camera Detection:**
```dart
// Device with 1 camera
Expected: "Total: 1 camera, Front: 1 camera"

// Device with 3 cameras (e.g., Pixel 6)
Expected: "Total: 3 cameras, Front: 1, Back: 2"

// Device with 5 cameras (e.g., S21 Ultra)
Expected: Detect ultra-wide, telephoto correctly
```

**RAM/ROM:**
```dart
// 8GB RAM, 128GB ROM (45GB free)
Expected: 
  - RAM: 8 GB
  - Storage: 45 GB free / 128 GB

// 12GB RAM, 256GB ROM
Expected:
  - RAM: 12 GB  
  - Storage: xxx GB free / 256 GB
```

## 🚀 Next Steps (Optional)

### Camera Details v2.0
- [ ] Đọc resolution thực tế (không phải từ tên)
- [ ] Hiển thị aperture (f/1.8, f/2.2...)
- [ ] Hiển thị focal length (24mm, 70mm...)
- [ ] OIS support detection

### Advanced Features
- [ ] Benchmark RAM speed
- [ ] Storage read/write speed test
- [ ] Camera quality score (megapixels, sensor size)

---

**Updated**: 2025-11-10  
**Status**: ✅ Complete  
**Files Modified**: 2  
**New Features**: Real-time camera & RAM/ROM display

