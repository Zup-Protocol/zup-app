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
import 'package:zup_app/abis/uniswap_permit2.abi.g.dart';
import 'package:zup_app/abis/uniswap_v3_pool.abi.g.dart';
import 'package:zup_app/abis/uniswap_v3_position_manager.abi.g.dart';
import 'package:zup_app/app/app_cubit/app_cubit.dart';
import 'package:zup_app/app/create/deposit/deposit_cubit.dart';
import 'package:zup_app/app/create/deposit/deposit_page.dart';
import 'package:zup_app/app/create/deposit/widgets/preview_deposit_modal/preview_deposit_modal.dart';
import 'package:zup_app/core/cache.dart';
import 'package:zup_app/core/dtos/deposit_settings_dto.dart';
import 'package:zup_app/core/dtos/pool_search_filters_dto.dart';
import 'package:zup_app/core/dtos/pool_search_settings_dto.dart';
import 'package:zup_app/core/dtos/token_price_dto.dart';
import 'package:zup_app/core/dtos/yield_dto.dart';
import 'package:zup_app/core/dtos/yields_dto.dart';
import 'package:zup_app/core/enums/networks.dart';
import 'package:zup_app/core/enums/zup_navigator_paths.dart';
import 'package:zup_app/core/injections.dart';
import 'package:zup_app/core/pool_service.dart';
import 'package:zup_app/core/repositories/tokens_repository.dart';
import 'package:zup_app/core/slippage.dart';
import 'package:zup_app/core/zup_analytics.dart';
import 'package:zup_app/core/zup_links.dart';
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
  late Cache cache;
  late UniswapV3Pool uniswapV3pool;
  late Erc20 erc20;
  late TokensRepository tokensRepository;
  late ZupHolder zupHolder;
  late PoolService poolService;
  late UniswapPermit2 permit2;

  setUp(() async {
    await Web3Kit.initializeForTest();
    await inject.unregister<Wallet>();
    UrlLauncherPlatform.instance = UrlLauncherPlatformCustomMock();

    cubit = DepositCubitMock();
    wallet = WalletMock();
    navigator = ZupNavigatorMock();
    appCubit = AppCubitMock();
    uniswapV3pool = UniswapV3PoolMock();
    erc20 = Erc20Mock();
    cache = CacheMock();
    tokensRepository = TokensRepositoryMock();
    zupHolder = ZupHolder();
    poolService = PoolServiceMock();
    permit2 = UniswapPermit2Mock();

    registerFallbackValue(BuildContextMock());
    registerFallbackValue(AppNetworks.sepolia);
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

    inject.registerFactory<Cache>(() => cache);
    inject.registerFactory<ZupAnalytics>(() => ZupAnalyticsMock());
    inject.registerFactory<ZupLinks>(() => ZupLinksMock());
    inject.registerFactory<GlobalKey<NavigatorState>>(() => GlobalKey());
    inject.registerFactory<ZupNavigator>(() => navigator);
    inject.registerFactory<Wallet>(() => wallet);
    inject.registerFactory<ZupCachedImage>(() => mockZupCachedImage());
    inject.registerFactory<AppCubit>(() => appCubit);
    inject.registerFactory<ZupSingletonCache>(() => ZupSingletonCache.shared);
    inject.registerFactory<GlobalKey<ScaffoldMessengerState>>(() => GlobalKey());
    inject.registerFactory<UniswapV3Pool>(() => uniswapV3pool);
    inject.registerFactory<Erc20>(() => erc20);
    inject.registerFactory<UniswapV3PositionManager>(() => UniswapV3PositionManagerMock());
    inject.registerFactory<TokensRepository>(() => tokensRepository);
    inject.registerFactory<ZupHolder>(() => zupHolder);
    inject.registerFactory<PoolService>(() => poolService);
    inject.registerFactory<UniswapPermit2>(() => permit2);

    when(() => tokensRepository.getTokenPrice(any(), any())).thenAnswer((_) async => TokenPriceDto.fixture());
    when(() => cubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => cubit.state).thenAnswer((_) => const DepositState.initial());
    when(() => cubit.getBestPools(
          token0AddressOrId: any(named: "token0AddressOrId"),
          token1AddressOrId: any(named: "token1AddressOrId"),
          ignoreMinLiquidity: any(named: "ignoreMinLiquidity"),
        )).thenAnswer((_) async {});
    when(() => cache.getPoolSearchSettings()).thenReturn(PoolSearchSettingsDto.fixture());
    when(() => cubit.selectedYieldStream).thenAnswer((_) => const Stream.empty());
    when(() => appCubit.selectedNetwork).thenReturn(AppNetworks.sepolia);
    when(() => cubit.poolTickStream).thenAnswer((_) => const Stream.empty());
    when(() => cubit.latestPoolTick).thenAnswer((_) => BigInt.from(32523672));
    when(() => wallet.signerStream).thenAnswer((_) => const Stream.empty());
    when(() => wallet.signer).thenReturn(null);
    when(() => cubit.saveDepositSettings(any(), any())).thenAnswer((_) async => ());
    when(() => cubit.depositSettings).thenReturn(DepositSettingsDto.fixture());
    when(() => cubit.poolSearchSettings).thenReturn(PoolSearchSettingsDto.fixture());
    when(() => cubit.selectedYieldTimeframe).thenReturn(YieldTimeFrame.day);
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
      await tester.pumpAndSettle();
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
      await tester.pumpAndSettle();
    });

    verify(
      () => cubit.getBestPools(
        token0AddressOrId: token0Address,
        token1AddressOrId: token1Address,
      ),
    ).called(1);
  });

  zGoldenTest("When the cubit state is loading it should show the loading state",
      goldenFileName: "deposit_page_loading", (tester) async {
    when(() => cubit.state).thenReturn(const DepositState.loading());

    await tester.runAsync(() async {
      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.pumpAndSettle();
    });

    await tester.pumpAndSettle();
  });

  zGoldenTest("When the cubit state is noYields with no min liquidity searched, it should just show the noYields state",
      goldenFileName: "deposit_page_no_yields", (tester) async {
    when(() => cubit.state).thenReturn(
      const DepositState.noYields(
        filtersApplied: PoolSearchFiltersDto(minTvlUsd: 0),
      ),
    );

    await tester.pumpDeviceBuilder(await goldenBuilder());
    await tester.pumpAndSettle();

    await tester.pumpAndSettle();
  });

  zGoldenTest(
    """When the cubit state is noYields and the search had a min liquidity set, it should show the noYields state
    with a helper text saying it, and a button to search all pools""",
    goldenFileName: "deposit_page_no_yields_filtered_by_min_liquidity",
    (tester) async {
      when(() => cubit.state).thenReturn(
        const DepositState.noYields(
          filtersApplied: PoolSearchFiltersDto(minTvlUsd: 97654),
        ),
      );

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.pumpAndSettle();

      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    "When clicking the helper button in the no yields state, to search all pools, it should call the cubit to search all pools",
    (tester) async {
      when(
        () => cubit.getBestPools(
            token0AddressOrId: any(named: "token0AddressOrId"),
            token1AddressOrId: any(named: "token1AddressOrId"),
            ignoreMinLiquidity: any(named: "ignoreMinLiquidity")),
      ).thenAnswer((_) async {});

      when(() => cubit.state).thenReturn(
        const DepositState.noYields(
          filtersApplied: PoolSearchFiltersDto(minTvlUsd: 97654),
        ),
      );

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("search-all-pools-button")));
      await tester.pumpAndSettle();

      verify(
        () => cubit.getBestPools(
          token0AddressOrId: any(named: "token0AddressOrId"),
          token1AddressOrId: any(named: "token1AddressOrId"),
          ignoreMinLiquidity: true,
        ),
      ).called(1);
    },
  );

  zGoldenTest("""When clicking the helper button in the no yields state,
   it should navigate back to choose tokens stage""", (tester) async {
    when(() => navigator.navigateToNewPosition()).thenAnswer((_) async {});

    when(() => cubit.state).thenReturn(const DepositState.noYields(filtersApplied: PoolSearchFiltersDto()));

    await tester.pumpDeviceBuilder(await goldenBuilder());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key("help-button")));
    await tester.pumpAndSettle();

    verify(() => navigator.navigateToNewPosition()).called(1);
  });

  zGoldenTest("When the cubit state is error, it should show the error state", goldenFileName: "deposit_page_error",
      (tester) async {
    when(() => cubit.state).thenReturn(const DepositState.error());

    await tester.pumpDeviceBuilder(await goldenBuilder());
    await tester.pumpAndSettle();

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
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key("help-button")));
    await tester.pumpAndSettle();

    verify(() => cubit.getBestPools(token0AddressOrId: token0Address, token1AddressOrId: token1Address))
        .called(2); // 2 because of the initial call
  });

  zGoldenTest("When the state is sucess, it should show the success state", goldenFileName: "deposit_page_success",
      (tester) async {
    final yields = YieldsDto.fixture();

    when(() => cubit.state).thenReturn(DepositState.success(yields));

    await tester.pumpDeviceBuilder(await goldenBuilder());
    await tester.pumpAndSettle();

    await tester.pumpAndSettle();
  });

  zGoldenTest("""When the state is success, and the minimum liquidity search config is more than 0,
      it should show a text about showing only pools with more than X(min) liquidity, and a button
      to search all pools""", goldenFileName: "deposit_page_success_filtered_by_min_liquidity", (tester) async {
    final yields = YieldsDto.fixture();
    when(() => cubit.poolSearchSettings).thenReturn(PoolSearchSettingsDto(minLiquidityUSD: 97654));
    when(() => cubit.state).thenReturn(DepositState.success(yields));

    await tester.pumpDeviceBuilder(await goldenBuilder());
    await tester.pumpAndSettle();

    await tester.pumpAndSettle();
  });

  zGoldenTest("""When the state is success, and the minimum liquidity search config is 0,
      it should not show a text about showing only pools with more than X(min) liquidity""",
      goldenFileName: "deposit_page_success_not_filtered_by_min_liquidity", (tester) async {
    final yields = YieldsDto.fixture();
    when(() => cubit.poolSearchSettings).thenReturn(PoolSearchSettingsDto(minLiquidityUSD: 0));
    when(() => cubit.state).thenReturn(DepositState.success(yields));

    await tester.pumpDeviceBuilder(await goldenBuilder());
    await tester.pumpAndSettle();

    await tester.pumpAndSettle();
  });

  zGoldenTest("""When the state is success, and the repository returns that the filter for mininum liquidity
    search has zero, but the user has a local filter set, it should show a text and a button to search only pools
    with the local filter amount set""",
      goldenFileName: "deposit_page_success_filtered_by_min_liquidity_local_filter_set", (tester) async {
    final yields = YieldsDto.fixture().copyWith(
      filters: const PoolSearchFiltersDto(minTvlUsd: 0),
    ); // api filter returns 0
    when(() => cubit.poolSearchSettings).thenReturn(PoolSearchSettingsDto(minLiquidityUSD: 2189)); // local filter set
    when(() => cubit.state).thenReturn(DepositState.success(yields));

    await tester.pumpDeviceBuilder(await goldenBuilder());
    await tester.pumpAndSettle();

    await tester.pumpAndSettle();
  });

  zGoldenTest("""When clicking in the button to search all pools in the success state
   that is with a filter for min liquidity, it should call the cubit to get pools with
   the ignore min liquidity flag""", (tester) async {
    final yields = YieldsDto.fixture().copyWith(
      filters: const PoolSearchFiltersDto(minTvlUsd: 12675),
    );

    when(() => cubit.poolSearchSettings).thenReturn(PoolSearchSettingsDto(minLiquidityUSD: 12675));
    when(() => cubit.state).thenReturn(DepositState.success(yields));
    when(() => cubit.getBestPools(
        token0AddressOrId: any(named: "token0AddressOrId"),
        token1AddressOrId: any(named: "token1AddressOrId"),
        ignoreMinLiquidity: any(named: "ignoreMinLiquidity"))).thenAnswer((_) async {});

    await tester.pumpDeviceBuilder(await goldenBuilder());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key("hide-show-all-pools-button")));
    await tester.pumpAndSettle();

    verify(
      () => cubit.getBestPools(
        token0AddressOrId: any(named: "token0AddressOrId"),
        token1AddressOrId: any(named: "token1AddressOrId"),
        ignoreMinLiquidity: true,
      ),
    ).called(1);
  });

  zGoldenTest("""When clicking in the button to search only pools with more than x amount in
   the success state that is without a filter for min liquidity, it should call the cubit to get pools with
   the min liquidity set to not be ignored""", (tester) async {
    final yields = YieldsDto.fixture().copyWith(
      filters: const PoolSearchFiltersDto(minTvlUsd: 0),
    ); // api filter returns 0

    when(() => cubit.poolSearchSettings).thenReturn(PoolSearchSettingsDto(minLiquidityUSD: 12675)); // local filter set
    when(() => cubit.state).thenReturn(DepositState.success(yields));
    when(() => cubit.getBestPools(
        token0AddressOrId: any(named: "token0AddressOrId"),
        token1AddressOrId: any(named: "token1AddressOrId"),
        ignoreMinLiquidity: any(named: "ignoreMinLiquidity"))).thenAnswer((_) async {});

    await tester.pumpDeviceBuilder(await goldenBuilder());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key("hide-show-all-pools-button")));
    await tester.pumpAndSettle();

    verify(
      () => cubit.getBestPools(
        token0AddressOrId: any(named: "token0AddressOrId"),
        token1AddressOrId: any(named: "token1AddressOrId"),
        ignoreMinLiquidity: false,
      ),
    ).called(2); // two calls, one when the page is loaded and one when the user clicks the button
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
      await tester.runAsync(() async {
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
        await tester.drag(find.byKey(const Key("deposit-settings-button")), const Offset(0, -500));
        await tester.pumpAndSettle();

        await tester.pumpAndSettle();
      });
    },
  );

  zGoldenTest("When clicking back in the success state, it should navigate to the choose tokens page", (tester) async {
    when(() => navigator.navigateToNewPosition()).thenAnswer((_) async {});

    when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));

    await tester.pumpDeviceBuilder(await goldenBuilder());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key("back-button")));
    await tester.pumpAndSettle();

    verify(() => navigator.navigateToNewPosition()).called(1);
  });

  zGoldenTest("When hovering the title of the pool time frame section, it should show a tooltip explaining it",
      goldenFileName: "deposit_page_timeframe_tooltip", (tester) async {
    when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));

    await tester.pumpDeviceBuilder(await goldenBuilder());
    await tester.pumpAndSettle();

    await tester.hover(find.byKey(const Key("timeframe-tooltip")));
    await tester.pumpAndSettle();
  });

  zGoldenTest(
      "When clicking learn more in the pool time frame tooltip, it should launch the Zup blog page explaining it",
      (tester) async {
    when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));

    await tester.pumpDeviceBuilder(await goldenBuilder());
    await tester.pumpAndSettle();

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
    await tester.runAsync(() async {
      final yields = YieldsDto.fixture();
      final selectedYield = yields.best24hYield;

      when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
      when(() => cubit.selectedYield).thenReturn(selectedYield);
      when(() => cubit.state).thenReturn(DepositState.success(yields));

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();
    });
  });

  zGoldenTest("When selecting a yield, it should call select yield in the cubit", (tester) async {
    when(() => cubit.selectYield(any(), any())).thenAnswer((_) async {});
    when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));

    await tester.pumpDeviceBuilder(await goldenBuilder());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key("yield-card-24h")));
    await tester.pumpAndSettle();

    verify(() => cubit.selectYield(any(), any())).called(1);
  });

  zGoldenTest("When selecting a yield, it should scroll down to the range section",
      goldenFileName: "deposit_page_select_yield_scroll", (tester) async {
    await tester.runAsync(() async {
      final selectedYield = YieldsDto.fixture().best24hYield;
      when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
      when(() => cubit.selectedYield).thenReturn(null);
      when(() => cubit.selectYield(any(), any())).thenAnswer((_) async {});
      when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
      when(() => cubit.selectedYield).thenReturn(selectedYield);

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("yield-card-30d")));
      await tester.pumpAndSettle();

      verify(() => cubit.selectYield(any(), any())).called(1);
    });
  });

  zGoldenTest(
      "When clicking the segmented control to switch the base token to quote token, it should reverse the tokens",
      goldenFileName: "deposit_page_reverse_tokens", (tester) async {
    await tester.runAsync(() async {
      final selectedYield = YieldsDto.fixture().best24hYield;

      when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
      when(() => cubit.selectedYield).thenReturn(selectedYield);
      when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("reverse-tokens-reversed")));
      await tester.pumpAndSettle();
    });
  });

  zGoldenTest(
      "When clicking the segmented control to switch back to base token, after reversing the tokens, it should reverse again",
      goldenFileName: "deposit_page_reverse_tokens_back", (tester) async {
    await tester.runAsync(() async {
      final selectedYield = YieldsDto.fixture().best24hYield;

      when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
      when(() => cubit.selectedYield).thenReturn(selectedYield);
      when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("reverse-tokens-reversed")));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("reverse-tokens-not-reversed")));
      await tester.pumpAndSettle();
    });
  });

  zGoldenTest(
      "When clicking the segmented control to switch back to base token, after reversing the tokens, it should reverse again",
      goldenFileName: "deposit_page_reverse_tokens_back", (tester) async {
    await tester.runAsync(() async {
      final selectedYield = YieldsDto.fixture().best24hYield;

      when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
      when(() => cubit.selectedYield).thenReturn(selectedYield);
      when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("reverse-tokens-reversed")));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("reverse-tokens-not-reversed")));
      await tester.pumpAndSettle();
    });
  });

  zGoldenTest("""When emitting an event to the tick stream,
      it should calculate the price of the selected yield assets""", goldenFileName: "deposit_page_calculate_price",
      (tester) async {
    await tester.runAsync(() async {
      final selectedYield = YieldsDto.fixture().best24hYield;

      when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
      when(() => cubit.selectedYield).thenReturn(selectedYield);
      when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
      when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(BigInt.from(174072)));

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();
    });
  });

  zGoldenTest(
      "When reversing the tokens, it should calculate the price based on the reversed tokens, from a given tick in the cubit",
      goldenFileName: "deposit_page_calculate_price_reversed", (tester) async {
    await tester.runAsync(() async {
      final selectedYield = YieldsDto.fixture().best24hYield;

      when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
      when(() => cubit.selectedYield).thenReturn(selectedYield);
      when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
      when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(BigInt.from(174072)));

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("reverse-tokens-reversed")));
      await tester.pumpAndSettle();
    });
  });

  zGoldenTest(
    "When typing a min price more than the current price, it should show an alert saying that is out of range",
    goldenFileName: "deposit_page_min_price_out_of_range",
    (tester) async {
      await tester.runAsync(() async {
        final selectedYield = YieldsDto.fixture().best24hYield;
        final currentPriceAsTick = BigInt.from(174072);

        when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
        when(() => cubit.selectedYield).thenReturn(selectedYield);
        when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
        when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
        when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

        await tester.pumpDeviceBuilder(await goldenBuilder());
        await tester.pumpAndSettle();

        await tester.enterText(find.byKey(const Key("min-price-selector")), "1000");
        FocusManager.instance.primaryFocus?.unfocus();

        await tester.pumpAndSettle();
      });
    },
  );

  zGoldenTest(
    """When typing a min price more than the current price,
     it should show an alert saying that is out of range. 
     If the user reverse the tokens, and in the reversed state
     is not out of range, it should not show the alert""",
    goldenFileName: "deposit_page_min_price_out_of_range_reversed_in_range",
    (tester) async {
      await tester.runAsync(() async {
        final selectedYield = YieldsDto.fixture().best24hYield;
        final currentPriceAsTick = BigInt.from(174072);

        when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
        when(() => cubit.selectedYield).thenReturn(selectedYield);
        when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
        when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
        when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

        await tester.pumpDeviceBuilder(await goldenBuilder());
        await tester.pumpAndSettle();

        await tester.enterText(find.byKey(const Key("min-price-selector")), "1000");
        FocusManager.instance.primaryFocus?.unfocus();

        await tester.tap(find.byKey(const Key("reverse-tokens-reversed")));
        await tester.pumpAndSettle();
      });
    },
  );

  zGoldenTest(
    """When typing a min price more than the current price,
     it should show an alert saying that is out of range. 
     If the user reverse the tokens, and in the reversed state
     is is still out of range, it should keep showing the alert""",
    goldenFileName: "deposit_page_min_price_out_of_range_reversed",
    (tester) async {
      await tester.runAsync(() async {
        final selectedYield = YieldsDto.fixture().best24hYield;
        final currentPriceAsTick = BigInt.from(174072);

        when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
        when(() => cubit.selectedYield).thenReturn(selectedYield);
        when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
        when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
        when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

        await tester.pumpDeviceBuilder(await goldenBuilder());
        await tester.pumpAndSettle();

        await tester.enterText(find.byKey(const Key("min-price-selector")), "90000000000");
        FocusManager.instance.primaryFocus?.unfocus();

        await tester.tap(find.byKey(const Key("reverse-tokens-reversed")));
        await tester.pumpAndSettle();
      });
    },
  );

  zGoldenTest("When typing a max price less than the min price, it should show an error message",
      goldenFileName: "deposit_page_max_price_less_than_min_price", (tester) async {
    await tester.runAsync(() async {
      final selectedYield = YieldsDto.fixture().best24hYield;
      final currentPriceAsTick = BigInt.from(174072);

      when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
      when(() => cubit.selectedYield).thenReturn(selectedYield);
      when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
      when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
      when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key("min-price-selector")), "1200");
      FocusManager.instance.primaryFocus?.unfocus();

      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key("max-price-selector")), "1000");
      FocusManager.instance.primaryFocus?.unfocus();

      await tester.pumpAndSettle();
    });
  });

  zGoldenTest("""When typing a max price lower than the current price
  but higher than min price, it shouw show a alert of out of range""",
      goldenFileName: "deposit_page_max_price_out_of_range", (tester) async {
    await tester.runAsync(() async {
      final selectedYield = YieldsDto.fixture().best24hYield;
      final currentPriceAsTick = BigInt.from(174072);

      when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
      when(() => cubit.selectedYield).thenReturn(selectedYield);
      when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
      when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
      when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key("min-price-selector")), "0.000000001");
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key("max-price-selector")), "0.0000001");
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
    });
  });

  zGoldenTest("When typing 0 in the max price, it should set it to infinity max price",
      goldenFileName: "deposit_page_max_price_set_to_infinity", (tester) async {
    await tester.runAsync(() async {
      final selectedYield = YieldsDto.fixture().best24hYield;
      final currentPriceAsTick = BigInt.from(174072);

      when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
      when(() => cubit.selectedYield).thenReturn(selectedYield);
      when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
      when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
      when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key("min-price-selector")), "1");
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key("max-price-selector")), "2");
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key("max-price-selector")), "");
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key("max-price-selector")), "0");
      FocusManager.instance.primaryFocus?.unfocus();

      await tester.pumpAndSettle();
    });
  });

  zGoldenTest("When typing a min price, but then selecting the full range button, it should set it to 0",
      goldenFileName: "deposit_page_min_price_set_to_full_range", (tester) async {
    await tester.runAsync(() async {
      final selectedYield = YieldsDto.fixture().best24hYield;
      final currentPriceAsTick = BigInt.from(174072);

      when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
      when(() => cubit.selectedYield).thenReturn(selectedYield);
      when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
      when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
      when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key("min-price-selector")), "1");
      FocusManager.instance.primaryFocus?.unfocus();

      await tester.tap(find.byKey(const Key("full-range-button")));
      await tester.pumpAndSettle();
    });
  });

  zGoldenTest(
      "When clicking the 5% range button and then clicking the full range button, it should set it to full range",
      goldenFileName: "deposit_page_5_percent_set_to_full_range", (tester) async {
    await tester.runAsync(() async {
      final selectedYield = YieldsDto.fixture().best24hYield;
      final currentPriceAsTick = BigInt.from(174072);

      when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
      when(() => cubit.selectedYield).thenReturn(selectedYield);
      when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
      when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
      when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("5-percent-range-button")));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("full-range-button")));
      await tester.pumpAndSettle();
    });
  });

  zGoldenTest("""When clicking the 5% range button and then clicking the full range button,
      it should set it to full range. And when clicking to reverse tokens, it should
      keep the full range selected""", goldenFileName: "deposit_page_5_percent_set_to_full_range_reverse_tokens",
      (tester) async {
    await tester.runAsync(() async {
      final selectedYield = YieldsDto.fixture().best24hYield;
      final currentPriceAsTick = BigInt.from(174072);

      when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
      when(() => cubit.selectedYield).thenReturn(selectedYield);
      when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
      when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
      when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("5-percent-range-button")));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("full-range-button")));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("reverse-tokens-reversed")));
      await tester.pumpAndSettle();
    });
  });

  zGoldenTest("""When clicking the 5% range button, it should set 5% up
  and 5% down of the current price for the min and max prices""", goldenFileName: "deposit_page_set_5_percent_range",
      (tester) async {
    await tester.runAsync(() async {
      final selectedYield = YieldsDto.fixture().best24hYield;
      final currentPriceAsTick = BigInt.from(174072);

      when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
      when(() => cubit.selectedYield).thenReturn(selectedYield);
      when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
      when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
      when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("5-percent-range-button")));
      await tester.pumpAndSettle();
    });
  });

  zGoldenTest("""When clicking the 5% range button, it should set 5% up
  and 5% down of the current price for the min and max prices. And when
  clicking to reverse tokens, it should keep the 5% range selected but
  now with the reverse tokens range ratio""", goldenFileName: "deposit_page_set_5_percent_range_reverse_tokens",
      (tester) async {
    await tester.runAsync(() async {
      final selectedYield = YieldsDto.fixture().best24hYield;
      final currentPriceAsTick = BigInt.from(174072);

      when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
      when(() => cubit.selectedYield).thenReturn(selectedYield);
      when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
      when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
      when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("5-percent-range-button")));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("reverse-tokens-reversed")));
      await tester.pumpAndSettle();
    });
  });

  zGoldenTest("""When clicking the 20% range button, it should set 20% up
  and 20% down of the current price for the min and max prices""", goldenFileName: "deposit_page_set_20_percent_range",
      (tester) async {
    await tester.runAsync(() async {
      final selectedYield = YieldsDto.fixture().best24hYield;
      final currentPriceAsTick = BigInt.from(174072);

      when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
      when(() => cubit.selectedYield).thenReturn(selectedYield);
      when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
      when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
      when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("20-percent-range-button")));
      await tester.pumpAndSettle();
    });
  });

  zGoldenTest("""When clicking the 20% range button, it should set 20% up
  and 20% down of the current price for the min and max prices. And when
  clicking to reverse tokens, it should keep the 20% range selected but
  now with the reverse tokens range ratio""", goldenFileName: "deposit_page_set_20_percent_range_reverse_tokens",
      (tester) async {
    await tester.runAsync(() async {
      final selectedYield = YieldsDto.fixture().best24hYield;
      final currentPriceAsTick = BigInt.from(174072);

      when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
      when(() => cubit.selectedYield).thenReturn(selectedYield);
      when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
      when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
      when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("20-percent-range-button")));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("reverse-tokens-reversed")));
      await tester.pumpAndSettle();
    });
  });

  zGoldenTest("""When clicking the 50% range button, it should set 50% up
  and 50% down of the current price for the min and max prices""", goldenFileName: "deposit_page_set_50_percent_range",
      (tester) async {
    await tester.runAsync(() async {
      final selectedYield = YieldsDto.fixture().best24hYield;
      final currentPriceAsTick = BigInt.from(174072);

      when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
      when(() => cubit.selectedYield).thenReturn(selectedYield);
      when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
      when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
      when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("50-percent-range-button")));
      await tester.pumpAndSettle();
    });
  });

  zGoldenTest("""When clicking the 50% range button, it should set 50% up
  and 50% down of the current price for the min and max prices. And when
  clicking to reverse tokens, it should keep the 50% range selected but
  now with the reverse tokens range ratio""", goldenFileName: "deposit_page_set_50_percent_range_reverse_tokens",
      (tester) async {
    await tester.runAsync(() async {
      final selectedYield = YieldsDto.fixture().best24hYield;
      final currentPriceAsTick = BigInt.from(174072);

      when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
      when(() => cubit.selectedYield).thenReturn(selectedYield);
      when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
      when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
      when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("50-percent-range-button")));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("reverse-tokens-reversed")));
      await tester.pumpAndSettle();
    });
  });

  zGoldenTest("When typing a max price, but then selecting the full range button, it should set it to infinity",
      goldenFileName: "deposit_page_max_price_set_to_full_range", (tester) async {
    await tester.runAsync(() async {
      final selectedYield = YieldsDto.fixture().best24hYield;
      final currentPriceAsTick = BigInt.from(174072);

      when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
      when(() => cubit.selectedYield).thenReturn(selectedYield);
      when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
      when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
      when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key("max-price-selector")), "1");
      FocusManager.instance.primaryFocus?.unfocus();

      await tester.tap(find.byKey(const Key("full-range-button")));
      await tester.pumpAndSettle();
    });
  });

  zGoldenTest("""When clicking the percentage range button,but then typing a custom max price,
      and reversing tokens, it should keep the typed max price. And the min price should be the
      one from the percentage range""",
      goldenFileName: "deposit_page_set_percentage_range_then_type_max_price_reverse_tokens", (tester) async {
    await tester.runAsync(() async {
      final selectedYield = YieldsDto.fixture().best24hYield;
      final currentPriceAsTick = BigInt.from(174072);

      when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
      when(() => cubit.selectedYield).thenReturn(selectedYield);
      when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
      when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
      when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("50-percent-range-button")));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key("max-price-selector")), "1");
      FocusManager.instance.primaryFocus?.unfocus();

      await tester.tap(find.byKey(const Key("reverse-tokens-reversed")));
      await tester.pumpAndSettle();
    });
  });

  zGoldenTest("""When clicking the percentage range button,but then typing a custom min price,
      and reversing tokens, it should keep the typed min price and the max price should be the
      one from the percentage range""",
      goldenFileName: "deposit_page_set_percentage_range_then_type_min_price_reverse_tokens", (tester) async {
    await tester.runAsync(() async {
      final selectedYield = YieldsDto.fixture().best24hYield;
      final currentPriceAsTick = BigInt.from(174072);

      when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
      when(() => cubit.selectedYield).thenReturn(selectedYield);
      when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
      when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
      when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("50-percent-range-button")));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key("min-price-selector")), "1216");
      FocusManager.instance.primaryFocus?.unfocus();

      await tester.tap(find.byKey(const Key("reverse-tokens-reversed")));
      await tester.pumpAndSettle();
    });
  });

  zGoldenTest("""When typing a min and max price and then clicking the full range button,
   it should set the min price to 0 and the max price to infinity""",
      goldenFileName: "deposit_page_min_and_max_price_set_to_full_range", (tester) async {
    await tester.runAsync(() async {
      final selectedYield = YieldsDto.fixture().best24hYield;
      final currentPriceAsTick = BigInt.from(174072);

      when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
      when(() => cubit.selectedYield).thenReturn(selectedYield);
      when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
      when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
      when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key("min-price-selector")), "1");
      FocusManager.instance.primaryFocus?.unfocus();

      await tester.enterText(find.byKey(const Key("max-price-selector")), "2");
      FocusManager.instance.primaryFocus?.unfocus();

      await tester.tap(find.byKey(const Key("full-range-button")));
      await tester.pumpAndSettle();
    });
  });

  zGoldenTest(
      "When there's a invalid range, the deposit section should be disabled (with opacity) and cannot be clicked or typed",
      goldenFileName: "deposit_page_invalid_range_deposit_section", (tester) async {
    await tester.runAsync(() async {
      final selectedYield = YieldsDto.fixture().best24hYield;
      final currentPriceAsTick = BigInt.from(174072);

      when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
      when(() => cubit.selectedYield).thenReturn(selectedYield);
      when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
      when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
      when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key("min-price-selector")), "2");
      FocusManager.instance.primaryFocus?.unfocus();

      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key("max-price-selector")), "1");
      FocusManager.instance.primaryFocus?.unfocus();

      await tester.drag(find.byKey(const Key("deposit-settings-button")), const Offset(0, -500));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key("deposit-button")));
      await tester.pumpAndSettle();
    });
  });

  zGoldenTest(
    "When inputing the base token amount, the quote amount token should be automatically calculated",
    goldenFileName: "deposit_page_input_base_token_amount",
    (tester) async {
      await tester.runAsync(() async {
        final selectedYield = YieldsDto.fixture().best24hYield;
        final currentPriceAsTick = BigInt.from(174072);

        when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
        when(() => cubit.selectedYield).thenReturn(selectedYield);
        when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
        when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
        when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

        await tester.pumpDeviceBuilder(await goldenBuilder());
        await tester.pumpAndSettle();
        await tester.drag(find.byKey(const Key("deposit-section")), const Offset(0, -500));
        await tester.pumpAndSettle();

        await tester.enterText(find.byKey(const Key("base-token-input-card")), "1");
        await tester.pumpAndSettle();
      });
    },
  );

  zGoldenTest(
    "When inputing the quote token amount, the base amount token should be automatically calculated",
    goldenFileName: "deposit_page_input_quote_token_amount",
    (tester) async {
      await tester.runAsync(() async {
        final selectedYield = YieldsDto.fixture().best24hYield;
        final currentPriceAsTick = BigInt.from(174072);

        when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
        when(() => cubit.selectedYield).thenReturn(selectedYield);
        when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
        when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
        when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

        await tester.pumpDeviceBuilder(await goldenBuilder());
        await tester.pumpAndSettle();
        await tester.drag(find.byKey(const Key("deposit-section")), const Offset(0, -500));
        await tester.pumpAndSettle();

        await tester.enterText(find.byKey(const Key("quote-token-input-card")), "1");
        await tester.pumpAndSettle();
      });
    },
  );

  zGoldenTest(
    """When inputing the base token, then reversing the tokens,
    the quote token then should be the same as the previous base token,
    and the new base token amount should be automatically calculated""",
    goldenFileName: "deposit_page_input_base_token_amount_and_reverse",
    (tester) async {
      await tester.runAsync(() async {
        final selectedYield = YieldsDto.fixture().best24hYield;
        final currentPriceAsTick = BigInt.from(174072);

        when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
        when(() => cubit.selectedYield).thenReturn(selectedYield);
        when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
        when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
        when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

        await tester.pumpDeviceBuilder(await goldenBuilder());
        await tester.pumpAndSettle();
        await tester.drag(find.byKey(const Key("deposit-section")), const Offset(0, -500));
        await tester.pumpAndSettle();

        await tester.enterText(find.byKey(const Key("base-token-input-card")), "1");
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key("reverse-tokens-reversed")));
        await tester.pumpAndSettle();
      });
    },
  );

  zGoldenTest(
    """When inputing the quote token, then reversing the tokens,
    the base token then should be the same as the previous quote token,
    and the new quote token amount should be automatically calculated""",
    goldenFileName: "deposit_page_input_quote_token_amount_and_reverse",
    (tester) async {
      await tester.runAsync(() async {
        final selectedYield = YieldsDto.fixture().best24hYield;
        final currentPriceAsTick = BigInt.from(174072);

        when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
        when(() => cubit.selectedYield).thenReturn(selectedYield);
        when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
        when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
        when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

        await tester.pumpDeviceBuilder(await goldenBuilder());
        await tester.pumpAndSettle();
        await tester.drag(find.byKey(const Key("deposit-section")), const Offset(0, -500));
        await tester.pumpAndSettle();

        await tester.enterText(find.byKey(const Key("quote-token-input-card")), "1");
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key("reverse-tokens-reversed")));
        await tester.pumpAndSettle();
      });
    },
  );

  zGoldenTest(
    """When inputing the base token amount with the tokens reversed, the quote token amount should be automatically calculated""",
    goldenFileName: "deposit_page_input_base_token_amount_reversed",
    (tester) async {
      await tester.runAsync(() async {
        final selectedYield = YieldsDto.fixture().best24hYield;
        final currentPriceAsTick = BigInt.from(174072);

        when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
        when(() => cubit.selectedYield).thenReturn(selectedYield);
        when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
        when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
        when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

        await tester.pumpDeviceBuilder(await goldenBuilder());
        await tester.pumpAndSettle();
        await tester.drag(find.byKey(const Key("deposit-section")), const Offset(0, -500));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key("reverse-tokens-reversed")));
        await tester.pumpAndSettle();

        await tester.enterText(find.byKey(const Key("base-token-input-card")), "1");
        await tester.pumpAndSettle();
      });
    },
  );

  zGoldenTest(
    """When inputing the quote token amount with the tokens reversed, the base token amount should be automatically calculated""",
    goldenFileName: "deposit_page_input_quote_token_amount_reversed",
    (tester) async {
      await tester.runAsync(() async {
        final selectedYield = YieldsDto.fixture().best24hYield;
        final currentPriceAsTick = BigInt.from(174072);

        when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
        when(() => cubit.selectedYield).thenReturn(selectedYield);
        when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
        when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
        when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

        await tester.pumpDeviceBuilder(await goldenBuilder());
        await tester.pumpAndSettle();
        await tester.drag(find.byKey(const Key("deposit-section")), const Offset(0, -500));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key("reverse-tokens-reversed")));
        await tester.pumpAndSettle();

        await tester.enterText(find.byKey(const Key("quote-token-input-card")), "1");
        await tester.pumpAndSettle();
      });
    },
  );

  zGoldenTest("""When inputing the base token amount with the tokens reversed,
   then turning them normal, the quote token amount should now be the 
   previous base token amount, and the new base token amount should be automatically calculated""",
      goldenFileName: "deposit_page_input_base_token_amount_and_reverse_back", (tester) async {
    await tester.runAsync(() async {
      final selectedYield = YieldsDto.fixture().best24hYield;
      final currentPriceAsTick = BigInt.from(174072);

      when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
      when(() => cubit.selectedYield).thenReturn(selectedYield);
      when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
      when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
      when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.pumpAndSettle();
      await tester.drag(find.byKey(const Key("deposit-section")), const Offset(0, -500));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("reverse-tokens-reversed")));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key("base-token-input-card")), "1");
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("reverse-tokens-not-reversed")));
      await tester.pumpAndSettle();
    });
  });

  zGoldenTest("""When inputing the quote token amount with the tokens reversed,
   then turning them normal, the base token amount should now be the 
   previous quote token amount, and the new quote token amount should be automatically calculated""",
      goldenFileName: "deposit_page_input_quote_token_amount_and_reverse_back", (tester) async {
    await tester.runAsync(() async {
      final selectedYield = YieldsDto.fixture().best24hYield;
      final currentPriceAsTick = BigInt.from(174072);

      when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
      when(() => cubit.selectedYield).thenReturn(selectedYield);
      when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
      when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
      when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.pumpAndSettle();
      await tester.drag(find.byKey(const Key("deposit-section")), const Offset(0, -500));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("reverse-tokens-reversed")));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key("quote-token-input-card")), "1");
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("reverse-tokens-not-reversed")));
      await tester.pumpAndSettle();
    });
  });

  zGoldenTest(
    "When inputing the base token amount, then changing the range, the quote token amount should be recalculated",
    goldenFileName: "deposit_page_input_base_token_amount_and_change_range",
    (tester) async {
      await tester.runAsync(() async {
        final selectedYield = YieldsDto.fixture().best24hYield;
        final currentPriceAsTick = BigInt.from(174072);

        when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
        when(() => cubit.selectedYield).thenReturn(selectedYield);
        when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
        when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
        when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

        await tester.pumpDeviceBuilder(await goldenBuilder());
        await tester.pumpAndSettle();
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
        await tester.pumpAndSettle();
      });
    },
  );

  zGoldenTest(
    "When inputing the quote token amount, then changing the range, the base token amount should be recalculated",
    goldenFileName: "deposit_page_input_quote_token_amount_and_change_range",
    (tester) async {
      await tester.runAsync(() async {
        final selectedYield = YieldsDto.fixture().best24hYield;
        final currentPriceAsTick = BigInt.from(174072);

        when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
        when(() => cubit.selectedYield).thenReturn(selectedYield);
        when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
        when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
        when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

        await tester.pumpDeviceBuilder(await goldenBuilder());
        await tester.pumpAndSettle();
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
        await tester.pumpAndSettle();
      });
    },
  );

  zGoldenTest(
      "When inputing the base token amount, reversing the tokens and then changing the range, the base token amount should be recalculated",
      goldenFileName: "deposit_page_input_base_token_amount_reverse_tokens_and_change_range", (tester) async {
    await tester.runAsync(() async {
      final selectedYield = YieldsDto.fixture().best24hYield;
      final currentPriceAsTick = BigInt.from(174072);

      when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
      when(() => cubit.selectedYield).thenReturn(selectedYield);
      when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
      when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
      when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.pumpAndSettle();
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
      await tester.pumpAndSettle();
    });
  });

  zGoldenTest(
      "When inputing the quote token amount, reversing the tokens and then changing the range, the quote token amount should be recalculated",
      goldenFileName: "deposit_page_input_quote_token_amount_reverse_tokens_and_change_range", (tester) async {
    await tester.runAsync(() async {
      final selectedYield = YieldsDto.fixture().best24hYield;
      final currentPriceAsTick = BigInt.from(174072);

      when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
      when(() => cubit.selectedYield).thenReturn(selectedYield);
      when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
      when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
      when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.pumpAndSettle();
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
      await tester.pumpAndSettle();
    });
  });

  zGoldenTest(
    "When inputing a range, then inputing the base token amount, the quote token amount should be automatically calculated",
    goldenFileName: "deposit_page_input_range_then_input_base_token_amount",
    (tester) async {
      await tester.runAsync(() async {
        final selectedYield = YieldsDto.fixture().best24hYield;
        final currentPriceAsTick = BigInt.from(174072);

        when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
        when(() => cubit.selectedYield).thenReturn(selectedYield);
        when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
        when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
        when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

        await tester.pumpDeviceBuilder(await goldenBuilder());
        await tester.pumpAndSettle();
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
        await tester.pumpAndSettle();
      });
    },
  );

  zGoldenTest(
    "When inputing a range, then inputing the quote token amount, the base token amount should be automatically calculated",
    goldenFileName: "deposit_page_input_range_then_input_quote_token_amount",
    (tester) async {
      await tester.runAsync(() async {
        final selectedYield = YieldsDto.fixture().best24hYield;
        final currentPriceAsTick = BigInt.from(174072);

        when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
        when(() => cubit.selectedYield).thenReturn(selectedYield);
        when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
        when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
        when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

        await tester.pumpDeviceBuilder(await goldenBuilder());
        await tester.pumpAndSettle();
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
      });
    },
  );

  zGoldenTest(
    "When inputing a range,reversing the tokens, then inputing the base token amount, the quote token amount should be automatically calculated",
    goldenFileName: "deposit_page_input_range_then_reverse_tokens_then_input_base_token_amount",
    (tester) async {
      await tester.runAsync(() async {
        final selectedYield = YieldsDto.fixture().best24hYield;
        final currentPriceAsTick = BigInt.from(174072);

        when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
        when(() => cubit.selectedYield).thenReturn(selectedYield);
        when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
        when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
        when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

        await tester.pumpDeviceBuilder(await goldenBuilder());
        await tester.pumpAndSettle();
        await tester.drag(find.byKey(const Key("deposit-section")), const Offset(0, -500));
        await tester.pumpAndSettle();

        await tester.enterText(find.byKey(const Key("min-price-selector")), "1200");
        await tester.pumpAndSettle();

        await tester.enterText(find.byKey(const Key("max-price-selector")), "0");
        await tester.pumpAndSettle();

        await tester.enterText(find.byKey(const Key("max-price-selector")), "90000");
        await tester.pumpAndSettle();

        FocusManager.instance.primaryFocus?.unfocus(); // unfocus the fields to calculate the valid price
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key("reverse-tokens-reversed")));
        await tester.pumpAndSettle();

        await tester.enterText(find.byKey(const Key("base-token-input-card")), "1");
        await tester.pumpAndSettle();

        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pumpAndSettle();
      });
    },
  );

  zGoldenTest(
    "When inputing a range, reversing the tokens, then inputing the quote token amount, the base token amount should be automatically calculated",
    goldenFileName: "deposit_page_input_range_then_reverse_tokens_then_input_quote_token_amount",
    (tester) async {
      await tester.runAsync(() async {
        final selectedYield = YieldsDto.fixture().best24hYield;
        final currentPriceAsTick = BigInt.from(174072);

        when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
        when(() => cubit.selectedYield).thenReturn(selectedYield);
        when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
        when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
        when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

        await tester.pumpDeviceBuilder(await goldenBuilder());
        await tester.pumpAndSettle();
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
        await tester.pumpAndSettle();
      });
    },
  );

  zGoldenTest("""When inputing base token amount, and then setting a max price out of range,
       it should keep the quote token amount and disable the base token input""",
      goldenFileName: "deposit_page_input_base_token_amount_then_set_max_price_out_of_range", (tester) async {
    await tester.runAsync(() async {
      final selectedYield = YieldsDto.fixture().best24hYield;
      final currentPriceAsTick = BigInt.from(174072);

      when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
      when(() => cubit.selectedYield).thenReturn(selectedYield);
      when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
      when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
      when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.pumpAndSettle();
      await tester.drag(find.byKey(const Key("deposit-section")), const Offset(0, -500));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key("base-token-input-card")), "1");
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key("max-price-selector")), "0");
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key("max-price-selector")), "0.00000001");
      await tester.pumpAndSettle();

      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
    });
  });

  zGoldenTest("""When inputing quote token amount, and then setting a min price out of range,
       it should keep the base token amount and disable the quote token input""",
      goldenFileName: "deposit_page_input_quote_token_amount_then_set_min_price_out_of_range", (tester) async {
    await tester.runAsync(() async {
      final selectedYield = YieldsDto.fixture().best24hYield;
      final currentPriceAsTick = BigInt.from(174072);

      when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
      when(() => cubit.selectedYield).thenReturn(selectedYield);
      when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
      when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
      when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.pumpAndSettle();
      await tester.drag(find.byKey(const Key("deposit-section")), const Offset(0, -500));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key("quote-token-input-card")), "1");
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key("min-price-selector")), "2");
      await tester.pumpAndSettle();

      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
    });
  });

  zGoldenTest("""When inputing base token amount, reversing the tokens, and then setting a max price out of range,
       it should keep the quote token amount and disable the base token input""",
      goldenFileName: "deposit_page_input_base_token_amount_then_reverse_tokens_then_set_max_price_out_of_range",
      (tester) async {
    await tester.runAsync(() async {
      final selectedYield = YieldsDto.fixture().best24hYield;
      final currentPriceAsTick = BigInt.from(174072);

      when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
      when(() => cubit.selectedYield).thenReturn(selectedYield);
      when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
      when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
      when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.pumpAndSettle();
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
      await tester.pumpAndSettle();
    });
  });

  zGoldenTest("""When inputing quote token amount, reversing the tokens, and then setting a min price out of range,
       it should keep the base token amount and disable the quote token input""",
      goldenFileName: "deposit_page_input_quote_token_amount_then_reverse_tokens_then_set_min_price_out_of_range",
      (tester) async {
    await tester.runAsync(() async {
      final selectedYield = YieldsDto.fixture().best24hYield;
      final currentPriceAsTick = BigInt.from(174072);

      when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
      when(() => cubit.selectedYield).thenReturn(selectedYield);
      when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
      when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
      when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.pumpAndSettle();
      await tester.drag(find.byKey(const Key("deposit-section")), const Offset(0, -500));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key("quote-token-input-card")), "1");
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("reverse-tokens-reversed")));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key("min-price-selector")), "70000");
      await tester.pumpAndSettle();

      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
    });
  });

  zGoldenTest(
    "When the user is is not connected, it should show the connect wallet button instead of the deposit button",
    goldenFileName: "deposit_page_not_connected",
    (tester) async {
      await tester.runAsync(() async {
        final selectedYield = YieldsDto.fixture().best24hYield;
        final currentPriceAsTick = BigInt.from(174072);

        when(() => wallet.signer).thenReturn(null);
        when(() => wallet.signerStream).thenAnswer((_) => Stream.value(null));
        when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
        when(() => cubit.selectedYield).thenReturn(selectedYield);
        when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
        when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
        when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

        await tester.pumpDeviceBuilder(await goldenBuilder());
        await tester.pumpAndSettle();
        await tester.drag(find.byKey(const Key("deposit-section")), const Offset(0, -500));
        await tester.pumpAndSettle();
      });
    },
  );

  zGoldenTest(
    """When the user is is not connected,
    it should show the connect wallet button instead of the deposit button.
    When clicking the button, it should show the connect wallet modal
    """,
    goldenFileName: "deposit_page_not_connected_deposit_button_click",
    (tester) async {
      await tester.runAsync(() async {
        final selectedYield = YieldsDto.fixture().best24hYield;
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
      });
    },
  );

  zGoldenTest(
    """When the user is connected, but there's no amount to deposit typed,
    the deposit button should should be disabled""",
    goldenFileName: "deposit_page_no_amount_deposit_button",
    (tester) async {
      await tester.runAsync(() async {
        final selectedYield = YieldsDto.fixture().best24hYield;
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
        await tester.pumpAndSettle();
        await tester.drag(find.byKey(const Key("deposit-settings-button")), const Offset(0, -500));
        await tester.pumpAndSettle();
      });
    },
  );

  zGoldenTest(
    """When the user is connected, there's an amount to deposit typed,
    but the user doesn't have enough balance of base token,
    the deposit button should should be disabled""",
    goldenFileName: "deposit_page_not_enough_base_token_balance_deposit_button",
    (tester) async {
      await tester.runAsync(() async {
        final selectedYield = YieldsDto.fixture().best24hYield;
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
        await tester.pumpAndSettle();
        await tester.drag(find.byKey(const Key("deposit-settings-button")), const Offset(0, -500));
        await tester.pumpAndSettle();

        await tester.enterText(find.byKey(const Key("base-token-input-card")), "1");
        await tester.pumpAndSettle();
      });
    },
  );

  zGoldenTest(
    """When the user is connected, there's an amount to deposit typed,
    but the user doesn't have enough balance of quote token,
    the deposit button should should be disabled""",
    goldenFileName: "deposit_page_not_enough_quote_token_balance_deposit_button",
    (tester) async {
      await tester.runAsync(() async {
        final selectedYield = YieldsDto.fixture().best24hYield;
        final currentPriceAsTick = BigInt.from(174072);
        final signer = SignerMock();

        when(() => wallet.signer).thenReturn(signer);
        when(() => wallet.signerStream).thenAnswer((_) => Stream.value(signer));

        when(() => cubit.getWalletTokenAmount(selectedYield.token0.addresses[selectedYield.network.chainId]!,
            network: any(named: "network"))).thenAnswer(
          (_) => Future.value(32567352673),
        );
        when(() => cubit.getWalletTokenAmount(selectedYield.token1.addresses[selectedYield.network.chainId]!,
            network: any(named: "network"))).thenAnswer(
          (_) => Future.value(0),
        );
        when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
        when(() => cubit.selectedYield).thenReturn(selectedYield);
        when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
        when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
        when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

        await tester.pumpDeviceBuilder(await goldenBuilder());
        await tester.pumpAndSettle();
        await tester.drag(find.byKey(const Key("deposit-settings-button")), const Offset(0, -500));
        await tester.pumpAndSettle();

        await tester.enterText(find.byKey(const Key("quote-token-input-card")), "1");
        await tester.pumpAndSettle();
      });
    },
  );

  zGoldenTest(
    """When the user is not connected, type an amount to deposit, and then connect
    without having enough balance of base token, the deposit button should should be disabled""",
    goldenFileName: "deposit_page_not_enough_base_token_balance_deposit_button_after_connecting",
    (tester) async {
      await tester.runAsync(() async {
        final selectedYield = YieldsDto.fixture().best24hYield;
        final currentPriceAsTick = BigInt.from(174072);
        final signerStreamController = StreamController<Signer?>.broadcast();
        final signer = SignerMock();

        when(() => wallet.signer).thenReturn(null);
        when(() => wallet.signerStream).thenAnswer((_) => signerStreamController.stream);
        when(() => cubit.getWalletTokenAmount(selectedYield.token0.addresses[selectedYield.network.chainId]!,
            network: any(named: "network"))).thenAnswer(
          (_) => Future.value(0),
        );
        when(() => cubit.getWalletTokenAmount(selectedYield.token1.addresses[selectedYield.network.chainId]!,
            network: any(named: "network"))).thenAnswer(
          (_) => Future.value(0),
        );
        when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
        when(() => cubit.selectedYield).thenReturn(selectedYield);
        when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
        when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
        when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

        await tester.pumpDeviceBuilder(await goldenBuilder());
        await tester.pumpAndSettle();
        await tester.drag(find.byKey(const Key("deposit-settings-button")), const Offset(0, -500));
        await tester.pumpAndSettle();

        await tester.enterText(find.byKey(const Key("quote-token-input-card")), "1");
        await tester.pumpAndSettle();

        signerStreamController.add(signer);
        await tester.pumpAndSettle();
      });
    },
  );

  zGoldenTest(
    """When the user is not connected, type an amount to deposit, and then connect
    without having enough balance of quote token, the deposit button should should be disabled""",
    goldenFileName: "deposit_page_not_enough_quote_token_balance_deposit_button_after_connecting",
    (tester) async {
      await tester.runAsync(() async {
        final selectedYield = YieldsDto.fixture().best24hYield;
        final currentPriceAsTick = BigInt.from(174072);
        final signerStreamController = StreamController<Signer?>.broadcast();
        final signer = SignerMock();

        when(() => wallet.signer).thenReturn(null);
        when(() => wallet.signerStream).thenAnswer((_) => signerStreamController.stream);
        when(() => cubit.getWalletTokenAmount(selectedYield.token0.addresses[selectedYield.network.chainId]!,
            network: any(named: "network"))).thenAnswer(
          (_) => Future.value(347537253),
        );
        when(() => cubit.getWalletTokenAmount(selectedYield.token1.addresses[selectedYield.network.chainId]!,
            network: any(named: "network"))).thenAnswer(
          (_) => Future.value(0),
        );
        when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
        when(() => cubit.selectedYield).thenReturn(selectedYield);
        when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
        when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
        when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

        await tester.pumpDeviceBuilder(await goldenBuilder());
        await tester.pumpAndSettle();
        await tester.drag(find.byKey(const Key("deposit-section")), const Offset(0, -500));
        await tester.pumpAndSettle();

        await tester.enterText(find.byKey(const Key("quote-token-input-card")), "1");
        await tester.pumpAndSettle();

        signerStreamController.add(signer);
        await tester.pumpAndSettle();
      });
    },
  );

  zGoldenTest(
    """When the user is connected, type an amount to deposit, and have enough balance of both tokens
    the deposit button should be enabled""",
    goldenFileName: "deposit_page_enough_balance_deposit_button",
    (tester) async {
      await tester.runAsync(() async {
        final selectedYield = YieldsDto.fixture().best24hYield;
        final currentPriceAsTick = BigInt.from(174072);

        final signer = SignerMock();

        when(() => wallet.signer).thenReturn(signer);
        when(() => wallet.signerStream).thenAnswer((_) => Stream.value(signer));
        when(() => cubit.getWalletTokenAmount(selectedYield.token0.addresses[selectedYield.network.chainId]!,
            network: any(named: "network"))).thenAnswer(
          (_) => Future.value(347537253),
        );
        when(() => cubit.getWalletTokenAmount(selectedYield.token1.addresses[selectedYield.network.chainId]!,
            network: any(named: "network"))).thenAnswer(
          (_) => Future.value(32576352673),
        );
        when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
        when(() => cubit.selectedYield).thenReturn(selectedYield);
        when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
        when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
        when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

        await tester.pumpDeviceBuilder(await goldenBuilder());
        await tester.pumpAndSettle();
        await tester.drag(find.byKey(const Key("deposit-settings-button")), const Offset(0, -500));
        await tester.pumpAndSettle();

        await tester.enterText(find.byKey(const Key("quote-token-input-card")), "1");
        await tester.pumpAndSettle();
      });
    },
  );

  zGoldenTest("""When the min range is out of range, and the user does not have quote token balance
       but has enough balance of base token, the deposit button should be enabled""",
      goldenFileName: "deposit_page_min_range_out_of_range_deposit_button", (tester) async {
    await tester.runAsync(() async {
      final selectedYield = YieldsDto.fixture().best24hYield;
      final currentPriceAsTick = BigInt.from(174072);

      final signer = SignerMock();

      when(() => wallet.signer).thenReturn(signer);
      when(() => wallet.signerStream).thenAnswer((_) => Stream.value(signer));
      when(() => cubit.getWalletTokenAmount(selectedYield.token0.addresses[selectedYield.network.chainId]!,
          network: any(named: "network"))).thenAnswer(
        (_) => Future.value(347537253),
      );
      when(() => cubit.getWalletTokenAmount(selectedYield.token1.addresses[selectedYield.network.chainId]!,
          network: any(named: "network"))).thenAnswer(
        (_) => Future.value(0),
      );
      when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
      when(() => cubit.selectedYield).thenReturn(selectedYield);
      when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
      when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
      when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.pumpAndSettle();
      await tester.drag(find.byKey(const Key("deposit-settings-button")), const Offset(0, -500));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key("min-price-selector")), "1");
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key("base-token-input-card")), "1");
      await tester.pumpAndSettle();
    });
  });

  zGoldenTest("""When the max range is out of range, and the user does not have base token balance
       but has enough balance of quote token, the deposit button should be enabled""",
      goldenFileName: "deposit_page_max_range_out_of_range_deposit_button", (tester) async {
    await tester.runAsync(() async {
      final selectedYield = YieldsDto.fixture().best24hYield;
      final currentPriceAsTick = BigInt.from(174072);

      final signer = SignerMock();

      when(() => wallet.signer).thenReturn(signer);
      when(() => wallet.signerStream).thenAnswer((_) => Stream.value(signer));
      when(() => cubit.getWalletTokenAmount(selectedYield.token0.addresses[selectedYield.network.chainId]!,
          network: any(named: "network"))).thenAnswer(
        (_) => Future.value(0),
      );
      when(() => cubit.getWalletTokenAmount(selectedYield.token1.addresses[selectedYield.network.chainId]!,
          network: any(named: "network"))).thenAnswer(
        (_) => Future.value(3237526),
      );
      when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
      when(() => cubit.selectedYield).thenReturn(selectedYield);
      when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
      when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
      when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

      await tester.pumpDeviceBuilder(await goldenBuilder());
      await tester.pumpAndSettle();
      await tester.drag(find.byKey(const Key("deposit-settings-button")), const Offset(0, -500));
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
  });

  zGoldenTest("When clicking the enabled deposit button, it should show the preview modal of the deposit",
      goldenFileName: "deposit_page_preview_modal", (tester) async {
    await tester.runAsync(() async {
      final selectedYield = YieldsDto.fixture().best24hYield;
      final currentPriceAsTick = BigInt.from(174072);

      final signer = SignerMock();

      when(() => wallet.signer).thenReturn(signer);
      when(() => wallet.signerStream).thenAnswer((_) => Stream.value(signer));
      when(() => cubit.getWalletTokenAmount(selectedYield.token0.addresses[selectedYield.network.chainId]!,
          network: any(named: "network"))).thenAnswer(
        (_) => Future.value(347537253),
      );
      when(() => cubit.getWalletTokenAmount(selectedYield.token1.addresses[selectedYield.network.chainId]!,
          network: any(named: "network"))).thenAnswer(
        (_) => Future.value(32576352673),
      );
      when(() => cubit.selectYield(any(), any())).thenAnswer((_) => Future.value());
      when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
      when(() => cubit.selectedYield).thenReturn(selectedYield);
      when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
      when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
      when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

      await tester.pumpDeviceBuilder(await goldenBuilder(), wrapper: GoldenConfig.localizationsWrapper());
      await tester.tap(find.byKey(const Key("yield-card-24h")));
      await tester.pumpAndSettle();
      await tester.drag(find.byKey(const Key("deposit-settings-button")), const Offset(0, -500));
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
      await tester.runAsync(() async {
        final selectedYield = YieldsDto.fixture().best24hYield;

        when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
        when(() => cubit.selectedYield).thenReturn(selectedYield);
        when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
        when(() => cubit.poolTickStream).thenAnswer((_) => const Stream.empty());
        when(() => cubit.latestPoolTick).thenReturn(null);

        await tester.pumpDeviceBuilder(await goldenBuilder());
        await tester.pumpAndSettle();
        await tester.drag(find.byKey(const Key("deposit-section")), const Offset(0, -500));
        await tester.pumpAndSettle();

        await tester.enterText(find.byKey(const Key("base-token-input-card")), "1");
        await tester.pumpAndSettle();
      });
    },
  );

  zGoldenTest(
    """When the quote token amount input is not empty, and the pool tick is null,
  the base token input should be loading""",
    goldenFileName: "deposit_page_base_token_input_loading",
    (tester) async {
      await tester.runAsync(() async {
        final selectedYield = YieldsDto.fixture().best24hYield;

        when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
        when(() => cubit.selectedYield).thenReturn(selectedYield);
        when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
        when(() => cubit.poolTickStream).thenAnswer((_) => const Stream.empty());
        when(() => cubit.latestPoolTick).thenReturn(null);

        await tester.pumpDeviceBuilder(await goldenBuilder());
        await tester.pumpAndSettle();
        await tester.drag(find.byKey(const Key("deposit-section")), const Offset(0, -500));
        await tester.pumpAndSettle();

        await tester.enterText(find.byKey(const Key("quote-token-input-card")), "1");
        await tester.pumpAndSettle();
      });
    },
  );

  zGoldenTest(
    """When the quote token amount input is loading, and a non null pool tick
    is emitted, the quote token amount should be enabled
    """,
    goldenFileName: "deposit_page_quote_token_input_enabled_after_loading",
    (tester) async {
      await tester.runAsync(() async {
        final selectedYield = YieldsDto.fixture().best24hYield;

        when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
        when(() => cubit.selectedYield).thenReturn(selectedYield);
        when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
        when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(BigInt.from(2131)));
        when(() => cubit.latestPoolTick).thenReturn(null);

        await tester.pumpDeviceBuilder(await goldenBuilder());
        await tester.pumpAndSettle();
        await tester.drag(find.byKey(const Key("deposit-section")), const Offset(0, -500));
        await tester.pumpAndSettle();

        await tester.enterText(find.byKey(const Key("base-token-input-card")), "1");
        await tester.pumpAndSettle();
      });
    },
  );

  zGoldenTest(
    """When the base token amount input is loading, and a non null pool tick
    is emitted, the base token amount should be enabled
    """,
    goldenFileName: "deposit_page_base_token_input_enabled_after_loading",
    (tester) async {
      await tester.runAsync(() async {
        final selectedYield = YieldsDto.fixture().best24hYield;

        when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
        when(() => cubit.selectedYield).thenReturn(selectedYield);
        when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
        when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(BigInt.from(2131)));
        when(() => cubit.latestPoolTick).thenReturn(null);

        await tester.pumpDeviceBuilder(await goldenBuilder());
        await tester.pumpAndSettle();
        await tester.drag(find.byKey(const Key("deposit-section")), const Offset(0, -500));
        await tester.pumpAndSettle();

        await tester.enterText(find.byKey(const Key("quote-token-input-card")), "1");
        await tester.pumpAndSettle();
      });
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

      await tester.pumpDeviceBuilder(await goldenBuilder(), wrapper: GoldenConfig.localizationsWrapper());
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

      await tester.pumpDeviceBuilder(await goldenBuilder(), wrapper: GoldenConfig.localizationsWrapper());
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

      await tester.pumpDeviceBuilder(await goldenBuilder(), wrapper: GoldenConfig.localizationsWrapper());
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

      await tester.pumpDeviceBuilder(await goldenBuilder(), wrapper: GoldenConfig.localizationsWrapper());
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

      await tester.pumpDeviceBuilder(await goldenBuilder(), wrapper: GoldenConfig.localizationsWrapper());
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

      await tester.pumpDeviceBuilder(await goldenBuilder(), wrapper: GoldenConfig.localizationsWrapper());
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

      await tester.pumpDeviceBuilder(await goldenBuilder(), wrapper: GoldenConfig.localizationsWrapper());
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

      await tester.pumpDeviceBuilder(await goldenBuilder(), wrapper: GoldenConfig.localizationsWrapper());
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
        final selectedYield = YieldsDto.fixture().best24hYield;
        final currentPriceAsTick = BigInt.from(174072);

        final signer = SignerMock();

        when(() => wallet.signer).thenReturn(signer);
        when(() => wallet.signerStream).thenAnswer((_) => Stream.value(signer));
        when(() => cubit.getWalletTokenAmount(selectedYield.token0.addresses[selectedYield.network.chainId]!,
            network: any(named: "network"))).thenAnswer(
          (_) => Future.value(347537253),
        );
        when(() => cubit.getWalletTokenAmount(selectedYield.token1.addresses[selectedYield.network.chainId]!,
            network: any(named: "network"))).thenAnswer(
          (_) => Future.value(32576352673),
        );
        when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
        when(() => cubit.selectedYield).thenReturn(selectedYield);
        when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
        when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(currentPriceAsTick));
        when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);
        when(() => cubit.selectYield(any(), any())).thenAnswer((_) async => () {});
        when(() => cubit.selectedYieldTimeframe).thenReturn(YieldTimeFrame.day);

        await tester.pumpDeviceBuilder(await goldenBuilder(), wrapper: GoldenConfig.localizationsWrapper());
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key("yield-card-24h")));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key("deposit-settings-button")));
        await tester.pumpAndSettle();

        await tester.enterText(find.byKey(const Key("slippage-text-field")), expectedSlippage.value.toString());
        await tester.enterText(find.byKey(const Key("deadline-textfield")), expectedDeadline.inMinutes.toString());
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key("deposit-settings-button"))); // closing the dropdown
        await tester.pumpAndSettle();

        await tester.drag(find.byKey(const Key("deposit-settings-button")), const Offset(0, -1000));
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

  zGoldenTest(
    "When loading the screen, and the network in the path param is different from the selected one, it should switch the network",
    (tester) async {
      when(() => navigator.getParam(any())).thenAnswer((_) => AppNetworks.scroll.name);

      await tester.runAsync(() async => await tester.pumpDeviceBuilder(await goldenBuilder()));
      await tester.pumpAndSettle();

      verify(() => appCubit.updateAppNetwork(AppNetworks.scroll)).called(1);
    },
  );

  zGoldenTest(
    "When loading the screen, and the network in the path param is equal from the selected one, it should not switch the network",
    (tester) async {
      when(() => navigator.getParam(any())).thenAnswer((_) => appCubit.selectedNetwork.name);

      await tester.runAsync(() async => await tester.pumpDeviceBuilder(await goldenBuilder()));
      await tester.pumpAndSettle();

      verifyNever(() => appCubit.updateAppNetwork(any()));
    },
  );

  zGoldenTest(
    """When emitting a new pool tick, and the deposit amounts are already typed,
  it should update the amount that have been calculated by the typed amount""",
    goldenFileName: "deposit_page_pool_tick_update_deposit_amount",
    (tester) async {
      await tester.runAsync(() async {
        final selectedYield = YieldsDto.fixture().best24hYield;
        final currentPriceAsTick = BigInt.from(174072);
        final nextPriceAsTick = BigInt.from(261892);
        final poolTickStreamController = StreamController<BigInt>.broadcast();

        final signer = SignerMock();

        when(() => wallet.signer).thenReturn(signer);
        when(() => wallet.signerStream).thenAnswer((_) => Stream.value(signer));
        when(() => cubit.getWalletTokenAmount(selectedYield.token0.addresses[selectedYield.network.chainId]!,
            network: any(named: "network"))).thenAnswer(
          (_) => Future.value(347537253),
        );
        when(() => cubit.getWalletTokenAmount(selectedYield.token1.addresses[selectedYield.network.chainId]!,
            network: any(named: "network"))).thenAnswer(
          (_) => Future.value(32576352673),
        );
        when(() => cubit.selectYield(any(), any())).thenAnswer((_) => Future.value());
        when(() => cubit.selectedYieldStream).thenAnswer((_) => Stream.value(selectedYield));
        when(() => cubit.selectedYield).thenReturn(selectedYield);
        when(() => cubit.state).thenReturn(DepositState.success(YieldsDto.fixture()));
        when(() => cubit.poolTickStream).thenAnswer((_) => poolTickStreamController.stream);
        when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

        await tester.pumpDeviceBuilder(await goldenBuilder(), wrapper: GoldenConfig.localizationsWrapper());
        await tester.tap(find.byKey(const Key("yield-card-24h")));
        await tester.pumpAndSettle();
        await tester.drag(find.byKey(const Key("deposit-settings-button")), const Offset(0, -500));
        await tester.pumpAndSettle();

        await tester.enterText(find.byKey(const Key("quote-token-input-card")), "1");
        await tester.pumpAndSettle();

        poolTickStreamController.add(nextPriceAsTick);
        when(() => cubit.latestPoolTick).thenReturn(nextPriceAsTick);
        await tester.pumpAndSettle();
      });
    },
  );
}
