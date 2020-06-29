import 'package:flutter/material.dart';
import 'package:preferences/preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../handlers/download-handler.dart';
import '../handlers/language-delegate.dart';
import '../utils/global-utils.dart' as global;

/// A page for setting the user options.
///
/// Note: A lot of the settings are currently
/// disabled as the features are not yet
/// implemented in this beta version.
/// It's on the TODO list.
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
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: PreferencePage([
        PreferenceTitle(AppLocalizations.of(global.context)
            .getText('server.settings.heading')),
        TextFieldPreference(
          AppLocalizations.of(global.context)
              .getText('navigate.remote.control.label'),
          'server_url',
          autofocus: false,
          validator: (s) {
            // Workaround for the broken onChange method
            PrefService.setString("server_url", s);
            global.url = s;
          },
          onChange: () {
            // Does not work at the moment
            DownloadHandler().testConnection(global.url, context);
          },
        ),
        CheckboxPreference(
          AppLocalizations.of(global.context).getText('remote.use.autoconnect'),
          'use_autoconnect',
          defaultVal: true,
          disabled: false,
        ),
        // Should not be needed
        // DropdownPreference(
        //   AppLocalizations.of(global.context)
        //       .getText('Timeout length for auto-connect'),
        //   'autoconnect_timout',
        //   defaultVal: 'Medium',
        //   values: [
        //     AppLocalizations.of(global.context).getText('Short'),
        //     AppLocalizations.of(global.context).getText('Medium'),
        //     AppLocalizations.of(global.context).getText('Long')
        //   ],
        //   disabled: true,
        // ),
        PreferenceTitle(AppLocalizations.of(global.context)
            .getText('remote.navigation.settings.title')),
        CheckboxPreference(
          AppLocalizations.of(global.context)
              .getText('remote.enable.volume.navigation'),
          'volume_navigation_use',
          desc: AppLocalizations.of(global.context)
              .getText("remote.volume.navigation.description"),
          disabled: true,
          onChange: () {
            setState(() {});
          },
          onDisable: () {
            PrefService.setBool('exp_showos', false);
          },
        ),
        CheckboxPreference(
          AppLocalizations.of(global.context).getText('remote.enable.dpad.navigation'),
          'dpad_navigation_use',
          desc: AppLocalizations.of(global.context)
              .getText("remote.dpad.navigation.description"),
          disabled: true,
          onChange: () {
            setState(() {});
          },
          onDisable: () {
            PrefService.setBool('exp_showos', false);
          },
        ),
        DropdownPreference(
          AppLocalizations.of(global.context)
              .getText('remote.swipe.navigation.title'),
          'swipe_navigation_action',
          desc: AppLocalizations.of(global.context)
              .getText("remote.swipe.navigation.description"),
          defaultVal: 'off',
          values: ['off', 'slide', 'item'],
          displayValues: [
            AppLocalizations.of(global.context).getText('remote.action.nothing'),
            AppLocalizations.of(global.context).getText('remote.swipe.navigation.slide'),
            AppLocalizations.of(global.context).getText('remote.swipe.navigation.item')
          ],
          disabled: false,
          onChange: (change) {
            settingsFunctions['swipe'](
                !PrefService.getString("swipe_navigation_action")
                    .contains("off"));
            print(PrefService.getString("swipe_navigation_action"));
          },
        ),
        PreferenceHider([
          PreferenceTitle('Experimental'),
          SwitchPreference(
            'Show Operating System',
            'exp_showos',
            desc: 'This option shows the users operating system in his profile',
          )
        ], '!advanced_enabled'),
        PreferenceTitle(
            AppLocalizations.of(global.context).getText('general.options.heading')),
        CheckboxPreference(
          AppLocalizations.of(global.context)
              .getText('remote.disable.record'),
          'disable_record',
          disabled: false,
          defaultVal: false,
          onChange: () {
            settingsFunctions['record'](PrefService.getBool("disable_record"));
          },
        ),
        DropdownPreference(
          AppLocalizations.of(global.context).getText('interface.theme.label'),
          'app_theme',
          defaultVal: 'light',
          values: ['light', 'dark'],
          displayValues: [
            AppLocalizations.of(global.context).getText('default.theme.label'),
            AppLocalizations.of(global.context).getText('dark.theme.label')
          ],
          disabled: false,
          onChange: (value) => settingsFunctions['theme'](
              (PrefService.getString("app_theme") ?? "light")
                  .contains("light")),
        ),
        PreferenceTitle(
            AppLocalizations.of(global.context).getText('remote.information.title')),
        PreferencePageLink(
          AppLocalizations.of(global.context).getText('help.menu.about'),
          leading: Icon(Icons.info),
          trailing: Icon(Icons.keyboard_arrow_right),
          page: PreferencePage([
            PreferenceText(
              AppLocalizations.of(global.context).getText("remote.about.title"),
              onTap: () => _showAboutDialog(context),
            ),
            PreferenceText(
              AppLocalizations.of(global.context)
                  .getText("help.menu.discussion"),
              onTap: () => _launchURL("https://quelea.discourse.group/"),
            ),
            PreferenceText(
              AppLocalizations.of(global.context).getText("remote.report.issue"),
              onTap: () => _launchURL(
                  "https://github.com/arvidny/quelea-flutter-remote/issues"),
            ),
            PreferenceText(
              AppLocalizations.of(global.context)
                  .getText("remote.about.translating"),
              onTap: () => _launchURL("https://quelea.org/lang"),
            ),
            PreferenceText(
              AppLocalizations.of(global.context).getText("remote.privacy.policy"),
              onTap: () => _launchURL(
                  "https://quelea-projection.github.io/docs/Android_Applications_Privacy_Policy"),
            ),
            PreferenceText(
              AppLocalizations.of(global.context).getText("remote.donations.link"),
              onTap: () => _launchURL("https://paypal.me/ArvidNy"),
            ),
            PreferenceText(
              AppLocalizations.of(global.context).getText("help.menu.facebook"),
              onTap: () => _launchURL("https://facebook.com/quelea.projection"),
            ),
            PreferenceText(
              AppLocalizations.of(global.context).getText("help.menu.website"),
              onTap: () => _launchURL("https://quelea.org"),
            ),
            PreferenceText(
              AppLocalizations.of(global.context).getText("remote.source.code"),
              onTap: () => _launchURL("https://github.com/ArvidNy/quelea-flutter-remote"),
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
            AppLocalizations.of(global.context).getText("remote.control.app.name"),
        applicationVersion: "0.1.0",
        applicationLegalese: "© Quelea 2020",
        applicationIcon: Image.asset("images/ic_launcher.png"),
        children: <Widget>[
          Text(AppLocalizations.of(global.context).getText(
              "remote.about.text.app")),
          Text("\n"),
          Text(AppLocalizations.of(global.context).getText(
              "remote.about.text.support")),
          Text("\n"),
          Text(AppLocalizations.of(global.context).getText(
              "remote.about.text.responsibility"))
        ]);
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
