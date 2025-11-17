# PowerShell script to setup SDK and demo project
# Run: .\setup_sdk_demo.ps1

Write-Host "🚀 Setting up Phone Diagnostics SDK Demo" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

$PACKAGE_DIR = "..\phone_diagnostics_sdk"
$DEMO_DIR = "..\diagnostics_demo"
$CURRENT_DIR = Get-Location

# Step 1: Create package structure
Write-Host "📁 Step 1: Creating package structure..." -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path "$PACKAGE_DIR\lib\src\controllers" | Out-Null
New-Item -ItemType Directory -Force -Path "$PACKAGE_DIR\lib\src\models" | Out-Null
New-Item -ItemType Directory -Force -Path "$PACKAGE_DIR\lib\src\views" | Out-Null
New-Item -ItemType Directory -Force -Path "$PACKAGE_DIR\lib\src\services" | Out-Null
New-Item -ItemType Directory -Force -Path "$PACKAGE_DIR\lib\src\utils" | Out-Null
New-Item -ItemType Directory -Force -Path "$PACKAGE_DIR\lib\src\widgets" | Out-Null
New-Item -ItemType Directory -Force -Path "$PACKAGE_DIR\assets" | Out-Null

# Step 2: Copy source files
Write-Host "📋 Step 2: Copying source files..." -ForegroundColor Yellow
Copy-Item -Path "lib\diagnostics\controllers\*" -Destination "$PACKAGE_DIR\lib\src\controllers\" -Recurse -Force
Copy-Item -Path "lib\diagnostics\models\*" -Destination "$PACKAGE_DIR\lib\src\models\" -Recurse -Force
Copy-Item -Path "lib\diagnostics\views\*" -Destination "$PACKAGE_DIR\lib\src\views\" -Recurse -Force
Copy-Item -Path "lib\diagnostics\services\*" -Destination "$PACKAGE_DIR\lib\src\services\" -Recurse -Force
Copy-Item -Path "lib\diagnostics\utils\*" -Destination "$PACKAGE_DIR\lib\src\utils\" -Recurse -Force

# Copy widgets
Copy-Item -Path "lib\diagnostics\views\widgets\*" -Destination "$PACKAGE_DIR\lib\src\widgets\" -Recurse -Force

# Copy assets
Copy-Item -Path "assets\diag_rules.json" -Destination "$PACKAGE_DIR\assets\" -Force
Copy-Item -Path "assets\diag_thresholds.json" -Destination "$PACKAGE_DIR\assets\" -Force

# Step 3: Create main export file
Write-Host "📝 Step 3: Creating main export file..." -ForegroundColor Yellow
@"
library phone_diagnostics_sdk;

// Controllers
export 'src/controllers/auto_diagnostics_controller.dart';

// Models
export 'src/models/diag_step.dart';
export 'src/models/device_profile.dart';
export 'src/models/diag_environment.dart';
export 'src/models/rule_evaluator.dart';
export 'src/models/profile_manager.dart';

// Views
export 'src/views/auto_diagnostics_view.dart';
export 'src/views/diagnostic_result_page.dart';
export 'src/views/failed_tests_warning_page.dart';

// Services
export 'src/services/phone_info_service.dart';

// Widgets
export 'src/widgets/device_info_section.dart';
export 'src/widgets/auto_suite_section.dart';
export 'src/widgets/animated_test_item.dart';
export 'src/widgets/phone_3d_widget.dart';
export 'src/widgets/widgets.dart';
"@ | Out-File -FilePath "$PACKAGE_DIR\lib\phone_diagnostics_sdk.dart" -Encoding UTF8

# Step 4: Update package pubspec.yaml
Write-Host "⚙️  Step 4: Updating package pubspec.yaml..." -ForegroundColor Yellow
@"
name: phone_diagnostics_sdk
description: A comprehensive phone diagnostics SDK for Flutter
version: 1.0.0

environment:
  sdk: ^3.7.2
  flutter: ">=3.0.0"

dependencies:
  flutter:
    sdk: flutter
  get: ^4.6.6
  device_info_plus: ^10.0.0
  battery_plus: ^6.0.0
  connectivity_plus: ^6.0.0
  network_info_plus: ^5.0.0
  flutter_blue_plus: ^1.32.0
  nfc_manager: ^3.5.0
  sensors_plus: ^5.0.0
  geolocator: ^12.0.0
  vibration: ^2.0.0
  camera: ^0.11.0
  local_auth: ^2.2.0
  permission_handler: ^11.3.0
  audioplayers: ^6.0.0
  record: ^5.1.0
  proximity_sensor: ^1.0.2
  path_provider: ^2.1.0
  http: ^1.2.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0

flutter:
  assets:
    - assets/diag_rules.json
    - assets/diag_thresholds.json
"@ | Out-File -FilePath "$PACKAGE_DIR\pubspec.yaml" -Encoding UTF8

# Step 5: Update demo app pubspec.yaml
Write-Host "📱 Step 5: Updating demo app pubspec.yaml..." -ForegroundColor Yellow
@"
name: diagnostics_demo
description: Demo app for Phone Diagnostics SDK
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: ^3.7.2

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  get: ^4.6.6
  phone_diagnostics_sdk:
    path: ../phone_diagnostics_sdk

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0

flutter:
  uses-material-design: true
"@ | Out-File -FilePath "$DEMO_DIR\pubspec.yaml" -Encoding UTF8

# Step 6: Create demo app main.dart
Write-Host "🎨 Step 6: Creating demo app..." -ForegroundColor Yellow
@"
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
        title: const Text('Phone Diagnostics SDK Demo'),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.amber.shade50,
              Colors.white,
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.phone_android,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 48),
                
                // Title
                const Text(
                  'Phone Diagnostics SDK',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 16),
                
                // Subtitle
                Text(
                  'Comprehensive device testing solution',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 48),
                
                // Features
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildFeature(Icons.check_circle, '20+ Auto Tests'),
                      const SizedBox(height: 12),
                      _buildFeature(Icons.touch_app, 'Interactive Tests'),
                      const SizedBox(height: 12),
                      _buildFeature(Icons.analytics, 'Detailed Reports'),
                      const SizedBox(height: 12),
                      _buildFeature(Icons.price_check, 'Price Estimation'),
                    ],
                  ),
                ),
                
                const SizedBox(height: 48),
                
                // Start button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Initialize controller
                      Get.put(AutoDiagnosticsController());
                      
                      // Navigate to diagnostics
                      Get.to(() => const AutoDiagnosticsView());
                    },
                    icon: const Icon(Icons.play_arrow, size: 28),
                    label: const Text(
                      'Start Diagnostics',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Info text
                Text(
                  'Tap to run comprehensive device tests',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeature(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.amber, size: 24),
        const SizedBox(width: 12),
        Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
"@ | Out-File -FilePath "$DEMO_DIR\lib\main.dart" -Encoding UTF8

# Step 7: Get dependencies
Write-Host "📦 Step 7: Getting dependencies..." -ForegroundColor Yellow
Set-Location $PACKAGE_DIR
flutter pub get
Set-Location $DEMO_DIR
flutter pub get
Set-Location $CURRENT_DIR

Write-Host ""
Write-Host "✅ Setup complete!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "📦 Package location: $PACKAGE_DIR" -ForegroundColor White
Write-Host "📱 Demo app location: $DEMO_DIR" -ForegroundColor White
Write-Host ""
Write-Host "To run the demo app:" -ForegroundColor Yellow
Write-Host "  cd $DEMO_DIR" -ForegroundColor White
Write-Host "  flutter run" -ForegroundColor White
Write-Host ""
