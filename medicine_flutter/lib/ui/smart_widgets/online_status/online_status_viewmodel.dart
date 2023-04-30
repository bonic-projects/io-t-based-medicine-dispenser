import 'dart:async';

import 'package:medicine/app/app.locator.dart';
import 'package:medicine/app/app.logger.dart';
import 'package:medicine/models/device.dart';
import 'package:medicine/services/rtdb_service.dart';
import 'package:stacked/stacked.dart';

class OnlineStatusViewModel extends BaseViewModel {
  final log = getLogger('StatusWidget');

  final _dbService = locator<RtdbService>();

  DeviceReading? get node => _dbService.node;

  bool _isOnline = false;
  bool get isOnline => _isOnline;

  bool isOnlineCheck(DateTime? time) {
    // log.i(" Online check");
    if (time == null) return false;
    final DateTime now = DateTime.now();
    final difference = now.difference(time).inSeconds;
    // log.i("Status $time");
    return difference >= 0 && difference <= 4;
  }

  late Timer timer;

  void setTimer() {
    log.i("Setting timer");
    const oneSec = Duration(seconds: 1);
    timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        _isOnline = isOnlineCheck(node?.lastSeen);
        notifyListeners();
      },
    );
  }
}
