import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:preferences/preferences.dart';

import '../handlers/download-handler.dart';
import '../handlers/language-delegate.dart';
import '../utils/global-utils.dart';

/// A class that returns a widget with all the
/// three hide buttons (logo, clear & black).
class ToggleHideButtons extends StatelessWidget {
  final double _itemWidth = 60;
  final bool logoPressed;
  final bool blackPressed;
  final bool clearPressed;

  ToggleHideButtons(this.logoPressed, this.blackPressed, this.clearPressed);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        _transparentArea(_itemWidth, true),
        _hideButton(
            imagePath: "images/btn-logo.png",
            isPressed: logoPressed,
            btnUrl: "tlogo",
            tooltip:
                AppLocalizations.of(Get.context).getText("remote.logo.text")),
        _transparentArea(_itemWidth / 2, false),
        _hideButton(
            color: Colors.black,
            isPressed: blackPressed,
            btnUrl: "black",
            tooltip: AppLocalizations.of(Get.context)
                .getText("black.screen.tooltip")),
        _transparentArea(_itemWidth / 2, false),
        _hideButton(
            color: Colors.white,
            isPressed: clearPressed,
            btnUrl: "clear",
            tooltip: AppLocalizations.of(Get.context)
                .getText("clear.text.tooltip")),
        _transparentArea(_itemWidth, true),
      ],
    );
  }

  Widget _hideButton(
      {String imagePath = "",
      Color color = Colors.transparent,
      bool isPressed,
      String btnUrl,
      String tooltip}) {
    bool isLightTheme =
        (PrefService.getString("app_theme") ?? "light").contains("light");
    Color pressedColor =
        isLightTheme ? Colors.grey.shade800 : Colors.greenAccent[700];
    Color normalColor =
        isLightTheme ? Colors.grey.shade200 : Colors.grey.shade600;
    return Container(
      width: _itemWidth,
      height: _itemWidth,
      child: Tooltip(
        message: tooltip,
        child: RaisedButton(
          elevation: 5,
          padding: EdgeInsets.all(8.0),
          onPressed: () =>
              DownloadHandler().sendSignal(url + "/$btnUrl", () => {}),
          shape: CircleBorder(),
          color: isPressed ? pressedColor : normalColor,
          child: Container(
            decoration: new BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: imagePath.isEmpty
                ? Container()
                : Image.asset(
                    imagePath,
                    fit: BoxFit.contain,
                  ),
          ),
        ),
      ),
    );
  }

  Widget _transparentArea(double size, bool expanded) {
    return expanded
        ? Expanded(
            child: Container(
              color: Colors.transparent,
              width: size,
              height: size,
            ),
          )
        : Container(
            color: Colors.transparent,
            width: size,
            height: size,
          );
  }
}
