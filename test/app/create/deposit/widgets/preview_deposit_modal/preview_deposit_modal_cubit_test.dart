import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:web3kit/core/core.dart';
import 'package:web3kit/core/dtos/transaction_receipt.dart';
import 'package:web3kit/core/dtos/transaction_response.dart';
import 'package:web3kit/core/exceptions/ethers_exceptions.dart';
import 'package:zup_app/abis/erc_20.abi.g.dart';
import 'package:zup_app/abis/fee_controller.abi.g.dart';
import 'package:zup_app/abis/uniswap_position_manager.abi.g.dart';
import 'package:zup_app/abis/uniswap_v3_pool.abi.g.dart';
import 'package:zup_app/abis/zup_router.abi.g.dart';
import 'package:zup_app/app/create/deposit/widgets/preview_deposit_modal/preview_deposit_modal_cubit.dart';
import 'package:zup_app/core/dtos/token_dto.dart';
import 'package:zup_app/core/dtos/yield_dto.dart';
import 'package:zup_app/core/enums/networks.dart';
import 'package:zup_app/core/v3_pool_constants.dart';

import '../../../../../matchers.dart';
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
  late ZupRouter zupRouter;
  late ZupRouterImpl zupRouterImpl;
  late FeeController feeController;
  late FeeControllerImpl feeControllerImpl;
  late Wallet wallet;
  late Signer signer;
  late TransactionResponse transactionResponse;
  late UniswapPositionManager uniswapPositionManager;

  setUp(() {
    uniswapV3Pool = UniswapV3PoolMock();
    erc20 = Erc20Mock();
    zupRouter = ZupRouterMock();
    feeController = FeeControllerMock();
    wallet = WalletMock();
    uniswapV3PoolImpl = UniswapV3PoolImplMock();
    erc20Impl = Erc20ImplMock();
    signer = SignerMock();
    transactionResponse = TransactionResponseMock();
    zupRouterImpl = ZupRouterImplMock();
    feeControllerImpl = FeeControllerImplMock();
    uniswapPositionManager = UniswapPositionManagerMock();

    sut = PreviewDepositModalCubit(
      initialPoolTick: initialPoolTick,
      uniswapV3Pool: uniswapV3Pool,
      currentYield: currentYield,
      erc20: erc20,
      wallet: wallet,
      zupRouter: zupRouter,
      feeController: feeController,
      uniswapPositionManager: uniswapPositionManager,
    );

    registerFallbackValue(const ChainInfo(hexChainId: "0x1"));
    registerFallbackValue(signer);
    registerFallbackValue(BigInt.one);
    registerFallbackValue((amount: BigInt.from(1), token: ""));
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

    when(() => wallet.connectedNetwork).thenAnswer((_) async => currentYield.network.chainInfo!);

    when(() =>
            feeController.fromRpcProvider(contractAddress: any(named: "contractAddress"), rpcUrl: any(named: "rpcUrl")))
        .thenReturn(feeControllerImpl);

    when(() => feeControllerImpl.calculateJoinPoolFee(
            token0Amount: any(named: "token0Amount"), token1Amount: any(named: "token1Amount")))
        .thenAnswer((_) async => (feeToken0: BigInt.from(100), feeToken1: BigInt.from(100)));

    when(() => zupRouter.fromSigner(contractAddress: any(named: "contractAddress"), signer: signer))
        .thenReturn(zupRouterImpl);

    when(
      () => zupRouterImpl.deposit(
          token0: any(named: "token0"),
          token1: any(named: "token1"),
          positionManager: any(named: "positionManager"),
          depositData: any(named: "depositData")),
    ).thenAnswer((_) async => transactionResponse);

    when(() => uniswapPositionManager.getMintCalldata(params: any(named: "params"))).thenReturn("0x");
  });

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

      when(() => uniswapV3PoolImpl.slot0()).thenAnswer((_) async => (
            feeProtocol: BigInt.zero,
            observationCardinality: BigInt.zero,
            observationCardinalityNext: BigInt.zero,
            observationIndex: BigInt.zero,
            sqrtPriceX96: BigInt.zero,
            tick: expectedEmittedTick,
            unlocked: true,
          ));

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
      verify(() => uniswapV3PoolImpl.slot0()).called(2);
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
        token0: TokenDto.fixture().copyWith(address: "Token 0 Address"),
        token1: TokenDto.fixture().copyWith(address: "Token 1 Address"),
      );

      sut = PreviewDepositModalCubit(
        uniswapPositionManager: uniswapPositionManager,
        initialPoolTick: initialPoolTick,
        uniswapV3Pool: uniswapV3Pool,
        currentYield: customYield,
        erc20: erc20,
        wallet: wallet,
        zupRouter: zupRouter,
        feeController: feeController,
      );

      final token0Contract = Erc20ImplMock();
      final token1Contract = Erc20ImplMock();
      final token0Allowance = BigInt.from(12345);
      final token1Allowance = BigInt.from(54321);

      when(() => erc20.fromRpcProvider(contractAddress: customYield.token0.address, rpcUrl: any(named: "rpcUrl")))
          .thenReturn(token0Contract);

      when(() => erc20.fromRpcProvider(contractAddress: customYield.token1.address, rpcUrl: any(named: "rpcUrl")))
          .thenReturn(token1Contract);

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
      const yieldNetwork = Networks.sepolia;
      final customYield = YieldDto.fixture().copyWith(network: yieldNetwork);

      sut = PreviewDepositModalCubit(
        initialPoolTick: initialPoolTick,
        uniswapV3Pool: uniswapV3Pool,
        currentYield: customYield,
        erc20: erc20,
        wallet: wallet,
        zupRouter: zupRouter,
        feeController: feeController,
        uniswapPositionManager: uniswapPositionManager,
      );

      when(() => wallet.switchOrAddNetwork(any())).thenAnswer((_) async {});
      when(() => wallet.connectedNetwork).thenAnswer((_) async => Networks.scrollSepolia.chainInfo!);

      await sut.approveToken(currentYield.token0, BigInt.from(32761));

      verify(() => wallet.switchOrAddNetwork(yieldNetwork.chainInfo!)).called(1);
    },
  );

  test(
    """When calling `approveToken` and the current user connected
    network is the same as the token network, it should not
    ask to switch the network""",
    () async {
      const yieldNetwork = Networks.sepolia;
      final customYield = YieldDto.fixture().copyWith(network: yieldNetwork);

      sut = PreviewDepositModalCubit(
        uniswapPositionManager: uniswapPositionManager,
        initialPoolTick: initialPoolTick,
        uniswapV3Pool: uniswapV3Pool,
        currentYield: customYield,
        erc20: erc20,
        wallet: wallet,
        zupRouter: zupRouter,
        feeController: feeController,
      );

      when(() => wallet.switchOrAddNetwork(any())).thenAnswer((_) async {});
      when(() => wallet.connectedNetwork).thenAnswer((_) async => yieldNetwork.chainInfo!);

      await sut.approveToken(currentYield.token0, BigInt.from(121));

      verifyNever(() => wallet.switchOrAddNetwork(yieldNetwork.chainInfo!));
    },
  );

  test(
    """When calling `approveToken` it should connect to the erc20 contract with the current signer,
    and call the `approve` function with the zup router address as spender and the amount as value""",
    () async {
      final token = currentYield.token0;
      final tokenAmount = BigInt.from(121);

      when(() => erc20.fromSigner(contractAddress: any(named: "contractAddress"), signer: any(named: "signer")))
          .thenReturn(erc20Impl);

      when(() => erc20Impl.approve(spender: any(named: "spender"), value: any(named: "value")))
          .thenAnswer((_) async => transactionResponse);

      when(() => transactionResponse.waitConfirmation()).thenAnswer((_) async => TransactionReceipt(hash: ""));

      await sut.approveToken(token, tokenAmount);

      verify(() => erc20.fromSigner(contractAddress: token.address, signer: signer)).called(1);
      verify(() => erc20Impl.approve(spender: currentYield.network.zupRouterAddress!, value: tokenAmount)).called(1);
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
        expectLater(sut.stream, emits(const PreviewDepositModalState.waitingTransaction(txId: txId)));

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
        expect(sut.state, const PreviewDepositModalState.waitingTransaction(txId: txId));

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
    the initial state with the updated allowance
    """,
    () async {
      final token0Allowance = BigInt.from(12345);

      expectLater(
          sut.stream,
          emitsInOrder([
            anything,
            anything,
            PreviewDepositModalState.approveSuccess(txId: transactionResponse.hash, symbol: currentYield.token0.symbol),
            PreviewDepositModalState.initial(token0Allowance: token0Allowance, token1Allowance: BigInt.zero),
          ]));

      await sut.approveToken(currentYield.token0, token0Allowance);
    },
  );

  test(
    """When calling `approveToken` with the token1 and everything is ok,
    it should emit the approve success state and right after,
    the initial state with the updated allowance
    """,
    () async {
      final token1Allowance = BigInt.from(12345);

      expectLater(
          sut.stream,
          emitsInOrder([
            anything,
            anything,
            PreviewDepositModalState.approveSuccess(txId: transactionResponse.hash, symbol: currentYield.token1.symbol),
            PreviewDepositModalState.initial(token0Allowance: BigInt.zero, token1Allowance: token1Allowance),
          ]));

      await sut.approveToken(currentYield.token1, token1Allowance);
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
      final connectedNetwork = Networks.scrollSepolia.chainInfo!;
      final yieldNetwork = Networks.sepolia.chainInfo!;

      when(() => wallet.connectedNetwork).thenAnswer((_) async => connectedNetwork);

      await sut.deposit(
        token0Amount: BigInt.one,
        token1Amount: BigInt.one,
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
      final connectedNetwork = Networks.sepolia.chainInfo!;
      final yieldNetwork = Networks.sepolia.chainInfo!;

      when(() => wallet.connectedNetwork).thenAnswer((_) async => connectedNetwork);

      await sut.deposit(
        token0Amount: BigInt.one,
        token1Amount: BigInt.one,
        minPrice: 0,
        maxPrice: 0,
        isMinPriceInfinity: false,
        isMaxPriceInfinity: false,
        isReversed: false,
      );

      verifyNever(() => wallet.switchOrAddNetwork(yieldNetwork));
    },
  );

  test("When calling `deposit`, the tokens amount sent to the contract call should match the passed values", () async {
    final token0Amount = BigInt.from(32421);
    final token1Amount = BigInt.from(8729889);

    await sut.deposit(
      token0Amount: token0Amount,
      token1Amount: token1Amount,
      minPrice: 1200,
      maxPrice: 3000,
      isMinPriceInfinity: false,
      isMaxPriceInfinity: false,
      isReversed: false,
    );

    verify(
      () => zupRouterImpl.deposit(
        token0: (amount: token0Amount, token: currentYield.token0.address),
        token1: (amount: token1Amount, token: currentYield.token1.address),
        positionManager: any(named: "positionManager"),
        depositData: any(named: "depositData"),
      ),
    );
  });

  test(
    "When calling `deposit` the position manager address passed to the contract call should match the network's one",
    () async {
      await sut.deposit(
        token0Amount: BigInt.one,
        token1Amount: BigInt.one,
        minPrice: 0,
        maxPrice: 0,
        isMinPriceInfinity: true,
        isMaxPriceInfinity: true,
        isReversed: false,
      );

      verify(
        () => zupRouterImpl.deposit(
          token0: any(named: "token0"),
          token1: any(named: "token1"),
          positionManager: currentYield.positionManagerAddress,
          depositData: any(named: "depositData"),
        ),
      );
    },
  );

  test(
    """When calling `deposit`, the amount0Desired in the depositData should be
      the passed token0 amount minus the fee amount, got from the fee controller""",
    () async {
      final feeAmount = BigInt.from(100);
      final token0Amount = BigInt.from(32421);

      when(() => feeControllerImpl.calculateJoinPoolFee(
          token0Amount: any(named: "token0Amount"), token1Amount: any(named: "token1Amount"))).thenAnswer(
        (_) async => (feeToken0: feeAmount, feeToken1: feeAmount),
      );

      when(() => uniswapPositionManager.getMintCalldata(params: any(named: "params"))).thenReturn("");

      await sut.deposit(
        token0Amount: token0Amount,
        token1Amount: BigInt.one,
        minPrice: 0,
        maxPrice: 0,
        isMinPriceInfinity: true,
        isMaxPriceInfinity: true,
        isReversed: false,
      );

      verify(
        () => uniswapPositionManager.getMintCalldata(
          params: any(
            named: "params",
            that: ExpectedMatcher(
              expects: (item) {
                expect(item.amount0Desired, token0Amount - feeAmount);
              },
            ),
          ),
        ),
      ).called(1);
    },
  );

  test(
    """When calling `deposit`, the amount1Desired in the depositData should be
      the passed token1 amount minus the fee amount, got from the fee controller""",
    () async {
      final feeAmount = BigInt.from(431);
      final token1Amount = BigInt.from(6721);

      when(() => feeControllerImpl.calculateJoinPoolFee(
          token0Amount: any(named: "token0Amount"), token1Amount: any(named: "token1Amount"))).thenAnswer(
        (_) async => (feeToken0: feeAmount, feeToken1: feeAmount),
      );

      when(() => uniswapPositionManager.getMintCalldata(params: any(named: "params"))).thenReturn("");

      await sut.deposit(
        token0Amount: BigInt.one,
        token1Amount: token1Amount,
        minPrice: 0,
        maxPrice: 0,
        isMinPriceInfinity: true,
        isMaxPriceInfinity: true,
        isReversed: false,
      );

      verify(
        () => uniswapPositionManager.getMintCalldata(
          params: any(
            named: "params",
            that: ExpectedMatcher(
              expects: (item) {
                expect(item.amount1Desired, token1Amount - feeAmount);
              },
            ),
          ),
        ),
      ).called(1);
    },
  );

  test(
    "When calling `deposit`, the recipient in the depositData, should be the connected signer address",
    () async {
      const signerAddress = "0x0000000000000000000000000000000000000231";
      when(() => signer.address).thenAnswer((_) async => signerAddress);

      await sut.deposit(
        token0Amount: BigInt.one,
        token1Amount: BigInt.one,
        minPrice: 0,
        maxPrice: 0,
        isMinPriceInfinity: true,
        isMaxPriceInfinity: true,
        isReversed: false,
      );

      verify(() => uniswapPositionManager.getMintCalldata(
            params: any(
              named: "params",
              that: ExpectedMatcher(expects: (item) => expect(item.recipient, signerAddress)),
            ),
          )).called(1);
    },
  );

  test(
      "When calling `deposit` the minPrice is infinity, and is not reversed, the tick lower in the depositData should be the min tick",
      () async {
    await sut.deposit(
      token0Amount: BigInt.one,
      token1Amount: BigInt.one,
      minPrice: 0,
      maxPrice: 3000,
      isMinPriceInfinity: true,
      isMaxPriceInfinity: false,
      isReversed: false,
    );

    verify(
      () => uniswapPositionManager.getMintCalldata(
        params: any(
          named: "params",
          that: ExpectedMatcher(
            expects: (item) => expect(item.tickLower, V3PoolConstants.minTick),
          ),
        ),
      ),
    ).called(1);
  });

  test(
      "When calling `deposit` with the maxPrice infinity, and reversed, the tick lower in the depositData should be the min tick",
      () async {
    await sut.deposit(
      token0Amount: BigInt.one,
      token1Amount: BigInt.one,
      minPrice: 1200,
      maxPrice: 0,
      isMinPriceInfinity: false,
      isMaxPriceInfinity: true,
      isReversed: true,
    );

    verify(
      () => uniswapPositionManager.getMintCalldata(
        params: any(
          named: "params",
          that: ExpectedMatcher(
            expects: (item) => expect(item.tickLower, V3PoolConstants.minTick),
          ),
        ),
      ),
    ).called(1);
  });

  test(
    "When calling `deposit` with a min price that is not infinity, it should calculate the correct tickLower for the depositData",
    () async {
      const minPrice = 1200.0;

      await sut.deposit(
        token0Amount: BigInt.one,
        token1Amount: BigInt.one,
        minPrice: minPrice,
        maxPrice: 0,
        isMinPriceInfinity: false,
        isMaxPriceInfinity: true,
        isReversed: false,
      );

      verify(
        () => uniswapPositionManager.getMintCalldata(
          params: any(
            named: "params",
            that: ExpectedMatcher(
              expects: (item) => expect(
                item.tickLower,
                V3PoolConversorsMixinWrapper().tickToClosestValidTick(
                  tick: V3PoolConversorsMixinWrapper().priceToTick(
                    price: minPrice,
                    poolToken0Decimals: currentYield.token0.decimals,
                    poolToken1Decimals: currentYield.token1.decimals,
                    isReversed: false,
                  ),
                  tickSpacing: currentYield.tickSpacing,
                ),
              ),
            ),
          ),
        ),
      ).called(1);
    },
  );

  test(
    """When calling `deposit` with a max price that is not infinity, and it's reversed,
    it should calculate the correct tickLower for the depositData, using the max price
    (because it's reversed)
    """,
    () async {
      const maxPrice = 3000.0;
      const isReversed = true;

      await sut.deposit(
        token0Amount: BigInt.one,
        token1Amount: BigInt.one,
        minPrice: 1200,
        maxPrice: maxPrice,
        isMinPriceInfinity: false,
        isMaxPriceInfinity: false,
        isReversed: isReversed,
      );

      verify(
        () => uniswapPositionManager.getMintCalldata(
          params: any(
            named: "params",
            that: ExpectedMatcher(
              expects: (item) => expect(
                item.tickLower,
                V3PoolConversorsMixinWrapper().tickToClosestValidTick(
                  tick: V3PoolConversorsMixinWrapper().priceToTick(
                    price: maxPrice,
                    poolToken0Decimals: currentYield.token0.decimals,
                    poolToken1Decimals: currentYield.token1.decimals,
                    isReversed: isReversed,
                  ),
                  tickSpacing: currentYield.tickSpacing,
                ),
              ),
            ),
          ),
        ),
      ).called(1);
    },
  );

  test(
    "When calling `deposit` with a max price that is infinity, and it's not reversed, the tick upper in the depositData should be the max tick",
    () async {
      await sut.deposit(
        token0Amount: BigInt.one,
        token1Amount: BigInt.one,
        minPrice: 1200,
        maxPrice: 0,
        isMinPriceInfinity: false,
        isMaxPriceInfinity: true,
        isReversed: false,
      );

      verify(
        () => uniswapPositionManager.getMintCalldata(
          params: any(
            named: "params",
            that: ExpectedMatcher(
              expects: (item) => expect(item.tickUpper, V3PoolConstants.maxTick),
            ),
          ),
        ),
      ).called(1);
    },
  );

  test(
    "When calling `deposit` with a min price that is infinity, and it's reversed, the tick upper in the depositData should be the max tick",
    () async {
      const maxPrice = 3000.0;
      const isReversed = true;

      await sut.deposit(
        token0Amount: BigInt.one,
        token1Amount: BigInt.one,
        minPrice: 0,
        maxPrice: maxPrice,
        isMinPriceInfinity: true,
        isMaxPriceInfinity: false,
        isReversed: isReversed,
      );

      verify(
        () => uniswapPositionManager.getMintCalldata(
          params: any(
            named: "params",
            that: ExpectedMatcher(
              expects: (item) => expect(
                item.tickUpper,
                V3PoolConstants.maxTick,
              ),
            ),
          ),
        ),
      ).called(1);
    },
  );

  test(
    """When calling `deposit` with a max price that is not infinity,
    and it's not reversed, the tick upper in the depositData should be
    calculated based on the max price""",
    () async {
      const maxPrice = 3000.50;

      await sut.deposit(
        token0Amount: BigInt.one,
        token1Amount: BigInt.one,
        minPrice: 1200,
        maxPrice: maxPrice,
        isMinPriceInfinity: false,
        isMaxPriceInfinity: false,
        isReversed: false,
      );

      verify(
        () => uniswapPositionManager.getMintCalldata(
          params: any(
            named: "params",
            that: ExpectedMatcher(
              expects: (item) => expect(
                item.tickUpper,
                V3PoolConversorsMixinWrapper().tickToClosestValidTick(
                  tick: V3PoolConversorsMixinWrapper().priceToTick(
                    price: maxPrice,
                    poolToken0Decimals: currentYield.token0.decimals,
                    poolToken1Decimals: currentYield.token1.decimals,
                    isReversed: false,
                  ),
                  tickSpacing: currentYield.tickSpacing,
                ),
              ),
            ),
          ),
        ),
      ).called(1);
    },
  );

  test(
    """When calling `deposit` with a max price that is not infinity,
    and it's reversed, the tick upper in the depositData should be
    calculated based on the min price""",
    () async {
      const minPrice = 50.32;
      const isReversed = true;

      await sut.deposit(
        token0Amount: BigInt.one,
        token1Amount: BigInt.one,
        minPrice: minPrice,
        maxPrice: 300.50,
        isMinPriceInfinity: false,
        isMaxPriceInfinity: false,
        isReversed: isReversed,
      );

      verify(
        () => uniswapPositionManager.getMintCalldata(
          params: any(
            named: "params",
            that: ExpectedMatcher(
              expects: (item) => expect(
                item.tickUpper,
                V3PoolConversorsMixinWrapper().tickToClosestValidTick(
                  tick: V3PoolConversorsMixinWrapper().priceToTick(
                    price: minPrice,
                    poolToken0Decimals: currentYield.token0.decimals,
                    poolToken1Decimals: currentYield.token1.decimals,
                    isReversed: isReversed,
                  ),
                  tickSpacing: currentYield.tickSpacing,
                ),
              ),
            ),
          ),
        ),
      ).called(1);
    },
  );

  test("When calling `deposit` the fee in the depositData should be the feeTier of the yield pool", () async {
    await sut.deposit(
      token0Amount: BigInt.one,
      token1Amount: BigInt.one,
      minPrice: 1200,
      maxPrice: 3000.50,
      isMinPriceInfinity: false,
      isMaxPriceInfinity: false,
      isReversed: false,
    );

    verify(
      () => uniswapPositionManager.getMintCalldata(
        params: any(
          named: "params",
          that: ExpectedMatcher(
            expects: (item) => expect(item.fee, BigInt.from(currentYield.feeTier)),
          ),
        ),
      ),
    ).called(1);
  });

  test("When calling `deposit` the token0 in the depositData should be the token0 of the yield pool", () async {
    await sut.deposit(
      token0Amount: BigInt.one,
      token1Amount: BigInt.one,
      minPrice: 1200,
      maxPrice: 3000.50,
      isMinPriceInfinity: false,
      isMaxPriceInfinity: false,
      isReversed: false,
    );

    verify(
      () => uniswapPositionManager.getMintCalldata(
        params: any(
          named: "params",
          that: ExpectedMatcher(
            expects: (item) => expect(item.token0, currentYield.token0.address),
          ),
        ),
      ),
    ).called(1);
  });

  test("When calling `deposit` the token1 in the depositData should be the token1 of the yield pool", () async {
    await sut.deposit(
      token0Amount: BigInt.one,
      token1Amount: BigInt.one,
      minPrice: 1200,
      maxPrice: 3000.50,
      isMinPriceInfinity: false,
      isMaxPriceInfinity: false,
      isReversed: false,
    );

    verify(
      () => uniswapPositionManager.getMintCalldata(
        params: any(
          named: "params",
          that: ExpectedMatcher(
            expects: (item) => expect(item.token1, currentYield.token1.address),
          ),
        ),
      ),
    ).called(1);
  });

  test(
    "When calling `deposit`, after the transcation to deposit is sent, it should emit the waiting transaction state",
    () async {
      const txId = "0x123456789";
      bool callbackCalled = false;

      when(() => transactionResponse.hash).thenReturn(txId);
      when(
        () => zupRouterImpl.deposit(
          token0: any(named: "token0"),
          token1: any(named: "token1"),
          positionManager: any(named: "positionManager"),
          depositData: any(named: "depositData"),
        ),
      ).thenAnswer((_) async {
        expectLater(
          sut.stream,
          emits(const PreviewDepositModalState.waitingTransaction(txId: txId)),
        );

        callbackCalled = true;

        return transactionResponse;
      });

      await sut.deposit(
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
        expect(sut.state, const PreviewDepositModalState.waitingTransaction(txId: txId));

        callbackCalled = true;

        return TransactionReceipt(hash: "");
      });

      await sut.deposit(
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
        () => zupRouterImpl.deposit(
          token0: any(named: "token0"),
          token1: any(named: "token1"),
          positionManager: any(named: "positionManager"),
          depositData: any(named: "depositData"),
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
        () => zupRouterImpl.deposit(
          token0: any(named: "token0"),
          token1: any(named: "token1"),
          positionManager: any(named: "positionManager"),
          depositData: any(named: "depositData"),
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
}