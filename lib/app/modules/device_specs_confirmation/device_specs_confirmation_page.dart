import 'package:flutter/material.dart';
import 'package:kdtd_ver2_1/generated/locale_keys.g.dart';
import 'package:get/get.dart' hide Trans;
import 'package:kdtd_ver2_1/app/core/theme/app_colors.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_text_styles.dart';
import 'package:kdtd_ver2_1/app/core/widgets/pvi_modernist/pvi_modernist.dart';
import 'package:kdtd_ver2_1/app/data/model/device_cosmetic_survey.dart';
import 'package:kdtd_ver2_1/app/modules/diagnostics_home/diagnostics_home_controller.dart';
import 'package:kdtd_ver2_1/app/modules/pre_test_guide/pre_test_guide_page.dart';

/// Màn hình Trung Gian 1: Xác Nhận Cấu Hình RAM/ROM & Khảo Sát Ngoại Quan Sơ Bộ
/// Bước 2 trong luồng kiểm định PVI Assurance
class DeviceSpecsConfirmationPage extends StatefulWidget {
  const DeviceSpecsConfirmationPage({super.key});

  @override
  State<DeviceSpecsConfirmationPage> createState() =>
      _DeviceSpecsConfirmationPageState();
}

class _DeviceSpecsConfirmationPageState
    extends State<DeviceSpecsConfirmationPage> {
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

  void _finishAndNavigateToResult() {
    _saveSurvey();
    debugPrint('[DeviceSpecsConfirmation] Đã lưu khảo sát. Chuyển sang PreTestPreparationGuidePage');
    Get.to(() => const PreTestPreparationGuidePage());
  }

  String get _unavailable =>
      LocaleKeys.device_specs_confirmation_value_unavailable.trans();

  /// RAM/ROM lấy từ controller (đã làm tròn về mốc phổ biến, cùng nguồn với
  /// mã IT) để các màn không lệch nhau. Không đọc được → "Không xác định",
  /// không bịa số mặc định. iOS không cho đọc RAM thật nên giá trị ước tính
  /// được đánh dấu "~".
  String _formatStorage(String key) {
    final gb = key == 'ram' ? controller.ramGbValue : controller.romGbValue;
    if (gb == null) return _unavailable;
    final estimated = controller.info[key]?['source'].toString().contains('estimated') == true;
    return estimated ? '~$gb GB' : '$gb GB';
  }

  String _formatBattery() {
    final level = (controller.info['battery'] as Map<String, dynamic>?)?['level'];
    return level != null ? '$level%' : _unavailable;
  }

  @override
  Widget build(BuildContext context) {
    final displayName =
        controller.marketingName.isNotEmpty && controller.marketingName != '-'
            ? controller.marketingName
            : (controller.modelName.isNotEmpty && controller.modelName != '-'
                ? controller.modelName
                : LocaleKeys.device_specs_confirmation_default_device_name
                    .trans());

    final brand =
        controller.brand.isNotEmpty
            ? controller.brand
            : LocaleKeys.device_specs_confirmation_default_brand.trans();

    return Scaffold(
      backgroundColor: AppColors.tradeInSurfaceBg,
      appBar: AppBar(
        backgroundColor: AppColors.pviNavy,
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          LocaleKeys.device_specs_confirmation_appbar_title.trans(),
          style: AppTextStyles.appBarTitle.copyWith(
            color: AppColors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.white,
            size: 18.sp,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          // 1. Top Minimalist Stepper (Bước 2: Đối soát active)
          const PviModernistStepper(
            currentStep: 2,
            completedSteps: {1},
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 2. Thẻ thông số phần cứng thiết bị
                  _buildDeviceSpecsCard(displayName, brand),
                  SizedBox(height: 14.h),

                  // 3. Thông tin ước tính giá & gợi ý Thu cũ đổi mới
                  _buildValuationTeaser(),
                  SizedBox(height: 18.h),

                  // 4. Phần khảo sát nhanh ngoại quan máy
                  _buildSectionHeader(
                    title: 'KHẢO SÁT NGOẠI QUAN MÁY',
                    icon: Icons.palette_outlined,
                  ),
                  SizedBox(height: 10.h),

                  // Câu hỏi A: Thân máy & Khung viền
                  _buildSurveyGroup(
                    title: LocaleKeys.device_specs_confirmation_question_body_title.trans(),
                    icon: Icons.phone_android_rounded,
                    items: BodyCondition.values.map((item) {
                      return _buildSurveyOptionRow(
                        label: item.label,
                        description: item.description,
                        isSelected: _body == item,
                        onTap: () => setState(() => _body = item),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 14.h),

                  // Câu hỏi B: Mặt kính màn hình
                  _buildSurveyGroup(
                    title: LocaleKeys.device_specs_confirmation_question_screen_title.trans(),
                    icon: Icons.screenshot_rounded,
                    items: ScreenCondition.values.map((item) {
                      return _buildSurveyOptionRow(
                        label: item.label,
                        description: item.description,
                        isSelected: _screen == item,
                        onTap: () => setState(() => _screen = item),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 14.h),

                  // Câu hỏi C: Trạng thái tài khoản người dùng
                  _buildSurveyGroup(
                    title: LocaleKeys.device_specs_confirmation_question_account_title.trans(),
                    icon: Icons.account_circle_outlined,
                    items: AccountStatus.values.map((item) {
                      return _buildSurveyOptionRow(
                        label: item.label,
                        description: item.description,
                        isSelected: _account == item,
                        onTap: () => setState(() => _account = item),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          _buildBottomActionDock(),
        ],
      ),
    );
  }

  /// Thẻ thông số thiết bị Inset Group
  Widget _buildDeviceSpecsCard(String displayName, String brand) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: AppColors.tradeInEmeraldLight,
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(color: AppColors.tradeInEmeraldBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.tradeInEmerald,
                      size: 13.sp,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'ĐÃ ĐỐI SOÁT PHẦN CỨNG',
                      style: AppTextStyles.badge.copyWith(
                        color: AppColors.tradeInEmerald,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: AppColors.pviNavySurface,
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(color: AppColors.pviNavyBorder),
                ),
                child: Text(
                  'BƯỚC 2 / 3',
                  style: AppTextStyles.badge.copyWith(
                    color: AppColors.pviNavy,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Container(
                width: 44.w,
                height: 44.h,
                decoration: BoxDecoration(
                  color: AppColors.pviNavySurface,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.pviNavyBorder),
                ),
                child: Icon(
                  Icons.phone_iphone_rounded,
                  color: AppColors.pviNavy,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: AppTextStyles.cardTitle.copyWith(
                        color: AppColors.tradeInNavy,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Hãng sản xuất: $brand',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Divider(height: 1, color: AppColors.border),
          SizedBox(height: 14.h),

          // Lưới thông số 2x2
          Row(
            children: [
              Expanded(
                child: _buildSpecItem(
                  Icons.memory_rounded,
                  LocaleKeys.device_specs_confirmation_spec_ram_label.trans(),
                  _formatStorage('ram'),
                ),
              ),
              Expanded(
                child: _buildSpecItem(
                  Icons.storage_rounded,
                  LocaleKeys.device_specs_confirmation_spec_rom_label.trans(),
                  _formatStorage('rom'),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: _buildSpecItem(
                  Icons.battery_charging_full_rounded,
                  LocaleKeys.device_specs_confirmation_spec_battery_label.trans(),
                  _formatBattery(),
                ),
              ),
              Expanded(
                child: _buildSpecItem(
                  Icons.verified_outlined,
                  LocaleKeys.device_specs_confirmation_spec_brand_origin_label.trans(),
                  brand,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpecItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(7.r),
          decoration: BoxDecoration(
            color: AppColors.tradeInSurfaceBg,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Icon(icon, color: AppColors.tradeInNavy, size: 16.sp),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 11.sp,
                ),
              ),
              Text(
                value,
                style: AppTextStyles.cardTitle.copyWith(
                  color: AppColors.tradeInNavy,
                  fontWeight: FontWeight.w700,
                  fontSize: 13.sp,
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

  /// Banner định giá sơ bộ
  Widget _buildValuationTeaser() {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.warningSurface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.warningBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.stars_rounded,
                color: AppColors.warningDark,
                size: 20.sp,
              ),
              SizedBox(width: 6.w),
              Text(
                LocaleKeys.device_specs_confirmation_valuation_title.trans(),
                style: AppTextStyles.cardTitle.copyWith(
                  color: AppColors.warningDark,
                  fontWeight: FontWeight.bold,
                  fontSize: 13.5.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14.sp, color: AppColors.tradeInNavy),
            SizedBox(width: 6.w),
            Text(
              title,
              style: AppTextStyles.badge.copyWith(
                fontSize: 11.sp,
                color: AppColors.tradeInNavy,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSurveyGroup({
    required String title,
    required IconData icon,
    required List<Widget> items,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 8.h),
            child: Row(
              children: [
                Icon(icon, size: 16.sp, color: AppColors.pviNavy),
                SizedBox(width: 8.w),
                Text(
                  title,
                  style: AppTextStyles.cardTitle.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.tradeInNavy,
                    fontSize: 13.5.sp,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.border),
          for (int i = 0; i < items.length; i++) ...[
            items[i],
            if (i < items.length - 1)
              Divider(height: 1, indent: 44.w, color: AppColors.border),
          ],
        ],
      ),
    );
  }

  Widget _buildSurveyOptionRow({
    required String label,
    required String description,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: isSelected ? AppColors.pviRedSurface : AppColors.white,
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: isSelected ? AppColors.pviRed : AppColors.borderStrong,
              size: 18.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.cardTitle.copyWith(
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: isSelected ? AppColors.pviRed : AppColors.tradeInNavy,
                      fontSize: 13.sp,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    description,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textMuted,
                      fontSize: 11.sp,
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

  /// Thanh điều hướng hành động cố định bên dưới
  Widget _buildBottomActionDock() {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 12.h),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 48.h,
          child: FilledButton.icon(
            onPressed: _finishAndNavigateToResult,
            icon: Icon(
              Icons.arrow_forward_rounded,
              color: AppColors.white,
              size: 20.sp,
            ),
            label: Text(
              'TIẾP TỤC',
              style: AppTextStyles.button.copyWith(
                color: AppColors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.pviRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
