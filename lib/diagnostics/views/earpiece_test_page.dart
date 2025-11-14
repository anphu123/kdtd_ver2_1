import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:proximity_sensor/proximity_sensor.dart';

class EarpieceTestPage extends StatefulWidget {
  const EarpieceTestPage({super.key});

  @override
  State<EarpieceTestPage> createState() => _EarpieceTestPageState();
}

class _EarpieceTestPageState extends State<EarpieceTestPage>
    with SingleTickerProviderStateMixin {
  final _player = AudioPlayer();
  StreamSubscription<int>? _proximitySub;
  bool _isNear = false;
  bool _hasDetectedNear = false;
  bool _isPlaying = false;
  Timer? _autoPassTimer;
  int _nearCount = 0;

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _start();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _autoPassTimer?.cancel();
    _proximitySub?.cancel();
    _player.stop();
    _player.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    try {
      // Setup audio player
      await _player.setVolume(0.5);
      await _player.setReleaseMode(ReleaseMode.loop);

      // Play sine wave through earpiece
      await _player.play(BytesSource(_genSineWaveBytes()));

      setState(() => _isPlaying = true);

      // Listen to proximity sensor
      _proximitySub = ProximitySensor.events.listen((distance) {
        final isNear = distance > 0;

        setState(() {
          _isNear = isNear;
          if (isNear) {
            _nearCount++;
            if (!_hasDetectedNear) {
              _hasDetectedNear = true;
              _startAutoPassTimer();
            }
          }
        });
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    }
  }

  void _startAutoPassTimer() {
    _autoPassTimer?.cancel();
    _autoPassTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _hasDetectedNear) {
        _finish(true);
      }
    });
  }

  Future<void> _finish(bool passed) async {
    await _player.stop();
    if (mounted) {
      Navigator.pop(context, passed);
    }
  }

  Uint8List _genSineWaveBytes({
    int sampleRate = 44100,
    int seconds = 2,
    double freqHz = 800,
  }) {
    final total = sampleRate * seconds;
    final data = ByteData(44 + total * 2);

    void w16(int o, int v) => data.setUint16(o, v, Endian.little);
    void w32(int o, int v) => data.setUint32(o, v, Endian.little);

    // WAV header
    data.buffer.asUint8List().setRange(0, 4, 'RIFF'.codeUnits);
    w32(4, 36 + total * 2);
    data.buffer.asUint8List().setRange(8, 12, 'WAVE'.codeUnits);
    data.buffer.asUint8List().setRange(12, 16, 'fmt '.codeUnits);
    w32(16, 16);
    w16(20, 1); // PCM
    w16(22, 1); // Mono
    w32(24, sampleRate);
    w32(28, sampleRate * 2);
    w16(32, 2);
    w16(34, 16);
    data.buffer.asUint8List().setRange(36, 40, 'data'.codeUnits);
    w32(40, total * 2);

    // Generate sine wave
    final amp = 32767 * 0.3;
    var off = 44;
    for (var n = 0; n < total; n++) {
      final s = (sin(2 * pi * freqHz * (n / sampleRate)) * amp).round();
      data.setInt16(off, s, Endian.little);
      off += 2;
    }

    return data.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: const Text('Test Loa trong'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _finish(false),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Status indicator
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:
                      _hasDetectedNear
                          ? Colors.green.withValues(alpha: 0.2)
                          : Colors.blue.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _hasDetectedNear ? Colors.green : Colors.blue,
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _hasDetectedNear ? Icons.check_circle : Icons.sensors,
                      color: _hasDetectedNear ? Colors.green : Colors.blue,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _hasDetectedNear
                          ? 'Đã phát hiện cảm biến!'
                          : 'Đang chờ phát hiện...',
                      style: TextStyle(
                        color: _hasDetectedNear ? Colors.green : Colors.blue,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              // Animated phone icon
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  final scale = _isNear ? 1.1 : 1.0;
                  final opacity =
                      _isNear ? 1.0 : (0.5 + _pulseController.value * 0.5);

                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            _hasDetectedNear
                                ? Colors.green.withValues(alpha: opacity * 0.3)
                                : Colors.blue.withValues(alpha: opacity * 0.3),
                        boxShadow:
                            _isNear
                                ? [
                                  BoxShadow(
                                    color:
                                        _hasDetectedNear
                                            ? Colors.green.withValues(
                                              alpha: 0.5,
                                            )
                                            : Colors.blue.withValues(
                                              alpha: 0.5,
                                            ),
                                    blurRadius: 40,
                                    spreadRadius: 10,
                                  ),
                                ]
                                : null,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            Icons.phone_android,
                            size: 100,
                            color:
                                _hasDetectedNear ? Colors.green : Colors.blue,
                          ),
                          if (_isNear)
                            Positioned(
                              top: 30,
                              right: 50,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Colors.orange,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.sensors,
                                  size: 24,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 48),

              // Instructions
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      _hasDetectedNear
                          ? 'Tự động kết thúc sau 3 giây...'
                          : 'Hướng dẫn',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (!_hasDetectedNear) ...[
                      _buildInstructionStep(
                        '1',
                        'Đặt điện thoại sát tai',
                        Icons.phone_in_talk,
                      ),
                      const SizedBox(height: 12),
                      _buildInstructionStep(
                        '2',
                        'Cảm biến tiệm cận sẽ kích hoạt',
                        Icons.sensors,
                      ),
                      const SizedBox(height: 12),
                      _buildInstructionStep(
                        '3',
                        'Xác nhận nghe thấy âm thanh',
                        Icons.hearing,
                      ),
                    ] else
                      const Text(
                        'Đã phát hiện cảm biến tiệm cận!\nBạn có nghe thấy âm thanh từ loa trong không?',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStat(
                    'Trạng thái',
                    _isNear ? 'Gần' : 'Xa',
                    _isNear ? Colors.green : Colors.grey,
                  ),
                  _buildStat('Số lần', '$_nearCount', Colors.blue),
                  _buildStat(
                    'Âm thanh',
                    _isPlaying ? 'Đang phát' : 'Dừng',
                    _isPlaying ? Colors.orange : Colors.grey,
                  ),
                ],
              ),
            ],
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
                  onPressed: () => _finish(false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.close),
                  label: const Text('Không đạt'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _finish(true),
                  style: FilledButton.styleFrom(
                    backgroundColor:
                        _hasDetectedNear
                            ? Colors.green
                            : Colors.green.withOpacity(0.7),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.check),
                  label: Text(_hasDetectedNear ? 'Đạt' : 'Đạt (Thủ công)'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionStep(String number, String text, IconData icon) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildStat(String label, String value, Color color) {
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
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
