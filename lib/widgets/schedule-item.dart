import 'package:flutter/material.dart';

import '../handlers/download-handler.dart';
import '../utils/global-utils.dart';

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
              .download(url + "/gotoitem" + index.toString(), () => {});
        }
        if (Navigator.canPop(context)) Navigator.pop(context);
      },
    );
  }

  @override
  String toStringShort() {
    return title + isLive.toString() + isPreview.toString() + index.toString();
  }
}
