import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
        appBar: AppBar(title: const Text('Test Loa ngoài')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                playing ? Icons.volume_up_rounded : Icons.volume_mute,
                size: 96,
              ),
              const SizedBox(height: 12),
              const Text('Bạn có nghe tiếng beep rõ không?'),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => controller.finish(false),
                    icon: const Icon(Icons.close),
                    label: const Text('Không đạt'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => controller.finish(true),
                    icon: const Icon(Icons.check),
                    label: const Text('Đạt'),
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
