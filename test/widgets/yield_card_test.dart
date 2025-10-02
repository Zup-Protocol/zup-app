import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:zup_app/core/dtos/protocol_dto.dart';
import 'package:zup_app/core/dtos/token_dto.dart';
import 'package:zup_app/core/dtos/yield_dto.dart';
import 'package:zup_app/core/enums/yield_timeframe.dart';
import 'package:zup_app/core/injections.dart';
import 'package:zup_app/widgets/yield_card.dart';
import 'package:zup_app/widgets/zup_cached_image.dart';
import 'package:zup_core/extensions/widget_tester_extension.dart';

import '../golden_config.dart';
import '../mocks.dart';

void main() {
  autoUpdateGoldenFiles = true;
  setUp(() {
    inject.registerFactory<ZupCachedImage>(() => mockZupCachedImage());
    inject.registerFactory<bool>(() => false, instanceName: InjectInstanceNames.infinityAnimationAutoPlay);
  });

  tearDown(() => inject.reset());

  Future<DeviceBuilder> goldenBuilder({
    bool isHotestYield = true,
    YieldDto? yieldPool,
    YieldTimeFrame? yieldTimeFrame,
    bool snapshotDarkMode = false,
  }) async => await goldenDeviceBuilder(
    darkMode: snapshotDarkMode,
    Center(
      child: SizedBox(
        height: 310,
        width: 340,
        child: YieldCard(
          isHotestYield: false,
          yieldPool: yieldPool ?? YieldDto.fixture(),
          yieldTimeFrame: yieldTimeFrame ?? YieldTimeFrame.day,
        ),
      ),
    ),
  );

  zGoldenTest(
    """When passing the yield timeframe as day,
    it should show the day yield from the passed yield pool""",
    goldenFileName: "yield_card_day_timeframe",
    (tester) async {
      final pool = YieldDto.fixture().copyWith(yield24h: 12518721);
      await tester.pumpDeviceBuilder(await goldenBuilder(yieldTimeFrame: YieldTimeFrame.day, yieldPool: pool));
    },
  );

  zGoldenTest(
    """When passing the yield timeframe as week,
    it should show the week yield from the passed yield pool""",
    goldenFileName: "yield_card_week_timeframe",
    (tester) async {
      final pool = YieldDto.fixture().copyWith(yield7d: 111122111);
      await tester.pumpDeviceBuilder(await goldenBuilder(yieldTimeFrame: YieldTimeFrame.week, yieldPool: pool));
    },
  );

  zGoldenTest(
    """When passing the yield timeframe as month,
    it should show the month yield from the passed yield pool""",
    goldenFileName: "yield_card_month_timeframe",
    (tester) async {
      final pool = YieldDto.fixture().copyWith(yield30d: 991);
      await tester.pumpDeviceBuilder(await goldenBuilder(yieldTimeFrame: YieldTimeFrame.month, yieldPool: pool));
    },
  );

  zGoldenTest(
    """When passing the yield timeframe as three months,
    it should show the three months yield from the passed yield pool""",
    goldenFileName: "yield_card_three_months_timeframe",
    (tester) async {
      final pool = YieldDto.fixture().copyWith(yield90d: 654);
      await tester.pumpDeviceBuilder(await goldenBuilder(yieldTimeFrame: YieldTimeFrame.threeMonth, yieldPool: pool));
    },
  );

  zGoldenTest(
    "When the theme is in dark mode, the card should be in dark mode",
    goldenFileName: "yield_card_dark_mode",
    (tester) async {
      await tester.pumpDeviceBuilder(await goldenBuilder(snapshotDarkMode: true));
    },
  );

  zGoldenTest(
    """When the user hovers the blockchain icon, it should display a tooltip
    explaining that the pool is at n blockchain""",
    goldenFileName: "yield_card_blockchain_tooltip_hover",
    (tester) async {
      final yieldPool = YieldDto.fixture();
      await tester.pumpDeviceBuilder(await goldenBuilder(yieldPool: yieldPool));

      await tester.hover(find.byKey(Key("yield-card-network-${yieldPool.network.label}")));
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    """When hovering the info icon after the yield percent, it should display a tooltip
    explaining the yield percent, and showing other timesframes yields""",
    goldenFileName: "yield_card_yield_tooltip_hover",
    (tester) async {
      final yieldPool = YieldDto.fixture().copyWith(yield24h: 1212, yield7d: 2919, yield30d: 9824, yield90d: 1111);
      await tester.pumpDeviceBuilder(await goldenBuilder(yieldPool: yieldPool));

      await tester.hover(find.byKey(Key("yield-breakdown-tooltip-${yieldPool.poolAddress}")));
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    """When the device is mobile, and the user clicks the yield, it should display a tooltip
    explaining the yield percent, and showing other timesframes yields""",
    goldenFileName: "yield_card_yield_tap_mobile",
    (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      final yieldPool = YieldDto.fixture().copyWith(yield24h: 1212, yield7d: 2919, yield30d: 9824, yield90d: 1111);
      await tester.pumpDeviceBuilder(await goldenBuilder(yieldPool: yieldPool));

      await tester.hover(find.byKey(Key("yield-card-yield-${yieldPool.poolAddress}")));
      await tester.pumpAndSettle();

      debugDefaultTargetPlatformOverride = null;
    },
  );

  zGoldenTest(
    "When the tvl decimals is greater than 2, the tvl should be compact",
    goldenFileName: "yield_card_compacte_tvl",
    (tester) async {
      final pool = YieldDto.fixture().copyWith(totalValueLockedUSD: 112152871.219201);
      await tester.pumpDeviceBuilder(await goldenBuilder(yieldPool: pool));
    },
  );

  zGoldenTest(
    "When the protocol name is too big, it add a overflow ellipsis",
    goldenFileName: "yield_card_overflow_protocol_name",
    (tester) async {
      final pool = YieldDto.fixture().copyWith(
        protocol: ProtocolDto.fixture().copyWith(name: "Lorem ipsum dolor sit amet consectetur adipiscing elit"),
      );
      await tester.pumpDeviceBuilder(await goldenBuilder(yieldPool: pool));
    },
  );

  zGoldenTest(
    "When the token symbol pass 8 chars, it should be overflowed with an ellipsis",
    goldenFileName: "yield_card_overflow_token_symbol",
    (tester) async {
      final pool = YieldDto.fixture().copyWith(
        token0: TokenDto.fixture().copyWith(symbol: "Lorem ipsum dolor sit amet consectetur adipiscing elit"),
        token1: TokenDto.fixture().copyWith(symbol: "elit adipiscing consectetur amet sit dolor ipsum Lorem"),
      );
      await tester.pumpDeviceBuilder(await goldenBuilder(yieldPool: pool));
    },
  );
}
