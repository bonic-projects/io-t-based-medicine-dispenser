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
  DeviceReading2? get node2 => _dbService.node2;

  bool _isOnline = false;
  bool get isOnline => _isOnline;
  bool _isOnlineBand = false;
  bool get isOnlineBand => _isOnlineBand;

  bool isOnlineCheck(DateTime? time) {
    // log.i(" Online check");
    if (time == null) return false;
    final DateTime now = DateTime.now();
    final difference = now.difference(time).inSeconds;
    // log.i("Status $difference ");
    return difference >= 0 && difference <= 8;
  }

  late Timer timer;

  void setTimer() {
    log.i("Setting timer");
    const oneSec = Duration(seconds: 1);
    timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        _isOnline = isOnlineCheck(node?.lastSeen);
        _isOnlineBand = isOnlineCheck(node2?.lastSeen);
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }
}
