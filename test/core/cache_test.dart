import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zup_app/core/cache.dart';
import 'package:zup_app/core/dtos/deposit_settings_dto.dart';
import 'package:zup_app/core/dtos/pool_search_settings_dto.dart';

import '../mocks.dart';

void main() {
  late Cache sut;
  late SharedPreferencesWithCache sharedPreferencesWithCache;

  setUp(() {
    registerFallbackValue(DepositSettingsDto.fixture());

    sharedPreferencesWithCache = SharedPreferencesWithCacheMock();
    sut = Cache(sharedPreferencesWithCache);
  });

  test("When calling `saveHidingClosedPositionsStatus` it should use the correct key and store the correct status",
      () async {
    when(() => sharedPreferencesWithCache.setBool(any(), any())).thenAnswer((_) async => true);

    const status = true;
    await sut.saveHidingClosedPositionsStatus(status: status);

    verify(() => sharedPreferencesWithCache.setBool(CacheKey.hidingClosedPositions.key, status)).called(1);
  });

  test("When calling `getHidingClosedPositionsStatus` it should use the correct key and return the correct status",
      () async {
    const status = true;

    when(() => sharedPreferencesWithCache.getBool(any())).thenReturn(status);

    final result = await sut.getHidingClosedPositionsStatus();

    expect(result, status);

    verify(() => sharedPreferencesWithCache.getBool(CacheKey.hidingClosedPositions.key)).called(1);
  });

  test("When calling `getHidingClosedPositionsStatus` and the shared preferences return null, it should return false",
      () async {
    when(() => sharedPreferencesWithCache.getBool(any())).thenReturn(null);

    final result = await sut.getHidingClosedPositionsStatus();

    expect(result, false);
  });

  test(
    "When calling `saveDepositSettings` it should use the correct key to store the deposit settings",
    () async {
      final settings = DepositSettingsDto();

      when(() => sharedPreferencesWithCache.setString(any(), any())).thenAnswer((_) async => true);
      await sut.saveDepositSettings(settings);

      verify(() => sharedPreferencesWithCache.setString(CacheKey.depositSettings.key, any())).called(1);
    },
  );

  test(
    "When calling `saveDepositSettings` it should convert the dto to json, and store the json as a string",
    () async {
      final settings = DepositSettingsDto();
      when(() => sharedPreferencesWithCache.setString(any(), any())).thenAnswer((_) async => true);

      await sut.saveDepositSettings(settings);

      verify(
        () => sharedPreferencesWithCache.setString(
          any(),
          jsonEncode(settings.toJson()).toString(),
        ),
      ).called(1);
    },
  );

  test("When calling `getDepositSettings` it should use the correct key to get the deposit settings", () async {
    when(() => sharedPreferencesWithCache.getString(any())).thenReturn("{}");

    sut.getDepositSettings();

    verify(() => sharedPreferencesWithCache.getString(CacheKey.depositSettings.key)).called(1);
  });

  test("When calling `getDepositSettings` it should convert the returned saved json to a deposit settings dto", () {
    final settings = DepositSettingsDto(deadlineMinutes: 321, maxSlippage: 7384);

    when(() => sharedPreferencesWithCache.getString(any())).thenReturn(jsonEncode(settings.toJson()));

    final result = sut.getDepositSettings();

    expect(result, settings);
  });

  test("When calling '.keys' in the cache key enum, it should return all the cache keys as Set", () {
    expect(CacheKey.keys, CacheKey.values.map((e) => e.key).toSet());
  });

  test("when calling `saveTestnetMode` it should save under the correct key", () async {
    when(() => sharedPreferencesWithCache.setBool(any(), any())).thenAnswer((_) async => true);

    const isTestnetMode = true;
    await sut.saveTestnetMode(isTestnetMode: isTestnetMode);

    verify(() => sharedPreferencesWithCache.setBool(CacheKey.isTestnetMode.key, isTestnetMode)).called(1);
  });

  test("when calling `getTestnetMode` it should get under the correct key", () async {
    when(() => sharedPreferencesWithCache.getBool(any())).thenReturn(true);

    final result = sut.getTestnetMode();

    expect(result, true);

    verify(() => sharedPreferencesWithCache.getBool(CacheKey.isTestnetMode.key)).called(1);
  });

  test("when calling 'savePoolSearchSettings' it should save under the correct key", () {
    when(() => sharedPreferencesWithCache.setString(any(), any())).thenAnswer((_) async => true);

    final settings = PoolSearchSettingsDto(
      minLiquidityUSD: 12786,
    );
    sut.savePoolSearchSettings(settings: settings);

    verify(() => sharedPreferencesWithCache.setString(
          CacheKey.poolSearchSettings.key,
          jsonEncode(settings.toJson()),
        )).called(1);
  });

  test("when calling 'getPoolSearchSettings' it should get under the correct key", () {
    final result = sut.getPoolSearchSettings();

    when(() => sharedPreferencesWithCache.getString(any())).thenReturn(jsonEncode(result.toJson()));

    expect(result, result);
    verify(() => sharedPreferencesWithCache.getString(CacheKey.poolSearchSettings.key)).called(1);
  });

  test("when calling 'saveCookiesConsentStatus' it should save under the correct key", () {
    when(() => sharedPreferencesWithCache.setBool(any(), any())).thenAnswer((_) async => true);

    const status = true;
    sut.saveCookiesConsentStatus(status: status);

    verify(() => sharedPreferencesWithCache.setBool(CacheKey.areCookiesConsented.key, status)).called(1);
  });

  test("when calling 'getCookiesConsentStatus' it should get under the correct key", () {
    when(() => sharedPreferencesWithCache.getBool(any())).thenReturn(true);

    final result = sut.getCookiesConsentStatus();

    expect(result, true);
    verify(() => sharedPreferencesWithCache.getBool(CacheKey.areCookiesConsented.key)).called(1);
  });
}
