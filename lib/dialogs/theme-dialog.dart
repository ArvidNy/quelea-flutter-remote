import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../handlers/download-handler.dart';
import '../handlers/language-delegate.dart';
import '../handlers/ssl-network-image.dart';
import '../utils/global-utils.dart' as global;

showThemesDialog(List<String> themes) {
  Get.dialog(
    AlertDialog(
      actions: <Widget>[
        FlatButton(
            onPressed: () => Get.back(closeOverlays: true),
            child: Text(
                AppLocalizations.of(Get.context).getText("cancel.button"))),
      ],
      content: Container(
        width: double.maxFinite,
        child: ListView.builder(
            itemCount: themes.length,
            itemBuilder: (context, index) {
              return Column(
                children: <Widget>[
                  InkWell(
                    child: global.url.startsWith("https")
                        ? Image(
                            image: NetworkImageSSL(
                                "${global.url}/themethumb$index"))
                        : Image.network("${global.url}/themethumb$index"),
                    onTap: () {
                      DownloadHandler().sendSignal(
                          "${global.url}/settheme/${themes[index]}", () {
                        Get.rawSnackbar(
                            message: AppLocalizations.of(Get.context)
                                .getText("remote.theme.was.set")
                                .replaceFirst("\$1", themes[index]),
                            backgroundColor: Get.theme.accentColor);
                      });
                      Get.back(closeOverlays: true);
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
