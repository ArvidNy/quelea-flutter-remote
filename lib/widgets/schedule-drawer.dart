import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../dialogs/theme-dialog.dart';
import '../handlers/download-handler.dart';
import '../handlers/language-delegate.dart';
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
      onPressed: () => _logout(),
      child: Row(
        children: <Widget>[
          Icon(Icons.exit_to_app),
          Text(AppLocalizations.of(context).getText("remote.logout.text")),
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
                                child: Text(
                                    AppLocalizations.of(Get.context)
                                        .getText("schedule.menu"),
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 18)),
                              ),
                              IconButton(
                                tooltip: AppLocalizations.of(Get.context)
                                    .getText("remote.select.theme"),
                                icon: Icon(
                                  Icons.color_lens,
                                  color: Colors.white,
                                ),
                                onPressed: () => DownloadHandler().download(
                                    "${global.url}/getthemes", (themes) {
                                  showThemesDialog(
                                      themes.toString().split("\n"));
                                }),
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
                onPressed: () => _openSettings(_settingsFunctions),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.settings),
                    Text(AppLocalizations.of(context).getText("options.title")),
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

  void _logout() {
    global.syncHandler.stop();
    DownloadHandler().sendSignal(global.url + "/logout", () {
      DownloadHandler().testConnection(global.url, false);
    });
  }

  void _openSettings(Map<String, Function> _settingsFunctions) {
    Get.back();
    Get.to(
        () => SettingsPage(
              title: AppLocalizations.of(Get.context).getText("options.title"),
              settingsFunctions: _settingsFunctions,
            ),
        transition: Transition.rightToLeft);
  }
}
