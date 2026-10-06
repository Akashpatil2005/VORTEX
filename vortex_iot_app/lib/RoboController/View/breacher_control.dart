import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;

class BreacherControl extends StatefulWidget {
  const BreacherControl({super.key});

  @override
  State<BreacherControl> createState() => _BreacherControlState();
}

class _BreacherControlState extends State<BreacherControl> {
  // 🔴 BREACHER ESP IP
  static const String espIP = "10.89.72.187";

  // 🎤 VOICE
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool listening = false;
  String spokenText = "Tap mic & speak";

  // ---------- HTTP ----------
  Future<void> send(String cmd) async {
    try {
      await http.get(Uri.parse("http://$espIP/$cmd"));
    } catch (_) {}
  }

  // ----- VOICE
  Future<void> startListening() async {
    final ok = await _speech.initialize();
    if (!ok) return;

    setState(() => listening = true);

    _speech.listen(
      listenMode: stt.ListenMode.confirmation,
      onResult: (r) {
        final cmd = r.recognizedWords.toLowerCase();
        setState(() => spokenText = cmd);
        _handleVoice(cmd);
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
    else if (cmd.contains("auto"))
      send("auto");
    else if (cmd.contains("manual")) {
      send("manual");
      send("stop");
    }
  }

  // ---------- BUTTON ----------
  Widget btn(
    IconData icon,
    String cmd, {
    double size = 75,
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
      appBar: AppBar(
        title: const Text("BREACHER CONTROL"),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),

          // 🎤 VOICE STATUS
          Text(spokenText, style: const TextStyle(color: Colors.orangeAccent)),

          IconButton(
            iconSize: 72,
            color: listening ? Colors.redAccent : Colors.white,
            icon: Icon(listening ? Icons.mic : Icons.mic_none),
            onPressed: listening ? stopListening : startListening,
          ),

          const SizedBox(height: 12),

          // ---- MODES ----
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  send("manual");
                  send("stop");
                },
                child: const Text("MANUAL"),
              ),
              ElevatedButton(
                onPressed: () {
                  send("auto");
                },
                child: const Text("AUTO"),
              ),
            ],
          ),

          const SizedBox(height: 30),

          // ---- FORWARD ----
          btn(Icons.keyboard_arrow_up, "forward"),

          const SizedBox(height: 12),

          // ---- ROTATE + STOP ----
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              btn(Icons.rotate_left, "rotate_left"),
              btn(Icons.stop, "stop", size: 85, color: Colors.redAccent),
              btn(Icons.rotate_right, "rotate_right"),
            ],
          ),

          const SizedBox(height: 12),

          // ---- BACK ----
          btn(Icons.keyboard_arrow_down, "back"),

          const SizedBox(height: 20),

          // ---- LEFT / RIGHT ----
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              btn(Icons.arrow_left, "left"),
              btn(Icons.arrow_right, "right"),
            ],
          ),

          const SizedBox(height: 30),

          // ---- EMERGENCY ----
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 18),
            ),
            onPressed: () {
              send("stop");
              send("manual");
            },
            child: const Text("EMERGENCY STOP", style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }
}
