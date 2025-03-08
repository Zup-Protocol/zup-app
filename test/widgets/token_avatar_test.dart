import 'package:flutter/src/widgets/basic.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:zup_app/core/dtos/token_dto.dart';
import 'package:zup_app/core/injections.dart';
import 'package:zup_app/widgets/token_avatar.dart';
import 'package:zup_app/widgets/zup_cached_image.dart';

import '../golden_config.dart';
import '../mocks.dart';

void main() {
  setUp(() {
    inject.registerFactory<ZupCachedImage>(() => mockZupCachedImage());
  });

  tearDown(() => inject.reset());

  Future<DeviceBuilder> goldenBuilder({TokenDto? token, double size = 30}) => goldenDeviceBuilder(
        Center(
          child: TokenAvatar(
              asset: token ?? const TokenDto(logoUrl: 'https://www.google.com.br', name: 'Zup'), size: size),
        ),
        device: GoldenDevice.square,
      );

  zGoldenTest(
    "When the logoUrl from the dto is empty, it should create an avatar with the initial letter of the token name",
    goldenFileName: "token_avatar_empty_logo_url",
    (tester) async {
      await tester
          .pumpDeviceBuilder(await goldenBuilder(token: TokenDto.fixture().copyWith(logoUrl: '', name: "ZUP TOKEN")));
    },
  );

  zGoldenTest(
    "When the logoUrl from the dto is not empty, it should use the url to get the image with $ZupCachedImage",
    goldenFileName: "token_avatar_not_empty_logo_url",
    (tester) async {
      const url = "some_url";

      await tester.pumpDeviceBuilder(await goldenBuilder(token: TokenDto.fixture().copyWith(logoUrl: url)));
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest("When passing a size to the widget, it should be applied", goldenFileName: "token_avatar_size",
      (tester) async {
    await tester.pumpDeviceBuilder(await goldenBuilder(token: TokenDto.fixture().copyWith(logoUrl: ''), size: 200));
  });
}
