import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class BreacherStatusPage extends StatefulWidget {
  const BreacherStatusPage({super.key});

  @override
  State<BreacherStatusPage> createState() => _BreacherStatusPageState();
}

class _BreacherStatusPageState extends State<BreacherStatusPage> {
  // 🔗 RTDB BACKBONE (DO NOT CHANGE)
  final DatabaseReference _breacherRef = FirebaseDatabase.instance.refFromURL(
    'https://vortex-fcee1-default-rtdb.asia-southeast1.firebasedatabase.app/breacher',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F1A),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Breacher Live Status',
          style: TextStyle(color: Colors.orange),
        ),
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: _breacherRef.onValue,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.orange),
            );
          }

          final root = Map<String, dynamic>.from(
            snapshot.data!.snapshot.value as Map,
          );

          final telemetry = Map<String, dynamic>.from(root['telemetry'] ?? {});

          // ---------- TELEMETRY VALUES ----------
          final int encoderLeft =
              (telemetry['encoder_left'] as num?)?.toInt() ?? 0;

          final int encoderRight =
              (telemetry['encoder_right'] as num?)?.toInt() ?? 0;

          final String mode = telemetry['mode']?.toString() ?? 'UNKNOWN';

          final double tilt = (telemetry['mpu_tilt'] as num?)?.toDouble() ?? 0;

          final int plowState = (telemetry['plow_state'] as num?)?.toInt() ?? 0;

          final double distance =
              (telemetry['ultrasonic_distance'] as num?)?.toDouble() ?? 0;

          // ---------- CALCULATIONS ----------
          final bool unstable = tilt.abs() > 0.2;
          final bool obstacle = distance > 0 && distance < 25;
          final bool plowActive = plowState == 1;

          final int avgEncoder = ((encoderLeft + encoderRight) / 2).round();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _sensorCard(
                  title: 'Control Mode',
                  value: mode,
                  message: 'Operation Mode',
                  icon: Icons.gamepad,
                ),

                _sensorCard(
                  title: 'Plow / Blade',
                  value: plowActive ? 'ACTIVE' : 'INACTIVE',
                  message: plowActive ? 'Clearing Debris' : 'Idle',
                  icon: Icons.construction,
                  alert: plowActive,
                ),

                _sensorCard(
                  title: 'Obstacle Ahead',
                  value: obstacle ? 'DETECTED' : 'CLEAR',
                  message: obstacle ? 'Obstacle Too Close' : 'Path Clear',
                  icon: Icons.warning,
                  alert: obstacle,
                ),

                _sensorCard(
                  title: 'Stability',
                  value: unstable ? 'UNSTABLE' : 'STABLE',
                  message: unstable ? 'Tilt Detected' : 'Orientation Normal',
                  icon: Icons.explore,
                  alert: unstable,
                ),

                // ---------- RAW TELEMETRY ----------
                _sensorCard(
                  title: 'Encoder Left',
                  value: encoderLeft.toString(),
                  message: 'Wheel Count',
                  icon: Icons.rotate_left,
                ),

                _sensorCard(
                  title: 'Encoder Right',
                  value: encoderRight.toString(),
                  message: 'Wheel Count',
                  icon: Icons.rotate_right,
                ),

                _sensorCard(
                  title: 'Average Encoder',
                  value: avgEncoder.toString(),
                  message: 'Movement Index',
                  icon: Icons.speed,
                ),

                _sensorCard(
                  title: 'Ultrasonic Distance',
                  value: distance.toStringAsFixed(1),
                  message: 'cm',
                  icon: Icons.straighten,
                ),

                _sensorCard(
                  title: 'MPU Tilt',
                  value: tilt.toStringAsFixed(3),
                  message: 'Radians',
                  icon: Icons.trending_up,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ---------- SENSOR CARD UI (SAME AS SCOUT) ----------
  Widget _sensorCard({
    required String title,
    required String value,
    required String message,
    required IconData icon,
    bool alert = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: alert
            ? Colors.redAccent.withOpacity(0.25)
            : const Color(0xFF121826),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: alert
                ? Colors.redAccent.withOpacity(0.4)
                : Colors.orange.withOpacity(0.3),
            blurRadius: 14,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 36, color: alert ? Colors.redAccent : Colors.orange),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.white70, fontSize: 15),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: TextStyle(
                  color: alert ? Colors.redAccent : Colors.orange,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                message,
                style: TextStyle(
                  color: alert ? Colors.redAccent : Colors.greenAccent,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
