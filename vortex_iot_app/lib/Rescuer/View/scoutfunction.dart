import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ScoutStatusPage extends StatefulWidget {
  const ScoutStatusPage({super.key});

  @override
  State<ScoutStatusPage> createState() => _ScoutStatusPageState();
}

class _ScoutStatusPageState extends State<ScoutStatusPage> {
  final DatabaseReference _scoutRef = FirebaseDatabase.instance.refFromURL(
    'https://vortex-fcee1-default-rtdb.asia-southeast1.firebasedatabase.app/scout',
  );

  double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  int _toInt(dynamic v) => _toDouble(v).toInt();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F1A),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Scout Live Status',
          style: TextStyle(color: Colors.orange),
        ),
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: _scoutRef.onValue,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.orange),
            );
          }

          final root = Map<String, dynamic>.from(
            snapshot.data!.snapshot.value as Map,
          );

          final status = Map<String, dynamic>.from(root['status'] ?? {});
          final telemetry = Map<String, dynamic>.from(root['telemetry'] ?? {});

          // ---------- RAW → CONVERTED ----------
          final bool online = status['online'] ?? false;
          final String direction = status['direction'] ?? 'unknown';

          final double temperature =
              _toDouble(telemetry['dht22_temperature']) / 10;

          final double humidity = _toDouble(telemetry['dht22_humidity']) / 100;

          final int gas = _toInt(telemetry['gas_mq135']);
          final double distance = _toDouble(telemetry['ultrasonic_distance']);
          final double tilt = _toDouble(telemetry['mpu_tilt']);
          final int sound = _toInt(telemetry['sound_level']);
          final bool pirMotion = _toInt(telemetry['pir_motion']) == 1;
          final bool humanDetected = telemetry['human_detected'] == true;

          // ---------- CONDITIONS ----------
          final bool fireTemp = temperature > 60;
          final bool airUnsafe = gas > 3000;
          final bool blocked = distance > 0 && distance < 20;
          final bool unstable = tilt.abs() > 0.2;
          final bool loudSound = sound > 800;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _sensorCard(
                  title: 'Scout Status',
                  value: online ? 'ONLINE' : 'OFFLINE',
                  message: 'Direction: $direction',
                  icon: Icons.wifi_tethering,
                  alert: !online,
                ),

                _sensorCard(
                  title: '🔥 Temperature',
                  value: '${temperature.toStringAsFixed(1)} °C',
                  message: fireTemp ? 'High Temperature' : 'Normal',
                  icon: Icons.thermostat,
                  alert: fireTemp,
                ),

                _sensorCard(
                  title: '💧 Humidity',
                  value: '${humidity.toStringAsFixed(1)} %',
                  message: humidity < 30 ? 'Low Humidity' : 'Normal',
                  icon: Icons.water_drop,
                  alert: humidity < 30,
                ),

                _sensorCard(
                  title: '🧪 Gas (MQ-135)',
                  value: gas.toString(),
                  message: airUnsafe ? 'Toxic Level' : 'Safe',
                  icon: Icons.warning_amber,
                  alert: airUnsafe,
                ),

                _sensorCard(
                  title: '📏 Distance',
                  value: distance >= 999
                      ? 'Out of Range'
                      : '${distance.toStringAsFixed(1)} cm',
                  message: blocked ? 'Obstacle Near' : 'Clear',
                  icon: Icons.straighten,
                  alert: blocked,
                ),

                _sensorCard(
                  title: '📐 Tilt',
                  value: tilt.toStringAsFixed(2),
                  message: unstable ? 'Unstable' : 'Stable',
                  icon: Icons.explore,
                  alert: unstable,
                ),

                _sensorCard(
                  title: '🧍 Human Presence',
                  value: (humanDetected || pirMotion) ? 'DETECTED' : 'NONE',
                  message: pirMotion ? 'Motion Active' : 'No Motion',
                  icon: Icons.person_search,
                  alert: humanDetected || pirMotion,
                ),

                _sensorCard(
                  title: '🔊 Sound Level',
                  value: sound.toString(),
                  message: loudSound ? 'Loud Noise' : 'Normal',
                  icon: Icons.graphic_eq,
                  alert: loudSound,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

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
                ? Colors.redAccent.withOpacity(0.45)
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
