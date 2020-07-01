import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:preferences/preference_service.dart';

import './download-handler.dart';
import './language-delegate.dart';
import '../pages/settings-page.dart';
import '../utils/global-utils.dart' as global;

void handleKeyEvent(RawKeyEvent event, BuildContext context,
    Map<String, Function> settingsStateFunctions) {
  print(event);
  if (event.runtimeType == RawKeyDownEvent) {
    if (event.data.logicalKey == LogicalKeyboardKey.arrowDown ||
        (event.data.logicalKey == LogicalKeyboardKey.audioVolumeDown &&
                PrefService.getBool("use_volume_navigation") ??
            false) ||
        event.data.logicalKey == LogicalKeyboardKey.pageDown) {
      if (event.isControlPressed) {
        DownloadHandler().download("${global.url}/nextitem", () {});
      } else {
        DownloadHandler().download("${global.url}/next", () {});
      }
    } else if (event.data.logicalKey == LogicalKeyboardKey.arrowUp ||
        (event.data.logicalKey == LogicalKeyboardKey.audioVolumeUp &&
                PrefService.getBool("use_volume_navigation") ??
            false)  ||
        event.data.logicalKey == LogicalKeyboardKey.pageUp) {
      if (event.isControlPressed) {
        DownloadHandler().download("${global.url}/previtem", () {});
      } else {
        DownloadHandler().download("${global.url}/prev", () {});
      }
    } else if (event.data.logicalKey == LogicalKeyboardKey.f5) {
      DownloadHandler().download("${global.url}/tlogo", () {});
    } else if (event.data.logicalKey == LogicalKeyboardKey.f6) {
      DownloadHandler().download("${global.url}/black", () {});
    } else if (event.data.logicalKey == LogicalKeyboardKey.f7) {
      DownloadHandler().download("${global.url}/clear", () {});
    } else if (event.data.logicalKey.keyId <= LogicalKeyboardKey.digit9.keyId &&
        event.data.logicalKey.keyId >= LogicalKeyboardKey.digit1.keyId) {
      DownloadHandler().download(
          "${global.url}/section${int.parse(event.data.keyLabel) - 1}", () {});
    } else if (event.data.logicalKey == LogicalKeyboardKey.keyT &&
        (event.isMetaPressed || event.isControlPressed)) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SettingsPage(
            title: AppLocalizations.of(context).getText("options.title"),
            settingsFunctions: settingsStateFunctions,
          ),
        ),
      );
    }
  }
}
