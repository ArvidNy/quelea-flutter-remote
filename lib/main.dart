import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:preferences/preferences.dart';
import 'package:wakelock/wakelock.dart';

import './main-content.dart';
import './utils/color-utils.dart';
import './utils/global-utils.dart' as global;
import './handlers/language-delegate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PrefService.init(prefix: 'pref_');
  runApp(QueleaMobileRemote());
}

class QueleaMobileRemote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    setGlobals(context);
    Wakelock.enable();
    return StreamBuilder<bool>(
        initialData: true,
        builder: (context, snapshot) {
          return GetMaterialApp(
            title: "Quelea Mobile Remote",
            debugShowCheckedModeBanner: global.debug,
            supportedLocales: getSupportedLocales(),
            localizationsDelegates: [
              AppLocalizationsDelegate(),
              GlobalWidgetsLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
            ],
            theme: ThemeData(
              brightness: Brightness.light,
              primaryColor: Colors.black,
              indicatorColor: Colors.grey[600],
              appBarTheme: AppBarTheme(
                backgroundColor: Colors.black,
                titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
                iconTheme: IconThemeData(color: Colors.white),
              ),
              colorScheme: ColorScheme.fromSwatch(primarySwatch: primaryBlack)
                  .copyWith(
                      brightness: Brightness.light,
                      secondary: Colors.grey[800]),
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              primaryColor: Colors.black,
              indicatorColor: Colors.grey[600],
              primarySwatch: primaryBlack,
              appBarTheme: AppBarTheme(
                backgroundColor: Colors.black,
                titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
                iconTheme: IconThemeData(color: Colors.white),
              ),
              colorScheme: ColorScheme.fromSwatch(primarySwatch: primaryBlack)
                  .copyWith(
                      brightness: Brightness.dark, secondary: Colors.grey[800]),
            ),
            themeMode: (PrefService.getString("app_theme") ?? "light")
                    .contains("light")
                ? ThemeMode.light
                : ThemeMode.dark,
            home: Scaffold(
              resizeToAvoidBottomInset: false,
              body: MainPage(),
            ),
          );
        });
  }

  /// Set global variables that might be needed from different classes.
  void setGlobals(BuildContext context) async {
    global.chapterList = await DefaultAssetBundle.of(context)
        .loadString("assets/chapter_lengths.txt");
  }

  getSupportedLocales() {
    List<Locale> locales = [];
    for (int i = 0; i < global.supportedLanguages.length; i++) {
      if (global.supportedLanguages[i].contains("_")) {
        locales.add(Locale.fromSubtags(
            languageCode: global.supportedLanguages[i].split("_")[0],
            countryCode: global.supportedLanguages[i].split("_")[1]));
      } else {
        locales.add(
            Locale.fromSubtags(languageCode: global.supportedLanguages[i]));
      }
    }
    return locales;
  }
}
