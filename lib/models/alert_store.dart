import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'alert.dart';

class AlertStore extends ChangeNotifier {
  final Box _box;
  final List<Alert> _items = [];

  AlertStore._(this._box) {
    // load existing alerts
    for (var v in _box.values) {
      if (v is Alert) _items.add(v);
    }
    // sort newest first
    _items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  static Future<AlertStore> open() async {
    final box = Hive.box('alerts');
    return AlertStore._(box);
  }

  List<Alert> get alerts => List.unmodifiable(_items);

  Future<void> addAlert(Alert a) async {
    await _box.put(a.id, a);
    _items.insert(0, a);
    notifyListeners();
  }

  Future<void> markRead(String id) async {
    final idx = _items.indexWhere((e) => e.id == id);
    if (idx == -1) return;
    _items[idx].read = true;
    await _box.put(_items[idx].id, _items[idx]);
    notifyListeners();
  }

  Future<void> clearAll() async {
    await _box.clear();
    _items.clear();
    notifyListeners();
  }
}
