import '../entities/device_info.dart';
import '../repositories/diagnostics_repository.dart';

/// Get Device Info Use Case
///
/// Encapsulates business logic for retrieving device information
/// Following Single Responsibility Principle and Use Case Pattern
class GetDeviceInfoUseCase {
  final IDiagnosticsRepository _repository;

  const GetDeviceInfoUseCase(this._repository);

  /// Execute the use case
  Future<DeviceInfo> call() async {
    try {
      return await _repository.getDeviceInfo();
    } catch (e) {
      // Log error or handle it appropriately
      rethrow;
    }
  }
}

