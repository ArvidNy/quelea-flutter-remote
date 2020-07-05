import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:indexed_list_view/indexed_list_view.dart';
import 'package:preferences/preferences.dart';

import '../handlers/download-handler.dart';
import '../handlers/language-delegate.dart';
import '../utils/global-utils.dart' as global;

/// Opens a dialog for selecting:
/// 1. Bible translation
/// 2. Bible book
/// 3. Chapter and verses
Function bibleSearchFunction() {
  return () =>
      DownloadHandler().download(global.url + "/translations", (translations) {
        _showBibleDialog(
            AppLocalizations.of(Get.context).getText("select.language"),
            translations.split("\n"), (translation) {
          String t = translation.toString().replaceFirst("*", "");
          DownloadHandler().download(global.url + "/books/$t", (books) {
            _showBibleDialog(
                AppLocalizations.of(Get.context).getText("remote.select.book"),
                books.split("\n"), (book) {
              int bookNum = 0;
              for (String s in books.split("\n")) {
                bookNum++;
                if (s.contains(book)) break;
              }
              _showBibleChapterDialog(
                  AppLocalizations.of(Get.context)
                      .getText("remote.select.chapter.verses"),
                  bookNum,
                  t,
                  book);
            });
          });
        });
      });
}

void _showBibleDialog(String title, List items, Function closeSearch) {
  if (global.debug) debugPrint(items.toString());
  Get.dialog(AlertDialog(
    title: Text(title),
    actions: <Widget>[
      FlatButton(
        child: Text(AppLocalizations.of(Get.context).getText("cancel.button")),
        onPressed: () {
          Get.back(closeOverlays: true);
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
                  onTap: () =>
                      _closeAndReturnItem(items[index], closeSearch),
                  child: Container(
                      height: 45, child: Center(child: Text(items[index]))),
                )
              : Container();
        },
      ),
    ),
  ));
}

void _closeAndReturnItem(String item, Function ret) {
  Get.back(closeOverlays: true);
  ret(item);
}

final _itemScrollController = IndexedScrollController(initialIndex: 0);

void _showBibleChapterDialog(
    String title, int bookNum, String translation, String book) {
  int chapter = 1;
  int verseStart = 0;
  int verseEnd = 0;
  Get.dialog(AlertDialog(
    title: Text(title),
    actions: <Widget>[
      FlatButton(
        child: Text(AppLocalizations.of(Get.context).getText("cancel.button")),
        onPressed: () {
          Get.back(closeOverlays: true);
          _itemScrollController.jumpToIndex(0);
        },
      ),
      FlatButton(
          child: Text(
              AppLocalizations.of(Get.context).getText("remote.add.go.live")),
          onPressed: () {
            Get.back(closeOverlays: true);
            _itemScrollController.jumpToIndex(0);
            DownloadHandler().download(
                global.url +
                    "/addbible/$translation/$book/" +
                    getPassageName(chapter, verseStart, verseEnd),
                () => DownloadHandler()
                    .download(global.url + "/gotoitem9999", () => {}));
          }),
      FlatButton(
          child: Text(AppLocalizations.of(Get.context).getText("ok.button")),
          onPressed: () {
            Get.back(closeOverlays: true);
            _itemScrollController.jumpToIndex(0);
            DownloadHandler().download(
                global.url +
                    "/addbible/$translation/$book/" +
                    getPassageName(chapter, verseStart, verseEnd),
                () => {});
          }),
    ],
    content: StatefulBuilder(
      builder: (context, setState) {
        return Container(
          width: 500,
          child: Stack(
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
                        _itemScrollController.jumpToIndex(index);
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
              Text("Add $book " +
                  getPassageName(chapter, verseStart, verseEnd) +
                  "\nin $translation"),
            ],
          ),
        );
      },
    ),
  ));
}

String getPassageName(int chapter, int verseStart, int verseEnd) {
  return "$chapter" +
      (verseStart > 0 ? ":$verseStart" : "") +
      (verseEnd > verseStart ? "-$verseEnd" : "");
}

_getNumberListView(
    List items, int i, Function onTapAction, bool useItemScrollController) {
  return Expanded(
    child: Container(
      padding: EdgeInsets.only(top: 40),
      width: double.maxFinite,
      child: useItemScrollController
          ? IndexedListView.builder(
              maxItemCount: items.length - 1,
              minItemCount: 0,
              controller: _itemScrollController,
              itemBuilder: (BuildContext context, int index) {
                return _getInkWell(index, items, onTapAction, i);
              },
            )
          : ListView.builder(
              itemCount: items.length,
              itemBuilder: (BuildContext context, int index) {
                return _getInkWell(index, items, onTapAction, i);
              }),
    ),
  );
}

_getInkWell(int index, List items, Function onTapAction, int i) {
  bool isLightTheme =
      (PrefService.getString("app_theme") ?? "light").contains("light");
  Color color;
  if (i == int.parse(items[index])) {
    if (isLightTheme) {
      color = Colors.grey[200];
    } else {
      color = Colors.grey[600];
    }
  } else {
    if (isLightTheme) {
      color = Colors.white;
    } else {
      color = Colors.grey[800];
    }
  }
  return items[index].toString().isNotEmpty
      ? InkWell(
          onTap: () => onTapAction(index),
          child: Container(
              color: color,
              height: 45,
              child: Center(child: Text(items[index]))),
        )
      : Container();
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
