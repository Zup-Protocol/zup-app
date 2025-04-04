import 'package:clock/clock.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:web3kit/web3kit.dart';
import 'package:zup_app/abis/uniswap_v3_pool.abi.g.dart';
import 'package:zup_app/app/app_cubit/app_cubit.dart';
import 'package:zup_app/app/create/deposit/deposit_cubit.dart';
import 'package:zup_app/core/cache.dart';
import 'package:zup_app/core/dtos/deposit_settings_dto.dart';
import 'package:zup_app/core/dtos/yield_dto.dart';
import 'package:zup_app/core/dtos/yields_dto.dart';
import 'package:zup_app/core/enums/networks.dart';
import 'package:zup_app/core/repositories/yield_repository.dart';
import 'package:zup_app/core/slippage.dart';
import 'package:zup_core/zup_singleton_cache.dart';

import '../../../mocks.dart';

void main() {
  late YieldRepository yieldRepository;
  late ZupSingletonCache zupSingletonCache;
  late Wallet wallet;
  late UniswapV3Pool uniswapV3Pool;
  late UniswapV3PoolImpl uniswapV3PoolImpl;
  late DepositCubit sut;
  late Cache cache;
  late AppCubit appCubit;

  final poolTick = BigInt.from(31276567121);

  setUp(() {
    registerFallbackValue(DepositSettingsDto.fixture());
    registerFallbackValue(Networks.sepolia);

    yieldRepository = YieldRepositoryMock();
    zupSingletonCache = ZupSingletonCache.shared;
    wallet = WalletMock();
    uniswapV3Pool = UniswapV3PoolMock();
    uniswapV3PoolImpl = UniswapV3PoolImplMock();
    cache = CacheMock();
    appCubit = AppCubitMock();

    sut = DepositCubit(yieldRepository, zupSingletonCache, wallet, uniswapV3Pool, cache, appCubit);

    when(() => appCubit.selectedNetwork).thenAnswer((_) => Networks.sepolia);

    when(
      () => uniswapV3Pool.fromRpcProvider(contractAddress: any(named: "contractAddress"), rpcUrl: any(named: "rpcUrl")),
    ).thenReturn(uniswapV3PoolImpl);

    when(() => uniswapV3PoolImpl.slot0()).thenAnswer((_) async => (
          feeProtocol: BigInt.zero,
          observationCardinality: BigInt.zero,
          observationCardinalityNext: BigInt.zero,
          observationIndex: BigInt.zero,
          sqrtPriceX96: BigInt.zero,
          tick: poolTick,
          unlocked: true
        ));
  });

  tearDown(() async {
    await zupSingletonCache.clear();
  });

  group("When calling `setup`, the cubit should register a periodic task to get the pool tick every minute. ", () {
    test("And if the selected yield is not null, it should execute the task to get the pool tick", () async {
      BigInt? actualLastEmittedPoolTick;
      int eventsCounter = 0;
      const minutesPassed = 3;

      final selectedYield = YieldDto.fixture();
      await sut.selectYield(selectedYield);

      fakeAsync((async) {
        sut.setup();

        sut.poolTickStream.listen((event) {
          actualLastEmittedPoolTick = event;
          eventsCounter++;
        });

        async.elapse(const Duration(minutes: minutesPassed));

        expect(actualLastEmittedPoolTick, poolTick);
        expect(
          eventsCounter,
          minutesPassed *
              2, /* it will be called twice per minute because
                of one of the emits are null,
                before fetching the latest tick */
        );
      });
    });
    test("""And when the minuted passed, but the selected yield is null
  it should not execute the task to get the pool tick""", () async {
      BigInt? actualLastEmittedPoolTick;
      int eventsCounter = 0;
      const minutesPassed = 3;

      await sut.selectYield(null);

      fakeAsync((async) {
        sut.setup();

        sut.poolTickStream.listen((event) {
          actualLastEmittedPoolTick = event;
          eventsCounter++;
        });

        async.elapse(const Duration(minutes: minutesPassed));

        expect(actualLastEmittedPoolTick, null);
        expect(eventsCounter, 0);
      });
    });

    test("""If the cubit is closed, and the minuted passed,
         it should not execute the task to get the pool tick
        and cancel the periodic task""", () async {
      final selectedYield = YieldDto.fixture();
      await sut.selectYield(selectedYield);
      int eventCount = 0;

      fakeAsync((async) {
        sut.setup();
        sut.close();

        sut.poolTickStream.listen((_) {
          eventCount++;
        });

        async.elapse(const Duration(minutes: 10));

        expect(async.periodicTimerCount, 0);
        expect(eventCount, 0);
      });
    });
  });

  test("When calling `getBestPools` it should emit the loading state", () async {
    expectLater(sut.stream, emits(const DepositState.loading()));

    await sut.getBestPools(token0Address: "", token1Address: "");
  });

  test("When calling `getBestPools` it should call the yield repository to get the best pools", () async {
    when(() => yieldRepository.getYields(
        token0Address: any(named: "token0Address"),
        token1Address: any(named: "token1Address"),
        network: any(named: "network"))).thenAnswer(
      (_) async => YieldsDto.fixture(),
    );

    const token0Address = "token0Address";
    const token1Address = "token1Address";

    await sut.getBestPools(token0Address: token0Address, token1Address: token1Address);

    verify(() => yieldRepository.getYields(
          token0Address: token0Address,
          token1Address: token1Address,
          network: any(named: "network"),
        )).called(1);
  });

  test("When calling `getBestPools` and receiving an empty list of pools, it should emit the noYields state", () async {
    when(() => yieldRepository.getYields(
        token0Address: any(named: "token0Address"),
        token1Address: any(named: "token1Address"),
        network: any(named: "network"))).thenAnswer(
      (_) async => YieldsDto.empty(),
    );

    expectLater(sut.stream, emitsInOrder([const DepositState.loading(), const DepositState.noYields()]));

    await sut.getBestPools(token0Address: "", token1Address: "");
  });

  test("When calling `getBestPools` and receiving a list of pools it should emit success state", () async {
    final pools = YieldsDto.fixture();

    when(() => yieldRepository.getYields(
        token0Address: any(named: "token0Address"),
        token1Address: any(named: "token1Address"),
        network: any(named: "network"))).thenAnswer((_) async => pools);

    expectLater(sut.stream, emitsInOrder([const DepositState.loading(), DepositState.success(pools)]));

    await sut.getBestPools(token0Address: "", token1Address: "");
  });

  test("When calling `getBestPools` and receiving an error, it should emit the error state", () async {
    when(() => yieldRepository.getYields(
        token0Address: any(named: "token0Address"),
        token1Address: any(named: "token1Address"),
        network: any(named: "network"))).thenThrow(Exception());

    expectLater(sut.stream, emitsInOrder([const DepositState.loading(), const DepositState.error()]));

    await sut.getBestPools(token0Address: "", token1Address: "");
  });

  test("When calling `selectYield` it should save the selected yield in a variable", () async {
    final selectedYield = YieldDto.fixture();

    await sut.selectYield(selectedYield);

    expect(sut.selectedYield, selectedYield);
  });

  test("When calling `selectYield` it should emit the selected yield in the stream", () async {
    final selectedYield = YieldDto.fixture();

    expectLater(sut.selectedYieldStream, emits(selectedYield));

    await sut.selectYield(selectedYield);
  });

  test("When calling `selectYield` with a non-empty yield it should get the pool tick", () async {
    final selectedYield = YieldDto.fixture();

    await sut.selectYield(selectedYield);

    verify(() => uniswapV3PoolImpl.slot0()).called(1);
  });

  test("When calling `selectYield` but the yield is null, it should not get the pool tick", () async {
    await sut.selectYield(null);

    verifyNever(() => uniswapV3PoolImpl.slot0());
  });

  test("When calling `getSelectedPoolTick` it should set the latest pool tick to null", () async {
    expectLater(sut.latestPoolTick, null);

    await sut.selectYield(YieldDto.fixture());
    await sut.getSelectedPoolTick();
  });

  test("When calling `getSelectedPoolTick` it should emit a null pool tick before getting the pool tick", () async {
    expectLater(sut.poolTickStream, emits(null));

    await sut.selectYield(YieldDto.fixture());
    await sut.getSelectedPoolTick();
  });

  test("""When calling `getSelectedPoolTick` it should create the
  UniswapV3Pool contract from RPC, with the address of the selected
  pool""", () async {
    final selectedYield = YieldDto.fixture();

    await sut.selectYield(YieldDto.fixture());
    await sut.getSelectedPoolTick();

    verify(
      () => uniswapV3Pool.fromRpcProvider(
        contractAddress: selectedYield.poolAddress,
        rpcUrl: selectedYield.network.rpcUrl,
      ),
    ).called(2); // 2 because of the `selectYield` and the `getSelectedPoolTick`
  });

  test("When calling `getSelectedPoolTick` it should use the slot0 from the UniswapV3Pool contract", () async {
    await sut.selectYield(YieldDto.fixture());
    await sut.getSelectedPoolTick();

    verify(() => uniswapV3PoolImpl.slot0()).called(2); // 2 because of the `selectYield` and the `getSelectedPoolTick`
  });

  test(""""
  When calling `getSelectedPoolTick` for a selected pool,
  but when the call to the contract completes, the selected pool
  is not the same as the one passed to the call, it shoul re-call
  `getSelectedPoolTick` to get the correct pool tick
""", () async {
    final expectedYieldBTick = BigInt.from(326287637265372111);

    const yieldAPoolAddress = "0x3263782637263";
    const yieldBPoolAddress = "0xPoolAddressYieldB";

    final yieldA = YieldDto.fixture().copyWith(poolAddress: yieldAPoolAddress);
    final yieldB = YieldDto.fixture().copyWith(poolAddress: yieldBPoolAddress);

    when(() => uniswapV3PoolImpl.slot0()).thenAnswer((_) async {
      when(() => uniswapV3PoolImpl.slot0()).thenAnswer((_) async {
        return (
          feeProtocol: BigInt.zero,
          observationCardinality: BigInt.zero,
          observationCardinalityNext: BigInt.zero,
          observationIndex: BigInt.zero,
          sqrtPriceX96: BigInt.zero,
          tick: expectedYieldBTick,
          unlocked: true
        );
      });

      await sut.selectYield(yieldB);

      return (
        feeProtocol: BigInt.zero,
        observationCardinality: BigInt.zero,
        observationCardinalityNext: BigInt.zero,
        observationIndex: BigInt.zero,
        sqrtPriceX96: BigInt.zero,
        tick: poolTick,
        unlocked: true
      );
    });

    await sut.selectYield(yieldA); // assuming that select yield will call `getSelectedPoolTick`

    verify(
      () => uniswapV3Pool.fromRpcProvider(contractAddress: yieldBPoolAddress, rpcUrl: yieldB.network.rpcUrl),
    ).called(2); // 2 because of the check in the `getSelectedPoolTick` that will re-call, and the selection

    expect(sut.latestPoolTick, expectedYieldBTick);
  });

  test("When calling `getSelectedPoolTick` it should emit the pool tick got", () async {
    final expectedPoolTick = BigInt.from(97866745634534392);

    when(() => uniswapV3PoolImpl.slot0()).thenAnswer((_) async => (
          feeProtocol: BigInt.zero,
          observationCardinality: BigInt.zero,
          observationCardinalityNext: BigInt.zero,
          observationIndex: BigInt.zero,
          sqrtPriceX96: BigInt.zero,
          tick: expectedPoolTick,
          unlocked: true
        ));

    expectLater(sut.poolTickStream, emitsInOrder([null, expectedPoolTick]));

    await sut.selectYield(YieldDto.fixture()); // assuming that select yield will call `getSelectedPoolTick`
  });

  test("When calling `getSelectedPoolTick` it should save the pool tick in the cubit", () async {
    final expectedPoolTick = BigInt.from(97866745634534392);

    when(() => uniswapV3PoolImpl.slot0()).thenAnswer((_) async => (
          feeProtocol: BigInt.zero,
          observationCardinality: BigInt.zero,
          observationCardinalityNext: BigInt.zero,
          observationIndex: BigInt.zero,
          sqrtPriceX96: BigInt.zero,
          tick: expectedPoolTick,
          unlocked: true
        ));

    await sut.selectYield(YieldDto.fixture()); // assuming that select yield will call `getSelectedPoolTick`

    expect(sut.latestPoolTick, expectedPoolTick);
  });

  test("When calling `getSelectedPoolTick` it should save the same tick as the emitted ", () async {
    final expectedPoolTick = BigInt.from(97866745634534392);

    when(() => uniswapV3PoolImpl.slot0()).thenAnswer((_) async => (
          feeProtocol: BigInt.zero,
          observationCardinality: BigInt.zero,
          observationCardinalityNext: BigInt.zero,
          observationIndex: BigInt.zero,
          sqrtPriceX96: BigInt.zero,
          tick: expectedPoolTick,
          unlocked: true
        ));

    expectLater(sut.poolTickStream, emitsInOrder([null, expectedPoolTick]));
    await sut.selectYield(YieldDto.fixture()); // assuming that select yield will call `getSelectedPoolTick`

    expect(sut.latestPoolTick, expectedPoolTick);
  });

  test("when closing the cubit, it should close the pool tick stream", () async {
    await sut.selectYield(YieldDto.fixture());
    await sut.close();

    expect(
      () async => await sut.getSelectedPoolTick(),
      throwsA(isA<StateError>()),
    );
  });

  test("When closing the cubit, it should close the selected yield stream", () async {
    await sut.close();

    expect(
      () async => await sut.selectYield(YieldDto.fixture()),
      throwsA(isA<StateError>()),
    );
  });

  test("When calling `getWalletTokenAmount` and there's no connected signer, it should return 0", () async {
    final tokenAmount = await sut.getWalletTokenAmount("", network: Networks.sepolia);

    expect(tokenAmount, 0);
  });

  test("When calling `getWalletTokenAmount` and there's a connected signer it should get the wallet token amount",
      () async {
    final signer = SignerMock();
    const tokenAddress = "0x0";
    const network = Networks.sepolia;
    const expectedTokenBalance = 1243.542;

    when(() => wallet.tokenBalance(tokenAddress, rpcUrl: any(named: "rpcUrl"))).thenAnswer((_) async => 1243.542);
    when(() => wallet.signer).thenReturn(signer);
    when(() => signer.address).thenAnswer((_) async => "0x99E3CfADCD8Feecb5DdF91f88998cFfB3145F78c");

    final actualTokenBalance = await sut.getWalletTokenAmount(tokenAddress, network: network);

    expect(actualTokenBalance, expectedTokenBalance);
    verify(() => wallet.tokenBalance(tokenAddress, rpcUrl: network.rpcUrl)).called(1);
  });

  test(
      "When calling `getWalletTokenAmount` it should use zup singleton cache to return the cached value if the cache is not more than 10 minutes old",
      () async {
    const tokenAddress = "0x0";
    final signer = SignerMock();
    const network = Networks.sepolia;
    const expectedTokenBalance = 1243.542;
    const notExpectedTokenBalance = 498361387.42;

    when(() => wallet.tokenBalance(tokenAddress, rpcUrl: any(named: "rpcUrl"))).thenAnswer((_) async => 1243.542);
    when(() => wallet.signer).thenReturn(signer);
    when(() => signer.address).thenAnswer((_) async => "0x99E3CfADCD8Feecb5DdF91f88998cFfB3145F78c");

    final actualTokenBalance1 = await sut.getWalletTokenAmount(tokenAddress, network: network);

    when(() => wallet.tokenBalance(tokenAddress, rpcUrl: any(named: "rpcUrl"))).thenAnswer(
      (_) async => notExpectedTokenBalance,
    );

    final actualTokenBalance2 = await sut.getWalletTokenAmount(tokenAddress, network: network);

    verify(() => wallet.tokenBalance(tokenAddress, rpcUrl: network.rpcUrl)).called(1);

    expect(actualTokenBalance1, expectedTokenBalance);
    expect(actualTokenBalance2, expectedTokenBalance);
  });

  test("When calling `getWalletTokenAmount` it should use zup singleton cache with a 10 minutes expiration time",
      () async {
    const tokenAddress = "0x0";
    final signer = SignerMock();
    const network = Networks.sepolia;
    const expectedTokenBalance = 1243.542;
    const notExpectedTokenBalance = 498361387.42;

    when(() => wallet.tokenBalance(tokenAddress, rpcUrl: any(named: "rpcUrl"))).thenAnswer(
      (_) async => notExpectedTokenBalance,
    );
    when(() => wallet.signer).thenReturn(signer);
    when(() => signer.address).thenAnswer((_) async => "0x99E3CfADCD8Feecb5DdF91f88998cFfB3145F78c");

    await sut.getWalletTokenAmount(tokenAddress, network: network);

    await withClock(Clock(() => DateTime.now().add(const Duration(minutes: 11))), () async {
      when(() => wallet.tokenBalance(tokenAddress, rpcUrl: any(named: "rpcUrl")))
          .thenAnswer((_) async => expectedTokenBalance);

      final actualTokenBalance2 = await sut.getWalletTokenAmount(tokenAddress, network: network);

      verify(() => wallet.tokenBalance(tokenAddress, rpcUrl: network.rpcUrl))
          .called(2); // it should call the method twice because the cache is expired

      expect(actualTokenBalance2, expectedTokenBalance);
    });
  });

  test("When calling `getWalletTokenAmount` and an error occurs getting the wallet balance, it should return 0",
      () async {
    final signer = SignerMock();
    const tokenAddress = "0x0";
    const network = Networks.sepolia;

    when(() => wallet.tokenBalance(tokenAddress, rpcUrl: any(named: "rpcUrl"))).thenThrow(Exception());
    when(() => wallet.signer).thenReturn(signer);
    when(() => signer.address).thenAnswer((_) async => "0x99E3CfADCD8Feecb5DdF91f88998cFfB3145F78c");

    final actualTokenBalance = await sut.getWalletTokenAmount(tokenAddress, network: network);

    expect(actualTokenBalance, 0.0);
  });

  test(
    "When calling `saveDepositSettings` it should save the passed params in the cache",
    () async {
      when(() => cache.saveDepositSettings(any())).thenAnswer((_) async => () {});

      const slippage = Slippage.zeroPointOnePercent;
      const deadline = Duration(minutes: 5);

      final expectedDepositSettings = DepositSettingsDto(
        deadlineMinutes: deadline.inMinutes,
        maxSlippage: slippage.value.toDouble(),
      );

      await sut.saveDepositSettings(slippage, deadline);

      verify(() => cache.saveDepositSettings(expectedDepositSettings)).called(1);
    },
  );

  test(
    "When calling `depositSettings` it should get the deposit settings from the cache",
    () {
      final expectedDepositSettings = DepositSettingsDto(
        deadlineMinutes: 5,
        maxSlippage: 0.01,
      );

      when(() => cache.getDepositSettings()).thenReturn(expectedDepositSettings);

      final actualDepositSettings = sut.depositSettings;

      expect(actualDepositSettings, expectedDepositSettings);
    },
  );
}
