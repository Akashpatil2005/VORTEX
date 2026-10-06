import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

class ControllerScreen extends StatefulWidget {
  const ControllerScreen({super.key});

  @override
  State<ControllerScreen> createState() => _ControllerScreenState();
}
 final String baseUrl = "http://192.168.4.1";
  final String streamUrl = "http://10.128.57.174/stream";
class _ControllerScreenState extends State<ControllerScreen> {
  bool isManual = true;

  // 🔴 ESP32 IP
  final String baseUrl = "http://192.168.4.1";

  @override
  void deactivate() {
    // Restore portrait whenever screen is left
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.deactivate();
  }

  @override
  void dispose() {
    // Also restore portrait on dispose
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  // ================= HTTP SEND =================
  Future<void> sendCommand(String path) async {
    try {
      await http.get(Uri.parse("$baseUrl$path"));
      log("Sent: $path");
    } catch (e) {
      log("HTTP Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // ================= LIVE STREAM ON TOP =================
              Container(
                width: double.infinity,
                height: h * 0.4,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.cyanAccent, width: 1.5),
                ),
                alignment: Alignment.center,
                child: const Text(
                  "LIVE STREAM",
                  style: TextStyle(color: Colors.white54, letterSpacing: 1),
                ),
              ),

              const SizedBox(height: 32),

              // ================= ARROWS =================
              SizedBox(
                height: h * 0.25,
                width: double.infinity,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      top: 0,
                      child: _arrow(Icons.keyboard_arrow_up, "/move/forward"),
                    ),
                    Positioned(
                      bottom: 0,
                      child: _arrow(
                        Icons.keyboard_arrow_down,
                        "/move/backward",
                      ),
                    ),
                    Positioned(
                      left: 0,
                      child: _arrow(Icons.keyboard_arrow_left, "/move/left"),
                    ),
                    Positioned(
                      right: 0,
                      child: _arrow(Icons.keyboard_arrow_right, "/move/right"),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // ================= MANUAL / AUTO + BRAKE =================
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          isManual = !isManual;
                          sendCommand(isManual ? "/mode/manual" : "/mode/auto");
                          sendCommand("/move/stop");
                        });
                      },
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: isManual ? Colors.blue : Colors.deepPurple,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          isManual ? "MANUAL" : "AUTO",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => sendCommand("/move/stop"),
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          "BRAKE",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= ARROW BUTTON =================
  Widget _arrow(IconData icon, String command) {
    return GestureDetector(
      onTapDown: (_) => sendCommand(command),
      onTapUp: (_) => sendCommand("/move/stop"),
      onTapCancel: () => sendCommand("/move/stop"),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.1,
        width: MediaQuery.of(context).size.width * 0.4,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF2A2E34),
          border: Border.all(color: Colors.cyanAccent, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.cyanAccent.withOpacity(0.4),
              blurRadius: 10,
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 40),
      ),
    );
  }
}
