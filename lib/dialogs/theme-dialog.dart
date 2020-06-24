import 'package:flutter/material.dart';
import 'package:org.quelea.mobileremote/handlers/download-handler.dart';

import '../utils/global-utils.dart' as global;

showThemesDialog(BuildContext context, List<String> themes) {
  showDialog(
    context: context,
    child: AlertDialog(
      actions: <Widget>[
        FlatButton(
            onPressed: () =>
                Navigator.canPop(context) ? Navigator.pop(context) : null,
            child: Text("Cancel")),
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
                      DownloadHandler().download(
                          "${global.url}/settheme/${themes[index]}", (d) {
                        Scaffold.of(global.context).showSnackBar(
                          SnackBar(
                            content: Text(
                                "${themes[index]} was set as the global theme"),
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
