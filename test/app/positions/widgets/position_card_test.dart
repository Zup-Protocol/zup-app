import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';
import 'package:zup_app/app/positions/widgets/position_card.dart';
import 'package:zup_app/core/dtos/position_dto.dart';
import 'package:zup_app/core/dtos/protocol_dto.dart';
import 'package:zup_app/core/enums/networks.dart';
import 'package:zup_app/core/injections.dart';
import 'package:zup_app/widgets/zup_cached_image.dart';
import 'package:zup_core/zup_core.dart';

import '../../../golden_config.dart';
import '../../../mocks.dart';

void main() {
  setUp(() {
    inject.registerFactory<ZupCachedImage>(() => mockZupCachedImage());
    UrlLauncherPlatform.instance = UrlLauncherPlatformCustomMock();
  });

  tearDown(() => inject.reset());

  Future<DeviceBuilder> goldenBuilder({PositionDto? position}) async => await goldenDeviceBuilder(
        PositionCard(position: position ?? PositionDto.fixture()),
        largeDevice: false,
      );

  zGoldenTest(
    "Position card default",
    goldenFileName: "position_card_default",
    (tester) async {
      await tester.pumpDeviceBuilder(await goldenBuilder());
    },
  );

  zGoldenTest(
    "When hovering the card, it should show the hover state",
    goldenFileName: "position_card_hover",
    (tester) async {
      await tester.pumpDeviceBuilder(await goldenBuilder());

      await tester.pumpAndSettle();
      await tester.hover(find.byType(PositionCard));
    },
  );

  zGoldenTest("When the network of the position is null, it should not be displayed",
      goldenFileName: "position_card_null_network", (tester) async {
    await tester.pumpDeviceBuilder(await goldenBuilder(position: PositionDto.fixture().copyWith(network: null)));
  });

  zGoldenTest("When the network of the position is not null, it should be displayed",
      goldenFileName: "position_card_network", (tester) async {
    await tester.pumpDeviceBuilder(
      await goldenBuilder(position: PositionDto.fixture().copyWith(network: Networks.arbitrum)),
    );
  });

  zGoldenTest("When clicking the card, it should launch the protocol url", (tester) async {
    const protocolUrl = "www.google.com";

    await tester.pumpDeviceBuilder(await goldenBuilder(
        position: PositionDto.fixture().copyWith(
      protocol: ProtocolDto.fixture().copyWith(url: protocolUrl),
    )));

    await tester.ensureVisible(find.byType(PositionCard));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key("position-card")));
    await tester.pumpAndSettle();

    expect(UrlLauncherPlatformCustomMock.lastLaunchedUrl, protocolUrl);
  });
}
