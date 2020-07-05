import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../handlers/download-handler.dart';
import '../handlers/language-delegate.dart';
import '../utils/global-utils.dart' as global;

/// A class that returns a widget for the items
/// that should be added into the `ScheduleDrawer`.
class ScheduleItem extends StatelessWidget {
  final String title;
  final bool isLive;
  final bool isPreview;
  final int index;

  ScheduleItem({this.title, this.isLive, this.isPreview, this.index = -1});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    if (isLive) {
      backgroundColor = Colors.lightBlue.shade500;
    } else if (isPreview) {
      backgroundColor = Colors.grey.shade300;
    } else {
      backgroundColor = Colors.transparent;
    }
    return InkWell(
      child: Container(
        height: 45,
        color: backgroundColor,
        padding: EdgeInsets.all(12),
        child: Text(
          title.trim(),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      onTap: () {
        if (index >= 0) {
          DownloadHandler().download(global.url + "/gotoitem$index", () => {});
        }
        Get.back();
      },
      onLongPress: () {
        Get.dialog(
          SimpleDialog(
              title: Text(AppLocalizations.of(context)
                  .getText("remote.choose.action")
                  .replaceFirst("\$1", title)),
              children: <Widget>[
                _getDialogOption(
                    AppLocalizations.of(context)
                        .getText("remove.song.schedule.tooltip"),
                    "remove"),
                _getDialogOption(
                    AppLocalizations.of(context)
                        .getText("move.up.schedule.tooltip"),
                    "moveup"),
                _getDialogOption(
                    AppLocalizations.of(context)
                        .getText("move.down.schedule.tooltip"),
                    "movedown"),
              ]),
        );
      },
    );
  }

  @override
  String toStringShort() {
    return title + isLive.toString() + isPreview.toString() + index.toString();
  }

  _getDialogOption(String text, String action) {
    return SimpleDialogOption(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Text(text),
      ),
      onPressed: () {
        DownloadHandler().sendSignal("${global.url}/$action/$index", () => {});
        Get.back();
      },
    );
  }
}
