import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zup_app/core/injections.dart';
import 'package:zup_app/core/zup_links.dart';
import 'package:zup_app/widgets/app_footer.dart';

import '../golden_config.dart';
import '../mocks.dart';

void main() {
  late ZupLinks zupLinks;

  setUp(() {
    zupLinks = ZupLinksMock();

    inject.registerLazySingleton<ZupLinks>(() => zupLinks);
  });

  tearDown(() => inject.reset());

  Future<DeviceBuilder> goldenBuilder({bool isMobile = false}) async => await goldenDeviceBuilder(
        const Column(
          children: [
            Spacer(),
            AppFooter(),
          ],
        ),
        device: isMobile ? GoldenDevice.mobile : GoldenDevice.pc,
      );

  zGoldenTest("App footer ", goldenFileName: "app_footer", (tester) async {
    await tester.pumpDeviceBuilder(await goldenBuilder());
  });

  zGoldenTest(
    "When clicking the github icon, it should launch the zup github link",
    (tester) async {
      when(() => zupLinks.launchZupGithub()).thenAnswer((_) async {});

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.tap(find.byKey(const Key("github-button")));
      await tester.pumpAndSettle();

      verify(() => zupLinks.launchZupGithub()).called(1);
    },
  );

  zGoldenTest(
    "When clicking the telegram icon, it should launch the zup telegram link",
    (tester) async {
      when(() => zupLinks.launchZupTelegram()).thenAnswer((_) async {});

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.tap(find.byKey(const Key("telegram-button")));
      await tester.pumpAndSettle();

      verify(() => zupLinks.launchZupTelegram()).called(1);
    },
  );

  zGoldenTest(
    "When clicking the twitter icon, it should launch the zup twitter link",
    (tester) async {
      when(() => zupLinks.launchZupTwitter()).thenAnswer((_) async {});

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.tap(find.byKey(const Key("twitter-button")));
      await tester.pumpAndSettle();

      verify(() => zupLinks.launchZupTwitter()).called(1);
    },
  );

  zGoldenTest(
    "When the running device is with a mobile size, the footer should be mobile adapted",
    goldenFileName: "app_footer_mobile",
    (tester) async {
      await tester.pumpDeviceBuilder(await goldenBuilder(isMobile: true));
    },
  );
}
