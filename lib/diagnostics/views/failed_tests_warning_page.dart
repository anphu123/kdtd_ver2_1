import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auto_diagnostics_controller.dart';
import '../model/diag_step.dart';

/// Màn hình cảnh báo khi có test không pass
class FailedTestsWarningPage extends StatelessWidget {
  final List<DiagStep> failedSteps;
  final int score;

  const FailedTestsWarningPage({
    super.key,
    required this.failedSteps,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade50,
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text('Cảnh báo - Thiết bị có vấn đề'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Warning Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.warning_rounded,
                size: 80,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 24),

            // Score
            Text(
              'Điểm: $score/100',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              _getGradeText(score),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),

            const SizedBox(height: 32),

            // Warning Message
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red, width: 2),
              ),
              child: Column(
                children: [
                  const Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 28),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Thiết bị có vấn đề nghiêm trọng',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _getWarningMessage(score),
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Failed Tests List
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.list_alt, color: Colors.red),
                      const SizedBox(width: 12),
                      Text(
                        'Các test không đạt (${failedSteps.length})',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...failedSteps.map((step) => _buildFailedItem(step)),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Recommendations
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange.shade400, Colors.orange.shade600],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.lightbulb, color: Colors.white, size: 28),
                      SizedBox(width: 12),
                      Text(
                        'Khuyến nghị',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ..._getRecommendations(score).map(
                    (rec) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              rec,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Action Buttons
            Column(
              children: [
                FilledButton.icon(
                  onPressed: () {
                    Get.back();
                    Get.find<AutoDiagnosticsController>().start();
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.blue,
                    minimumSize: const Size.fromHeight(56),
                  ),
                  icon: const Icon(Icons.refresh),
                  label: const Text(
                    'Kiểm tra lại',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                  ),
                  icon: const Icon(Icons.close),
                  label: const Text('Đóng', style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    // Navigate to result page anyway
                    Get.back();
                  },
                  child: const Text('Xem kết quả chi tiết →'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFailedItem(DiagStep step) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(_getIcon(step.code), color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (step.note != null && step.note!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    step.note!,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ],
            ),
          ),
          const Icon(Icons.cancel, color: Colors.red, size: 28),
        ],
      ),
    );
  }

  IconData _getIcon(String code) {
    switch (code) {
      case 'battery':
        return Icons.battery_alert;
      case 'screen':
        return Icons.phone_android;
      case 'touch':
        return Icons.touch_app;
      case 'camera':
        return Icons.camera_alt;
      case 'speaker':
        return Icons.volume_up;
      case 'mic':
        return Icons.mic;
      case 'ear':
        return Icons.hearing;
      case 'vibrate':
        return Icons.vibration;
      case 'keys':
        return Icons.keyboard;
      case 'wifi':
        return Icons.wifi;
      case 'bt':
        return Icons.bluetooth;
      case 'nfc':
        return Icons.nfc;
      case 'gps':
        return Icons.location_on;
      default:
        return Icons.error;
    }
  }

  String _getGradeText(int score) {
    if (score >= 70) return 'Khá';
    if (score >= 60) return 'Trung bình';
    return 'Yếu';
  }

  String _getWarningMessage(int score) {
    if (score >= 60) {
      return 'Thiết bị có một số vấn đề cần được khắc phục. '
          'Giá thu mua sẽ thấp hơn đáng kể. '
          'Khuyến nghị sửa chữa trước khi bán.';
    } else {
      return 'Thiết bị có nhiều vấn đề nghiêm trọng. '
          'Không khuyến nghị thu mua ở tình trạng hiện tại. '
          'Cần sửa chữa toàn diện hoặc bán phụ tùng.';
    }
  }

  List<String> _getRecommendations(int score) {
    if (score >= 60) {
      return [
        'Sửa chữa các vấn đề đã phát hiện',
        'Kiểm tra lại sau khi sửa',
        'Có thể tăng giá 20-30% sau sửa chữa',
        'Liên hệ trung tâm bảo hành',
      ];
    } else {
      return [
        'Cân nhắc chi phí sửa chữa vs giá bán',
        'Có thể bán phụ tùng riêng lẻ',
        'Tham khảo ý kiến chuyên gia',
        'Không nên sử dụng tiếp nếu có vấn đề an toàn',
      ];
    }
  }
}
