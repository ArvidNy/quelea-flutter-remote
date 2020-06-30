import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:indexed_list_view/indexed_list_view.dart';
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
import './pages/settings-page.dart';

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
  final _itemScrollController = IndexedScrollController();
  StreamController<bool> _isLightTheme;
  final FocusNode _focusNode = FocusNode();

  bool _useSwipe = !(PrefService.getString("swipe_navigation_action") ?? "off")
      .contains("off");
  bool _disableRecord = PrefService.getBool("disable_record") ?? false;

  _MainState(this._isLightTheme);

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKeyEvent(RawKeyEvent event) {
    if (event.runtimeType.toString() == 'RawKeyDownEvent') {
      print(event.data.logicalKey);
      if (event.data.logicalKey == LogicalKeyboardKey.arrowDown) {
        if (event.data.isControlPressed) {
          DownloadHandler().download("${global.url}/nextitem", () {});
        } else {
          DownloadHandler().download("${global.url}/next", () {});
        }
      } else if (event.data.logicalKey == LogicalKeyboardKey.arrowUp) {
        if (event.data.isControlPressed) {
          DownloadHandler().download("${global.url}/previtem", () {});
        } else {
          DownloadHandler().download("${global.url}/prev", () {});
        }
      } else if (event.data.logicalKey == LogicalKeyboardKey.pageDown) {
        DownloadHandler().download("${global.url}/next", () {});
      } else if (event.data.logicalKey == LogicalKeyboardKey.pageUp) {
        DownloadHandler().download("${global.url}/prev", () {});
      } else if (event.data.logicalKey == LogicalKeyboardKey.f5) {
        DownloadHandler().download("${global.url}/tlogo", () {});
      } else if (event.data.logicalKey == LogicalKeyboardKey.f6) {
        DownloadHandler().download("${global.url}/black", () {});
      } else if (event.data.logicalKey == LogicalKeyboardKey.f7) {
        DownloadHandler().download("${global.url}/clear", () {});
      } else if (event.data.logicalKey.keyId <=
              LogicalKeyboardKey.digit9.keyId &&
          event.data.logicalKey.keyId >= LogicalKeyboardKey.digit1.keyId) {
        DownloadHandler().download(
            "${global.url}/section${int.parse(event.data.keyLabel) - 1}",
            () {});
      } else if (event.data.logicalKey == LogicalKeyboardKey.keyT &&
          (event.data.isMetaPressed || event.data.isControlPressed)) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SettingsPage(
              title: AppLocalizations.of(context).getText("options.title"),
              settingsFunctions: <String, Function>{
                'record': _setDisableRecord,
                'swipe': _setSwipe,
                'theme': (b) => _isLightTheme.add(b),
              },
            ),
          ),
        );
      }
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
    print(liveItem.toString());
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
            _itemScrollController.jumpToIndex(liveItem.activeSlide);
          });
        });
      } else {
        setState(() {
          print("set item");
          this._liveItem = liveItem;
          _itemScrollController.jumpToIndex(liveItem.activeSlide);
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
    return RawKeyboardListener(
      focusNode: _focusNode,
      onKey: _handleKeyEvent,
      child: WillPopScope(
        child: Scaffold(
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
          if (!global.drawerContext.toString().contains("dirty") &&
              Scaffold.of(global.drawerContext).isDrawerOpen) {
            Navigator.pop(global.drawerContext, true);
            return Future<bool>.value(false);
          } else {
            return showExitDialog(context);
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
                  : showAddNoticeDialog(context),
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
