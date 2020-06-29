import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../handlers/download-handler.dart';
import '../handlers/language-delegate.dart';
import '../utils/global-utils.dart' as global;

/// Opens a dialog for selecting:
/// 1. Bible translation
/// 2. Bible book
/// 3. Chapter and verses
Function bibleSearchFunction(BuildContext context) {
    return () => DownloadHandler().download(global.url + "/translations",
            (translations) {
          _showBibleDialog(
              context, AppLocalizations.of(context).getText("select.language"), translations.split("\n"),
              (translation) {
            DownloadHandler().download(global.url + "/books/$translation",
                (books) {
              _showBibleDialog(context, AppLocalizations.of(context).getText("remote.select.book"), books.split("\n"),
                  (book) {
                int bookNum = 0;
                for (String s in books.split("\n")) {
                  bookNum++;
                  if (s.contains(book)) break;
                }
                _showBibleChapterDialog(context, AppLocalizations.of(context).getText("remote.select.chapter.verses"),
                    bookNum, translation, book);
              });
            });
          });
        });
  }

void _showBibleDialog(
    BuildContext context, String title, List items, Function closeSearch) {
  print(items);
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
          ],
          content: Container(
            width: 300.0,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: items.length,
              itemBuilder: (BuildContext context, int index) {
                return items[index].toString().isNotEmpty
                    ? InkWell(
                        onTap: () => _closeAndReturnItem(
                            items[index], closeSearch, context),
                        child: Container(
                            height: 45,
                            child: Center(child: Text(items[index]))),
                      )
                    : Container();
              },
            ),
          ),
        );
      });
}

void _closeAndReturnItem(String item, Function ret, BuildContext context) {
  if (Navigator.canPop(context)) {
    Navigator.pop(context);
  }
  ret(item);
}

final ItemScrollController _itemScrollController = ItemScrollController();

void _showBibleChapterDialog(BuildContext context, String title, int bookNum,
    String translation, String book) {
  int chapter = 1;
  int verseStart = 1;
  int verseEnd = 1;

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
                child: Text(AppLocalizations.of(context).getText("ok.button")),
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                  DownloadHandler().download(
                      global.url +
                          "/addbible/$translation/$book/$chapter:$verseStart" +
                          (verseEnd != verseStart ? "-$verseEnd" : ""),
                      () => {});
                }),
          ],
          content: StatefulBuilder(
            builder: (context, setState) {
              return Stack(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      _getNumberListView(
                          _getNumberListFromBibleBook("$bookNum,", true), chapter,
                          (index) {
                        setState(() {
                          chapter = index + 1;
                        });
                      }, false),
                      _getNumberListView(
                          _getNumberListFromBibleBook("$bookNum,$chapter,", false),
                          verseStart, (index) {
                        setState(() {
                          verseStart = index + 1;
                          if (verseEnd < verseStart) {
                            verseEnd = index + 1;
                            _itemScrollController.jumpTo(index: index);
                          }
                        });
                      }, false),
                      _getNumberListView(
                          _getNumberListFromBibleBook("$bookNum,$chapter,", false),
                          verseEnd, (index) {
                        setState(() {
                          verseEnd = index + 1;
                        });
                      }, true),
                    ],
                  ),
                  Text("Add $book $chapter:$verseStart" +
                      (verseEnd > verseStart ? "-$verseEnd" : "") +
                      "\nin $translation"),
                ],
              );
            },
          ),
        );
      });
}

_getNumberListView(
    List items, int i, Function onTapAction, bool useItemScrollController) {
  return Container(
    padding: EdgeInsets.only(top: 40),
    width: 75,
    child: ScrollablePositionedList.builder(
      itemCount: items.length,
      itemScrollController:
          useItemScrollController ? _itemScrollController : null,
      itemBuilder: (BuildContext context, int index) {
        return items[index].toString().isNotEmpty
            ? InkWell(
                onTap: () => onTapAction(index),
                child: Container(
                    color: i == int.parse(items[index])
                        ? Colors.grey[200]
                        : Colors.white,
                    height: 45,
                    child: Center(child: Text(items[index]))),
              )
            : Container();
      },
    ),
  );
}

List<String> _getNumberListFromBibleBook(String startsWith, bool chapter) {
  String maxNum = "";
  for (String s in global.chapterList.split("\n")) {
    if (s.startsWith(startsWith)) maxNum = s.split(",")[chapter ? 1 : 2];
  }
  List<String> numList = List.filled(int.parse(maxNum), "");
  for (int i = 0; i < numList.length; i++) {
    numList[i] = (i + 1).toString();
  }
  return numList;
}
