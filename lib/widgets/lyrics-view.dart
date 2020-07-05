import 'package:flutter/material.dart';

import '../handlers/download-handler.dart';
import '../utils/global-utils.dart' as global;
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
            itemCount: liveItem.itemSlides.length,
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
      DownloadHandler().sendSignal(global.url + "/play", () => {});
    } else {
      DownloadHandler()
          .sendSignal(global.url + "/section" + index.toString(), () => {});
    }
  }
}
