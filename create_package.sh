#!/bin/bash

# Script to convert current project to Flutter package
# Usage: bash create_package.sh

PACKAGE_NAME="phone_diagnostics_sdk"
PACKAGE_DIR="../$PACKAGE_NAME"

echo "🚀 Creating Flutter Package: $PACKAGE_NAME"
echo "================================================"

# Step 1: Create package
echo "📦 Step 1: Creating package structure..."
cd ..
flutter create --template=package $PACKAGE_NAME
cd $PACKAGE_NAME

# Step 2: Create directory structure
echo "📁 Step 2: Creating directory structure..."
mkdir -p lib/src/controllers
mkdir -p lib/src/models
mkdir -p lib/src/views
mkdir -p lib/src/services
mkdir -p lib/src/utils
mkdir -p lib/src/widgets
mkdir -p lib/src/admin/controllers
mkdir -p lib/src/admin/services
mkdir -p lib/src/admin/views
mkdir -p assets

# Step 3: Copy source files
echo "📋 Step 3: Copying source files..."
cp -r ../kdtd_ver2_1/lib/diagnostics/controllers/* lib/src/controllers/
cp -r ../kdtd_ver2_1/lib/diagnostics/models/* lib/src/models/
cp -r ../kdtd_ver2_1/lib/diagnostics/views/* lib/src/views/
cp -r ../kdtd_ver2_1/lib/diagnostics/services/* lib/src/services/
cp -r ../kdtd_ver2_1/lib/diagnostics/utils/* lib/src/utils/
cp -r ../kdtd_ver2_1/lib/admin/* lib/src/admin/

# Copy widgets separately
mkdir -p lib/src/widgets
cp -r ../kdtd_ver2_1/lib/diagnostics/views/widgets/* lib/src/widgets/

# Step 4: Copy assets
echo "🎨 Step 4: Copying assets..."
cp ../kdtd_ver2_1/assets/diag_rules.json assets/
cp ../kdtd_ver2_1/assets/diag_thresholds.json assets/

# Step 5: Create main export file
echo "📝 Step 5: Creating main export file..."
cat > lib/$PACKAGE_NAME.dart << 'EOF'
library phone_diagnostics_sdk;

// Controllers
export 'src/controllers/auto_diagnostics_controller.dart';

// Models
export 'src/models/diag_step.dart';
export 'src/models/device_profile.dart';
export 'src/models/diag_environment.dart';
export 'src/models/rule_evaluator.dart';
export 'src/models/profile_manager.dart';
export 'src/models/screen_defect_type.dart';

// Views
export 'src/views/auto_diagnostics_view.dart';
export 'src/views/diagnostic_result_page.dart';
export 'src/views/failed_tests_warning_page.dart';

// Services
export 'src/services/phone_info_service.dart';
export 'src/services/price_estimation_service.dart';

// Admin
export 'src/admin/services/excel_import_service.dart';
export 'src/admin/views/admin_import_page.dart';
export 'src/admin/controllers/admin_data_controller.dart';

// Widgets
export 'src/widgets/device_info_section.dart';
export 'src/widgets/phone_3d_widget.dart';
export 'src/widgets/purchase_action_buttons.dart';
export 'src/widgets/animated_test_item.dart';
export 'src/widgets/auto_suite_section.dart';

// Utils
export 'src/utils/device_name_mapper.dart';
export 'src/utils/phone_image_mapper.dart';
EOF

# Step 6: Update pubspec.yaml
echo "⚙️  Step 6: Updating pubspec.yaml..."
cat > pubspec.yaml << 'EOF'
name: phone_diagnostics_sdk
description: A comprehensive phone diagnostics SDK for Flutter with auto-detection, pricing estimation, and admin features.
version: 1.0.0
homepage: https://github.com/your-org/phone_diagnostics_sdk

environment:
  sdk: ^3.7.2
  flutter: ">=3.0.0"

dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  get: ^4.6.6
  
  # Device Info
  device_info_plus: ^10.0.0
  battery_plus: ^6.0.0
  connectivity_plus: ^6.0.0
  network_info_plus: ^5.0.0
  
  # Hardware
  flutter_blue_plus: ^1.32.0
  nfc_manager: ^3.5.0
  sensors_plus: ^5.0.0
  geolocator: ^12.0.0
  vibration: ^2.0.0
  camera: ^0.11.0
  
  # Security & Permissions
  local_auth: ^2.2.0
  permission_handler: ^11.3.0
  
  # Audio
  audioplayers: ^6.0.0
  record: ^5.1.0
  proximity_sensor: ^1.0.2
  
  # Storage & Files
  path_provider: ^2.1.0
  shared_preferences: ^2.2.2
  
  # Network
  http: ^1.2.0
  
  # Admin Features
  excel: ^4.0.3
  file_picker: ^8.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0

flutter:
  assets:
    - assets/diag_rules.json
    - assets/diag_thresholds.json
EOF

# Step 7: Create example app
echo "📱 Step 7: Creating example app..."
mkdir -p example/lib
cat > example/lib/main.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phone_diagnostics_sdk/phone_diagnostics_sdk.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Phone Diagnostics SDK Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phone Diagnostics SDK'),
        backgroundColor: Colors.amber,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.phone_android,
              size: 100,
              color: Colors.amber,
            ),
            const SizedBox(height: 24),
            const Text(
              'Phone Diagnostics SDK',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Comprehensive device testing solution',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              onPressed: () {
                // Initialize controller
                Get.put(AutoDiagnosticsController());
                
                // Navigate to diagnostics
                Get.to(() => const AutoDiagnosticsView());
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Diagnostics'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
EOF

cat > example/pubspec.yaml << 'EOF'
name: phone_diagnostics_sdk_example
description: Example app for phone_diagnostics_sdk
publish_to: 'none'

environment:
  sdk: ^3.7.2

dependencies:
  flutter:
    sdk: flutter
  phone_diagnostics_sdk:
    path: ../

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0

flutter:
  uses-material-design: true
EOF

# Step 8: Create README
echo "📖 Step 8: Creating README..."
cat > README.md << 'EOF'
# Phone Diagnostics SDK

A comprehensive Flutter SDK for phone diagnostics, device testing, and quality assessment.

## Features

- ✅ **Auto Diagnostics**: Automated testing of 20+ device components
- 📱 **Device Info**: Detailed hardware and software information
- 🎯 **Rule-Based Evaluation**: Configurable pass/fail criteria
- 💰 **Price Estimation**: Grade-based pricing system
- 📊 **Admin Panel**: Excel import for device pricing data
- 🎨 **Beautiful UI**: Modern, animated interface
- 🔧 **Customizable**: Flexible configuration and theming

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  phone_diagnostics_sdk:
    git:
      url: https://github.com/your-org/phone_diagnostics_sdk.git
```

Or for local development:

```yaml
dependencies:
  phone_diagnostics_sdk:
    path: ../phone_diagnostics_sdk
```

## Quick Start

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:phone_diagnostics_sdk/phone_diagnostics_sdk.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home: Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              // Initialize controller
              Get.put(AutoDiagnosticsController());
              
              // Start diagnostics
              Get.to(() => const AutoDiagnosticsView());
            },
            child: const Text('Run Diagnostics'),
          ),
        ),
      ),
    );
  }
}
```

## Platform Setup

### Android

Add permissions to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
<uses-permission android:name="android.permission.VIBRATE"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.BLUETOOTH"/>
<uses-permission android:name="android.permission.BLUETOOTH_SCAN"/>
<uses-permission android:name="android.permission.NFC"/>
<uses-permission android:name="android.permission.READ_PHONE_STATE"/>
```

### iOS

Add to `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>Camera is needed for testing</string>
<key>NSMicrophoneUsageDescription</key>
<string>Microphone is needed for audio testing</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>Location is needed for GPS testing</string>
```

## Documentation

See [API Documentation](API.md) for detailed API reference.

## License

MIT License
EOF

echo ""
echo "✅ Package created successfully!"
echo "================================================"
echo "📦 Package location: $PACKAGE_DIR"
echo ""
echo "Next steps:"
echo "1. cd $PACKAGE_DIR"
echo "2. flutter pub get"
echo "3. cd example && flutter run"
echo ""
echo "To use in another project:"
echo "Add to pubspec.yaml:"
echo "  phone_diagnostics_sdk:"
echo "    path: $PACKAGE_DIR"
