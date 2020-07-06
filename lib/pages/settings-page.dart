import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:preferences/preferences.dart';

import '../handlers/language-delegate.dart';
import '../utils/global-utils.dart' as global;

/// A page for setting the user options.
class SettingsPage extends StatefulWidget {
  SettingsPage({Key key, this.title, this.settingsFunctions}) : super(key: key);

  final String title;
  final Map<String, Function> settingsFunctions;

  @override
  _SettingsPageState createState() => _SettingsPageState(settingsFunctions);
}

class _SettingsPageState extends State<SettingsPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  Map<String, Function> settingsFunctions;

  _SettingsPageState(this.settingsFunctions);

  @override
  void initState() {
    super.initState();
    global.syncHandler.stop();
  }

  @override
  void dispose() {
    global.syncHandler.start();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: PreferencePage([
        PreferenceTitle(AppLocalizations.of(Get.context)
            .getText('server.settings.heading')),
        TextFieldPreference(
          AppLocalizations.of(Get.context)
              .getText('navigate.remote.control.label'),
          'server_url',
          autofocus: false,
          onChange: (s) {
            global.url = s;
          },
        ),
        CheckboxPreference(
          AppLocalizations.of(Get.context).getText('remote.use.autoconnect'),
          'use_autoconnect',
          defaultVal: true,
          disabled: false,
        ),
        // Should not be needed
        // DropdownPreference(
        //   AppLocalizations.of(Get.context)
        //       .getText('Timeout length for auto-connect'),
        //   'autoconnect_timout',
        //   defaultVal: 'Medium',
        //   values: [
        //     AppLocalizations.of(Get.context).getText('Short'),
        //     AppLocalizations.of(Get.context).getText('Medium'),
        //     AppLocalizations.of(Get.context).getText('Long')
        //   ],
        //   disabled: true,
        // ),
        PreferenceTitle(AppLocalizations.of(Get.context)
            .getText('remote.navigation.settings.title')),
        DropdownPreference(
          AppLocalizations.of(Get.context)
              .getText('remote.swipe.navigation.title'),
          'swipe_navigation_action',
          desc: AppLocalizations.of(Get.context)
              .getText("remote.swipe.navigation.description"),
          defaultVal: 'off',
          values: ['off', 'slide', 'item'],
          displayValues: [
            AppLocalizations.of(Get.context).getText('remote.action.nothing'),
            AppLocalizations.of(Get.context).getText('remote.action.slide'),
            AppLocalizations.of(Get.context).getText('remote.action.item')
          ],
          disabled: false,
          onChange: (change) {
            settingsFunctions['swipe'](
                !PrefService.getString("swipe_navigation_action")
                    .contains("off"));
          },
        ),
        Platform.isAndroid
            ? CheckboxPreference(
                AppLocalizations.of(Get.context)
                    .getText('remote.enable.volume.navigation'),
                'use_volume_navigation',
                desc: AppLocalizations.of(Get.context)
                    .getText("remote.volume.navigation.description"),
                disabled: false,
                onChange: () {
                  setState(() {});
                },
              )
            : Container(),
        PreferenceHider([
          DropdownPreference(
            AppLocalizations.of(Get.context).getText('remote.long.press.title'),
            'long_volume_action',
            desc: AppLocalizations.of(Get.context)
                .getText("remote.long.press.description"),
            defaultVal: 'nothing',
            values: ['nothing', 'slide', 'item', 'logo', 'clear', 'black'],
            displayValues: [
              AppLocalizations.of(Get.context).getText('remote.action.nothing'),
              AppLocalizations.of(Get.context).getText('remote.action.slide'),
              AppLocalizations.of(Get.context).getText('remote.action.item'),
              AppLocalizations.of(Get.context).getText('remote.action.logo'),
              AppLocalizations.of(Get.context).getText('remote.action.clear'),
              AppLocalizations.of(Get.context).getText('remote.action.black')
            ],
            disabled: false,
          ),
          DropdownPreference(
            AppLocalizations.of(Get.context)
                .getText('remote.double.press.title'),
            'double_volume_action',
            desc: AppLocalizations.of(Get.context)
                .getText("remote.double.press.description"),
            defaultVal: 'nothing',
            values: ['nothing', 'slide', 'item', 'logo', 'clear', 'black'],
            displayValues: [
              AppLocalizations.of(Get.context).getText('remote.action.nothing'),
              AppLocalizations.of(Get.context).getText('remote.action.slide'),
              AppLocalizations.of(Get.context).getText('remote.action.item'),
              AppLocalizations.of(Get.context).getText('remote.action.logo'),
              AppLocalizations.of(Get.context).getText('remote.action.clear'),
              AppLocalizations.of(Get.context).getText('remote.action.black')
            ],
            disabled: false,
          ),
        ], '!use_volume_navigation'),
        // Does keyboard shortcuts have to be optional?
        // CheckboxPreference(
        //   AppLocalizations.of(Get.context).getText('remote.enable.dpad.navigation'),
        //   'dpad_navigation_use',
        //   desc: AppLocalizations.of(Get.context)
        //       .getText("remote.dpad.navigation.description"),
        //   disabled: true,
        //   onChange: () {
        //     setState(() {});
        //   },
        //   onDisable: () {
        //     PrefService.setBool('exp_showos', false);
        //   },
        // ),
        PreferenceTitle(AppLocalizations.of(Get.context)
            .getText('general.options.heading')),
        CheckboxPreference(
          AppLocalizations.of(Get.context).getText('remote.disable.record'),
          'disable_record',
          disabled: false,
          defaultVal: false,
          onChange: () {
            settingsFunctions['record'](PrefService.getBool("disable_record"));
          },
        ),
        DropdownPreference(
          AppLocalizations.of(Get.context).getText('interface.theme.label'),
          'app_theme',
          defaultVal: 'light',
          values: ['light', 'dark'],
          displayValues: [
            AppLocalizations.of(Get.context).getText('default.theme.label'),
            AppLocalizations.of(Get.context).getText('dark.theme.label')
          ],
          disabled: false,
          onChange: (value) {
            settingsFunctions['setState']((){
              Get.changeThemeMode((PrefService.getString("app_theme") ?? "light")
                    .contains("light")
                ? ThemeMode.light
                : ThemeMode.dark);
            });
          },
        ),

        // settingsFunctions['theme'](
        //     (PrefService.getString("app_theme") ?? "light")
        //         .contains("light")),
        PreferenceTitle(AppLocalizations.of(Get.context)
            .getText('remote.information.title')),
        PreferencePageLink(
          AppLocalizations.of(Get.context).getText('help.menu.about'),
          leading: Icon(Icons.info),
          trailing: Icon(Icons.keyboard_arrow_right),
          page: PreferencePage([
            PreferenceText(
              AppLocalizations.of(Get.context).getText("remote.about.title"),
              onTap: () => _showAboutDialog(context),
            ),
            PreferenceText(
              AppLocalizations.of(Get.context).getText("help.menu.manual"),
              onTap: () => global.launchURL(
                  "https://quelea-projection.github.io/docs/Remote_Control_Manual"),
            ),
            PreferenceText(
              AppLocalizations.of(Get.context).getText("help.menu.discussion"),
              onTap: () => global.launchURL("https://quelea.discourse.group/"),
            ),
            PreferenceText(
              AppLocalizations.of(Get.context).getText("remote.report.issue"),
              onTap: () => global.launchURL(
                  "https://github.com/arvidny/quelea-flutter-remote/issues"),
            ),
            PreferenceText(
              AppLocalizations.of(Get.context)
                  .getText("remote.about.translating"),
              onTap: () => global.launchURL("https://quelea.org/lang"),
            ),
            PreferenceText(
              AppLocalizations.of(Get.context).getText("remote.privacy.policy"),
              onTap: () => global.launchURL(
                  "https://quelea-projection.github.io/docs/Android_Applications_Privacy_Policy"),
            ),
            PreferenceText(
              AppLocalizations.of(Get.context).getText("remote.donations.link"),
              onTap: () => global.launchURL("https://paypal.me/ArvidNy"),
            ),
            PreferenceText(
              AppLocalizations.of(Get.context).getText("help.menu.facebook"),
              onTap: () =>
                  global.launchURL("https://facebook.com/quelea.projection"),
            ),
            PreferenceText(
              AppLocalizations.of(Get.context).getText("help.menu.website"),
              onTap: () => global.launchURL("https://quelea.org"),
            ),
            PreferenceText(
              AppLocalizations.of(Get.context).getText("remote.source.code"),
              onTap: () => global.launchURL(
                  "https://github.com/ArvidNy/quelea-flutter-remote"),
            ),
          ]),
        ),
      ]),
    );
  }

  _showAboutDialog(BuildContext context) {
    showAboutDialog(
        context: context,
        applicationName:
            AppLocalizations.of(Get.context).getText("remote.control.app.name"),
        applicationVersion: "0.1.0",
        applicationLegalese: "© Quelea 2020",
        applicationIcon: Image.asset("images/ic_launcher.png"),
        children: <Widget>[
          Text(AppLocalizations.of(Get.context)
              .getText("remote.about.text.app")),
          Text("\n"),
          Text(AppLocalizations.of(Get.context)
              .getText("remote.about.text.support")),
          Text("\n"),
          Text(AppLocalizations.of(Get.context)
              .getText("remote.about.text.responsibility"))
        ]);
  }
}
