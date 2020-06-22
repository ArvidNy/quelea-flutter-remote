import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import './dialogs/bible-dialog.dart';
import './dialogs/search-type-dialog.dart';
import './handlers/download-handler.dart';
import './handlers/search-delegate.dart';
import './objects/status-item.dart';
import './utils/global-utils.dart' as global;
import './widgets/live-item.dart';
import './widgets/lyrics-view.dart';
import './widgets/navigation-buttons.dart';
import './widgets/schedule-drawer.dart';
import './widgets/toggle-buttons.dart';
import './objects/schedule-list.dart';
import './widgets/schedule-item.dart';

class MainPage extends StatefulWidget {
  @override
  _MainState createState() {
    return _MainState();
  }
}

class _MainState extends State<MainPage> {
  ScheduleList _scheduleItems = ScheduleList(List<ScheduleItem>());
  bool _isLogo = false;
  bool _isBlack = false;
  bool _isClear = false;
  bool _isRecord = false;
  LiveItem _liveItem = LiveItem("");
  final ItemScrollController itemScrollController = ItemScrollController();

  void _setRecord(bool isRecord) {
    if (this._isRecord != isRecord) {
      setState(() {
        this._isRecord = isRecord;
      });
    }
  }

  void _setSchedule(ScheduleList scheduleItems) {
    if (this._scheduleItems.toString() != scheduleItems.toString()) {
      setState(() {
        this._scheduleItems = scheduleItems;
      });
    }
  }

  void _setBlack(bool isBlack) {
    if (this._isBlack != isBlack) {
      setState(() {
        this._isBlack = isBlack;
      });
    }
  }

  void _setClear(bool isClear) {
    if (this._isClear != isClear) {
      setState(() {
        this._isClear = isClear;
      });
    }
  }

  void _setLogo(bool isLogo) {
    if (this._isLogo != isLogo) {
      setState(() {
        this._isLogo = isLogo;
      });
    }
  }

  void _setDisableRecord(bool disable) {
    setState(() {
      global.disableRecord = disable;
    });
  }

  void _setLiveItem(LiveItem liveItem) async {
    if (this._liveItem.titleText != liveItem.titleText ||
        this._liveItem.activeSlide != liveItem.activeSlide ||
        !listEquals(this._liveItem.lyrics, liveItem.lyrics)) {
      // Workaround for images getting cached between two presentations and the wrong image appearing
      if (this._liveItem.isPresentation &&
          liveItem.isPresentation &&
          this._liveItem.titleText != liveItem.titleText) {
        setState(() {
          this._liveItem = LiveItem("");
          PaintingBinding.instance.imageCache.clear();
          Future.delayed(Duration(milliseconds: 1000))
              .then((value) => this._liveItem = liveItem);
        });
      } else {
        setState(() {
          this._liveItem = liveItem;
        });
      }
    }
  }

  void _setStatus(StatusItem statusHandler) {
    _setBlack(statusHandler.black);
    _setLogo(statusHandler.logo);
    _setClear(statusHandler.clear);
    _setRecord(statusHandler.record);
  }

  @override
  Widget build(BuildContext context) {
    global.context = context;
    if (!global.syncHandler.isConnected)
      DownloadHandler().testConnection(global.url, context);
    global.syncHandler.setFunctions(_setLiveItem, _setSchedule, _setStatus);
    return Scaffold(
      drawer: ScheduleDrawer(_scheduleItems.getList(), _setDisableRecord),
      drawerScrimColor: Colors.black54,
      appBar: AppBar(
        title: Text(
          'Quelea Mobile Remote',
          style: TextStyle(color: Colors.white),
        ),
        actions: _getAppBarIcons(),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            ToggleHideButtons(_isLogo, _isBlack, _isClear),
            Container(height: 16),
            Expanded(
              child: Row(
                children: <Widget>[
                  Expanded(child: LyricsView(_liveItem, itemScrollController)),
                  Container(width: 16),
                  NavigationButtons()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _getAppBarIcons() {
    return <Widget>[
      IconButton(
        icon: new Icon(Icons.search),
        onPressed: () {
          showSelectSearchTypeDialog(context, () async {
            showSearch(context: context, delegate: SongSearchDelegate());
          }, bibleSearchFunction(context));
        },
        tooltip: "Search for a song or a Bible passage",
      ),
      global.disableRecord ? Container() : IconButton(
        icon: _isRecord
            ? Icon(Icons.mic, color: Colors.red[300])
            : Icon(Icons.mic, color: Colors.white),
        onPressed: () =>
            DownloadHandler().download(global.url + "/record", () => {}),
        tooltip: "Start/stop recording",
      ),
      IconButton(
        icon: Icon(Icons.warning),
        onPressed: () => global.notImplementedSnackbar(),
        tooltip: "Add a notice",
      ),
    ];
  }
}
