import 'package:flutter/material.dart';
import 'package:preferences/preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../handlers/sync-handler.dart';
import '../handlers/language-delegate.dart';
import '../objects/status-item.dart';

// Global variables
String url = PrefService.getString('server_url') ?? "http://192.168.0.1:1112";
BuildContext context;
bool debug = false;
SyncHandler syncHandler = new SyncHandler();
final mainScaffoldKey = GlobalKey<ScaffoldState>();
final drawerScaffoldKey = GlobalKey<ScaffoldState>();
String chapterList;
StatusItem statusHandler = StatusItem();
double serverVersion = 2020.0;
Map<String, String> lang = {};
final FocusNode focusNode = FocusNode();
String tempLyrics = "";
String tempSchedule = "";
String tempStatus = "";
List<String> supportedLanguages = [
  'en_GB',
  'en_US',
  'bg',
  'chs',
  'cs',
  'de',
  'es',
  'fi',
  'fr',
  'hu',
  'lt',
  'nl',
  'no',
  'pj',
  'pl',
  'pt',
  'pt_BR',
  'ro',
  'ru',
  'sk',
  'sv',
  'sw'
];

// Global methods
void needsNewerServerSnackbar(double version) {
  mainScaffoldKey.currentState.showSnackBar(SnackBar(
    duration: Duration(seconds: 3),
    content: Text(AppLocalizations.of(context)
        .getText("remote.needs.newer.version")
        .replaceFirst("\$1", version.toString())),
  ));
}

  launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
