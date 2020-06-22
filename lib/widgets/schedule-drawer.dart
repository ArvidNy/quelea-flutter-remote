import 'package:flutter/material.dart';

import '../handlers/download-handler.dart';
import '../pages/settings-page.dart';
import '../utils/global-utils.dart' as global;
import '../widgets/schedule-item.dart';

/// A class that returns the drawer that
/// displays the current schedule.
class ScheduleDrawer extends StatelessWidget {
  final List<ScheduleItem> scheduleItems;
  final Map<String, Function> _settingsFunctions;

  ScheduleDrawer(this.scheduleItems, this._settingsFunctions);

  @override
  Widget build(BuildContext context) {
    var flatButton = FlatButton(
      onPressed: () => _logout(context),
      child: Row(
        children: <Widget>[
          Icon(Icons.exit_to_app),
          Text("Logout"),
        ],
      ),
    );
    return Drawer(
      child: Column(
        children: <Widget>[
          Stack(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      height: 90,
                      child: DrawerHeader(
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Text('Schedule',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 18)),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.color_lens,
                                  color: Colors.white,
                                ),
                                onPressed: global.notImplementedSnackbar,
                              ),
                            ],
                          ),
                          decoration: BoxDecoration(color: Colors.black87),
                          margin: EdgeInsets.all(0.0),
                          padding: EdgeInsets.only(left: 8.0)),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: scheduleItems.length,
              padding: EdgeInsets.all(0),
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide()),
                  ),
                  child: scheduleItems[index],
                );
              },
            ),
          ),
          Row(
            children: <Widget>[
              FlatButton(
                onPressed: () => _openSettings(context, _settingsFunctions),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.settings),
                    Text("Settings"),
                  ],
                ),
              ),
              Expanded(child: Container()),
              flatButton,
            ],
          ),
        ],
      ),
    );
  }

  void _logout(BuildContext context) {
    print("logout");
    global.syncHandler.stop();
    DownloadHandler().download(global.url + "/logout", (res) {
      DownloadHandler().testConnection(global.url, context);
    });
  }

  void _openSettings(BuildContext context, Map<String, Function> _settingsFunctions) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsPage(
          title: "Settings",
          settingsFunctions: _settingsFunctions,
        ),
      ),
    );
  }
}
