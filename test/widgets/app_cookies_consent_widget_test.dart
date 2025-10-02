import 'package:flutter/foundation.dart';
import 'package:flutter/src/widgets/basic.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zup_app/core/app_cache.dart';
import 'package:zup_app/core/injections.dart';
import 'package:zup_app/core/zup_links.dart';
import 'package:zup_app/widgets/app_cookies_consent_widget.dart';

import '../golden_config.dart';
import '../mocks.dart';

void main() {
  late AppCache cache;
  late ZupLinks zupLinks;

  setUp(() {
    cache = AppCacheMock();
    zupLinks = ZupLinksMock();

    inject.registerFactory<ZupLinks>(() => zupLinks);
    inject.registerFactory<AppCache>(() => cache);
  });

  tearDown(() => inject.reset());

  Future<DeviceBuilder> goldenBuilder({void Function()? onAccept}) async =>
      await goldenDeviceBuilder(Center(child: AppCookieConsentWidget(onAccept: onAccept ?? () {})));

  zGoldenTest(
    "App cookies consent widget",
    goldenFileName: "app_cookies_consent_widget",
    (tester) async => await tester.pumpDeviceBuilder(await goldenBuilder()),
  );

  zGoldenTest("When clicking in the privacy policy button, it should launch the privacy policy", (tester) async {
    when(() => zupLinks.launchPrivacyPolicy()).thenAnswer((_) async {});

    await tester.pumpDeviceBuilder(await goldenBuilder());

    await tester.tap(find.byKey(const Key("privacy-policy-button")));
    await tester.pumpAndSettle();

    verify(() => zupLinks.launchPrivacyPolicy()).called(1);
  });

  zGoldenTest("When clicking in the understood button, it should save the cookie consent", (tester) async {
    when(() => cache.saveCookiesConsentStatus(status: any(named: "status"))).thenAnswer((_) async {});

    await tester.pumpDeviceBuilder(await goldenBuilder());

    await tester.tap(find.byKey(const Key("accept-cookies-button")));
    await tester.pumpAndSettle();

    verify(() => cache.saveCookiesConsentStatus(status: true)).called(1);
  });

  zGoldenTest("When clicking in the understood button, it should callback", (tester) async {
    bool hasCalled = false;

    when(() => cache.saveCookiesConsentStatus(status: any(named: "status"))).thenAnswer((_) async {});

    await tester.pumpDeviceBuilder(
      await goldenBuilder(
        onAccept: () {
          hasCalled = true;
        },
      ),
    );

    await tester.tap(find.byKey(const Key("accept-cookies-button")));
    await tester.pumpAndSettle();

    expect(hasCalled, true);
  });
}
