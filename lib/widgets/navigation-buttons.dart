import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:preferences/preferences.dart';

import '../handlers/download-handler.dart';
import '../utils/global-utils.dart';

/// A class that returns a widget with 
/// the side navigation buttons.
class NavigationButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _itemButton(
            () => DownloadHandler().sendSignal(url + "/previtem", () => {}),
            "images/btn_prev_item.png"),
        Container(
          height: 12,
        ),
        _slideButton(() => DownloadHandler().sendSignal(url + "/prev", () => {}),
            "images/btn_prev_slide.png"),
        Container(
          height: 12,
        ),
        _slideButton(() => DownloadHandler().sendSignal(url + "/next", () => {}),
            "images/btn_next_slide.png"),
        Container(
          height: 12,
        ),
        _itemButton(
            () => DownloadHandler().sendSignal(url + "/nextitem", () => {}),
            "images/btn_next_item.png"),
      ],
    );
  }

  _itemButton(void Function() clickFunction, String imagePath) {
    bool isLightTheme = (PrefService.getString("app_theme") ?? "light").contains("light");
    return Container(
      width: 52,
      height: MediaQuery.of(Get.context).size.height * 0.1,
      child: RaisedButton(
          onPressed: clickFunction,
          elevation: 10,
          shape: RoundedRectangleBorder(
              side: BorderSide(color: isLightTheme ? Colors.black12 : Colors.white, width: 1),
              borderRadius: BorderRadius.all(Radius.circular(22))),
          color: isLightTheme ? Colors.grey.shade300 : Colors.grey[800],
          child: Image.asset(imagePath)),
    );
  }

  _slideButton(void Function() clickFunction, String imagePath) {
    bool isLightTheme = (PrefService.getString("app_theme") ?? "light").contains("light");
    return Expanded(
        child: Container(
      width: 52,
      child: RaisedButton(
          onPressed: clickFunction,
          elevation: 10,
          shape: RoundedRectangleBorder(
              side: BorderSide(color: isLightTheme ? Colors.black12 : Colors.white, width: 1),
              borderRadius: BorderRadius.all(Radius.circular(22))),
          color: isLightTheme ? Colors.grey.shade300 : Colors.grey[800],
          child: Image.asset(imagePath)),
    ));
  }
}
