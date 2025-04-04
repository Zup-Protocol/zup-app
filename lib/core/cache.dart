import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:zup_app/core/dtos/deposit_settings_dto.dart';

enum CacheKey {
  hidingClosedPositions,
  depositSettings;

  String get key => name;

  static Set<String> get keys => values.map((key) => key.key).toSet();
}

class Cache {
  Cache(this._cache);

  final SharedPreferencesWithCache _cache;

  Future<void> saveHidingClosedPositionsStatus({required bool status}) async {
    await _cache.setBool(CacheKey.hidingClosedPositions.key, status);
  }

  Future<bool> getHidingClosedPositionsStatus() async {
    return _cache.getBool(CacheKey.hidingClosedPositions.key) ?? false;
  }

  Future<void> saveDepositSettings(DepositSettingsDto settings) async {
    await _cache.setString(CacheKey.depositSettings.key, jsonEncode(settings.toJson()));
  }

  DepositSettingsDto getDepositSettings() {
    final cache = _cache.getString(CacheKey.depositSettings.key) ?? "{}";

    return DepositSettingsDto.fromJson(jsonDecode(cache));
  }
}
