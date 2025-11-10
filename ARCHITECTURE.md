# Auto Diagnostics - GetX MVC Architecture

## 📁 Project Structure

```
lib/
├── main.dart                          # App entry point
├── routes/
│   ├── app_pages.dart                 # Centralized route configuration
│   └── app_routes.dart                # Route constants
└── diagnostics/
    ├── controllers/
    │   └── auto_diagnostics_controller.dart  # Business logic
    ├── views/
    │   └── auto_diagnostics_view.dart        # UI layer
    ├── bindings/
    │   └── auto_diagnostics_binding.dart     # Dependency injection
    └── model/
        └── diag_step.dart             # Data models
```

## 🏗️ Architecture Overview

This app follows **GetX MVC Pattern**:

- **Model**: Data structures (`DiagStep`, device info maps)
- **View**: UI components (`AutoDiagnosticsView`)
- **Controller**: Business logic (`AutoDiagnosticsController`)
- **Binding**: Dependency injection (`AutoDiagnosticsBinding`)

## 🚀 Navigation

### Using Routes

Navigate to Auto Diagnostics screen:

```dart
// From anywhere in the app
Get.toNamed(Routes.AUTO_DIAGNOSTICS);
```

### Route Configuration

Routes are centralized in `lib/routes/app_pages.dart`:

```dart
static final routes = [
  GetPage(
    name: _Paths.AUTO_DIAGNOSTICS,
    page: () => const AutoDiagnosticsView(),
    binding: AutoDiagnosticsBinding(),
  ),
];
```

## 🎯 Key Features

### 1. **Platform Detection**

The controller automatically detects the platform and device brand:

```dart
// In controller:
bool get isAndroid => (info['osmodel']?['platform'] == 'android');
bool get isIOS => (info['osmodel']?['platform'] == 'ios');
String get brand => (info['osmodel']?['brand'] as String?) ?? '';
String get manufacturer => (info['osmodel']?['manufacturer'] as String?) ?? '';
String get modelName => (info['osmodel']?['model'] as String?) ?? '';
bool get isSamsung => vendor.toLowerCase() == 'samsung';
bool get isApple => vendor.toLowerCase() == 'apple' || isIOS;
```

### 2. **No Parameter Passing**

The view doesn't need any parameters. All device information is automatically collected:

```dart
// Old approach (NOT used):
// Get.to(() => AutoDiagnosticsView(modelName: 'Samsung S21'));

// New approach (used):
Get.toNamed(Routes.AUTO_DIAGNOSTICS);
// Controller automatically detects: Android, Samsung, model name, etc.
```

### 3. **Automatic Device Info Collection**

On initialization, the controller collects:
- ✅ OS platform (Android/iOS)
- ✅ Device brand (Samsung, Apple, etc.)
- ✅ Device manufacturer
- ✅ Model name
- ✅ Battery info
- ✅ RAM/ROM info
- ✅ Network connectivity
- ✅ And more...

## 📱 Platform-Specific Logic

### Android Detection

```dart
if (controller.isAndroid) {
  // Android-specific code
}

if (controller.isSamsung) {
  // Samsung-specific features (e.g., S-Pen)
}
```

### iOS Detection

```dart
if (controller.isIOS) {
  // iOS-specific code
}

if (controller.isApple) {
  // Apple device
}
```

## 🔧 How It Works

### 1. **App Initialization**

```
main.dart
  ↓
GetMaterialApp
  ↓
AppPages.INITIAL → Routes.AUTO_DIAGNOSTICS
```

### 2. **Route Navigation**

```
User navigates to /auto-diagnostics
  ↓
AutoDiagnosticsBinding creates AutoDiagnosticsController
  ↓
Controller.onInit() runs
  ↓
_collectInfoEarly() gathers device info (parallel async)
  ↓
View displays info using controller getters
```

### 3. **Device Info Flow**

```
Controller.onInit()
  ↓
_collectInfoEarly()
  ↓
├─ _getOsAndModel()      → Platform, brand, model
├─ _getBatteryInfo()     → Battery level, state
├─ _getWifiInfo()        → WiFi SSID
├─ _getRamInfo()         → RAM free/total
└─ _getRomInfo()         → ROM free/total
  ↓
Stored in controller.info observable map
  ↓
View reactively displays via Obx()
```

## 🎨 UI Structure

The view is composed of:

1. **Progress Donut**: Shows test completion (X/Y completed)
2. **Device Info Card**: Displays model, IMEI, platform, brand, RAM, ROM
3. **Status Pills**: Pass/fail counters
4. **Test Grid**: Individual diagnostic steps
5. **Start/Restart Button**: Launches diagnostic flow

## 🧪 Diagnostic Tests

Tests are organized in `_buildSteps()`:

- **Auto tests**: Run automatically (battery, WiFi, sensors, etc.)
- **Manual tests**: Require user interaction (touch, camera, speaker, etc.)

### Platform-Specific Tests

Some tests are platform-aware:

```dart
DiagStep(
  code: 'spen',
  title: 'S-Pen (Samsung)',
  kind: DiagKind.auto,
  run: _snapSPen,  // Only relevant for Samsung devices
),
```

## 📊 Data Flow (Reactive)

```
Controller.info (Observable Map)
  ↓
Obx(() { ... })  // Auto-rebuilds when data changes
  ↓
UI displays current state
```

## 🔑 Key Benefits

1. ✅ **Clean separation of concerns** (MVC)
2. ✅ **No parameter passing** needed
3. ✅ **Automatic platform detection**
4. ✅ **Reactive UI** updates
5. ✅ **Centralized routing**
6. ✅ **Easy to test** (controller logic isolated)
7. ✅ **Scalable** (easy to add new routes/features)

## 🚦 Adding New Routes

1. Define path in `app_routes.dart`:
```dart
abstract class _Paths {
  static const NEW_FEATURE = '/new-feature';
}
```

2. Add route constant:
```dart
abstract class Routes {
  static const NEW_FEATURE = _Paths.NEW_FEATURE;
}
```

3. Add page in `app_pages.dart`:
```dart
GetPage(
  name: _Paths.NEW_FEATURE,
  page: () => const NewFeatureView(),
  binding: NewFeatureBinding(),
),
```

4. Navigate:
```dart
Get.toNamed(Routes.NEW_FEATURE);
```

## 📚 Resources

- [GetX Documentation](https://pub.dev/packages/get)
- [GetX Pattern](https://github.com/kauemurakami/getx_pattern)
- [Flutter Best Practices](https://flutter.dev/docs/development/ui/best-practices)

