import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:kdtd_ver2_1/app/core/theme/app_colors.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_text_styles.dart';
import 'package:kdtd_ver2_1/app/routes/app_routes.dart';
import 'package:kdtd_ver2_1/generated/locale_keys.g.dart';

/// Màn mở đầu: giới thiệu chương trình nâng cấp iPhone dành cho khách mua
/// bảo hiểm thiết bị PVI.
///
/// Đây là initial route của app. Người xem chủ yếu là KHÁCH HÀNG đứng tại
/// quầy, không phải kỹ thuật viên — nên màn này giải thích ba bước của quy
/// trình trước, rồi mới mời bắt đầu, thay vì ném thẳng vào bảng kiểm định
/// đầy thông số như trước.
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.tradeInSurfaceBg,
      body: Column(
        children: [
          const Expanded(child: _Hero()),
          _BottomBar(),
        ],
      ),
    );
  }
}

// ==================== PHẦN TRÊN: THƯƠNG HIỆU + 3 BƯỚC ====================

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _BrandHeader(),
          Padding(
            padding: EdgeInsets.fromLTRB(24.w, 28.h, 24.w, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StepTile(
                  index: 1,
                  accent: AppColors.pviBlue,
                  surface: AppColors.pviBlueSurface,
                  icon: Icons.qr_code_scanner_rounded,
                  title: LocaleKeys.welcome_step_1_title.trans(),
                  description: LocaleKeys.welcome_step_1_desc.trans(),
                ),
                _StepTile(
                  index: 2,
                  accent: AppColors.pviNavy,
                  surface: AppColors.pviNavySurface,
                  icon: Icons.fact_check_rounded,
                  title: LocaleKeys.welcome_step_2_title.trans(),
                  description: LocaleKeys.welcome_step_2_desc.trans(),
                ),
                _StepTile(
                  index: 3,
                  accent: AppColors.tradeInEmerald,
                  surface: AppColors.successSurface,
                  icon: Icons.swap_horizontal_circle_rounded,
                  title: LocaleKeys.welcome_step_3_title.trans(),
                  description: LocaleKeys.welcome_step_3_desc.trans(),
                  isLast: true,
                ),
                SizedBox(height: 20.h),
                const _TrustNote(),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Dải đầu trang màu navy mang nhận diện PVI.
class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 32.h),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.pviNavy, AppColors.pviNavyDark],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 24.h),
            // Nhãn thương hiệu: vạch đỏ PVI + tên, nhất quán với tiêu đề
            // hạng mục ở trang chủ.
            Row(
              children: [
                Container(
                  width: 3.5.w,
                  height: 14.h,
                  decoration: BoxDecoration(
                    color: AppColors.pviRed,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  LocaleKeys.welcome_brand_tagline.trans().toUpperCase(),
                  style: AppTextStyles.overline.copyWith(
                    color: AppColors.white,
                    letterSpacing: 1.4,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            SizedBox(height: 18.h),
            Text(
              LocaleKeys.welcome_title.trans(),
              style: AppTextStyles.heroTitle.copyWith(
                color: AppColors.white,
                fontSize: 27.sp,
                height: 1.28,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 14.h),
            Text(
              LocaleKeys.welcome_subtitle.trans(),
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.white70,
                height: 1.55,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Một bước trong quy trình, kèm đường nối dọc sang bước kế tiếp.
class _StepTile extends StatelessWidget {
  const _StepTile({
    required this.index,
    required this.accent,
    required this.surface,
    required this.icon,
    required this.title,
    required this.description,
    this.isLast = false,
  });

  final int index;
  final Color accent;
  final Color surface;
  final IconData icon;
  final String title;
  final String description;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cột trái: huy hiệu số + đường nối
          Column(
            children: [
              Container(
                width: 40.r,
                height: 40.r,
                decoration: BoxDecoration(
                  color: surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: accent, width: 1.4),
                ),
                child: Icon(icon, size: 20.r, color: accent),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1.5.w,
                    margin: EdgeInsets.symmetric(vertical: 6.h),
                    color: AppColors.tradeInBorder,
                  ),
                ),
            ],
          ),
          SizedBox(width: 14.w),
          // Cột phải: nội dung bước
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 22.h, top: 2.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '$index',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: accent,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Flexible(
                        child: Text(
                          title,
                          style: AppTextStyles.cardTitle.copyWith(
                            color: AppColors.tradeInNavy,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    description,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.tradeInSlate,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Câu trấn an: kết quả do máy chấm, không cảm tính.
class _TrustNote extends StatelessWidget {
  const _TrustNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.pviNavySurface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.pviNavyBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.verified_user_rounded, size: 18.r, color: AppColors.pviNavy),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              LocaleKeys.welcome_note.trans(),
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.tradeInNavy,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== PHẦN DƯỚI: NÚT BẮT ĐẦU ====================

/// Nút hành động ghim đáy màn hình.
///
/// Ghim cố định chứ không để cuộn theo nội dung: đây là hành động duy nhất
/// của màn này, khách không phải cuộn xuống mới tìm thấy.
class _BottomBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.tradeInBorder)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(24.w, 14.h, 24.w, 14.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: FilledButton.icon(
                  onPressed: () => Get.toNamed(AppRoutes.diagnosticsHome),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.pviRed,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  icon: Icon(Icons.arrow_forward_rounded,
                      size: 20.r, color: AppColors.white),
                  label: Text(
                    LocaleKeys.welcome_start_btn.trans(),
                    style: AppTextStyles.button.copyWith(
                      color: AppColors.white,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.schedule_rounded,
                      size: 14.r, color: AppColors.tradeInSlate),
                  SizedBox(width: 6.w),
                  Text(
                    LocaleKeys.welcome_duration_hint.trans(),
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.tradeInSlate,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
