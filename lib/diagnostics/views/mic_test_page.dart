import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';

class MicTestPage extends StatefulWidget {
  const MicTestPage({super.key});

  @override
  State<MicTestPage> createState() => _MicTestPageState();
}

enum MicTestPhase {
  recording, // Đang thu âm 5 giây
  playing, // Đang phát lại
  confirming, // Chờ người dùng xác nhận
}

class _MicTestPageState extends State<MicTestPage>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  final AudioRecorder _rec = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  StreamSubscription<Amplitude>? _sub;
  StreamSubscription<void>? _playerCompleteSub;
  double _amp = 0.0;
  double _maxAmp = 0.0;
  bool _ready = false;
  bool _hasDetectedSound = false;
  String? _error;
  String? _recordingPath;

  late AnimationController _pulseController;
  final List<double> _amplitudeHistory = [];
  Timer? _recordingTimer;
  Timer? _countdownTimer;

  MicTestPhase _phase = MicTestPhase.recording;
  int _countdown = 5; // Countdown từ 5 giây

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    // Setup player complete listener once
    _playerCompleteSub = _player.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _phase = MicTestPhase.confirming;
        });
      }
    });

    _start();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pulseController.dispose();
    _recordingTimer?.cancel();
    _countdownTimer?.cancel();
    _playerCompleteSub?.cancel();
    _player.dispose();
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
      await _rec.dispose();

      // Delete temp recording file
      if (_recordingPath != null) {
        try {
          final file = File(_recordingPath!);
          if (await file.exists()) {
            await file.delete();
          }
        } catch (_) {}
        _recordingPath = null;
      }
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
      _maxAmp = 0;
      _hasDetectedSound = false;
      _amplitudeHistory.clear();
      _phase = MicTestPhase.recording;
      _countdown = 5;
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

      // Create temp file path for recording
      final tempDir = await getTemporaryDirectory();
      _recordingPath =
          '${tempDir.path}/mic_test_${DateTime.now().millisecondsSinceEpoch}.m4a';

      // Start recording for amplitude monitoring
      await _rec.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
          numChannels: 1,
        ),
        path: _recordingPath!,
      );

      await _sub?.cancel();
      _sub = _rec
          .onAmplitudeChanged(const Duration(milliseconds: 100))
          .listen(
            (a) {
              if (!mounted) return;
              final currentAmp = a.current.abs();
              setState(() {
                _amp = currentAmp;
                if (currentAmp > _maxAmp) _maxAmp = currentAmp;

                // Lưu lịch sử amplitude cho waveform
                _amplitudeHistory.add(currentAmp);
                if (_amplitudeHistory.length > 50) {
                  _amplitudeHistory.removeAt(0);
                }

                // Phát hiện âm thanh (threshold: 1000)
                if (currentAmp > 1000 && !_hasDetectedSound) {
                  _hasDetectedSound = true;
                }
              });
            },
            onError: (e) {
              if (!mounted) return;
              setState(() => _error = 'Lỗi amplitude: $e');
            },
          );

      if (!mounted) return;
      setState(() => _ready = true);

      // Bắt đầu countdown 5 giây
      _startRecordingCountdown();
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Không thể khởi động micro: $e');
    }
  }

  void _startRecordingCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _countdown--;
      });

      if (_countdown <= 0) {
        timer.cancel();
        _stopRecordingAndPlayback();
      }
    });
  }

  Future<void> _stopRecordingAndPlayback() async {
    try {
      // Dừng thu âm
      await _sub?.cancel();
      _sub = null;

      if (await _rec.isRecording()) {
        await _rec.stop();
      }

      if (!mounted) return;

      // Chuyển sang phase phát lại
      setState(() {
        _phase = MicTestPhase.playing;
      });

      // Phát lại file đã thu
      if (_recordingPath != null && await File(_recordingPath!).exists()) {
        await _player.play(DeviceFileSource(_recordingPath!));
        // Listener đã được setup trong initState, sẽ tự động chuyển phase
      } else {
        // Không có file, chuyển thẳng sang confirming
        if (mounted) {
          setState(() {
            _phase = MicTestPhase.confirming;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Lỗi khi phát lại: $e';
          _phase = MicTestPhase.confirming;
        });
      }
    }
  }

  String _getInstructionText() {
    switch (_phase) {
      case MicTestPhase.recording:
        return 'Đang thu âm... Hãy nói "Một hai ba"';
      case MicTestPhase.playing:
        return 'Đang phát lại âm thanh đã thu...';
      case MicTestPhase.confirming:
        return 'Bạn có nghe thấy âm thanh vừa phát không?';
    }
  }

  Color _getPhaseColor() {
    switch (_phase) {
      case MicTestPhase.recording:
        return _hasDetectedSound ? Colors.green : Colors.blue;
      case MicTestPhase.playing:
        return Colors.orange;
      case MicTestPhase.confirming:
        return Colors.purple;
    }
  }

  IconData _getPhaseIcon() {
    switch (_phase) {
      case MicTestPhase.recording:
        return _hasDetectedSound ? Icons.check_circle : Icons.mic;
      case MicTestPhase.playing:
        return Icons.volume_up;
      case MicTestPhase.confirming:
        return Icons.help_outline;
    }
  }

  String _getPhaseStatus() {
    switch (_phase) {
      case MicTestPhase.recording:
        return _hasDetectedSound
            ? 'Đã phát hiện âm thanh!'
            : 'Đang lắng nghe...';
      case MicTestPhase.playing:
        return 'Đang phát lại...';
      case MicTestPhase.confirming:
        return 'Chờ xác nhận';
    }
  }

  Future<void> _finish(bool passed) async {
    await _player.stop();
    await _disposeRecording();
    if (mounted) {
      Navigator.pop(context, passed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final level = (_amp.clamp(0, 20000)) / 20000.0;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: const Text('Test Micro'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _finish(false),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Builder(
            builder: (_) {
              if (_error != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 64,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: _start,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Thử lại'),
                      ),
                    ],
                  ),
                );
              }

              if (!_ready) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 16),
                      Text(
                        'Đang chuẩn bị micro...',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Status indicator
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _getPhaseColor().withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _getPhaseColor(), width: 2),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getPhaseIcon(),
                          color: _getPhaseColor(),
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _getPhaseStatus(),
                          style: TextStyle(
                            color: _getPhaseColor(),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Animated mic icon
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      final scale = 1.0 + (level * 0.5);
                      final opacity = 0.3 + (level * 0.7);
                      return Transform.scale(
                        scale: scale,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                _hasDetectedSound
                                    ? Colors.green.withValues(alpha: opacity)
                                    : Colors.blue.withValues(alpha: opacity),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    _hasDetectedSound
                                        ? Colors.green.withValues(alpha: 0.5)
                                        : Colors.blue.withValues(alpha: 0.5),
                                blurRadius: 30 * level,
                                spreadRadius: 10 * level,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.mic,
                            size: 60,
                            color:
                                _hasDetectedSound ? Colors.green : Colors.blue,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 48),

                  // Instruction based on phase
                  Text(
                    _getInstructionText(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  // Countdown display during recording
                  if (_phase == MicTestPhase.recording) ...[
                    const SizedBox(height: 16),
                    Text(
                      '$_countdown',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Waveform visualizer
                  Container(
                    height: 100,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: CustomPaint(
                      painter: WaveformPainter(
                        amplitudes: _amplitudeHistory,
                        color: _hasDetectedSound ? Colors.green : Colors.blue,
                      ),
                      size: const Size(double.infinity, 68),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatItem(
                        label: 'Hiện tại',
                        value: _amp.toStringAsFixed(0),
                        color: Colors.blue,
                      ),
                      _StatItem(
                        label: 'Cao nhất',
                        value: _maxAmp.toStringAsFixed(0),
                        color: Colors.green,
                      ),
                      _StatItem(
                        label: 'Mức độ',
                        value: '${(level * 100).toStringAsFixed(0)}%',
                        color: Colors.orange,
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          color: Colors.black87,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed:
                      _phase == MicTestPhase.confirming
                          ? () => _finish(false)
                          : null,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    disabledForegroundColor: Colors.grey,
                  ),
                  icon: const Icon(Icons.close),
                  label: Text(
                    _phase == MicTestPhase.confirming
                        ? 'Không nghe rõ'
                        : 'Chờ...',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed:
                      _phase == MicTestPhase.confirming
                          ? () => _finish(true)
                          : null,
                  style: FilledButton.styleFrom(
                    backgroundColor:
                        _phase == MicTestPhase.confirming
                            ? (_hasDetectedSound
                                ? Colors.green
                                : Colors.green.withValues(alpha: 0.7))
                            : Colors.grey,
                    disabledBackgroundColor: Colors.grey,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.check),
                  label: Text(
                    _phase == MicTestPhase.confirming
                        ? (_hasDetectedSound ? 'Nghe rõ' : 'Nghe rõ (Thủ công)')
                        : 'Chờ...',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class WaveformPainter extends CustomPainter {
  final List<double> amplitudes;
  final Color color;

  WaveformPainter({required this.amplitudes, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (amplitudes.isEmpty) return;

    final paint =
        Paint()
          ..color = color
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round;

    final barWidth = size.width / amplitudes.length;
    final centerY = size.height / 2;

    for (int i = 0; i < amplitudes.length; i++) {
      final x = i * barWidth;
      final normalizedAmp = (amplitudes[i].clamp(0, 20000) / 20000);
      final barHeight = normalizedAmp * size.height;

      canvas.drawLine(
        Offset(x, centerY - barHeight / 2),
        Offset(x, centerY + barHeight / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(WaveformPainter oldDelegate) {
    return oldDelegate.amplitudes != amplitudes || oldDelegate.color != color;
  }
}
