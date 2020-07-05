import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../handlers/download-handler.dart';
import '../handlers/language-delegate.dart';
import '../utils/global-utils.dart' as global;

/// Shows a dialog for previewing a song item and adding it to the schedule
void showAddSearchItemDialog(
    String title, String lyrics, var id, Function closeSearch) {
  Get.dialog(AlertDialog(
    title: Text(title),
    actions: <Widget>[
      FlatButton(
        child: Text(AppLocalizations.of(Get.context).getText("cancel.button")),
        onPressed: () {
          Get.back();
        },
      ),
      FlatButton(
        child: Text(
            AppLocalizations.of(Get.context).getText("remote.add.go.live")),
        onPressed: () {
          DownloadHandler().sendSignal(
              global.url + "/add/$id",
              () => DownloadHandler()
                  .sendSignal(global.url + "/gotoitem9999", () => {}));
          closeSearch();
        },
      ),
      FlatButton(
        child: Text("Add"),
        onPressed: () {
          DownloadHandler().sendSignal(global.url + "/add/$id", () => {});
          closeSearch();
        },
      ),
    ],
    content: SingleChildScrollView(
      child: Text(lyrics),
    ),
  ));
}
