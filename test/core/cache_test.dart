import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zup_app/core/cache.dart';

import '../mocks.dart';

void main() {
  late Cache sut;
  late SharedPreferencesWithCache sharedPreferencesWithCache;

  const hidingClosedPositionsKey = "HIDING_CLOSED_POSITIONS";

  setUp(() {
    sharedPreferencesWithCache = SharedPreferencesWithCacheMock();
    sut = Cache(sharedPreferencesWithCache);
  });

  test("When calling `saveHidingClosedPositionsStatus` it should use the correct key and store the correct status",
      () async {
    when(() => sharedPreferencesWithCache.setBool(any(), any())).thenAnswer((_) async => true);

    const status = true;
    await sut.saveHidingClosedPositionsStatus(status: status);

    verify(() => sharedPreferencesWithCache.setBool(hidingClosedPositionsKey, status)).called(1);
  });

  test("When calling `getHidingClosedPositionsStatus` it should use the correct key and return the correct status",
      () async {
    const status = true;

    when(() => sharedPreferencesWithCache.getBool(any())).thenReturn(status);

    final result = await sut.getHidingClosedPositionsStatus();

    expect(result, status);

    verify(() => sharedPreferencesWithCache.getBool(hidingClosedPositionsKey)).called(1);
  });

  test("When calling `getHidingClosedPositionsStatus` and the shared preferences return null, it should return false",
      () async {
    when(() => sharedPreferencesWithCache.getBool(any())).thenReturn(null);

    final result = await sut.getHidingClosedPositionsStatus();

    expect(result, false);
  });
}
