import 'dart:async';

import '../handlers/download-handler.dart';
import '../utils/global-utils.dart';

/// Checks the server each 0.5 seconds to see if anything has changed and updates:
/// * The current lyrics
/// * The current schedule
/// * The current status (like which buttons are active)
class SyncHandler {
  Timer timer;
  Function setLiveItem;
  Function setSchedule;
  Function setBlack;
  bool isConnected = false;

  setFunctions(setLiveItem, setSchedule, setBlack) {
    this.setLiveItem = setLiveItem;
    this.setSchedule = setSchedule;
    this.setBlack = setBlack;
  }

  start() {
    if (timer == null || !timer.isActive) {
      timer = Timer.periodic(Duration(milliseconds: 500), (t) {
        DownloadHandler().download(url + "/lyrics", setLiveItem);
        DownloadHandler().download(url + "/schedule", setSchedule);
        DownloadHandler().download(url + "/status", setBlack);
      });
    }
  }

  stop() {
    if (timer != null && timer.isActive) {
      timer.cancel();
    }
  }
}
