import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_colors.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_text_styles.dart';
import 'package:kdtd_ver2_1/app/data/model/diag_step.dart';
import 'package:kdtd_ver2_1/app/modules/diagnostic_result/diagnostic_result_page.dart';
import 'package:kdtd_ver2_1/app/modules/diagnostics_home/diagnostics_home_controller.dart';

/// Màn hình thông báo phân hạng thiết bị khi có lỗi phần cứng (Hạng C / Hạng D)
/// Giúp khách hàng yên tâm rằng máy vẫn được thu cũ và trợ giá lên đời mới.
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
    final grade = score >= 60 ? 'C' : 'D';

    return Scaffold(
      backgroundColor: AppColors.tradeInSurfaceBg,
      appBar: AppBar(
        backgroundColor: AppColors.tradeInNavy,
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Kết Quả Phân Hạng Thu Cũ',
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Certificate / Grading Card
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.tradeInNavy, AppColors.tradeInDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.tradeInNavy.withValues(alpha: 0.15),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Grade & Score Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.tradeInGold.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.tradeInGold, width: 1.2),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.verified, color: AppColors.tradeInGold, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              'Phân Loại: Hạng $grade',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: AppColors.tradeInGold,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.tradeInDark,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Sức khỏe: $score/100',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.tradeInSlateLight,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Icon & Heading
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: AppColors.tradeInGold.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.tradeInGold.withValues(alpha: 0.4), width: 1.5),
                    ),
                    child: const Icon(
                      Icons.sync_alt_rounded,
                      color: AppColors.tradeInGold,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'Đủ Điều Kiện Thu Cũ Lên Đời',
                    style: AppTextStyles.titleLarge.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  Text(
                    'Mặc dù ghi nhận một số lỗi linh kiện (${failedSteps.length} mục), thiết bị vẫn được thẩm định thu mua theo chuẩn Hạng $grade kèm gói trợ giá đặc quyền!',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.tradeInSlateLight,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Subsidy Voucher Callout
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.tradeInGoldLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.tradeInGold.withValues(alpha: 0.6)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.tradeInGold.withValues(alpha: 0.25),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.card_giftcard, color: AppColors.tradeInGoldDark, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ưu Đãi Trợ Giá Lên Đời Hạng $grade',
                          style: AppTextStyles.titleSmall.copyWith(
                            color: AppColors.tradeInGoldDark,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Tặng thêm 1.500.000đ khi đổi sang iPhone 16 / Galaxy S24 Series.',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.tradeInNavy,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Failed Tests Details Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.tradeInBorder),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.assignment_late_outlined, color: AppColors.warning, size: 22),
                      const SizedBox(width: 10),
                      Text(
                        'Hạng mục ghi nhận lỗi (${failedSteps.length})',
                        style: AppTextStyles.sectionHeader.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Được khấu trừ hợp lý theo chính sách thu mua minh bạch, không ép giá:',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.tradeInSlate,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...failedSteps.map((step) => _buildFailedItem(step)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Trade-in benefits reassurance
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.tradeInNavy.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.tradeInNavy.withValues(alpha: 0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.check_circle_outline, color: AppColors.tradeInBlue, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Lợi ích khi lên đời ngay tại cửa hàng',
                        style: AppTextStyles.titleSmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.tradeInNavy,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildBulletPoint('Không cần chi tiền túi sửa chữa linh kiện hư hỏng'),
                  _buildBulletPoint('Hỗ trợ sao lưu dữ liệu sang máy mới an toàn 100%'),
                  _buildBulletPoint('Bù tiền chênh lệch trả góp 0% lãi suất linh hoạt'),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Action Buttons
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Primary: View Trade-In valuation & showroom
                Container(
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.tradeInBlue, AppColors.tradeInBlueLight],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.tradeInBlue.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Get.off(() => const DiagnosticResultPage());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.arrow_forward_rounded, color: AppColors.white, size: 20),
                    label: Text(
                      'Xem Định Giá & Chọn Máy Lên Đời',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Secondary: Retest
                OutlinedButton.icon(
                  onPressed: () {
                    Get.back();
                    Get.find<DiagnosticsHomeController>().startWithPermissionCheck();
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    side: const BorderSide(color: AppColors.tradeInNavy, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.refresh, color: AppColors.tradeInNavy, size: 20),
                  label: Text(
                    'Kiểm tra lại lần nữa',
                    style: AppTextStyles.titleSmall.copyWith(
                      color: AppColors.tradeInNavy,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Back to home
                TextButton(
                  onPressed: () => Get.back(),
                  child: Text(
                    'Quay về trang chủ',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.tradeInSlate,
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

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6, right: 10),
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
              color: AppColors.tradeInBlue,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.tradeInDark,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFailedItem(DiagStep step) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.tradeInSurfaceBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.tradeInBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(_getIcon(step.code), color: AppColors.warning, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.tradeInDark,
                  ),
                ),
                if (step.note != null && step.note!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    step.note!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.tradeInSlate,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.warningLight.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'Cần bảo dưỡng',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.tradeInGoldDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
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
        return Icons.info_outline;
    }
  }
}
