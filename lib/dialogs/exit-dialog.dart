import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../handlers/language-delegate.dart';

showExitDialog<bool>(BuildContext context) {
  return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("${AppLocalizations.of(context).getText("exit.text")}?"),
          actions: <Widget>[
            FlatButton(
              child:
                  Text(AppLocalizations.of(context).getText("cancel.button")),
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
            FlatButton(
              child: Text(AppLocalizations.of(context).getText("exit.button")),
              onPressed: () {
                SystemChannels.platform
                            .invokeMethod('SystemNavigator.pop');
              },
            )
          ],
        );
      });
}
