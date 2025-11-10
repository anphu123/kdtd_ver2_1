import 'dart:math';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class SpeakerTestPage extends StatefulWidget {
  const SpeakerTestPage({super.key});

  @override
  State<SpeakerTestPage> createState() => _SpeakerTestPageState();
}

class _SpeakerTestPageState extends State<SpeakerTestPage> {
  final _player = AudioPlayer();
  bool _playing = false;

  @override
  void initState() { super.initState(); _playBeepLoop(); }

  @override
  void dispose() { _player.stop(); _player.dispose(); super.dispose(); }

  Future<void> _playBeepLoop() async {
    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.play(BytesSource(_genSineWavBytes()));
    setState(() => _playing = true);
  }

  Uint8List _genSineWavBytes({int sampleRate=44100, int seconds=1, double freqHz=880}) {
    final total = sampleRate * seconds;
    final data = ByteData(44 + total * 2);
    void w8(int o,int v)=>data.setUint8(o,v);
    void w16(int o,int v)=>data.setUint16(o,v,Endian.little);
    void w32(int o,int v)=>data.setUint32(o,v,Endian.little);
    data.buffer.asUint8List().setRange(0,4,'RIFF'.codeUnits); w32(4,36+total*2);
    data.buffer.asUint8List().setRange(8,12,'WAVE'.codeUnits);
    data.buffer.asUint8List().setRange(12,16,'fmt '.codeUnits); w32(16,16); w16(20,1); w16(22,1);
    w32(24,sampleRate); w32(28,sampleRate*2); w16(32,2); w16(34,16);
    data.buffer.asUint8List().setRange(36,40,'data'.codeUnits); w32(40,total*2);
    final amp = 32767 * 0.5; var off = 44;
    for (var n=0; n<total; n++) {
      final s = (sin(2*pi*freqHz*(n/sampleRate))*amp).round();
      data.setInt16(off, s, Endian.little); off += 2;
    }
    return data.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Loa ngoài')),
      body: Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(_playing ? Icons.volume_up_rounded : Icons.volume_mute, size: 96),
          const SizedBox(height: 12),
          const Text('Bạn có nghe tiếng beep rõ không?'),
        ],
      )),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            Expanded(child: OutlinedButton.icon(onPressed: ()=>Navigator.pop(context,false), icon: const Icon(Icons.close), label: const Text('Không đạt'))),
            const SizedBox(width: 12),
            Expanded(child: FilledButton.icon(onPressed: ()=>Navigator.pop(context,true), icon: const Icon(Icons.check), label: const Text('Đạt'))),
          ]),
        ),
      ),
    );
  }
}
