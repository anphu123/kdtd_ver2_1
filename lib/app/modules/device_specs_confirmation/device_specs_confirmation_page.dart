import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_colors.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_text_styles.dart';
import 'package:kdtd_ver2_1/app/data/model/device_cosmetic_survey.dart';
import 'package:kdtd_ver2_1/app/modules/diagnostics_home/diagnostics_home_controller.dart';
import 'package:kdtd_ver2_1/app/modules/pre_test_guide/pre_test_guide_page.dart';

/// Màn hình Trung Gian 1: Xác Nhận Cấu Hình RAM/ROM & Khảo Sát Ngoại Quan Sơ Bộ
/// Hiển thị ngay sau khi đọc xong thông số phần cứng cơ bản.
class DeviceSpecsConfirmationPage extends StatefulWidget {
  const DeviceSpecsConfirmationPage({super.key});

  @override
  State<DeviceSpecsConfirmationPage> createState() => _DeviceSpecsConfirmationPageState();
}

class _DeviceSpecsConfirmationPageState extends State<DeviceSpecsConfirmationPage> {
  final controller = Get.find<DiagnosticsHomeController>();

  BodyCondition _body = BodyCondition.pristine;
  ScreenCondition _screen = ScreenCondition.flawless;
  AccountStatus _account = AccountStatus.readyToLogOut;

  @override
  void initState() {
    super.initState();
    _body = controller.cosmeticSurvey.value.body;
    _screen = controller.cosmeticSurvey.value.screen;
    _account = controller.cosmeticSurvey.value.account;
  }

  void _saveSurvey() {
    controller.cosmeticSurvey.value = DeviceCosmeticSurvey(
      body: _body,
      screen: _screen,
      account: _account,
    );
  }

  String _formatRam() {
    final ramInfo = controller.info['ram'] as Map<String, dynamic>?;
    final total = ramInfo?['totalBytes'];
    if (total is num) {
      final gb = (total / (1024 * 1024 * 1024)).round();
      return '$gb GB';
    }
    return '8 GB';
  }

  String _formatRom() {
    final romInfo = controller.info['rom'] as Map<String, dynamic>?;
    final total = romInfo?['totalBytes'];
    if (total is num) {
      final gb = (total / (1024 * 1024 * 1024)).round();
      return '$gb GB';
    }
    return '128 GB';
  }

  String _formatBattery() {
    final batteryInfo = controller.info['battery'] as Map<String, dynamic>?;
    final level = batteryInfo?['level'];
    if (level != null) {
      return '$level%';
    }
    return 'Tốt (≥85%)';
  }

  @override
  Widget build(BuildContext context) {
    final displayName = controller.marketingName.isNotEmpty && controller.marketingName != '-'
        ? controller.marketingName
        : (controller.modelName.isNotEmpty && controller.modelName != '-'
            ? controller.modelName
            : 'Thiết bị của bạn');

    final origin = controller.origin;
    final brand = controller.brand.isNotEmpty ? controller.brand : 'Chính hãng';

    return Scaffold(
      backgroundColor: AppColors.tradeInSurfaceBg,
      appBar: AppBar(
        backgroundColor: AppColors.tradeInNavy,
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Xác Nhận Cấu Hình Thiết Bị',
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
            // 1. Hero Device Specs Card
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.tradeInEmerald.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check_circle_rounded, color: AppColors.tradeInEmerald, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ĐÃ QUÉT CẤU HÌNH THÀNH CÔNG',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.tradeInEmerald,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              displayName,
                              style: AppTextStyles.titleLarge.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Divider(color: AppColors.white12, height: 1),
                  const SizedBox(height: 16),

                  // 2x2 Specs Grid
                  Row(
                    children: [
                      Expanded(child: _buildSpecItem(Icons.memory_rounded, 'Bộ nhớ RAM', _formatRam())),
                      Expanded(child: _buildSpecItem(Icons.storage_rounded, 'Bộ nhớ trong', _formatRom())),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildSpecItem(Icons.battery_charging_full_rounded, 'Tình trạng Pin', _formatBattery())),
                      Expanded(child: _buildSpecItem(Icons.verified_outlined, 'Thương hiệu & Xuất xứ', '$brand • $origin')),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. Pre-valuation & Trade-In Voucher Teaser
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.tradeInGoldLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.tradeInGold.withValues(alpha: 0.6)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.stars_rounded, color: AppColors.tradeInGoldDark, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        'Định Giá Thu Cũ Ước Tính',
                        style: AppTextStyles.titleSmall.copyWith(
                          color: AppColors.tradeInGoldDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Khoảng giá thu mua dự kiến:',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.tradeInNavy,
                        ),
                      ),
                      Text(
                        '6.500.000đ - 9.800.000đ',
                        style: AppTextStyles.titleSmall.copyWith(
                          color: AppColors.tradeInNavy,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.card_giftcard, color: AppColors.tradeInGoldDark, size: 16),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Tặng thêm voucher tới 2.000.000đ khi lên đời máy mới hôm nay!',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.tradeInGoldDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 3. Quick Cosmetic Survey Section
            Text(
              'Khảo Sát Ngoại Quan Thực Tế',
              style: AppTextStyles.sectionHeader.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.tradeInNavy,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Chọn nhanh tình trạng máy bên ngoài để hệ thống tính toán giá thu sát thực tế nhất:',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.tradeInSlate),
            ),
            const SizedBox(height: 14),

            // Question A: Body & Frame
            _buildSurveyQuestion(
              title: '1. Thân máy & viền kim loại',
              options: BodyCondition.values.map((item) {
                final isSelected = _body == item;
                return _buildOptionChip(
                  label: item.label,
                  description: item.description,
                  isSelected: isSelected,
                  onTap: () {
                    setState(() => _body = item);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 14),

            // Question B: Screen Glass
            _buildSurveyQuestion(
              title: '2. Mặt kính màn hình hiển thị',
              options: ScreenCondition.values.map((item) {
                final isSelected = _screen == item;
                return _buildOptionChip(
                  label: item.label,
                  description: item.description,
                  isSelected: isSelected,
                  onTap: () {
                    setState(() => _screen = item);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 14),

            // Question C: Account Status
            _buildSurveyQuestion(
              title: '3. Tài khoản iCloud / Google Account',
              options: AccountStatus.values.map((item) {
                final isSelected = _account == item;
                return _buildOptionChip(
                  label: item.label,
                  description: item.description,
                  isSelected: isSelected,
                  onTap: () {
                    setState(() => _account = item);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 28),

            // 4. Primary Actions
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
                  _saveSurvey();
                  Get.to(() => const PreTestPreparationGuidePage());
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
                  'Tiếp Tục: Chuẩn Bị Kiểm Tra Chức Năng',
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
                  'Quay về trang chủ',
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

  Widget _buildSpecItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.tradeInBlueLight, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.tradeInSlateLight,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.titleSmall.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSurveyQuestion({
    required String title,
    required List<Widget> options,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.tradeInBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.titleSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.tradeInNavy,
            ),
          ),
          const SizedBox(height: 12),
          ...options,
        ],
      ),
    );
  }

  Widget _buildOptionChip({
    required String label,
    required String description,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.tradeInBlue.withValues(alpha: 0.08) : AppColors.tradeInSurfaceBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppColors.tradeInBlue : AppColors.tradeInBorder,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: isSelected ? AppColors.tradeInBlue : AppColors.neutralGrey,
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        color: isSelected ? AppColors.tradeInBlue : AppColors.tradeInNavy,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.tradeInSlate,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
