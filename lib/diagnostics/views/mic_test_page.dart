import 'dart:async';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

class MicTestPage extends StatefulWidget {
  const MicTestPage({super.key});

  @override
  State<MicTestPage> createState() => _MicTestPageState();
}

class _MicTestPageState extends State<MicTestPage> with WidgetsBindingObserver {
  final AudioRecorder _rec = AudioRecorder();
  StreamSubscription<Amplitude>? _sub;
  double _amp = 0.0;
  bool _ready = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _start();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeRecording();
    super.dispose();
  }

  Future<void> _disposeRecording() async {
    try {
      await _sub?.cancel();
      _sub = null;
      if (await _rec.isRecording()) {
        await _rec.stop();
      }
      // Optional (nếu dùng lâu dài nhiều lần có thể gọi _rec.dispose())
    } catch (_) {}
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.paused) {
      await _disposeRecording();
      if (mounted) setState(() => _ready = false);
    } else if (state == AppLifecycleState.resumed && mounted) {
      _start();
    }
  }

  Future<void> _start() async {
    if (!mounted) return;
    setState(() {
      _error = null;
      _ready = false;
      _amp = 0;
    });

    try {
      final mic = await Permission.microphone.request();
      if (!mic.isGranted) {
        if (!mounted) return;
        setState(() => _error = 'Ứng dụng không có quyền Micro.');
        return;
      }

      final ok = await _rec.hasPermission();
      if (!ok) {
        if (!mounted) return;
        setState(() => _error = 'Thiết bị không cấp quyền ghi âm.');
        return;
      }

      if (await _rec.isRecording()) {
        await _rec.stop();
      }

      // === TẠO FILE TẠM CHO PATH (khắc phục lỗi "Null -> String") ===
      final dir = await getTemporaryDirectory();
      final filePath =
          '${dir.path}/mic_test_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _rec.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: filePath, // <-- BẮT BUỘC LÀ STRING HỢP LỆ
      );

      await _sub?.cancel();
      _sub = _rec
          .onAmplitudeChanged(const Duration(milliseconds: 150))
          .listen((a) {
        if (!mounted) return;
        setState(() => _amp = a.current.abs());
      }, onError: (e) {
        if (!mounted) return;
        setState(() => _error = 'Lỗi amplitude: $e');
      });

      if (!mounted) return;
      setState(() => _ready = true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Không thể khởi động micro: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    final level = (_amp.clamp(0, 20000)) / 20000.0;

    return Scaffold(
      appBar: AppBar(title: const Text('Test Micro')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Builder(
            builder: (_) {
              if (_error != null) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_error!, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    FilledButton(onPressed: _start, child: const Text('Thử lại')),
                  ],
                );
              }
              if (!_ready) return const Text('Đang chuẩn bị micro...');

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Nói “Một hai ba”…'),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: 240,
                    height: 20,
                    child: LinearProgressIndicator(value: level),
                  ),
                  const SizedBox(height: 8),
                  Text('Amplitude: ${_amp.toStringAsFixed(0)}'),
                ],
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await _disposeRecording();
                    if (mounted) Navigator.pop(context, false);
                  },
                  icon: const Icon(Icons.close),
                  label: const Text('Không đạt'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () async {
                    await _disposeRecording();
                    if (mounted) Navigator.pop(context, true);
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Đạt'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
