import 'package:flutter/foundation.dart';
import 'schedule.dart';

class ScheduleStore extends ChangeNotifier {
  final List<Schedule> _items = [];
  DateTime selectedDate = DateTime.now();

  List<Schedule> get all => List.unmodifiable(_items);

  List<Schedule> forDate(DateTime date) {
    return _items.where((s) => s.isSameDay(date)).toList()
      ..sort((a, b) => a.start.compareTo(b.start));
  }

  void setSelectedDate(DateTime d) {
    selectedDate = DateTime(d.year, d.month, d.day);
    notifyListeners();
  }

  void add(Schedule s) {
    _items.add(s);
    notifyListeners();
  }

  void update(Schedule s) {
    final i = _items.indexWhere((x) => x.id == s.id);
    if (i != -1) {
      _items[i] = s;
      notifyListeners();
    }
  }

  void remove(String id) {
    _items.removeWhere((x) => x.id == id);
    notifyListeners();
  }

  void toggle(String id) {
    final i = _items.indexWhere((x) => x.id == id);
    if (i != -1) {
      _items[i].enabled = !_items[i].enabled;
      notifyListeners();
    }
  }
}