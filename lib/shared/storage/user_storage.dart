import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class UserStorage {
  UserStorage(this._prefs);

  final SharedPreferences _prefs;

  static const _driverKey = 'driver_data';

  Future<void> saveDriver(Map<String, dynamic> driverJson) async {
    await _prefs.setString(_driverKey, jsonEncode(driverJson));
  }

  Map<String, dynamic>? getDriver() {
    final raw = _prefs.getString(_driverKey);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> clearDriver() async {
    await _prefs.remove(_driverKey);
  }

  bool get isLoggedIn => _prefs.containsKey(_driverKey);
}
