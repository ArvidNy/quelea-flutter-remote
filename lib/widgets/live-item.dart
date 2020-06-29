import 'package:flutter/material.dart';

import '../utils/global-utils.dart' as global;
import '../utils/html-parser.dart' as parser;

/// A class for handeling the item that currently is live.
class LiveItem {
  final List<String> lyrics = [];
  int activeSlide = 0;
  bool isMedia = false;
  bool isPresentation = false;
  String titleText = "";
  String _html;

  /// Parses the html into variables.
  LiveItem(this._html) {
    titleText = _getTitle(_html);
    isPresentation = _html.contains("img");
    for (String s in parser.getSlides(_html)) {
      lyrics.add(s);
    }
    activeSlide = getActiveSlide(_html);
    if (lyrics.isEmpty) {
      String play = global.statusHandler.play;
      if (_html.contains("play()")) {
        isMedia = true;
        lyrics.add("\n$play\n");
      }
    }
  }

  /// Returns a `Text` widget for all text based items
  /// and a `FadeInImage` that are downloaded from the
  /// server for presentations.
  Widget getSlide(int i) {
    String sectionTitle = _getSectionTitle(i);
    return Container(
      padding: EdgeInsets.all(6),
      color:
          (i == activeSlide) ? Colors.lightBlue.shade500 : Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          sectionTitle.isEmpty
              ? Container()
              : Text(
                  sectionTitle,
                  style: TextStyle(
                    color: _getSectionColor(sectionTitle),
                  ),
                ),
          isPresentation
              ? Center(
                  child: FadeInImage.assetNetwork(
                      key: ValueKey(titleText.toString() + i.toString()),
                      placeholder: 'images/loading.gif',
                      image: global.url + "/slides/slide${i + 1}.png"))
              : Text(
                  lyrics[i],
                  style: TextStyle(fontSize: 16),
                ),
        ],
      ),
    );
  }

  /// Calculates the active slide.
  int getActiveSlide(String html) {
    int count = 0;
    for (String s in html.split("</div>")) {
      if (s.contains("inner current")) return count;
      count++;
    }
    return -1;
  }

  /// Returns a string with what currently is being displayed.
  String _getTitle(String html) {
    if (!html.contains("<i>")) return "";
    return html.substring(html.indexOf("<i>") + 3, html.indexOf("<br/></i>"));
  }

  String _getSectionTitle(int i) {
    RegExp sectionTitleRegEx =
        RegExp("section[(]$i[)];\" data-type=\"([a-zA-Z0-9 -]*)");
    if (sectionTitleRegEx.hasMatch(_html)) {
      return sectionTitleRegEx.firstMatch(_html).group(1);
    } else {
      return "";
    }
  }

  _getSectionColor(String sectionTitle) {
    Color sectionColor = Colors.green[900];
    if (sectionTitle.contains("Verse")) {
      sectionColor = Colors.blue[900];
    } else if (sectionTitle.contains("Chorus")) {
      sectionColor = Colors.red[900];
    }
    return sectionColor;
  }
}
