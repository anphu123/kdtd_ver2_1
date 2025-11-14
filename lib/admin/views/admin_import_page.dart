import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import '../services/excel_import_service.dart';
import '../controllers/admin_data_controller.dart';

class AdminImportPage extends StatefulWidget {
  const AdminImportPage({super.key});

  @override
  State<AdminImportPage> createState() => _AdminImportPageState();
}

class _AdminImportPageState extends State<AdminImportPage> {
  final _controller = Get.put(AdminDataController());

  bool _isImporting = false;
  String? _tcListPath;
  String? _tradeInPath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin - Import Data'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'Import Dữ liệu từ Excel',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Upload file Excel để cập nhật danh sách thiết bị và giá cả',
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 32),

            // TC_list Import
            _buildImportCard(
              title: 'TC_list (Danh sách thiết bị)',
              description: 'File chứa thông tin model, marketing name, giá gốc',
              icon: Icons.phone_android,
              color: Colors.blue,
              filePath: _tcListPath,
              onPickFile: () => _pickFile('tc_list'),
              onImport: () => _importTCList(),
            ),

            const SizedBox(height: 20),

            // TradeIn Prices Import
            _buildImportCard(
              title: 'Data_2Hand_Tradein (Giá thu mua)',
              description: 'File chứa giá thu mua theo tháng và grade',
              icon: Icons.attach_money,
              color: Colors.green,
              filePath: _tradeInPath,
              onPickFile: () => _pickFile('tradein'),
              onImport: () => _importTradeIn(),
            ),

            const SizedBox(height: 32),

            // Statistics
            Obx(() => _buildStatistics()),

            const SizedBox(height: 32),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _isImporting ? null : _importAll,
                    icon:
                        _isImporting
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : const Icon(Icons.upload_file),
                    label: Text(
                      _isImporting ? 'Đang import...' : 'Import tất cả',
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      minimumSize: const Size.fromHeight(50),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _controller.clearAllData,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Xóa dữ liệu'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      minimumSize: const Size.fromHeight(50),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImportCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required String? filePath,
    required VoidCallback onPickFile,
    required VoidCallback onImport,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // File path display
          if (filePath != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.insert_drive_file, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      filePath.split('/').last,
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    onPressed: () {
                      setState(() {
                        if (title.contains('TC_list')) {
                          _tcListPath = null;
                        } else {
                          _tradeInPath = null;
                        }
                      });
                    },
                  ),
                ],
              ),
            ),

          const SizedBox(height: 12),

          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onPickFile,
                  icon: const Icon(Icons.folder_open, size: 18),
                  label: const Text('Chọn file'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: filePath != null ? onImport : null,
                  icon: const Icon(Icons.upload, size: 18),
                  label: const Text('Import'),
                  style: FilledButton.styleFrom(backgroundColor: color),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thống kê dữ liệu',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Thiết bị',
                  '${_controller.devices.length}',
                  Icons.phone_android,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Giá tháng này',
                  '${_controller.currentMonthPrices.length}',
                  Icons.calendar_today,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Tổng giá',
                  '${_controller.allPrices.length}',
                  Icons.attach_money,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Future<void> _pickFile(String type) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          if (type == 'tc_list') {
            _tcListPath = result.files.single.path;
          } else {
            _tradeInPath = result.files.single.path;
          }
        });
      }
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Không thể chọn file: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _importTCList() async {
    if (_tcListPath == null) return;

    setState(() => _isImporting = true);

    try {
      final devices = await ExcelImportService.parseTCList(_tcListPath!);
      await _controller.importDevices(devices);

      Get.snackbar(
        'Thành công',
        'Đã import ${devices.length} thiết bị',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Import thất bại: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isImporting = false);
    }
  }

  Future<void> _importTradeIn() async {
    if (_tradeInPath == null) return;

    setState(() => _isImporting = true);

    try {
      final prices = await ExcelImportService.parseTradeInPrices(_tradeInPath!);
      await _controller.importPrices(prices);

      Get.snackbar(
        'Thành công',
        'Đã import ${prices.length} bản ghi giá',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Import thất bại: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isImporting = false);
    }
  }

  Future<void> _importAll() async {
    if (_tcListPath == null && _tradeInPath == null) {
      Get.snackbar(
        'Thông báo',
        'Vui lòng chọn ít nhất 1 file',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() => _isImporting = true);

    try {
      if (_tcListPath != null) {
        await _importTCList();
      }
      if (_tradeInPath != null) {
        await _importTradeIn();
      }

      Get.snackbar(
        'Hoàn thành',
        'Đã import tất cả dữ liệu',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isImporting = false);
    }
  }
}
