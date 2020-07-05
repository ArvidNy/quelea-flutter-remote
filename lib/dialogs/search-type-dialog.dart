import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../handlers/language-delegate.dart';

/// Shows a dialog for selecting if a song or a Bible passage should be searched for
void showSelectSearchTypeDialog(Function songSearch, Function bibleSearch) {
  Get.dialog(AlertDialog(
    title:
        Text(AppLocalizations.of(Get.context).getText("library.song.search")),
    actions: <Widget>[
      FlatButton(
        child: Text(AppLocalizations.of(Get.context).getText("cancel.button")),
        onPressed: () {
          Get.back(closeOverlays: true);
        },
      ),
    ],
    content: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              IconButton(
                icon: new Icon(Icons.book),
                onPressed: () {
                  Get.back(closeOverlays: true);
                  bibleSearch();
                },
              ),
              Text(
                  AppLocalizations.of(Get.context).getText("rcs.bible.search")),
            ],
          ),
        ),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              IconButton(
                icon: new Icon(Icons.music_note),
                onPressed: () {
                  Get.back(closeOverlays: true);
                  songSearch();
                },
              ),
              Text(AppLocalizations.of(Get.context).getText("rcs.song.search")),
            ],
          ),
        ),
      ],
    ),
  ));
}
