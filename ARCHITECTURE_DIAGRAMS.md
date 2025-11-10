# 🎨 System Architecture Diagram

## Sơ Đồ Tổng Thể

```
┌─────────────────────────────────────────────────────────────┐
│                      KDTD Auto Diagnostics                  │
│                     Flutter + GetX App                       │
└─────────────────────────────────────────────────────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
        ▼                     ▼                     ▼
┌───────────────┐    ┌────────────────┐    ┌──────────────┐
│   Routing     │    │  Binding       │    │  View        │
│  (GetX)       │    │  (GetX)        │    │ (Material 3) │
│               │    │                │    │              │
│ AppPages      │───▶│ AutoDiag       │───▶│ AutoDiag     │
│ AppRoutes     │    │ Binding        │    │ NewView      │
└───────────────┘    └────────┬───────┘    └──────┬───────┘
                              │                   │
                              ▼                   │
                     ┌────────────────┐           │
                     │  Controller    │◀──────────┘
                     │  (GetX)        │
                     │                │
                     │ AutoDiag       │
                     │ Controller     │
                     └────────┬───────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
        ▼                     ▼                     ▼
┌───────────────┐    ┌────────────────┐    ┌──────────────┐
│   Models      │    │  Services      │    │  Evaluator   │
│               │    │                │    │              │
│ DiagStep      │    │ Camera         │    │ Rule         │
│ DeviceProfile │    │ Battery        │    │ Evaluator    │
│ Environment   │    │ Connectivity   │    │              │
│ Thresholds    │    │ Sensors        │    │ Profile      │
│               │    │ GPS            │    │ Manager      │
└───────────────┘    └────────────────┘    └──────────────┘
```

---

## Chi Tiết Từng Layer

### 1. **Presentation Layer** (View)

```
AutoDiagnosticsNewView
│
├── DeviceInfoCard
│   ├── Device Icon & Name
│   ├── Circular Progress
│   └── Pass/Fail/Skip Stats
│
├── QuickStatsRow
│   ├── RAM Card
│   ├── Storage Card
│   └── Battery Card
│
├── CameraInfoCard
│   ├── Camera Count
│   ├── Camera Types (Auto-detect)
│   └── Camera Names
│
├── TestCategorySection (Auto)
│   ├── Header (Icon + Title)
│   └── TestItemCard × N
│       ├── Test Icon
│       ├── Title + Note
│       └── Status Badge
│
├── TestCategorySection (Manual)
│   └── TestItemCard × N
│
├── CapabilitiesCard
│   ├── NFC Chip
│   ├── Bio Chip
│   └── S-Pen Chip (conditional)
│
└── Action Buttons
    ├── Start/Restart Button
    ��── Print Results Button
```

---

### 2. **Business Logic Layer** (Controller)

```
AutoDiagnosticsController
│
├── Initialization
│   ├── onInit()
│   │   ├── _buildSteps()          → Create 25 test steps
│   │   ├── _prepareCameras()       → Detect cameras
│   │   ├── _collectInfoEarly()     → Pre-load info
│   │   └── _initializeEvaluator()  → Init rule engine
│   │
│   └── _buildSteps()
│       ├── Auto Tests (17)
│       │   ├── osmodel, battery, mobile, wifi
│       │   ├── ram, rom, bt, nfc, sim
│       │   ├── sensors, gps, charge, wired
│       │   ├── lock, spen, bio, vibrate
│       │   └── ...
│       │
│       └── Manual Tests (8)
│           ├── keys, touch, screen
│           ├── camera, speaker, mic, ear
│           └── ...
│
├── Test Execution
│   └── start()
│       ├── Update environment
│       ├── For each step:
│       │   ├── Set status = RUNNING
│       │   ├── Execute run() or interact()
│       │   ├── Collect data → info[code]
│       │   ├── Evaluate with RuleEvaluator
│       │   ├── Update status (PASS/FAIL/SKIP)
│       │   └── Update note (reason)
│       │
│       └── Calculate score & grade
│
├── Data Collection (Snapshots)
│   ├── _snapOsModel()      → Platform, brand, model
│   ├── _snapBattery()      → Level, state
│   ├── _snapWifi()         → SSID, connected
│   ├── _snapMobile()       → dBm, radio type
│   ├── _snapRam()          → Free/Total bytes
│   ├── _snapRom()          → Free/Total bytes
│   ├── _snapSensors()      → Accel, gyro
│   ├── _snapGps()          → Accuracy
│   ├── _snapNfc()          → Available
│   ├── _snapSim()          → Slot count, states
│   └── ...
│
└── Interactive Tests
    ├── _openCameraQuick()       → AdvancedCameraTestPage
    ├── _openTouchGrid()         → TouchGridTestPage
    ├── _openScreenBurnInTest()  → Auto/Manual based on tier
    ├── _openSpeakerTest()       → SpeakerTestPage
    ├── _openMicTest()           → MicTestPage
    └── _confirm()               → Dialog confirmation
```

---

### 3. **Data Layer** (Models & Services)

```
Models
│
├── DiagStep
│   ├── code: String
│   ├── title: String
│   ├── kind: DiagKind (auto/manual)
│   ├── status: DiagStatus (pending/running/passed/failed/skipped)
│   ├── note: String?
│   ├── run: Future<bool> Function()?
│   └── interact: Future<bool> Function()?
│
├── DeviceProfile
│   ├── name: String
│   ├── require: List<String>
│   ├── sPen: bool
│   ├── bio: bool
│   ├── secureLock: bool
│   ├── tier: int (1-5)
│   └── autoScreenTest: bool
│
├── DiagEnvironment
│   ├── brand: String
│   ├── platform: String
│   ├── locationServiceOn: bool
│   ├── grantedPerms: Set<String>
│   ├── deniedPerms: Set<String>
│   └── sensors: Map<String, bool>
│
└── DiagThresholds
    ├── mobile: { dbm_min, dbm_max }
    ├── gps: { accuracy_m_pass, timeout_sec }
    ├── touch: { pass_ratio_min }
    └── audio: { mic_rms_min }

Services (Platform Channels & Plugins)
│
├── Camera Service
│   ├── availableCameras()
│   ├── CameraController
│   └── takePicture()
│
├── Battery Service
│   ├── batteryLevel
│   └── batteryState
│
├── Connectivity Service
│   ├── checkConnectivity()
│   └── WiFi/Mobile status
│
├── Network Info
│   ├── getWifiName()
│   └── getWifiIP()
│
├── Sensors Service
│   ├── accelerometerEvents
│   ├── gyroscopeEvents
│   └── sensor availability
│
├── GPS Service
│   ├── getCurrentPosition()
│   ├── isLocationServiceEnabled()
│   └── accuracy
│
├── NFC Service
│   └── isAvailable()
│
└── Platform Channels (Native)
    ├── getSignalStrengthDbm()
    ├── getMobileRadioType()
    ├── getRamInfo()
    ├── getRomInfo()
    ├── getSimSlotCount()
    ├── isSPenSupported()
    └── ...
```

---

### 4. **Evaluation Engine**

```
RuleEvaluator
│
├── Input
│   ├── DeviceProfile (requirements)
│   ├── DiagEnvironment (system state)
│   ├── DiagThresholds (limits)
│   └── Payload (test data)
│
├── Evaluation Logic
│   ├── For each test code:
│   │   ├── Check profile requirements
│   │   ├── Check environment constraints
│   │   ├── Apply thresholds
│   │   └── Return EvalResult
│   │
│   └── EvalResult: PASS / FAIL / SKIP
│
├── Reason Generation
│   └── getReason(code, payload, result)
│       ├── Context-aware messages
│       ├── Brand-specific hints
│       └── Human-readable strings
│
└── Rule Repository (JSON)
    ├── diag_rules.json
    │   ├── Test conditions
    │   ├── Pass criteria
    │   ├── Fail criteria
    │   └── Skip criteria
    │
    └── diag_thresholds.json
        ├── Threshold values
        ├── Profile requirements
        └── Brand quirks
```

---

## Data Flow Diagram

### Test Execution Flow

```
User Action                Controller                 Evaluator
───────────                ──────────                 ─────────

[Start] ──────────────────▶ start()
                            │
                            ├─ Update environment
                            │
                            ├─ Loop steps
                            │   │
                            │   ├─ status = RUNNING ──▶ UI updates
                            │   │
                            │   ├─ Execute test
                            │   │   ├─ Auto: run()
                            │   │   └─ Manual: interact() ──▶ User Input
                            │   │
                            │   ├─ Collect data
                            │   │   └─ info[code] = {...}
                            │   │
                            │   ├─ Evaluate ──────────────▶ evaluate(code, payload)
                            │   │                              │
                            │   │                              ├─ Check profile
                            │   │                              ├─ Check environment
                            │   │                              ├─ Apply thresholds
                            │   │                              │
                            │   │◀─────────────────────────── return PASS/FAIL/SKIP
                            │   │
                            │   ├─ Get reason ─────────────▶ getReason(code, payload, result)
                            │   │                              │
                            │   │◀─────────────────────────── return "Reason string"
                            │   │
                            │   ├─ Update status
                            │   ├─ Update note
                            │   ├─ Update counters
                            │   └─ steps.refresh() ──▶ UI updates
                            │
                            └─ Show final result ──▶ Snackbar
```

---

### Reactive Data Binding

```
Controller Observable              UI (Obx)
─────────────────────              ────────

steps = [...]                      ListView
  │                                   │
  ├─ steps.refresh() ─────────────▶ rebuild
  │                                   │
  └─ steps[0].status = PASSED ───▶ Icon changes to ✓

info['ram'] = {...}                QuickStatsRow
  │                                   │
  └─ info.refresh() ──────────────▶ rebuild
                                      │
                                      └─ Display "8 GB"

passedCount.value++                DeviceInfoCard
  │                                   │
  └─ trigger Obx ──────────────────▶ rebuild
                                      │
                                      └─ Update "18/25 passed"

isRunning.value = true             Start Button
  │                                   │
  └─ trigger Obx ──────────────────▶ setState(disabled)
                                      │
                                      └─ Show "Running..."
```

---

## Component Interaction Diagram

```
┌──────────────────────────────────────────────────────────┐
│                    User Interface                        │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐        │
│  │ Device     │  │ Quick      │  │  Camera    │        │
│  │ Info Card  │  │ Stats Row  │  │  Info Card │        │
│  └─────┬──────┘  └─────┬──────┘  └─────┬──────┘        │
│        │               │               │                │
│        └───────────────┴───────────────┘                │
│                        │                                │
└────────────────────────┼────────────────────────────────┘
                         │ Obx() reads
                         ▼
┌──────────────────────────────────────────────────────────┐
│                    Controller State                      │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐        │
│  │ steps.obs  │  │ info.obs   │  │ counters   │        │
│  │ (RxList)   │  │ (RxMap)    │  │ (RxInt)    │        │
│  └─────┬──────┘  └─────┬──────┘  └─────┬──────┘        │
│        │               │               │                │
│        └───────────────┴───────────────┘                │
│                        │                                │
└────────────────────────┼────────────────────────────────┘
                         │ Updates via
                         ▼
┌──────────────────────────────────────────────────────────┐
│                  Business Logic                          │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐        │
│  │ Test       │  │ Data       │  │ Evaluation │        │
│  │ Execution  │  │ Collection │  │ Engine     │        │
│  └─────┬──────┘  └─────┬──────┘  └─────┬──────┘        │
│        │               │               │                │
│        └───────────────┴───────────────┘                │
│                        │                                │
└────────────────────────┼────────────────────────────────┘
                         │ Calls
                         ▼
┌──────────────────────────────────────────────────────────┐
│                   Platform Services                      │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐        │
│  │ Camera     │  │ Battery    │  │ Sensors    │        │
│  │ GPS        │  │ WiFi       │  │ NFC        │        │
│  └────────────┘  └────────────┘  └────────────┘        │
└──────────────────────────────────────────────────────────┘
```

---

## File Organization Tree

```
lib/
├── main.dart                          # Entry point
│
├── core/
│   └── routes/
│       ├── app_routes.dart            # Route constants
│       └── app_pages.dart             # Route config + bindings
│
├── diagnostics/
│   ├── bindings/
│   │   └── auto_diagnostics_binding.dart
│   │
│   ├── controllers/
│   │   └── auto_diagnostics_controller.dart
│   │
│   ├── model/
│   │   ├── diag_step.dart             # Test step model
│   │   ├── device_profile.dart        # Device requirements
│   │   ├── diag_environment.dart      # System state
│   │   ├── diag_thresholds.dart       # Threshold models
│   │   ├── profile_manager.dart       # Profile loader
│   │   └── rule_evaluator.dart        # Evaluation engine
│   │
│   └── views/
│       ├── auto_diagnostics_view_new.dart    # Main view
│       ├── auto_diagnostics_view.dart        # Alternate view
│       ├── advanced_camera_test_page.dart    # Camera test
│       ├── screen_burnin_test_page.dart      # Screen test
│       ├── auto_screen_burnin_test_page.dart # Auto screen
│       ├── touch_grid_test_page.dart         # Touch test
│       ├── speaker_test_page.dart            # Speaker test
│       ├── mic_test_page.dart                # Mic test
│       └── earpiece_test_page.dart           # Earpiece test
│
└── views/
    └── onboarding_view.dart           # Onboarding

assets/
├── diag_rules.json                    # Test rules
└── diag_thresholds.json               # Thresholds + profiles

android/
└── app/src/main/kotlin/.../
    └── DiagnosticsPlugin.kt           # Native methods
```

---

**Created**: 2025-11-10  
**Version**: 1.0  
**Type**: Architecture Documentation  
**Purpose**: Visual reference for system design

