import 'dart:async';

import 'package:medicine/app/app.locator.dart';
import 'package:medicine/app/app.logger.dart';
import 'package:medicine/models/appuser.dart';
import 'package:medicine/models/device.dart';
import 'package:medicine/services/rtdb_service.dart';
import 'package:medicine/services/user_service.dart';
import 'package:stacked/stacked.dart';

class DeviceControlViewModel extends ReactiveViewModel {
  final log = getLogger('DeviceControlWidget');
  final _dbService = locator<RtdbService>();
  final _userService = locator<UserService>();

  AppUser? get user => _userService.user;

  @override
  List<ListenableServiceMixin> get listenableServices => [_dbService];

  final int _servoMinAngle = 50;
  int get servoMinAngle => _servoMinAngle;
  final int _servoMaxAngle = 140;
  int get servoMaxAngle => _servoMaxAngle;

  void setServo1({bool? isOpen}) {
    if (isOpen != null) {
      if (isOpen) {
        _deviceData!.servo1 = servoMaxAngle;
      } else {
        _deviceData!.servo1 = _servoMinAngle;
      }
    }

    if (_deviceData!.servo1 == _servoMinAngle) {
      _deviceData!.servo1 = servoMaxAngle;
    } else {
      _deviceData!.servo1 = _servoMinAngle;
    }
    setDeviceData();
    notifyListeners();
  }

  void setServo2({bool? isOpen}) {
    if (isOpen != null) {
      if (isOpen) {
        _deviceData!.servo2 = servoMaxAngle;
      } else {
        _deviceData!.servo2 = _servoMinAngle;
      }
    }

    if (_deviceData!.servo2 == _servoMinAngle) {
      _deviceData!.servo2 = servoMaxAngle;
    } else {
      _deviceData!.servo2 = _servoMinAngle;
    }
    setDeviceData();
    notifyListeners();
  }

  void setRedLed() {
    _deviceData!.redLed = !_deviceData!.redLed;
    setDeviceData();
    notifyListeners();
  }

  void setGreenLed() {
    _deviceData!.greenLed = !_deviceData!.greenLed;
    setDeviceData();
    notifyListeners();
  }

  void setBuzzer() {
    _deviceData!.buzzer = !_deviceData!.buzzer;
    setDeviceData();
    notifyListeners();
  }

  void setReset() {
    _deviceData!.reset = !_deviceData!.reset;
    setDeviceData();
    // notifyListeners();
  }

  void changeM1(bool isIncrement) {
    if (isIncrement) {
      _deviceData!.m1++;
    } else {
      _deviceData!.m1--;
    }
    setDeviceData();
    notifyListeners();
  }

  void changeM2(bool isIncrement) {
    if (isIncrement) {
      _deviceData!.m2++;
    } else {
      _deviceData!.m2--;
    }
    setDeviceData();
    notifyListeners();
  }

  ///RTDB======================================================
  DeviceReading? get node => _dbService.node;
  DeviceReading2? get node2 => _dbService.node2;
  void setupDevice() {
    log.i("Setting up listening from robot");
    if (node == null) {
      _dbService.setupNodeListening();
      _dbService.setupNode2Listening();
    }
    //Getting servo angle
    getDeviceData();
  }

  DeviceData? _deviceData;
  DeviceData? get deviceData => _deviceData;

  void setDeviceData() {
    _dbService.setDeviceData(_deviceData!);
  }

  void getDeviceData() async {
    setBusy(true);
    if (user == null) await _userService.fetchUser();
    DeviceData? deviceData = await _dbService.getDeviceData();
    if (deviceData != null) {
      _deviceData = DeviceData(
        servo1: deviceData.servo1,
        servo2: deviceData.servo2,
        redLed: deviceData.redLed,
        greenLed: deviceData.greenLed,
        buzzer: deviceData.buzzer,
        reset: deviceData.reset,
        m1: deviceData.m1,
        m2: deviceData.m2,
      );
    }
    setBusy(false);
  }

  ///=======================
  bool _isDispensing = false;
  bool get isDispensing => _isDispensing;
  String _status = "";
  String get status => _status;

  bool _isStatus = false;
  bool get isStatus => _isStatus;
  void setStatusView() {
    _isStatus = !_isStatus;
    notifyListeners();
  }

  void dispense(int m) async {
    setReset();
    _isDispensing = true;
    _status = "Dispensing started..";
    notifyListeners();
    await Future.delayed(const Duration(seconds: 2));
    _status = "Enter you pin";
    notifyListeners();
    await Future.delayed(const Duration(seconds: 8));
    if (user!.pin == node2!.pin) {
      _status = "Pin passed";
      notifyListeners();
      await Future.delayed(const Duration(seconds: 2));
      _status = "Scan you RFID";
      notifyListeners();
      await Future.delayed(const Duration(seconds: 5));
      if (user!.rfid == node!.rfid) {
        _status = "User verified";
        notifyListeners();
        await Future.delayed(const Duration(seconds: 1));
        rightInput("Dispensing medicine");
        await Future.delayed(const Duration(seconds: 1));
        if (m == 1) {
          setServo1();
          await Future.delayed(const Duration(seconds: 1));
          setServo1();
          await Future.delayed(const Duration(seconds: 1));

          changeM1(false);
        } else {
          setServo2();
          await Future.delayed(const Duration(seconds: 1));
          setServo2();
          await Future.delayed(const Duration(seconds: 1));
          changeM2(false);
        }
        rightInput("Thank you for visiting!");
        await Future.delayed(const Duration(seconds: 3));
      } else if (node2!.pin.isNotEmpty) {
        await wrongInput("Wrong RFID input, retry");
      } else {
        await wrongInput("No RFID input, Time out!");
      }
    } else if (node2!.pin.isNotEmpty) {
      await wrongInput("Wrong pin, retry");
    } else {
      await wrongInput("No pin input, Time out!");
    }

    _isDispensing = false;
    notifyListeners();
  }

  Future wrongInput(String text) async {
    _status = text;
    setRedLed();
    setBuzzer();
    await Future.delayed(const Duration(seconds: 1));
    setRedLed();
    setBuzzer();
  }

  Future rightInput(String text) async {
    _status = text;
    setGreenLed();
    // await Future.delayed(const Duration(seconds: 1));
    // setGreenLed();
  }
}
