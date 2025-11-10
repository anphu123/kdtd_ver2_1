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

class _EarpieceTestPageState extends State<EarpieceTestPage> {
  final _player = AudioPlayer();
  StreamSubscription<int>? _sub;
  bool _nearOnce = false;

  @override
  void initState(){ super.initState(); _start(); }

  @override
  void dispose(){ _sub?.cancel(); _player.stop(); _player.dispose(); super.dispose(); }

  Future<void> _start() async {
    await _player.setVolume(0.3);
    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.play(BytesSource(_genSineWavBytes()));
    _sub = ProximitySensor.events.listen((v){ if (v > 0) _nearOnce = true; });
  }

  Uint8List _genSineWavBytes({int sampleRate=44100, int seconds=1, double freqHz=660}) {
    final total = sampleRate * seconds;
    final data = ByteData(44 + total * 2);
    void w16(int o,int v)=>data.setUint16(o,v,Endian.little);
    void w32(int o,int v)=>data.setUint32(o,v,Endian.little);
    data.buffer.asUint8List().setRange(0,4,'RIFF'.codeUnits); w32(4,36+total*2);
    data.buffer.asUint8List().setRange(8,12,'WAVE'.codeUnits);
    data.buffer.asUint8List().setRange(12,16,'fmt '.codeUnits); w32(16,16); w16(20,1); w16(22,1);
    w32(24,sampleRate); w32(28,sampleRate*2); w16(32,2); w16(34,16);
    data.buffer.asUint8List().setRange(36,40,'data'.codeUnits); w32(40,total*2);
    final amp = 32767 * 0.25; var off = 44;
    for (var n=0; n<total; n++){
      final s = (sin(2*pi*freqHz*(n/sampleRate))*amp).round();
      data.setInt16(off, s, Endian.little); off += 2;
    }
    return data.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Loa trong')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Áp điện thoại sát tai (cảm biến tiệm cận kích hoạt) và xác nhận nghe rõ.'),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            Expanded(child: OutlinedButton.icon(onPressed: ()=>Navigator.pop(context,false), icon: const Icon(Icons.close), label: const Text('Không đạt'))),
            const SizedBox(width: 12),
            Expanded(child: FilledButton.icon(onPressed: ()=>Navigator.pop(context,_nearOnce), icon: const Icon(Icons.check), label: const Text('Đạt'))),
          ]),
        ),
      ),
    );
  }
}
