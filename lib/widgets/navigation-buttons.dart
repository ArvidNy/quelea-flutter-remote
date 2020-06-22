import 'package:flutter/material.dart';

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
            () => DownloadHandler().download(url + "/previtem", () => {}),
            "images/btn_prev_item.png"),
        Container(
          height: 12,
        ),
        _slideButton(() => DownloadHandler().download(url + "/prev", () => {}),
            "images/btn_prev_slide.png"),
        Container(
          height: 12,
        ),
        _slideButton(() => DownloadHandler().download(url + "/next", () => {}),
            "images/btn_next_slide.png"),
        Container(
          height: 12,
        ),
        _itemButton(
            () => DownloadHandler().download(url + "/nextitem", () => {}),
            "images/btn_next_item.png"),
      ],
    );
  }

  _itemButton(void Function() clickFunction, String imagePath) {
    return Container(
      width: 52,
      height: MediaQuery.of(context).size.height * 0.1,
      child: RaisedButton(
          onPressed: clickFunction,
          elevation: 10,
          shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.black12, width: 1),
              borderRadius: BorderRadius.all(Radius.circular(22))),
          color: Colors.grey.shade300,
          child: Image.asset(imagePath)),
    );
  }

  _slideButton(void Function() clickFunction, String imagePath) {
    return Expanded(
        child: Container(
      width: 52,
      child: RaisedButton(
          onPressed: clickFunction,
          elevation: 10,
          shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.black12, width: 1),
              borderRadius: BorderRadius.all(Radius.circular(22))),
          color: Colors.grey.shade300,
          child: Image.asset(imagePath)),
    ));
  }
}
