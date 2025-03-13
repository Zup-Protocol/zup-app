import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:lottie/lottie.dart';
import 'package:mocktail/mocktail.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';
import 'package:web3kit/web3kit.dart';
import 'package:zup_app/abis/erc_20.abi.g.dart';
import 'package:zup_app/abis/uniswap_position_manager.abi.g.dart';
import 'package:zup_app/abis/uniswap_v3_pool.abi.g.dart';
import 'package:zup_app/app/app_cubit/app_cubit.dart';
import 'package:zup_app/app/create/deposit/deposit_cubit.dart';
import 'package:zup_app/app/create/deposit/deposit_page.dart';
import 'package:zup_app/app/create/deposit/widgets/preview_deposit_modal/preview_deposit_modal.dart';
import 'package:zup_app/app/positions/positions_cubit.dart';
import 'package:zup_app/core/dtos/deposit_settings_dto.dart';
import 'package:zup_app/core/dtos/yield_dto.dart';
import 'package:zup_app/core/dtos/yields_by_timeframe_dto.dart';
import 'package:zup_app/core/dtos/yields_dto.dart';
import 'package:zup_app/core/enums/networks.dart';
import 'package:zup_app/core/enums/zup_navigator_paths.dart';
import 'package:zup_app/core/injections.dart';
import 'package:zup_app/core/slippage.dart';
import 'package:zup_app/core/zup_navigator.dart';
import 'package:zup_app/gen/assets.gen.dart';
import 'package:zup_app/widgets/zup_cached_image.dart';
import 'package:zup_core/zup_core.dart';

import '../../../golden_config.dart';
import '../../../mocks.dart';

void main() {
  late DepositCubit cubit;
  late Wallet wallet;
  late ZupNavigator navigator;
  late AppCubit appCubit;
  late PositionsCubit positionsCubit;
  late UniswapV3Pool uniswapV3pool;
  late Erc20 erc20;

  setUp(() async {
    await Web3Kit.initializeForTest();
    await inject.unregister<Wallet>();
    UrlLauncherPlatform.instance = UrlLauncherPlatformCustomMock();

    cubit = DepositCubitMock();
    wallet = WalletMock();
    navigator = ZupNavigatorMock();
    appCubit = AppCubitMock();
    positionsCubit = PositionsCubitMock();
    uniswapV3pool = UniswapV3PoolMock();
    erc20 = Erc20Mock();

    registerFallbackValue(BuildContextMock());
    registerFallbackValue(Networks.sepolia);
    registerFallbackValue(Slippage.fromValue(32));
    registerFallbackValue(DepositSettingsDto.fixture());
    registerFallbackValue(Duration.zero);

    inject.registerFactory<LottieBuilder>(
      () => Assets.lotties.click.lottie(animate: false),
      instanceName: InjectInstanceNames.lottieClick,
    );
    inject.registerFactory<LottieBuilder>(
      () => Assets.lotties.empty.lottie(animate: false),
      instanceName: InjectInstanceNames.lottieEmpty,
    );
    inject.registerFactory<LottieBuilder>(
      () => Assets.lotties.radar.lottie(animate: false),
      instanceName: InjectInstanceNames.lottieRadar,
    );
    inject.registerFactory<LottieBuilder>(
      () => Assets.lotties.matching.lottie(animate: false),
      instanceName: InjectInstanceNames.lottieMatching,
    );
    inject.registerFactory<LottieBuilder>(
      () => Assets.lotties.seaching.lottie(animate: false),
      instanceName: InjectInstanceNames.lottieSearching,
    );
    inject.registerFactory<ScrollController>(
      () => ScrollController(),
      instanceName: InjectInstanceNames.appScrollController,
    );

    inject.registerFactory<GlobalKey<NavigatorState>>(() => GlobalKey());
    inject.registerFactory<ZupNavigator>(() => navigator);
    inject.registerFactory<Wallet>(() => wallet);
    inject.registerFactory<ZupCachedImage>(() => mockZupCachedImage());
    inject.registerFactory<AppCubit>(() => appCubit);
    inject.registerFactory<ZupSingletonCache>(() => ZupSingletonCache.shared);
    inject.registerFactory<GlobalKey<ScaffoldMessengerState>>(() => GlobalKey());
    inject.registerFactory<PositionsCubit>(() => positionsCubit);
    inject.registerFactory<UniswapV3Pool>(() => uniswapV3pool);
    inject.registerFactory<Erc20>(() => erc20);
    inject.registerFactory<UniswapPositionManager>(() => UniswapPositionManagerMock());

    when(() => cubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => cubit.state).thenAnswer((_) => const DepositState.initial());
    when(() =>
            cubit.getBestPools(token0Address: any(named: "token0Address"), token1Address: any(named: "token1Address")))
        .thenAnswer((_) async {});
    when(() => cubit.selectedYieldStream).thenAnswer((_) => const Stream.empty());
    when(() => appCubit.selectedNetwork).thenReturn(Networks.sepolia);
    when(() => cubit.poolTickStream).thenAnswer((_) => const Stream.empty());
    when(() => cubit.latestPoolTick).thenAnswer((_) => BigInt.from(32523672));
    when(() => wallet.signerStream).thenAnswer((_) => const Stream.empty());
    when(() => wallet.signer).thenReturn(null);
    when(() => cubit.saveDepositSettings(any(), any())).thenAnswer((_) async => ());
    when(() => cubit.depositSettings).thenReturn(DepositSettingsDto.fixture());
  });

  tearDown(() async {
    await ZupSingletonCache.shared.clear();
    await inject.reset();
  });

  Future<DeviceBuilder> goldenBuilder({bool isMobile = false}) => goldenDeviceBuilder(
        BlocProvider.value(
          value: cubit,
          child: const DepositPage(),
        ),
        device: isMobile ? GoldenDevice.mobile : GoldenDevice.pc,
      );

  zGoldenTest("When initializing the page it should call setup in the cubit", (tester) async {
    await tester.runAsync(() async {
      await tester.pumpDeviceBuilder(await goldenBuilder());
    });

    verify(() => cubit.setup()).called(1);
  });

  zGoldenTest("""When initializing the page it should get the list of best pools,
   passing the correct token addresses (from the url)""", (tester) async {
    const token0Address = "0xToken0";
    const token1Address = "0xToken1";

    when(() => navigator.getParam(ZupNavigatorPaths.deposit.routeParamsName!.param0)).thenReturn(token0Address);
    when(() => navigator.getParam(ZupNavigatorPaths.deposit.routeParamsName!.param1)).thenReturn(token1Address);

    await tester.runAsync(() async {
      await tester.pumpDeviceBuilder(await goldenBuilder());
    });

    verify(
      () => cubit.getBestPools(
        token0Address: token0Address,
        token1Address: token1Address,
      ),
    ).called(1);
  });

  zGoldenTest("When the cubit state is loading it should show the loading state",
      goldenFileName: "deposit_page_loading", (tester) async {
    when(() => cubit.state).thenReturn(const DepositState.loading());

    await tester.runAsync(() async {
      await tester.pumpDeviceBuilder(await goldenBuilder());
    });

    await tester.pumpAndSettle();
  });

  zGoldenTest("When the cubit state is noYields, it should show the noYields state",
      goldenFileName: "deposit_page_no_yields", (tester) async {
    when(() => cubit.state).thenReturn(const DepositState.noYields());

    await tester.pumpDeviceBuilder(await goldenBuilder());

    await tester.pumpAndSettle();
  });

  zGoldenTest("""When clicking the helper button in the no yields state,
   it should navigate back to choose tokens stage""", (tester) async {
    when(() => navigator.back(any())).thenAnswer((_) async {});

    when(() => cubit.state).thenReturn(const DepositState.noYields());

    await tester.pumpDeviceBuilder(await goldenBuilder());

    await tester.tap(find.byKey(const Key("help-button")));
    await tester.pumpAndSettle();

    verify(() => navigator.back(any())).called(1);
  });

  zGoldenTest("When the cubit state is error, it should show the error state", goldenFileName: "deposit_page_error",
      (tester) async {
    when(() => cubit.state).thenReturn(const DepositState.error());

    await tester.pumpDeviceBuilder(await goldenBuilder());

    await tester.pumpAndSettle();
  });

  zGoldenTest(""""When clicking the helper button in the error state,
    it should try to get best pools again with the same tokens""", (tester) async {
    const token0Address = "0xToken0";
    const token1Address = "0xToken1";

    when(() => navigator.getParam(ZupNavigatorPaths.deposit.routeParamsName!.param0)).thenReturn(token0Address);
    when(() => navigator.getParam(ZupNavigatorPaths.deposit.routeParamsName!.param1)).thenReturn(token1Address);
    when(() => cubit.state).thenReturn(const DepositState.error());

    await tester.pumpDeviceBuilder(await goldenBuilder());

    await tester.tap(find.byKey(const Key("help-button")));
    await tester.pumpAndSettle();

    verify(() => cubit.getBestPools(token0Address: token0Address, token1Address: token1Address))
        .called(2); // 2 because of the initial call
  });

  zGoldenTest("When the state is sucess, it should show the success state", goldenFileName: "deposit_page_success",
      (tester) async {
    final yields = YieldsDto.fixture();

    when(() => cubit.state).thenReturn(DepositState.success(yields));

    await tester.pumpDeviceBuilder(await goldenBuilder());

    await tester.pumpAndSettle();
  });

  zGoldenTest("When the state is sucess, and the running device is a mobile, the yield cards should be in a column",
      goldenFileName: "deposit_page_success_mobile", (tester) async {
    final yields = YieldsDto.fixture();

    when(() => cubit.depositSettings).thenReturn(DepositSettingsDto(
      deadlineMinutes: 10,
      maxSlippage: DepositSettingsDto.defaultMaxSlippage,
    ));

    when(() => cubit.state).thenReturn(DepositState.success(yields));

    await tester.pumpDeviceBuilder(await goldenBuilder(isMobile: true));

    await tester.pumpAndSettle();
  });

  zGoldenTest(
    "When the running device is mobile, the range section should be adapted to it",
    goldenFileName: "deposit_page_range_section_mobile",
    (tester) async {
      final selectedYield = YieldDto.fixture();
      final yields = YieldsDto.fixture();

      when(() => cubit.depositSettings).thenReturn(DepositSettingsDto(
        deadlineMinutes: 10,
        maxSlippage: DepositSettingsDto.defaultMaxSlippage,
      ));

      when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
      when(() => cubit.selectedYield).thenReturn(selectedYield);
      when(() => cubit.state).thenReturn(DepositState.success(yields));
      when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));

      await tester.pumpDeviceBuilder(await goldenBuilder(isMobile: true));
      await tester.pumpAndSettle();
      await tester.drag(find.byKey(const Key("full-range-button")), const Offset(0, -500));
      await tester.pumpAndSettle();

      await tester.pumpAndSettle();
    },
  );

  zGoldenTest("When clicking back in the success state, it should navigate to the choose tokens page", (tester) async {
    when(() => navigator.navigateToNewPosition()).thenAnswer((_) async {});

    when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));

    await tester.pumpDeviceBuilder(await goldenBuilder());

    await tester.tap(find.byKey(const Key("back-button")));
    await tester.pumpAndSettle();

    verify(() => navigator.navigateToNewPosition()).called(1);
  });

  zGoldenTest("When hovering the title of the pool time frame section, it should show a tooltip explaining it",
      goldenFileName: "deposit_page_timeframe_tooltip", (tester) async {
    when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));

    await tester.pumpDeviceBuilder(await goldenBuilder());

    await tester.hover(find.byKey(const Key("timeframe-tooltip")));
    await tester.pumpAndSettle();
  });

  zGoldenTest(
      "When clicking learn more in the pool time frame tooltip, it should launch the Zup blog page explaining it",
      (tester) async {
    when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));

    await tester.pumpDeviceBuilder(await goldenBuilder());

    await tester.hover(find.byKey(const Key("timeframe-tooltip")));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key("helper-button-tooltip")));
    await tester.pumpAndSettle();

    expect(
      UrlLauncherPlatformCustomMock.lastLaunchedUrl,
      "https://zupprotocol.substack.com/p/zup-timeframes-explained-why-you",
    );
  });

  zGoldenTest("When the selected yield stream in the cubit emits a yield, it should select the yield",
      goldenFileName: "deposit_page_selected_yield_stream", (tester) async {
    final yields = YieldsDto.fixture();
    final selectedYield = yields.timeframedYields.best24hYields.first;

    when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
    when(() => cubit.selectedYield).thenReturn(selectedYield);
    when(() => cubit.state).thenReturn(DepositState.success(yields));

    await tester.pumpDeviceBuilder(await goldenBuilder());
    await tester.pumpAndSettle();
  });

  zGoldenTest("When selecting a yield, it should call select yield in the cubit", (tester) async {
    when(() => cubit.selectYield(any())).thenAnswer((_) async {});
    when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));

    await tester.pumpDeviceBuilder(await goldenBuilder());

    await tester.tap(find.byKey(const Key("yield-card-24h")));
    await tester.pumpAndSettle();

    verify(() => cubit.selectYield(any())).called(1);
  });

  zGoldenTest("When selecting a yield, it should scroll down to the range section",
      goldenFileName: "deposit_page_select_yield_scroll", (tester) async {
    final selectedYield = YieldsDto.fixture().timeframedYields.best24hYields.first;

    when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
    when(() => cubit.selectedYield).thenReturn(null);
    when(() => cubit.selectYield(any())).thenAnswer((_) async {});
    when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
    when(() => cubit.selectedYield).thenReturn(selectedYield);

    await tester.pumpDeviceBuilder(await goldenBuilder());

    await tester.tap(find.byKey(const Key("yield-card-30d")));
    await tester.pumpAndSettle();

    verify(() => cubit.selectYield(any())).called(1);
  });

  zGoldenTest("When there is not yields in 24h, it should not show the 24h card", goldenFileName: "deposit_page_no_24h",
      (tester) async {
    final yields = YieldsDto.fixture().copyWith(
      timeframedYields: YieldsByTimeframeDto.fixture().copyWith(best24hYields: []),
    );

    when(() => cubit.state).thenReturn(DepositState.success(yields));

    await tester.pumpDeviceBuilder(await goldenBuilder());
  });

  zGoldenTest("When there is not yields in 30d, it should not show the 30d card", goldenFileName: "deposit_page_no_30d",
      (tester) async {
    final yields = YieldsDto.fixture().copyWith(
      timeframedYields: YieldsByTimeframeDto.fixture().copyWith(best30dYields: []),
    );

    when(() => cubit.state).thenReturn(DepositState.success(yields));

    await tester.pumpDeviceBuilder(await goldenBuilder());

    await tester.pumpAndSettle();
  });

  zGoldenTest("When there is not yields in 3months, it should not show the 3months card",
      goldenFileName: "deposit_page_no_3months", (tester) async {
    final yields = YieldsDto.fixture().copyWith(
      timeframedYields: YieldsByTimeframeDto.fixture().copyWith(best90dYields: []),
    );
    when(() => cubit.state).thenReturn(DepositState.success(yields));

    await tester.pumpDeviceBuilder(await goldenBuilder());

    await tester.pumpAndSettle();
  });

  zGoldenTest(
      "When clicking the segmented control to switch the base token to quote token, it should reverse the tokens",
      goldenFileName: "deposit_page_reverse_tokens", (tester) async {
    final selectedYield = YieldsDto.fixture().timeframedYields.best24hYields.first;

    when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
    when(() => cubit.selectedYield).thenReturn(selectedYield);
    when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));

    await tester.pumpDeviceBuilder(await goldenBuilder());

    await tester.tap(find.byKey(const Key("reverse-tokens-reversed")));
    await tester.pumpAndSettle();
  });

  zGoldenTest(
      "When clicking the segmented control to switch back to base token, after reversing the tokens, it should reverse again",
      goldenFileName: "deposit_page_reverse_tokens_back", (tester) async {
    final selectedYield = YieldsDto.fixture().timeframedYields.best24hYields.first;

    when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
    when(() => cubit.selectedYield).thenReturn(selectedYield);
    when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));

    await tester.pumpDeviceBuilder(await goldenBuilder());

    await tester.tap(find.byKey(const Key("reverse-tokens-reversed")));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key("reverse-tokens-not-reversed")));
    await tester.pumpAndSettle();
  });

  zGoldenTest(
      "When clicking the segmented control to switch back to base token, after reversing the tokens, it should reverse again",
      goldenFileName: "deposit_page_reverse_tokens_back", (tester) async {
    final selectedYield = YieldsDto.fixture().timeframedYields.best24hYields.first;

    when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
    when(() => cubit.selectedYield).thenReturn(selectedYield);
    when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));

    await tester.pumpDeviceBuilder(await goldenBuilder());

    await tester.tap(find.byKey(const Key("reverse-tokens-reversed")));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key("reverse-tokens-not-reversed")));
    await tester.pumpAndSettle();
  });

  zGoldenTest("""When emitting an event to the tick stream,
      it should calculate the price of the selected yield assets""", goldenFileName: "deposit_page_calculate_price",
      (tester) async {
    final selectedYield = YieldsDto.fixture().timeframedYields.best24hYields.first;

    when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
    when(() => cubit.selectedYield).thenReturn(selectedYield);
    when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
    when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(BigInt.from(174072)));

    await tester.pumpDeviceBuilder(await goldenBuilder());
  });

  zGoldenTest(
      "When reversing the tokens, it should calculate the price based on the reversed tokens, from a given tick in the cubit",
      goldenFileName: "deposit_page_calculate_price_reversed", (tester) async {
    final selectedYield = YieldsDto.fixture().timeframedYields.best24hYields.first;

    when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
    when(() => cubit.selectedYield).thenReturn(selectedYield);
    when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
    when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(BigInt.from(174072)));

    await tester.pumpDeviceBuilder(await goldenBuilder());

    await tester.tap(find.byKey(const Key("reverse-tokens-reversed")));
    await tester.pumpAndSettle();
  });

  zGoldenTest(
    "When typing a min price more than the current price, it should show an alert saying that is out of range",
    goldenFileName: "deposit_page_min_price_out_of_range",
    (tester) async {
      final selectedYield = YieldsDto.fixture().timeframedYields.best24hYields.first;
      final currentPriceAsTick = BigInt.from(174072);

      when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
      when(() => cubit.selectedYield).thenReturn(selectedYield);
      when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
      when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
      when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

      await tester.pumpDeviceBuilder(await goldenBuilder());

      await tester.enterText(find.byKey(const Key("min-price-selector")), "1000");
      FocusManager.instance.primaryFocus?.unfocus();

      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    """When typing a min price more than the current price,
     it should show an alert saying that is out of range. 
     If the user reverse the tokens, and in the reversed state
     is not out of range, it should not show the alert""",
    goldenFileName: "deposit_page_min_price_out_of_range_reversed_in_range",
    (tester) async {
      final selectedYield = YieldsDto.fixture().timeframedYields.best24hYields.first;
      final currentPriceAsTick = BigInt.from(174072);

      when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
      when(() => cubit.selectedYield).thenReturn(selectedYield);
      when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
      when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
      when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

      await tester.pumpDeviceBuilder(await goldenBuilder());

      await tester.enterText(find.byKey(const Key("min-price-selector")), "1000");
      FocusManager.instance.primaryFocus?.unfocus();

      await tester.tap(find.byKey(const Key("reverse-tokens-reversed")));
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    """When typing a min price more than the current price,
     it should show an alert saying that is out of range. 
     If the user reverse the tokens, and in the reversed state
     is is still out of range, it should keep showing the alert""",
    goldenFileName: "deposit_page_min_price_out_of_range_reversed",
    (tester) async {
      final selectedYield = YieldsDto.fixture().timeframedYields.best24hYields.first;
      final currentPriceAsTick = BigInt.from(174072);

      when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
      when(() => cubit.selectedYield).thenReturn(selectedYield);
      when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
      when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
      when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

      await tester.pumpDeviceBuilder(await goldenBuilder());

      await tester.enterText(find.byKey(const Key("min-price-selector")), "90000000000");
      FocusManager.instance.primaryFocus?.unfocus();

      await tester.tap(find.byKey(const Key("reverse-tokens-reversed")));
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest("When typing a max price less than the min price, it should show an error message",
      goldenFileName: "deposit_page_max_price_less_than_min_price", (tester) async {
    final selectedYield = YieldsDto.fixture().timeframedYields.best24hYields.first;
    final currentPriceAsTick = BigInt.from(174072);

    when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
    when(() => cubit.selectedYield).thenReturn(selectedYield);
    when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
    when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
    when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

    await tester.pumpDeviceBuilder(await goldenBuilder());

    await tester.enterText(find.byKey(const Key("min-price-selector")), "1200");
    FocusManager.instance.primaryFocus?.unfocus();

    await tester.enterText(find.byKey(const Key("max-price-selector")), "1000");
    FocusManager.instance.primaryFocus?.unfocus();
  });

  zGoldenTest("""When typing a max price lower than the current price
  but higher than min price, it shouw show a alert of out of range""",
      goldenFileName: "deposit_page_max_price_out_of_range", (tester) async {
    final selectedYield = YieldsDto.fixture().timeframedYields.best24hYields.first;
    final currentPriceAsTick = BigInt.from(174072);

    when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
    when(() => cubit.selectedYield).thenReturn(selectedYield);
    when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
    when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
    when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

    await tester.pumpDeviceBuilder(await goldenBuilder());

    await tester.enterText(find.byKey(const Key("min-price-selector")), "0.000000001");
    FocusManager.instance.primaryFocus?.unfocus();

    await tester.enterText(find.byKey(const Key("max-price-selector")), "0.0000001");
    FocusManager.instance.primaryFocus?.unfocus();
  });

  zGoldenTest("When typing 0 in the max price, it should set it to infinity max price",
      goldenFileName: "deposit_page_max_price_set_to_infinity", (tester) async {
    final selectedYield = YieldsDto.fixture().timeframedYields.best24hYields.first;
    final currentPriceAsTick = BigInt.from(174072);

    when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
    when(() => cubit.selectedYield).thenReturn(selectedYield);
    when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
    when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
    when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

    await tester.pumpDeviceBuilder(await goldenBuilder());

    await tester.enterText(find.byKey(const Key("min-price-selector")), "1");
    FocusManager.instance.primaryFocus?.unfocus();

    await tester.enterText(find.byKey(const Key("max-price-selector")), "2");
    FocusManager.instance.primaryFocus?.unfocus();

    await tester.enterText(find.byKey(const Key("max-price-selector")), "");
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key("max-price-selector")), "0");
    FocusManager.instance.primaryFocus?.unfocus();

    await tester.pumpAndSettle();
  });

  zGoldenTest("When typing a min price, but then selecting the full range button, it should set it to 0",
      goldenFileName: "deposit_page_min_price_set_to_full_range", (tester) async {
    final selectedYield = YieldsDto.fixture().timeframedYields.best24hYields.first;
    final currentPriceAsTick = BigInt.from(174072);

    when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
    when(() => cubit.selectedYield).thenReturn(selectedYield);
    when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
    when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
    when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

    await tester.pumpDeviceBuilder(await goldenBuilder());

    await tester.enterText(find.byKey(const Key("min-price-selector")), "1");
    FocusManager.instance.primaryFocus?.unfocus();

    await tester.tap(find.byKey(const Key("full-range-button")));
    await tester.pumpAndSettle();
  });

  zGoldenTest("When typing a max price, but then selecting the full range button, it should set it to infinity",
      goldenFileName: "deposit_page_max_price_set_to_full_range", (tester) async {
    final selectedYield = YieldsDto.fixture().timeframedYields.best24hYields.first;
    final currentPriceAsTick = BigInt.from(174072);

    when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
    when(() => cubit.selectedYield).thenReturn(selectedYield);
    when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
    when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
    when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

    await tester.pumpDeviceBuilder(await goldenBuilder());

    await tester.enterText(find.byKey(const Key("max-price-selector")), "1");
    FocusManager.instance.primaryFocus?.unfocus();

    await tester.tap(find.byKey(const Key("full-range-button")));
    await tester.pumpAndSettle();
  });

  zGoldenTest("""When typing a min and max price and then clicking the full range button,
   it should set the min price to 0 and the max price to infinity""",
      goldenFileName: "deposit_page_min_and_max_price_set_to_full_range", (tester) async {
    final selectedYield = YieldsDto.fixture().timeframedYields.best24hYields.first;
    final currentPriceAsTick = BigInt.from(174072);

    when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
    when(() => cubit.selectedYield).thenReturn(selectedYield);
    when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
    when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
    when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

    await tester.pumpDeviceBuilder(await goldenBuilder());

    await tester.enterText(find.byKey(const Key("min-price-selector")), "1");
    FocusManager.instance.primaryFocus?.unfocus();

    await tester.enterText(find.byKey(const Key("max-price-selector")), "2");
    FocusManager.instance.primaryFocus?.unfocus();

    await tester.tap(find.byKey(const Key("full-range-button")));
    await tester.pumpAndSettle();
  });

  zGoldenTest(
      "When there's a invalid range, the deposit section should be disabled (with opacity) and cannot be clicked or typed",
      goldenFileName: "deposit_page_invalid_range_deposit_section", (tester) async {
    final selectedYield = YieldsDto.fixture().timeframedYields.best24hYields.first;
    final currentPriceAsTick = BigInt.from(174072);

    when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
    when(() => cubit.selectedYield).thenReturn(selectedYield);
    when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
    when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
    when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

    await tester.pumpDeviceBuilder(await goldenBuilder());

    await tester.enterText(find.byKey(const Key("min-price-selector")), "2");
    FocusManager.instance.primaryFocus?.unfocus();

    await tester.enterText(find.byKey(const Key("max-price-selector")), "1");
    FocusManager.instance.primaryFocus?.unfocus();

    await tester.drag(find.byKey(const Key("deposit-section")), const Offset(0, -500));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key("deposit-button")));
    await tester.pumpAndSettle();
  });

  zGoldenTest(
    "When inputing the base token amount, the quote amount token should be automatically calculated",
    goldenFileName: "deposit_page_input_base_token_amount",
    (tester) async {
      final selectedYield = YieldsDto.fixture().timeframedYields.best24hYields.first;
      final currentPriceAsTick = BigInt.from(174072);

      when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
      when(() => cubit.selectedYield).thenReturn(selectedYield);
      when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
      when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
      when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.drag(find.byKey(const Key("deposit-section")), const Offset(0, -500));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key("base-token-input-card")), "1");
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    "When inputing the quote token amount, the base amount token should be automatically calculated",
    goldenFileName: "deposit_page_input_quote_token_amount",
    (tester) async {
      final selectedYield = YieldsDto.fixture().timeframedYields.best24hYields.first;
      final currentPriceAsTick = BigInt.from(174072);

      when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
      when(() => cubit.selectedYield).thenReturn(selectedYield);
      when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
      when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
      when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.drag(find.byKey(const Key("deposit-section")), const Offset(0, -500));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key("quote-token-input-card")), "1");
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    """When inputing the base token, then reversing the tokens,
    the quote token then should be the same as the previous base token,
    and the new base token amount should be automatically calculated""",
    goldenFileName: "deposit_page_input_base_token_amount_and_reverse",
    (tester) async {
      final selectedYield = YieldsDto.fixture().timeframedYields.best24hYields.first;
      final currentPriceAsTick = BigInt.from(174072);

      when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
      when(() => cubit.selectedYield).thenReturn(selectedYield);
      when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
      when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
      when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.drag(find.byKey(const Key("deposit-section")), const Offset(0, -500));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key("base-token-input-card")), "1");
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("reverse-tokens-reversed")));
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    """When inputing the quote token, then reversing the tokens,
    the base token then should be the same as the previous quote token,
    and the new quote token amount should be automatically calculated""",
    goldenFileName: "deposit_page_input_quote_token_amount_and_reverse",
    (tester) async {
      final selectedYield = YieldsDto.fixture().timeframedYields.best24hYields.first;
      final currentPriceAsTick = BigInt.from(174072);

      when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
      when(() => cubit.selectedYield).thenReturn(selectedYield);
      when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
      when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
      when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.drag(find.byKey(const Key("deposit-section")), const Offset(0, -500));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key("quote-token-input-card")), "1");
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("reverse-tokens-reversed")));
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    """When inputing the base token amount with the tokens reversed, the quote token amount should be automatically calculated""",
    goldenFileName: "deposit_page_input_base_token_amount_reversed",
    (tester) async {
      final selectedYield = YieldsDto.fixture().timeframedYields.best24hYields.first;
      final currentPriceAsTick = BigInt.from(174072);

      when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
      when(() => cubit.selectedYield).thenReturn(selectedYield);
      when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
      when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
      when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.drag(find.byKey(const Key("deposit-section")), const Offset(0, -500));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("reverse-tokens-reversed")));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key("base-token-input-card")), "1");
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    """When inputing the quote token amount with the tokens reversed, the base token amount should be automatically calculated""",
    goldenFileName: "deposit_page_input_quote_token_amount_reversed",
    (tester) async {
      final selectedYield = YieldsDto.fixture().timeframedYields.best24hYields.first;
      final currentPriceAsTick = BigInt.from(174072);

      when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
      when(() => cubit.selectedYield).thenReturn(selectedYield);
      when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
      when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
      when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.drag(find.byKey(const Key("deposit-section")), const Offset(0, -500));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("reverse-tokens-reversed")));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key("quote-token-input-card")), "1");
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest("""When inputing the base token amount with the tokens reversed,
   then turning them normal, the quote token amount should now be the 
   previous base token amount, and the new base token amount should be automatically calculated""",
      goldenFileName: "deposit_page_input_base_token_amount_and_reverse_back", (tester) async {
    final selectedYield = YieldsDto.fixture().timeframedYields.best24hYields.first;
    final currentPriceAsTick = BigInt.from(174072);

    when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
    when(() => cubit.selectedYield).thenReturn(selectedYield);
    when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
    when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
    when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

    await tester.pumpDeviceBuilder(await goldenBuilder());
    await tester.drag(find.byKey(const Key("deposit-section")), const Offset(0, -500));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key("reverse-tokens-reversed")));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key("base-token-input-card")), "1");
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key("reverse-tokens-not-reversed")));
    await tester.pumpAndSettle();
  });

  zGoldenTest("""When inputing the quote token amount with the tokens reversed,
   then turning them normal, the base token amount should now be the 
   previous quote token amount, and the new quote token amount should be automatically calculated""",
      goldenFileName: "deposit_page_input_quote_token_amount_and_reverse_back", (tester) async {
    final selectedYield = YieldsDto.fixture().timeframedYields.best24hYields.first;
    final currentPriceAsTick = BigInt.from(174072);

    when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
    when(() => cubit.selectedYield).thenReturn(selectedYield);
    when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
    when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
    when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

    await tester.pumpDeviceBuilder(await goldenBuilder());
    await tester.drag(find.byKey(const Key("deposit-section")), const Offset(0, -500));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key("reverse-tokens-reversed")));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key("quote-token-input-card")), "1");
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key("reverse-tokens-not-reversed")));
    await tester.pumpAndSettle();
  });

  zGoldenTest(
    "When inputing the base token amount, then changing the range, the quote token amount should be recalculated",
    goldenFileName: "deposit_page_input_base_token_amount_and_change_range",
    (tester) async {
      final selectedYield = YieldsDto.fixture().timeframedYields.best24hYields.first;
      final currentPriceAsTick = BigInt.from(174072);

      when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
      when(() => cubit.selectedYield).thenReturn(selectedYield);
      when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
      when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
      when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.drag(find.byKey(const Key("deposit-section")), const Offset(0, -500));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key("base-token-input-card")), "1");
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key("min-price-selector")), "0.00000001");
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key("max-price-selector")), "0");
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key("max-price-selector")), "3");
      await tester.pumpAndSettle();
      FocusManager.instance.primaryFocus?.unfocus();
    },
  );

  zGoldenTest(
    "When inputing the quote token amount, then changing the range, the base token amount should be recalculated",
    goldenFileName: "deposit_page_input_quote_token_amount_and_change_range",
    (tester) async {
      final selectedYield = YieldsDto.fixture().timeframedYields.best24hYields.first;
      final currentPriceAsTick = BigInt.from(174072);

      when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
      when(() => cubit.selectedYield).thenReturn(selectedYield);
      when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
      when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
      when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.drag(find.byKey(const Key("deposit-section")), const Offset(0, -500));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key("quote-token-input-card")), "1");
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key("min-price-selector")), "0.00000001");
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key("max-price-selector")), "0");
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key("max-price-selector")), "3");
      await tester.pumpAndSettle();

      FocusManager.instance.primaryFocus?.unfocus();
    },
  );

  zGoldenTest(
      "When inputing the base token amount, reversing the tokens and then changing the range, the base token amount should be recalculated",
      goldenFileName: "deposit_page_input_base_token_amount_reverse_tokens_and_change_range", (tester) async {
    final selectedYield = YieldsDto.fixture().timeframedYields.best24hYields.first;
    final currentPriceAsTick = BigInt.from(174072);

    when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
    when(() => cubit.selectedYield).thenReturn(selectedYield);
    when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
    when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
    when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

    await tester.pumpDeviceBuilder(await goldenBuilder());
    await tester.drag(find.byKey(const Key("deposit-section")), const Offset(0, -500));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key("base-token-input-card")), "1");
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key("reverse-tokens-reversed")));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key("min-price-selector")), "1200");
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key("max-price-selector")), "0");
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key("max-price-selector")), "90000");
    await tester.pumpAndSettle();

    FocusManager.instance.primaryFocus?.unfocus();
  });

  zGoldenTest(
      "When inputing the quote token amount, reversing the tokens and then changing the range, the quote token amount should be recalculated",
      goldenFileName: "deposit_page_input_quote_token_amount_reverse_tokens_and_change_range", (tester) async {
    final selectedYield = YieldsDto.fixture().timeframedYields.best24hYields.first;
    final currentPriceAsTick = BigInt.from(174072);

    when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
    when(() => cubit.selectedYield).thenReturn(selectedYield);
    when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
    when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
    when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

    await tester.pumpDeviceBuilder(await goldenBuilder());
    await tester.drag(find.byKey(const Key("deposit-section")), const Offset(0, -500));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key("quote-token-input-card")), "1");
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key("reverse-tokens-reversed")));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key("min-price-selector")), "1200");
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key("max-price-selector")), "0");
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key("max-price-selector")), "90000");
    await tester.pumpAndSettle();

    FocusManager.instance.primaryFocus?.unfocus();
  });

  zGoldenTest(
    "When inputing a range, then inputing the base token amount, the quote token amount should be automatically calculated",
    goldenFileName: "deposit_page_input_range_then_input_base_token_amount",
    (tester) async {
      final selectedYield = YieldsDto.fixture().timeframedYields.best24hYields.first;
      final currentPriceAsTick = BigInt.from(174072);

      when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
      when(() => cubit.selectedYield).thenReturn(selectedYield);
      when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
      when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
      when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.drag(find.byKey(const Key("deposit-section")), const Offset(0, -500));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key("min-price-selector")), "0.000001");
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key("max-price-selector")), "0");
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key("max-price-selector")), "3");
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key("base-token-input-card")), "1");
      await tester.pumpAndSettle();

      FocusManager.instance.primaryFocus?.unfocus();
    },
  );

  zGoldenTest(
    "When inputing a range, then inputing the quote token amount, the base token amount should be automatically calculated",
    goldenFileName: "deposit_page_input_range_then_input_quote_token_amount",
    (tester) async {
      final selectedYield = YieldsDto.fixture().timeframedYields.best24hYields.first;
      final currentPriceAsTick = BigInt.from(174072);

      when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
      when(() => cubit.selectedYield).thenReturn(selectedYield);
      when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
      when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
      when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.drag(find.byKey(const Key("deposit-section")), const Offset(0, -500));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key("min-price-selector")), "0.000001");
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key("max-price-selector")), "0");
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key("max-price-selector")), "3");
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key("quote-token-input-card")), "1");
      await tester.pumpAndSettle();

      FocusManager.instance.primaryFocus?.unfocus();
    },
  );

  zGoldenTest(
    "When inputing a range,reversing the tokens, then inputing the base token amount, the quote token amount should be automatically calculated",
    goldenFileName: "deposit_page_input_range_then_reverse_tokens_then_input_base_token_amount",
    (tester) async {
      final selectedYield = YieldsDto.fixture().timeframedYields.best24hYields.first;
      final currentPriceAsTick = BigInt.from(174072);

      when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
      when(() => cubit.selectedYield).thenReturn(selectedYield);
      when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
      when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
      when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.drag(find.byKey(const Key("deposit-section")), const Offset(0, -500));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key("min-price-selector")), "1200");
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key("max-price-selector")), "0");
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key("max-price-selector")), "90000");
      await tester.pumpAndSettle();

      FocusManager.instance.primaryFocus?.unfocus(); // unfocus the fields to calculate the valid price

      await tester.tap(find.byKey(const Key("reverse-tokens-reversed")));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key("base-token-input-card")), "1");
      await tester.pumpAndSettle();

      FocusManager.instance.primaryFocus?.unfocus();
    },
  );

  zGoldenTest(
    "When inputing a range, reversing the tokens, then inputing the quote token amount, the base token amount should be automatically calculated",
    goldenFileName: "deposit_page_input_range_then_reverse_tokens_then_input_quote_token_amount",
    (tester) async {
      final selectedYield = YieldsDto.fixture().timeframedYields.best24hYields.first;
      final currentPriceAsTick = BigInt.from(174072);

      when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
      when(() => cubit.selectedYield).thenReturn(selectedYield);
      when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
      when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
      when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.drag(find.byKey(const Key("deposit-section")), const Offset(0, -500));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key("min-price-selector")), "1200");
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key("max-price-selector")), "0");
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key("max-price-selector")), "90000");
      await tester.pumpAndSettle();

      FocusManager.instance.primaryFocus?.unfocus(); // unfocus the fields to calculate the valid price

      await tester.tap(find.byKey(const Key("reverse-tokens-reversed")));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key("quote-token-input-card")), "1");
      await tester.pumpAndSettle();

      FocusManager.instance.primaryFocus?.unfocus();
    },
  );

  zGoldenTest("""When inputing base token amount, and then setting a max price out of range,
       it should keep the quote token amount and disable the base token input""",
      goldenFileName: "deposit_page_input_base_token_amount_then_set_max_price_out_of_range", (tester) async {
    final selectedYield = YieldsDto.fixture().timeframedYields.best24hYields.first;
    final currentPriceAsTick = BigInt.from(174072);

    when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
    when(() => cubit.selectedYield).thenReturn(selectedYield);
    when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
    when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
    when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

    await tester.pumpDeviceBuilder(await goldenBuilder());
    await tester.drag(find.byKey(const Key("deposit-section")), const Offset(0, -500));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key("base-token-input-card")), "1");
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key("max-price-selector")), "0");
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key("max-price-selector")), "0.00000001");
    await tester.pumpAndSettle();

    FocusManager.instance.primaryFocus?.unfocus();
  });

  zGoldenTest("""When inputing quote token amount, and then setting a min price out of range,
       it should keep the base token amount and disable the quote token input""",
      goldenFileName: "deposit_page_input_quote_token_amount_then_set_min_price_out_of_range", (tester) async {
    final selectedYield = YieldsDto.fixture().timeframedYields.best24hYields.first;
    final currentPriceAsTick = BigInt.from(174072);

    when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
    when(() => cubit.selectedYield).thenReturn(selectedYield);
    when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
    when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
    when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

    await tester.pumpDeviceBuilder(await goldenBuilder());
    await tester.drag(find.byKey(const Key("deposit-section")), const Offset(0, -500));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key("quote-token-input-card")), "1");
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key("min-price-selector")), "2");
    await tester.pumpAndSettle();

    FocusManager.instance.primaryFocus?.unfocus();
  });

  zGoldenTest("""When inputing base token amount, reversing the tokens, and then setting a max price out of range,
       it should keep the quote token amount and disable the base token input""",
      goldenFileName: "deposit_page_input_base_token_amount_then_reverse_tokens_then_set_max_price_out_of_range",
      (tester) async {
    final selectedYield = YieldsDto.fixture().timeframedYields.best24hYields.first;
    final currentPriceAsTick = BigInt.from(174072);

    when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
    when(() => cubit.selectedYield).thenReturn(selectedYield);
    when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
    when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
    when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

    await tester.pumpDeviceBuilder(await goldenBuilder());
    await tester.drag(find.byKey(const Key("deposit-section")), const Offset(0, -500));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key("base-token-input-card")), "1");
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key("reverse-tokens-reversed")));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key("max-price-selector")), "0");
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key("max-price-selector")), "3");
    await tester.pumpAndSettle();

    FocusManager.instance.primaryFocus?.unfocus();
  });

  zGoldenTest("""When inputing quote token amount, reversing the tokens, and then setting a min price out of range,
       it should keep the base token amount and disable the quote token input""",
      goldenFileName: "deposit_page_input_quote_token_amount_then_reverse_tokens_then_set_min_price_out_of_range",
      (tester) async {
    final selectedYield = YieldsDto.fixture().timeframedYields.best24hYields.first;
    final currentPriceAsTick = BigInt.from(174072);

    when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
    when(() => cubit.selectedYield).thenReturn(selectedYield);
    when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
    when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
    when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

    await tester.pumpDeviceBuilder(await goldenBuilder());
    await tester.drag(find.byKey(const Key("deposit-section")), const Offset(0, -500));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key("quote-token-input-card")), "1");
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key("reverse-tokens-reversed")));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key("min-price-selector")), "70000");
    await tester.pumpAndSettle();

    FocusManager.instance.primaryFocus?.unfocus();
  });

  zGoldenTest(
    "When the user is is not connected, it should show the connect wallet button instead of the deposit button",
    goldenFileName: "deposit_page_not_connected",
    (tester) async {
      final selectedYield = YieldsDto.fixture().timeframedYields.best24hYields.first;
      final currentPriceAsTick = BigInt.from(174072);

      when(() => wallet.signer).thenReturn(null);
      when(() => wallet.signerStream).thenAnswer((_) => Stream.value(null));
      when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
      when(() => cubit.selectedYield).thenReturn(selectedYield);
      when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
      when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
      when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.drag(find.byKey(const Key("deposit-section")), const Offset(0, -500));
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    """When the user is is not connected,
    it should show the connect wallet button instead of the deposit button.
    When clicking the button, it should show the connect wallet modal
    """,
    goldenFileName: "deposit_page_not_connected_deposit_button_click",
    (tester) async {
      final selectedYield = YieldsDto.fixture().timeframedYields.best24hYields.first;
      final currentPriceAsTick = BigInt.from(174072);

      when(() => wallet.signer).thenReturn(null);
      when(() => wallet.signerStream).thenAnswer((_) => Stream.value(null));
      when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
      when(() => cubit.selectedYield).thenReturn(selectedYield);
      when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
      when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
      when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

      await tester.pumpDeviceBuilder(await goldenBuilder(), wrapper: GoldenConfig.localizationsWrapper());
      await tester.drag(find.byKey(const Key("deposit-section")), const Offset(0, -500));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("deposit-button")));
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    """When the user is connected, but there's no amount to deposit typed,
    the deposit button should should be disabled""",
    goldenFileName: "deposit_page_no_amount_deposit_button",
    (tester) async {
      final selectedYield = YieldsDto.fixture().timeframedYields.best24hYields.first;
      final currentPriceAsTick = BigInt.from(174072);
      final signer = SignerMock();

      when(() => wallet.signer).thenReturn(signer);
      when(() => wallet.signerStream).thenAnswer((_) => Stream.value(signer));
      when(() => cubit.getWalletTokenAmount(any(), network: any(named: "network"))).thenAnswer(
        (_) => Future.value(0.0),
      );
      when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
      when(() => cubit.selectedYield).thenReturn(selectedYield);
      when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
      when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
      when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.drag(find.byKey(const Key("deposit-section")), const Offset(0, -500));
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    """When the user is connected, there's an amount to deposit typed,
    but the user doesn't have enough balance of base token,
    the deposit button should should be disabled""",
    goldenFileName: "deposit_page_not_enough_base_token_balance_deposit_button",
    (tester) async {
      final selectedYield = YieldsDto.fixture().timeframedYields.best24hYields.first;
      final currentPriceAsTick = BigInt.from(174072);
      final signer = SignerMock();

      when(() => wallet.signer).thenReturn(signer);
      when(() => wallet.signerStream).thenAnswer((_) => Stream.value(signer));
      when(() => cubit.getWalletTokenAmount(any(), network: any(named: "network"))).thenAnswer(
        (_) => Future.value(0.0),
      );
      when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
      when(() => cubit.selectedYield).thenReturn(selectedYield);
      when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
      when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
      when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.drag(find.byKey(const Key("deposit-section")), const Offset(0, -500));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key("base-token-input-card")), "1");
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    """When the user is connected, there's an amount to deposit typed,
    but the user doesn't have enough balance of quote token,
    the deposit button should should be disabled""",
    goldenFileName: "deposit_page_not_enough_quote_token_balance_deposit_button",
    (tester) async {
      final selectedYield = YieldsDto.fixture().timeframedYields.best24hYields.first;
      final currentPriceAsTick = BigInt.from(174072);
      final signer = SignerMock();

      when(() => wallet.signer).thenReturn(signer);
      when(() => wallet.signerStream).thenAnswer((_) => Stream.value(signer));

      when(() => cubit.getWalletTokenAmount(selectedYield.token0.address, network: any(named: "network"))).thenAnswer(
        (_) => Future.value(32567352673),
      );
      when(() => cubit.getWalletTokenAmount(selectedYield.token1.address, network: any(named: "network"))).thenAnswer(
        (_) => Future.value(0),
      );
      when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
      when(() => cubit.selectedYield).thenReturn(selectedYield);
      when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
      when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
      when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.drag(find.byKey(const Key("deposit-section")), const Offset(0, -500));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key("quote-token-input-card")), "1");
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    """When the user is not connected, type an amount to deposit, and then connect
    without having enough balance of base token, the deposit button should should be disabled""",
    goldenFileName: "deposit_page_not_enough_base_token_balance_deposit_button_after_connecting",
    (tester) async {
      final selectedYield = YieldsDto.fixture().timeframedYields.best24hYields.first;
      final currentPriceAsTick = BigInt.from(174072);
      final signerStreamController = StreamController<Signer?>.broadcast();
      final signer = SignerMock();

      when(() => wallet.signer).thenReturn(null);
      when(() => wallet.signerStream).thenAnswer((_) => signerStreamController.stream);
      when(() => cubit.getWalletTokenAmount(selectedYield.token0.address, network: any(named: "network"))).thenAnswer(
        (_) => Future.value(0),
      );
      when(() => cubit.getWalletTokenAmount(selectedYield.token1.address, network: any(named: "network"))).thenAnswer(
        (_) => Future.value(0),
      );
      when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
      when(() => cubit.selectedYield).thenReturn(selectedYield);
      when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
      when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
      when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.drag(find.byKey(const Key("deposit-section")), const Offset(0, -500));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key("quote-token-input-card")), "1");
      await tester.pumpAndSettle();

      signerStreamController.add(signer);
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    """When the user is not connected, type an amount to deposit, and then connect
    without having enough balance of quote token, the deposit button should should be disabled""",
    goldenFileName: "deposit_page_not_enough_quote_token_balance_deposit_button_after_connecting",
    (tester) async {
      final selectedYield = YieldsDto.fixture().timeframedYields.best24hYields.first;
      final currentPriceAsTick = BigInt.from(174072);
      final signerStreamController = StreamController<Signer?>.broadcast();
      final signer = SignerMock();

      when(() => wallet.signer).thenReturn(null);
      when(() => wallet.signerStream).thenAnswer((_) => signerStreamController.stream);
      when(() => cubit.getWalletTokenAmount(selectedYield.token0.address, network: any(named: "network"))).thenAnswer(
        (_) => Future.value(347537253),
      );
      when(() => cubit.getWalletTokenAmount(selectedYield.token1.address, network: any(named: "network"))).thenAnswer(
        (_) => Future.value(0),
      );
      when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
      when(() => cubit.selectedYield).thenReturn(selectedYield);
      when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
      when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
      when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.drag(find.byKey(const Key("deposit-section")), const Offset(0, -500));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key("quote-token-input-card")), "1");
      await tester.pumpAndSettle();

      signerStreamController.add(signer);
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    """When the user is connected, type an amount to deposit, and have enough balance of both tokens
    the deposit button should be enabled""",
    goldenFileName: "deposit_page_enough_balance_deposit_button",
    (tester) async {
      final selectedYield = YieldsDto.fixture().timeframedYields.best24hYields.first;
      final currentPriceAsTick = BigInt.from(174072);

      final signer = SignerMock();

      when(() => wallet.signer).thenReturn(signer);
      when(() => wallet.signerStream).thenAnswer((_) => Stream.value(signer));
      when(() => cubit.getWalletTokenAmount(selectedYield.token0.address, network: any(named: "network"))).thenAnswer(
        (_) => Future.value(347537253),
      );
      when(() => cubit.getWalletTokenAmount(selectedYield.token1.address, network: any(named: "network"))).thenAnswer(
        (_) => Future.value(32576352673),
      );
      when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
      when(() => cubit.selectedYield).thenReturn(selectedYield);
      when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
      when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
      when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.drag(find.byKey(const Key("deposit-section")), const Offset(0, -500));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key("quote-token-input-card")), "1");
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest("""When the min range is out of range, and the user does not have quote token balance
       but has enough balance of base token, the deposit button should be enabled""",
      goldenFileName: "deposit_page_min_range_out_of_range_deposit_button", (tester) async {
    final selectedYield = YieldsDto.fixture().timeframedYields.best24hYields.first;
    final currentPriceAsTick = BigInt.from(174072);

    final signer = SignerMock();

    when(() => wallet.signer).thenReturn(signer);
    when(() => wallet.signerStream).thenAnswer((_) => Stream.value(signer));
    when(() => cubit.getWalletTokenAmount(selectedYield.token0.address, network: any(named: "network"))).thenAnswer(
      (_) => Future.value(347537253),
    );
    when(() => cubit.getWalletTokenAmount(selectedYield.token1.address, network: any(named: "network"))).thenAnswer(
      (_) => Future.value(0),
    );
    when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
    when(() => cubit.selectedYield).thenReturn(selectedYield);
    when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
    when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
    when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

    await tester.pumpDeviceBuilder(await goldenBuilder());
    await tester.drag(find.byKey(const Key("deposit-section")), const Offset(0, -500));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key("min-price-selector")), "1");
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key("base-token-input-card")), "1");
    await tester.pumpAndSettle();
  });

  zGoldenTest("""When the max range is out of range, and the user does not have base token balance
       but has enough balance of quote token, the deposit button should be enabled""",
      goldenFileName: "deposit_page_max_range_out_of_range_deposit_button", (tester) async {
    final selectedYield = YieldsDto.fixture().timeframedYields.best24hYields.first;
    final currentPriceAsTick = BigInt.from(174072);

    final signer = SignerMock();

    when(() => wallet.signer).thenReturn(signer);
    when(() => wallet.signerStream).thenAnswer((_) => Stream.value(signer));
    when(() => cubit.getWalletTokenAmount(selectedYield.token0.address, network: any(named: "network"))).thenAnswer(
      (_) => Future.value(0),
    );
    when(() => cubit.getWalletTokenAmount(selectedYield.token1.address, network: any(named: "network"))).thenAnswer(
      (_) => Future.value(3237526),
    );
    when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
    when(() => cubit.selectedYield).thenReturn(selectedYield);
    when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
    when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
    when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

    await tester.pumpDeviceBuilder(await goldenBuilder());
    await tester.drag(find.byKey(const Key("deposit-section")), const Offset(0, -500));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key("min-price-selector")), "0.0000001");
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key("max-price-selector")), "0");
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key("max-price-selector")), "0.000001");
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key("quote-token-input-card")), "1");
    await tester.pumpAndSettle();
  });

  zGoldenTest("When clicking the enabled deposit button, it should show the preview modal of the deposit",
      goldenFileName: "deposit_page_preview_modal", (tester) async {
    await tester.runAsync(() async {
      final selectedYield = YieldsDto.fixture().timeframedYields.best24hYields.first;
      final currentPriceAsTick = BigInt.from(174072);

      final signer = SignerMock();

      when(() => wallet.signer).thenReturn(signer);
      when(() => wallet.signerStream).thenAnswer((_) => Stream.value(signer));
      when(() => cubit.getWalletTokenAmount(selectedYield.token0.address, network: any(named: "network"))).thenAnswer(
        (_) => Future.value(347537253),
      );
      when(() => cubit.getWalletTokenAmount(selectedYield.token1.address, network: any(named: "network"))).thenAnswer(
        (_) => Future.value(32576352673),
      );
      when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
      when(() => cubit.selectedYield).thenReturn(selectedYield);
      when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
      when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
      when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

      await tester.pumpDeviceBuilder(await goldenBuilder(), wrapper: GoldenConfig.localizationsWrapper());
      await tester.drag(find.byKey(const Key("deposit-section")), const Offset(0, -500));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key("quote-token-input-card")), "1");
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("deposit-button")));
      await tester.pumpAndSettle();
    });
  });

  zGoldenTest(
    """When the base token amount input is not empty, and the pool tick is null,
  the quote token input should be loading""",
    goldenFileName: "deposit_page_quote_token_input_loading",
    (tester) async {
      final selectedYield = YieldsDto.fixture().timeframedYields.best24hYields.first;

      when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
      when(() => cubit.selectedYield).thenReturn(selectedYield);
      when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
      when(() => cubit.poolTickStream).thenAnswer((_) => const Stream.empty());
      when(() => cubit.latestPoolTick).thenReturn(null);

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.drag(find.byKey(const Key("deposit-section")), const Offset(0, -500));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key("base-token-input-card")), "1");
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    """When the quote token amount input is not empty, and the pool tick is null,
  the base token input should be loading""",
    goldenFileName: "deposit_page_base_token_input_loading",
    (tester) async {
      final selectedYield = YieldsDto.fixture().timeframedYields.best24hYields.first;

      when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
      when(() => cubit.selectedYield).thenReturn(selectedYield);
      when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
      when(() => cubit.poolTickStream).thenAnswer((_) => const Stream.empty());
      when(() => cubit.latestPoolTick).thenReturn(null);

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.drag(find.byKey(const Key("deposit-section")), const Offset(0, -500));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key("quote-token-input-card")), "1");
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    """When the quote token amount input is loading, and a non null pool tick
    is emitted, the quote token amount should be enabled
    """,
    goldenFileName: "deposit_page_quote_token_input_enabled_after_loading",
    (tester) async {
      final selectedYield = YieldsDto.fixture().timeframedYields.best24hYields.first;

      when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
      when(() => cubit.selectedYield).thenReturn(selectedYield);
      when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
      when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(BigInt.from(2131)));
      when(() => cubit.latestPoolTick).thenReturn(null);

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.drag(find.byKey(const Key("deposit-section")), const Offset(0, -500));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key("base-token-input-card")), "1");
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    """When the base token amount input is loading, and a non null pool tick
    is emitted, the base token amount should be enabled
    """,
    goldenFileName: "deposit_page_base_token_input_enabled_after_loading",
    (tester) async {
      final selectedYield = YieldsDto.fixture().timeframedYields.best24hYields.first;

      when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
      when(() => cubit.selectedYield).thenReturn(selectedYield);
      when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
      when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(BigInt.from(2131)));
      when(() => cubit.latestPoolTick).thenReturn(null);

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.drag(find.byKey(const Key("deposit-section")), const Offset(0, -500));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key("quote-token-input-card")), "1");
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    """When the deposit settings dropdown callback the onSettingsChanged callback,
    it should call saveDepositSettings in the cubit, to save the deposit
    settings in the cache""",
    (tester) async {
      const expectedSlippageCallback = Slippage.onePercent;
      const expectedDeadlineCallback = Duration(minutes: 21);

      when(() => cubit.saveDepositSettings(any(), any())).thenAnswer((_) async => () {});
      when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.tap(find.byKey(const Key("deposit-settings-button")));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key("slippage-text-field")), expectedSlippageCallback.value.toString());
      await tester.enterText(
          find.byKey(const Key("deadline-textfield")), expectedDeadlineCallback.inMinutes.toString());
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();

      verify(() => cubit.saveDepositSettings(expectedSlippageCallback, expectedDeadlineCallback)).called(1);
    },
  );

  zGoldenTest(
    """When the selected slippage is not the default value from the deposit settings dto,
    the title of the deposit settings button should be the selected slippage value""",
    goldenFileName: "deposit_page_deposit_settings_button_slippage_title",
    (tester) async {
      when(() => cubit.saveDepositSettings(any(), any())).thenAnswer((_) async => () {});
      when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.tap(find.byKey(const Key("deposit-settings-button")));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key("slippage-text-field")), "12.3");
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    """When the selected slippage value is lower than 10% and greater than 1%,
    the deposit settings button should be orange-styled with the slippage value""",
    goldenFileName: "deposit_page_deposit_settings_button_orange",
    (tester) async {
      when(() => cubit.saveDepositSettings(any(), any())).thenAnswer((_) async => () {});
      when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.tap(find.byKey(const Key("deposit-settings-button")));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key("slippage-text-field")), "1.2");
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    """When the selected slippage value is lower than 1%,
    the deposit settings button should be gray-styled with
    zup purple with the slippage value""",
    goldenFileName: "deposit_page_deposit_settings_button_zup_purple_gray",
    (tester) async {
      when(() => cubit.saveDepositSettings(any(), any())).thenAnswer((_) async => () {});
      when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.tap(find.byKey(const Key("deposit-settings-button")));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key("slippage-text-field")), "0.32");
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    """When the selected slippage value is greater than 10%,
    the deposit settings button should be red-styled with the 
    slippage value""",
    goldenFileName: "deposit_page_deposit_settings_button_red",
    (tester) async {
      when(() => cubit.saveDepositSettings(any(), any())).thenAnswer((_) async => () {});
      when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.tap(find.byKey(const Key("deposit-settings-button")));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key("slippage-text-field")), "21.2");
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    """When the deposit settings callback the onSettingsChanged callback,
    it should update the slippage and deadline variable""",
    (tester) async {
      const expectedSlippageCallback = Slippage.onePercent;
      const expectedDeadlineCallback = Duration(minutes: 21);

      when(() => cubit.saveDepositSettings(any(), any())).thenAnswer((_) async => () {});
      when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.tap(find.byKey(const Key("deposit-settings-button")));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key("slippage-text-field")), expectedSlippageCallback.value.toString());
      await tester.enterText(
          find.byKey(const Key("deadline-textfield")), expectedDeadlineCallback.inMinutes.toString());
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();

      verify(() => cubit.saveDepositSettings(expectedSlippageCallback, expectedDeadlineCallback)).called(1);
    },
  );

  zGoldenTest(
    """When opening the deposit settings dropdown, the default selected slippage and the deadline should be
    the ones from the cubit""",
    goldenFileName: "deposit_page_deposit_settings_dropdown",
    (tester) async {
      final expectedDepositSettings = DepositSettingsDto(maxSlippage: 32.1, deadlineMinutes: 98);
      when(() => cubit.saveDepositSettings(any(), any())).thenAnswer((_) async => () {});
      when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
      when(() => cubit.depositSettings).thenReturn(expectedDepositSettings);

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.tap(find.byKey(const Key("deposit-settings-button")));
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    """When selecting a slippage and a deadline in the deposit settings dropdown, closing the dropdown,
    and opening it again, the selected slippage and deadline should be the ones selected previously""",
    goldenFileName: "deposit_page_deposit_settings_dropdown_reopening",
    (tester) async {
      when(() => cubit.saveDepositSettings(any(), any())).thenAnswer((_) async => () {});
      when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.tap(find.byKey(const Key("deposit-settings-button")));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byKey(const Key("slippage-text-field")), "0.7"); // expected slippage to be shown on reopening
      await tester.enterText(
          find.byKey(const Key("deadline-textfield")), "76"); // expected deadline to be shown on reopening
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();

      // Closing the dropdown
      await tester.tap(find.byKey(const Key("deposit-settings-button")));
      await tester.pumpAndSettle();

      // // Reopening the dropdown
      await tester.tap(find.byKey(const Key("deposit-settings-button")));
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    """When selecting a slippage and a deadline in the deposit settings dropdown,
  and then clicking to preview the deposit, it should pass the correct slippage and deadline
  to the preview modal""",
    (tester) async {
      final expectedSlippage = Slippage.custom(0.7);
      const expectedDeadline = Duration(minutes: 76);

      await tester.runAsync(() async {
        final selectedYield = YieldsDto.fixture().timeframedYields.best24hYields.first;
        final currentPriceAsTick = BigInt.from(174072);

        final signer = SignerMock();

        when(() => wallet.signer).thenReturn(signer);
        when(() => wallet.signerStream).thenAnswer((_) => Stream.value(signer));
        when(() => cubit.getWalletTokenAmount(selectedYield.token0.address, network: any(named: "network"))).thenAnswer(
          (_) => Future.value(347537253),
        );
        when(() => cubit.getWalletTokenAmount(selectedYield.token1.address, network: any(named: "network"))).thenAnswer(
          (_) => Future.value(32576352673),
        );
        when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
        when(() => cubit.selectedYield).thenReturn(selectedYield);
        when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
        when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
        when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

        await tester.pumpDeviceBuilder(await goldenBuilder(), wrapper: GoldenConfig.localizationsWrapper());
        await tester.tap(find.byKey(const Key("deposit-settings-button")));
        await tester.pumpAndSettle();

        await tester.enterText(find.byKey(const Key("slippage-text-field")), expectedSlippage.value.toString());
        await tester.enterText(find.byKey(const Key("deadline-textfield")), expectedDeadline.inMinutes.toString());
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key("deposit-settings-button"))); // closing the dropdown
        await tester.pumpAndSettle();

        await tester.drag(find.byKey(const Key("deposit-section")), const Offset(0, -500));
        await tester.pumpAndSettle();

        await tester.enterText(find.byKey(const Key("quote-token-input-card")), "1");
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key("deposit-button")));
        await tester.pumpAndSettle();

        final previewDepositModal = find.byType(PreviewDepositModal).evaluate().first.widget as PreviewDepositModal;

        expect(previewDepositModal.maxSlippage, expectedSlippage, reason: "maxSlippage should be passed correctly");
        expect(previewDepositModal.deadline, expectedDeadline, reason: "deadline should be passed correctly");
      });
    },
  );
}
