import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../handlers/download-handler.dart';
import '../handlers/language-delegate.dart';
import '../utils/global-utils.dart' as global;

/// Get a dialog for entering either a URL or a password
Widget getLoginDialog(String message, bool isPassword) {
  String input = global.url;
  TextField textField = TextField(
    onChanged: (text) => input = text,
    controller: TextEditingController(text: isPassword ? "" : global.url),
    keyboardType: TextInputType.url,
    decoration: InputDecoration(
        border: OutlineInputBorder(), labelText: isPassword ? "" : global.url),
    onSubmitted: (text) {
      if (global.debug) debugPrint("submitted");
      if (isPassword) {
        _sendPassword(input);
      } else {
      }
    },
  );
  return WillPopScope(
    onWillPop: () {
      return Future.value(false);
    },
    child: AlertDialog(
      title: Row(
        children: <Widget>[
          Expanded(
              child: Text(
            message,
            style: TextStyle(fontSize: 18),
          )),
          isPassword
              ? Container()
              : IconButton(
                  icon: Icon(Icons.help),
                  onPressed: () => global.launchURL(
                      "https://quelea-projection.github.io/docs/Remote_Control_Troubleshooting"))
        ],
      ),
      actions: <Widget>[
        // Exit is not allowed for iOS apps
        Platform.isAndroid
            ? FlatButton(
                child:
                    Text(AppLocalizations.of(Get.context).getText("exit.button")),
                onPressed: () {
                  SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                },
              )
            : Column(),
        isPassword
            ? Container()
            : FlatButton(
                child: Text(AppLocalizations.of(Get.context)
                    .getText("remote.search.server")),
                onPressed: () {
                  Get.back(closeOverlays: true);
                  DownloadHandler().showLoadingIndicator();
                  DownloadHandler().autoConnect();
                },
              ),
        FlatButton(
          child: Text(AppLocalizations.of(Get.context).getText("ok.button")),
          onPressed: () {
            Get.back(closeOverlays: true);
            if (isPassword) {
              _sendPassword(input);
            } else {
              DownloadHandler().showLoadingIndicator();
              DownloadHandler().testConnection(input, false);
            }
          },
        ),
      ],
      content: textField,
    ),
  );
}

void _sendPassword(String password) async {
  await DownloadHandler().postPassword(global.url, password);
  DownloadHandler().testConnection(global.url, false);
}
