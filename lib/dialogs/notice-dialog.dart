import 'package:flutter/material.dart';
import 'package:org.quelea.mobileremote/handlers/download-handler.dart';

import '../handlers/language-delegate.dart';
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
        title: Text(AppLocalizations.of(context).getText("new.notice.text")),
        content: textField,
        actions: <Widget>[
          FlatButton(
            onPressed: () => Navigator.canPop(global.context)
                ? Navigator.pop(global.context)
                : null,
            child: Text(AppLocalizations.of(context).getText("cancel.button")),
          ),
          FlatButton(onPressed: () => addNotice(message), child: Text(AppLocalizations.of(context).getText("ok.button"))),
        ],
      ));
}

addNotice(String message) {
  if (Navigator.canPop(global.context)) Navigator.pop(global.context);
  DownloadHandler().download("${global.url}/notice/$message", () => {});
}
