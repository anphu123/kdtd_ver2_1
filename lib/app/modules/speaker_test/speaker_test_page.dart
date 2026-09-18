import 'package:flutter/material.dart';
import 'package:kdtd_ver2_1/app/core/extensions/string_extensions.dart';
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
      return Scaffold(
        appBar: AppBar(title: Text(LocaleKeys.speaker_test_title.trans())),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                playing ? Icons.volume_up_rounded : Icons.volume_mute,
                size: 96.r,
              ),
              SizedBox(height: 12.h),
              Text(LocaleKeys.speaker_test_instruction.trans()),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(12.r),
            child: Row(
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
          ),
        ),
      );
    });
  }
}
