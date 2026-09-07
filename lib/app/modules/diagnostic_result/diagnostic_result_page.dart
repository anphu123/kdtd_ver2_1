import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_colors.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_text_styles.dart';
import 'package:kdtd_ver2_1/app/data/model/diag_step.dart';
import 'package:kdtd_ver2_1/app/data/model/upgrade_device_option.dart';
import 'package:kdtd_ver2_1/app/data/services/price_estimation_service.dart';
import 'package:kdtd_ver2_1/app/modules/diagnostics_home/diagnostics_home_controller.dart';

/// Trang kết quả thẩm định & Lên đời máy mới (Trade-In & Upgrade)
class DiagnosticResultPage extends StatefulWidget {
  const DiagnosticResultPage({super.key});

  @override
  State<DiagnosticResultPage> createState() => _DiagnosticResultPageState();
}

class _DiagnosticResultPageState extends State<DiagnosticResultPage> {
  final DiagnosticsHomeController controller = Get.find<DiagnosticsHomeController>();
  late UpgradeDeviceOption selectedOption;
  final List<UpgradeDeviceOption> upgradeOptions = UpgradeDeviceOption.defaultOptions;
  PriceEstimate? priceEstimate;
  bool isLoadingPrice = true;

  @override
  void initState() {
    super.initState();
    selectedOption = upgradeOptions.first;
    _fetchPriceEstimate();
  }

  Future<void> _fetchPriceEstimate() async {
    final total = controller.steps.length;
    final passed = controller.passedCount.value;
    final score = total > 0 ? (passed * 100 / total).round() : 0;
    final ramGb = controller.info['ram']?['totalGb'] as int? ?? 4;
    final romGb = controller.info['rom']?['totalGb'] as int? ?? 64;

    try {
      final estimate = await PriceEstimationService.estimatePrice(
        modelName: controller.modelName,
        brand: controller.brand,
        score: score,
        ramGb: ramGb,
        romGb: romGb,
        origin: controller.origin,
      );
      if (mounted) {
        setState(() {
          priceEstimate = estimate;
          isLoadingPrice = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoadingPrice = false;
        });
      }
    }
  }

  String _formatPrice(int amount) {
    return '${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} đ';
  }

  @override
  Widget build(BuildContext context) {
    final total = controller.steps.length;
    final passed = controller.passedCount.value;
    final failed = controller.failedCount.value;
    final score = total > 0 ? (passed * 100 / total).round() : 0;

    final baseTradeInValue = priceEstimate?.estimatedPrice ?? 5000000;
    final totalSubsidy = selectedOption.subsidyAmount;
    final totalValuation = baseTradeInValue + totalSubsidy;
    final topUpAmount = selectedOption.calculateTopUp(baseTradeInValue);

    return Scaffold(
      backgroundColor: AppColors.tradeInSurfaceBg,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.tradeInNavy, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Thẩm Định & Lên Đời Máy',
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.tradeInNavy,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: AppColors.tradeInSlate, size: 22),
            onPressed: () => _shareTradeInCertificate(baseTradeInValue, totalValuation, topUpAmount),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Certificate Hero Card
                _buildCertificateCard(score, baseTradeInValue, totalSubsidy, totalValuation),

                const SizedBox(height: 24),

                // 2. Interactive Upgrade Showroom
                _buildUpgradeShowroom(baseTradeInValue, topUpAmount),

                const SizedBox(height: 24),

                // 3. Trade-in Process 3 steps
                _buildTradeInStepsCard(),

                const SizedBox(height: 24),

                // 4. Diagnostic Checklist Summary
                _buildDiagnosticBreakdown(total, passed, failed),

                const SizedBox(height: 20),

                // Secondary actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Get.back();
                          controller.startWithPermissionCheck();
                        },
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('Thẩm định lại'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          controller.printTestResults();
                          Get.snackbar('Đã in', 'Đã xuất thông số thẩm định ra console');
                        },
                        icon: const Icon(Icons.print_outlined, size: 18),
                        label: const Text('Xuất báo cáo'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Sticky Bottom Checkout Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildStickyBottomBar(topUpAmount),
          ),
        ],
      ),
    );
  }

  /// Card 1: Chứng Nhận Thẩm Định & Định Giá Máy Cũ
  Widget _buildCertificateCard(int score, int baseTradeInValue, int subsidy, int totalValuation) {
    final gradeText = score >= 90
        ? 'Hạng A • Xuất sắc'
        : score >= 80
            ? 'Hạng B • Khá tốt'
            : score >= 70
                ? 'Hạng C • Đạt chuẩn'
                : 'Hạng D • Hỗ trợ thu';

    final displayName = controller.marketingName.isNotEmpty &&
            controller.marketingName != '-'
        ? controller.marketingName
        : (controller.modelName.isNotEmpty && controller.modelName != '-'
            ? controller.modelName
            : 'Thiết bị của bạn');

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.tradeInNavy, AppColors.tradeInDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.tradeInNavy.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Glow
          Positioned(
            right: -20,
            bottom: -20,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.tradeInBlue.withValues(alpha: 0.18),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.verified_rounded, color: AppColors.tradeInEmerald, size: 20),
                        const SizedBox(width: 6),
                        Text(
                          'CHỨNG NHẬN THẨM ĐỊNH THU CŨ',
                          style: AppTextStyles.badge.copyWith(
                            color: AppColors.tradeInEmerald,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        gradeText,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Device Name
                Text(
                  displayName,
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Điểm sức khỏe máy: $score/100 • Định giá tự động',
                  style: AppTextStyles.caption.copyWith(color: AppColors.white70),
                ),

                const SizedBox(height: 20),

                // Price Highlights Grid
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.white.withValues(alpha: 0.12)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Giá thu máy cũ:', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white70)),
                          isLoadingPrice
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                                )
                              : Text(
                                  _formatPrice(baseTradeInValue),
                                  style: AppTextStyles.titleMedium.copyWith(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.stars_rounded, color: AppColors.tradeInGold, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                'Trợ giá lên đời độc quyền:',
                                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.tradeInGold),
                              ),
                            ],
                          ),
                          Text(
                            '+ ${_formatPrice(subsidy)}',
                            style: AppTextStyles.titleSmall.copyWith(
                              color: AppColors.tradeInGold,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Divider(color: AppColors.white24, height: 1),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TỔNG GIÁ TRỊ KHẤU TRỪ',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.tradeInEmeraldLight,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Áp dụng trực tiếp vào máy mới',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.white70,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            _formatPrice(totalValuation),
                            style: AppTextStyles.priceDisplay.copyWith(
                              color: AppColors.tradeInEmerald,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  /// Card 2: Interactive Upgrade Showroom
  Widget _buildUpgradeShowroom(int baseTradeInValue, int topUpAmount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chọn Máy Mới Muốn Lên Đời',
                  style: AppTextStyles.sectionHeader.copyWith(color: AppColors.tradeInNavy),
                ),
                const SizedBox(height: 2),
                Text(
                  'Chạm vào máy để tính số tiền bù thực tế',
                  style: AppTextStyles.caption.copyWith(color: AppColors.neutralGreyDark),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.tradeInGoldLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Trả góp 0%',
                style: AppTextStyles.badge.copyWith(color: AppColors.tradeInGoldDark),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // Horizontal Phone Carousel
        SizedBox(
          height: 175,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: upgradeOptions.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final option = upgradeOptions[index];
              final isSelected = option.id == selectedOption.id;
              final diff = option.calculateTopUp(baseTradeInValue);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedOption = option;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 155,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected ? AppColors.tradeInBlue : AppColors.tradeInBorder,
                      width: isSelected ? 2.2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected
                            ? AppColors.tradeInBlue.withValues(alpha: 0.15)
                            : AppColors.black.withValues(alpha: 0.03),
                        blurRadius: isSelected ? 12 : 6,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Tag + Select icon
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.tradeInBlue : AppColors.neutralGreyLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              option.tag,
                              style: AppTextStyles.badge.copyWith(
                                fontSize: 9,
                                color: isSelected ? AppColors.white : AppColors.neutralGreyDark,
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check_circle, color: AppColors.tradeInBlue, size: 16),
                        ],
                      ),

                      // Device Icon
                      Center(
                        child: Icon(
                          option.icon,
                          size: 38,
                          color: isSelected ? AppColors.tradeInBlue : AppColors.tradeInSlate,
                        ),
                      ),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            option.name,
                            style: AppTextStyles.labelMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.tradeInNavy,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${option.storage} • ${option.colorName}',
                            style: AppTextStyles.caption.copyWith(
                              fontSize: 10,
                              color: AppColors.neutralGreyDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Chỉ bù: ${_formatPrice(diff)}',
                            style: AppTextStyles.badge.copyWith(
                              color: AppColors.passDark,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 16),

        // Real-Time Upgrade Math Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.tradeInBorder),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.04),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Bảng tính lên đời: ${selectedOption.name}',
                    style: AppTextStyles.cardTitle.copyWith(color: AppColors.tradeInNavy),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.tradeInBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      selectedOption.storage,
                      style: AppTextStyles.badge.copyWith(color: AppColors.tradeInBlue),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _buildMathRow('Giá niêm yết máy mới:', selectedOption.formattedRetailPrice, isSub: false),
              const SizedBox(height: 8),
              _buildMathRow('Trừ giá thu máy cũ của bạn:', '- ${_formatPrice(baseTradeInValue)}', isHighlight: true),
              const SizedBox(height: 8),
              _buildMathRow('Trừ trợ giá độc quyền lên đời:', '- ${selectedOption.formattedSubsidy}', isGold: true),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1, color: AppColors.tradeInBorder),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SỐ TIỀN BÙ THỰC TẾ',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.tradeInNavy,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.credit_card, size: 12, color: AppColors.tradeInBlue),
                          const SizedBox(width: 4),
                          Text(
                            'Hoặc 0% lãi: ${_formatPrice(selectedOption.monthlyInstallment(topUpAmount))}/tháng',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.tradeInBlue,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Text(
                    _formatPrice(topUpAmount),
                    style: AppTextStyles.priceDisplay.copyWith(
                      color: AppColors.passDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMathRow(String label, String value, {bool isSub = true, bool isHighlight = false, bool isGold = false}) {
    Color valueColor = AppColors.tradeInNavy;
    if (isHighlight) valueColor = AppColors.passDark;
    if (isGold) valueColor = AppColors.tradeInGoldDark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isSub ? AppColors.neutralGreyDark : AppColors.tradeInNavy,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  /// Card 3: 3 Bước đổi máy
  Widget _buildTradeInStepsCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.tradeInBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quy Trình Thu Cũ Lên Đời 3 Bước',
            style: AppTextStyles.cardTitle.copyWith(color: AppColors.tradeInNavy),
          ),
          const SizedBox(height: 14),
          _buildStepRow('1', 'Thẩm định máy trên app', 'Hoàn thành bài test tự động nhận kết quả minh bạch', true),
          const SizedBox(height: 10),
          _buildStepRow('2', 'Chọn máy & Nhận voucher', 'Chọn mẫu siêu phẩm muốn đổi và giữ mức trợ giá 7 ngày', false),
          const SizedBox(height: 10),
          _buildStepRow('3', 'Bàn giao máy & Rinh máy mới', 'Giao dịch tại hệ thống hoặc nhân viên hỗ trợ tận nhà', false),
        ],
      ),
    );
  }

  Widget _buildStepRow(String number, String title, String desc, bool isDone) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isDone ? AppColors.tradeInEmerald : AppColors.tradeInBlue.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check, size: 14, color: AppColors.white)
                : Text(
                    number,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.tradeInBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
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
              Text(
                desc,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.neutralGreyDark,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Card 4: Danh mục kiểm định chi tiết
  Widget _buildDiagnosticBreakdown(int total, int passed, int failed) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.tradeInBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Chi Tiết Kiểm Định Phần Cứng',
                style: AppTextStyles.cardTitle.copyWith(color: AppColors.tradeInNavy),
              ),
              Row(
                children: [
                  _buildMiniStat('Đạt: $passed', AppColors.pass),
                  const SizedBox(width: 6),
                  if (failed > 0) _buildMiniStat('Lỗi: $failed', AppColors.fail),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.tradeInBorder),
          const SizedBox(height: 10),
          ...controller.steps.take(8).map((step) => _buildStepResultTile(step)),
          if (controller.steps.length > 8)
            Center(
              child: TextButton.icon(
                onPressed: () => _showFullDiagnosticsDialog(),
                icon: const Icon(Icons.list_alt_rounded, size: 16),
                label: Text('Xem toàn bộ ${controller.steps.length} bài test'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: AppTextStyles.badge.copyWith(color: color, fontSize: 11),
      ),
    );
  }

  Widget _buildStepResultTile(DiagStep step) {
    final isPassed = step.status == DiagStatus.passed;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            isPassed ? Icons.check_circle_rounded : Icons.warning_rounded,
            size: 18,
            color: isPassed ? AppColors.pass : AppColors.warning,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              step.title,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.tradeInNavy),
            ),
          ),
          Text(
            isPassed ? 'Tốt' : 'Cần lưu ý',
            style: AppTextStyles.caption.copyWith(
              color: isPassed ? AppColors.pass : AppColors.warning,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Sticky Bottom Bar
  Widget _buildStickyBottomBar(int topUpAmount) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, -4),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tiền bù lên ${selectedOption.name}:',
                style: AppTextStyles.caption.copyWith(color: AppColors.neutralGreyDark, fontSize: 11),
              ),
              Text(
                _formatPrice(topUpAmount),
                style: AppTextStyles.titleLarge.copyWith(
                  color: AppColors.passDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: () => _showUpgradeModal(topUpAmount),
                icon: const Icon(Icons.rocket_launch_rounded, size: 20),
                label: const Text('Lên Đời Ngay'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.tradeInBlue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  textStyle: AppTextStyles.button.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Modal xác nhận lên đời máy mới
  void _showUpgradeModal(int topUpAmount) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.tradeInBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.swap_horizontal_circle_rounded, color: AppColors.tradeInBlue, size: 28),
                  const SizedBox(width: 10),
                  Text(
                    'Xác Nhận Đổi Lên Máy Mới',
                    style: AppTextStyles.titleLarge.copyWith(
                      color: AppColors.tradeInNavy,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.tradeInSurfaceBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.tradeInBorder),
                ),
                child: Column(
                  children: [
                    _buildModalRow('Máy cũ thu hồi:', '${controller.brand} ${controller.modelName}'),
                    const SizedBox(height: 8),
                    _buildModalRow('Máy mới lên đời:', '${selectedOption.name} (${selectedOption.storage})'),
                    const SizedBox(height: 8),
                    _buildModalRow('Trợ giá độc quyền:', '+ ${selectedOption.formattedSubsidy}', isGold: true),
                    const Divider(height: 16),
                    _buildModalRow('Số tiền bù cần thanh toán:', _formatPrice(topUpAmount), isTotal: true),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Chọn phương thức giao nhận:',
                style: AppTextStyles.titleSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.tradeInNavy,
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.storefront_rounded, color: AppColors.tradeInBlue),
                title: const Text('Đổi máy tại cửa hàng gần nhất'),
                subtitle: const Text('Giữ máy & trợ giá trong 7 ngày'),
                trailing: const Icon(Icons.radio_button_checked, color: AppColors.tradeInBlue),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Get.snackbar(
                      'Thành Công!',
                      'Đã lưu đơn lên đời #${DateTime.now().millisecondsSinceEpoch}. Nhân viên sẽ liên hệ trong 5 phút.',
                      backgroundColor: AppColors.pass,
                      colorText: AppColors.white,
                      snackPosition: SnackPosition.TOP,
                      duration: const Duration(seconds: 4),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.tradeInBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Xác Nhận Giữ Ưu Đãi Lên Đời'),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModalRow(String label, String value, {bool isGold = false, bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.neutralGreyDark)),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: isTotal
                ? AppColors.passDark
                : isGold
                    ? AppColors.tradeInGoldDark
                    : AppColors.tradeInNavy,
            fontSize: isTotal ? 16 : 14,
          ),
        ),
      ],
    );
  }

  void _showFullDiagnosticsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chi Tiết Tất Cả Các Bài Test'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: controller.steps.length,
            itemBuilder: (context, index) {
              final step = controller.steps[index];
              return _buildStepResultTile(step);
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Đóng')),
        ],
      ),
    );
  }

  void _shareTradeInCertificate(int baseValue, int totalValuation, int topUp) {
    final text = '''
🌟 CHỨNG NHẬN THẨM ĐỊNH THU CŨ ĐỔI MỚI
📱 Thiết bị: ${controller.brand} ${controller.modelName}
💰 Giá thu máy cũ: ${_formatPrice(baseValue)}
🎁 Trợ giá lên đời: ${_formatPrice(selectedOption.subsidyAmount)}
🔥 Tổng khấu trừ: ${_formatPrice(totalValuation)}
🚀 Lên đời ${selectedOption.name} chỉ bù: ${_formatPrice(topUp)}
''';
    Clipboard.setData(ClipboardData(text: text));
    Get.snackbar('Đã sao chép', 'Đã lưu chứng nhận thẩm định vào clipboard để chia sẻ');
  }
}
