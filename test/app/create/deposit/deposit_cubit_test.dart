import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:web3kit/web3kit.dart';
import 'package:zup_app/abis/uniswap_v3_pool.abi.g.dart';
import 'package:zup_app/app/create/deposit/deposit_cubit.dart';
import 'package:zup_app/core/dtos/yield_dto.dart';
import 'package:zup_app/core/dtos/yields_dto.dart';
import 'package:zup_app/core/enums/networks.dart';
import 'package:zup_app/core/repositories/yield_repository.dart';
import 'package:zup_core/zup_core.dart';

import '../../../mocks.dart';

void main() {
  late DepositCubit sut;
  late YieldRepository yieldRepository;
  late ZupSingletonCache zupSingletonCache;
  late Wallet wallet;
  late UniswapV3Pool uniswapV3Pool;
  late UniswapV3PoolImpl uniswapV3PoolImpl;

  setUp(() {
    yieldRepository = YieldRepositoryMock();
    zupSingletonCache = ZupSingletonCache.shared;
    wallet = WalletMock();
    uniswapV3Pool = UniswapV3PoolMock();
    uniswapV3PoolImpl = UniswapV3PoolImplMock();

    sut = DepositCubit(yieldRepository, zupSingletonCache, wallet, uniswapV3Pool);

    when(() => yieldRepository.getYields(
        token0Address: any(named: "token0Address"),
        token1Address: any(named: "token1Address"))).thenAnswer((_) async => YieldsDto.fixture());

    when(() =>
            uniswapV3Pool.fromRpcProvider(contractAddress: any(named: "contractAddress"), rpcUrl: any(named: "rpcUrl")))
        .thenReturn(uniswapV3PoolImpl);
  });

  tearDown(() async => await ZupSingletonCache.shared.clear());

  test("When calling `getBestPools` it should emit a loading state", () async {
    expectLater(sut.stream, emits(const DepositState.loading()));

    await sut.getBestPools(token0Address: "any", token1Address: "any");
  });

  test("When calling `getBestPools` it should make a fetch with the repository", () async {
    const token0Address = "0x0";
    const token1Address = "0x1";

    await sut.getBestPools(token0Address: token0Address, token1Address: token1Address);

    verify(() => yieldRepository.getYields(token0Address: token0Address, token1Address: token1Address)).called(1);
  });

  test(
      "When calling `getBestPools` ans getting a empty list of yields from the repository it should emit a no yields state",
      () async {
    when(() => yieldRepository.getYields(
        token0Address: any(named: "token0Address"), token1Address: any(named: "token1Address"))).thenAnswer(
      (_) async => const YieldsDto(
        last24Yields: [],
        last30dYields: [],
        last90dYields: [],
      ),
    );

    await sut.getBestPools(token0Address: "any", token1Address: "any");

    expect(sut.state, const DepositState.noYields());
  });

  test("When calling `getBestPools` getting a valid list of yields from the repository it should emit a success state",
      () async {
    final yields = YieldsDto(
      last24Yields: [YieldDto.fixture()],
      last30dYields: [YieldDto.fixture()],
      last90dYields: [YieldDto.fixture()],
    );

    when(() => yieldRepository.getYields(
        token0Address: any(named: "token0Address"), token1Address: any(named: "token1Address"))).thenAnswer(
      (_) async => yields,
    );

    await sut.getBestPools(token0Address: "any", token1Address: "any");

    expect(sut.state, DepositState.success(yields));
  });

  test("When calling `getBestPools` and getting an error while fetching the yields, it should emit an error state",
      () async {
    when(
      () => yieldRepository.getYields(
          token0Address: any(named: "token0Address"), token1Address: any(named: "token1Address")),
    ).thenThrow(Exception());

    await sut.getBestPools(token0Address: "any", token1Address: "any");

    expect(sut.state, const DepositState.error());
  });

  test("When calling `getWalletTokenAmount` and there's no connected signer, it should return 0", () async {
    final tokenAmount = await sut.getWalletTokenAmount("", network: Networks.arbitrum);

    expect(tokenAmount, 0);
  });

  test("When calling `getWalletTokenAmount` and there's a connected signer it should get the wallet token amount",
      () async {
    final signer = SignerMock();
    const tokenAddress = "0x0";
    const network = Networks.arbitrum;
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
    const network = Networks.arbitrum;
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
    const network = Networks.arbitrum;
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
    const network = Networks.arbitrum;

    when(() => wallet.tokenBalance(tokenAddress, rpcUrl: any(named: "rpcUrl"))).thenThrow(Exception());
    when(() => wallet.signer).thenReturn(signer);
    when(() => signer.address).thenAnswer((_) async => "0x99E3CfADCD8Feecb5DdF91f88998cFfB3145F78c");

    final actualTokenBalance = await sut.getWalletTokenAmount(tokenAddress, network: network);

    expect(actualTokenBalance, 0.0);
  });

  test("When calling `getPoolTick` it should get it from the pool contract", () async {
    const poolNetwork = Networks.arbitrum;
    const poolAddress = "0x0";
    final expectPoolTick = BigInt.from(2737256372);

    when(() => uniswapV3PoolImpl.slot0()).thenAnswer((_) async => (
          sqrtPriceX96: BigInt.from(0),
          tick: expectPoolTick,
          observationIndex: BigInt.from(0),
          observationCardinality: BigInt.from(0),
          observationCardinalityNext: BigInt.from(0),
          feeProtocol: BigInt.from(0),
          unlocked: true,
        ));

    final actualPooltick = await sut.getPoolTick(poolNetwork, poolAddress);

    verify(() => uniswapV3PoolImpl.slot0()).called(1);

    expect(actualPooltick, expectPoolTick);
  });

  test("When calling `getPoolTick` it should use the zup singleton cache to cache the pool tick", () async {
    const poolNetwork = Networks.arbitrum;
    const poolAddress = "0x0";
    final expectPoolTick = BigInt.from(2737256372);
    final notExpectedPoolTick = BigInt.from(903489321);

    when(() => uniswapV3PoolImpl.slot0()).thenAnswer((_) async => (
          sqrtPriceX96: BigInt.from(0),
          tick: expectPoolTick,
          observationIndex: BigInt.from(0),
          observationCardinality: BigInt.from(0),
          observationCardinalityNext: BigInt.from(0),
          feeProtocol: BigInt.from(0),
          unlocked: true,
        ));

    final actualPooltick1 = await sut.getPoolTick(poolNetwork, poolAddress);

    when(() => uniswapV3PoolImpl.slot0()).thenAnswer((_) async => (
          sqrtPriceX96: BigInt.from(0),
          tick: notExpectedPoolTick,
          observationIndex: BigInt.from(0),
          observationCardinality: BigInt.from(0),
          observationCardinalityNext: BigInt.from(0),
          feeProtocol: BigInt.from(0),
          unlocked: true,
        ));

    final actualPooltick2 = await sut.getPoolTick(poolNetwork, poolAddress);

    verify(() => uniswapV3PoolImpl.slot0()).called(1);

    expect(actualPooltick1, expectPoolTick);
    expect(actualPooltick2, expectPoolTick);
  });

  test("When calling `getPoolTick` it should use the zup singleton cache with 1 minute expiration", () async {
    const poolNetwork = Networks.arbitrum;
    const poolAddress = "0x0";
    final expectPoolTick = BigInt.from(2737256372);
    final notExpectedPoolTick = BigInt.from(903489321);

    when(() => uniswapV3PoolImpl.slot0()).thenAnswer((_) async => (
          sqrtPriceX96: BigInt.from(0),
          tick: notExpectedPoolTick,
          observationIndex: BigInt.from(0),
          observationCardinality: BigInt.from(0),
          observationCardinalityNext: BigInt.from(0),
          feeProtocol: BigInt.from(0),
          unlocked: true,
        ));

    await sut.getPoolTick(poolNetwork, poolAddress);

    await withClock(Clock(() => DateTime.now().add(const Duration(minutes: 2))), () async {
      when(() => uniswapV3PoolImpl.slot0()).thenAnswer((_) async => (
            sqrtPriceX96: BigInt.from(0),
            tick: expectPoolTick,
            observationIndex: BigInt.from(0),
            observationCardinality: BigInt.from(0),
            observationCardinalityNext: BigInt.from(0),
            feeProtocol: BigInt.from(0),
            unlocked: true,
          ));

      final actualPooltick2 = await sut.getPoolTick(poolNetwork, poolAddress);

      verify(() => uniswapV3PoolImpl.slot0()).called(2);

      expect(actualPooltick2, expectPoolTick);
    });
  });

  test("When calling `getPoolTick` and the contract returns an error, it should return 0", () async {
    const poolNetwork = Networks.arbitrum;
    const poolAddress = "0x0";

    when(() => uniswapV3PoolImpl.slot0()).thenThrow(Exception());

    final actualPooltick = await sut.getPoolTick(poolNetwork, poolAddress);

    expect(actualPooltick, BigInt.zero);
  });
}
