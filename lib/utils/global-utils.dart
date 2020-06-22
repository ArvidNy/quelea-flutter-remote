import 'package:flutter/material.dart';
import 'package:preferences/preferences.dart';

import '../objects/status-item.dart';
import '../handlers/sync-handler.dart';

// Global variables
String url = PrefService.getString('server_url') ??
    "http://192.168.0.1:1112"; // Local AVD 10.0.2.2
BuildContext context;
bool debug = true;
bool disableRecord = PrefService.getBool("disable_record") ?? false;
SyncHandler syncHandler = new SyncHandler();
final scaffoldKey = GlobalKey<ScaffoldState>();
String chapterList;
StatusItem statusHandler = StatusItem();

// Global methods
void notImplementedSnackbar() {
  scaffoldKey.currentState.showSnackBar(
      SnackBar(content: Text("This feature is not yet implemented")));
}
