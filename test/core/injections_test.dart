// ignore_for_file: depend_on_referenced_packages

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import "package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart";
import "package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart";
import 'package:zup_app/core/cache.dart';
import 'package:zup_app/core/injections.dart';

void main() {
  setUp(() async {
    SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty();

    await setupInjections();
  });

  tearDown(() => inject.reset());

  test("When registering shared preferences, the allow list should include all the Cache keys", () {
    final cache = inject<SharedPreferencesWithCache>();

    for (final key in CacheKey.keys) {
      expect(cache.getString(key), null); // if the key is not in the allow list, it will throw and test will fail
    }

    expect(
      () => cache.getString("random-key"),
      throwsArgumentError,
    ); // if there is no allolist defined, it will not throw. So this should throw, and the other expects should not
  });
}
