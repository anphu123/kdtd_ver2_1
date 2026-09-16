import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_colors.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_text_styles.dart';
import 'package:kdtd_ver2_1/app/modules/diagnostics_home/diagnostics_home_controller.dart';

/// Màn hình Trung Gian 2: Hướng Dẫn Chuẩn Bị Trước Khi Kiểm Tra Tính Năng
/// Giúp khách hàng chuẩn bị máy (tăng âm lượng, tháo ốp/sạc, lau camera)
/// trước khi tiến hành các bài test chức năng.
class PreTestPreparationGuidePage extends StatelessWidget {
  const PreTestPreparationGuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DiagnosticsHomeController>();

    return Scaffold(
      backgroundColor: AppColors.tradeInSurfaceBg,
      appBar: AppBar(
        backgroundColor: AppColors.tradeInNavy,
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Hướng Dẫn Chuẩn Bị',
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.white, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Header Banner
            Container(
              padding: const EdgeInsets.all(20),
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
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: AppColors.tradeInBlue.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.tradeInBlue.withValues(alpha: 0.4), width: 1.5),
                    ),
                    child: const Icon(
                      Icons.checklist_rounded,
                      color: AppColors.tradeInBlueLight,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Chuẩn Bị Thiết Bị (~60s)',
                    style: AppTextStyles.titleLarge.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Thực hiện nhanh 5 bước dưới đây để các bài test âm thanh, cảm ứng, camera và cảm biến cho kết quả định giá chính xác nhất.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.tradeInSlateLight,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // 2. Step-by-Step Checklist
            Text(
              'Các Bước Cần Thực Hiện',
              style: AppTextStyles.sectionHeader.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.tradeInNavy,
              ),
            ),
            const SizedBox(height: 12),

            _buildGuideCard(
              index: '1',
              icon: Icons.volume_up_rounded,
              title: 'Bật loa & Tăng âm lượng tối đa',
              description: 'Gạt phím im lặng (nếu có) và bấm tăng âm lượng lên mức cao nhất để kiểm tra màng loa và micro phản hồi.',
              iconColor: AppColors.tradeInBlue,
            ),
            _buildGuideCard(
              index: '2',
              icon: Icons.power_off_rounded,
              title: 'Tháo dây sạc & tai nghe',
              description: 'Đảm bảo không cắm phụ kiện để hệ thống kiểm tra tình trạng cổng cắm và phát âm thanh qua loa độc lập.',
              iconColor: AppColors.tradeInGoldDark,
            ),
            _buildGuideCard(
              index: '3',
              icon: Icons.phone_android_rounded,
              title: 'Tháo ốp lưng bảo vệ',
              description: 'Giúp quá trình đo độ rung haptic, sạc không dây và cảm biến tiệm cận không bị ảnh hưởng.',
              iconColor: AppColors.tradeInEmerald,
            ),
            _buildGuideCard(
              index: '4',
              icon: Icons.cleaning_services_rounded,
              title: 'Lau sạch camera & màn hình',
              description: 'Dùng khăn mềm lau sạch ống kính camera và bề mặt cảm ứng để quá trình kiểm tra lấy nét và cảm ứng không bị chạm ảo.',
              iconColor: AppColors.purple,
            ),
            _buildGuideCard(
              index: '5',
              icon: Icons.wifi_rounded,
              title: 'Giữ kết nối Wi-Fi & Bluetooth',
              description: 'Đảm bảo máy đã bật Wi-Fi và Bluetooth để ứng dụng kiểm tra độ nhạy của các ăng-ten kết nối không dây.',
              iconColor: AppColors.tradeInBlue,
            ),

            const SizedBox(height: 12),

            // 3. Security Assurance Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.tradeInEmerald.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.tradeInEmerald.withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.security_rounded, color: AppColors.tradeInEmerald, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Bảo mật 100%: Quá trình thẩm định chỉ kiểm tra phần cứng và hoàn toàn không truy cập dữ liệu cá nhân hay hình ảnh của bạn.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.tradeInNavy,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 4. Primary CTA: Start functional testing
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
                  controller.startFunctionalDiagnostics();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.play_arrow_rounded, color: AppColors.white, size: 24),
                label: Text(
                  'Bắt Đầu Kiểm Tra Chức Năng Ngay',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            Center(
              child: TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  'Quay lại bước trước',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.tradeInSlate,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideCard({
    required String index,
    required IconData icon,
    required String title,
    required String description,
    required Color iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.tradeInBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.tradeInNavy,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.tradeInSlate,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
