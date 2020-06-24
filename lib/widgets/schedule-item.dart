import 'package:flutter/material.dart';

import '../handlers/download-handler.dart';
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
          DownloadHandler()
              .download(global.url + "/gotoitem$index", () => {});
        }
        if (Navigator.canPop(context)) Navigator.pop(context);
      },
      onLongPress: () {
        showDialog(
          context: global.context,
          child: AlertDialog(
            content: Container(
              height: 180,
              width: double.maxFinite,
              child: Column(
                children: <Widget>[
                  Text("Choose action for $title:",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ListView(
                    padding: EdgeInsets.only(top: 10),
                    shrinkWrap: true,
                    children: <Widget>[
                      _getInkWell("Remove from the schedule", "remove"),
                      _getInkWell("Move up", "moveup"),
                      _getInkWell("Move down", "movedown"),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  String toStringShort() {
    return title + isLive.toString() + isPreview.toString() + index.toString();
  }

  _getInkWell(String text, String action) {
    return InkWell(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Text(text),
      ),
      onTap: () {
        DownloadHandler().download("${global.url}/$action/$index", () => {});
        if (Navigator.canPop(global.context)) Navigator.pop(global.context);
      },
    );
  }
}
