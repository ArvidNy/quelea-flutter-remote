import 'package:flutter/material.dart';

import '../handlers/download-handler.dart';
import '../utils/global-utils.dart';
import '../widgets/live-item.dart';

/// A class widget that shows the current
/// `LiveItem` in a `ListView`.
class LyricsView extends StatelessWidget {
  final LiveItem liveItem;
  final ScrollController scrollController;

  LyricsView(this.liveItem, this.scrollController);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(liveItem.titleText),
        Expanded(
          child: ListView.builder(
            controller: scrollController,
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
      DownloadHandler().sendSignal(url + "/play", () => {});
    } else {
      DownloadHandler()
          .sendSignal(url + "/section" + index.toString(), () => {});
    }
  }
}
