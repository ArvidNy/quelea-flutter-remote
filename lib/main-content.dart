import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:preferences/preferences.dart';

import './dialogs/bible-dialog.dart';
import './dialogs/exit-dialog.dart';
import './dialogs/notice-dialog.dart';
import './dialogs/search-type-dialog.dart';
import './handlers/download-handler.dart';
import './handlers/language-delegate.dart';
import './handlers/search-delegate.dart';
import './objects/schedule-list.dart';
import './objects/status-item.dart';
import './utils/global-utils.dart' as global;
import './widgets/live-item.dart';
import './widgets/lyrics-view.dart';
import './widgets/navigation-buttons.dart';
import './widgets/schedule-drawer.dart';
import './widgets/toggle-buttons.dart';
import './widgets/schedule-item.dart';
import 'handlers/key-event-handler.dart';

class MainPage extends StatefulWidget {

  @override
  _MainState createState() {
    return _MainState();
  }
}

class _MainState extends State<MainPage> with WidgetsBindingObserver {
  ScheduleList _scheduleItems = ScheduleList(List<ScheduleItem>());
  bool _isLogo = false;
  bool _isBlack = false;
  bool _isClear = false;
  bool _isRecord = false;
  LiveItem _liveItem = LiveItem("");
  final _itemScrollController = ScrollController();

  bool _useSwipe = !(PrefService.getString("swipe_navigation_action") ?? "off")
      .contains("off");
  bool _disableRecord = PrefService.getBool("disable_record") ?? false;

  _MainState();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!global.syncHandler.isConnected) {
        DownloadHandler().showLoadingIndicator();
        DownloadHandler().testConnection(global.url,
            PrefService.getBool("use_autoconnect") ?? true);
      }
    });
  }

  @override
  void dispose() {
    global.focusNode.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (!global.syncHandler.isConnected) {
        DownloadHandler().showLoadingIndicator();
        DownloadHandler().testConnection(global.url,
            PrefService.getBool("use_autoconnect") ?? false);
      }
    } else if (state == AppLifecycleState.paused) {
      global.syncHandler.stop();
      global.syncHandler.isConnected = false;
    }
  }

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
        if (scheduleItems.getLiveItemPos() < 0) {
          _setLiveItem(LiveItem(""));
        }
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
    bool newItem = this._liveItem.titleText != liveItem.titleText;
    double offset =
        _itemScrollController.hasClients ? _itemScrollController.offset : 0;
    if (newItem) offset = 0;

    // Workaround for images getting cached between two presentations and the wrong image appearing
    if (this._liveItem.isPresentation &&
        liveItem.isPresentation &&
        this._liveItem.titleText != liveItem.titleText) {
      setState(() {
        this._liveItem = LiveItem("");
        PaintingBinding.instance.imageCache.clear();
        Future.delayed(Duration(milliseconds: 1000)).then((value) {
          this._liveItem = liveItem;
          _itemScrollController.jumpTo(offset);
        });
      });
    } else {
      setState(() {
        this._liveItem = liveItem;
        _itemScrollController.jumpTo(offset);
      });
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

  void _setState(Function function) {
    setState(() {
      function();
    });
  }

  @override
  Widget build(BuildContext context) {
    global.syncHandler.setFunctions(_setLiveItem, _setSchedule, _setStatus);
    Map<String, Function> settingsStateFunctions = <String, Function>{
      'record': _setDisableRecord,
      'swipe': _setSwipe,
      'setState': _setState,
    };
    return RawKeyboardListener(
      focusNode: global.focusNode,
      onKey: (event) =>
          handleKeyEvent(event, settingsStateFunctions, _liveItem),
      child: WillPopScope(
        child: Scaffold(
          key: global.drawerScaffoldKey,
          drawer:
              ScheduleDrawer(_scheduleItems.getList(), settingsStateFunctions),
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
        ),
        onWillPop: () {
          if (global.drawerScaffoldKey.currentState.isDrawerOpen) {
            Navigator.pop(global.drawerScaffoldKey.currentState.context, true);
            return Future<bool>.value(false);
          } else {
            return showExitDialog();
          }
        },
      ),
    );
  }

  _getAppBarIcons() {
    return <Widget>[
      IconButton(
        icon: new Icon(Icons.search),
        onPressed: () {
          showSelectSearchTypeDialog(() async {
            showSearch(context: context, delegate: SongSearchDelegate());
          }, bibleSearchFunction());
        },
        tooltip: AppLocalizations.of(context).getText("remote.search.tooltip"),
      ),
      _disableRecord
          ? Container()
          : IconButton(
              icon: _isRecord
                  ? Icon(Icons.mic, color: Colors.red[300])
                  : Icon(Icons.mic, color: Colors.white),
              onPressed: () => DownloadHandler()
                  .sendSignal(global.url + "/record", () => {}),
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
                  : showAddNoticeDialog(),
              tooltip: AppLocalizations.of(context)
                  .getText("remote.send.notice.tooltip"),
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
      if (_liveItem.activeSlide == _liveItem.itemSlides.length - 1) {
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
          DownloadHandler().sendSignal(
              global.url +
                  (PrefService.getString("swipe_navigation_action")
                          .contains("item")
                      ? "/previtem"
                      : "/prev"),
              () => {});
        } else {
          DownloadHandler().sendSignal(
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
