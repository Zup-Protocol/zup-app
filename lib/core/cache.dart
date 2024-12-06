import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:zup_app/core/dtos/deposit_settings_dto.dart';

class Cache {
  Cache(this._cache);

  final SharedPreferencesWithCache _cache;

  final _hidingClosedPositionsKey = "HIDING_CLOSED_POSITIONS";
  final _depositSettingsKey = "DEPOSIT_SETTINGS";

  Future<void> saveHidingClosedPositionsStatus({required bool status}) async {
    await _cache.setBool(_hidingClosedPositionsKey, status);
  }

  Future<bool> getHidingClosedPositionsStatus() async {
    return _cache.getBool(_hidingClosedPositionsKey) ?? false;
  }

  Future<void> saveDepositSettings(DepositSettingsDto settings) async {
    await _cache.setString(_depositSettingsKey, jsonEncode(settings.toJson()));
  }

  DepositSettingsDto getDepositSettings() {
    final cache = _cache.getString(_depositSettingsKey) ?? "{}";

    return DepositSettingsDto.fromJson(jsonDecode(cache));
  }
}
