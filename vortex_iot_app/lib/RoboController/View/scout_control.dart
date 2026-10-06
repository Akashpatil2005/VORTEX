import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;

class ScoutControlPage extends StatefulWidget {
  const ScoutControlPage({super.key});

  @override
  State<ScoutControlPage> createState() => _ScoutControlPageState();
}

class _ScoutControlPageState extends State<ScoutControlPage> {
  // 🔴 ESP32 IP
  static const String espIP = "10.89.72.103";

  // 🎤 Voice
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool listening = false;
  String spokenText = "Tap mic & speak";

  // ---------- HTTP ----------
  Future<void> send(String cmd) async {
    try {
      await http.get(Uri.parse("http://$espIP/$cmd"));
    } catch (_) {}
  }

  // ---------- VOICE ----------
  Future<void> startListening() async {
    final ok = await _speech.initialize();
    if (!ok) return;

    setState(() => listening = true);

    _speech.listen(
      listenMode: stt.ListenMode.confirmation,
      onResult: (r) {
        final text = r.recognizedWords.toLowerCase();
        setState(() => spokenText = text);
        _handleVoice(text);
      },
    );
  }

  void stopListening() {
    _speech.stop();
    setState(() => listening = false);
  } 

  void _handleVoice(String cmd) {
    if (cmd.contains("forward"))
      send("forward");
    else if (cmd.contains("back"))
      send("back");
    else if (cmd.contains("rotate left"))
      send("rotate_left");
    else if (cmd.contains("rotate right"))
      send("rotate_right");
    else if (cmd.contains("left"))
      send("left");
    else if (cmd.contains("right"))
      send("right");
    else if (cmd.contains("stop"))
      send("stop");
  }

  // ---------- CONTROL BUTTON ----------
  Widget controlBtn(
    IconData icon,
    String cmd, {
    double size = 65,
    Color color = Colors.white,
  }) {
    return IconButton(
      iconSize: size,
      color: color,
      icon: Icon(icon),
      onPressed: () => send(cmd),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F1A),
      appBar: AppBar(title: const Text("SCOUT CONTROL"), centerTitle: true),
      body: Column(
        children: [
          const SizedBox(height: 12),

          // 🎤 VOICE STATUS
          Text(spokenText, style: const TextStyle(color: Colors.orangeAccent)),

          IconButton(
            iconSize: 72,
            color: listening ? Colors.red : Colors.cyan,
            icon: Icon(listening ? Icons.mic : Icons.mic_none),
            onPressed: listening ? stopListening : startListening,
          ),

          const SizedBox(height: 20),

          // ⬆️ FORWARD
          controlBtn(Icons.keyboard_arrow_up, "forward"),

          const SizedBox(height: 10),

          // 🔄 ROTATE + STOP
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              controlBtn(Icons.rotate_left, "rotate_left"),
              controlBtn(Icons.stop, "stop", size: 78, color: Colors.red),
              controlBtn(Icons.rotate_right, "rotate_right"),
            ],
          ),

          const SizedBox(height: 10),

          // ⬇️ BACK
          controlBtn(Icons.keyboard_arrow_down, "back"),

          const SizedBox(height: 20),

          // ⬅️ ➡️ LEFT / RIGHT
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              controlBtn(Icons.arrow_left, "left"),
              controlBtn(Icons.arrow_right, "right"),
            ],
          ),

          const SizedBox(height: 30),

          // 🚨 EMERGENCY STOP
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            ),
            onPressed: () => send("stop"),
            child: const Text("EMERGENCY STOP"),
          ),
        ],
      ),
    );
  }
}
