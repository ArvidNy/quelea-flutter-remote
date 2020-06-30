import 'package:flutter/material.dart';

import '../handlers/download-handler.dart';
import '../handlers/language-delegate.dart';
import '../utils/global-utils.dart' as global;

/// Shows a dialog for previewing a song item and adding it to the schedule
void showAddSearchItemDialog(BuildContext context, String title, String lyrics,
    var id, Function closeSearch) {
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          actions: <Widget>[
            FlatButton(
              child: Text(AppLocalizations.of(context).getText("cancel.button")),
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              },
            ),
            FlatButton(
              child: Text(AppLocalizations.of(context).getText("remote.add.go.live")),
              onPressed: () {
                DownloadHandler().sendSignal(
                    global.url + "/add/$id",
                    () => DownloadHandler()
                        .sendSignal(global.url + "/gotoitem9999", () => {}));
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                  closeSearch();
                }
              },
            ),
            FlatButton(
              child: Text("Add"),
              onPressed: () {
                DownloadHandler().sendSignal(global.url + "/add/$id", () => {});
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                  closeSearch();
                }
              },
            ),
          ],
          content: SingleChildScrollView(
            child: Text(lyrics),
          ),
        );
      });
}
