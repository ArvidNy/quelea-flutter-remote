import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/global-utils.dart' as global;

class AppLocalizations {
  AppLocalizations(this.locale);

  Locale locale;

  static Future<AppLocalizations> load(Locale locale) async {
    await _loadLangFile(locale.toString(), _localizedValues);
    await _loadLangFile("en_GB", _englishValues);
    return AppLocalizations(locale);
  }

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static Map<String, String> _localizedValues = {};
  static Map<String, String> _englishValues = {};

  static Future<void> _loadLangFile(String langCode, _localizedValues) async {
    String langString = await rootBundle.loadString("translations/$langCode.lang");
    for (String s in langString.split("\n")) {
      if (s.contains("=")) _localizedValues[s.split("=")[0]] = s.split("=")[1];
    }
  }

  String getText(String text) {
    String ret = _localizedValues[text] ?? _englishValues[text] ?? text;
    if (ret == text) {
      print("Failed loading string: '$text'");
    }
    // A workaround for the `DropdownPreference` in `SettingsPage` that gets too wide sometimes
    if (text.contains("swipe.navigation.item") || text.contains("swipe.navigation.slide") && ret.length > 10) {
      ret = ret.replaceFirst(" ", "\n", (ret.length/3).round());
    }
    return ret;
  }
}

class AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => global.supportedLanguages.contains(locale.toString());

@override
  Future<AppLocalizations> load(Locale locale) => AppLocalizations.load(locale);

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
