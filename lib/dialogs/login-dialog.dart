import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../handlers/download-handler.dart';
import '../handlers/language-delegate.dart';
import '../utils/global-utils.dart' as global;

/// Shows a dialog for entering either a URL or a password
void showInputDialog(BuildContext context, String message, bool isPassword) {
  String input = global.url;
  TextField textField = TextField(
    onChanged: (text) => input = text,
    controller: TextEditingController(text: isPassword ? "" : global.url),
    keyboardType: TextInputType.url,
    decoration: InputDecoration(
        border: OutlineInputBorder(), labelText: isPassword ? "" : global.url),
    onSubmitted: (text) {
      if (global.debug) print("submitted");
      if (isPassword) {
        _sendPassword(input);
      } else {
        if (Navigator.canPop(global.context)) Navigator.pop(global.context);
        DownloadHandler().showLoadingIndicator(global.context);
        DownloadHandler().testConnection(input, global.context, false);
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
            title: Row(
              children: <Widget>[
                Expanded(child: Text(message)),
                isPassword ? Container() : IconButton(
                    icon: Icon(Icons.help),
                    onPressed: () => global.launchURL(
                        "https://quelea-projection.github.io/docs/Remote_Troubleshooting"))
              ],
            ),
            actions: <Widget>[
              // Exit is not allowed for iOS apps
              Platform.isAndroid
                  ? FlatButton(
                      child: Text(
                          AppLocalizations.of(context).getText("exit.button")),
                      onPressed: () {
                        SystemChannels.platform
                            .invokeMethod('SystemNavigator.pop');
                      },
                    )
                  : Column(),
              isPassword
                  ? Container()
                  : FlatButton(
                      child: Text(AppLocalizations.of(context)
                          .getText("remote.search.server")),
                      onPressed: () {
                        if (Navigator.canPop(global.context)) Navigator.pop(global.context);
                        DownloadHandler().showLoadingIndicator(context);
                        DownloadHandler().autoConnect(global.context);
                      },
                    ),
              FlatButton(
                child: Text(AppLocalizations.of(context).getText("ok.button")),
                onPressed: () {
                  if (isPassword) {
                    _sendPassword(input);
                  } else {
                    DownloadHandler().showLoadingIndicator(context);
                    DownloadHandler().testConnection(input, global.context, false);
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
  DownloadHandler().testConnection(global.url, global.context, false);
}
