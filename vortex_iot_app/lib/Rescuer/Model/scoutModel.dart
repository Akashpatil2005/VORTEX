class ScoutStatusModel {
  final double temperature;
  final double humidity;
  final double pressure;
  final int gasLevel;
  final bool humanDetected;
  final double speed;
  final int distance;

  ScoutStatusModel({
    required this.temperature,
    required this.humidity,
    required this.pressure,
    required this.gasLevel,
    required this.humanDetected,
    required this.speed,
    required this.distance,
  });

  factory ScoutStatusModel.fromMap(Map<String, dynamic> map) {
    return ScoutStatusModel(
      temperature: (map['temperature'] ?? 0).toDouble(),
      humidity: (map['humidity'] ?? 0).toDouble(),
      pressure: (map['pressure'] ?? 0).toDouble(),
      gasLevel: map['gasLevel'] ?? 0,
      humanDetected: map['humanDetected'] ?? false,
      speed: (map['speed'] ?? 0).toDouble(),
      distance: map['distance'] ?? 0,
    );
  }

  ///  ESP32 / app updates Firebase
  Map<String, dynamic> toMap() {
    return {
      'temperature': temperature,
      'humidity': humidity,
      'pressure': pressure,
      'gasLevel': gasLevel,
      'humanDetected': humanDetected,
      'speed': speed,
      'distance': distance,
    };
  }
}
