/// Device Sensor Reading model
class DeviceReading {
  double d1;
  int d2;
  DateTime lastSeen;

  DeviceReading({
    required this.d1,
    required this.d2,
    required this.lastSeen,
  });

  factory DeviceReading.fromMap(Map data) {
    return DeviceReading(
      d1: data['d1'] != null
          ? (data['d1'] % 1 == 0 ? data['d1'] + 0.1 : data['d1'])
          : 0.0,
      d2: data['d2'] ?? 0,
      lastSeen: DateTime.fromMillisecondsSinceEpoch(data['ts']),
    );
  }
}

/// Device control model
class DeviceData {
  int servo1;
  int servo2;
  int servo3;
  bool isReadSensor;

  DeviceData({
    required this.servo1,
    required this.servo2,
    required this.servo3,
    required this.isReadSensor,
  });

  factory DeviceData.fromMap(Map data) {
    return DeviceData(
      servo1: data['servo1'] ?? 0,
      servo2: data['servo2'] ?? 0,
      servo3: data['servo3'] ?? 0,
      isReadSensor: data['isReadSensor'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'servo1': servo1,
        'servo2': servo2,
        'servo3': servo3,
        'isReadSensor': isReadSensor,
      };
}
