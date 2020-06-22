import 'dart:core';

import '../widgets/schedule-item.dart';

/// A class for handeling the schedule list.
class ScheduleList {
  List<ScheduleItem> _items;

  ScheduleList(this._items);

  List<ScheduleItem> getList() {
    return _items;
  }

  @override
  String toString() {
    String s = "";
    for (ScheduleItem si in _items) {
      s += si.toStringShort();
    }
    return s;
  }

}