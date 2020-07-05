import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:org.quelea.mobileremote/handlers/download-handler.dart';

import '../handlers/language-delegate.dart';
import '../utils/global-utils.dart' as global;

void showAddNoticeDialog() {
  String message = "";
  TextField textField = TextField(
    autofocus: true,
    onChanged: (text) => message = text,
    onSubmitted: (text) => addNotice(text),
  );
  Get.dialog(AlertDialog(
    title: Text(AppLocalizations.of(Get.context).getText("new.notice.text")),
    content: textField,
    actions: <Widget>[
      FlatButton(
        onPressed: () => Get.back(closeOverlays: true),
        child: Text(AppLocalizations.of(Get.context).getText("cancel.button")),
      ),
      FlatButton(
          onPressed: () => addNotice(message),
          child: Text(AppLocalizations.of(Get.context).getText("ok.button"))),
    ],
  ));
}

addNotice(String message) {
  Get.back(closeOverlays: true);
  DownloadHandler().sendSignal("${global.url}/notice/$message", () => {});
}
