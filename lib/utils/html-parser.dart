import 'package:html/dom.dart';
import 'package:html/parser.dart';

import '../widgets/schedule-item.dart';
import '../objects/schedule-list.dart';
import '../objects/search-item.dart';

/// Parses the data from `/lyrics` and returns
/// the slides in a `List<String>`.
List<String> getSlides(String html) {
  List<String> slides = [];
  Document document = parse(html.toString());
  if (html.contains("lyric")) {
    return _getLyricSlides(document, slides);
  } else if (html.contains("img")) {
    return _getImageSlides(document, slides);
  }
  return slides;
}

List<String> _getImageSlides(Document document, List<String> slides) {
  for (Element s in document.getElementsByTagName("div")) {
    slides.add(s.text);
  }
  return slides;
}

List<String> _getLyricSlides(Document document, List<String> slides) {
  if (document.getElementById("outer") != null) {
    for (Element s in document.getElementById("outer").children) {
      String slide = "";
      for (Element line in s.getElementsByClassName("lyric")) {
        slide += line.text + "\n";
      }
      slides.add(slide.trimRight());
    }
  }
  return slides;
}

/// Parses the data from `/search` and returns
/// a `List<SearchItem>` with the results.
List<SearchItem> getSearchResults(String html) {
  List<SearchItem> searchResult = [];
  Document document = parse(html);
  if (document.getElementsByTagName("a") != null) {
    for (Element s in document.getElementsByTagName("a")) {
      print(s.text);
      searchResult
          .add(SearchItem(s.attributes["href"].split("/").last, s.text));
    }
  }
  return searchResult;
}

/// Parses the data from `/schedule` and returns
/// a `ScheduleList`.
ScheduleList getSchedule(String html) {
  html = html.replaceAll("""<!DOCTYPE html>
<html>
<head>
<meta charset=\"UTF-8\">
</head>""", "");
  List<ScheduleItem> items = [];

  int index = 0;
  for (String s in html.split("<br/>")) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    var item = s.replaceAll(exp, "");
    if (item.trim().isNotEmpty) {
      items.add(ScheduleItem(
          title: item,
          isLive: s.contains("<b>"),
          isPreview: s.contains("<i>"),
          index: index));
    }
    index++;
  }
  return ScheduleList(items);
}

/// Parses the html text and returns a string.
/// It's possible to exclude tags (such as links).
String getText(String html, List<String> excludeTags) {
  String ret = "";
  Document document = parse(html.replaceAll("<br/>", "\n"));
  for (String tag in excludeTags) {
    for (Element e in document.getElementsByTagName(tag)) {
      e.remove();
    }
  }
  for (Element e in document.children) {
    ret += e.text;
  }
  return ret;
}
