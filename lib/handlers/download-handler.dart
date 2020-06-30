import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:ping_discover_network/ping_discover_network.dart';
import 'package:preferences/preference_service.dart';

import '../dialogs/login-dialog.dart';
import '../objects/search-item.dart';
import '../utils/global-utils.dart' as global;
import '../utils/html-parser.dart' as parser;
import '../widgets/live-item.dart';
import './language-delegate.dart';

/// A class for handeling all network signals and receiving data.
class DownloadHandler {
  static int connectionFailed = 0;

  /// An async method for downloading the page content of a URL.
  /// The results are parsed in a separate method (`_parseData`)
  /// and/or can be accessed through the passed function `update`.
  ///
  /// Example:
  /// ```
  /// download(global.url + "/lyrics", (downloadedData) => {
  ///   // parse downloaded data
  /// })
  /// ```
  ///
  /// Note: Some URLs will return specific items, such as
  /// `"/lyrics"` (`LiveItem`) or `"/schedule"` (`ScheduleList`).
  /// See the method `_parseData` for more info.
  /// 
  /// This method should only be used when a server response is
  /// expected. Use `sendSignal` otherwise.
  Future download(String urlString, Function update) async {
    if (global.debug) print(urlString);
    try {
      var url = Uri.parse(urlString);
      var httpClient = HttpClient();
      var request = await httpClient.getUrl(url);
      var response = await request.close();
      var data = await utf8.decoder.bind(response).toList();
      _parseData(data, urlString, update);
      connectionFailed = 0;
    } catch (exception) {
      if (urlString.contains("lyrics")) connectionFailed++;
      if (connectionFailed > 5) {
        if (!Navigator.canPop(global.context)) {
          showInputDialog(
              global.context,
              AppLocalizations.of(global.context)
                  .getText("remote.failed.finding.server"),
              false);
        }
        global.syncHandler.stop();
      }
    }
  }

  /// An async method for sending a signal to the server.
  ///
  /// Example:
  /// ```
  /// sendSignal(global.url + "/play", () => {
  ///   // Code to run when finished
  /// })
  /// ```
  ///
  /// This method should only be used when no server response is
  /// expected. Use `download` otherwise.
  Future sendSignal(String urlString, Function update) async {
    if (global.debug) print(urlString);
    try {
      var url = Uri.parse(urlString);
      var httpClient = HttpClient();
      var request = await httpClient.getUrl(url);
      var response = await request.close();
      print(response.statusCode);
      if (response.statusCode != 200) {
        _showSignalFailedSnackbar();
      }
      update();
    } catch (exception) {
      print("exception: $exception");
      _showSignalFailedSnackbar();
    }
  }

  void _parseData(List<String> data, String urlString, Function update) {
    if (urlString.contains("lyrics"))
      update(LiveItem(data.toString()));
    else if (urlString.contains("schedule"))
      update(parser.getSchedule(data.join()));
    else if (urlString.contains("status")) {
      global.statusHandler.parseStatus(data.join());
      update(global.statusHandler);
    } else if (urlString.contains("search")) {
      parser.getSearchResults(data.join());
    } else if (urlString.contains("translations") ||
        urlString.contains("books")) {
      update(data.join());
    } else if (urlString.contains("getthemes")) {
      update(data.join());
    } else if (urlString.contains("song")) {
      update(parser.getText(data.join(), ["a"]));
    } else if (urlString.contains("addbible")) {
      global.scaffoldKey.currentState.showSnackBar(
        SnackBar(
          duration: Duration(seconds: 3),
          content: Text(data.join()),
        ),
      );
      update();
    } else {
      update(data.join());
    }
  }

  /// Sends a password string to the server.
  Future postPassword(String urlString, String password) async {
    var url = Uri.parse(urlString);
    HttpClient httpClient = HttpClient();
    var request = await httpClient.postUrl(url);
    request.write("password=$password");
    var response = await request.close();
    await utf8.decoder.bind(response).toList();
    httpClient.close();
  }

  /// Tests if the Quelea server is found at a specific URL.
  ///
  /// Opens the `showInputDialog` for entering a new URL
  /// if the connection fails or for entering the password
  /// if the connection is successful.
  void testConnection(String url, BuildContext context) {
    if (global.debug) print("Test " + url);
    if (Navigator.canPop(context)) Navigator.pop(context);
    if (!url.startsWith("http")) url = "http://" + url;
    if (!url.replaceFirst("://", "").contains(":")) {
      SchedulerBinding.instance.addPostFrameCallback((_) => showInputDialog(
          context,
          AppLocalizations.of(global.context).getText("remote.port.needed"),
          false));
    } else {
      SchedulerBinding.instance
          .addPostFrameCallback((_) => _showLoadingIndicator(context));
      global.url = url;
      _testConnection(url).then((onValue) {
        SchedulerBinding.instance.addPostFrameCallback(
            (_) => global.scaffoldKey.currentState.hideCurrentSnackBar());
        if (onValue["code"] == 200) {
          global.syncHandler.isConnected = true;
          if (onValue["data"].toString().contains("password")) {
            showInputDialog(
                context,
                AppLocalizations.of(global.context)
                    .getText("remote.control.password"),
                true);
          } else if (onValue["data"].toString().contains("logobutton")) {
            Scaffold.of(context).showSnackBar(SnackBar(
              duration: Duration(seconds: 3),
              content: Text(AppLocalizations.of(global.context)
                  .getText("remote.connected")),
            ));
            PrefService.setString("server_url", url);
            FocusScope.of(context).requestFocus(global.focusNode);
            global.syncHandler.start();
            download("$url/serverversion", (response) {
              if (response
                  .toString()
                  .contains("apple-mobile-web-app-capable")) {
                global.serverVersion = 2020.0;
              } else {
                global.serverVersion = double.parse(response.toString());
              }
            });
          } else {
            showInputDialog(
                context,
                AppLocalizations.of(global.context)
                    .getText("remote.wrong.content"),
                false);
          }
        } else {
          SchedulerBinding.instance.addPostFrameCallback(
              (_) => global.scaffoldKey.currentState.hideCurrentSnackBar());
          showInputDialog(
              context,
              AppLocalizations.of(global.context)
                  .getText("remote.failed.finding.server"),
              false);
        }
      }).catchError((onError) {
        SchedulerBinding.instance.addPostFrameCallback(
            (_) => global.scaffoldKey.currentState.hideCurrentSnackBar());
        print("Catch error: " + onError.toString());
        showInputDialog(
            context,
            AppLocalizations.of(global.context)
                .getText("remote.failed.finding.server"),
            false);
      });
    }
  }

  /// Returns a list of search results from a string query.
  Future<List<SearchItem>> searchResults(String query) async {
    return _testConnection(global.url + "/search/$query").then((onValue) {
      return parser.getSearchResults(onValue["data"].toString());
    });
  }

  void autoConnect(BuildContext context) async {
    if (await (Connectivity().checkConnectivity()) == ConnectivityResult.wifi) {
      var wifiIP = await (Connectivity().getWifiIP());
      final stream = NetworkAnalyzer.discover2(
          wifiIP.substring(0, wifiIP.lastIndexOf(".")), 50015);
      stream.listen((NetworkAddress addr) {
        if (addr.exists) {
          DownloadHandler().download("http://${addr.ip}:50015", (html) {
            String remoteUrl = html.toString().split("\n")[1];
            testConnection(remoteUrl, context);
          });
        }
      });
    } else {
      showInputDialog(context,
          AppLocalizations.of(global.context).getText("remote.no.wifi"), false);
    }
  }

  Future _testConnection(String urlString) async {
    print("test $urlString");
    var url = Uri.parse(urlString);
    var httpClient = HttpClient();
    httpClient.connectionTimeout = Duration(milliseconds: 3000);
    var request = await httpClient.getUrl(url);
    var response = await request.close();
    var data = await utf8.decoder.bind(response).toList();
    return {"code": response.statusCode, "data": data.join()};
  }

  void _showLoadingIndicator(BuildContext context) {
    global.scaffoldKey.currentState.hideCurrentSnackBar();
    global.scaffoldKey.currentState.showSnackBar(
      SnackBar(
        duration: Duration(seconds: 90),
        content: Row(
          children: <Widget>[
            CircularProgressIndicator(),
            Padding(padding: EdgeInsets.all(16)),
            Text(
                "${AppLocalizations.of(global.context).getText("loading.text")}...")
          ],
        ),
      ),
    );
  }

  void _showSignalFailedSnackbar() {
    global.scaffoldKey.currentState.hideCurrentSnackBar();
    global.scaffoldKey.currentState.showSnackBar(SnackBar(
      duration: Duration(seconds: 3),
      content: Text(AppLocalizations.of(global.context).getText("remote.signal.failed")),
    ));
  }
}
