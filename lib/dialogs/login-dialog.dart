import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../handlers/download-handler.dart';
import '../utils/global-utils.dart' as global;

/// Shows a dialog for entering either a URL or a password
void showInputDialog(BuildContext context, String message, bool isPassword) {
  String input = global.url;
  TextField textField = TextField(
    onChanged: (text) => input = text,
    controller: TextEditingController(text: isPassword ? "" : global.url),
    keyboardType: TextInputType.url,
    decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: isPassword ? "" : "e.g. http://192.168.0.1:1112"),
    onSubmitted: (text) {
      if (global.debug) print("submitted");
      if (isPassword) {
        _sendPassword(input);
      } else {
        if (Navigator.canPop(global.context)) Navigator.pop(global.context);
        DownloadHandler().testConnection(input, global.context);
      }
    },
  );
  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return WillPopScope(
           onWillPop: () {
              return Future.value(false);
            },
            child: AlertDialog(
              title: Text(message),
              actions: <Widget>[
                // Exit is not allowed for iOS apps
                Platform.isAndroid
                    ? FlatButton(
                        child: Text("Exit"),
                        onPressed: () {
                          SystemChannels.platform
                              .invokeMethod('SystemNavigator.pop');
                        },
                      )
                    : Column(),
                FlatButton(
                  child: Text("OK"),
                  onPressed: () {
                    if (isPassword) {
                      _sendPassword(input);
                    } else {
                      DownloadHandler().testConnection(input, global.context);
                    }
                  },
                ),
              ],
              content: textField,
            ),
           );
      });
}

void _sendPassword(String password) async {
  if (Navigator.canPop(global.context)) Navigator.pop(global.context);
  await DownloadHandler().postPassword(global.url, password);
  DownloadHandler().testConnection(global.url, global.context);
}
