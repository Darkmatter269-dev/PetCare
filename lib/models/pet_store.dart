import 'package:flutter/foundation.dart';
import 'pet.dart';

class PetStore extends ChangeNotifier {
  final List<Pet> _items = [];

  List<Pet> get all => List.unmodifiable(_items);

  void add(Pet p) {
    _items.insert(0, p);
    notifyListeners();
  }

  void update(Pet p) {
    final i = _items.indexWhere((x) => x.id == p.id);
    if (i != -1) {
      _items[i] = p;
      notifyListeners();
    }
  }

  void remove(String id) {
    _items.removeWhere((x) => x.id == id);
    notifyListeners();
  }

  // safer lookup that returns null when not found (no "null as Pet")
  Pet? byId(String id) {
    final idx = _items.indexWhere((x) => x.id == id);
    return idx == -1 ? null : _items[idx];
  }
}