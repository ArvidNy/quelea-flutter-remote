import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:get/route_manager.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import '../handlers/server-search-handler.dart';
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
  Future download(String urlString, Function update, {Duration timeout}) async {
    if (global.debug) debugPrint(urlString);
    try {
      var url = Uri.parse(urlString);
      var httpClient = HttpClient();
      httpClient.connectionTimeout = timeout ?? Duration(milliseconds: 5000);
      httpClient.badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true);
      var request = await httpClient.getUrl(url);
      var response = await request.close();
      var data = await utf8.decoder.bind(response).join();
      if (response.statusCode == 200) {
        _parseData(data, urlString, update);
      } else {
        if (global.debug)
          debugPrint("Got response code ${response.statusCode}");
      }
      connectionFailed = 0;
    } catch (exception) {
      if (global.debug)
        debugPrint(
            "Failed with the following exception ${exception.toString()}");
      if (urlString.contains("lyrics")) {
        connectionFailed++;
        if (global.debug) debugPrint("failed: $connectionFailed");
      }
      if (connectionFailed > 5) {
        Get.back(closeOverlays: true);
        Get.dialog(getLoginDialog(
            AppLocalizations.of(Get.context)
                .getText("remote.failed.finding.server"),
            false));
        connectionFailed = 0;
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
    if (global.debug) debugPrint(urlString);
    try {
      var url = Uri.parse(urlString);
      var httpClient = HttpClient();
      httpClient.badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true);
      var request = await httpClient.getUrl(url);
      var response = await request.close();
      if (response.statusCode != 200) {
        _showSignalFailedSnackbar();
      }
      update();
    } catch (exception) {
      if (global.debug)
        debugPrint("Failed sending $urlString with the exception: $exception");
      _showSignalFailedSnackbar();
    }
  }

  void _parseData(String data, String urlString, Function update) {
    if (urlString.contains("lyrics")) {
      if (global.tempLyrics != data || data.contains("play()")) {
        global.tempLyrics = data;
        update(LiveItem(data));
      }
    } else if (urlString.contains("schedule")) {
      if (global.tempSchedule != data) {
        update(parser.getSchedule(data));
        global.tempSchedule = data;
      }
    } else if (urlString.contains("status")) {
      if (global.tempStatus != data) {
        global.statusHandler.parseStatus(data);
        global.tempStatus = data;
      }
      update(global.statusHandler);
    } else if (urlString.contains("search")) {
      parser.getSearchResults(data);
    } else if (urlString.contains("song")) {
      update(parser.getText(data, ["a"]));
    } else if (urlString.contains("addbible")) {
      Get.rawSnackbar(
          message: data,
          duration: Duration(seconds: 3),
          backgroundColor: Get.theme.colorScheme.secondary);
      update();
    } else {
      update(data);
    }
  }

  /// Sends a password string to the server.
  Future postPassword(String urlString, String password) async {
    var url = Uri.parse(urlString);
    HttpClient httpClient = HttpClient();
    httpClient.badCertificateCallback =
        ((X509Certificate cert, String host, int port) => true);
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
  void testConnection(String url, bool autoConnect) {
    if (global.debug) debugPrint("Test " + url);
    if (!url.startsWith("http")) url = "http://" + url;
    if (_urlIsOk(url)) {
      global.url = url;
      _testConnection(url).then((onValue) {
        if (global.debug) debugPrint(onValue["code"].toString());
        if (onValue["code"] == 200) {
          _handleTestResults(onValue, autoConnect, url);
        } else {
          _failedConnectingDialog(autoConnect);
        }
      }).catchError((onError) {
        if (global.debug) debugPrint(onError.toString());
        _failedConnectingDialog(autoConnect);
      });
    }
  }

  void _handleTestResults(onValue, bool autoConnect, String url) {
    if (global.debug) print(onValue['data']);
    Get.back(closeOverlays: true);
    if (onValue["data"].toString().contains("password")) {
      Get.dialog(getLoginDialog(
          AppLocalizations.of(Get.context).getText("remote.control.password"),
          true));
    } else if (onValue["data"].toString().contains("logoButton")) {
      global.syncHandler.isConnected = true;
      Get.rawSnackbar(
          message: AppLocalizations.of(Get.context).getText("remote.connected"),
          duration: Duration(seconds: 3),
          backgroundColor: Get.theme.colorScheme.secondary);
      PrefService.setString("server_url", url);
      FocusScope.of(Get.context).requestFocus(global.focusNode);
      global.syncHandler.start();
      download("$url/serverversion", (response) {
        if (response.toString().contains("apple-mobile-web-app-capable")) {
          global.serverVersion = 2020.0;
        } else {
          global.serverVersion = double.parse(response.toString());
        }
      });
    } else {
      global.syncHandler.isConnected = false;
      Get.dialog(getLoginDialog(
          AppLocalizations.of(Get.context).getText("remote.wrong.content"),
          false));
    }
  }

  bool _urlIsOk(url) {
    if (url.length - url.replaceAll(":", "").length > 2) {
      Get.dialog(getLoginDialog(
          AppLocalizations.of(Get.context).getText("remote.ipv6.not.supported"),
          false));
      return false;
    } else if (!url.replaceFirst("://", "").contains(":")) {
      Get.dialog(getLoginDialog(
          AppLocalizations.of(Get.context).getText("remote.port.needed"),
          false));
      return false;
    }
    return true;
  }

  void _failedConnectingDialog(bool autoConnect) {
    global.syncHandler.isConnected = false;
    if (autoConnect) {
      DownloadHandler().autoConnect();
    } else {
      Get.back(closeOverlays: true);
      Get.dialog(getLoginDialog(
          AppLocalizations.of(Get.context).getText(global.isFirstRun()
              ? "navigate.remote.control.label"
              : "remote.failed.finding.server"),
          false));
    }
  }

  /// Returns a list of search results from a string query.
  Future<List<SearchItem>> searchResults(String query) async {
    return _testConnection(global.url + "/search/$query").then((onValue) {
      return parser.getSearchResults(onValue["data"].toString());
    });
  }

  void autoConnect() async {
    if (await (Connectivity().checkConnectivity()) == ConnectivityResult.wifi) {
      var wifiIP = await (NetworkInfo().getWifiIP());
      if (global.debug) debugPrint(wifiIP);
      final stream = ServerSearchHandler.discover2(
          wifiIP.substring(0, wifiIP.lastIndexOf(".")), 50015,
          timeout: Duration(milliseconds: 3000), start: 1, end: 200);
      // iOS devices (or at least the simulator) seem to get overloaded when
      // searching all 256 IP numbers, so only pinging the first 200 here.
      // If the server would be located at a higher IP, it can be entered manually.
      try {
        String foundAddr = "";
        stream.listen((NetworkAddress addr) {
          if (addr.exists) {
            if (global.debug) debugPrint("found ${addr.ip}");
            foundAddr = addr.ip;
            _checkAutoConnectUrl(foundAddr);
          }
        }).onDone(() {
          if (global.debug) debugPrint("done $foundAddr");
          if (foundAddr.isEmpty) {
            Get.back(closeOverlays: true);
            Get.dialog(getLoginDialog(
                AppLocalizations.of(Get.context)
                    .getText("remote.failed.finding.server"),
                false));
          } else if (!global.syncHandler.isConnected) {
            if (global.debug) debugPrint("check autoconnect URL");
            _checkAutoConnectUrl(foundAddr);
          }
        });
      } catch (e) {
        if (global.debug)
          debugPrint("Failed auto-connecting with the following exception: $e");
        Get.back(closeOverlays: true);
        Get.dialog(getLoginDialog(
            AppLocalizations.of(Get.context)
                .getText("remote.failed.finding.server"),
            false));
      }
    } else {
      Get.back(closeOverlays: true);
      Get.dialog(getLoginDialog(
          AppLocalizations.of(Get.context).getText("remote.no.wifi"), false));
    }
  }

  void _checkAutoConnectUrl(String foundAddr) {
    DownloadHandler().download("http://$foundAddr:50015", (html) {
      if (html.toString().contains("\n")) {
        String remoteUrl = html.toString().split("\n")[1];
        // Avoid issues with unsupported IPv6 from the server
        // and only use the port number
        if (remoteUrl.length - remoteUrl.replaceAll(":", "").length > 2) {
          remoteUrl =
              foundAddr + remoteUrl.substring(remoteUrl.lastIndexOf(":"));
        }
        testConnection(remoteUrl, false);
      }
    }, timeout: Duration(seconds: 2)).catchError(
        (e) => debugPrint("error: $e"));
  }

  Future _testConnection(String urlString) async {
    if (global.debug) debugPrint("test $urlString");
    var url = Uri.parse(urlString);
    var httpClient = HttpClient();
    httpClient.connectionTimeout = Duration(milliseconds: 3000);
    httpClient.badCertificateCallback =
        ((X509Certificate cert, String host, int port) => true);
    var request = await httpClient.getUrl(url);
    var response = await request.close();
    var data = await utf8.decoder.bind(response).toList();
    return {"code": response.statusCode, "data": data};
  }

  void showLoadingIndicator() {
    Get.rawSnackbar(
        message:
            "${AppLocalizations.of(Get.context).getText("loading.text")}...",
        showProgressIndicator: true,
        duration: Duration(seconds: 60),
        onTap: (object) => Get.dialog(getLoginDialog(
            AppLocalizations.of(Get.context)
                .getText("navigate.remote.control.label"),
            false)),
        backgroundColor: Get.theme.colorScheme.secondary);
  }

  void _showSignalFailedSnackbar() {
    Get.rawSnackbar(
        message:
            AppLocalizations.of(Get.context).getText("remote.signal.failed"),
        duration: Duration(seconds: 3),
        backgroundColor: Get.theme.colorScheme.secondary);
  }
}
