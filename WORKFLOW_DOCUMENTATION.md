# 📖 Luồng Hoạt Động - Auto Diagnostics System

## Tổng Quan

Hệ thống Auto Diagnostics là ứng dụng kiểm tra phần cứng thiết bị tự động, sử dụng **GetX** cho state management và **Material 3** cho UI/UX.

---

## 🔄 Luồng Hoạt Động Tổng Thể

```
┌─────────────┐
│   App Start │
└──────┬──────┘
       │
       ▼
┌─────────────────┐
│  Route System   │ ──→ AppPages.initial
│  (app_pages.dart)│     = diagnosticsAutoOld
└──────┬──────────┘
       │
       ▼
┌──────────────────────┐
│ AutoDiagnosticsBinding│ ──→ Khởi tạo controller
│      (Get.put)        │
└──────┬───────────────┘
       │
       ▼
┌────────────────────────────┐
│ AutoDiagnosticsController  │
│        onInit()            │ ──→ 1. _buildSteps()
└──────┬─────────────────────┘    2. _prepareCameras()
       │                           3. _collectInfoEarly()
       │                           4. _initializeEvaluator()
       ▼
┌────────────────────────────┐
│  AutoDiagnosticsNewView    │ ──→ Hiển thị UI
│      (Material 3)          │
└────────────────────────────┘
```

---

## 🎯 Luồng Chi Tiết

### 1. **Khởi Tạo Ứng Dụng**

```dart
// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialRoute: AppPages.initial,        // → diagnosticsAutoOld
      getPages: AppPages.routes,             // Danh sách routes
      binding: AutoDiagnosticsBinding(),     // Binding controller
    );
  }
}
```

**Kết quả:**
- ✅ App khởi động
- ✅ Route system được load
- ✅ Initial route: `AutoDiagnosticsNewView`

---

### 2. **Binding & Controller Initialization**

```dart
// auto_diagnostics_binding.dart
class AutoDiagnosticsBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AutoDiagnosticsController());  // Singleton
  }
}

// auto_diagnostics_controller.dart
class AutoDiagnosticsController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    steps.assignAll(_buildSteps());       // Build test list
    _prepareCameras();                     // Detect cameras
    _collectInfoEarly();                   // Pre-load info
    _initializeEvaluator();                // Init rule engine
  }
}
```

**Timeline:**
```
0ms   → onInit() called
10ms  → _buildSteps() → 25 tests created
20ms  → _prepareCameras() → Camera list loaded
30ms  → _collectInfoEarly() → Battery, RAM, ROM loaded
500ms → _initializeEvaluator() → Profile matched, rules loaded
```

**Kết quả:**
- ✅ 25 tests (17 auto + 8 manual)
- ✅ Camera specs stored in `info['camera_specs']`
- ✅ Initial info: Battery, RAM, ROM, WiFi
- ✅ Device profile matched (e.g., "samsung_s21_ultra")
- ✅ Rule evaluator ready

---

### 3. **UI Rendering (AutoDiagnosticsNewView)**

```dart
class AutoDiagnosticsNewView extends GetView<AutoDiagnosticsController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => CustomScrollView(
        slivers: [
          // 1. Device Info Card
          SliverToBoxAdapter(child: DeviceInfoCard(...)),
          
          // 2. Quick Stats Row (RAM/ROM/Battery)
          SliverToBoxAdapter(child: QuickStatsRow(...)),
          
          // 3. Camera Info Card
          SliverToBoxAdapter(child: CameraInfoCard(...)),
          
          // 4. Auto Tests Section
          SliverToBoxAdapter(child: TestCategorySection(...)),
          
          // 5. Manual Tests Section
          SliverToBoxAdapter(child: TestCategorySection(...)),
          
          // 6. Capabilities Card
          SliverToBoxAdapter(child: CapabilitiesCard(...)),
          
          // 7. Action Buttons
          SliverToBoxAdapter(child: _buildButtons()),
        ],
      )),
    );
  }
}
```

**UI Components Timeline:**
```
0ms   → Scaffold created
10ms  → DeviceInfoCard rendered (device name, progress 0%)
20ms  → QuickStatsRow rendered (RAM: -, ROM: -, Battery: -)
30ms  → CameraInfoCard rendered (0 cameras)
40ms  → TestCategorySection (Auto) rendered (17 tests, all PENDING)
50ms  → TestCategorySection (Manual) rendered (8 tests, all PENDING)
60ms  → CapabilitiesCard rendered (NFC: -, Bio: -)
70ms  → Start button rendered (enabled)
```

**Reactive Updates (Obx):**
```
500ms  → info['camera_specs'] updated
       → CameraInfoCard re-rendered (shows real cameras)
       
1000ms → info['ram'] updated
       → QuickStatsRow re-rendered (RAM: 8 GB)
       
1500ms → info['rom'] updated
       → QuickStatsRow re-rendered (Storage: 45/128 GB)
```

---

### 4. **User Nhấn "Start Tests"**

```dart
// User taps button
onPressed: controller.start()

// Controller executes
Future<void> start() async {
  isRunning.value = true;  // → UI shows "Running..."
  
  // Update environment
  await _updateEnvironment();  // Check permissions, services
  
  // Loop through all tests
  for (final step in steps) {
    step.status = DiagStatus.running;  // → UI shows spinner
    steps.refresh();                   // → Obx rebuilds
    
    bool result;
    
    // Execute test
    if (step.kind == DiagKind.auto) {
      result = await step.run!();  // Auto test
    } else {
      result = await step.interact!();  // Manual test (user input)
    }
    
    // Evaluate result
    if (_evaluator != null) {
      final payload = info[step.code];
      final evalResult = _evaluator!.evaluate(step.code, payload);
      final reason = _evaluator!.getReason(step.code, payload, evalResult);
      
      switch (evalResult) {
        case EvalResult.pass:
          step.status = DiagStatus.passed;
          passedCount++;
          break;
        case EvalResult.fail:
          step.status = DiagStatus.failed;
          failedCount++;
          break;
        case EvalResult.skip:
          step.status = DiagStatus.skipped;
          skippedCount++;
          break;
      }
      
      step.note = reason;
    }
    
    steps.refresh();  // → UI updates
  }
  
  isRunning.value = false;
  
  // Show final result
  Get.snackbar('Complete', 'Score: 85/100 - Loại 2');
}
```

**Test Execution Timeline:**

```
T+0s    → [osmodel] RUNNING
T+0.1s  → [osmodel] PASS ("Android 13, Samsung S21 Ultra")

T+0.2s  → [battery] RUNNING
T+0.3s  → [battery] PASS ("Level: 85%")

T+0.4s  → [mobile] RUNNING
T+0.5s  → [mobile] PASS ("Signal: -75 dBm")

T+0.6s  → [wifi] RUNNING
T+0.7s  → [wifi] PASS ("Connected: MyWiFi")

T+0.8s  → [ram] RUNNING
T+0.9s  → [ram] PASS ("8 GB")

...

T+5.0s  → [camera] RUNNING (Manual test)
        → User opens AdvancedCameraTestPage
        → User captures photos
        → User confirms "All cameras OK"
T+10.0s → [camera] PASS ("Đã chụp 3 ảnh")

...

T+30.0s → All tests complete
        → Score: 85/100
        → Grade: Loại 2
```

---

### 5. **Auto Test Flow (Ví dụ: WiFi Test)**

```dart
// Step 1: Build step
DiagStep(
  code: 'wifi',
  title: 'Wi-Fi (SSID)',
  kind: DiagKind.auto,
  run: _snapWifi,
)

// Step 2: Execute
Future<bool> _snapWifi() async {
  info['wifi'] = await _getWifiInfo();  // Collect data
  return true;
}

// Step 3: Collect data
Future<Map<String, dynamic>> _getWifiInfo() async {
  final conn = await Connectivity().checkConnectivity();
  final onWifi = conn.contains(ConnectivityResult.wifi);
  
  String? ssid;
  if (onWifi) {
    ssid = await NetworkInfo().getWifiName();
  }
  
  return {
    'connected': onWifi,
    'ssid': ssid,
  };
}

// Step 4: Store in info
info['wifi'] = {
  'connected': true,
  'ssid': 'MyHomeWiFi',
}

// Step 5: Evaluate
final result = _evaluator.evaluate('wifi', info['wifi']);
// → Check rules in diag_rules.json

// Rule:
{
  "wifi": {
    "pass": "connected == true && exists(ssid) && ssid != ''",
    "fail": "connected == true && (!exists(ssid) || ssid == '')",
    "skip": "!connected || !location_service_on()"
  }
}

// Evaluation:
if (connected == true && ssid == 'MyHomeWiFi') {
  return EvalResult.pass;  // ✓ PASS
}

// Step 6: Get reason
final reason = _evaluator.getReason('wifi', payload, result);
// → "Kết nối: MyHomeWiFi"

// Step 7: Update UI
step.status = DiagStatus.passed;
step.note = "Kết nối: MyHomeWiFi";
steps.refresh();  // → Obx rebuilds TestItemCard
```

**UI Changes:**
```
Before:  [WiFi Test] [○ WAIT] Grey border
Running: [WiFi Test] [⟳ RUN]  Blue border + spinner
After:   [WiFi Test] [✓ PASS] Green border
         "Kết nối: MyHomeWiFi"
```

---

### 6. **Manual Test Flow (Ví dụ: Camera Test)**

```dart
// Step 1: Build step
DiagStep(
  code: 'camera',
  title: 'Camera Test',
  kind: DiagKind.manual,
  interact: _openCameraQuick,
)

// Step 2: User interaction
Future<bool> _openCameraQuick() async {
  // Check permission
  final status = await Permission.camera.request();
  if (!status.isGranted) return false;
  
  // Open camera test page
  final result = await Get.to<bool>(
    () => AdvancedCameraTestPage(cameras: _cams)
  );
  
  return result == true;
}

// Step 3: Camera test page flow
class AdvancedCameraTestPage {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Show camera preview
      // Detect shake (gyroscope)
      // Detect obstruction (brightness)
      // User captures photos
      // User confirms OK or has issues
    );
  }
}

// User flow:
1. Page opens with camera preview
2. System detects:
   - Shake level: 0.5 rad/s (OK)
   - Brightness: Normal
   - 4 cameras detected (Front, Main, Ultra-wide, Tele)
3. User switches cameras (1/4, 2/4, 3/4, 4/4)
4. User captures test photos (3 photos)
5. User taps "All Cameras OK" → returns true

// Step 4: Evaluate
info['camera'] = {
  'photos': 3,
  'userConfirm': true,
  'issues': [],
}

final result = _evaluator.evaluate('camera', info['camera']);
// → PASS (photos >= 1 && userConfirm == true)

final reason = _evaluator.getReason('camera', payload, result);
// → "Đã chụp 3 ảnh"

// Step 5: Update UI
step.status = DiagStatus.passed;
step.note = "Đã chụp 3 ảnh";
```

---

### 7. **Rule Evaluation System**

```
┌─────────────────┐
│   Test Result   │
│   (payload)     │
└────────┬────────┘
         │
         ▼
┌─────────────────────┐
│  RuleEvaluator      │
│  .evaluate()        │
└────────┬────────────┘
         │
         ▼
┌─────────────────────┐
│ Check Device Profile│
│ - Is NFC required?  │
│ - Is S-Pen required?│
└────────┬────────────┘
         │
         ▼
┌─────────────────────┐
│ Check Environment   │
│ - Permissions OK?   │
│ - Services ON?      │
│ - Brand quirks?     │
└────────┬────────────┘
         │
         ▼
┌─────────────────────┐
│  Apply Thresholds   │
│  - dBm: [-120,-40]  │
│  - GPS: <= 50m      │
│  - Touch: >= 98%    │
└────────┬────────────┘
         │
         ▼
┌─────────────────────┐
│   Return Result     │
│ - PASS / FAIL / SKIP│
│ - Reason (string)   │
└─────────────────────┘
```

**Example Evaluation:**

```dart
// Test: GPS
payload = {
  'serviceOn': true,
  'accuracyM': 12.5
}

// Step 1: Check environment
if (!_environment.locationServiceOn) {
  return EvalResult.skip;  // Location service OFF
}

if (_environment.isPermDenied('location')) {
  return EvalResult.skip;  // Permission denied
}

// Step 2: Check threshold
if (payload['accuracyM'] > thresholds.gps.accuracyPass) {
  return EvalResult.fail;  // Accuracy > 50m
}

// Step 3: Pass
return EvalResult.pass;  // Accuracy = 12.5m ✓

// Reason
if (result == EvalResult.pass) {
  return "Độ chính xác: ${payload['accuracyM']}m";
}
```

---

### 8. **Brand-Specific Logic (Quirks)**

```dart
// Xiaomi (MIUI) - WiFi requires Location
if (_environment.isMiui && !_environment.locationServiceOn) {
  // WiFi test → SKIP
  return EvalResult.skip;
  reason = "MIUI: cần bật Vị trí để đọc SSID";
}

// Samsung - S-Pen detection
if (_profile.sPen == true) {
  // S-Pen required
  if (payload['detected'] == false) {
    return EvalResult.fail;
    reason = "Thiết bị yêu cầu S-Pen nhưng không phát hiện";
  }
}

// iOS - Charging source unavailable
if (_environment.platform == 'ios' && payload['source'] == null) {
  return EvalResult.skip;
  reason = "iOS không hỗ trợ đọc nguồn sạc";
}
```

---

### 9. **Real-time Data Flow**

```
Controller                UI (Obx)
─────────                ─────────

info['ram'] = null  →   "RAM: -"
      ↓ (collect data)
info['ram'] = {     →   "RAM: 8 GB"
  totalBytes: 8GB
}

info['camera_specs'] = {} → "No cameras"
      ↓ (detect cameras)
info['camera_specs'] = {  → "4 cameras"
  total: 4,                 "1 front, 3 back"
  front: 1,                 "Ultra-wide detected"
  back: 3,
  cameras: [...]
}

steps[0].status = PENDING → Grey icon
      ↓ (run test)
steps[0].status = RUNNING → Blue spinner
      ↓ (evaluate)
steps[0].status = PASSED  → Green checkmark
steps[0].note = "OK"      → "OK" displayed
```

---

### 10. **Complete Test Lifecycle**

```
1. INIT
   ├─ Create DiagStep
   ├─ status = PENDING
   └─ UI: Grey icon

2. START
   ├─ status = RUNNING
   ├─ UI: Blue spinner
   └─ Execute run() or interact()

3. COLLECT
   ├─ Gather data
   ├─ Store in info[code]
   └─ Data available for evaluation

4. EVALUATE
   ├─ RuleEvaluator.evaluate()
   ├─ Check profile, environment, thresholds
   └─ Return PASS/FAIL/SKIP

5. REASON
   ├─ RuleEvaluator.getReason()
   ├─ Generate human-readable message
   └─ Store in step.note

6. UPDATE
   ├─ Update step.status
   ├─ Update counters (passed/failed/skipped)
   ├─ steps.refresh()
   └─ UI: Update color, icon, text

7. COMPLETE
   ├─ All tests done
   ├─ Calculate score
   ├─ Determine grade
   └─ Show snackbar
```

---

## 📊 State Management

### Reactive Variables (GetX)

```dart
class AutoDiagnosticsController extends GetxController {
  // Observable lists
  final steps = <DiagStep>[].obs;       // Test list
  final info = <String, dynamic>{}.obs;  // Test data
  
  // Observable counters
  final isRunning = false.obs;
  final passedCount = 0.obs;
  final failedCount = 0.obs;
  final skippedCount = 0.obs;
  
  // Computed properties (getters)
  String get modelName => info['osmodel']?['model'] ?? '';
  String get brand => info['osmodel']?['brand'] ?? '';
  bool get isSamsung => vendor == 'samsung';
}
```

### UI Reactivity

```dart
// UI auto-updates when observable changes
Obx(() {
  final modelName = controller.modelName;  // Read observable
  return Text(modelName);                  // Auto rebuild
})

// Multiple observables
Obx(() {
  final passed = controller.passedCount.value;
  final failed = controller.failedCount.value;
  final total = controller.steps.length;
  
  return Text('$passed/$total passed, $failed failed');
})
```

---

## 🎯 Key Patterns

### 1. **Separation of Concerns**
- Controller: Business logic, data collection, evaluation
- View: UI rendering, user interaction
- Model: Data structures, rules, profiles
- Evaluator: Independent evaluation engine

### 2. **Reactive Programming**
- Observable variables (`RxList`, `RxInt`, `Rx<Map>`)
- `Obx()` for auto-rebuild
- `steps.refresh()` to trigger manual updates

### 3. **Modular Widgets**
- Each widget self-contained
- Props-based (no direct controller access in child widgets)
- Reusable across views

### 4. **Type Safety**
- Null checks before cast
- Default values
- Null-safe operators (`?.`, `??`)

---

## 🔍 Debugging Flow

### 1. **Check Controller Init**
```dart
print('✅ Controller initialized');
print('Steps: ${steps.length}');
print('Cameras: ${_cams.length}');
```

### 2. **Monitor Test Execution**
```dart
for (final step in steps) {
  print('Running: ${step.code}');
  final result = await step.run!();
  print('Result: $result');
  print('Info: ${info[step.code]}');
}
```

### 3. **Check Evaluation**
```dart
print('Evaluating: ${step.code}');
final result = _evaluator!.evaluate(step.code, payload);
print('Eval result: $result');
final reason = _evaluator!.getReason(step.code, payload, result);
print('Reason: $reason');
```

### 4. **UI Update Verification**
```dart
steps.refresh();
print('Steps refreshed - UI should update');
print('Status: ${step.status}');
print('Note: ${step.note}');
```

---

## 📈 Performance Considerations

### 1. **Lazy Loading**
- Camera list loaded on init (not on demand)
- Info collected early (battery, RAM, ROM)
- Other tests run on-demand

### 2. **Efficient Rendering**
- `Obx()` only rebuilds affected widgets
- `const` constructors where possible
- `SizedBox.shrink()` for empty states

### 3. **Async Operations**
- All test runs are async
- No blocking UI
- Progress shown with spinners

---

**Created**: 2025-11-10  
**Version**: 1.0  
**Status**: ✅ Complete Documentation

