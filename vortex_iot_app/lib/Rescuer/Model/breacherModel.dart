class BreacherStatusModel {
  final bool humanDetected;
  final double speed;
  final int distance;
  final DateTime lastUpdated;

  BreacherStatusModel({
    required this.humanDetected,
    required this.speed,
    required this.distance,
    required this.lastUpdated,
  });

  // From Firebase / ESP32 JSON
  factory BreacherStatusModel.fromMap(Map<String, dynamic> map) {
    return BreacherStatusModel(
      humanDetected: map['humanDetected'] ?? false,
      speed: (map['speed'] ?? 0).toDouble(),
      distance: map['distance'] ?? 0,
      lastUpdated: DateTime.now(),
    );
  }

  // Obj To Firebase (optional)
  Map<String, dynamic> toMap() {
    return {
      'humanDetected': humanDetected,
      'speed': speed,
      'distance': distance,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}
