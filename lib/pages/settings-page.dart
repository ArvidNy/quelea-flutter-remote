import 'package:flutter/material.dart';
import 'package:preferences/preferences.dart';

import '../handlers/download-handler.dart';
import '../utils/global-utils.dart' as global;

/// A page for setting the user options.
/// 
/// Note: A lot of the settings are currently
/// disabled as the features are not yet
/// implemented in this beta version.
/// It's on the TODO list.
class SettingsPage extends StatefulWidget {
  SettingsPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: PreferencePage([
        PreferenceTitle('Server settings'),
        TextFieldPreference(
          'Server URL',
          'server_url',
          autofocus: false,
          validator: (s) {
            // Workaround for the broken onChange method
            PrefService.setString("server_url", s);
            global.url = s;
          },
          onChange: () { // Does not work at the moment
            DownloadHandler().testConnection(global.url, context);
          },
        ),
        CheckboxPreference(
          'Automatically try to find the server URL',
          'autoconnect_use',
          disabled: true,
          onChange: () {
            setState(() {
            });
          },
          onDisable: () {
            PrefService.setBool('exp_showos', false);
          },
        ),
        DropdownPreference(
          'Timeout length for auto-connect',
          'autoconnect_timout',
          defaultVal: 'Medium',
          values: ['Short', 'Medium', 'Long'],
          disabled: true,
        ),
        PreferenceTitle('Navigation settings'),
        CheckboxPreference(
          'Use volume rocker navigation',
          'volume_navigation_use',
          disabled: true,
          onChange: () {
            setState(() {});
          },
          onDisable: () {
            PrefService.setBool('exp_showos', false);
          },
        ),
        CheckboxPreference(
          'Use d-pad navigation',
          'dpad_navigation_use',
          disabled: true,
          onChange: () {
            setState(() {});
          },
          onDisable: () {
            PrefService.setBool('exp_showos', false);
          },
        ),
        DropdownPreference(
          'Swipe navigation action',
          'swipe_navigation_action',
          defaultVal: 'Do nothing',
          values: ['Do nothing', 'Next/previous slide', 'Next/previous item'],
          disabled: true,
        ),
        CheckboxPreference(
          'Use d-pad navigation',
          'dpad_navigation_use',
          disabled: true,
          onChange: () {
            setState(() {});
          },
          onDisable: () {
            PrefService.setBool('exp_showos', false);
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
        PreferenceTitle('General settings'),
        CheckboxPreference(
          'Disable the record button',
          'record_disable',
          disabled: true,
          onChange: () {
            setState(() {});
          },
          onDisable: () {
            PrefService.setBool('exp_showos', false);
          },
        ),
        DropdownPreference(
          'Application theme',
          'app_theme',
          defaultVal: 'Light',
          values: ['Light', 'Dark'],
          disabled: true,
        ),
        PreferenceTitle('Information'),
        PreferencePageLink(
          'About the app',
          leading: Icon(Icons.info),
          trailing: Icon(Icons.keyboard_arrow_right),
          page: PreferencePage([
            PreferenceText("About the app", onTap: () => _showAboutDialog(context),),
                        PreferenceText("Contact the developer", onTap: () => null,),
                        PreferenceText("How to translate the app", onTap: () => null,),
                        PreferenceText("Privacy policy", onTap: () => null,),
                      ]),
                    ),
                  ]),
                );
              }
              _showAboutDialog(BuildContext context) {
                showAboutDialog(context: context, applicationName: "Quelea Mobile Remote", applicationVersion: "0.1.0", applicationLegalese: "© Quelea 2020", applicationIcon:  Image.asset("images/ic_launcher.png"), children: <Widget>[
                  Text("This app is a non-profit app made to be used with the open source church software Quelea (http://quelea.org). This version is still in beta, so it's not flawless yet nor is it feature complete. This is a side project and mostly meant for personal usage, but is gladly shared with anyone who might find it useful."),
                  Text("\n"),
                  Text("Feel free to send me an email at arvid @ quelea.org if you have any questions or are experiencing issues, but make sure you\'ve started Quelea before the app (with both servers active), that both devices are connected to same network and that you\'ve entered the correct URL first."),
                  Text("\n"),
                  Text("I cannot guarantee a flawless experience, so I will not take responsibility for any issues that could occur in a live setting.")
                ]);
              }
}