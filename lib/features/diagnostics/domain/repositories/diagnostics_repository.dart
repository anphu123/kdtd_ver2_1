import '../entities/diagnostic_step.dart';
import '../entities/device_info.dart';

/// Diagnostics Repository Interface
///
/// Defines contract for diagnostics data operations
/// Following Repository Pattern and Dependency Inversion Principle
abstract class IDiagnosticsRepository {
  /// Get device information
  Future<DeviceInfo> getDeviceInfo();

  /// Get all diagnostic steps
  Future<List<DiagnosticStep>> getAllSteps();

  /// Execute a specific diagnostic step
  Future<DiagnosticStep> executeStep(DiagnosticStep step);

  /// Execute all automated steps
  Future<List<DiagnosticStep>> executeAllAutoSteps();

  /// Save diagnostic results
  Future<bool> saveResults(List<DiagnosticStep> steps);

  /// Get diagnostic history
  Future<List<Map<String, dynamic>>> getHistory();

  /// Clear diagnostic history
  Future<bool> clearHistory();
}

