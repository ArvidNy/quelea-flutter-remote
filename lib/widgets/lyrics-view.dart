import 'package:flutter/material.dart';
import 'package:indexed_list_view/indexed_list_view.dart';

import '../handlers/download-handler.dart';
import '../utils/global-utils.dart';
import '../widgets/live-item.dart';

/// A class widget that shows the current
/// `LiveItem` in a `ListView`.
class LyricsView extends StatelessWidget {
  final LiveItem liveItem;
  final IndexedScrollController scrollController;

  LyricsView(this.liveItem, this.scrollController);

  @override
  Widget build(BuildContext context) {
    // Workaround for infinite scroll both past first item
    scrollController.addListener(() {
      if (scrollController.position.pixels < 0) {
        scrollController.animateToIndex(0);
      }
    });
    return Column(
      children: <Widget>[
        Text(liveItem.titleText),
        Expanded(
          child: IndexedListView.builder(
            controller: scrollController,
            maxItemCount: liveItem.lyrics.length - 1,
            minItemCount: 0,
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
