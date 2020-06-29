import 'package:flutter/material.dart';

import '../handlers/language-delegate.dart';

/// Shows a dialog for selecting if a song or a Bible passage should be searched for
void showSelectSearchTypeDialog(
    BuildContext context, Function songSearch, Function bibleSearch) {
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).getText("library.song.search")),
          actions: <Widget>[
            FlatButton(
              child: Text(AppLocalizations.of(context).getText("cancel.button")),
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
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
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
                        bibleSearch();
                      },
                    ),
                    Text(AppLocalizations.of(context).getText("rcs.bible.search")),
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
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
                        songSearch();
                      },
                    ),
                    Text(AppLocalizations.of(context).getText("rcs.song.search")),
                  ],
                ),
              ),
            ],
          ),
        );
      });
}
