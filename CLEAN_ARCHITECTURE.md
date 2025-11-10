# 🏗️ Clean Code Architecture - KDTD Project

## 📋 Table of Contents
1. [Architecture Overview](#architecture-overview)
2. [Project Structure](#project-structure)
3. [Clean Code Principles](#clean-code-principles)
4. [Design Patterns](#design-patterns)
5. [Best Practices](#best-practices)

---

## 🎯 Architecture Overview

Dự án được tổ chức theo **Clean Architecture** + **Feature-First** approach với các nguyên tắc SOLID.

### Core Layers:

```
┌─────────────────────────────────────────┐
│         Presentation Layer              │
│  (UI, Pages, Widgets, Controllers)      │
├─────────────────────────────────────────┤
│          Domain Layer                   │
│  (Entities, UseCases, Repositories)     │
├─────────────────────────────────────────┤
│           Data Layer                    │
│  (Models, DataSources, Implementations) │
├─────────────────────────────────────────┤
│          Core Layer                     │
│  (Constants, Theme, Routes, Utils)      │
└─────────────────────────────────────────┘
```

---

## 📁 Project Structure

### New Clean Architecture Structure:

```
lib/
├── core/                           # Core application files
│   ├── constants/                  # App-wide constants
│   │   └── app_constants.dart      # ✅ Centralized constants
│   ├── theme/                      # Theme configuration
│   │   ├── app_theme.dart          # ✅ Main theme
│   │   ├── app_colors.dart         # ✅ Color palette
│   │   └── app_text_styles.dart    # ✅ Typography
│   ├── routes/                     # Navigation
│   │   ├── app_routes.dart         # ✅ Route constants
│   │   └── app_pages.dart          # ✅ Route configuration
│   ├── utils/                      # Utility functions
│   ├── extensions/                 # Dart extensions
│   └── errors/                     # Error handling
│
├── features/                       # Feature modules
│   ├── diagnostics/                # Diagnostics feature
│   │   ├── domain/                 # Domain layer
│   │   │   ├── entities/           # Business entities
│   │   │   │   ├── diagnostic_step.dart      # ✅ Step entity
│   │   │   │   └── device_info.dart          # ✅ Device entity
│   │   │   ├── repositories/       # Repository interfaces
│   │   │   │   └── diagnostics_repository.dart # ✅ Interface
│   │   │   └── usecases/           # Business logic
│   │   │       ├── get_device_info_usecase.dart # ✅ Use case
│   │   │       └── execute_diagnostic_step_usecase.dart # ✅ Use case
│   │   ├── data/                   # Data layer
│   │   │   ├── models/             # Data models
│   │   │   ├── datasources/        # Data sources
│   │   │   └── repositories/       # Repository implementations
│   │   └── presentation/           # Presentation layer
│   │       ├── pages/              # Screen pages
│   │       ├── widgets/            # Reusable widgets
│   │       ├── controllers/        # GetX controllers
│   │       └── bindings/           # GetX bindings
│   │
│   ├── onboarding/                 # Onboarding feature
│   │   ├── domain/
│   │   ├── data/
│   │   └── presentation/
│   │
│   └── settings/                   # Settings feature
│       ├── domain/
│       ├── data/
│       └── presentation/
│
└── main.dart                       # App entry point
```

---

## 🎨 Clean Code Principles

### 1. SOLID Principles

#### ✅ Single Responsibility Principle (SRP)
```dart
// ❌ Bad: God class doing everything
class DiagnosticsController {
  void getDeviceInfo() {}
  void executeTests() {}
  void saveResults() {}
  void sendToServer() {}
  void generateReport() {}
}

// ✅ Good: Separated responsibilities
class GetDeviceInfoUseCase { ... }
class ExecuteTestsUseCase { ... }
class SaveResultsUseCase { ... }
```

#### ✅ Open/Closed Principle (OCP)
```dart
// ✅ Open for extension, closed for modification
abstract class IDiagnosticsRepository {
  Future<DeviceInfo> getDeviceInfo();
}

class LocalDiagnosticsRepository implements IDiagnosticsRepository { ... }
class RemoteDiagnosticsRepository implements IDiagnosticsRepository { ... }
```

#### ✅ Liskov Substitution Principle (LSP)
```dart
// ✅ Subtypes can replace base types
IDiagnosticsRepository repo = LocalDiagnosticsRepository();
// or
IDiagnosticsRepository repo = RemoteDiagnosticsRepository();
```

#### ✅ Interface Segregation Principle (ISP)
```dart
// ✅ Specific interfaces instead of fat interfaces
abstract class IDeviceInfoProvider {
  Future<DeviceInfo> getDeviceInfo();
}

abstract class IDiagnosticExecutor {
  Future<DiagnosticStep> executeStep(DiagnosticStep step);
}
```

#### ✅ Dependency Inversion Principle (DIP)
```dart
// ✅ Depend on abstractions, not concretions
class DiagnosticsController {
  final IDiagnosticsRepository _repository; // Interface, not implementation
  
  DiagnosticsController(this._repository);
}
```

### 2. Clean Code Guidelines

#### ✅ Meaningful Names
```dart
// ❌ Bad
var d; // What is d?
var list1; // What kind of list?

// ✅ Good
var deviceInfo;
var diagnosticSteps;
```

#### ✅ Functions Should Do One Thing
```dart
// ❌ Bad
void processData() {
  // Fetch data
  // Validate data
  // Transform data
  // Save data
  // Send notification
}

// ✅ Good
Future<Data> fetchData() { ... }
bool validateData(Data data) { ... }
Data transformData(Data data) { ... }
Future<void> saveData(Data data) { ... }
```

#### ✅ Small Functions
```dart
// ✅ Functions should be small (< 20 lines)
Future<DeviceInfo> getDeviceInfo() async {
  try {
    return await _repository.getDeviceInfo();
  } catch (e) {
    rethrow;
  }
}
```

#### ✅ No Side Effects
```dart
// ❌ Bad: Modifies external state
int calculateTotal(List<int> items) {
  globalCounter++; // Side effect!
  return items.reduce((a, b) => a + b);
}

// ✅ Good: Pure function
int calculateTotal(List<int> items) {
  return items.reduce((a, b) => a + b);
}
```

### 3. DRY Principle (Don't Repeat Yourself)

```dart
// ❌ Bad: Repeated code
void showSuccessMessage() {
  Get.snackbar('Success', 'Operation completed', backgroundColor: Colors.green);
}

void showErrorMessage() {
  Get.snackbar('Error', 'Operation failed', backgroundColor: Colors.red);
}

// ✅ Good: Extracted common logic
void showMessage(String title, String message, Color color) {
  Get.snackbar(title, message, backgroundColor: color);
}
```

---

## 🎯 Design Patterns Used

### 1. Repository Pattern
```dart
abstract class IDiagnosticsRepository {
  Future<DeviceInfo> getDeviceInfo();
}

class DiagnosticsRepositoryImpl implements IDiagnosticsRepository {
  @override
  Future<DeviceInfo> getDeviceInfo() async {
    // Implementation
  }
}
```

### 2. Use Case Pattern
```dart
class GetDeviceInfoUseCase {
  final IDiagnosticsRepository _repository;
  
  const GetDeviceInfoUseCase(this._repository);
  
  Future<DeviceInfo> call() async {
    return await _repository.getDeviceInfo();
  }
}
```

### 3. Factory Pattern
```dart
class DiagnosticStep {
  factory DiagnosticStep.fromJson(Map<String, dynamic> json) {
    return DiagnosticStep(
      id: json['id'],
      code: json['code'],
      // ...
    );
  }
}
```

### 4. Singleton Pattern
```dart
class AppConstants {
  AppConstants._(); // Private constructor
  
  static const String appName = 'KDTD';
}
```

### 5. Observer Pattern (via GetX)
```dart
class DiagnosticsController extends GetxController {
  final _steps = <DiagnosticStep>[].obs; // Observable
  
  List<DiagnosticStep> get steps => _steps;
}
```

---

## 🚀 Best Practices

### 1. File Naming
```
✅ snake_case for files:
   - diagnostic_step.dart
   - auto_diagnostics_page.dart
   
✅ PascalCase for classes:
   - DiagnosticStep
   - AutoDiagnosticsPage
```

### 2. Import Organization
```dart
// 1. Dart imports
import 'dart:async';
import 'dart:math';

// 2. Flutter imports
import 'package:flutter/material.dart';

// 3. Package imports
import 'package:get/get.dart';

// 4. Project imports
import '../domain/entities/diagnostic_step.dart';
import '../domain/usecases/get_device_info_usecase.dart';
```

### 3. Const Constructors
```dart
// ✅ Always use const when possible
const SizedBox(height: 16);
const EdgeInsets.all(8);
```

### 4. Null Safety
```dart
// ✅ Use null-aware operators
String? name;
final displayName = name ?? 'Unknown';

// ✅ Use null-aware cascades
list?.add(item);

// ✅ Use null assertion only when sure
final certainValue = nullableValue!;
```

### 5. Error Handling
```dart
// ✅ Always handle errors
try {
  final result = await fetchData();
  return result;
} on NetworkException catch (e) {
  // Handle network error
  return handleNetworkError(e);
} catch (e) {
  // Handle generic error
  return handleGenericError(e);
}
```

### 6. Comments
```dart
// ✅ Document public APIs
/// Gets device information
/// 
/// Returns [DeviceInfo] with model, brand, and platform details
/// Throws [DeviceException] if device info cannot be retrieved
Future<DeviceInfo> getDeviceInfo() async { ... }

// ✅ Explain complex logic
// Calculate progress based on completed/total ratio
// Ensures minimum 0% and maximum 100%
final progress = (completed / total).clamp(0.0, 1.0);
```

### 7. Testing
```dart
// ✅ Write unit tests for use cases
test('GetDeviceInfoUseCase returns device info', () async {
  // Arrange
  final mockRepo = MockDiagnosticsRepository();
  final useCase = GetDeviceInfoUseCase(mockRepo);
  
  // Act
  final result = await useCase();
  
  // Assert
  expect(result, isA<DeviceInfo>());
});
```

---

## 📊 Code Quality Metrics

### Target Metrics:
- **Code Coverage**: > 80%
- **Cyclomatic Complexity**: < 10
- **Lines per Method**: < 20
- **Methods per Class**: < 10
- **Dependencies per Class**: < 5

### Tools:
```bash
# Code analysis
flutter analyze

# Code metrics
flutter pub run dart_code_metrics:metrics

# Test coverage
flutter test --coverage
```

---

## 🎓 Resources

### Books:
1. **Clean Code** - Robert C. Martin
2. **Clean Architecture** - Robert C. Martin
3. **Refactoring** - Martin Fowler
4. **Design Patterns** - Gang of Four

### Articles:
- [Flutter Best Practices](https://flutter.dev/docs/development/ui/best-practices)
- [GetX Pattern](https://github.com/kauemurakami/getx_pattern)
- [SOLID Principles](https://en.wikipedia.org/wiki/SOLID)

---

## ✅ Migration Checklist

- [x] Create core/ directory structure
- [x] Define constants and theme
- [x] Setup routes properly
- [x] Create domain layer (entities, repositories, use cases)
- [ ] Implement data layer (models, data sources)
- [ ] Refactor presentation layer (pages, widgets, controllers)
- [ ] Add dependency injection
- [ ] Write unit tests
- [ ] Add integration tests
- [ ] Document public APIs
- [ ] Setup CI/CD

---

**Version**: 2.1.0  
**Last Updated**: November 10, 2025  
**Architecture**: Clean Architecture + Feature-First  
**State Management**: GetX  
**Status**: ✅ **IN PROGRESS**

