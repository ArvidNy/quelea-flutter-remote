import 'package:flutter/material.dart';
import 'package:preferences/preferences.dart';

import '../objects/item-slide.dart';
import '../utils/global-utils.dart' as global;
import '../utils/html-parser.dart' as parser;

/// A class for handeling the item that currently is live.
class LiveItem {
  final List<ItemSlide> itemSlides = [];
  int activeSlide = 0;
  bool isMedia = false;
  bool isPresentation = false;
  String titleText = "";
  String _html;

  /// Parses the html into variables.
  LiveItem(this._html) {
    titleText = _getTitle(_html);
    isPresentation = _html.contains("img");
    int i = 0;
    for (String s in parser.getSlides(_html)) {
      String sectionTitle = _getSectionTitle(i);
      itemSlides.add(ItemSlide(s, title: sectionTitle));
      i++;
    }
    activeSlide = getActiveSlide(_html);
    if (itemSlides.isEmpty) {
      String play = global.statusHandler.play;
      if (_html.contains("play()")) {
        isMedia = true;
        itemSlides.add(ItemSlide("\n$play\n"));
      }
    }
  }

  /// Returns a `Text` widget for all text based items
  /// and a `FadeInImage` that are downloaded from the
  /// server for presentations.
  Widget getSlide(int i) {
    return Container(
      padding: EdgeInsets.all(6),
      color:
          (i == activeSlide) ? Colors.lightBlue.shade500 : Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          itemSlides[i].title.isEmpty
              ? Container()
              : Text(
                  itemSlides[i].title,
                  style: TextStyle(
                    color: _getSectionColor(
                        itemSlides[i].title, (i == activeSlide)),
                  ),
                ),
          isPresentation
              ? Center(
                  child: FadeInImage.assetNetwork(
                      key: ValueKey(titleText.toString() + i.toString()),
                      placeholder: 'images/loading.gif',
                      image: global.url + "/slides/slide${i + 1}.png"))
              : Text(
                  itemSlides[i].lyrics,
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

  bool hasSectionTitles() {
    for (ItemSlide i in itemSlides) {
      if (i.title.isNotEmpty) {
        return true;
      }
    }
    return false;
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

  _getSectionColor(String sectionTitle, bool isSelected) {
    bool isLightTheme =
        (PrefService.getString("app_theme") ?? "light").contains("light");
    int colorValue = (isLightTheme || isSelected) ? 900 : 400;
    Color sectionColor = Colors.green[colorValue];
    if (sectionTitle.contains("Verse")) {
      sectionColor = Colors.blue[colorValue];
    } else if (sectionTitle.contains("Chorus")) {
      sectionColor = Colors.red[colorValue];
    }
    return sectionColor;
  }
}
