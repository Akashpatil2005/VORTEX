import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ScoutLiveCamPage extends StatefulWidget {
  const ScoutLiveCamPage({super.key});

  @override
  State<ScoutLiveCamPage> createState() => _ScoutLiveCamPageState();
}

class _ScoutLiveCamPageState extends State<ScoutLiveCamPage> {
  // ================= CONFIG =================
  final String streamUrl = "http://10.89.72.120/stream";

  late final WebViewController _controller;

  // ================= INIT =================
  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      // 🔥 FIX: HTML WRAPPER FOR FULL SIZE STREAM
      ..loadHtmlString(_htmlWrapper(streamUrl));
  }

  // ================= DISPOSE =================
  @override
  void dispose() {
    _controller.loadHtmlString("<html><body></body></html>");
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  // ================= HTML STREAM FIX =================
  String _htmlWrapper(String url) {
    return '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <style>
    html, body {
      margin: 0;
      padding: 0;
      width: 100%;
      height: 100%;
      background: black;
      overflow: hidden;
    }
    img {
      width: 100%;
      height: 100%;
      object-fit: cover;
    }
  </style>
</head>
<body>
  <img src="$url">
</body>
</html>
''';
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // ================= HEADER =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  const Icon(Icons.videocam, color: Colors.green),
                  const SizedBox(width: 8),
                  const Text(
                    "SCOUT LIVE FEED",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const Spacer(),
                  _liveBadge(),
                ],
              ),
            ),

            // ================= CAMERA FRAME =================
            Expanded(
              child: Center(
                child: Container(
                  width: w * 0.95,
                  height: h * 0.6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromARGB(255, 255, 213, 0),
                        Color.fromARGB(255, 0, 255, 72),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.6),
                        blurRadius: 25,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(3),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        children: [
                          // ================= LIVE STREAM =================
                          WebViewWidget(controller: _controller),

                          // ================= HUD =================
                          Positioned(
                            bottom: 12,
                            left: 12,
                            child: _hudChip("CAM: ESP32"),
                          ),
                          Positioned(
                            bottom: 12,
                            right: 12,
                            child: _hudChip("STATUS: LIVE"),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ================= INFO BAR =================
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF0E1117),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green, width: 1),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _InfoItem(label: "STATUS", value: "CONNECTED"),
                  _InfoItem(label: "SIGNAL", value: "GOOD"),
                ],
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ================= LIVE BADGE =================
  Widget _liveBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.redAccent,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.redAccent.withOpacity(0.6), blurRadius: 10),
        ],
      ),
      child: const Text(
        "LIVE",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  // ================= HUD CHIP =================
  Widget _hudChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.green),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.greenAccent,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ================= INFO ITEM =================
class _InfoItem extends StatelessWidget {
  final String label;
  final String value;

  const _InfoItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.green,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11),
        ),
      ],
    );
  }
}
