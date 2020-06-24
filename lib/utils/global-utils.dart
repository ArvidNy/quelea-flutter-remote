import 'package:flutter/material.dart';
import 'package:preferences/preferences.dart';

import '../objects/status-item.dart';
import '../handlers/sync-handler.dart';

// Global variables
String url = PrefService.getString('server_url') ??
    "http://192.168.0.1:1112";
BuildContext context;
bool debug = true;
SyncHandler syncHandler = new SyncHandler();
final scaffoldKey = GlobalKey<ScaffoldState>();
String chapterList;
StatusItem statusHandler = StatusItem();
double serverVersion = 2020.0;

// Global methods
void notImplementedSnackbar() {
  scaffoldKey.currentState.showSnackBar(
      SnackBar(content: Text("This feature is not yet implemented")));
}

void needsNewerServerSnackbar(double version) {
  scaffoldKey.currentState.showSnackBar(SnackBar(
    duration: Duration(seconds: 3),
    content:
        Text("This feature needs the server to run Quelea $version or above"),
  ));
}
