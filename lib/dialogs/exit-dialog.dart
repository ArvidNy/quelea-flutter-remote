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
          Navigator.pop(Get.context, false);
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
