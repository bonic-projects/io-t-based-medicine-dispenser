import 'dart:async';

import 'package:medicine/app/app.locator.dart';
import 'package:medicine/app/app.logger.dart';
import 'package:medicine/models/device.dart';
import 'package:medicine/services/rtdb_service.dart';
import 'package:stacked/stacked.dart';

class DeviceControlViewModel extends ReactiveViewModel {
  final log = getLogger('DeviceControlWidget');
  final _dbService = locator<RtdbService>();

  @override
  List<ListenableServiceMixin> get listenableServices => [_dbService];

  final int _servoMinAngle = 50;
  int get servoMinAngle => _servoMinAngle;
  final int _servoMaxAngle = 140;
  int get servoMaxAngle => _servoMaxAngle;

  void setServo1() {
    if (_deviceData.servo1 == _servoMinAngle) {
      _deviceData.servo1 = servoMaxAngle;
    } else {
      _deviceData.servo1 = _servoMinAngle;
    }
    setDeviceData();
    notifyListeners();
  }

  void setServo2() {
    if (_deviceData.servo2 == _servoMinAngle) {
      _deviceData.servo2 = servoMaxAngle;
    } else {
      _deviceData.servo2 = _servoMinAngle;
    }
    setDeviceData();
    notifyListeners();
  }

  void setServo3(double value) {
    _deviceData.servo3 = value.toInt();
    notifyListeners();
    // setDeviceData();
  }

  ///RTDB======================================================
  DeviceReading? get node => _dbService.node;
  void setupDevice() {
    log.i("Setting up listening from robot");
    if (node == null) {
      _dbService.setupNodeListening();
    }
    //Getting servo angle
    getDeviceData();
  }

  DeviceData _deviceData = DeviceData(
    servo1: 40,
    servo2: 40,
    servo3: 90,
    isReadSensor: false,
  );
  DeviceData get deviceData => _deviceData;

  void setDeviceData() {
    _dbService.setDeviceData(_deviceData);
  }

  void getDeviceData() async {
    setBusy(true);
    DeviceData? deviceData = await _dbService.getDeviceData();
    if (deviceData != null) {
      _deviceData = DeviceData(
          servo1: deviceData.servo1,
          servo2: deviceData.servo2,
          servo3: deviceData.servo3,
          isReadSensor: deviceData.isReadSensor);
    }
    setBusy(false);
  }
}
