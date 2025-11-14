import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auto_diagnostics_controller.dart';
import '../model/diag_step.dart';
import '../services/price_estimation_service.dart';
import 'widgets/phone_3d_widget.dart';
import 'widgets/purchase_action_buttons.dart';

class DiagnosticResultPage extends GetView<AutoDiagnosticsController> {
  const DiagnosticResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    final total = controller.steps.length;
    final passed = controller.passedCount.value;
    final failed = controller.failedCount.value;
    final skipped = controller.skippedCount.value;
    final score = total > 0 ? (passed * 100 / total).round() : 0;
    final grade = _getGrade(score);
    final gradeColor = _getGradeColor(score);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text('Kết quả kiểm định'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 3D Phone Display
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [gradeColor, gradeColor.withValues(alpha: 0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: gradeColor.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // 3D Phone Widget
                  SizedBox(
                    height: 450,
                    child: Center(
                      child: Phone3DWidget(
                        score: score,
                        modelName: controller.modelName,
                        brand: controller.brand,
                        color: gradeColor,
                        useRealImage: false, // Set true khi có hình ảnh thực
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Xếp loại: $grade',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getGradeDescription(score),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '👆 Vuốt để xoay điện thoại',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

            // Price Estimation Card
            FutureBuilder<PriceEstimate?>(
              future: _estimatePrice(score),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(child: CircularProgressIndicator()),
                  );
                }

                if (!snapshot.hasData) return const SizedBox.shrink();

                final priceEstimate = snapshot.data!;
                return _buildPriceCard(priceEstimate);
              },
            ),

            // Device Info Card
            _buildInfoCard(
              title: 'Thông tin thiết bị',
              icon: Icons.phone_android,
              children: [
                _buildInfoRow('Model', controller.modelName),
                _buildInfoRow('Hãng', controller.brand),
                _buildInfoRow('Tên thương mại', controller.marketingName),
                _buildInfoRow('Xuất xứ', controller.origin),
                if (controller.info['ram'] != null)
                  _buildInfoRow(
                    'RAM',
                    '${controller.info['ram']['totalGb']} GB',
                  ),
                if (controller.info['rom'] != null)
                  _buildInfoRow(
                    'ROM',
                    '${controller.info['rom']['totalGb']} GB',
                  ),
              ],
            ),

            // Summary Card
            _buildInfoCard(
              title: 'Tổng kết',
              icon: Icons.assessment,
              children: [
                _buildStatRow('Tổng số test', '$total', Colors.blue),
                _buildStatRow('Đạt', '$passed', Colors.green),
                _buildStatRow('Không đạt', '$failed', Colors.red),
                _buildStatRow('Bỏ qua', '$skipped', Colors.orange),
              ],
            ),

            // Test Results by Category
            _buildCategoryResults('Phần cứng', [
              'battery',
              'screen',
              'touch',
              'camera',
              'speaker',
              'mic',
              'ear',
              'vibrate',
              'keys',
            ]),

            _buildCategoryResults('Cảm biến', [
              'accel',
              'gyro',
              'mag',
              'light',
              'prox',
            ]),

            _buildCategoryResults('Kết nối', [
              'wifi',
              'bt',
              'nfc',
              'gps',
              'mobile',
            ]),

            _buildCategoryResults('Bảo mật', ['bio']),

            const SizedBox(height: 20),

            // Purchase Action Buttons
            FutureBuilder<PriceEstimate?>(
              future: _estimatePrice(score),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  return PurchaseActionButtons(
                    estimatedPrice: snapshot.data!.estimatedPrice,
                    modelName: controller.modelName,
                    brand: controller.brand,
                    score: score,
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            // Secondary Actions
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Get.back();
                        controller.start(); // Restart
                      },
                      icon: const Icon(Icons.refresh, size: 20),
                      label: const Text('Kiểm tra lại'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        controller.printTestResults();
                        Get.snackbar(
                          'Thành công',
                          'Đã in kết quả ra console',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      },
                      icon: const Icon(Icons.print, size: 20),
                      label: const Text('In kết quả'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
              Icon(icon, color: Colors.blue),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryResults(String category, List<String> codes) {
    final categorySteps =
        controller.steps.where((s) => codes.contains(s.code)).toList();

    if (categorySteps.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Text(
            category,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...categorySteps.map((step) => _buildTestResultItem(step)),
        ],
      ),
    );
  }

  Widget _buildTestResultItem(DiagStep step) {
    IconData icon;
    Color color;
    String statusText;

    switch (step.status) {
      case DiagStatus.passed:
        icon = Icons.check_circle;
        color = Colors.green;
        statusText = 'Đạt';
        break;
      case DiagStatus.failed:
        icon = Icons.cancel;
        color = Colors.red;
        statusText = 'Không đạt';
        break;
      case DiagStatus.skipped:
        icon = Icons.remove_circle_outline;
        color = Colors.orange;
        statusText = 'Bỏ qua';
        break;
      default:
        icon = Icons.help_outline;
        color = Colors.grey;
        statusText = 'Chưa test';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              statusText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<PriceEstimate?> _estimatePrice(int score) async {
    try {
      final ramGb = controller.info['ram']?['totalGb'] as int? ?? 4;
      final romGb = controller.info['rom']?['totalGb'] as int? ?? 64;

      return await PriceEstimationService.estimatePrice(
        modelName: controller.modelName,
        brand: controller.brand,
        score: score,
        ramGb: ramGb,
        romGb: romGb,
        origin: controller.origin,
      );
    } catch (e) {
      print('Error estimating price: $e');
      return null;
    }
  }

  Widget _buildPriceCard(PriceEstimate priceEstimate) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.attach_money, color: Colors.white, size: 32),
              const SizedBox(width: 12),
              const Text(
                'Giá thu mua ước tính',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Estimated Price
          Center(
            child: Column(
              children: [
                Text(
                  priceEstimate.formattedEstimatedPrice,
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Khoảng: ${priceEstimate.priceRange}',
                  style: const TextStyle(fontSize: 16, color: Colors.white70),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Confidence
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Độ tin cậy: ${(priceEstimate.confidence * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Recommendation
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lightbulb, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    priceEstimate.recommendation,
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

          // Price Factors
          if (priceEstimate.factors.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Yếu tố ảnh hưởng:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...priceEstimate.factors.map(
              (factor) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      factor.impact == 'positive'
                          ? Icons.arrow_upward
                          : factor.impact == 'negative'
                          ? Icons.arrow_downward
                          : Icons.remove,
                      color:
                          factor.impact == 'positive'
                              ? Colors.lightGreenAccent
                              : factor.impact == 'negative'
                              ? Colors.redAccent
                              : Colors.white70,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${factor.name}: ${factor.description}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Note
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.white70, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Giá chỉ mang tính chất tham khảo. Giá thực tế có thể thay đổi.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getGrade(int score) {
    if (score >= 90) return 'Xuất sắc';
    if (score >= 80) return 'Tốt';
    if (score >= 70) return 'Khá';
    if (score >= 60) return 'Trung bình';
    return 'Yếu';
  }

  Color _getGradeColor(int score) {
    if (score >= 90) return const Color(0xFF4CAF50); // Green
    if (score >= 80) return const Color(0xFF2196F3); // Blue
    if (score >= 70) return const Color(0xFFFF9800); // Orange
    if (score >= 60) return const Color(0xFFFFC107); // Amber
    return const Color(0xFFF44336); // Red
  }

  String _getGradeDescription(int score) {
    if (score >= 90) {
      return 'Thiết bị trong tình trạng xuất sắc!\nTất cả các chức năng hoạt động tốt.';
    }
    if (score >= 80) {
      return 'Thiết bị hoạt động tốt.\nChỉ có một vài vấn đề nhỏ.';
    }
    if (score >= 70) {
      return 'Thiết bị ở mức khá.\nCó một số chức năng cần kiểm tra.';
    }
    if (score >= 60) {
      return 'Thiết bị ở mức trung bình.\nNhiều chức năng cần được sửa chữa.';
    }
    return 'Thiết bị có nhiều vấn đề.\nCần kiểm tra và sửa chữa kỹ lưỡng.';
  }
}
