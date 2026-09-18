/// Hằng số dùng trong trang xác nhận cấu hình thiết bị (DeviceSpecsConfirmation).
class DeviceSpecsConfirmationConstants {
  DeviceSpecsConfirmationConstants._();

  /// Số byte trong 1 GiB, dùng để quy đổi RAM/ROM sang GB hiển thị.
  static const int bytesPerGibibyte = 1024 * 1024 * 1024;

  /// Giá trị RAM mặc định khi không đọc được từ thiết bị.
  static const String defaultRamLabel = '8 GB';

  /// Giá trị ROM mặc định khi không đọc được từ thiết bị.
  static const String defaultRomLabel = '128 GB';
}
