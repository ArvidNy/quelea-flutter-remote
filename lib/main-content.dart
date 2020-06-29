import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:preferences/preferences.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import './dialogs/bible-dialog.dart';
import './dialogs/notice-dialog.dart';
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
import './handlers/language-delegate.dart';

class MainPage extends StatefulWidget {
  StreamController<bool> _isLightTheme;
  MainPage(this._isLightTheme);

  @override
  _MainState createState() {
    return _MainState(_isLightTheme);
  }
}

class _MainState extends State<MainPage> {
  ScheduleList _scheduleItems = ScheduleList(List<ScheduleItem>());
  bool _isLogo = false;
  bool _isBlack = false;
  bool _isClear = false;
  bool _isRecord = false;
  LiveItem _liveItem = LiveItem("");
  final ItemScrollController _itemScrollController = ItemScrollController();
  StreamController<bool> _isLightTheme;

  bool _useSwipe = !(PrefService.getString("swipe_navigation_action") ?? "off")
      .contains("off");
  bool _disableRecord = PrefService.getBool("disable_record") ?? false;

  _MainState(this._isLightTheme);

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
      _disableRecord = disable;
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
          Future.delayed(Duration(milliseconds: 1000)).then((value) {
            this._liveItem = liveItem;
            _itemScrollController.scrollTo(
                index: liveItem.activeSlide,
                duration: Duration(milliseconds: 100));
          });
        });
      } else {
        setState(() {
          this._liveItem = liveItem;
          _itemScrollController.scrollTo(
              index: liveItem.activeSlide,
              duration: Duration(milliseconds: 100));
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

  void _setSwipe(bool swipe) {
    setState(() {
      this._useSwipe = swipe;
    });
  }

  @override
  Widget build(BuildContext context) {
    global.context = context;
    if (!global.syncHandler.isConnected) {
      if (PrefService.getBool("use_autoconnect") ?? false) {
        DownloadHandler().autoConnect(context);
      } else {
        DownloadHandler().testConnection(global.url, context);
      }
    }
    global.syncHandler.setFunctions(_setLiveItem, _setSchedule, _setStatus);
    Map<String, Function> settingsStateFunctions = <String, Function>{
      'record': _setDisableRecord,
      'swipe': _setSwipe,
      'theme': (b) => _isLightTheme.add(b),
    };
    return Scaffold(
      drawer: ScheduleDrawer(_scheduleItems.getList(), settingsStateFunctions),
      drawerScrimColor: Colors.black54,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).getText("remote.control.app.name"),
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
                  Expanded(
                    child: _useSwipe
                        ? _getSwipeHandler()
                        : LyricsView(_liveItem, _itemScrollController),
                  ),
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
        tooltip: AppLocalizations.of(context).getText("remote.search.tooltip"),
      ),
      _disableRecord
          ? Container()
          : IconButton(
              icon: _isRecord
                  ? Icon(Icons.mic, color: Colors.red[300])
                  : Icon(Icons.mic, color: Colors.white),
              onPressed: () =>
                  DownloadHandler().download(global.url + "/record", () => {}),
              tooltip: _isRecord
                  ? AppLocalizations.of(context).getText("pause.record.tooltip")
                  : AppLocalizations.of(context)
                      .getText("record.audio.tooltip"),
            ),
      global.serverVersion >= 2020.1
          ? IconButton(
              icon: Icon(Icons.warning),
              onPressed: () => global.serverVersion < 2020.1
                  ? global.needsNewerServerSnackbar(2020.1)
                  : showAddNoticeDialog(context),
              tooltip:
                  AppLocalizations.of(context).getText("remote.send.notice.tooltip"),
            )
          : Container(),
    ];
  }

  _getSwipeHandler() {
    DismissDirection swipeDirection;
    if (PrefService.getString("swipe_navigation_action").contains("item")) {
      if (_scheduleItems.getLiveItemPos() ==
          _scheduleItems.getList().length - 1) {
        swipeDirection = DismissDirection.startToEnd;
      } else if (_scheduleItems.getLiveItemPos() == 0) {
        swipeDirection = DismissDirection.endToStart;
      } else {
        swipeDirection = DismissDirection.horizontal;
      }
    } else {
      if (_liveItem.activeSlide == _liveItem.lyrics.length - 1) {
        swipeDirection = DismissDirection.startToEnd;
      } else if (_liveItem.activeSlide == 0) {
        swipeDirection = DismissDirection.endToStart;
      } else {
        swipeDirection = DismissDirection.horizontal;
      }
    }
    return Dismissible(
      key: new ValueKey(_liveItem),
      background: Center(
        child: CircularProgressIndicator(),
      ),
      resizeDuration: null,
      direction: swipeDirection,
      onDismissed: (direction) {
        if (DismissDirection.startToEnd == direction) {
          DownloadHandler().download(
              global.url +
                  (PrefService.getString("swipe_navigation_action")
                          .contains("item")
                      ? "/previtem"
                      : "/prev"),
              () => {});
        } else {
          DownloadHandler().download(
              global.url +
                  (PrefService.getString("swipe_navigation_action")
                          .contains("item")
                      ? "/nextitem"
                      : "/next"),
              () => {});
        }
      },
      child: LyricsView(_liveItem, _itemScrollController),
    );
  }
}
