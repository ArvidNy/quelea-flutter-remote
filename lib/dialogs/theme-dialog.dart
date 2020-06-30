import 'package:flutter/material.dart';

import '../handlers/download-handler.dart';
import '../handlers/language-delegate.dart';
import '../utils/global-utils.dart' as global;

showThemesDialog(BuildContext context, List<String> themes) {
  showDialog(
    context: context,
    child: AlertDialog(
      actions: <Widget>[
        FlatButton(
            onPressed: () =>
                Navigator.canPop(context) ? Navigator.pop(context) : null,
            child: Text(AppLocalizations.of(context).getText("cancel.button"))),
      ],
      content: Container(
        width: double.maxFinite,
        child: ListView.builder(
            itemCount: themes.length,
            itemBuilder: (context, index) {
              return Column(
                children: <Widget>[
                  InkWell(
                    child: Image.network("${global.url}/themethumb$index"),
                    onTap: () {
                      DownloadHandler().sendSignal(
                          "${global.url}/settheme/${themes[index]}", () {
                        Scaffold.of(global.context).showSnackBar(
                          SnackBar(
                            content: Text(
                                AppLocalizations.of(context).getText("remote.theme.was.set").replaceFirst("\$1", themes[index])),
                          ),
                        );
                      });
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    },
                  ),
                  Text(themes[index]),
                ],
              );
            }),
      ),
    ),
  );
}
