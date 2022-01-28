import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
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
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Get.theme.indicatorColor)),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Get.theme.indicatorColor)),
        labelText: isPassword ? "" : global.url,
        labelStyle: TextStyle(color: Get.theme.textTheme.bodyText1.color)),
    onSubmitted: (text) {
      if (global.debug) debugPrint("submitted");
      if (isPassword) {
        _sendPassword(input);
      } else {}
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
            style: TextStyle(fontSize: 16),
          )),
          isPassword
              ? Container()
              : IconButton(
                  tooltip:
                      AppLocalizations.of(Get.context).getText("help.menu"),
                  icon: Icon(Icons.help),
                  onPressed: () => global.launchURL(
                      "https://quelea-projection.github.io/docs/Remote_Control_Troubleshooting"))
        ],
      ),
      actions: <Widget>[
        // Exit is not allowed for iOS apps
        Platform.isAndroid
            ? TextButton(
                child: Text(
                  AppLocalizations.of(Get.context).getText("exit.button"),
                ),
                onPressed: () {
                  SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                },
              )
            : Column(),
        isPassword
            ? Container()
            : TextButton(
                child: Text(
                  AppLocalizations.of(Get.context)
                      .getText("remote.search.server"),
                ),
                onPressed: () {
                  Get.back(closeOverlays: true);
                  DownloadHandler().showLoadingIndicator();
                  DownloadHandler().autoConnect();
                },
              ),
        TextButton(
          child: Text(
            AppLocalizations.of(Get.context).getText("ok.button"),
          ),
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
      content: Get.height < 600
          ? CustomTextField((value) => input = value)
          : textField,
    ),
  );
}

void _sendPassword(String password) async {
  await DownloadHandler().postPassword(global.url, password);
  DownloadHandler().testConnection(global.url, false);
}

class CustomTextField extends StatefulWidget {
  final Function setInput;
  CustomTextField(this.setInput);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  String url = global.url;

  void _setUrl(String url) {
    setState(() {
      this.url = url;
    });
    widget.setInput(url);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(border: Border.all(color: Colors.black)),
      height: 50,
      child: InkWell(
        child: Container(margin: EdgeInsets.only(left: 6), child: Text(url)),
        onTap: () => Navigator.of(Get.context).push(
          MaterialPageRoute(
            builder: (context) => SecondRoute(_setUrl, url),
          ),
        ),
      ),
    );
  }
}

class SecondRoute extends StatelessWidget {
  final Function setUrl;
  final String url;
  final TextEditingController controller = TextEditingController();

  SecondRoute(this.setUrl, this.url);

  @override
  Widget build(BuildContext context) {
    controller.text = url;
    KeyboardVisibilityController().onChange.listen((bool visible) {
      if (!visible) {
        Navigator.pop(context);
        setUrl(controller.text);
      }
    });
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                decoration: InputDecoration(
                  hintText: global.url,
                ),
                controller: controller,
                scrollPadding: EdgeInsets.all(20.0),
                keyboardType: TextInputType.multiline,
                maxLines: 1,
                autofocus: true,
              )
            ],
          ),
        ),
      ),
      resizeToAvoidBottomInset: true,
    );
  }
}
