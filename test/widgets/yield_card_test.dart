import 'package:flutter/src/widgets/basic.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zup_app/app/app_cubit/app_cubit.dart';
import 'package:zup_app/core/dtos/yield_dto.dart';
import 'package:zup_app/core/enums/networks.dart';
import 'package:zup_app/core/injections.dart';
import 'package:zup_app/widgets/yield_card.dart';
import 'package:zup_app/widgets/zup_cached_image.dart';

import '../golden_config.dart';
import '../mocks.dart';

void main() {
  ZupCachedImage zupCachedImage = mockZupCachedImage();
  late AppCubit appCubit;

  setUp(() {
    appCubit = AppCubitMock();

    inject.registerFactory<AppCubit>(() => appCubit);
    inject.registerFactory<ZupCachedImage>(() => zupCachedImage);

    when(() => appCubit.selectedNetwork).thenAnswer((_) => AppNetworks.sepolia);
    when(() => appCubit.selectedNetworkStream).thenAnswer((_) => const Stream.empty());
  });

  tearDown(() => inject.reset());

  Future<DeviceBuilder> goldenBuilder({
    YieldDto? currentYield,
    Function(YieldDto? yield)? onChangeSelection,
    bool isSelected = false,
    YieldTimeFrame? timeFrame,
  }) async =>
      await goldenDeviceBuilder(Center(
        child: SizedBox(
          width: 300,
          child: Center(
            child: YieldCard(
              isSelected: isSelected,
              onChangeSelection: (selectedYield) => onChangeSelection?.call(selectedYield),
              timeFrame: timeFrame ?? YieldTimeFrame.day,
              currentYield: currentYield ?? YieldDto.fixture(),
            ),
          ),
        ),
      ));

  zGoldenTest("When the app network is all networks, the yield card should display an icon of the network of the yield",
      goldenFileName: "yield_card_network_icon", (tester) async {
    when(() => appCubit.selectedNetwork).thenAnswer((_) => AppNetworks.allNetworks);

    await tester.pumpDeviceBuilder(await goldenBuilder());

    await tester.pumpAndSettle();
  });

  zGoldenTest("When passing `isSelected` as true, the yield card should be selected",
      goldenFileName: "yield_card_selected", (tester) async {
    await tester.pumpDeviceBuilder(await goldenBuilder(isSelected: true));

    await tester.pumpAndSettle();
  });

  zGoldenTest(
    "When passing the 30d timeframe, the yield card should display the 30d yield",
    goldenFileName: "yield_card_30d",
    (tester) async {
      final currentYield = YieldDto.fixture().copyWith(yield30d: 87654.98765);
      await tester.pumpDeviceBuilder(await goldenBuilder(timeFrame: YieldTimeFrame.month, currentYield: currentYield));

      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    "When passing the 24h timeframe, the yield card should display the 30d yield",
    goldenFileName: "yield_card_24h",
    (tester) async {
      final currentYield = YieldDto.fixture().copyWith(yield24h: 1447.23);
      await tester.pumpDeviceBuilder(await goldenBuilder(timeFrame: YieldTimeFrame.day, currentYield: currentYield));

      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    "When passing the 90d timeframe, the yield card should display the 90d yield",
    goldenFileName: "yield_card_90d",
    (tester) async {
      final currentYield = YieldDto.fixture().copyWith(yield90d: 1535421.32);
      await tester
          .pumpDeviceBuilder(await goldenBuilder(timeFrame: YieldTimeFrame.threeMonth, currentYield: currentYield));

      await tester.pumpAndSettle();
    },
  );
}
