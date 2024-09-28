import 'package:shared_preferences/shared_preferences.dart';

class Cache {
  Cache(this._cache);

  final SharedPreferencesWithCache _cache;

  final _hidingClosedPositionsKey = "HIDING_CLOSED_POSITIONS";

  Future<void> saveHidingClosedPositionsStatus({required bool status}) async {
    await _cache.setBool(_hidingClosedPositionsKey, status);
  }

  Future<bool> getHidingClosedPositionsStatus() async {
    return _cache.getBool(_hidingClosedPositionsKey) ?? false;
  }
}
