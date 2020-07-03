import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './download-handler.dart';
import './language-delegate.dart';
import '../dialogs/bible-dialog.dart';
import '../dialogs/search-type-dialog.dart';
import '../handlers/search-delegate.dart';
import '../pages/settings-page.dart';
import '../utils/global-utils.dart' as global;
import '../widgets/live-item.dart';

/// Handles all physical keyboard shortcuts.
void handleKeyEvent(RawKeyEvent event, BuildContext context,
    Map<String, Function> settingsStateFunctions, LiveItem liveItem) {
  if (event.runtimeType == RawKeyDownEvent) {
    // Next slide/item
    if (event.data.logicalKey == LogicalKeyboardKey.arrowDown ||
        event.data.logicalKey == LogicalKeyboardKey.pageDown) {
      if (event.isMetaPressed || event.isControlPressed || event.isAltPressed) {
        DownloadHandler().download("${global.url}/nextitem", () {});
      } else {
        DownloadHandler().download("${global.url}/next", () {});
      }
      // Previous slide/item
    } else if (event.data.logicalKey == LogicalKeyboardKey.arrowUp ||
        event.data.logicalKey == LogicalKeyboardKey.pageUp) {
      if (event.isMetaPressed || event.isControlPressed || event.isAltPressed) {
        DownloadHandler().download("${global.url}/previtem", () {});
      } else {
        DownloadHandler().download("${global.url}/prev", () {});
      }
      // Logo
    } else if (event.data.logicalKey == LogicalKeyboardKey.f5) {
      DownloadHandler().download("${global.url}/tlogo", () {});
      // Black
    } else if (event.data.logicalKey == LogicalKeyboardKey.f6) {
      DownloadHandler().download("${global.url}/black", () {});
      // Clear
    } else if (event.data.logicalKey == LogicalKeyboardKey.f7) {
      DownloadHandler().download("${global.url}/clear", () {});
      // Record
    } else if (event.data.logicalKey == LogicalKeyboardKey.keyR &&
        (event.isMetaPressed || event.isControlPressed)) {
      DownloadHandler().download("${global.url}/record", () {});
      // Slide numbers
    } else if (_isNumber(event) && !liveItem.hasSectionTitles()) {
      DownloadHandler().download(
          "${global.url}/section${int.parse(event.logicalKey.keyLabel) - 1}",
          () {});
      // Settings
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
      // Search
    } else if (event.data.logicalKey == LogicalKeyboardKey.keyL &&
        (event.isMetaPressed || event.isControlPressed)) {
      showSelectSearchTypeDialog(context, () async {
        showSearch(context: context, delegate: SongSearchDelegate());
      }, bibleSearchFunction(context));
      // Schedule
    } else if (event.data.logicalKey == LogicalKeyboardKey.keyD &&
        (event.isMetaPressed || event.isControlPressed)) {
      if (!global.drawerScaffoldKey.currentState.isDrawerOpen) {
        global.drawerScaffoldKey.currentState.openDrawer();
      }
      // Section titles
    } else {
      List supportedTitles = [
        LogicalKeyboardKey.keyT, // Tag
        LogicalKeyboardKey.keyC, // Chorus
        LogicalKeyboardKey.keyB, // Bridge
        LogicalKeyboardKey.keyP, // Pre-chorus
        LogicalKeyboardKey.keyI, // Intro
        LogicalKeyboardKey.keyO // Outro
      ];
      bool isNumber = _isNumber(event);
      if (supportedTitles.contains(event.data.logicalKey) || isNumber) {
        for (int i = 0; i < liveItem.itemSlides.length; i++) {
          String title = liveItem.itemSlides[i].title;
          if (isNumber && title.toLowerCase().startsWith('v')) {
            if (title.contains(" ") &&
                title.split(" ")[1].contains(event.logicalKey.keyLabel)) {
              DownloadHandler().download("${global.url}/section$i", () {});
            }
          } else if (title
              .toLowerCase()
              .startsWith(event.data.logicalKey.keyLabel.toLowerCase())) {
            DownloadHandler().download("${global.url}/section$i", () {});
          }
        }
      }
    }
  }
}

bool _isNumber(RawKeyEvent event) {
  try {
    int.parse(event.logicalKey.keyLabel);
    return true;
  } catch (e) {
    return false;
  }
}
