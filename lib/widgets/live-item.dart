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

  /// Parses the html into variables.
  LiveItem(String html) {
    titleText = getTitle(html);
    isPresentation = html.contains("img");
    for (String s in parser.getSlides(html)) {
      lyrics.add(s);
    }
    activeSlide = getActiveSlide(html);
    if (lyrics.isEmpty) {
      String play = global.statusHandler.play;
      if (html.contains("play()")) {
        isMedia = true;
        lyrics.add("\n$play\n");
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
      child: Center(
        child: isPresentation
            ? FadeInImage.assetNetwork(
                key: ValueKey(titleText.toString() + i.toString()),
                placeholder: 'images/loading.gif',
                image: global.url + "/slides/slide${i+1}.png")
            : Text(
                lyrics[i],
                style: TextStyle(fontSize: 16),
              ),
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
  String getTitle(String html) {
    if (!html.contains("<i>")) return "";
    return html.substring(html.indexOf("<i>") + 3, html.indexOf("<br/></i>"));
  }
}
