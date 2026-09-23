import 'package:flutter/material.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_colors.dart';
import 'package:kdtd_ver2_1/app/core/theme/app_text_styles.dart';
import 'package:kdtd_ver2_1/generated/locale_keys.g.dart';
import 'package:get/get.dart' hide Trans;

import 'speaker_test_controller.dart';

/// Test Loa ngoài (UI thuần)
///
/// Toàn bộ nghiệp vụ sống trong [SpeakerTestController]; widget này chỉ
/// đọc các field `.obs` qua `Obx` và gọi lại các method của controller
/// khi người dùng tương tác. Không cần `AnimationController` nên không
/// cần một View StatefulWidget riêng.
class SpeakerTestPage extends GetView<SpeakerTestController> {
  const SpeakerTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final playing = controller.playing.value;
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                LocaleKeys.speaker_test_title.trans(),
                style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 24.h),
              Icon(
                playing ? Icons.volume_up_rounded : Icons.volume_mute,
                size: 96.r,
                color: AppColors.tradeInBlue,
              ),
              SizedBox(height: 12.h),
              Text(
                LocaleKeys.speaker_test_instruction.trans(),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => controller.finish(false),
                      icon: const Icon(Icons.close),
                      label: Text(LocaleKeys.speaker_test_btn_fail.trans()),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => controller.finish(true),
                      icon: const Icon(Icons.check),
                      label: Text(LocaleKeys.speaker_test_btn_pass.trans()),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}
