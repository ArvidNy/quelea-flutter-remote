import 'package:flutter/material.dart';

/// Shows a dialog for selecting if a song or a Bible passage should be searched for
void showSelectSearchTypeDialog(
    BuildContext context, Function songSearch, Function bibleSearch) {
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Search"),
          actions: <Widget>[
            FlatButton(
              child: Text("Cancel"),
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
                    Text("Bible search"),
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
                    Text("Song search"),
                  ],
                ),
              ),
            ],
          ),
        );
      });
}
