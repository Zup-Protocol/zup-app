import 'dart:async';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mocktail/mocktail.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';
import 'package:web3kit/web3kit.dart';
import 'package:zup_app/abis/erc_20.abi.g.dart';
import 'package:zup_app/abis/uniswap_position_manager.abi.g.dart';
import 'package:zup_app/abis/uniswap_v3_pool.abi.g.dart';
import 'package:zup_app/app/create/deposit/widgets/preview_deposit_modal/preview_deposit_modal.dart';
import 'package:zup_app/app/create/deposit/widgets/preview_deposit_modal/preview_deposit_modal_cubit.dart';
import 'package:zup_app/core/dtos/token_dto.dart';
import 'package:zup_app/core/dtos/yield_dto.dart';
import 'package:zup_app/core/enums/networks.dart';
import 'package:zup_app/core/injections.dart';
import 'package:zup_app/core/slippage.dart';
import 'package:zup_app/core/v3_pool_constants.dart';
import 'package:zup_app/core/zup_navigator.dart';
import 'package:zup_app/widgets/zup_cached_image.dart';
import 'package:zup_ui_kit/zup_ui_kit.dart';

import '../../../../../golden_config.dart';
import '../../../../../mocks.dart';
import '../../../../../wrappers.dart';

void main() {
  late PreviewDepositModalCubit cubit;
  late ZupNavigator navigator;
  late UrlLauncherPlatform urlLauncherPlatform;
  late ConfettiController confettiController;
  final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  final currentYield = YieldDto.fixture();

  setUp(() {
    navigator = ZupNavigatorMock();
    cubit = PreviewDepositModalCubitMock();
    urlLauncherPlatform = UrlLauncherPlatformCustomMock();
    confettiController = ConfettiControllerMock();

    UrlLauncherPlatform.instance = urlLauncherPlatform;

    registerFallbackValue(TokenDto.fixture());
    registerFallbackValue(BigInt.zero);
    registerFallbackValue(Duration.zero);
    registerFallbackValue(Slippage.fromValue(32));
    inject.registerFactory<ConfettiController>(
      () => confettiController,
      instanceName: InjectInstanceNames.confettiController10s,
    );
    inject.registerFactory<UniswapV3Pool>(() => UniswapV3PoolMock());
    inject.registerFactory<Erc20>(() => Erc20Mock());
    inject.registerFactory<UniswapPositionManager>(() => UniswapPositionManagerMock());
    inject.registerFactory<Wallet>(() => WalletMock());
    inject.registerLazySingleton<PreviewDepositModalCubit>(() => cubit);
    inject.registerFactory<ZupCachedImage>(() => mockZupCachedImage());
    inject.registerFactory<ZupNavigator>(() => navigator);
    inject.registerFactory<GlobalKey<ScaffoldMessengerState>>(() => scaffoldMessengerKey);
    inject.registerFactory<ScrollController>(
      () => GoldenConfig.scrollController,
      instanceName: InjectInstanceNames.appScrollController,
    );
    inject.registerFactory<GlobalKey<NavigatorState>>(() => GlobalKey());

    when(() => cubit.setup()).thenAnswer((_) async {});
    when(() => cubit.poolTickStream).thenAnswer((_) => Stream.value(V3PoolConstants.maxTick));
    when(() => cubit.latestPoolTick).thenReturn(BigInt.from(3247));
    when(() => cubit.stream).thenAnswer((_) => Stream.value(
          PreviewDepositModalState.initial(
            token0Allowance: BigInt.zero,
            token1Allowance: BigInt.zero,
          ),
        ));

    when(() => cubit.state).thenReturn(
      PreviewDepositModalState.initial(
        token0Allowance: BigInt.zero,
        token1Allowance: BigInt.zero,
      ),
    );

    when(
      () => cubit.deposit(
        deadline: any(named: "deadline"),
        isReversed: any(named: "isReversed"),
        isMaxPriceInfinity: any(named: "isMaxPriceInfinity"),
        isMinPriceInfinity: any(named: "isMinPriceInfinity"),
        maxPrice: any(named: "maxPrice"),
        minPrice: any(named: "minPrice"),
        slippage: any(named: "slippage"),
        token0Amount: any(named: "token0Amount"),
        token1Amount: any(named: "token1Amount"),
      ),
    ).thenAnswer((_) async {});

    when(() => confettiController.duration).thenReturn(Duration.zero);
    when(() => confettiController.play()).thenAnswer((_) async {});
    when(() => confettiController.state).thenReturn(ConfettiControllerState.stoppedAndCleared);
  });

  tearDown(() {
    inject.reset();
  });

  Future<DeviceBuilder> goldenBuilder({
    YieldDto? customYield,
    bool isReversed = false,
    ({bool isInfinity, double price}) minPrice = (isInfinity: false, price: 1200),
    ({bool isInfinity, double price}) maxPrice = (isInfinity: false, price: 3000),
    double token0DepositAmount = 1,
    double token1DepositAmount = 3,
    Duration deadline = const Duration(minutes: 30),
    Slippage slippage = Slippage.halfPercent,
    bool depositWithNativeToken = false,
  }) =>
      goldenDeviceBuilder(
        Builder(builder: (context) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            await ZupModal.show(context,
                size: const Size(450, 650),
                padding: const EdgeInsets.only(left: 20),
                title: "Preview Deposit",
                content: BlocProvider.value(
                  value: cubit,
                  child: PreviewDepositModal(
                    depositWithNativeToken: depositWithNativeToken,
                    deadline: deadline,
                    maxSlippage: slippage,
                    currentYield: customYield ?? currentYield,
                    isReversed: isReversed,
                    minPrice: minPrice,
                    maxPrice: maxPrice,
                    token0DepositAmount: token0DepositAmount,
                    token1DepositAmount: token1DepositAmount,
                  ),
                ));
          });

          return const SizedBox();
        }),
      );

  zGoldenTest(
    "When initializing the widget, it should call setup in the cubit",
    (tester) async {
      await tester.pumpDeviceBuilder(await goldenBuilder(), wrapper: GoldenConfig.localizationsWrapper());
      await tester.pumpAndSettle();

      verify(() => cubit.setup()).called(1);
    },
  );

  zGoldenTest(
    "When the state is waiting transaction, it should show a snackbar",
    goldenFileName: "preview_deposit_modal_waiting_transaction",
    (tester) async {
      when(() => cubit.state).thenReturn(
        const PreviewDepositModalState.waitingTransaction(txId: "txID", type: WaitingTransactionType.deposit),
      );
      when(() => cubit.stream).thenAnswer(
        (_) => Stream.value(
          const PreviewDepositModalState.waitingTransaction(txId: "txID", type: WaitingTransactionType.deposit),
        ),
      );

      await tester.pumpDeviceBuilder(await goldenBuilder(), wrapper: GoldenConfig.localizationsWrapper());
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    """When the state is waiting transaction, the deposit button should be disabled,
    with the text "Waiting for transaction"
    """,
    goldenFileName: "preview_deposit_modal_waiting_transaction_button",
    (tester) async {
      when(() => cubit.state).thenReturn(
          const PreviewDepositModalState.waitingTransaction(txId: "txID", type: WaitingTransactionType.deposit));
      when(() => cubit.stream).thenAnswer(
        (_) => Stream.value(
            const PreviewDepositModalState.waitingTransaction(txId: "txID", type: WaitingTransactionType.deposit)),
      );

      await tester.pumpDeviceBuilder(await goldenBuilder(), wrapper: GoldenConfig.localizationsWrapper());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("close-snack-bar"))); // Closing the snackbar to show the button behind it
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    """When clicking in the helper button of the snackbar when the state is waiting transaction,
    it should open the transaction in the yield network's explorer""",
    (tester) async {
      const txId = "0xtxID";
      const yieldNetwork = Networks.sepolia;

      when(() => cubit.state).thenReturn(
          const PreviewDepositModalState.waitingTransaction(txId: "txID", type: WaitingTransactionType.deposit));
      when(() => cubit.stream).thenAnswer(
        (_) => Stream.value(
            const PreviewDepositModalState.waitingTransaction(txId: txId, type: WaitingTransactionType.deposit)),
      );

      await tester.pumpDeviceBuilder(
        await goldenBuilder(customYield: YieldDto.fixture().copyWith(network: yieldNetwork)),
        wrapper: GoldenConfig.localizationsWrapper(),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key("helper-button-snack-bar")));
      await tester.pumpAndSettle();

      expect(
        UrlLauncherPlatformCustomMock.lastLaunchedUrl,
        "${yieldNetwork.chainInfo.blockExplorerUrls!.first}/tx/$txId",
      );
    },
  );

  zGoldenTest(
    "When the state is approve success, it should show a snackbar corresponding to it",
    goldenFileName: "preview_deposit_modal_approve_success",
    (tester) async {
      when(() => cubit.state).thenReturn(const PreviewDepositModalState.approveSuccess(txId: '', symbol: "TOKE SYM"));
      when(() => cubit.stream).thenAnswer((_) {
        return Stream.value(const PreviewDepositModalState.approveSuccess(txId: '', symbol: "TOKE SYM"));
      });

      await tester.pumpDeviceBuilder(await goldenBuilder(), wrapper: GoldenConfig.localizationsWrapper());
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    """When there's a current snackbar, and the approve success state is emitted, it should close the current snackbar
    and show the one with the approve success message
    """,
    goldenFileName: "preview_deposit_modal_approve_success_close_other_snackbar",
    (tester) async {
      when(() => cubit.state).thenReturn(const PreviewDepositModalState.approveSuccess(txId: '', symbol: "TOKE SYM"));
      when(() => cubit.stream).thenAnswer((_) {
        return Stream.fromFutures([
          Future.value(
            const PreviewDepositModalState.waitingTransaction(
              txId: '',
              type: WaitingTransactionType.approve,
            ),
          ), // Assuming that the waiting transaction state will display a snackbar

          Future.value(const PreviewDepositModalState.approveSuccess(txId: '', symbol: "TOKE SYM")),
        ]);
      });

      await tester.pumpDeviceBuilder(await goldenBuilder(), wrapper: GoldenConfig.localizationsWrapper());
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    "When the state is transaction error, it should show a snackbar corresponding to it",
    goldenFileName: "preview_deposit_modal_transaction_error",
    (tester) async {
      when(() => cubit.state).thenReturn(const PreviewDepositModalState.transactionError());
      when(() => cubit.stream).thenAnswer((_) {
        return Stream.value(const PreviewDepositModalState.transactionError());
      });

      await tester.pumpDeviceBuilder(await goldenBuilder(), wrapper: GoldenConfig.localizationsWrapper());
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    "When the min price and max price are infinity, it should be in range",
    goldenFileName: "preview_deposit_modal_in_range",
    (tester) async {
      await tester.pumpDeviceBuilder(
          await goldenBuilder(
            minPrice: (price: 0, isInfinity: true),
            maxPrice: (price: 0, isInfinity: true),
          ),
          wrapper: GoldenConfig.localizationsWrapper());

      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    "When depositWithNativeToken is true, the wrapped native token should be the native token",
    goldenFileName: "preview_deposit_modal_deposit_with_native_token",
    (tester) async {
      await tester.pumpDeviceBuilder(
          await goldenBuilder(
            depositWithNativeToken: true,
            customYield: currentYield.copyWith(
              token0: TokenDto.fixture().copyWith(address: currentYield.network.wrappedNative.address),
              token1: TokenDto.fixture().copyWith(address: "0x21"),
            ),
          ),
          wrapper: GoldenConfig.localizationsWrapper());

      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    "When the min price is higher than the current price, it should be in out of range state",
    goldenFileName: "preview_deposit_modal_out_of_range_min_price",
    (tester) async {
      const currentPrice = 3200.0;
      const minPrice = 4000.0;

      final currentPriceAsTick = V3PoolConversorsMixinWrapper().priceToTick(
        price: currentPrice,
        poolToken0Decimals: currentYield.token0.decimals,
        poolToken1Decimals: currentYield.token1.decimals,
      );

      when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

      await tester.pumpDeviceBuilder(
          await goldenBuilder(
            minPrice: (price: minPrice, isInfinity: false),
            maxPrice: (price: 0, isInfinity: true),
          ),
          wrapper: GoldenConfig.localizationsWrapper());

      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    "When the max price is lower than the current price, it should be in out of range state",
    goldenFileName: "preview_deposit_modal_out_of_range_max_price",
    (tester) async {
      const currentPrice = 3200.0;
      const maxPrice = 2000.0;

      final currentPriceAsTick = V3PoolConversorsMixinWrapper().priceToTick(
        price: currentPrice,
        poolToken0Decimals: currentYield.token0.decimals,
        poolToken1Decimals: currentYield.token1.decimals,
      );

      when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

      await tester.pumpDeviceBuilder(
          await goldenBuilder(
            minPrice: (price: 0, isInfinity: true),
            maxPrice: (price: maxPrice, isInfinity: false),
          ),
          wrapper: GoldenConfig.localizationsWrapper());

      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    """When the max price is higher than the current price,
    and the min price is lower than the current price,
    it should be in range state""",
    goldenFileName: "preview_deposit_modal_in_range_min_and_max_price",
    (tester) async {
      const currentPrice = 3200.0;
      const minPrice = 2000.0;
      const maxPrice = 4000.0;

      final currentPriceAsTick = V3PoolConversorsMixinWrapper().priceToTick(
        price: currentPrice,
        poolToken0Decimals: currentYield.token0.decimals,
        poolToken1Decimals: currentYield.token1.decimals,
      );

      when(() => cubit.latestPoolTick).thenReturn(currentPriceAsTick);

      await tester.pumpDeviceBuilder(
          await goldenBuilder(
            minPrice: (price: minPrice, isInfinity: false),
            maxPrice: (price: maxPrice, isInfinity: false),
          ),
          wrapper: GoldenConfig.localizationsWrapper());

      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    "When initializing with isReversed true, it should start with the tokens reversed",
    goldenFileName: "preview_deposit_modal_reversed",
    (tester) async {
      await tester.pumpDeviceBuilder(await goldenBuilder(isReversed: true),
          wrapper: GoldenConfig.localizationsWrapper());

      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    """When initializing with isReversed false,
    but clicking the switch button to reverse it,
    it should reverse the tokens""",
    goldenFileName: "preview_deposit_modal_reversed_manually",
    (tester) async {
      await tester.pumpDeviceBuilder(
        await goldenBuilder(isReversed: false),
        wrapper: GoldenConfig.localizationsWrapper(),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("reverse-tokens")));
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    """When initializing with isReversed false,
    but clicking the switch button to reverse it,
    it should reverse the tokens.
    If clicking to unreverse it,
    it should return to the initial state""",
    goldenFileName: "preview_deposit_modal_unreversed_manually",
    (tester) async {
      await tester.pumpDeviceBuilder(
        await goldenBuilder(isReversed: false),
        wrapper: GoldenConfig.localizationsWrapper(),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("unreverse-tokens")));
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    "When the state is loading, the deposit button should be disabled and loading",
    goldenFileName: "preview_deposit_modal_loading",
    (tester) async {
      when(() => cubit.state).thenReturn(const PreviewDepositModalState.loading());
      when(() => cubit.stream).thenAnswer((_) {
        return Stream.value(const PreviewDepositModalState.loading());
      });

      await tester.pumpDeviceBuilder(await goldenBuilder(), wrapper: GoldenConfig.localizationsWrapper());
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    """When the state is approving token, the deposit button
    should be disabled, loading, and with a corresponding
    title""",
    goldenFileName: "preview_deposit_modal_approving_token",
    (tester) async {
      when(() => cubit.state).thenReturn(const PreviewDepositModalState.approvingToken("Token A"));
      when(() => cubit.stream).thenAnswer((_) {
        return Stream.value(const PreviewDepositModalState.approvingToken("Token A"));
      });

      await tester.pumpDeviceBuilder(await goldenBuilder(), wrapper: GoldenConfig.localizationsWrapper());
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    """When the state is depositing, the deposit button should be disabled,
    loading, and with a corresponding title""",
    goldenFileName: "preview_deposit_modal_depositing",
    (tester) async {
      when(() => cubit.state).thenReturn(const PreviewDepositModalState.depositing());
      when(() => cubit.stream).thenAnswer((_) {
        return Stream.value(const PreviewDepositModalState.depositing());
      });

      await tester.pumpDeviceBuilder(await goldenBuilder(), wrapper: GoldenConfig.localizationsWrapper());
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    """When the state is initial, and the token0Allowance is is lower than
    the amount to deposit, the deposit button should be in the state to
    approve the token0 amount""",
    goldenFileName: "preview_deposit_modal_approve_token0_state",
    (tester) async {
      final token0Allowance = BigInt.from(100);
      const depositAmount = 200.43;

      when(() => cubit.state).thenReturn(
        PreviewDepositModalState.initial(
          token0Allowance: token0Allowance,
          token1Allowance: BigInt.zero,
        ),
      );

      when(() => cubit.stream).thenAnswer((_) {
        return Stream.value(PreviewDepositModalState.initial(
          token0Allowance: token0Allowance,
          token1Allowance: BigInt.zero,
        ));
      });

      await tester.pumpDeviceBuilder(
        await goldenBuilder(token0DepositAmount: depositAmount, token1DepositAmount: 0),
        wrapper: GoldenConfig.localizationsWrapper(),
      );
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    """When the state is initial, and the token0Allowance is is lower than
    the amount to deposit, the deposit button should be in the state to
    approve the token0 amount. Once clicking the button, it should call
    the cubit to approve the token0 with the deposit amount""",
    (tester) async {
      final token0Allowance = BigInt.from(100);
      const depositAmount = 200.43;

      when(() => cubit.approveToken(any(), any())).thenAnswer((_) => Future.value());

      when(() => cubit.state).thenReturn(
        PreviewDepositModalState.initial(
          token0Allowance: token0Allowance,
          token1Allowance: BigInt.zero,
        ),
      );

      when(() => cubit.stream).thenAnswer((_) {
        return Stream.value(PreviewDepositModalState.initial(
          token0Allowance: token0Allowance,
          token1Allowance: BigInt.zero,
        ));
      });

      await tester.pumpDeviceBuilder(
        await goldenBuilder(token0DepositAmount: depositAmount, token1DepositAmount: 0),
        wrapper: GoldenConfig.localizationsWrapper(),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("deposit-button")));
      await tester.pumpAndSettle();

      verify(
        () => cubit.approveToken(
          currentYield.token0,
          depositAmount.parseTokenAmount(decimals: currentYield.token0.decimals),
        ),
      ).called(1);
    },
  );

  zGoldenTest(
    """When the state is initial, and the token0Allowance is is higher than
    the amount to deposit, but the token1Allowance is lower,
    the deposit button should be in the state to approve the token1 amount""",
    goldenFileName: "preview_deposit_modal_approve_token1_state",
    (tester) async {
      final token1Allowance = BigInt.from(400);
      const depositAmount = 20031.2;

      when(() => cubit.state).thenReturn(
        PreviewDepositModalState.initial(
          token0Allowance: depositAmount.parseTokenAmount(decimals: currentYield.token0.decimals),
          token1Allowance: token1Allowance,
        ),
      );

      when(() => cubit.stream).thenAnswer((_) {
        return Stream.value(PreviewDepositModalState.initial(
          token0Allowance: depositAmount.parseTokenAmount(decimals: currentYield.token0.decimals),
          token1Allowance: token1Allowance,
        ));
      });

      await tester.pumpDeviceBuilder(
        await goldenBuilder(token0DepositAmount: depositAmount, token1DepositAmount: depositAmount),
        wrapper: GoldenConfig.localizationsWrapper(),
      );
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    """When the state is initial, and the token0Allowance is is higher than
    the amount to deposit, but the token1Allowance is lower,
    the deposit button should be in the state to approve the token1 amount.
    Once clicking the button, it should call the cubit to approve the token1
    with the deposit amount
    """,
    (tester) async {
      final token1Allowance = BigInt.from(400);
      const depositAmount = 20031.2;

      when(() => cubit.approveToken(any(), any())).thenAnswer((_) => Future.value());

      when(() => cubit.state).thenReturn(
        PreviewDepositModalState.initial(
          token0Allowance: depositAmount.parseTokenAmount(decimals: currentYield.token0.decimals),
          token1Allowance: token1Allowance,
        ),
      );

      when(() => cubit.stream).thenAnswer((_) {
        return Stream.value(PreviewDepositModalState.initial(
          token0Allowance: depositAmount.parseTokenAmount(decimals: currentYield.token0.decimals),
          token1Allowance: token1Allowance,
        ));
      });

      await tester.pumpDeviceBuilder(
        await goldenBuilder(token0DepositAmount: depositAmount, token1DepositAmount: depositAmount),
        wrapper: GoldenConfig.localizationsWrapper(),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("deposit-button")));
      await tester.pumpAndSettle();

      verify(
        () => cubit.approveToken(
          currentYield.token1,
          depositAmount.parseTokenAmount(decimals: currentYield.token1.decimals),
        ),
      ).called(1);
    },
  );

  zGoldenTest(
    """When the token0Allowance is higher than the amount to deposit,
    and the token1Allowance is also higher, the deposit button should be
    in the deposit state""",
    goldenFileName: "preview_deposit_modal_deposit_state",
    (tester) async {
      final token0Allowance = 400.parseTokenAmount(decimals: currentYield.token0.decimals);
      final token1Allowance = 1200.parseTokenAmount(decimals: currentYield.token1.decimals);

      const deposit0Amount = 100.2;
      const deposit1Amount = 110.2;

      when(() => cubit.state).thenReturn(
        PreviewDepositModalState.initial(
          token0Allowance: token0Allowance,
          token1Allowance: token1Allowance,
        ),
      );

      when(() => cubit.stream).thenAnswer((_) {
        return Stream.value(PreviewDepositModalState.initial(
          token0Allowance: token0Allowance,
          token1Allowance: token1Allowance,
        ));
      });

      await tester.pumpDeviceBuilder(
        await goldenBuilder(token0DepositAmount: deposit0Amount, token1DepositAmount: deposit1Amount),
        wrapper: GoldenConfig.localizationsWrapper(),
      );
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    """When the token0Allowance is higher than the amount to deposit,
    and the token1Allowance is also higher, the deposit button should be
    in the deposit state. Once the deposit button is clicked, it should call
    the deposit function in the cubit passing the correct params (got from the constructor)""",
    (tester) async {
      final token0Allowance = 400.parseTokenAmount(decimals: currentYield.token0.decimals);
      final token1Allowance = 1200.parseTokenAmount(decimals: currentYield.token1.decimals);

      const deposit0Amount = 100.2;
      const deposit1Amount = 110.2;
      const deadline = Duration(minutes: 653);
      const isReversed = false;
      const maxPrice = 1299.32;
      const minPrice = 100.32;
      const slippage = Slippage.halfPercent;
      const isMaxPriceInfinity = false;
      const isMinPriceInfinity = false;

      when(() => cubit.state).thenReturn(
        PreviewDepositModalState.initial(
          token0Allowance: token0Allowance,
          token1Allowance: token1Allowance,
        ),
      );

      when(() => cubit.stream).thenAnswer((_) {
        return Stream.value(PreviewDepositModalState.initial(
          token0Allowance: token0Allowance,
          token1Allowance: token1Allowance,
        ));
      });

      await tester.pumpDeviceBuilder(
        await goldenBuilder(
          token0DepositAmount: deposit0Amount,
          token1DepositAmount: deposit1Amount,
          deadline: deadline,
          isReversed: isReversed,
          minPrice: (isInfinity: isMinPriceInfinity, price: minPrice),
          maxPrice: (isInfinity: isMaxPriceInfinity, price: maxPrice),
          slippage: slippage,
        ),
        wrapper: GoldenConfig.localizationsWrapper(),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("deposit-button")));
      await tester.pumpAndSettle();

      verify(
        () => cubit.deposit(
          deadline: deadline,
          isReversed: isReversed,
          isMaxPriceInfinity: isMaxPriceInfinity,
          isMinPriceInfinity: isMinPriceInfinity,
          maxPrice: maxPrice,
          minPrice: minPrice,
          slippage: slippage,
          token0Amount: deposit0Amount.parseTokenAmount(decimals: currentYield.token0.decimals),
          token1Amount: deposit1Amount.parseTokenAmount(decimals: currentYield.token1.decimals),
        ),
      ).called(1);
    },
  );

  zGoldenTest(
    "Current price card should show the correct price based on the current tick",
    goldenFileName: "preview_deposit_modal_current_price",
    (tester) async {
      when(() => cubit.latestPoolTick).thenReturn(
        V3PoolConversorsMixinWrapper().priceToTick(
          price: 0.01, // It should be shown in the card (or very close to it)
          poolToken0Decimals: currentYield.token0.decimals,
          poolToken1Decimals: currentYield.token1.decimals,
          isReversed: false,
        ),
      );

      await tester.pumpDeviceBuilder(await goldenBuilder(), wrapper: GoldenConfig.localizationsWrapper());
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    "When it's reversed, the Current price card should show the correct price based on the current tick",
    goldenFileName: "preview_deposit_modal_current_price_reversed",
    (tester) async {
      when(() => cubit.latestPoolTick).thenReturn(
        V3PoolConversorsMixinWrapper().priceToTick(
          price: 1200, // It should be shown in the card (or very close to it)
          poolToken0Decimals: currentYield.token0.decimals,
          poolToken1Decimals: currentYield.token1.decimals,
          isReversed: true,
        ),
      );

      await tester.pumpDeviceBuilder(await goldenBuilder(), wrapper: GoldenConfig.localizationsWrapper());
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key("reverse-tokens")));
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    "When the cubit emits a new tick in the stream, the current price card should update with the new tick",
    goldenFileName: "preview_deposit_modal_current_price_stream",
    (tester) async {
      const newPrice = 0.02632; // It should be shown in the card (or very close to it)
      final newPriceAsTick = V3PoolConversorsMixinWrapper().priceToTick(
        price: newPrice,
        poolToken0Decimals: currentYield.token0.decimals,
        poolToken1Decimals: currentYield.token1.decimals,
        isReversed: false,
      );

      final poolTickStreamController = StreamController<BigInt>.broadcast();
      when(() => cubit.poolTickStream).thenAnswer((_) => poolTickStreamController.stream);

      await tester.pumpDeviceBuilder(await goldenBuilder(), wrapper: GoldenConfig.localizationsWrapper());
      await tester.pumpAndSettle();

      when(() => cubit.latestPoolTick).thenReturn(newPriceAsTick);
      poolTickStreamController.add(newPriceAsTick);

      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    "When the min price is infinity, it should show 0 in the min price card",
    goldenFileName: "preview_deposit_modal_min_price_infinity",
    (tester) async {
      await tester.pumpDeviceBuilder(
        await goldenBuilder(
          minPrice: (
            isInfinity: true,
            price: 125167, // just to be sure that it will not be displayed
          ),
        ),
        wrapper: GoldenConfig.localizationsWrapper(),
      );
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    "When the max price is infinity, it should show the infinity symbol in the max price card",
    goldenFileName: "preview_deposit_modal_max_price_infinity",
    (tester) async {
      await tester.pumpDeviceBuilder(
        await goldenBuilder(
          maxPrice: (
            isInfinity: true,
            price: 125167, // just to be sure that it will not be displayed
          ),
        ),
        wrapper: GoldenConfig.localizationsWrapper(),
      );
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    "The Min price, and max price cards should correctly show the prices passed",
    goldenFileName: "preview_deposit_modal_range_prices",
    (tester) async {
      await tester.pumpDeviceBuilder(
        await goldenBuilder(
          minPrice: (
            isInfinity: false,
            price: 0.04, // It should be shown in the card (or very close to it)
          ),
          maxPrice: (
            isInfinity: false,
            price: 1.2, // It should be shown in the card (or very close to it)
          ),
        ),
        wrapper: GoldenConfig.localizationsWrapper(),
      );
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    """When manually reversing the tokens, the Min price, and max price
    cards should correctly show the prices passed, but converted to the
    current quote token""",
    goldenFileName: "preview_deposit_modal_range_prices_reversed_manually",
    (tester) async {
      await tester.pumpDeviceBuilder(
        await goldenBuilder(
          minPrice: (
            isInfinity: false,
            price: 0.04,
          ),
          maxPrice: (
            isInfinity: false,
            price: 1.2,
          ),
        ),
        wrapper: GoldenConfig.localizationsWrapper(),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("reverse-tokens")));
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    "When the modal starts with the tokens reversed, it should show the min and max prices correctly",
    goldenFileName: "preview_deposit_modal_range_prices_reversed",
    (tester) async {
      await tester.pumpDeviceBuilder(
        await goldenBuilder(
          isReversed: true,
          minPrice: (
            isInfinity: false,
            price: 1200, // It should be shown in the card (or very close to it)
          ),
          maxPrice: (
            isInfinity: false,
            price: 3000, // It should be shown in the card (or very close to it)
          ),
        ),
        wrapper: GoldenConfig.localizationsWrapper(),
      );
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    """When the modal starts with the tokens reversed, then it's manually reversed,
    it should show the min and max prices conversed in the current quote token correctly""",
    goldenFileName: "preview_deposit_modal_range_prices_reversed_manually_reversed",
    (tester) async {
      await tester.pumpDeviceBuilder(
        await goldenBuilder(
          isReversed: true,
          minPrice: (
            isInfinity: false,
            price: 1200,
          ),
          maxPrice: (
            isInfinity: false,
            price: 3000,
          ),
        ),
        wrapper: GoldenConfig.localizationsWrapper(),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("unreverse-tokens")));
      await tester.pumpAndSettle();
    },
  );

  zGoldenTest(
    "When calling `.show` method and the device is mobile, it should should a bottom sheet instead of a dialog",
    goldenFileName: "preview_deposit_modal_show_mobile",
    (tester) async {
      await tester.runAsync(() async {
        await tester.pumpDeviceBuilder(
          await goldenDeviceBuilder(
            Builder(builder: (context) {
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                PreviewDepositModal(
                  depositWithNativeToken: false,
                  currentYield: currentYield,
                  isReversed: true,
                  minPrice: (isInfinity: true, price: 0),
                  maxPrice: (isInfinity: true, price: 0),
                  token0DepositAmount: 1200,
                  token1DepositAmount: 4300,
                  deadline: const Duration(minutes: 30),
                  maxSlippage: Slippage.halfPercent,
                ).show(context, currentPoolTick: BigInt.from(121475));
              });

              return const SizedBox();
            }),
            device: GoldenDevice.mobile,
          ),
          wrapper: GoldenConfig.localizationsWrapper(),
        );
        await tester.pumpAndSettle();
      });
    },
  );

  zGoldenTest(
    "When calling `.show` method and the device is desktop, it should should a dialog instead of a bottom sheet",
    goldenFileName: "preview_deposit_modal_show_desktop",
    (tester) async {
      await tester.runAsync(() async {
        await tester.pumpDeviceBuilder(
          await goldenDeviceBuilder(
            Builder(builder: (context) {
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                PreviewDepositModal(
                  depositWithNativeToken: false,
                  currentYield: currentYield,
                  isReversed: true,
                  minPrice: (isInfinity: true, price: 0),
                  maxPrice: (isInfinity: true, price: 0),
                  token0DepositAmount: 1200,
                  token1DepositAmount: 4300,
                  deadline: const Duration(minutes: 30),
                  maxSlippage: Slippage.halfPercent,
                ).show(context, currentPoolTick: BigInt.from(121475));
              });

              return const SizedBox();
            }),
            device: GoldenDevice.pc,
          ),
          wrapper: GoldenConfig.localizationsWrapper(),
        );
        await tester.pumpAndSettle();
      });
    },
  );

  zGoldenTest(
    """When the state is depositSuccess, it should navigate back to new positions and show a deposit success modal""",
    goldenFileName: "preview_deposit_modal_deposit_success_modal",
    (tester) async {
      when(() => navigator.navigateToNewPosition()).thenAnswer((_) async {});

      when(() => cubit.state).thenReturn(const PreviewDepositModalState.depositSuccess(txId: '21'));
      when(() => cubit.stream).thenAnswer((_) {
        return Stream.value(const PreviewDepositModalState.depositSuccess(txId: '32'));
      });

      await tester.pumpDeviceBuilder(
        await goldenBuilder(),
        wrapper: GoldenConfig.localizationsWrapper(scaffoldMessengerKey: scaffoldMessengerKey),
      );

      await tester.pumpAndSettle();

      verify(() => navigator.navigateToNewPosition()).called(1);
    },
  );
}
