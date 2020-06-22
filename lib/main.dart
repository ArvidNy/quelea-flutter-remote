import 'package:flutter/material.dart';
import 'package:preferences/preferences.dart';

import './main-content.dart';
import './utils/global-utils.dart' as global;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PrefService.init(prefix: 'pref_');
  runApp(QueleaMobileRemote());
}

class QueleaMobileRemote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    setGlobals(context);
    return MaterialApp(
      title: 'Quelea Mobile Remote',
      theme: ThemeData(
        primaryColor: Colors.black,
        primaryTextTheme: TextTheme(
          headline5: TextStyle(color: Colors.white),
        ),
      ),
      home: Scaffold(
        key: global.scaffoldKey,
        body: MainPage(),
      ),
    );
  }

  /// Set global variables that might be needed from different classes.
  void setGlobals(BuildContext context) async {
    global.chapterList = await DefaultAssetBundle.of(context)
        .loadString("assets/chapter_lengths.txt");
  }
}
