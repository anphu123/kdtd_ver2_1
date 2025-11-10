# Quick Reference - Auto Diagnostics

## 🚀 Navigation

```dart
// From anywhere in the app
Get.toNamed(Routes.AUTO_DIAGNOSTICS);
```

## 📱 Platform Detection (in Controller)

```dart
// Check platform
controller.isAndroid  // true if Android
controller.isIOS      // true if iOS
controller.platform   // 'android', 'ios', or 'unknown'

// Check brand
controller.brand         // 'Samsung', 'Apple', etc.
controller.manufacturer  // Manufacturer name
controller.vendor        // Normalized vendor name
controller.isSamsung     // true if Samsung device
controller.isApple       // true if Apple device

// Get model
controller.modelName  // 'SM-G991B', 'iPhone 13', etc.
```

## 🎯 Usage in View

```dart
// Access device info directly from controller
Obx(() {
  final model = controller.modelName;
  final platform = controller.isAndroid ? 'Android' : 'iOS';
  final brand = controller.brand;
  
  return Text('$brand $model running $platform');
});
```

## 🔧 Device Info Available

All accessible via `controller.info`:

```dart
// OS & Model
controller.info['osmodel']
  ├─ platform       // 'android' | 'ios'
  ├─ model          // Device model
  ├─ brand          // Brand name
  ├─ manufacturer   // Manufacturer
  └─ vendor         // Normalized

// Battery
controller.info['battery']
  ├─ level          // 0-100
  └─ state          // 'charging', 'full', etc.

// Memory
controller.info['ram']
  ├─ freeBytes
  └─ totalBytes
  
controller.info['rom']
  ├─ freeBytes
  └─ totalBytes

// Network
controller.info['wifi']
  ├─ connected      // bool
  └─ ssid           // WiFi name

controller.info['mobile']
  ├─ connected      // bool
  ├─ dbm            // Signal strength
  └─ radio          // 'LTE', '5G', etc.

// Hardware
controller.info['bluetooth']  // { enabled, scanOk }
controller.info['nfc']        // { available }
controller.info['sim']        // { slotCount, states }
controller.info['sensors']    // { accelerometer, gyroscope }
controller.info['gps']        // { serviceOn, accuracyM }
```

## 📁 File Locations

```
lib/
├── main.dart                           # App entry
├── routes/
│   ├── app_pages.dart                 # Add new routes here
│   └── app_routes.dart                # Add route constants here
└── diagnostics/
    ├── controllers/
    │   └── auto_diagnostics_controller.dart
    ├── views/
    │   └── auto_diagnostics_view.dart
    └── bindings/
        └── auto_diagnostics_binding.dart
```

## ➕ Adding New Routes

### Step 1: Define route constant (`app_routes.dart`)
```dart
abstract class Routes {
  static const MY_NEW_SCREEN = _Paths.MY_NEW_SCREEN;
}

abstract class _Paths {
  static const MY_NEW_SCREEN = '/my-new-screen';
}
```

### Step 2: Add route config (`app_pages.dart`)
```dart
GetPage(
  name: _Paths.MY_NEW_SCREEN,
  page: () => const MyNewScreenView(),
  binding: MyNewScreenBinding(),
),
```

### Step 3: Navigate
```dart
Get.toNamed(Routes.MY_NEW_SCREEN);
```

## 🧩 GetX MVC Pattern

```
User Action
    ↓
View (UI)
    ↓
Controller (Logic)
    ↓
Model (Data)
    ↓
View (Update)
```

### Controller
```dart
class MyController extends GetxController {
  final count = 0.obs;  // Observable
  
  void increment() => count++;
}
```

### Binding
```dart
class MyBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(MyController());
  }
}
```

### View
```dart
class MyView extends GetView<MyController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() => Text('${controller.count}'));
  }
}
```

## 🎨 Common Patterns

### Reactive Data
```dart
// In Controller
final data = <String, dynamic>{}.obs;

// In View
Obx(() => Text('${controller.data['key']}')),
```

### Loading State
```dart
// In Controller
final isLoading = false.obs;

void fetchData() async {
  isLoading.value = true;
  // ... fetch data
  isLoading.value = false;
}

// In View
Obx(() => controller.isLoading.value 
    ? CircularProgressIndicator() 
    : DataWidget()),
```

### Dialogs & Snackbars
```dart
// Show dialog
Get.dialog(AlertDialog(...));

// Show snackbar
Get.snackbar('Title', 'Message');

// Navigate
Get.toNamed(Routes.SOMEWHERE);
Get.back();
```

## 🔍 Debugging

### Check platform detection
```dart
print('Platform: ${controller.platform}');
print('Brand: ${controller.brand}');
print('Model: ${controller.modelName}');
print('Is Samsung: ${controller.isSamsung}');
print('Is Apple: ${controller.isApple}');
```

### Check device info
```dart
print('Full info: ${controller.info}');
print('OS Model: ${controller.info['osmodel']}');
```

## ⚡ Performance Tips

1. Use `const` constructors when possible
2. Minimize rebuilds with `Obx()` wrapping only what changes
3. Use `ever()` for side effects instead of rebuilding UI
4. Lazy load controllers with `Get.lazyPut()` if not needed immediately

## 📚 Resources

- [GetX Docs](https://pub.dev/packages/get)
- [Flutter Docs](https://flutter.dev/docs)
- [ARCHITECTURE.md](./ARCHITECTURE.md) - Full architecture guide
- [IMPLEMENTATION_SUMMARY.md](./IMPLEMENTATION_SUMMARY.md) - Changes made

