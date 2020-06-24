import 'package:flutter/material.dart';
import 'package:org.quelea.mobileremote/handlers/download-handler.dart';

import '../utils/global-utils.dart' as global;

void showAddNoticeDialog(BuildContext context) {
  String message = "";
  TextField textField = TextField(
    autofocus: true,
    onChanged: (text) => message = text,
    onSubmitted: (text) => addNotice(text),
  );
  showDialog(
      context: context,
      child: AlertDialog(
        title: Text("Write a text to add as a notice"),
        content: textField,
        actions: <Widget>[
          FlatButton(
            onPressed: () => Navigator.canPop(global.context)
                ? Navigator.pop(global.context)
                : null,
            child: Text("Cancel"),
          ),
          FlatButton(onPressed: () => addNotice(message), child: Text("OK")),
        ],
      ));
}

addNotice(String message) {
  if (Navigator.canPop(global.context)) Navigator.pop(global.context);
  DownloadHandler().download("${global.url}/notice/$message", () => {});
}
