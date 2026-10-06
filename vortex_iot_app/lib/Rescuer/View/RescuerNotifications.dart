import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class RescueNotificationPage extends StatelessWidget {
  RescueNotificationPage({super.key});

  // 🔗 RTDB CONNECTIONS (DO NOT CHANGE STYLE)
  final DatabaseReference _scoutRef = FirebaseDatabase.instance.refFromURL(
    'https://vortex-fcee1-default-rtdb.asia-southeast1.firebasedatabase.app/scout',
  );

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
          'Rescue Alerts',
          style: TextStyle(color: Colors.orange),
        ),
      ),

      // 🔴 FIRST STREAM → SCOUT
      body: StreamBuilder<DatabaseEvent>(
        stream: _scoutRef.onValue,
        builder: (context, scoutSnap) {
          if (!scoutSnap.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.orange),
            );
          }

          final scoutRoot = scoutSnap.data!.snapshot.value as Map? ?? {};
          final scoutTelemetry = Map<String, dynamic>.from(
            scoutRoot['telemetry'] ?? {},
          );

          // 🟠 SECOND STREAM → BREACHER
          return StreamBuilder<DatabaseEvent>(
            stream: _breacherRef.onValue,
            builder: (context, breacherSnap) {
              if (!breacherSnap.hasData) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.orange),
                );
              }

              final breacherRoot =
                  breacherSnap.data!.snapshot.value as Map? ?? {};
              final breacherTelemetry = Map<String, dynamic>.from(
                breacherRoot['telemetry'] ?? {},
              );

              final alerts = _buildAlerts(scoutTelemetry, breacherTelemetry);

              if (alerts.isEmpty) {
                return const Center(
                  child: Text(
                    '✅ No active alerts',
                    style: TextStyle(color: Colors.greenAccent, fontSize: 18),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: alerts.length,
                itemBuilder: (context, index) {
                  return _alertCard(alerts[index]);
                },
              );
            },
          );
        },
      ),
    );
  }

  // 🚨 ALERT ENGINE (ALL LOGIC HERE)
  List<_Alert> _buildAlerts(
    Map<String, dynamic> scout,
    Map<String, dynamic> breacher,
  ) {
    final List<_Alert> alerts = [];

    // ===== SCOUT DATA =====
    final double temp = (scout['dht22_temperature'] as num?)?.toDouble() ?? 0;
    final double hum = (scout['dht22_humidity'] as num?)?.toDouble() ?? 0;
    final int gas = (scout['gas_mq135'] as num?)?.toInt() ?? 0;
    final bool human = scout['human_detected'] == true;
    final int pir = (scout['pir_motion'] as num?)?.toInt() ?? 0;
    final int sound = (scout['sound_level'] as num?)?.toInt() ?? 0;
    final double scoutTilt = (scout['mpu_tilt'] as num?)?.toDouble() ?? 0;

    // 🔥 FIRE / GAS ALERT
    if (temp > 60 || gas > 3000 || hum < 30) {
      alerts.add(
        _Alert(
          icon: Icons.local_fire_department,
          title: 'Fire Risk Detected',
          message: 'High temperature or toxic gas',
          severity: 'HIGH',
        ),
      );
    }

    // ☠️ TOXIC AIR
    if (gas > 3000) {
      alerts.add(
        _Alert(
          icon: Icons.warning_amber,
          title: 'Toxic Air Detected',
          message: 'Unsafe breathing conditions',
          severity: 'CRITICAL',
        ),
      );
    }

    // 🧍 HUMAN DETECTED
    if (human || pir == 1) {
      alerts.add(
        _Alert(
          icon: Icons.person_search,
          title: 'Human Presence Detected',
          message: 'Possible survivor nearby',
          severity: 'CRITICAL',
        ),
      );
    }

    // 🔊 SOUND ALERT
    if (sound > 3500) {
      alerts.add(
        _Alert(
          icon: Icons.graphic_eq,
          title: 'Distress Sound Detected',
          message: 'Possible shout or impact',
          severity: 'MEDIUM',
        ),
      );
    }

    // ⚠️ SCOUT UNSTABLE
    if (scoutTilt.abs() > 3) {
      alerts.add(
        _Alert(
          icon: Icons.explore,
          title: 'Scout Unstable',
          message: 'Tilt or slope detected',
          severity: 'MEDIUM',
        ),
      );
    }

    // ===== BREACHER DATA =====
    final double breacherTilt = (breacher['mpu_tilt'] as num?)?.toDouble() ?? 0;
    final double distance =
        (breacher['ultrasonic_distance'] as num?)?.toDouble() ?? 999;

    // 🚧 OBSTACLE
    if (distance > 0 && distance < 25) {
      alerts.add(
        _Alert(
          icon: Icons.block,
          title: 'Obstacle Ahead',
          message: 'Breacher path blocked',
          severity: 'MEDIUM',
        ),
      );
    }

    // ⚠️ BREACHER UNSTABLE
    if (breacherTilt.abs() > 3) {
      alerts.add(
        _Alert(
          icon: Icons.warning,
          title: 'Breacher Unstable',
          message: 'Tilt detected',
          severity: 'MEDIUM',
        ),
      );
    }

    return alerts;
  }

  // 🎴 ALERT CARD UI
  Widget _alertCard(_Alert alert) {
    final Color color = alert.severity == 'CRITICAL'
        ? Colors.redAccent
        : alert.severity == 'HIGH'
        ? Colors.orange
        : Colors.yellow;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 14)],
      ),
      child: Row(
        children: [
          Icon(alert.icon, size: 36, color: color),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.title,
                  style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  alert.message,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  'Severity: ${alert.severity}',
                  style: TextStyle(color: color, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 🧩 ALERT MODEL
class _Alert {
  final IconData icon;
  final String title;
  final String message;
  final String severity;

  _Alert({
    required this.icon,
    required this.title,
    required this.message,
    required this.severity,
  });
}
