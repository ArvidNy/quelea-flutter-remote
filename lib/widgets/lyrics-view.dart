import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../handlers/download-handler.dart';
import '../utils/global-utils.dart';
import '../widgets/live-item.dart';

/// A class widget that shows the current
/// `LiveItem` in a `ListView`.
class LyricsView extends StatelessWidget {
  final LiveItem liveItem;
  final ItemScrollController scrollController;

  LyricsView(this.liveItem, this.scrollController);

  @override
  Widget build(BuildContext context) {
    print(liveItem.lyrics.length);
    return Column(
      children: <Widget>[
        Text(liveItem.titleText),
        Expanded(
          child: ListView.builder(
            itemCount: liveItem.lyrics.length,
            itemBuilder: (context, index) {
              return InkWell(
                child: liveItem.getSlide(index),
                onTap: () => _lyricsItemClick(index, liveItem),
              );
            },
          ),
        ),
      ],
    );
  }

  void _lyricsItemClick(int index, LiveItem liveItem) {
    if (liveItem.isMedia) {
      print(liveItem.lyrics.toString());
      DownloadHandler().download(url + "/play", () => {});
    } else {
      DownloadHandler().download(url + "/section" + index.toString(), () => {});
    }
  }
}
