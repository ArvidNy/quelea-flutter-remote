import 'dart:async';

import 'package:flutter/material.dart';
import 'package:preferences/preferences.dart';

import './main-content.dart';
import './utils/global-utils.dart' as global;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PrefService.init(prefix: 'pref_');
  runApp(QueleaMobileRemote());
}

StreamController<bool> isLightTheme = StreamController();

class QueleaMobileRemote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    setGlobals(context);
    return StreamBuilder<bool>(
        initialData: true,
        stream: isLightTheme.stream,
        builder: (context, snapshot) {
          return MaterialApp(
            title: 'Quelea Mobile Remote',
            theme: ThemeData(
              brightness: (PrefService.getString("app_theme") ?? "light")
                      .contains("light")
                  ? Brightness.light
                  : Brightness.dark,
              primaryColor: Colors.black,
              accentColor: Colors.grey[600],
            ),
            home: Scaffold(
              key: global.scaffoldKey,
              body: MainPage(isLightTheme),
            ),
          );
        });
  }

  /// Set global variables that might be needed from different classes.
  void setGlobals(BuildContext context) async {
    global.chapterList = await DefaultAssetBundle.of(context)
        .loadString("assets/chapter_lengths.txt");
  }
}
