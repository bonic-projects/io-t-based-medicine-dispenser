import 'package:medicine/app/app.logger.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:stacked/stacked.dart';

import '../models/device.dart';

class RtdbService with ListenableServiceMixin {
  final log = getLogger('RealTimeDB_Service');

  final FirebaseDatabase _db = FirebaseDatabase.instance;

  DeviceReading? _node;
  DeviceReading? get node => _node;
  DeviceReading2? _node2;
  DeviceReading2? get node2 => _node2;

  void setupNodeListening() {
    DatabaseReference starCountRef =
        _db.ref('/atm/0LwxBGgKNldol0sFQtowGUk5YDa2/reading/');
    starCountRef.onValue.listen((DatabaseEvent event) {
      if (event.snapshot.exists) {
        _node = DeviceReading.fromMap(event.snapshot.value as Map);
        log.v(_node?.lastSeen); //data['time']
        notifyListeners();
      }
    });
  }

  void setupNode2Listening() {
    DatabaseReference starCountRef =
        _db.ref('/atm/0LwxBGgKNldol0sFQtowGUk5YDa2/reading2/');
    starCountRef.onValue.listen((DatabaseEvent event) {
      if (event.snapshot.exists) {
        _node2 = DeviceReading2.fromMap(event.snapshot.value as Map);
        log.v(_node2?.lastSeen); //data['time']
        notifyListeners();
      }
    });
  }

  Future<DeviceData?> getDeviceData() async {
    DatabaseReference dataRef =
        _db.ref('/atm/0LwxBGgKNldol0sFQtowGUk5YDa2/data/');
    final value = await dataRef.once();
    if (value.snapshot.exists) {
      return DeviceData.fromMap(value.snapshot.value as Map);
    }
    return null;
  }

  void setDeviceData(DeviceData data) {
    log.i("Setting device data");
    DatabaseReference dataRef =
        _db.ref('/atm/0LwxBGgKNldol0sFQtowGUk5YDa2/data');
    dataRef.update(data.toJson());
  }
}
