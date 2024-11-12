import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:lottie/lottie.dart';
import 'package:mocktail/mocktail.dart';
import 'package:web3kit/web3kit.dart';
import 'package:zup_app/abis/uniswap_v3_pool.abi.g.dart';
import 'package:zup_app/app/app_cubit/app_cubit.dart';
import 'package:zup_app/app/create/deposit/deposit_page.dart';
import 'package:zup_app/core/debouncer.dart';
import 'package:zup_app/core/dtos/yields_dto.dart';
import 'package:zup_app/core/enums/networks.dart';
import 'package:zup_app/core/enums/zup_navigator_paths.dart';
import 'package:zup_app/core/injections.dart';
import 'package:zup_app/core/mixins/v3_pool_conversors_mixin.dart';
import 'package:zup_app/core/repositories/yield_repository.dart';
import 'package:zup_app/core/zup_navigator.dart';
import 'package:zup_app/gen/assets.gen.dart';
import 'package:zup_app/widgets/zup_cached_image.dart';
import 'package:zup_core/zup_core.dart';

import '../../../golden_config.dart';
import '../../../mocks.dart';

class _V3PoolConversors with V3PoolConversorsMixin {}

void main() {
  late ZupNavigator navigator;
  late Wallet wallet;
  late UniswapV3Pool uniswapV3Pool;
  late UniswapV3PoolImpl uniswapV3PoolImpl;
  late ZupSingletonCache zupSingletonCache;
  late YieldRepository yieldRepository;
  late AppCubit appCubit;

  setUp(() async {
    await Web3Kit.initializeForTest();
    await inject.unregister<Wallet>();

    navigator = ZupNavigatorMock();
    wallet = WalletMock();
    uniswapV3Pool = UniswapV3PoolMock();
    zupSingletonCache = ZupSingletonCache.shared;
    yieldRepository = YieldRepositoryMock();
    appCubit = AppCubitMock();
    uniswapV3PoolImpl = UniswapV3PoolImplMock();

    inject.registerFactory<ZupNavigator>(() => navigator);
    inject.registerFactory<Wallet>(() => wallet);
    inject.registerFactory<YieldRepository>(() => yieldRepository);
    inject.registerFactory<UniswapV3Pool>(() => uniswapV3Pool);
    inject.registerFactory<ZupSingletonCache>(() => zupSingletonCache);
    inject.registerFactory<ZupCachedImage>(() => mockZupCachedImage());
    inject.registerFactory<AppCubit>(() => appCubit);
    inject.registerFactory<LottieBuilder>(
      () => Assets.lotties.click.lottie(animate: false),
      instanceName: InjectInstanceNames.lottieClick,
    );
    inject.registerFactory<Debouncer>(() => Debouncer(milliseconds: 0));

    inject.registerFactory<LottieBuilder>(
      () => Assets.lotties.ghost.lottie(animate: false),
      instanceName: InjectInstanceNames.lottieGhost,
    );

    when(() => yieldRepository.getYields(
        token0Address: any(named: "token0Address"),
        token1Address: any(named: "token1Address"))).thenAnswer((_) async => YieldsDto.fixture());

    when(() => appCubit.selectedNetwork).thenAnswer((_) => Networks.arbitrum);
    when(() =>
            uniswapV3Pool.fromRpcProvider(contractAddress: any(named: "contractAddress"), rpcUrl: any(named: "rpcUrl")))
        .thenReturn(uniswapV3PoolImpl);

    registerFallbackValue(BuildContextMock());
  });

  tearDown(() async {
    await ZupSingletonCache.shared.clear();
    await inject.reset();
  });

  Future<DeviceBuilder> goldenBuilder() async => await goldenDeviceBuilder(const DepositPage());

  zGoldenTest("When instantiating the page, it should get the best pools with the selected tokens", (tester) async {
    const token0Address = "0x1234";
    const token1Address = "0x5678";

    when(() => navigator.getParam(ZupNavigatorPaths.deposit.routeParamsName!.param0)).thenReturn(token0Address);
    when(() => navigator.getParam(ZupNavigatorPaths.deposit.routeParamsName!.param1)).thenReturn(token1Address);

    await tester.pumpDeviceBuilder(await goldenBuilder());

    verify(
      () => yieldRepository.getYields(token0Address: token0Address, token1Address: token1Address),
    );
  });

  zGoldenTest("When clicking the back button, it should try navigate back", (tester) async {
    when(() => navigator.back(any())).thenAnswer((_) async => true);

    await tester.pumpDeviceBuilder(await goldenBuilder());

    await tester.tap(find.byKey(const Key("back-button")));
    await tester.pumpAndSettle();

    verify(() => navigator.back(any())).called(1);
  });

  zGoldenTest("When an error occur while getting the best pools, it should show the error state",
      goldenFileName: "deposit_page_error", (tester) async {
    when(() => yieldRepository.getYields(
        token0Address: any(named: "token0Address"),
        token1Address: any(named: "token1Address"))).thenAnswer((_) async => throw Exception());

    await tester.pumpDeviceBuilder(await goldenBuilder());
  });

  zGoldenTest("When Clicking in the helper button in the error state, it should re-fetch the pools", (tester) async {
    when(() => yieldRepository.getYields(
        token0Address: any(named: "token0Address"),
        token1Address: any(named: "token1Address"))).thenAnswer((_) async => throw Exception());

    await tester.pumpDeviceBuilder(await goldenBuilder());

    await tester.tap(find.byKey(const Key("help-button")));
    await tester.pumpAndSettle();

    verify(
      () => yieldRepository.getYields(
          token0Address: any(named: "token0Address"), token1Address: any(named: "token1Address")),
    ).called(2);
  });

  zGoldenTest("When the list of pools is empty, it should show the empty state", goldenFileName: "deposit_page_empty",
      (tester) async {
    when(() => yieldRepository.getYields(
        token0Address: any(named: "token0Address"),
        token1Address: any(named: "token1Address"))).thenAnswer((_) async => YieldsDto.empty());

    await tester.pumpDeviceBuilder(await goldenBuilder());
  });

  zGoldenTest("When clicking the helper button in the empty state, it should go back to the select tokens page",
      (tester) async {
    when(() => navigator.navigateToNewPosition()).thenAnswer((_) async {});
    when(() => yieldRepository.getYields(
        token0Address: any(named: "token0Address"),
        token1Address: any(named: "token1Address"))).thenAnswer((_) async => YieldsDto.empty());

    await tester.pumpDeviceBuilder(await goldenBuilder());

    await tester.tap(find.byKey(const Key("help-button")));
    await tester.pumpAndSettle();

    verify(() => navigator.navigateToNewPosition()).called(1);
  });

  zGoldenTest("When the list of pools is not empty, it should show the list of pools", goldenFileName: "deposit_page",
      (tester) async {
    when(() => yieldRepository.getYields(
        token0Address: any(named: "token0Address"),
        token1Address: any(named: "token1Address"))).thenAnswer((_) async => YieldsDto.fixture());

    await tester.pumpDeviceBuilder(await goldenBuilder());
  });

  zGoldenTest("When clicking in any card, it should scroll down and show the deposit form",
      goldenFileName: "deposit_page_selected_yield", (tester) async {
    when(() => wallet.signerStream).thenAnswer((_) => Stream.value(null));

    when(() => yieldRepository.getYields(
        token0Address: any(named: "token0Address"),
        token1Address: any(named: "token1Address"))).thenAnswer((_) async => YieldsDto.fixture());

    await tester.pumpDeviceBuilder(await goldenBuilder());

    await tester.tap(find.byKey(const Key("best-90d-yield-card")));
    await tester.pumpAndSettle();
  });

  zGoldenTest("When selecting any pool card, and deselecting it, it should show the select a pool state",
      goldenFileName: "deposit_page_select_unselect_yield", (tester) async {
    when(() => wallet.signerStream).thenAnswer((_) => Stream.value(null));

    when(() => yieldRepository.getYields(
        token0Address: any(named: "token0Address"),
        token1Address: any(named: "token1Address"))).thenAnswer((_) async => YieldsDto.fixture());

    await tester.pumpDeviceBuilder(await goldenBuilder());

    await tester.tap(find.byKey(const Key("best-90d-yield-card")));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key("best-90d-yield-card")));
    await tester.pumpAndSettle();
  });

  zGoldenTest("When hovering the time frame title, it should show a tooltip explaining the time frame",
      goldenFileName: "deposit_page_time_frame_tooltip", (tester) async {
    when(() => wallet.signerStream).thenAnswer((_) => Stream.value(null));

    when(() => yieldRepository.getYields(
        token0Address: any(named: "token0Address"),
        token1Address: any(named: "token1Address"))).thenAnswer((_) async => YieldsDto.fixture());

    await tester.pumpDeviceBuilder(await goldenBuilder());

    await tester.hover(find.byKey(const Key("timeframe-tooltip")));
    await tester.pumpAndSettle();
  });

  zGoldenTest("When clicking in the quote token selector, it should invert the tokens",
      goldenFileName: "deposit_page_invert_tokens", (tester) async {
    when(() => wallet.signerStream).thenAnswer((_) => Stream.value(null));

    when(() => yieldRepository.getYields(
        token0Address: any(named: "token0Address"),
        token1Address: any(named: "token1Address"))).thenAnswer((_) async => YieldsDto.fixture());

    await tester.pumpDeviceBuilder(await goldenBuilder());

    await tester.tap(find.byKey(const Key("best-90d-yield-card")));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key("quote-token-selector")));
    await tester.pumpAndSettle();
  });

  zGoldenTest("When clicking in the quote token selector, then in the base token selector, it invert the tokens back",
      goldenFileName: "deposit_page_invert_tokens_back", (tester) async {
    when(() => wallet.signerStream).thenAnswer((_) => Stream.value(null));

    when(() => yieldRepository.getYields(
        token0Address: any(named: "token0Address"),
        token1Address: any(named: "token1Address"))).thenAnswer((_) async => YieldsDto.fixture());

    await tester.pumpDeviceBuilder(await goldenBuilder());

    await tester.tap(find.byKey(const Key("best-90d-yield-card")));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key("quote-token-selector")));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key("base-token-selector")));
    await tester.pumpAndSettle();
  });

  zGoldenTest("When getting the pool tick, the asset price should be calculated",
      goldenFileName: "deposit_page_asset_price", (tester) async {
    final tick = BigInt.from(-195608);

    when(() => wallet.signerStream).thenAnswer((_) => Stream.value(null));
    when(() => uniswapV3PoolImpl.slot0()).thenAnswer((_) async => (
          sqrtPriceX96: BigInt.from(0),
          tick: tick,
          observationIndex: BigInt.from(0),
          observationCardinality: BigInt.from(0),
          observationCardinalityNext: BigInt.from(0),
          feeProtocol: BigInt.from(0),
          unlocked: true,
        ));
    when(() => yieldRepository.getYields(
        token0Address: any(named: "token0Address"),
        token1Address: any(named: "token1Address"))).thenAnswer((_) async => YieldsDto.fixture());

    await tester.pumpDeviceBuilder(await goldenBuilder());

    await tester.tap(find.byKey(const Key("best-90d-yield-card")));
    await tester.pumpAndSettle();

    final textWidget = find.byKey(const Key("token-price")).evaluate().first.widget as Text;

    expect(textWidget.data, "1 WETH ~ 3200.9377 USDC");
  });

  zGoldenTest("When typing the min range, it should show the typed value",
      goldenFileName: "deposit_page_min_range_filled", (tester) async {
    when(() => wallet.signerStream).thenAnswer((_) => Stream.value(null));
    when(() => yieldRepository.getYields(
        token0Address: any(named: "token0Address"),
        token1Address: any(named: "token1Address"))).thenAnswer((_) async => YieldsDto.fixture());

    await tester.pumpDeviceBuilder(await goldenBuilder());

    await tester.tap(find.byKey(const Key("best-90d-yield-card")));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key("min-range-selector")), "1000");
    await tester.pumpAndSettle();
  });

  zGoldenTest("When typing the min range higher than the current price, it should show an warning",
      goldenFileName: "deposit_page_min_range_filled_higher_than_current", (tester) async {
    final tick = BigInt.from(-195608);
    const token0Decimals = 18;
    const token1Decimals = 6;

    final yields = YieldsDto.fixture();
    when(() => wallet.signerStream).thenAnswer((_) => Stream.value(null));

    when(() => yieldRepository.getYields(
        token0Address: any(named: "token0Address"),
        token1Address: any(named: "token1Address"))).thenAnswer((_) async => yields);

    when(() => uniswapV3PoolImpl.slot0()).thenAnswer((_) async => (
          sqrtPriceX96: BigInt.from(0),
          tick: tick,
          observationIndex: BigInt.from(0),
          observationCardinality: BigInt.from(0),
          observationCardinalityNext: BigInt.from(0),
          feeProtocol: BigInt.from(0),
          unlocked: true,
        ));

    await tester.pumpDeviceBuilder(await goldenBuilder());

    await tester.tap(find.byKey(const Key("best-90d-yield-card")));
    await tester.pumpAndSettle();

    await tester.enterText(
        find.byKey(const Key("min-range-selector")),
        (_V3PoolConversors().tickToPrice(
                  tick: tick,
                  token0Decimals: token0Decimals,
                  token1Decimals: token1Decimals,
                  asToken0byToken1: true,
                ) +
                100)
            .toString());
    await tester.pumpAndSettle();

    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
  });

  zGoldenTest("When typing a max range lower than the min range, it should show an error",
      goldenFileName: "deposit_page_max_range_lower_than_min_range", (tester) async {
    when(() => wallet.signerStream).thenAnswer((_) => Stream.value(null));
    when(() => yieldRepository.getYields(
        token0Address: any(named: "token0Address"),
        token1Address: any(named: "token1Address"))).thenAnswer((_) async => YieldsDto.fixture());

    await tester.pumpDeviceBuilder(await goldenBuilder());

    await tester.tap(find.byKey(const Key("best-90d-yield-card")));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key("min-range-selector")), "2000");
    await tester.pumpAndSettle();

    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key("max-range-selector")), "1500");
    await tester.pumpAndSettle();

    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
  });

  zGoldenTest("When typing both ranges, and then clicking the button of full range, it should show the full range",
      goldenFileName: "deposit_page_full_range", (tester) async {
    when(() => wallet.signerStream).thenAnswer((_) => Stream.value(null));
    when(() => yieldRepository.getYields(
        token0Address: any(named: "token0Address"),
        token1Address: any(named: "token1Address"))).thenAnswer((_) async => YieldsDto.fixture());

    await tester.pumpDeviceBuilder(await goldenBuilder());

    await tester.tap(find.byKey(const Key("best-90d-yield-card")));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key("min-range-selector")), "2000");
    await tester.pumpAndSettle();

    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key("max-range-selector")), "1500");
    await tester.pumpAndSettle();

    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key("full-range-button")));
    await tester.pumpAndSettle();
  });

  zGoldenTest("When typing the max range lower than the current price, it should show an warning",
      goldenFileName: "deposit_page_max_range_filled_lower_than_current", (tester) async {
    final tick = BigInt.from(-195608);
    const token0Decimals = 18;
    const token1Decimals = 6;

    final yields = YieldsDto.fixture();
    when(() => wallet.signerStream).thenAnswer((_) => Stream.value(null));

    when(() => yieldRepository.getYields(
        token0Address: any(named: "token0Address"),
        token1Address: any(named: "token1Address"))).thenAnswer((_) async => yields);

    when(() => uniswapV3PoolImpl.slot0()).thenAnswer((_) async => (
          sqrtPriceX96: BigInt.from(0),
          tick: tick,
          observationIndex: BigInt.from(0),
          observationCardinality: BigInt.from(0),
          observationCardinalityNext: BigInt.from(0),
          feeProtocol: BigInt.from(0),
          unlocked: true,
        ));

    await tester.pumpDeviceBuilder(await goldenBuilder());

    await tester.tap(find.byKey(const Key("best-90d-yield-card")));
    await tester.pumpAndSettle();

    await tester.enterText(
        find.byKey(const Key("max-range-selector")),
        (_V3PoolConversors().tickToPrice(
                  tick: tick,
                  token0Decimals: token0Decimals,
                  token1Decimals: token1Decimals,
                  asToken0byToken1: true,
                ) -
                100)
            .toString());
    await tester.pumpAndSettle();

    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
  });

  zGoldenTest("When both ranges are filled, and then inverting the tokens, it should remain typed",
      goldenFileName: "deposit_page_inverting_tokens_with_filled_ranges", (tester) async {
    when(() => wallet.signerStream).thenAnswer((_) => Stream.value(null));
    when(() => yieldRepository.getYields(
        token0Address: any(named: "token0Address"),
        token1Address: any(named: "token1Address"))).thenAnswer((_) async => YieldsDto.fixture());
    when(() => uniswapV3PoolImpl.slot0()).thenAnswer((_) async => (
          sqrtPriceX96: BigInt.from(0),
          tick: BigInt.from(-195608),
          observationIndex: BigInt.from(0),
          observationCardinality: BigInt.from(0),
          observationCardinalityNext: BigInt.from(0),
          feeProtocol: BigInt.from(0),
          unlocked: true,
        ));

    await tester.pumpDeviceBuilder(await goldenBuilder());

    await tester.tap(find.byKey(const Key("best-90d-yield-card")));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key("min-range-selector")), "2000");
    await tester.pumpAndSettle();

    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key("max-range-selector")), "2600");
    await tester.pumpAndSettle();

    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key("quote-token-selector")));
    await tester.pumpAndSettle();
  });

  zGoldenTest("When typing the min range higher than the current price, the token 1 should not be needed to deposit",
      goldenFileName: "deposit_page_min_range_out_of_range_deposit_token_1", (tester) async {
    final tick = BigInt.from(-195608);
    const token0Decimals = 18;
    const token1Decimals = 6;

    final yields = YieldsDto.fixture();
    when(() => wallet.signerStream).thenAnswer((_) => Stream.value(null));

    when(() => yieldRepository.getYields(
        token0Address: any(named: "token0Address"),
        token1Address: any(named: "token1Address"))).thenAnswer((_) async => yields);

    when(() => uniswapV3PoolImpl.slot0()).thenAnswer((_) async => (
          sqrtPriceX96: BigInt.from(0),
          tick: tick,
          observationIndex: BigInt.from(0),
          observationCardinality: BigInt.from(0),
          observationCardinalityNext: BigInt.from(0),
          feeProtocol: BigInt.from(0),
          unlocked: true,
        ));

    await tester.pumpDeviceBuilder(await goldenBuilder());

    await tester.tap(find.byKey(const Key("best-90d-yield-card")));
    await tester.pumpAndSettle();

    await tester.enterText(
        find.byKey(const Key("min-range-selector")),
        (_V3PoolConversors().tickToPrice(
                  tick: tick,
                  token0Decimals: token0Decimals,
                  token1Decimals: token1Decimals,
                  asToken0byToken1: true,
                ) +
                100)
            .toString());
    await tester.pumpAndSettle();

    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
  });

  zGoldenTest("When typing the max range lower than the current price, the token 0 should not be needed to deposit",
      goldenFileName: "deposit_page_max_range_out_of_range_deposit_token_0", (tester) async {
    final tick = BigInt.from(-195608);
    const token0Decimals = 18;
    const token1Decimals = 6;

    final yields = YieldsDto.fixture();
    when(() => wallet.signerStream).thenAnswer((_) => Stream.value(null));

    when(() => yieldRepository.getYields(
        token0Address: any(named: "token0Address"),
        token1Address: any(named: "token1Address"))).thenAnswer((_) async => yields);

    when(() => uniswapV3PoolImpl.slot0()).thenAnswer((_) async => (
          sqrtPriceX96: BigInt.from(0),
          tick: tick,
          observationIndex: BigInt.from(0),
          observationCardinality: BigInt.from(0),
          observationCardinalityNext: BigInt.from(0),
          feeProtocol: BigInt.from(0),
          unlocked: true,
        ));

    await tester.pumpDeviceBuilder(await goldenBuilder());

    await tester.tap(find.byKey(const Key("best-90d-yield-card")));
    await tester.pumpAndSettle();

    await tester.enterText(
        find.byKey(const Key("max-range-selector")),
        (_V3PoolConversors().tickToPrice(
                  tick: tick,
                  token0Decimals: token0Decimals,
                  token1Decimals: token1Decimals,
                  asToken0byToken1: true,
                ) -
                100)
            .toString());
    await tester.pumpAndSettle();

    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
  });

  zGoldenTest(
      "When typing in one of the amount boxes, it should automatically calculate the other amount (token0 input case)",
      goldenFileName: "deposit_page_auto_calculate_token_1", (tester) async {
    when(() => wallet.signerStream).thenAnswer((_) => Stream.value(null));
    when(() => yieldRepository.getYields(
        token0Address: any(named: "token0Address"),
        token1Address: any(named: "token1Address"))).thenAnswer((_) async => YieldsDto.fixture());
    when(() => uniswapV3PoolImpl.slot0()).thenAnswer((_) async => (
          sqrtPriceX96: BigInt.from(0),
          tick: BigInt.from(-195608),
          observationIndex: BigInt.from(0),
          observationCardinality: BigInt.from(0),
          observationCardinalityNext: BigInt.from(0),
          feeProtocol: BigInt.from(0),
          unlocked: true,
        ));

    await tester.pumpDeviceBuilder(await goldenBuilder());

    await tester.tap(find.byKey(const Key("best-90d-yield-card")));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key("token-0-amount-card")), "1");
    await tester.pumpAndSettle();
  });

  zGoldenTest(
      "When typing in one of the amount boxes, it should automatically calculate the other amount (token1 input case)",
      goldenFileName: "deposit_page_auto_calculate_token_0", (tester) async {
    when(() => wallet.signerStream).thenAnswer((_) => Stream.value(null));
    when(() => yieldRepository.getYields(
        token0Address: any(named: "token0Address"),
        token1Address: any(named: "token1Address"))).thenAnswer((_) async => YieldsDto.fixture());
    when(() => uniswapV3PoolImpl.slot0()).thenAnswer((_) async => (
          sqrtPriceX96: BigInt.from(0),
          tick: BigInt.from(-195608),
          observationIndex: BigInt.from(0),
          observationCardinality: BigInt.from(0),
          observationCardinalityNext: BigInt.from(0),
          feeProtocol: BigInt.from(0),
          unlocked: true,
        ));

    await tester.pumpDeviceBuilder(await goldenBuilder());

    await tester.tap(find.byKey(const Key("best-90d-yield-card")));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key("token-1-amount-card")), "1000");
    await tester.pumpAndSettle();
  });

  zGoldenTest("When chaging ranges with typed amounts, it should adjust the amounts for the range (user typed amount0)",
      goldenFileName: "deposit_page_change_range_with_typed_amount", (tester) async {
    when(() => wallet.signerStream).thenAnswer((_) => Stream.value(null));
    when(() => yieldRepository.getYields(
        token0Address: any(named: "token0Address"),
        token1Address: any(named: "token1Address"))).thenAnswer((_) async => YieldsDto.fixture());
    when(() => uniswapV3PoolImpl.slot0()).thenAnswer((_) async => (
          sqrtPriceX96: BigInt.from(0),
          tick: BigInt.from(-195608),
          observationIndex: BigInt.from(0),
          observationCardinality: BigInt.from(0),
          observationCardinalityNext: BigInt.from(0),
          feeProtocol: BigInt.from(0),
          unlocked: true,
        ));

    await tester.pumpDeviceBuilder(await goldenBuilder());

    await tester.tap(find.byKey(const Key("best-90d-yield-card")));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key("token-0-amount-card")), "1");
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key("min-range-selector")), "2000");
    await tester.pumpAndSettle();

    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key("max-range-selector")), "10000");
    await tester.pumpAndSettle();

    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
  });

  zGoldenTest("When chaging ranges with typed amounts, it should adjust the amounts for the range (user typed amount1)",
      goldenFileName: "deposit_page_change_range_with_typed_amount_1", (tester) async {
    when(() => wallet.signerStream).thenAnswer((_) => Stream.value(null));
    when(() => yieldRepository.getYields(
        token0Address: any(named: "token0Address"),
        token1Address: any(named: "token1Address"))).thenAnswer((_) async => YieldsDto.fixture());
    when(() => uniswapV3PoolImpl.slot0()).thenAnswer((_) async => (
          sqrtPriceX96: BigInt.from(0),
          tick: BigInt.from(-195608),
          observationIndex: BigInt.from(0),
          observationCardinality: BigInt.from(0),
          observationCardinalityNext: BigInt.from(0),
          feeProtocol: BigInt.from(0),
          unlocked: true,
        ));

    await tester.pumpDeviceBuilder(await goldenBuilder());

    await tester.tap(find.byKey(const Key("best-90d-yield-card")));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key("token-1-amount-card")), "1500");
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key("min-range-selector")), "2000");
    await tester.pumpAndSettle();

    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key("max-range-selector")), "10000");
    await tester.pumpAndSettle();

    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
  });
  zGoldenTest(
      "When the user is not connected the deposit button should be to connect the wallet. So when clicking it, it should open the wallet modal",
      goldenFileName: "deposit_page_not_connected_deposit_button_click", (tester) async {
    when(() => wallet.signerStream).thenAnswer((_) => Stream.value(null));

    when(() => yieldRepository.getYields(
        token0Address: any(named: "token0Address"),
        token1Address: any(named: "token1Address"))).thenAnswer((_) async => YieldsDto.fixture());

    await tester.pumpDeviceBuilder(await goldenBuilder(), wrapper: GoldenConfig.localizationsWrapper());

    await tester.tap(find.byKey(const Key("best-90d-yield-card")));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key("deposit-button")));
    await tester.pumpAndSettle();
  });

  zGoldenTest("""When the user is connected, input a token amount,
      but the user doesn't have enough balance,
      the deposit button should be disabled,
      with a message that the user doesn't have enough balance
      (token0 input amount)
      """, goldenFileName: "deposit_page_not_enough_balance", (tester) async {
    final signer = SignerMock();

    const userBalance = 102.2;

    when(() => wallet.signerStream).thenAnswer((_) => Stream.value(signer));
    when(() => wallet.signer).thenReturn(signer);
    when(() => signer.address).thenAnswer((_) async => "0x99E3CfADCD8Feecb5DdF91f88998cFfB3145F78c");
    when(() => wallet.tokenBalance(any(), rpcUrl: any(named: "rpcUrl"))).thenAnswer((_) async => userBalance);

    when(() => yieldRepository.getYields(
        token0Address: any(named: "token0Address"),
        token1Address: any(named: "token1Address"))).thenAnswer((_) async => YieldsDto.fixture());

    await tester.pumpDeviceBuilder(await goldenBuilder());

    await tester.tap(find.byKey(const Key("best-90d-yield-card")));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key("token-0-amount-card")), (userBalance + 100).toString());
    await tester.pumpAndSettle();
  });

  zGoldenTest("""When the user is connected, input a token amount,
      but the user doesn't have enough balance,
      the deposit button should be disabled,
      with a message that the user doesn't have enough balance
      (token1 input amount)
      """, goldenFileName: "deposit_page_not_enough_balance_token_1", (tester) async {
    final signer = SignerMock();

    const userBalance = 102.2;

    when(() => wallet.signerStream).thenAnswer((_) => Stream.value(signer));
    when(() => wallet.signer).thenReturn(signer);
    when(() => signer.address).thenAnswer((_) async => "0x99E3CfADCD8Feecb5DdF91f88998cFfB3145F78c");
    when(() => wallet.tokenBalance(any(), rpcUrl: any(named: "rpcUrl"))).thenAnswer((_) async => userBalance);

    when(() => yieldRepository.getYields(
        token0Address: any(named: "token0Address"),
        token1Address: any(named: "token1Address"))).thenAnswer((_) async => YieldsDto.fixture());

    await tester.pumpDeviceBuilder(await goldenBuilder());

    await tester.tap(find.byKey(const Key("best-90d-yield-card")));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key("token-1-amount-card")), (userBalance + 100).toString());
    await tester.pumpAndSettle();
  });

  zGoldenTest("""When the user is connected,
      and input a token amount that he has enough balance,
      the deposit button should be enabled""", goldenFileName: "deposit_page_enough_balance", (tester) async {
    final signer = SignerMock();

    const userBalance = 102.2;

    when(() => wallet.signerStream).thenAnswer((_) => Stream.value(signer));
    when(() => wallet.signer).thenReturn(signer);
    when(() => signer.address).thenAnswer((_) async => "0x99E3CfADCD8Feecb5DdF91f88998cFfB3145F78c");
    when(() => wallet.tokenBalance(any(), rpcUrl: any(named: "rpcUrl"))).thenAnswer((_) async => userBalance);
    when(() => uniswapV3PoolImpl.slot0()).thenAnswer((_) async => (
          sqrtPriceX96: BigInt.from(0),
          tick: BigInt.from(-195608),
          observationIndex: BigInt.from(0),
          observationCardinality: BigInt.from(0),
          observationCardinalityNext: BigInt.from(0),
          feeProtocol: BigInt.from(0),
          unlocked: true,
        ));
    when(() => yieldRepository.getYields(
        token0Address: any(named: "token0Address"),
        token1Address: any(named: "token1Address"))).thenAnswer((_) async => YieldsDto.fixture());

    await tester.pumpDeviceBuilder(await goldenBuilder());

    await tester.tap(find.byKey(const Key("best-90d-yield-card")));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key("token-1-amount-card")), (userBalance - 1).toString());
    await tester.pumpAndSettle();
  });
}
