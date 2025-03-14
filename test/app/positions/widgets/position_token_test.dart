import 'package:flutter/src/widgets/basic.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zup_app/core/dtos/token_dto.dart';
import 'package:zup_app/core/injections.dart';
import 'package:zup_app/widgets/position_token.dart';
import 'package:zup_app/widgets/zup_cached_image.dart';

import '../../../golden_config.dart';
import '../../../mocks.dart';

void main() {
  late ZupCachedImage zupCachedImage;

  setUp(() {
    zupCachedImage = mockZupCachedImage();
    inject.registerFactory<ZupCachedImage>(() => zupCachedImage);
  });

  tearDown(() => inject.reset());

  Future<DeviceBuilder> goldenBuilder({String tokenSymbol = "SYM", String tokenUrl = "url.com"}) => goldenDeviceBuilder(
        Center(child: PositionToken(token: TokenDto.fixture().copyWith(symbol: tokenSymbol, logoUrl: tokenUrl))),
        device: GoldenDevice.square,
      );

  zGoldenTest(
    "Position token should display the token symbol",
    goldenFileName: "position_token_symbol",
    (tester) async {
      await tester.pumpDeviceBuilder(await goldenBuilder(tokenSymbol: "SYMBOL"));
    },
  );

  zGoldenTest(
    "Position token should use the passed url to get the image with $ZupCachedImage",
    (tester) async {
      const url = "some_url";

      await tester.pumpDeviceBuilder(await goldenBuilder(tokenUrl: url));
      await tester.pumpAndSettle();

      verify(() => zupCachedImage.build(
            url,
            height: any(named: "height"),
            width: any(named: "width"),
            radius: any(named: "radius"),
            errorWidget: any(named: "errorWidget"),
          )).called(1);
    },
  );
}
