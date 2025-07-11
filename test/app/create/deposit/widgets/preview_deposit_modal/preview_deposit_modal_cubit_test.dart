import 'package:clock/clock.dart';
import 'package:confetti/confetti.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mocktail/mocktail.dart';
import 'package:web3kit/core/core.dart';
import 'package:web3kit/core/dtos/transaction_receipt.dart';
import 'package:web3kit/core/dtos/transaction_response.dart';
import 'package:web3kit/core/exceptions/ethers_exceptions.dart';
import 'package:zup_app/abis/erc_20.abi.g.dart';
import 'package:zup_app/abis/uniswap_permit2.abi.g.dart';
import 'package:zup_app/abis/uniswap_v3_pool.abi.g.dart';
import 'package:zup_app/abis/uniswap_v3_position_manager.abi.g.dart';
import 'package:zup_app/app/create/deposit/widgets/preview_deposit_modal/preview_deposit_modal_cubit.dart';
import 'package:zup_app/core/dtos/token_dto.dart';
import 'package:zup_app/core/dtos/yield_dto.dart';
import 'package:zup_app/core/enums/networks.dart';
import 'package:zup_app/core/enums/pool_type.dart';
import 'package:zup_app/core/injections.dart';
import 'package:zup_app/core/pool_service.dart';
import 'package:zup_app/core/slippage.dart';
import 'package:zup_app/core/v3_v4_pool_constants.dart';
import 'package:zup_app/core/zup_analytics.dart';
import 'package:zup_app/widgets/zup_cached_image.dart';

import '../../../../../golden_config.dart';
import '../../../../../mocks.dart';
import '../../../../../wrappers.dart';

void main() {
  final BigInt initialPoolTick = BigInt.from(21765);
  final YieldDto currentYield = YieldDto.fixture();
  const transactionHash = "0x21";

  late PreviewDepositModalCubit sut;
  late UniswapV3Pool uniswapV3Pool;
  late UniswapV3PoolImpl uniswapV3PoolImpl;
  late Erc20Impl erc20Impl;
  late Erc20 erc20;
  late Wallet wallet;
  late Signer signer;
  late TransactionResponse transactionResponse;
  late UniswapV3PositionManager uniswapPositionManager;
  late UniswapV3PositionManagerImpl uniswapPositionManagerImpl;
  late ZupAnalytics zupAnalytics;
  late UniswapPermit2 permit2;
  late UniswapPermit2Impl permit2Impl;
  late PoolService poolService;

  setUp(() {
    uniswapV3Pool = UniswapV3PoolMock();
    erc20 = Erc20Mock();
    wallet = WalletMock();
    uniswapV3PoolImpl = UniswapV3PoolImplMock();
    erc20Impl = Erc20ImplMock();
    signer = SignerMock();
    transactionResponse = TransactionResponseMock();
    uniswapPositionManager = UniswapV3PositionManagerMock();
    uniswapPositionManagerImpl = UniswapV3PositionManagerImplMock();
    zupAnalytics = ZupAnalyticsMock();
    permit2 = UniswapPermit2Mock();
    permit2Impl = UniswapPermit2ImplMock();
    poolService = PoolServiceMock();

    sut = PreviewDepositModalCubit(
      initialPoolTick: initialPoolTick,
      currentYield: currentYield,
      erc20: erc20,
      wallet: wallet,
      uniswapPositionManager: uniswapPositionManager,
      navigatorKey: GlobalKey(),
      zupAnalytics: zupAnalytics,
      permit2: permit2,
      poolService: poolService,
    );

    registerFallbackValue(const ChainInfo(hexChainId: "0x1"));
    registerFallbackValue(signer);
    registerFallbackValue(BigInt.one);
    registerFallbackValue((amount: BigInt.from(1), token: ""));
    registerFallbackValue(YieldDto.fixture());
    registerFallbackValue(Duration.zero);
    registerFallbackValue((
      amount0Desired: BigInt.zero,
      amount0Min: BigInt.zero,
      amount1Desired: BigInt.zero,
      amount1Min: BigInt.zero,
      deadline: BigInt.zero,
      fee: BigInt.zero,
      recipient: "",
      tickLower: BigInt.zero,
      tickUpper: BigInt.zero,
      token0: "",
      token1: "",
    ));

    when(
      () => zupAnalytics.logDeposit(
          depositedYield: any(named: "depositedYield"),
          amount0: any(named: "amount0"),
          amount1: any(named: "amount1"),
          walletAddress: any(named: "walletAddress")),
    ).thenAnswer((_) async {});

    when(() => wallet.signer).thenReturn(signer);

    when(() => signer.address).thenAnswer((_) async => "0x99E3CfADCD8Feecb5DdF91f88998cFfB3145F78c");

    when(() =>
            uniswapV3Pool.fromRpcProvider(contractAddress: any(named: "contractAddress"), rpcUrl: any(named: "rpcUrl")))
        .thenReturn(uniswapV3PoolImpl);

    when(() => uniswapV3PoolImpl.slot0()).thenAnswer((_) async => (
          feeProtocol: BigInt.zero,
          observationCardinality: BigInt.zero,
          observationCardinalityNext: BigInt.zero,
          observationIndex: BigInt.zero,
          sqrtPriceX96: BigInt.zero,
          tick: initialPoolTick,
          unlocked: true,
        ));

    when(() => permit2.fromSigner(contractAddress: any(named: "contractAddress"), signer: any(named: "signer")))
        .thenReturn(permit2Impl);
    when(() => permit2.fromRpcProvider(contractAddress: any(named: "contractAddress"), rpcUrl: any(named: "rpcUrl")))
        .thenReturn(permit2Impl);

    when(() => erc20.fromRpcProvider(contractAddress: any(named: "contractAddress"), rpcUrl: any(named: "rpcUrl")))
        .thenReturn(erc20Impl);

    when(() => erc20.fromSigner(contractAddress: any(named: "contractAddress"), signer: any(named: "signer")))
        .thenReturn(erc20Impl);

    when(() => erc20Impl.allowance(owner: any(named: "owner"), spender: any(named: "spender")))
        .thenAnswer((_) async => BigInt.zero);

    when(() => erc20Impl.approve(spender: any(named: "spender"), value: any(named: "value")))
        .thenAnswer((_) async => transactionResponse);

    when(() => transactionResponse.hash).thenReturn(transactionHash);

    when(() => transactionResponse.waitConfirmation()).thenAnswer(
      (_) async => TransactionReceipt(hash: transactionHash),
    );

    when(
      () => permit2Impl.approve(
          token: any(named: "token"),
          spender: any(named: "spender"),
          amount: any(named: "amount"),
          expiration: any(named: "expiration")),
    ).thenAnswer((_) async => transactionResponse);

    when(() => permit2Impl.allowance(any(), any(), any())).thenAnswer(
      (_) async => (amount: BigInt.zero, expiration: BigInt.zero, nonce: BigInt.zero),
    );

    when(() => wallet.connectedNetwork).thenAnswer((_) async => currentYield.network.chainInfo);

    when(() => uniswapPositionManager.fromRpcProvider(
        contractAddress: any(named: "contractAddress"),
        rpcUrl: any(named: "rpcUrl"))).thenReturn(uniswapPositionManagerImpl);

    when(() => uniswapPositionManager.fromSigner(contractAddress: any(named: "contractAddress"), signer: signer))
        .thenReturn(uniswapPositionManagerImpl);

    when(
      () => uniswapPositionManagerImpl.mint(
        params: any(named: "params"),
      ),
    ).thenAnswer((_) async => transactionResponse);

    when(() => uniswapPositionManager.getMintCalldata(params: any(named: "params"))).thenReturn("0x");

    when(() => poolService.sendV3PoolDepositTransaction(any(), any(),
        amount0Desired: any(named: "amount0Desired"),
        amount1Desired: any(named: "amount1Desired"),
        amount0Min: any(named: "amount0Min"),
        amount1Min: any(named: "amount1Min"),
        deadline: any(named: "deadline"),
        recipient: any(named: "recipient"),
        tickLower: any(named: "tickLower"),
        tickUpper: any(named: "tickUpper"))).thenAnswer((_) async => transactionResponse);
  });

  void sutCopyWith({
    bool? customDepositWithNative,
    BigInt? customInitialPoolTick,
    UniswapV3Pool? customUniswapV3Pool,
    Erc20? customErc20,
    Wallet? customWallet,
    UniswapV3PositionManager? customUniswapPositionManager,
    YieldDto? customYield,
    GlobalKey<NavigatorState>? customNavigatorKey,
    UniswapPermit2? customPermit2,
    PoolService? customPoolService,
  }) {
    sut = PreviewDepositModalCubit(
      initialPoolTick: customInitialPoolTick ?? initialPoolTick,
      permit2: customPermit2 ?? permit2,
      poolService: customPoolService ?? poolService,
      currentYield: customYield ?? currentYield,
      erc20: customErc20 ?? erc20,
      wallet: customWallet ?? wallet,
      uniswapPositionManager: customUniswapPositionManager ?? uniswapPositionManager,
      navigatorKey: customNavigatorKey ?? GlobalKey(),
      zupAnalytics: zupAnalytics,
    );
  }

  test("The initial state of the cubit should be loading", () {
    expect(sut.state, const PreviewDepositModalState.loading());
  });

  test("After instanciating the cubit, the `latestPoolTick` should be equal to the initial pool tick", () {
    expect(sut.latestPoolTick, initialPoolTick);
  });

  test(
    "When calling `setup` in the cubit, it should immediately emit the initial pool tick",
    () async {
      expectLater(sut.poolTickStream, emits(initialPoolTick));

      await sut.setup();
    },
  );

  test(
    "When calling `setup` it should setup a timer to update the pool tick every one minute",
    () async {
      final expectedEmittedTick = BigInt.from(963287);
      int updatedTimes = 0;
      BigInt latestEmittedTick = BigInt.zero;
      const minutesPassed = 2;

      when(() => poolService.getPoolTick(any())).thenAnswer((_) async => expectedEmittedTick);

      fakeAsync((async) {
        sut.setup();

        sut.poolTickStream.listen((tick) {
          updatedTimes++;
          latestEmittedTick = tick;
        });

        async.elapse(const Duration(minutes: minutesPassed));
      });

      expect(
        updatedTimes,
        minutesPassed,
        reason: "`poolTickStream` should be emitted $minutesPassed times",
      );
      expect(
        latestEmittedTick,
        expectedEmittedTick,
        reason: "`poolTickStream` should be emitted with the updated tick",
      );
      expect(
        sut.latestPoolTick,
        expectedEmittedTick,
        reason: "`latestPoolTick` should be updated",
      );
      verify(() => poolService.getPoolTick(any())).called(2);
    },
  );

  test(
    """When the cubit is closed, but the timer to update the tick have been fired,
     the timer should be canceled, and it should not update the tick""",
    () async {
      fakeAsync((async) {
        sut.setup();
        async.flushMicrotasks();
        sut.close();

        expectLater(sut.poolTickStream, neverEmits(anything));
        async.elapse(const Duration(minutes: 2));

        verifyNever(() => uniswapV3PoolImpl.slot0());
      });
    },
  );

  test(
    """When calling `setup` it should get the yield tokens allowance from the connected signer
    and then emit the initial state with the allowance values""",
    () async {
      final customYield = YieldDto.fixture().copyWith(
        chainId: AppNetworks.sepolia.chainId,
        token0: TokenDto.fixture().copyWith(addresses: {
          AppNetworks.sepolia.chainId: "Token 0 Address",
        }),
        token1: TokenDto.fixture().copyWith(addresses: {
          AppNetworks.sepolia.chainId: "Token 1 Address",
        }),
      );

      sut = PreviewDepositModalCubit(
          uniswapPositionManager: uniswapPositionManager,
          initialPoolTick: initialPoolTick,
          permit2: permit2,
          poolService: poolService,
          currentYield: customYield,
          erc20: erc20,
          wallet: wallet,
          navigatorKey: GlobalKey(),
          zupAnalytics: zupAnalytics);

      final token0Contract = Erc20ImplMock();
      final token1Contract = Erc20ImplMock();
      final token0Allowance = BigInt.from(12345);
      final token1Allowance = BigInt.from(54321);

      when(() => erc20.fromRpcProvider(
          contractAddress: customYield.token0.addresses[customYield.network.chainId]!,
          rpcUrl: any(named: "rpcUrl"))).thenReturn(token0Contract);

      when(() => erc20.fromRpcProvider(
          contractAddress: customYield.token1.addresses[customYield.network.chainId]!,
          rpcUrl: any(named: "rpcUrl"))).thenReturn(token1Contract);

      when(() => token0Contract.allowance(owner: any(named: "owner"), spender: any(named: "spender")))
          .thenAnswer((_) async => token0Allowance);

      when(() => token1Contract.allowance(owner: any(named: "owner"), spender: any(named: "spender")))
          .thenAnswer((_) async => token1Allowance);

      await sut.setup();

      expect(sut.token0Allowance, token0Allowance, reason: "Token 0 allowance is incorrect");
      expect(sut.token1Allowance, token1Allowance, reason: "Token 1 allowance is incorrect");
      expect(
        sut.state,
        PreviewDepositModalState.initial(token0Allowance: token0Allowance, token1Allowance: token1Allowance),
        reason: "Initial state is incorrect",
      );
    },
  );

  test(
    "When calling `approveToken` it should emit the approving token state with the token symbol",
    () async {
      final token = TokenDto.fixture().copyWith(symbol: "TOKE SYMB");

      expectLater(sut.stream, emits(PreviewDepositModalState.approvingToken(token.symbol)));
      await sut.approveToken(token, BigInt.one);
    },
  );

  test(
    """When calling `approveToken` and the current user connected
    network is not the same as the token network, it should
    ask to switch the network""",
    () async {
      const yieldNetwork = AppNetworks.sepolia;
      final customYield = YieldDto.fixture().copyWith(chainId: yieldNetwork.chainId);

      sut = PreviewDepositModalCubit(
          navigatorKey: GlobalKey(),
          initialPoolTick: initialPoolTick,
          permit2: permit2,
          poolService: poolService,
          currentYield: customYield,
          erc20: erc20,
          wallet: wallet,
          uniswapPositionManager: uniswapPositionManager,
          zupAnalytics: zupAnalytics);

      when(() => wallet.switchOrAddNetwork(any())).thenAnswer((_) async {});
      when(() => wallet.connectedNetwork).thenAnswer((_) async => AppNetworks.mainnet.chainInfo);
      when(() => permit2Impl.allowance(any(), any(), any())).thenAnswer(
        (_) async => (amount: BigInt.zero, expiration: BigInt.zero, nonce: BigInt.zero),
      );

      await sut.approveToken(currentYield.token0, BigInt.from(32761));

      verify(() => wallet.switchOrAddNetwork(yieldNetwork.chainInfo)).called(1);
    },
  );

  test(
    """When calling `approveToken` and the current user connected
    network is the same as the token network, it should not
    ask to switch the network""",
    () async {
      const yieldNetwork = AppNetworks.sepolia;
      final customYield = YieldDto.fixture().copyWith(chainId: yieldNetwork.chainId);

      sut = PreviewDepositModalCubit(
          navigatorKey: GlobalKey(),
          uniswapPositionManager: uniswapPositionManager,
          initialPoolTick: initialPoolTick,
          permit2: permit2,
          poolService: poolService,
          currentYield: customYield,
          erc20: erc20,
          wallet: wallet,
          zupAnalytics: zupAnalytics);

      when(() => wallet.switchOrAddNetwork(any())).thenAnswer((_) async {});
      when(() => wallet.connectedNetwork).thenAnswer((_) async => yieldNetwork.chainInfo);

      await sut.approveToken(currentYield.token0, BigInt.from(121));

      verifyNever(() => wallet.switchOrAddNetwork(yieldNetwork.chainInfo));
    },
  );

  test(
    """When calling `approveToken` it should connect to the erc20 contract with the current signer,
    and call the `approve` function with the protocol position manager as spender and the amount as value""",
    () async {
      final token = currentYield.token0;
      final tokenAmount = BigInt.from(121);

      when(() => erc20.fromSigner(contractAddress: any(named: "contractAddress"), signer: any(named: "signer")))
          .thenReturn(erc20Impl);

      when(() => erc20Impl.approve(spender: any(named: "spender"), value: any(named: "value")))
          .thenAnswer((_) async => transactionResponse);

      when(() => transactionResponse.waitConfirmation()).thenAnswer((_) async => TransactionReceipt(hash: ""));

      await sut.approveToken(token, tokenAmount);

      verify(() => erc20.fromSigner(contractAddress: token.addresses[currentYield.chainId]!, signer: signer)).called(1);
      verify(() => erc20Impl.approve(spender: currentYield.positionManagerAddress, value: tokenAmount)).called(1);
    },
  );

  test("""When calling `approve token`, after the transaction
   to the contract it sent, it should emit the waiting transaction state
   with the transaction hash
   """, () async {
    bool callbackCalled = false;

    when(() => erc20Impl.approve(spender: any(named: "spender"), value: any(named: "value"))).thenAnswer(
      (_) async {
        const txId = "0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef";
        when(() => transactionResponse.hash).thenReturn(txId);
        expectLater(
          sut.stream,
          emits(
            const PreviewDepositModalState.waitingTransaction(txId: txId, type: WaitingTransactionType.approve),
          ),
        );

        callbackCalled = true;
        return transactionResponse;
      },
    );

    await sut.approveToken(currentYield.token0, BigInt.two);

    // Check that the callback above in the approval is called to validate the test
    expect(callbackCalled, true);
  });

  test(
    """When calling `approveToken` it should wait for the transaction
     to be confirmed in the waiting transaction state""",
    () async {
      const txId = "0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef";
      bool callbackCalled = false;

      when(() => transactionResponse.hash).thenReturn(txId);

      when(() => transactionResponse.waitConfirmation()).thenAnswer((_) async {
        expect(
          sut.state,
          const PreviewDepositModalState.waitingTransaction(txId: txId, type: WaitingTransactionType.approve),
        );

        callbackCalled = true;
        return TransactionReceipt(hash: "");
      });

      await sut.approveToken(currentYield.token0, BigInt.one);

      // Check that the callback above in the waitConfirmation is called to validate the test
      expect(callbackCalled, true);
    },
  );

  test(
    "When calling `approveToken` for the token0, the token0 allowance should be updated and the token1 allowance should be the same as before",
    () async {
      final expectedToken0Allowance = BigInt.from(12345);

      final token0Erc20Impl = Erc20ImplMock();

      when(() => erc20.fromRpcProvider(
          contractAddress: currentYield.token0.addresses[currentYield.chainId]!,
          rpcUrl: any(named: "rpcUrl"))).thenReturn(token0Erc20Impl);

      when(() => token0Erc20Impl.allowance(owner: any(named: "owner"), spender: any(named: "spender"))).thenAnswer(
        (_) async => expectedToken0Allowance,
      );

      await sut.approveToken(currentYield.token0, expectedToken0Allowance);

      expect(sut.token0Allowance, expectedToken0Allowance);

      expect(
        sut.token1Allowance,
        BigInt.zero,
        reason: "token1 allowance should be 0 because it has not been approved yet",
      );
    },
  );

  test(
    "When calling `approveToken` for the token1, the token1 allowance should be updated and the token0 allowance should be the same as before",
    () async {
      final expectedToken1Allowance = BigInt.from(12345);

      final token1Erc20Impl = Erc20ImplMock();

      when(() => erc20.fromRpcProvider(
          contractAddress: currentYield.token1.addresses[currentYield.chainId]!,
          rpcUrl: any(named: "rpcUrl"))).thenReturn(token1Erc20Impl);

      when(() => token1Erc20Impl.allowance(owner: any(named: "owner"), spender: any(named: "spender"))).thenAnswer(
        (_) async => expectedToken1Allowance,
      );

      await sut.approveToken(currentYield.token1, expectedToken1Allowance);

      expect(sut.token1Allowance, expectedToken1Allowance);
      expect(
        sut.token0Allowance,
        BigInt.zero,
        reason: "token0 allowance should be 0 because it has not been approved yet",
      );
    },
  );

  test(
    """When calling `approveToken` with the token0 and everything is ok,
    it should emit the approve success state and right after,
    the initial state with the updated allowance got from the contract again
    """,
    () async {
      final token0Allowance = BigInt.from(12345);
      final token0Erc20Impl = Erc20ImplMock();

      when(() => erc20.fromRpcProvider(
          contractAddress: currentYield.token0.addresses[currentYield.chainId]!,
          rpcUrl: any(named: "rpcUrl"))).thenReturn(token0Erc20Impl);

      when(() => token0Erc20Impl.allowance(owner: any(named: "owner"), spender: any(named: "spender"))).thenAnswer(
        (_) async => token0Allowance,
      );

      expectLater(
          sut.stream,
          emitsInOrder([
            anything,
            anything,
            PreviewDepositModalState.approveSuccess(txId: transactionResponse.hash, symbol: currentYield.token0.symbol),
            PreviewDepositModalState.initial(token0Allowance: token0Allowance, token1Allowance: BigInt.zero),
          ]));

      await sut.approveToken(currentYield.token0, token0Allowance);

      verify(() => token0Erc20Impl.allowance(owner: any(named: "owner"), spender: any(named: "spender"))).called(1);
    },
  );

  test(
    """When calling `approveToken` with the token1 and everything is ok,
    it should emit the approve success state and right after,
    the initial state with the updated allowance got from the contract again
    """,
    () async {
      final token1Allowance = BigInt.from(12345);
      final token1Erc20Impl = Erc20ImplMock();

      when(() => erc20.fromRpcProvider(
          contractAddress: currentYield.token1.addresses[currentYield.chainId]!,
          rpcUrl: any(named: "rpcUrl"))).thenReturn(token1Erc20Impl);

      when(() => token1Erc20Impl.allowance(owner: any(named: "owner"), spender: any(named: "spender"))).thenAnswer(
        (_) async => token1Allowance,
      );

      expectLater(
          sut.stream,
          emitsInOrder([
            anything,
            anything,
            PreviewDepositModalState.approveSuccess(txId: transactionResponse.hash, symbol: currentYield.token1.symbol),
            PreviewDepositModalState.initial(token0Allowance: BigInt.zero, token1Allowance: token1Allowance),
          ]));

      await sut.approveToken(currentYield.token1, token1Allowance);

      verify(() => token1Erc20Impl.allowance(owner: any(named: "owner"), spender: any(named: "spender"))).called(1);
    },
  );

  test(
    """When calling `approveToken` with the token1, the approve transaction is ok,
    but the get allowance from the contract call fail, it should emit the initial
    state with the allowance value passed to approve
    """,
    () async {
      final token1Allowance = BigInt.from(12345);

      when(() => erc20Impl.allowance(owner: any(named: "owner"), spender: any(named: "spender")))
          .thenThrow("dale error");

      expectLater(
          sut.stream,
          emitsInOrder([
            anything,
            anything,
            anything,
            PreviewDepositModalState.initial(token0Allowance: BigInt.zero, token1Allowance: token1Allowance),
          ]));

      await sut.approveToken(currentYield.token1, token1Allowance);
    },
  );

  test(
    """When calling `approveToken` with the token0, the approve transaction is ok,
    but the get allowance from the contract call fail, it should emit the initial
    state with the allowance value passed to approve
    """,
    () async {
      final token0Allowance = BigInt.from(439868);

      when(() => erc20Impl.allowance(owner: any(named: "owner"), spender: any(named: "spender")))
          .thenThrow("dale error");

      expectLater(
          sut.stream,
          emitsInOrder([
            anything,
            anything,
            anything,
            PreviewDepositModalState.initial(token0Allowance: token0Allowance, token1Allowance: BigInt.zero),
          ]));

      await sut.approveToken(currentYield.token0, token0Allowance);
    },
  );

  test(
    """When calling `approveToken` an error is thrown, and it's
    that the user rejected the action, it should emit the initial state""",
    () async {
      when(() => erc20Impl.approve(spender: any(named: "spender"), value: any(named: "value"))).thenThrow(
        UserRejectedAction(),
      );

      await sut.approveToken(currentYield.token0, BigInt.one);

      expect(
        sut.state,
        PreviewDepositModalState.initial(token0Allowance: BigInt.zero, token1Allowance: BigInt.zero),
      );
    },
  );

  test(
    """When calling `approveToken` an error is thrown, and it's not
    that the user rejected the action, it should emit the transaction error state,
    and right after the initial state""",
    () async {
      when(() => erc20Impl.approve(spender: any(named: "spender"), value: any(named: "value"))).thenThrow(Exception());

      expectLater(
          sut.stream,
          emitsInOrder([
            anything,
            const PreviewDepositModalState.transactionError(),
            PreviewDepositModalState.initial(token0Allowance: BigInt.zero, token1Allowance: BigInt.zero),
          ]));

      await sut.approveToken(currentYield.token0, BigInt.one);
    },
  );

  test("When calling `deposit` it should emit the depositing state", () async {
    expectLater(sut.stream, emits(const PreviewDepositModalState.depositing()));

    await sut.deposit(
      deadline: const Duration(minutes: 30),
      slippage: Slippage.halfPercent,
      token0Amount: BigInt.one,
      token1Amount: BigInt.one,
      minPrice: 0,
      maxPrice: 0,
      isMinPriceInfinity: false,
      isMaxPriceInfinity: false,
      isReversed: false,
    );
  });

  test(
    """When calling `deposit` and the signer connected network is
    different from the yield network, it should ask the user to switch network""",
    () async {
      final connectedNetwork = AppNetworks.mainnet.chainInfo;
      final yieldNetwork = AppNetworks.sepolia.chainInfo;

      when(() => wallet.connectedNetwork).thenAnswer((_) async => connectedNetwork);

      await sut.deposit(
        token0Amount: BigInt.one,
        token1Amount: BigInt.one,
        deadline: const Duration(minutes: 30),
        slippage: Slippage.halfPercent,
        minPrice: 0,
        maxPrice: 0,
        isMinPriceInfinity: false,
        isMaxPriceInfinity: false,
        isReversed: false,
      );

      verify(() => wallet.switchOrAddNetwork(yieldNetwork)).called(1);
    },
  );

  test(
    """When calling `deposit` and the signer connected network is
    the same from the yield network, it should not ask the user
    to switch network""",
    () async {
      final connectedNetwork = AppNetworks.sepolia.chainInfo;
      final yieldNetwork = AppNetworks.sepolia.chainInfo;

      when(() => wallet.connectedNetwork).thenAnswer((_) async => connectedNetwork);

      await sut.deposit(
        token0Amount: BigInt.one,
        token1Amount: BigInt.one,
        deadline: const Duration(minutes: 30),
        slippage: Slippage.halfPercent,
        minPrice: 0,
        maxPrice: 0,
        isMinPriceInfinity: false,
        isMaxPriceInfinity: false,
        isReversed: false,
      );

      verifyNever(() => wallet.switchOrAddNetwork(yieldNetwork));
    },
  );

  test("When calling `deposit`, the tokens amount sent to the pool service to deposit should be correct", () async {
    final token0Amount = BigInt.from(32421);
    final token1Amount = BigInt.from(8729889);

    await sut.deposit(
      token0Amount: token0Amount,
      token1Amount: token1Amount,
      deadline: const Duration(minutes: 30),
      slippage: Slippage.halfPercent,
      minPrice: 1200,
      maxPrice: 3000,
      isMinPriceInfinity: false,
      isMaxPriceInfinity: false,
      isReversed: false,
    );

    verify(
      () => poolService.sendV3PoolDepositTransaction(
        any(),
        any(),
        amount0Desired: token0Amount,
        amount1Desired: token1Amount,
        amount0Min: any(named: "amount0Min"),
        amount1Min: any(named: "amount1Min"),
        deadline: any(named: "deadline"),
        recipient: any(named: "recipient"),
        tickLower: any(named: "tickLower"),
        tickUpper: any(named: "tickUpper"),
      ),
    );
  });

  test(
    """When calling `deposit`, the amount1Min sent to the pool service to deposit
    should be the one calculated from the slippage""",
    () async {
      final token1Amount = BigInt.from(6721);
      const slippage = Slippage.halfPercent;

      when(() => uniswapPositionManager.getMintCalldata(params: any(named: "params"))).thenReturn("");

      sutCopyWith(customDepositWithNative: true);

      await sut.deposit(
        token0Amount: BigInt.one,
        token1Amount: token1Amount,
        deadline: const Duration(minutes: 30),
        slippage: slippage,
        minPrice: 0,
        maxPrice: 0,
        isMinPriceInfinity: true,
        isMaxPriceInfinity: true,
        isReversed: false,
      );

      verify(
        () => poolService.sendV3PoolDepositTransaction(
          any(),
          any(),
          amount0Desired: any(named: "amount0Desired"),
          amount1Desired: any(named: "amount1Desired"),
          amount0Min: any(named: "amount0Min"),
          amount1Min: slippage.calculateMinTokenAmountFromSlippage(token1Amount),
          deadline: any(named: "deadline"),
          recipient: any(named: "recipient"),
          tickLower: any(named: "tickLower"),
          tickUpper: any(named: "tickUpper"),
        ),
      ).called(1);
    },
  );

  test(
    """When calling `deposit`, the amount0Min sent to the pool service to deposit
    should be the one calculated from the slippage""",
    () async {
      final token0Amount = BigInt.from(32421);
      final slippage = Slippage.fromValue(50);

      when(() => uniswapPositionManager.getMintCalldata(params: any(named: "params"))).thenReturn("");
      sutCopyWith(customDepositWithNative: true);

      await sut.deposit(
        token0Amount: token0Amount,
        token1Amount: BigInt.one,
        deadline: const Duration(minutes: 30),
        slippage: slippage,
        minPrice: 0,
        maxPrice: 0,
        isMinPriceInfinity: true,
        isMaxPriceInfinity: true,
        isReversed: false,
      );

      verify(
        () => poolService.sendV3PoolDepositTransaction(
          any(),
          any(),
          amount0Desired: any(named: "amount0Desired"),
          amount1Desired: any(named: "amount1Desired"),
          amount0Min: slippage.calculateMinTokenAmountFromSlippage(token0Amount),
          amount1Min: any(named: "amount1Min"),
          deadline: any(named: "deadline"),
          recipient: any(named: "recipient"),
          tickLower: any(named: "tickLower"),
          tickUpper: any(named: "tickUpper"),
        ),
      ).called(1);
    },
  );

  test(
    "When calling `deposit`, the recipient sent to the pool service to deposit should be the signer address",
    () async {
      const signerAddress = "0x0000000000000000000000000000000000000231";
      when(() => signer.address).thenAnswer((_) async => signerAddress);

      sutCopyWith(customDepositWithNative: true);

      await sut.deposit(
        token0Amount: BigInt.one,
        token1Amount: BigInt.one,
        deadline: const Duration(minutes: 30),
        slippage: Slippage.halfPercent,
        minPrice: 0,
        maxPrice: 0,
        isMinPriceInfinity: true,
        isMaxPriceInfinity: true,
        isReversed: false,
      );

      verify(
        () => poolService.sendV3PoolDepositTransaction(
          any(),
          any(),
          amount0Desired: any(named: "amount0Desired"),
          amount1Desired: any(named: "amount1Desired"),
          amount0Min: any(named: "amount0Min"),
          amount1Min: any(named: "amount1Min"),
          deadline: any(named: "deadline"),
          recipient: signerAddress,
          tickLower: any(named: "tickLower"),
          tickUpper: any(named: "tickUpper"),
        ),
      ).called(1);
    },
  );

  test("""When calling `deposit` the minPrice is infinity, and is not reversed,
      the tick lower send to the pool service should be the min tick (adjusted for the tick spacing)""", () async {
    sutCopyWith(customDepositWithNative: true);

    await sut.deposit(
      token0Amount: BigInt.one,
      token1Amount: BigInt.one,
      deadline: const Duration(minutes: 30),
      slippage: Slippage.halfPercent,
      minPrice: 0,
      maxPrice: 3000,
      isMinPriceInfinity: true,
      isMaxPriceInfinity: false,
      isReversed: false,
    );

    verify(
      () => poolService.sendV3PoolDepositTransaction(
        any(),
        any(),
        amount0Desired: any(named: "amount0Desired"),
        amount1Desired: any(named: "amount1Desired"),
        amount0Min: any(named: "amount0Min"),
        amount1Min: any(named: "amount1Min"),
        deadline: any(named: "deadline"),
        recipient: any(named: "recipient"),
        tickLower: V3PoolConversorsMixinWrapper().tickToClosestValidTick(
          tick: V3V4PoolConstants.minTick,
          tickSpacing: currentYield.tickSpacing,
        ),
        tickUpper: any(named: "tickUpper"),
      ),
    ).called(1);
  });

  test("""When calling `deposit` with the maxPrice infinity, and reversed,
      the tick lower sent to the pool service should be the min tick
      (but adjusted for the tick spacing)""", () async {
    sutCopyWith(customDepositWithNative: true);

    await sut.deposit(
      token0Amount: BigInt.one,
      token1Amount: BigInt.one,
      deadline: const Duration(minutes: 30),
      slippage: Slippage.halfPercent,
      minPrice: 1200,
      maxPrice: 0,
      isMinPriceInfinity: false,
      isMaxPriceInfinity: true,
      isReversed: true,
    );

    verify(
      () => poolService.sendV3PoolDepositTransaction(
        any(),
        any(),
        amount0Desired: any(named: "amount0Desired"),
        amount1Desired: any(named: "amount1Desired"),
        amount0Min: any(named: "amount0Min"),
        amount1Min: any(named: "amount1Min"),
        deadline: any(named: "deadline"),
        recipient: any(named: "recipient"),
        tickLower: V3PoolConversorsMixinWrapper().tickToClosestValidTick(
          tick: V3V4PoolConstants.minTick,
          tickSpacing: currentYield.tickSpacing,
        ),
        tickUpper: any(named: "tickUpper"),
      ),
    ).called(1);
  });

  test(
    "When calling `deposit` with a min price that is not infinity, it should calculate the correct tickLower and send it to the pool service",
    () async {
      sutCopyWith(customDepositWithNative: true);

      const minPrice = 1200.0;

      await sut.deposit(
        token0Amount: BigInt.one,
        token1Amount: BigInt.one,
        deadline: const Duration(minutes: 30),
        slippage: Slippage.halfPercent,
        minPrice: minPrice,
        maxPrice: 0,
        isMinPriceInfinity: false,
        isMaxPriceInfinity: true,
        isReversed: false,
      );

      verify(
        () => poolService.sendV3PoolDepositTransaction(
          any(),
          any(),
          amount0Desired: any(named: "amount0Desired"),
          amount1Desired: any(named: "amount1Desired"),
          amount0Min: any(named: "amount0Min"),
          amount1Min: any(named: "amount1Min"),
          deadline: any(named: "deadline"),
          recipient: any(named: "recipient"),
          tickLower: V3PoolConversorsMixinWrapper().tickToClosestValidTick(
            tick: V3PoolConversorsMixinWrapper().priceToTick(
              price: minPrice,
              poolToken0Decimals: currentYield.token0NetworkDecimals,
              poolToken1Decimals: currentYield.token1NetworkDecimals,
              isReversed: false,
            ),
            tickSpacing: currentYield.tickSpacing,
          ),
          tickUpper: any(named: "tickUpper"),
        ),
      ).called(1);
    },
  );

  test(
    """When calling `deposit` with a max price that is not infinity, and it's reversed,
    it should calculate the correct tickLower and, using the max price
    (because it's reversed), and send it to the pool service
    """,
    () async {
      sutCopyWith(customDepositWithNative: true);

      const maxPrice = 3000.0;
      const isReversed = true;

      await sut.deposit(
        token0Amount: BigInt.one,
        token1Amount: BigInt.one,
        deadline: const Duration(minutes: 30),
        slippage: Slippage.halfPercent,
        minPrice: 1200,
        maxPrice: maxPrice,
        isMinPriceInfinity: false,
        isMaxPriceInfinity: false,
        isReversed: isReversed,
      );

      verify(
        () => poolService.sendV3PoolDepositTransaction(
          any(),
          any(),
          amount0Desired: any(named: "amount0Desired"),
          amount1Desired: any(named: "amount1Desired"),
          amount0Min: any(named: "amount0Min"),
          amount1Min: any(named: "amount1Min"),
          deadline: any(named: "deadline"),
          recipient: any(named: "recipient"),
          tickLower: V3PoolConversorsMixinWrapper().tickToClosestValidTick(
            tick: V3PoolConversorsMixinWrapper().priceToTick(
              price: maxPrice,
              poolToken0Decimals: currentYield.token0NetworkDecimals,
              poolToken1Decimals: currentYield.token1NetworkDecimals,
              isReversed: isReversed,
            ),
            tickSpacing: currentYield.tickSpacing,
          ),
          tickUpper: any(named: "tickUpper"),
        ),
      ).called(1);
    },
  );

  test(
    """When calling `deposit` with a max price that is infinity, and it's not reversed,
    the tick upper should be the max tick (but adjusted for the tick spacing)""",
    () async {
      sutCopyWith(customDepositWithNative: true);

      await sut.deposit(
        token0Amount: BigInt.one,
        token1Amount: BigInt.one,
        deadline: const Duration(minutes: 30),
        slippage: Slippage.halfPercent,
        minPrice: 1200,
        maxPrice: 0,
        isMinPriceInfinity: false,
        isMaxPriceInfinity: true,
        isReversed: false,
      );

      verify(
        () => poolService.sendV3PoolDepositTransaction(
          any(),
          any(),
          amount0Desired: any(named: "amount0Desired"),
          amount1Desired: any(named: "amount1Desired"),
          amount0Min: any(named: "amount0Min"),
          amount1Min: any(named: "amount1Min"),
          deadline: any(named: "deadline"),
          recipient: any(named: "recipient"),
          tickLower: any(named: "tickLower"),
          tickUpper: V3PoolConversorsMixinWrapper().tickToClosestValidTick(
            tick: V3V4PoolConstants.maxTick,
            tickSpacing: currentYield.tickSpacing,
          ),
        ),
      ).called(1);
    },
  );

  test(
    """When calling `deposit` with a min price that is infinity, and it's reversed,
    the tick upper should be the max tick (but adjusted for the tick spacing)""",
    () async {
      sutCopyWith(customDepositWithNative: true);

      const maxPrice = 3000.0;
      const isReversed = true;

      await sut.deposit(
        deadline: const Duration(minutes: 30),
        slippage: Slippage.halfPercent,
        token0Amount: BigInt.one,
        token1Amount: BigInt.one,
        minPrice: 0,
        maxPrice: maxPrice,
        isMinPriceInfinity: true,
        isMaxPriceInfinity: false,
        isReversed: isReversed,
      );
      verify(
        () => poolService.sendV3PoolDepositTransaction(
          any(),
          any(),
          amount0Desired: any(named: "amount0Desired"),
          amount1Desired: any(named: "amount1Desired"),
          amount0Min: any(named: "amount0Min"),
          amount1Min: any(named: "amount1Min"),
          deadline: any(named: "deadline"),
          recipient: any(named: "recipient"),
          tickLower: any(named: "tickLower"),
          tickUpper: V3PoolConversorsMixinWrapper().tickToClosestValidTick(
            tick: V3V4PoolConstants.maxTick,
            tickSpacing: currentYield.tickSpacing,
          ),
        ),
      ).called(1);
    },
  );

  test(
    """When calling `deposit` with a max price that is not infinity,
    and it's not reversed, the tick upper should be
    calculated based on the max price""",
    () async {
      sutCopyWith(customDepositWithNative: true);

      const maxPrice = 3000.50;

      await sut.deposit(
        deadline: const Duration(minutes: 30),
        slippage: Slippage.halfPercent,
        token0Amount: BigInt.one,
        token1Amount: BigInt.one,
        minPrice: 1200,
        maxPrice: maxPrice,
        isMinPriceInfinity: false,
        isMaxPriceInfinity: false,
        isReversed: false,
      );

      verify(
        () => poolService.sendV3PoolDepositTransaction(
          any(),
          any(),
          amount0Desired: any(named: "amount0Desired"),
          amount1Desired: any(named: "amount1Desired"),
          amount0Min: any(named: "amount0Min"),
          amount1Min: any(named: "amount1Min"),
          deadline: any(named: "deadline"),
          recipient: any(named: "recipient"),
          tickLower: any(named: "tickLower"),
          tickUpper: V3PoolConversorsMixinWrapper().tickToClosestValidTick(
            tick: V3PoolConversorsMixinWrapper().priceToTick(
              price: maxPrice,
              poolToken0Decimals: currentYield.token0NetworkDecimals,
              poolToken1Decimals: currentYield.token1NetworkDecimals,
              isReversed: false,
            ),
            tickSpacing: currentYield.tickSpacing,
          ),
        ),
      ).called(1);
    },
  );

  test(
    """When calling `deposit` with a max price that is not infinity,
    and it's reversed, the tick upper should be
    calculated based on the min price""",
    () async {
      sutCopyWith(customDepositWithNative: true);

      const minPrice = 50.32;
      const isReversed = true;

      await sut.deposit(
        deadline: const Duration(minutes: 30),
        slippage: Slippage.halfPercent,
        token0Amount: BigInt.one,
        token1Amount: BigInt.one,
        minPrice: minPrice,
        maxPrice: 300.50,
        isMinPriceInfinity: false,
        isMaxPriceInfinity: false,
        isReversed: isReversed,
      );

      verify(
        () => poolService.sendV3PoolDepositTransaction(
          any(),
          any(),
          amount0Desired: any(named: "amount0Desired"),
          amount1Desired: any(named: "amount1Desired"),
          amount0Min: any(named: "amount0Min"),
          amount1Min: any(named: "amount1Min"),
          deadline: any(named: "deadline"),
          recipient: any(named: "recipient"),
          tickLower: any(named: "tickLower"),
          tickUpper: V3PoolConversorsMixinWrapper().tickToClosestValidTick(
            tick: V3PoolConversorsMixinWrapper().priceToTick(
              price: minPrice,
              poolToken0Decimals: currentYield.token0NetworkDecimals,
              poolToken1Decimals: currentYield.token1NetworkDecimals,
              isReversed: isReversed,
            ),
            tickSpacing: currentYield.tickSpacing,
          ),
        ),
      ).called(1);
    },
  );

  test(
    "When calling `deposit`, after the transcation to deposit is sent, it should emit the waiting transaction state",
    () async {
      const txId = "0x123456789";
      bool callbackCalled = false;

      when(() => transactionResponse.hash).thenReturn(txId);
      when(
        () => poolService.sendV3PoolDepositTransaction(
          any(),
          any(),
          amount0Desired: any(named: "amount0Desired"),
          amount1Desired: any(named: "amount1Desired"),
          amount0Min: any(named: "amount0Min"),
          amount1Min: any(named: "amount1Min"),
          deadline: any(named: "deadline"),
          recipient: any(named: "recipient"),
          tickLower: any(named: "tickLower"),
          tickUpper: any(named: "tickUpper"),
        ),
      ).thenAnswer((_) async {
        expectLater(
          sut.stream,
          emits(
            const PreviewDepositModalState.waitingTransaction(txId: txId, type: WaitingTransactionType.deposit),
          ),
        );

        callbackCalled = true;

        return transactionResponse;
      });

      await sut.deposit(
        deadline: const Duration(minutes: 30),
        slippage: Slippage.halfPercent,
        token0Amount: BigInt.one,
        token1Amount: BigInt.one,
        minPrice: 1200,
        maxPrice: 3000.50,
        isMinPriceInfinity: false,
        isMaxPriceInfinity: false,
        isReversed: false,
      );

      // Making sure that the callback above in the thenAnswer is called, which is the real test
      expect(callbackCalled, true);
    },
  );

  test(
    """When calling `deposit`, after it sending the transaction,
  it should wait for the transaction to be confirmed, in the
  waiting transaction state""",
    () async {
      const txId = "0x123456789";
      bool callbackCalled = false;

      when(() => transactionResponse.hash).thenReturn(txId);
      when(() => transactionResponse.waitConfirmation()).thenAnswer((_) async {
        expect(
          sut.state,
          const PreviewDepositModalState.waitingTransaction(txId: txId, type: WaitingTransactionType.deposit),
        );

        callbackCalled = true;

        return TransactionReceipt(hash: "");
      });

      await sut.deposit(
        deadline: const Duration(minutes: 30),
        slippage: Slippage.halfPercent,
        token0Amount: BigInt.one,
        token1Amount: BigInt.one,
        minPrice: 1200,
        maxPrice: 3000.50,
        isMinPriceInfinity: false,
        isMaxPriceInfinity: false,
        isReversed: false,
      );

      // Making sure that the callback above in the thenAnswer is called, which is the real test
      expect(callbackCalled, true);
    },
  );

  test(
    "When calling `deposit`, after the transaction is confirmed, it should emit the deposit success state",
    () async {
      const txId = "0x123456789";

      when(() => transactionResponse.hash).thenReturn(txId);

      await sut.deposit(
        deadline: const Duration(minutes: 30),
        slippage: Slippage.halfPercent,
        token0Amount: BigInt.one,
        token1Amount: BigInt.one,
        minPrice: 1200,
        maxPrice: 3000.50,
        isMinPriceInfinity: false,
        isMaxPriceInfinity: false,
        isReversed: false,
      );

      expect(sut.state, const PreviewDepositModalState.depositSuccess(txId: txId));
    },
  );

  test(
    """When calling `deposit` and an error occur while depositing, it should emit the transaction error state,
    and right after, it should emit the initial state""",
    () async {
      when(
        () => poolService.sendV3PoolDepositTransaction(
          any(),
          any(),
          amount0Desired: any(named: "amount0Desired"),
          amount1Desired: any(named: "amount1Desired"),
          amount0Min: any(named: "amount0Min"),
          amount1Min: any(named: "amount1Min"),
          deadline: any(named: "deadline"),
          recipient: any(named: "recipient"),
          tickLower: any(named: "tickLower"),
          tickUpper: any(named: "tickUpper"),
        ),
      ).thenThrow("dale error");

      expectLater(
        sut.stream,
        emitsInOrder([
          anything,
          const PreviewDepositModalState.transactionError(),
          PreviewDepositModalState.initial(token0Allowance: BigInt.zero, token1Allowance: BigInt.zero),
        ]),
      );

      await sut.deposit(
        deadline: const Duration(minutes: 30),
        slippage: Slippage.halfPercent,
        token0Amount: BigInt.one,
        token1Amount: BigInt.one,
        minPrice: 1200,
        maxPrice: 3000.50,
        isMinPriceInfinity: false,
        isMaxPriceInfinity: false,
        isReversed: false,
      );
    },
  );

  test(
    "When calling `deposit` and an error of User rejected action occurs, it should emit the initial state",
    () async {
      when(
        () => poolService.sendV3PoolDepositTransaction(
          any(),
          any(),
          amount0Desired: any(named: "amount0Desired"),
          amount1Desired: any(named: "amount1Desired"),
          amount0Min: any(named: "amount0Min"),
          amount1Min: any(named: "amount1Min"),
          deadline: any(named: "deadline"),
          recipient: any(named: "recipient"),
          tickLower: any(named: "tickLower"),
          tickUpper: any(named: "tickUpper"),
        ),
      ).thenThrow(UserRejectedAction());

      expectLater(
        sut.stream,
        emitsInOrder([
          anything,
          PreviewDepositModalState.initial(token0Allowance: BigInt.zero, token1Allowance: BigInt.zero),
        ]),
      );

      await sut.deposit(
        deadline: const Duration(minutes: 30),
        slippage: Slippage.halfPercent,
        token0Amount: BigInt.one,
        token1Amount: BigInt.one,
        minPrice: 1200,
        maxPrice: 3000.50,
        isMinPriceInfinity: false,
        isMaxPriceInfinity: false,
        isReversed: false,
      );
    },
  );

  test(
    "When calling `deposit`, the deadline in the deposit data should be the passed deadline, but as a unix timestamp",
    () async {
      final date = DateTime(1983, 2, 12);

      withClock(Clock(() => date), () async {
        const deadline = Duration(minutes: 54);

        when(() => uniswapPositionManagerImpl.multicall(data: any(named: "data")))
            .thenAnswer((_) async => transactionResponse);

        sutCopyWith(customDepositWithNative: true);

        await sut.deposit(
          deadline: deadline,
          slippage: Slippage.halfPercent,
          token0Amount: BigInt.one,
          token1Amount: BigInt.one,
          minPrice: 1200,
          maxPrice: 3000.50,
          isMinPriceInfinity: false,
          isMaxPriceInfinity: false,
          isReversed: false,
        );

        verify(
          () => poolService.sendV3PoolDepositTransaction(
            any(),
            any(),
            amount0Desired: any(named: "amount0Desired"),
            amount1Desired: any(named: "amount1Desired"),
            amount0Min: any(named: "amount0Min"),
            amount1Min: any(named: "amount1Min"),
            deadline: deadline,
            recipient: any(named: "recipient"),
            tickLower: any(named: "tickLower"),
            tickUpper: any(named: "tickUpper"),
          ),
        ).called(1);
      });
    },
  );

  group(
    "Close golden tests",
    () {
      setUp(() {
        final confettiController = ConfettiControllerMock();

        inject.registerFactory<ZupCachedImage>(() => mockZupCachedImage());
        inject.registerFactory<ConfettiController>(
          () => confettiController,
          instanceName: InjectInstanceNames.confettiController10s,
        );

        when(() => confettiController.duration).thenReturn(Duration.zero);
        when(() => confettiController.play()).thenAnswer((_) async {});
        when(() => confettiController.state).thenReturn(ConfettiControllerState.stoppedAndCleared);
      });

      tearDown(() => inject.reset());

      zGoldenTest(
        """When the state is waiting transation from a deposit and the cubit is trying to close,
      it should show a snackbar about the deposit in progress""",
        (tester) async {
          bool tested = false;
          sutCopyWith(customNavigatorKey: GoldenConfig.navigatorKey);

          await tester.pumpDeviceBuilder(
            await goldenDeviceBuilder(const SizedBox()),
            wrapper: GoldenConfig.localizationsWrapper(),
          );

          when(() => transactionResponse.waitConfirmation()).thenAnswer((_) async {
            try {
              await tester.pumpAndSettle();

              await sut.close();
              await screenMatchesGolden(tester, "preview_deposit_modal_cubit_close_depositing_snackbar");
              tested = true; // if it does not reach here, the test have been failed
            } catch (e) {
              debugPrint(e.toString());
            }

            return TransactionReceipt(hash: "");
          });

          await sut.deposit(
            deadline: const Duration(minutes: 30),
            slippage: Slippage.halfPercent,
            token0Amount: BigInt.one,
            token1Amount: BigInt.one,
            minPrice: 1200,
            maxPrice: 3000.50,
            isMinPriceInfinity: false,
            isMaxPriceInfinity: false,
            isReversed: false,
          );

          // if waitConfirmation its not called, the test will fail. As the real test is
          // inside the stub of the waitConfirmation, it should change the `tested` variable
          expect(tested, true);
        },
      );

      zGoldenTest(
        """When the state is waiting transation from a approval and the cubit is trying to close,
      it should show a snackbar about the approval in progress""",
        (tester) async {
          bool tested = false;
          sutCopyWith(customNavigatorKey: GoldenConfig.navigatorKey);

          await tester.pumpDeviceBuilder(
            await goldenDeviceBuilder(const SizedBox()),
            wrapper: GoldenConfig.localizationsWrapper(),
          );

          when(() => transactionResponse.waitConfirmation()).thenAnswer((_) async {
            try {
              await sut.close();
              await tester.pumpAndSettle();

              await screenMatchesGolden(tester, "preview_deposit_modal_cubit_close_approving_snackbar");

              tested = true; // if it does not reach here, the test have been failed
            } catch (e) {
              debugPrint(e.toString());
            }
            return TransactionReceipt(hash: "");
          });

          await sut.approveToken(TokenDto.fixture(), BigInt.one);

          // if waitConfirmation its not called, the test will fail. As the real test is
          // inside the stub of the waitConfirmation, it should change the `tested` variable
          expect(tested, true);
        },
      );

      zGoldenTest(
        """When the state is waiting transation from a approval, the cubit is trying to close,
          and the approve succes state is emitted, it should show a snackbar about the approval success
          and then close the cubit""",
        goldenFileName: "preview_deposit_modal_cubit_close_approval_success_snackbar",
        (tester) async {
          sutCopyWith(customNavigatorKey: GoldenConfig.navigatorKey);

          await tester.pumpDeviceBuilder(
            await goldenDeviceBuilder(const SizedBox()),
            wrapper: GoldenConfig.localizationsWrapper(),
          );

          when(() => transactionResponse.waitConfirmation()).thenAnswer((_) async {
            try {
              await sut.close();
            } catch (e) {
              debugPrint(e.toString());
            }
            return TransactionReceipt(hash: "");
          });

          await sut.approveToken(TokenDto.fixture(), BigInt.one);
          await tester.pumpAndSettle();

          expect(sut.isClosed, true);
        },
      );

      zGoldenTest(
        """When the state is waiting transation from a deposit, the cubit is trying to close,
          and the deposit succes state is emitted, it should show the deposit success modal
          and then close the cubit""",
        goldenFileName: "preview_deposit_modal_cubit_close_deposit_success_modal",
        (tester) async {
          sutCopyWith(customNavigatorKey: GoldenConfig.navigatorKey);

          await tester.pumpDeviceBuilder(
            await goldenDeviceBuilder(const SizedBox()),
            wrapper: GoldenConfig.localizationsWrapper(),
          );

          when(() => transactionResponse.waitConfirmation()).thenAnswer((_) async {
            try {
              await sut.close();
            } catch (e) {
              debugPrint(e.toString());
            }
            return TransactionReceipt(hash: "");
          });

          await sut.deposit(
            deadline: const Duration(minutes: 30),
            slippage: Slippage.halfPercent,
            token0Amount: BigInt.one,
            token1Amount: BigInt.one,
            minPrice: 1200,
            maxPrice: 3000.50,
            isMinPriceInfinity: false,
            isMaxPriceInfinity: false,
            isReversed: false,
          );

          await tester.pumpAndSettle();
          await tester.pumpAndSettle();

          expect(sut.isClosed, true);
        },
      );
    },
  );

  test(
    """When calling `deposit` and an error with `slippage` text in its body occur while depositing,
    it should emit the slippage check error state and the initial state""",
    () async {
      when(
        () => poolService.sendV3PoolDepositTransaction(
          any(),
          any(),
          amount0Desired: any(named: "amount0Desired"),
          amount1Desired: any(named: "amount1Desired"),
          amount0Min: any(named: "amount0Min"),
          amount1Min: any(named: "amount1Min"),
          deadline: any(named: "deadline"),
          recipient: any(named: "recipient"),
          tickLower: any(named: "tickLower"),
          tickUpper: any(named: "tickUpper"),
        ),
      ).thenThrow("SLIPPAGE_ERROR");

      expectLater(
        sut.stream,
        emitsInOrder([
          anything,
          const PreviewDepositModalState.slippageCheckError(),
          PreviewDepositModalState.initial(token0Allowance: BigInt.zero, token1Allowance: BigInt.zero),
        ]),
      );

      await sut.deposit(
        deadline: const Duration(minutes: 30),
        slippage: Slippage.halfPercent,
        token0Amount: BigInt.one,
        token1Amount: BigInt.one,
        minPrice: 1200,
        maxPrice: 3000.50,
        isMinPriceInfinity: false,
        isMaxPriceInfinity: false,
        isReversed: false,
      );
    },
  );

  test(
    "When calling `deposit` and it succeeds, it should log the deposit event in the analytics with the correct params",
    () async {
      final token0amount = 187732.parseTokenAmount(decimals: 18);
      final token1amount = 9082.parseTokenAmount(decimals: 6);
      final userAddress = await signer.address;

      await sut.deposit(
        deadline: const Duration(minutes: 30),
        slippage: Slippage.halfPercent,
        token0Amount: token0amount,
        token1Amount: token1amount,
        minPrice: 1200,
        maxPrice: 3000.50,
        isMinPriceInfinity: false,
        isMaxPriceInfinity: false,
        isReversed: false,
      );

      verify(() => zupAnalytics.logDeposit(
            depositedYield: currentYield,
            amount0: token0amount.parseTokenAmount(decimals: currentYield.token0NetworkDecimals),
            amount1: token1amount.parseTokenAmount(decimals: currentYield.token1NetworkDecimals),
            walletAddress: userAddress,
          )).called(1);
    },
  );

  test(
    "When calling `deposit` and it don't succeed, it should not log the any deposit event ",
    () async {
      when(() => transactionResponse.waitConfirmation()).thenThrow(Exception());

      await sut.deposit(
        deadline: const Duration(minutes: 30),
        slippage: Slippage.halfPercent,
        token0Amount: BigInt.one,
        token1Amount: BigInt.one,
        minPrice: 1200,
        maxPrice: 3000.50,
        isMinPriceInfinity: false,
        isMaxPriceInfinity: false,
        isReversed: false,
      );

      verifyNever(() => zupAnalytics.logDeposit(
            depositedYield: any(named: "depositedYield"),
            amount0: any(named: "amount0"),
            amount1: any(named: "amount1"),
            walletAddress: any(named: "walletAddress"),
          ));
    },
  );

  test(
    "When calling `approveToken` and the pool type is v4, it should approve the permit2 contract as well ",
    () async {
      when(() => permit2Impl.allowance(any(), any(), any()))
          .thenAnswer((_) async => (amount: BigInt.zero, expiration: BigInt.zero, nonce: BigInt.zero));

      when(
        () => permit2Impl.approve(
            token: any(named: "token"),
            spender: any(named: "spender"),
            amount: any(named: "amount"),
            expiration: any(named: "expiration")),
      ).thenAnswer((_) async => transactionResponse);

      const permit2Address = "0x1234";
      final currentYield0 = currentYield.copyWith(poolType: PoolType.v4, permit2: permit2Address);

      sut = PreviewDepositModalCubit(
        initialPoolTick: initialPoolTick,
        poolService: poolService,
        currentYield: currentYield0,
        erc20: erc20,
        wallet: wallet,
        uniswapPositionManager: uniswapPositionManager,
        permit2: permit2,
        navigatorKey: GlobalKey(),
        zupAnalytics: zupAnalytics,
      );

      final token = currentYield.token0;
      final value = BigInt.one;

      await sut.approveToken(token, value);

      verify(
        () => permit2Impl.approve(
          token: token.addresses[currentYield.network.chainId]!,
          spender: currentYield0.positionManagerAddress,
          amount: EthereumConstants.uint160Max,
          expiration: EthereumConstants.uint48Max,
        ),
      ).called(1);
    },
  );

  test(
    "When calling `approveToken` with the pool type v4, the allowance is more than the needed value, and the expiration is not expired, it should not approve the permit2 contract ",
    () async {
      final allowedAmount = BigInt.from(1275);

      when(() => permit2Impl.allowance(any(), any(), any())).thenAnswer(
        (_) async => (amount: allowedAmount, expiration: EthereumConstants.uint48Max, nonce: BigInt.zero),
      );

      when(
        () => permit2Impl.approve(
            token: any(named: "token"),
            spender: any(named: "spender"),
            amount: any(named: "amount"),
            expiration: any(named: "expiration")),
      ).thenAnswer((_) async => transactionResponse);

      const permit2Address = "0x1234";
      final currentYield0 = currentYield.copyWith(poolType: PoolType.v4, permit2: permit2Address);

      sut = PreviewDepositModalCubit(
        initialPoolTick: initialPoolTick,
        poolService: poolService,
        currentYield: currentYield0,
        erc20: erc20,
        wallet: wallet,
        uniswapPositionManager: uniswapPositionManager,
        permit2: permit2,
        navigatorKey: GlobalKey(),
        zupAnalytics: zupAnalytics,
      );

      final token = currentYield.token0;
      final value = allowedAmount - BigInt.one;

      await sut.approveToken(token, value);

      verifyNever(
        () => permit2Impl.approve(
          token: token.addresses[currentYield.network.chainId]!,
          spender: currentYield0.positionManagerAddress,
          amount: EthereumConstants.uint160Max,
          expiration: EthereumConstants.uint48Max,
        ),
      );
    },
  );

  test(
    """When calling `approveToken` with the pool type v4, the allowance is more than the needed value,
    but the expiration is already expired,it should approve the permit2 contract""",
    () async {
      final allowedAmount = BigInt.from(1275);

      when(() => permit2Impl.allowance(any(), any(), any())).thenAnswer(
        (_) async => (
          amount: allowedAmount,
          expiration: BigInt.from((DateTime.now().millisecondsSinceEpoch / 1000) - 1),
          nonce: BigInt.zero
        ),
      );

      when(
        () => permit2Impl.approve(
            token: any(named: "token"),
            spender: any(named: "spender"),
            amount: any(named: "amount"),
            expiration: any(named: "expiration")),
      ).thenAnswer((_) async => transactionResponse);

      const permit2Address = "0x1234";
      final currentYield0 = currentYield.copyWith(poolType: PoolType.v4, permit2: permit2Address);

      sut = PreviewDepositModalCubit(
        initialPoolTick: initialPoolTick,
        poolService: poolService,
        currentYield: currentYield0,
        erc20: erc20,
        wallet: wallet,
        uniswapPositionManager: uniswapPositionManager,
        permit2: permit2,
        navigatorKey: GlobalKey(),
        zupAnalytics: zupAnalytics,
      );

      final token = currentYield.token0;
      final value = allowedAmount - BigInt.one;

      await sut.approveToken(token, value);

      verify(
        () => permit2Impl.approve(
          token: token.addresses[currentYield.network.chainId]!,
          spender: currentYield0.positionManagerAddress,
          amount: EthereumConstants.uint160Max,
          expiration: EthereumConstants.uint48Max,
        ),
      ).called(1);
    },
  );

  test(
    "When calling `approveToken` and the pool type is v4, it should approve the token for the permit2 address",
    () async {
      const permit2Address = "0x1234";
      final currentYield0 = currentYield.copyWith(poolType: PoolType.v4, permit2: permit2Address);
      when(() => permit2Impl.allowance(any(), any(), any())).thenAnswer(
        (_) async => (amount: BigInt.zero, expiration: BigInt.zero, nonce: BigInt.zero),
      );

      sut = PreviewDepositModalCubit(
        initialPoolTick: initialPoolTick,
        poolService: poolService,
        currentYield: currentYield0,
        erc20: erc20,
        wallet: wallet,
        uniswapPositionManager: uniswapPositionManager,
        permit2: permit2,
        navigatorKey: GlobalKey(),
        zupAnalytics: zupAnalytics,
      );

      final token = currentYield.token0;
      final value = BigInt.one;

      await sut.approveToken(token, value);

      verify(
        () => erc20Impl.approve(
          spender: permit2Address,
          value: value,
        ),
      ).called(1);
    },
  );

  test(
      "when calling `deposit` and the pool type is v4, it should call the pool service to deposit on v4 with the correct parameters",
      () async {
    final currentYield0 = currentYield.copyWith(
      poolType: PoolType.v4,
      permit2: "0x1234",
    );
    final token0Amount = BigInt.one;
    final token1Amount = BigInt.two;
    const minPrice = 1200.43;
    const maxPrice = 4000.12;
    const isMinPriceInfinity = false;
    const isMaxPriceInfinity = false;
    const isReversed = false;
    final slippage = Slippage.fromValue(32);
    const deadline = Duration(minutes: 30);
    final recipient = await signer.address;
    final tickLower = V3PoolConversorsMixinWrapper().tickToClosestValidTick(
        tick: V3PoolConversorsMixinWrapper().priceToTick(
          price: minPrice,
          poolToken0Decimals: currentYield0.token0NetworkDecimals,
          poolToken1Decimals: currentYield0.token1NetworkDecimals,
        ),
        tickSpacing: currentYield0.tickSpacing);

    final tickUpper = V3PoolConversorsMixinWrapper().tickToClosestValidTick(
        tick: V3PoolConversorsMixinWrapper().priceToTick(
          price: maxPrice,
          poolToken0Decimals: currentYield0.token0NetworkDecimals,
          poolToken1Decimals: currentYield0.token1NetworkDecimals,
        ),
        tickSpacing: currentYield0.tickSpacing);

    sut = PreviewDepositModalCubit(
      initialPoolTick: initialPoolTick,
      poolService: poolService,
      currentYield: currentYield0,
      erc20: erc20,
      wallet: wallet,
      uniswapPositionManager: uniswapPositionManager,
      permit2: permit2,
      navigatorKey: GlobalKey(),
      zupAnalytics: zupAnalytics,
    );

    await sut.deposit(
      token0Amount: token0Amount,
      token1Amount: token1Amount,
      minPrice: minPrice,
      maxPrice: maxPrice,
      isMinPriceInfinity: isMinPriceInfinity,
      isMaxPriceInfinity: isMaxPriceInfinity,
      isReversed: isReversed,
      slippage: slippage,
      deadline: deadline,
    );

    verify(
      () => poolService.sendV4PoolDepositTransaction(
        currentYield0,
        signer,
        amount0toDeposit: token0Amount,
        amount1ToDeposit: token1Amount,
        maxAmount0ToDeposit: slippage.calculateMaxTokenAmountFromSlippage(token0Amount),
        maxAmount1ToDeposit: slippage.calculateMaxTokenAmountFromSlippage(token1Amount),
        deadline: deadline,
        tickLower: tickLower,
        tickUpper: tickUpper,
        recipient: recipient,
        currentPoolTick: initialPoolTick,
      ),
    ).called(1);
  });

  test(
    """When calling `deposit` and the deposit pool type is v2,
    it should call the pool service to deposit on v2 with the
    correct params""",
    () async {
      const slippage = Slippage.halfPercent;
      final amount0 = BigInt.from(1261821789);
      final amount1 = BigInt.from(1261821789);
      const deadline = Duration(minutes: 30);

      final currentYield0 = currentYield.copyWith(poolType: PoolType.v2);
      final sut0 = PreviewDepositModalCubit(
        initialPoolTick: initialPoolTick,
        poolService: poolService,
        currentYield: currentYield0,
        erc20: erc20,
        wallet: wallet,
        uniswapPositionManager: uniswapPositionManager,
        permit2: permit2,
        navigatorKey: GlobalKey(),
        zupAnalytics: zupAnalytics,
      );

      await sut0.deposit(token0Amount: amount0, token1Amount: amount1, slippage: slippage, deadline: deadline);

      verify(
        () => poolService.sendV2PoolDepositTransaction(
          currentYield0,
          signer,
          amount0: amount0,
          amount1: amount1,
          amount0Min: slippage.calculateMinTokenAmountFromSlippage(amount0),
          amount1Min: slippage.calculateMinTokenAmountFromSlippage(amount1),
          deadline: deadline,
        ),
      ).called(1);
    },
  );
}
