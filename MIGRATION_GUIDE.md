# 🔄 Migration Guide - Clean Code Refactoring

## Overview

This guide helps migrate the existing codebase to the new Clean Architecture structure.

---

## 📋 Migration Steps

### Phase 1: Setup Core Structure ✅

#### 1.1 Create Core Directories
```bash
mkdir -p lib/core/{constants,theme,routes,utils,extensions,errors}
```

#### 1.2 Move Files
- [x] Created `core/constants/app_constants.dart`
- [x] Created `core/theme/app_theme.dart`
- [x] Created `core/theme/app_colors.dart`
- [x] Created `core/theme/app_text_styles.dart`
- [x] Refactored `routes/app_pages.dart`

### Phase 2: Domain Layer ✅

#### 2.1 Create Entities
- [x] `features/diagnostics/domain/entities/diagnostic_step.dart`
- [x] `features/diagnostics/domain/entities/device_info.dart`

#### 2.2 Define Repository Interfaces
- [x] `features/diagnostics/domain/repositories/diagnostics_repository.dart`

#### 2.3 Create Use Cases
- [x] `features/diagnostics/domain/usecases/get_device_info_usecase.dart`
- [x] `features/diagnostics/domain/usecases/execute_diagnostic_step_usecase.dart`

### Phase 3: Data Layer 🔄

#### 3.1 Create Models
```dart
// features/diagnostics/data/models/diagnostic_step_model.dart
class DiagnosticStepModel extends DiagnosticStep {
  // Add any data-specific fields or methods
}
```

#### 3.2 Create Data Sources
```dart
// features/diagnostics/data/datasources/device_info_local_datasource.dart
abstract class IDeviceInfoLocalDataSource {
  Future<Map<String, dynamic>> getDeviceInfo();
}
```

#### 3.3 Implement Repository
```dart
// features/diagnostics/data/repositories/diagnostics_repository_impl.dart
class DiagnosticsRepositoryImpl implements IDiagnosticsRepository {
  final IDeviceInfoLocalDataSource _localDataSource;
  
  @override
  Future<DeviceInfo> getDeviceInfo() async {
    final data = await _localDataSource.getDeviceInfo();
    return DeviceInfo.fromJson(data);
  }
}
```

### Phase 4: Presentation Layer 🔄

#### 4.1 Refactor Controllers
```dart
// OLD: Direct implementation
class DiagnosticsController extends GetxController {
  void getDeviceInfo() {
    // Direct device_info_plus calls
  }
}

// NEW: Use cases
class DiagnosticsController extends GetxController {
  final GetDeviceInfoUseCase _getDeviceInfoUseCase;
  
  DiagnosticsController(this._getDeviceInfoUseCase);
  
  Future<void> loadDeviceInfo() async {
    final deviceInfo = await _getDeviceInfoUseCase();
    // Update UI
  }
}
```

#### 4.2 Rename Files
```
OLD Structure:
lib/diagnostics/views/auto_diagnostics_view.dart

NEW Structure:
lib/features/diagnostics/presentation/pages/auto_diagnostics_page.dart
```

#### 4.3 Update Bindings
```dart
// features/diagnostics/presentation/bindings/diagnostics_binding.dart
class DiagnosticsBinding extends Bindings {
  @override
  void dependencies() {
    // Data sources
    Get.lazyPut<IDeviceInfoLocalDataSource>(
      () => DeviceInfoLocalDataSourceImpl(),
    );
    
    // Repositories
    Get.lazyPut<IDiagnosticsRepository>(
      () => DiagnosticsRepositoryImpl(Get.find()),
    );
    
    // Use cases
    Get.lazyPut(() => GetDeviceInfoUseCase(Get.find()));
    Get.lazyPut(() => ExecuteDiagnosticStepUseCase(Get.find()));
    
    // Controller
    Get.lazyPut(() => DiagnosticsController(Get.find()));
  }
}
```

---

## 🔧 Refactoring Checklist

### Code Quality

- [ ] Replace all magic numbers with named constants
- [ ] Extract repeated code into functions
- [ ] Split large functions (>20 lines) into smaller ones
- [ ] Add documentation to public APIs
- [ ] Remove unused imports
- [ ] Remove dead code
- [ ] Fix all warnings

### Naming Conventions

- [ ] Use camelCase for variables and methods
- [ ] Use PascalCase for classes
- [ ] Use snake_case for file names
- [ ] Use SCREAMING_SNAKE_CASE for constants
- [ ] Use meaningful names (avoid single letters)

### Architecture

- [ ] Move business logic to use cases
- [ ] Move data fetching to repositories
- [ ] Keep controllers thin (presentation logic only)
- [ ] Use dependency injection
- [ ] Follow SOLID principles

### Testing

- [ ] Write unit tests for use cases
- [ ] Write unit tests for repositories
- [ ] Write widget tests for pages
- [ ] Add integration tests
- [ ] Achieve >80% code coverage

---

## 📝 Code Examples

### Before: Tightly Coupled Code
```dart
class DiagnosticsController extends GetxController {
  final _battery = Battery();
  final _deviceInfo = DeviceInfoPlugin();
  
  Future<void> getBatteryInfo() async {
    final level = await _battery.batteryLevel;
    final state = await _battery.batteryState;
    // Update UI
  }
  
  Future<void> getDeviceInfo() async {
    try {
      final androidInfo = await _deviceInfo.androidInfo;
      // Process data
    } catch (e) {
      // Handle error
    }
  }
}
```

### After: Clean Architecture
```dart
// Domain Layer - Use Case
class GetBatteryInfoUseCase {
  final IBatteryRepository _repository;
  
  GetBatteryInfoUseCase(this._repository);
  
  Future<BatteryInfo> call() async {
    return await _repository.getBatteryInfo();
  }
}

// Data Layer - Repository Implementation
class BatteryRepositoryImpl implements IBatteryRepository {
  final Battery _battery;
  
  @override
  Future<BatteryInfo> getBatteryInfo() async {
    final level = await _battery.batteryLevel;
    final state = await _battery.batteryState;
    return BatteryInfo(level: level, state: state);
  }
}

// Presentation Layer - Controller
class DiagnosticsController extends GetxController {
  final GetBatteryInfoUseCase _getBatteryInfoUseCase;
  
  DiagnosticsController(this._getBatteryInfoUseCase);
  
  final batteryInfo = Rx<BatteryInfo?>(null);
  
  Future<void> loadBatteryInfo() async {
    try {
      final info = await _getBatteryInfoUseCase();
      batteryInfo.value = info;
    } catch (e) {
      // Handle error
    }
  }
}
```

---

## 🎯 Benefits

### Maintainability
- ✅ Easier to understand code structure
- ✅ Easier to locate bugs
- ✅ Easier to add new features

### Testability
- ✅ Can test business logic independently
- ✅ Can mock dependencies easily
- ✅ Higher code coverage possible

### Scalability
- ✅ Can add features without breaking existing code
- ✅ Can replace implementations without changing business logic
- ✅ Team members can work on different layers independently

### Code Quality
- ✅ Follows industry best practices
- ✅ Easier code reviews
- ✅ Better documentation

---

## 📊 Progress Tracker

### Core Layer
- [x] Constants (100%)
- [x] Theme (100%)
- [x] Routes (100%)
- [ ] Utils (0%)
- [ ] Extensions (0%)
- [ ] Errors (0%)

### Domain Layer
- [x] Entities (50%)
- [x] Repository Interfaces (30%)
- [x] Use Cases (20%)

### Data Layer
- [ ] Models (0%)
- [ ] Data Sources (0%)
- [ ] Repository Implementations (0%)

### Presentation Layer
- [ ] Pages (0%)
- [ ] Widgets (0%)
- [ ] Controllers Refactoring (0%)
- [ ] Bindings Update (0%)

### Testing
- [ ] Unit Tests (0%)
- [ ] Widget Tests (0%)
- [ ] Integration Tests (0%)

---

## 🚀 Next Steps

1. **Complete Domain Layer**
   - Add more entities (BatteryInfo, NetworkInfo, etc.)
   - Define all repository interfaces
   - Create all use cases

2. **Implement Data Layer**
   - Create all models
   - Implement data sources
   - Implement repositories

3. **Refactor Presentation**
   - Move files to new structure
   - Update controllers to use use cases
   - Update bindings with DI

4. **Add Tests**
   - Write unit tests for use cases
   - Write tests for repositories
   - Add widget tests

5. **Documentation**
   - Document all public APIs
   - Add code examples
   - Create architecture diagrams

---

**Last Updated**: November 10, 2025  
**Status**: 🟡 **IN PROGRESS** (30% Complete)

