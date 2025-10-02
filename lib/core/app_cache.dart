import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:zup_app/core/dtos/deposit_settings_dto.dart';
import 'package:zup_app/core/dtos/pool_search_settings_dto.dart';
import 'package:zup_app/core/dtos/theme_mode_dto.dart';
import 'package:zup_app/core/enums/app_theme_mode.dart';

enum AppCacheKey {
  hidingClosedPositions,
  depositSettingsV2,
  poolSearchSettings,
  areCookiesConsented,
  blockedProtocolsIds,
  themeMode,
  isTestnetMode;

  String get key => name;

  static Set<String> get keys => values.map((key) => key.key).toSet();
}

class AppCache {
  AppCache(this._cache);

  final SharedPreferencesWithCache _cache;

  Future<void> saveThemeMode(AppThemeMode themeMode) async {
    await _cache.setString(AppCacheKey.themeMode.key, jsonEncode(ThemeModeDto(themeMode: themeMode).toJson()));
  }

  AppThemeMode get themeMode {
    final storedThemeMode = _cache.getString(AppCacheKey.themeMode.key) ?? "{}";

    return ThemeModeDto.fromJson(jsonDecode(storedThemeMode)).themeMode;
  }

  Future<void> saveHidingClosedPositionsStatus({required bool status}) async {
    await _cache.setBool(AppCacheKey.hidingClosedPositions.key, status);
  }

  Future<bool> getHidingClosedPositionsStatus() async {
    return _cache.getBool(AppCacheKey.hidingClosedPositions.key) ?? false;
  }

  Future<void> saveDepositSettings(DepositSettingsDto settings) async {
    await _cache.setString(AppCacheKey.depositSettingsV2.key, jsonEncode(settings.toJson()));
  }

  DepositSettingsDto getDepositSettings() {
    final cache = _cache.getString(AppCacheKey.depositSettingsV2.key) ?? "{}";

    return DepositSettingsDto.fromJson(jsonDecode(cache));
  }

  Future<void> saveTestnetMode({required bool isTestnetMode}) async {
    await _cache.setBool(AppCacheKey.isTestnetMode.key, isTestnetMode);
  }

  bool getTestnetMode() {
    return _cache.getBool(AppCacheKey.isTestnetMode.key) ?? false;
  }

  Future<void> saveBlockedProtocolIds({required List<String> blockedProtocolIds}) async {
    await _cache.setStringList(AppCacheKey.blockedProtocolsIds.key, blockedProtocolIds);
  }

  List<String> get blockedProtocolsIds {
    return _cache.getStringList(AppCacheKey.blockedProtocolsIds.key) ?? [];
  }

  Future<void> savePoolSearchSettings({required PoolSearchSettingsDto settings}) async {
    await _cache.setString(AppCacheKey.poolSearchSettings.key, jsonEncode(settings.toJson()));
  }

  Future<void> saveCookiesConsentStatus({required bool status}) async {
    await _cache.setBool(AppCacheKey.areCookiesConsented.key, status);
  }

  bool? getCookiesConsentStatus() {
    return _cache.getBool(AppCacheKey.areCookiesConsented.key);
  }

  PoolSearchSettingsDto getPoolSearchSettings() {
    final cache = _cache.getString(AppCacheKey.poolSearchSettings.key) ?? "{}";

    return PoolSearchSettingsDto.fromJson(jsonDecode(cache));
  }
}
