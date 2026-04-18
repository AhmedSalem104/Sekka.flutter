import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local-only store for customer IDs the driver has marked as favorite.
/// Backend sync can be layered on top later without changing callers.
class FavoriteCustomersService extends ChangeNotifier {
  FavoriteCustomersService._();

  static final instance = FavoriteCustomersService._();

  static const _prefsKey = 'favorite_customer_ids';

  Set<String> _ids = <String>{};
  bool _loaded = false;

  Future<void> _ensureLoaded() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    _ids = (prefs.getStringList(_prefsKey) ?? const <String>[]).toSet();
    _loaded = true;
  }

  Future<Set<String>> all() async {
    await _ensureLoaded();
    return Set<String>.from(_ids);
  }

  Future<bool> isFavorite(String id) async {
    await _ensureLoaded();
    return _ids.contains(id);
  }

  Future<bool> toggle(String id) async {
    await _ensureLoaded();
    final prefs = await SharedPreferences.getInstance();
    if (_ids.contains(id)) {
      _ids.remove(id);
    } else {
      _ids.add(id);
    }
    await prefs.setStringList(_prefsKey, _ids.toList());
    notifyListeners();
    return _ids.contains(id);
  }
}
