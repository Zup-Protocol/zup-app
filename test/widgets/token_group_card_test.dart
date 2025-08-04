import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:zup_app/core/dtos/token_dto.dart';
import 'package:zup_app/core/dtos/token_group_dto.dart';
import 'package:zup_app/core/injections.dart';
import 'package:zup_app/widgets/token_group_card.dart';
import 'package:zup_app/widgets/zup_cached_image.dart';
import 'package:zup_core/zup_core.dart';
import 'package:zup_ui_kit/zup_tooltip.dart';

import '../golden_config.dart';
import '../mocks.dart';

void main() {
  setUp(() {
    inject.registerFactory<ZupCachedImage>(() => mockZupCachedImage());
  });

  tearDown(() => inject.reset());

  Future<DeviceBuilder> goldenBuilder({TokenGroupDto? group, VoidCallback? onClick}) async => await goldenDeviceBuilder(
    SizedBox(
      width: 300,
      child: Center(
        child: TokenGroupCard(group: group ?? TokenGroupDto.fixture(), onClick: onClick ?? () {}),
      ),
    ),
  );

  zGoldenTest("When clicking the card, the onClick callback should be called", (tester) async {
    bool callbackCalled = false;
    await tester.pumpDeviceBuilder(await goldenBuilder(onClick: () => callbackCalled = true));

    await tester.tap(find.byType(TokenGroupCard));
    await tester.pumpAndSettle();

    expect(callbackCalled, true);
  });

  zGoldenTest("When hovering the card, it should show the hover state", goldenFileName: "token_group_card_hover", (
    tester,
  ) async {
    await tester.pumpDeviceBuilder(await goldenBuilder());

    await tester.hover(find.byType(TokenGroupCard));
    await tester.pumpAndSettle();
  });

  zGoldenTest(
    "When hovering the info icon, it should show a tooltip with all the tokens that the group has",
    goldenFileName: "token_group_card_hover_info",
    (tester) async {
      final group = TokenGroupDto.fixture().copyWith(
        tokens: List.generate(20, (index) => TokenDto.fixture().copyWith(symbol: "Token$index")),
      );
      await tester.pumpDeviceBuilder(await goldenBuilder(group: group));

      await tester.hover(find.byType(ZupTooltip));
      await tester.pumpAndSettle();
    },
  );
}
