import 'package:flutter/src/widgets/basic.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:zup_app/core/dtos/token_dto.dart';
import 'package:zup_app/core/injections.dart';
import 'package:zup_app/widgets/token_card.dart';
import 'package:zup_app/widgets/zup_cached_image.dart';
import 'package:zup_core/zup_core.dart';

import '../golden_config.dart';
import '../mocks.dart';

void main() {
  setUp(() {
    inject.registerFactory<ZupCachedImage>(() => mockZupCachedImage());
  });

  tearDown(() => inject.reset());

  Future<DeviceBuilder> goldenBuilder({
    TokenDto? asset,
    Function()? onClick,
  }) async =>
      await goldenDeviceBuilder(
        Center(
          child: SizedBox(
            width: 400,
            child: TokenCard(
              asset: asset ?? TokenDto.fixture(),
              onClick: onClick ?? () {},
            ),
          ),
        ),
      );

  zGoldenTest("Token card default", goldenFileName: "token_card_default", (tester) async {
    await tester.pumpDeviceBuilder(await goldenBuilder());
  });

  zGoldenTest("When hovering the card, it should show the hover state", goldenFileName: "token_card_hover",
      (tester) async {
    await tester.pumpDeviceBuilder(await goldenBuilder());

    await tester.pumpAndSettle();
    await tester.hover(find.byType(TokenCard));

    await tester.pumpAndSettle();
  });

  zGoldenTest("When tapping the card, it should call the onClick callback", (tester) async {
    bool called = false;

    await tester.pumpDeviceBuilder(await goldenBuilder(onClick: () => called = true));

    await tester.tap(find.byType(TokenCard));

    expect(called, true);
  });
}
