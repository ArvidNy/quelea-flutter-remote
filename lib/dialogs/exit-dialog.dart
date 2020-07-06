import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../handlers/language-delegate.dart';

showExitDialog<bool>() {
  Get.dialog(AlertDialog(
    title: Text("${AppLocalizations.of(Get.context).getText("exit.text").trim()}?"),
    actions: <Widget>[
      FlatButton(
        child: Text(AppLocalizations.of(Get.context).getText("cancel.button")),
        onPressed: () {
          Get.back(closeOverlays: true);
        },
      ),
      FlatButton(
        child: Text(AppLocalizations.of(Get.context).getText("exit.button")),
        onPressed: () {
          SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        },
      )
    ],
  ));
}
