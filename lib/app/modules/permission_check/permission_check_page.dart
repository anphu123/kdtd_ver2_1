import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_colors.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_text_styles.dart';
import 'package:kdtd_ver2_1/app/core/widgets/pvi_modernist/pvi_modernist.dart';
import 'package:kdtd_ver2_1/app/modules/permission_check/permission_check_controller.dart';
import 'package:permission_handler/permission_handler.dart';

/// Màn hình chuyên biệt: Cấp Quyền Để Kiểm Định
/// Cho phép người dùng xem trạng thái từng quyền, cấp quyền một chạm hoặc theo từng mục,
/// và tự động làm mới trạng thái khi quay lại từ Cài Đặt.
class PermissionCheckPage extends GetView<PermissionCheckController> {
  const PermissionCheckPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.tradeInSurfaceBg,
      appBar: AppBar(
        backgroundColor: AppColors.pviNavy,
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Cấp Quyền Kiểm Định',
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
        actions: [
          IconButton(
            tooltip: 'Làm mới quyền',
            icon: Icon(Icons.refresh_rounded, color: AppColors.white, size: 22.sp),
            onPressed: controller.refreshStatuses,
          ),
        ],
      ),
      body: Obx(() {
        return Column(
          children: [
            PviModernistStepper(
              currentStep: 1,
              completedSteps: controller.allRequiredGranted ? const {1} : const {},
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 20.h),
                children: [
                  _buildProtocolBanner(),
                  SizedBox(height: 16.h),
                  _buildSectionHeader(
                    title: 'QUYỀN PHẦN CỨNG BẮT BUỘC',
                    subtitle: 'Bắt buộc để kiểm tra camera và loa mic',
                    icon: Icons.lock_rounded,
                    accentColor: AppColors.pviRed,
                  ),
                  SizedBox(height: 8.h),
                  _buildInsetGroup(
                    items: controller.items.where((item) => item.isRequired).toList(),
                  ),
                  SizedBox(height: 16.h),
                  _buildSectionHeader(
                    title: 'CẢM BIẾN & NGOẠI VI (KHUYẾN NGHỊ)',
                    subtitle: 'Hỗ trợ kiểm tra GPS, sóng mạng và Bluetooth',
                    icon: Icons.tune_rounded,
                    accentColor: AppColors.pviNavy,
                  ),
                  SizedBox(height: 8.h),
                  _buildInsetGroup(
                    items: controller.items.where((item) => !item.isRequired).toList(),
                  ),
                  SizedBox(height: 16.h),
                  _buildPrivacyAssuranceCard(),
                ],
              ),
            ),
            _buildBottomActionBar(),
          ],
        );
      }),
    );
  }

  /// 2. Thẻ Protocol & Tiến độ cấp quyền
  Widget _buildProtocolBanner() {
    final granted = controller.grantedCount;
    final total = controller.totalCount;
    final ratio = controller.progressRatio;
    final allReq = controller.allRequiredGranted;

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
                  color: AppColors.pviRedSurface,
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(color: AppColors.pviRedBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.verified_user_rounded,
                      color: AppColors.pviRed,
                      size: 13.sp,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'PVI ASSURANCE',
                      style: AppTextStyles.badge.copyWith(
                        color: AppColors.pviRed,
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
                  'TIÊU CHUẨN ĐỊNH GIÁ',
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 42.w,
                height: 42.h,
                decoration: BoxDecoration(
                  color: allReq ? AppColors.tradeInEmeraldLight : AppColors.pviRedSurface,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: allReq ? AppColors.tradeInEmeraldBorder : AppColors.pviRedBorder,
                    width: 1.2,
                  ),
                ),
                child: Icon(
                  allReq ? Icons.check_circle_rounded : Icons.lock_open_rounded,
                  color: allReq ? AppColors.tradeInEmerald : AppColors.pviRed,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ủy Quyền Phần Cứng',
                      style: AppTextStyles.cardTitle.copyWith(
                        color: AppColors.tradeInNavy,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      allReq
                          ? 'Đã đủ điều kiện bắt đầu kiểm định'
                          : 'Cần cấp quyền Camera & Micro để tiếp tục',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 12.sp,
                        color: allReq ? AppColors.tradeInEmerald : AppColors.textMuted,
                        fontWeight: allReq ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tiến độ cấp quyền:',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$granted / $total quyền sẵn sàng',
                style: AppTextStyles.badge.copyWith(
                  color: AppColors.tradeInNavy,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 6.h,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(
                allReq ? AppColors.tradeInEmerald : AppColors.pviRed,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 3. Tiêu đề phân đoạn
  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14.sp, color: accentColor),
            SizedBox(width: 6.w),
            Text(
              title,
              style: AppTextStyles.badge.copyWith(
                fontSize: 11.sp,
                color: accentColor,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        Padding(
          padding: EdgeInsets.only(left: 20.w),
          child: Text(
            subtitle,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 11.sp,
              color: AppColors.textMuted,
            ),
          ),
        ),
      ],
    );
  }

  /// 4. Inset Grouped Card (Chuẩn iOS Inset Group)
  Widget _buildInsetGroup({required List<PermissionCheckItem> items}) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            _buildPermissionRow(items[i]),
            if (i < items.length - 1)
              Divider(
                height: 1,
                thickness: 1,
                indent: 62.w,
                color: AppColors.border,
              ),
          ],
        ],
      ),
    );
  }

  /// Dòng hàng mục trong thẻ nhóm lồng
  Widget _buildPermissionRow(PermissionCheckItem item) {
    return Obx(() {
      final status = item.status.value;
      final isGranted = status.isGranted;
      final isPermDenied = status.isPermanentlyDenied;

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 38.w,
              height: 38.h,
              decoration: BoxDecoration(
                color: item.surfaceColor,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: item.surfaceColor == AppColors.pviRedSurface
                      ? AppColors.pviRedBorder
                      : AppColors.borderSubtle,
                  width: 1,
                ),
              ),
              child: Icon(item.icon, color: item.accentColor, size: 20.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          item.name,
                          style: AppTextStyles.cardTitle.copyWith(
                            fontSize: 13.5.sp,
                            color: AppColors.tradeInNavy,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (item.isRequired) ...[
                        SizedBox(width: 6.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 5.w,
                            vertical: 1.5.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.pviRedSurface,
                            borderRadius: BorderRadius.circular(4.r),
                            border: Border.all(color: AppColors.pviRedBorder),
                          ),
                          child: Text(
                            'Bắt buộc',
                            style: AppTextStyles.badge.copyWith(
                              fontSize: 9.sp,
                              color: AppColors.pviRed,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    item.description,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 11.5.sp,
                      color: AppColors.textMuted,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 10.w),
            _buildStatusActionButton(item, isGranted, isPermDenied),
          ],
        ),
      );
    });
  }

  /// Nút trạng thái hành động
  Widget _buildStatusActionButton(
    PermissionCheckItem item,
    bool isGranted,
    bool isPermDenied,
  ) {
    if (isGranted) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: AppColors.tradeInEmeraldLight,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.tradeInEmeraldBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_rounded,
              size: 14.sp,
              color: AppColors.tradeInEmerald,
            ),
            SizedBox(width: 4.w),
            Text(
              'ĐÃ CẤP',
              style: AppTextStyles.badge.copyWith(
                fontSize: 10.5.sp,
                color: AppColors.tradeInEmerald,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    }

    if (isPermDenied) {
      return OutlinedButton(
        onPressed: () => controller.openSettings(),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.tradeInGoldDark,
          side: const BorderSide(color: AppColors.tradeInGoldDark),
          padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
          visualDensity: VisualDensity.compact,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
          ),
        ),
        child: Text(
          'Cài đặt',
          style: AppTextStyles.caption.copyWith(
            fontSize: 11.sp,
            color: AppColors.tradeInGoldDark,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return FilledButton(
      onPressed: () => controller.requestSingle(item),
      style: FilledButton.styleFrom(
        backgroundColor: item.accentColor,
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        visualDensity: VisualDensity.compact,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
      ),
      child: Text(
        'Cấp quyền',
        style: AppTextStyles.badge.copyWith(
          color: AppColors.white,
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  /// 5. Cam kết an toàn & bảo mật
  Widget _buildPrivacyAssuranceCard() {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36.w,
            height: 36.h,
            decoration: BoxDecoration(
              color: AppColors.tradeInEmeraldLight,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: AppColors.tradeInEmeraldBorder),
            ),
            child: Icon(
              Icons.shield_outlined,
              size: 20.sp,
              color: AppColors.tradeInEmerald,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cam Kết Bảo Mật PVI (Non-Invasive)',
                  style: AppTextStyles.cardTitle.copyWith(
                    fontSize: 13.sp,
                    color: AppColors.tradeInNavy,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  'Quy trình kiểm định chỉ tương tác trực tiếp tín hiệu phần cứng để xác nhận tình trạng linh kiện máy. Tuyệt đối không đọc, sao chép hoặc lưu trữ dữ liệu riêng tư, hình ảnh hay danh bạ của bạn.',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 11.5.sp,
                    color: AppColors.textMuted,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 6. Thanh điều hướng hành động cố định bên dưới
  Widget _buildBottomActionBar() {
    final allGranted = controller.allGranted;
    final allReq = controller.allRequiredGranted;
    final isRequesting = controller.isRequestingAll.value;
    final remainingCount = controller.totalCount - controller.grantedCount;

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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (allReq && !allGranted) ...[
              Padding(
                padding: EdgeInsets.only(bottom: 6.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline_rounded,
                          size: 14.sp,
                          color: AppColors.tradeInEmerald,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'Đủ điều kiện kiểm định',
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 11.5.sp,
                            color: AppColors.tradeInEmerald,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: isRequesting ? null : controller.requestAll,
                      child: Text(
                        'Cấp nốt $remainingCount quyền phụ',
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 11.5.sp,
                          color: AppColors.pviNavy,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: FilledButton.icon(
                onPressed: () {
                  if (!allReq) {
                    controller.requestAll();
                  } else {
                    controller.proceedToDiagnostics();
                  }
                },
                icon: isRequesting
                    ? SizedBox(
                        width: 18.w,
                        height: 18.h,
                        child: const CircularProgressIndicator(
                          color: AppColors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Icon(
                        allReq
                            ? Icons.arrow_forward_rounded
                            : Icons.security_rounded,
                        size: 20.sp,
                        color: AppColors.white,
                      ),
                label: Text(
                  isRequesting
                      ? 'Đang yêu cầu cấp quyền...'
                      : (!allReq
                          ? 'CẤP TẤT CẢ QUYỀN'
                          : 'TIẾP TỤC: ĐỐI SOÁT SERIAL / IMEI'),
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
          ],
        ),
      ),
    );
  }
}
