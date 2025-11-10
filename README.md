# 📱 KDTD - Kiểm Định Thiết Bị (Device Diagnostics)

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?style=for-the-badge&logo=flutter)
![GetX](https://img.shields.io/badge/GetX-4.0+-8B5CF6?style=for-the-badge&logo=flutter)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

**A comprehensive mobile device diagnostics application with beautiful animations and smooth user experience**

[Features](#-features) • [Screenshots](#-screenshots) • [Getting Started](#-getting-started) • [Architecture](#-architecture) • [Documentation](#-documentation)

</div>

---

## ✨ Features

### 🎯 Core Functionality
- ✅ **Automatic Device Detection** - Platform (Android/iOS) and brand detection
- ✅ **Comprehensive Tests** - 20+ diagnostic tests covering all hardware components
- ✅ **Real-time Results** - Live progress tracking and status updates
- ✅ **Beautiful UI** - Modern design with smooth animations and transitions
- ✅ **Detailed Reports** - Complete diagnostic results with actionable insights

### 🔍 Diagnostic Tests

#### Automatic Tests
- **Device Info**: OS version, model, brand, manufacturer
- **Battery**: Level, charging state, health
- **Network**: Mobile signal (dBm), WiFi connectivity
- **Memory**: RAM and ROM usage
- **Bluetooth**: Availability and scanning
- **NFC**: Hardware detection
- **SIM**: Slot count and states
- **Sensors**: Accelerometer, gyroscope
- **GPS**: Location accuracy
- **Biometrics**: Fingerprint/Face ID availability
- **S-Pen**: Samsung S-Pen support (Samsung devices)

#### Interactive Tests
- **Touch Screen**: Multi-touch grid test
- **Camera**: Front and rear camera test
- **Speaker**: Audio playback test
- **Microphone**: Recording and amplitude test
- **Earpiece**: Proximity sensor test
- **Vibration**: Haptic feedback test
- **Physical Keys**: Volume and power button test

### 🎨 UI/UX Features
- 🌊 **Smooth Animations**: Collapsing headers, fade-in effects, slide transitions
- 📱 **Dynamic Dashboard**: Animated phone scanning with glow effects
- 🎯 **Floating Action Button**: Always accessible start/restart button
- 📊 **Progress Tracking**: Visual progress bar and status pills
- 🎭 **Status Indicators**: Color-coded test results (pass/fail/running)
- 🌙 **Theme Support**: Material 3 with light/dark mode

## 📸 Screenshots

### Onboarding Flow
Beautiful 3-page onboarding with animated icons and smooth page transitions.

### Home Dashboard
Dynamic header with phone scanning animation that collapses on scroll.

### Test Results
Real-time test execution with animated status updates.

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.0+
- Dart 3.0+
- Android Studio / VS Code / IntelliJ IDEA
- Android SDK (for Android development)
- Xcode (for iOS development)

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/yourusername/kdtd_ver2_1.git
cd kdtd_ver2_1
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Run the app**
```bash
flutter run
```

### Build for Production

**Android APK:**
```bash
flutter build apk --release
```

**Android App Bundle:**
```bash
flutter build appbundle --release
```

**iOS:**
```bash
flutter build ios --release
```

## 🏗️ Architecture

This project follows **GetX MVC Pattern** for clean architecture and state management.

```
lib/
├── main.dart                      # App entry point
├── routes/
│   └── app_pages.dart            # Centralized routing
├── views/
│   └── onboarding_view.dart      # Onboarding screens
└── diagnostics/
    ├── controllers/
    │   └── auto_diagnostics_controller.dart
    ├── views/
    │   ├── home_diagnostics_view.dart    # NEW: Dynamic dashboard
    │   ├── auto_diagnostics_view.dart    # Original grid view
    │   ├── camera_quick_page.dart
    │   ├── speaker_test_page.dart
    │   ├── mic_test_page.dart
    │   ├── earpiece_test_page.dart
    │   └── touch_grid_test_page.dart
    ├── bindings/
    │   └── auto_diagnostics_binding.dart
    └── model/
        └── diag_step.dart
```

### Key Architectural Decisions

1. **GetX for State Management**
   - Reactive programming with `.obs`
   - Dependency injection with `Bindings`
   - Route management with `GetMaterialApp`

2. **MVC Pattern**
   - **Model**: Data structures (DiagStep, device info)
   - **View**: Pure UI components
   - **Controller**: Business logic and state

3. **Separation of Concerns**
   - Each test has its own logic
   - UI components are reusable
   - Platform-specific code isolated

## 📚 Documentation

- [**ARCHITECTURE.md**](ARCHITECTURE.md) - Complete architecture guide
- [**IMPLEMENTATION_SUMMARY.md**](IMPLEMENTATION_SUMMARY.md) - Implementation details
- [**QUICK_REFERENCE.md**](QUICK_REFERENCE.md) - Quick reference guide
- [**DYNAMIC_DASHBOARD_DOCS.md**](DYNAMIC_DASHBOARD_DOCS.md) - Dashboard documentation

## 🎯 Key Components

### 1. Home Diagnostics View
Dynamic dashboard with:
- Collapsing animated header
- Phone scanning animation with glow effects
- Smooth scroll transitions
- Fade-in/slide-up item animations
- Floating Action Button

### 2. Auto Diagnostics Controller
Manages all diagnostic logic:
```dart
// Platform detection
controller.isAndroid  // true/false
controller.isIOS      // true/false
controller.isSamsung  // true/false
controller.isApple    // true/false

// Device info
controller.modelName
controller.brand
controller.manufacturer

// Test execution
await controller.start()
```

### 3. Onboarding View
3-page introduction with:
- Animated icons with glow effects
- Page indicators
- Skip/Next navigation

## 🔧 Configuration

### Routes
```dart
// Defined in lib/routes/app_pages.dart
Routes.ONBOARDING          // Initial onboarding
Routes.HOME_DIAGNOSTICS    // Dynamic dashboard
Routes.AUTO_DIAGNOSTICS    // Grid view
```

### Navigation
```dart
// Go to home dashboard
Get.toNamed(Routes.HOME_DIAGNOSTICS);

// Go back
Get.back();

// Replace all routes
Get.offAllNamed(Routes.HOME_DIAGNOSTICS);
```

## 📦 Dependencies

### Core
- `get: ^4.x` - State management, routing, DI
- `flutter/material.dart` - Material Design widgets

### Device Info
- `device_info_plus` - Platform and device detection
- `battery_plus` - Battery information
- `package_info_plus` - App package info

### Hardware Tests
- `camera` - Camera access
- `sensors_plus` - Accelerometer, gyroscope
- `geolocator` - GPS location
- `vibration` - Haptic feedback
- `local_auth` - Biometric authentication

### Connectivity
- `connectivity_plus` - Network status
- `network_info_plus` - WiFi information
- `flutter_blue_plus` - Bluetooth
- `nfc_manager` - NFC detection

### Audio
- `audioplayers` - Audio playback
- `record` - Audio recording

### Permissions
- `permission_handler` - Runtime permissions

## 🎨 Customization

### Theme
Customize colors in `main.dart`:
```dart
ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blue, // Change primary color
  ),
  useMaterial3: true,
)
```

### Add New Tests
1. Add test step in `_buildSteps()`:
```dart
DiagStep(
  code: 'new_test',
  title: 'New Test',
  kind: DiagKind.auto,
  run: _runNewTest,
)
```

2. Implement test logic:
```dart
Future<bool> _runNewTest() async {
  // Your test logic
  return true; // or false
}
```

## 🚀 Deployment

### Android
1. Update `android/app/build.gradle`
2. Generate keystore
3. Build release APK/AAB

### iOS
1. Update `ios/Runner.xcodeproj`
2. Configure signing
3. Build release IPA

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**Your Name**
- GitHub: [@yourusername](https://github.com/yourusername)
- Email: your.email@example.com

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- GetX community for state management
- Material Design for UI guidelines
- All open-source contributors

## 📞 Support

For support, email your.email@example.com or open an issue on GitHub.

---

<div align="center">

**Made with ❤️ using Flutter**

⭐ Star this repo if you find it helpful!

</div>

