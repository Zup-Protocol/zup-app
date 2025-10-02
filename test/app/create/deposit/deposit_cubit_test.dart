import 'package:clock/clock.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:web3kit/web3kit.dart';
import 'package:zup_app/abis/uniswap_v3_pool.abi.g.dart';
import 'package:zup_app/app/app_cubit/app_cubit.dart';
import 'package:zup_app/app/create/deposit/deposit_cubit.dart';
import 'package:zup_app/core/app_cache.dart';
import 'package:zup_app/core/dtos/deposit_settings_dto.dart';
import 'package:zup_app/core/dtos/pool_search_filters_dto.dart';
import 'package:zup_app/core/dtos/pool_search_settings_dto.dart';
import 'package:zup_app/core/dtos/yield_dto.dart';
import 'package:zup_app/core/dtos/yields_dto.dart';
import 'package:zup_app/core/enums/networks.dart';
import 'package:zup_app/core/pool_service.dart';
import 'package:zup_app/core/repositories/yield_repository.dart';
import 'package:zup_app/core/slippage.dart';
import 'package:zup_app/core/zup_analytics.dart';
import 'package:zup_core/zup_singleton_cache.dart';

import '../../../mocks.dart';

void main() {
  late YieldRepository yieldRepository;
  late ZupSingletonCache zupSingletonCache;
  late Wallet wallet;
  late UniswapV3Pool uniswapV3Pool;
  late UniswapV3PoolImpl uniswapV3PoolImpl;
  late DepositCubit sut;
  late AppCache cache;
  late AppCubit appCubit;
  late ZupAnalytics zupAnalytics;
  late PoolService poolService;
  final poolSqrtPriceX96 = BigInt.from(31276567121);

  setUp(() {
    registerFallbackValue(DepositSettingsDto.fixture());
    registerFallbackValue(AppNetworks.sepolia);
    registerFallbackValue(PoolSearchSettingsDto.fixture());
    registerFallbackValue(YieldDto.fixture());
    poolService = PoolServiceMock();

    yieldRepository = YieldRepositoryMock();
    zupSingletonCache = ZupSingletonCache.shared;
    wallet = WalletMock();
    uniswapV3Pool = UniswapV3PoolMock();
    uniswapV3PoolImpl = UniswapV3PoolImplMock();
    cache = AppCacheMock();
    appCubit = AppCubitMock();
    zupAnalytics = ZupAnalyticsMock();

    sut = DepositCubit(yieldRepository, zupSingletonCache, wallet, cache, appCubit, zupAnalytics, poolService);

    when(() => appCubit.isTestnetMode).thenReturn(false);
    when(() => cache.blockedProtocolsIds).thenReturn([]);
    when(
      () => yieldRepository.getAllNetworksYield(
        token0InternalId: any(named: "token0InternalId"),
        token1InternalId: any(named: "token1InternalId"),
        searchSettings: any(named: "searchSettings"),
        blockedProtocolIds: any(named: "blockedProtocolIds"),
        group0Id: any(named: "group0Id"),
        group1Id: any(named: "group1Id"),
        testnetMode: any(named: "testnetMode"),
      ),
    ).thenAnswer((_) async => YieldsDto.fixture());

    when(() => appCubit.selectedNetwork).thenAnswer((_) => AppNetworks.sepolia);
    when(() => cache.getPoolSearchSettings()).thenReturn(PoolSearchSettingsDto.fixture());
    when(
      () => uniswapV3Pool.fromRpcProvider(
        contractAddress: any(named: "contractAddress"),
        rpcUrl: any(named: "rpcUrl"),
      ),
    ).thenReturn(uniswapV3PoolImpl);

    when(
      () => zupAnalytics.logSearch(
        network: any(named: "network"),
        token0: any(named: "token0"),
        token1: any(named: "token1"),
        group0: any(named: "group0"),
        group1: any(named: "group1"),
      ),
    ).thenAnswer((_) async {});

    when(() => uniswapV3PoolImpl.slot0()).thenAnswer(
      (_) async => (
        feeProtocol: BigInt.zero,
        observationCardinality: BigInt.zero,
        observationCardinalityNext: BigInt.zero,
        observationIndex: BigInt.zero,
        sqrtPriceX96: poolSqrtPriceX96,
        tick: BigInt.zero,
        unlocked: true,
      ),
    );

    when(() => poolService.getSqrtPriceX96(any())).thenAnswer((_) async => poolSqrtPriceX96);
    when(() => cache.getPoolSearchSettings()).thenReturn(PoolSearchSettingsDto(minLiquidityUSD: 129816));
  });

  tearDown(() async {
    await zupSingletonCache.clear();
  });

  group(
    "When calling `setup`, the cubit should register a periodic task to get the pool sqrtPriceX96 every half minute. ",
    () {
      test("And if the selected yield is not null, it should execute the task to get the pool sqrtPriceX96", () async {
        BigInt? actualLastEmittedSqrtPriceX96;
        int eventsCounter = 0;
        const minutesPassed = 3;

        final selectedYield = YieldDto.fixture();
        await sut.selectYield(selectedYield);

        fakeAsync((async) {
          sut.setup();

          sut.poolSqrtPriceX96Stream.listen((event) {
            actualLastEmittedSqrtPriceX96 = event;
            eventsCounter++;
          });

          async.elapse(const Duration(minutes: minutesPassed));

          expect(actualLastEmittedSqrtPriceX96, poolSqrtPriceX96);
          expect(eventsCounter, minutesPassed * 2);
        });
      });

      test(
        """And when the minuted passed, but the selected yield is null
  it should not execute the task to get the pool sqrtPriceX96""",
        () async {
          BigInt? actualLastEmittedSqrtPriceX96;
          int eventsCounter = 0;
          const minutesPassed = 3;

          await sut.selectYield(null);

          fakeAsync((async) {
            sut.setup();

            sut.poolSqrtPriceX96Stream.listen((event) {
              actualLastEmittedSqrtPriceX96 = event;
              eventsCounter++;
            });

            async.elapse(const Duration(minutes: minutesPassed));

            expect(actualLastEmittedSqrtPriceX96, null);
            expect(eventsCounter, 0);
          });
        },
      );

      test(
        """If the cubit is closed, and the minuted passed,
         it should not execute the task to get the pool sqrtPriceX96
        and cancel the periodic task""",
        () async {
          final selectedYield = YieldDto.fixture();
          await sut.selectYield(selectedYield);
          int eventCount = 0;

          fakeAsync((async) {
            sut.setup();
            sut.close();

            sut.poolSqrtPriceX96Stream.listen((_) {
              eventCount++;
            });

            async.elapse(const Duration(minutes: 10));

            expect(async.periodicTimerCount, 0);
            expect(eventCount, 0);
          });
        },
      );
    },
  );

  test("When calling `getBestPools` it should emit the loading state", () async {
    expectLater(sut.stream, emits(const DepositState.loading()));

    await sut.getBestPools(token0AddressOrId: "", token1AddressOrId: "", group0Id: "", group1Id: "");
  });

  test("When calling `getBestPools` it should call the yield repository to get the best pools", () async {
    when(
      () => yieldRepository.getSingleNetworkYield(
        token0Address: any(named: "token0Address"),
        token1Address: any(named: "token1Address"),
        searchSettings: any(named: "searchSettings"),
        blockedProtocolIds: any(named: "blockedProtocolIds"),
        group0Id: any(named: "group0Id"),
        group1Id: any(named: "group1Id"),
        network: any(named: "network"),
      ),
    ).thenAnswer((_) async => YieldsDto.fixture());

    const token0Address = "token0Address";
    const token1Address = "token1Address";

    await sut.getBestPools(
      token0AddressOrId: token0Address,
      token1AddressOrId: token1Address,
      group0Id: null,
      group1Id: null,
    );

    verify(
      () => yieldRepository.getSingleNetworkYield(
        token0Address: token0Address,
        token1Address: token1Address,
        group0Id: any(named: "group0Id"),
        group1Id: any(named: "group1Id"),
        searchSettings: any(named: "searchSettings"),
        network: any(named: "network"),
        blockedProtocolIds: any(named: "blockedProtocolIds"),
      ),
    ).called(1);
  });

  test(
    """When calling `getBestPools` with group ids, it should call the yield repository to get the best pools
    passing the group ids""",
    () async {
      when(
        () => yieldRepository.getSingleNetworkYield(
          token0Address: any(named: "token0Address"),
          token1Address: any(named: "token1Address"),
          searchSettings: any(named: "searchSettings"),
          blockedProtocolIds: any(named: "blockedProtocolIds"),
          group0Id: any(named: "group0Id"),
          group1Id: any(named: "group1Id"),
          network: any(named: "network"),
        ),
      ).thenAnswer((_) async => YieldsDto.fixture());

      const group0Id = "group0";
      const group1Id = "group1";

      await sut.getBestPools(token0AddressOrId: null, token1AddressOrId: null, group0Id: group0Id, group1Id: group1Id);

      verify(
        () => yieldRepository.getSingleNetworkYield(
          token0Address: null,
          token1Address: null,
          group0Id: group0Id,
          group1Id: group1Id,
          searchSettings: any(named: "searchSettings"),
          network: any(named: "network"),
          blockedProtocolIds: any(named: "blockedProtocolIds"),
        ),
      ).called(1);
    },
  );

  test(
    """When calling `getBestPools` with group ids and token addresses, it should call the yield repository to get the best pools
    passing both the token addresses and the group ids""",
    () async {
      when(
        () => yieldRepository.getSingleNetworkYield(
          token0Address: any(named: "token0Address"),
          token1Address: any(named: "token1Address"),
          searchSettings: any(named: "searchSettings"),
          blockedProtocolIds: any(named: "blockedProtocolIds"),
          group0Id: any(named: "group0Id"),
          group1Id: any(named: "group1Id"),
          network: any(named: "network"),
        ),
      ).thenAnswer((_) async => YieldsDto.fixture());

      const group0Id = "group0";
      const group1Id = "group1";

      const token0Address = "token0Address";
      const token1Address = "token1Address";

      await sut.getBestPools(
        token0AddressOrId: token0Address,
        token1AddressOrId: token1Address,
        group0Id: group0Id,
        group1Id: group1Id,
      );

      verify(
        () => yieldRepository.getSingleNetworkYield(
          token0Address: token0Address,
          token1Address: token1Address,
          group0Id: group0Id,
          group1Id: group1Id,
          searchSettings: any(named: "searchSettings"),
          network: any(named: "network"),
          blockedProtocolIds: any(named: "blockedProtocolIds"),
        ),
      ).called(1);
    },
  );

  test(
    """When calling `getBestPools` with group ids, and the network is all networks,
     it should call the yield repository to get the best pools for all networks
    passing the group ids""",
    () async {
      when(() => appCubit.selectedNetwork).thenReturn(AppNetworks.allNetworks);

      when(
        () => yieldRepository.getAllNetworksYield(
          token0InternalId: any(named: "token0InternalId"),
          token1InternalId: any(named: "token1InternalId"),
          searchSettings: any(named: "searchSettings"),
          blockedProtocolIds: any(named: "blockedProtocolIds"),
          group0Id: any(named: "group0Id"),
          group1Id: any(named: "group1Id"),
        ),
      ).thenAnswer((_) async => YieldsDto.fixture());

      const group0Id = "group0";
      const group1Id = "group1";

      await sut.getBestPools(token0AddressOrId: null, token1AddressOrId: null, group0Id: group0Id, group1Id: group1Id);

      verify(
        () => yieldRepository.getAllNetworksYield(
          token0InternalId: null,
          token1InternalId: null,
          group0Id: group0Id,
          group1Id: group1Id,
          searchSettings: any(named: "searchSettings"),

          blockedProtocolIds: any(named: "blockedProtocolIds"),
        ),
      ).called(1);
    },
  );

  test(
    """When calling `getBestPools` with group ids and token addresses at all networks,
    it should call the yield repository to get the best pools passing both the token
    addresses and the group ids to get pools for all networks""",
    () async {
      when(() => appCubit.selectedNetwork).thenReturn(AppNetworks.allNetworks);

      when(
        () => yieldRepository.getAllNetworksYield(
          token0InternalId: any(named: "token0InternalId"),
          token1InternalId: any(named: "token1InternalId"),
          searchSettings: any(named: "searchSettings"),
          blockedProtocolIds: any(named: "blockedProtocolIds"),
          group0Id: any(named: "group0Id"),
          group1Id: any(named: "group1Id"),
        ),
      ).thenAnswer((_) async => YieldsDto.fixture());

      const group0Id = "group0";
      const group1Id = "group1";
      const token0Address = "token0Address";
      const token1Address = "token1Address";

      await sut.getBestPools(
        token0AddressOrId: token0Address,
        token1AddressOrId: token1Address,
        group0Id: group0Id,
        group1Id: group1Id,
      );

      verify(
        () => yieldRepository.getAllNetworksYield(
          token0InternalId: token0Address,
          token1InternalId: token1Address,
          group0Id: group0Id,
          group1Id: group1Id,
          searchSettings: any(named: "searchSettings"),
          blockedProtocolIds: any(named: "blockedProtocolIds"),
        ),
      ).called(1);
    },
  );

  test(
    """When calling `getBestPools` and receiving an empty list of pools,
  it should emit the noYields state with the min liquidity searched returned
  from the repository""",
    () async {
      const minLiquidityUSD = 123;

      when(
        () => yieldRepository.getSingleNetworkYield(
          blockedProtocolIds: any(named: "blockedProtocolIds"),
          token0Address: any(named: "token0Address"),
          token1Address: any(named: "token1Address"),
          searchSettings: any(named: "searchSettings"),
          group0Id: any(named: "group0Id"),
          group1Id: any(named: "group1Id"),
          network: any(named: "network"),
        ),
      ).thenAnswer(
        (_) async => const YieldsDto(
          pools: [],
          filters: PoolSearchFiltersDto(minTvlUsd: minLiquidityUSD),
        ),
      );

      expectLater(
        sut.stream,
        emitsInOrder([
          const DepositState.loading(),
          const DepositState.noYields(filtersApplied: PoolSearchFiltersDto(minTvlUsd: minLiquidityUSD)),
        ]),
      );

      await sut.getBestPools(token0AddressOrId: "", token1AddressOrId: "", group0Id: null, group1Id: null);
    },
  );

  test("When calling `getBestPools` and receiving a list of pools it should emit success state", () async {
    final pools = YieldsDto.fixture();

    when(
      () => yieldRepository.getSingleNetworkYield(
        blockedProtocolIds: any(named: "blockedProtocolIds"),
        token0Address: any(named: "token0Address"),
        token1Address: any(named: "token1Address"),
        searchSettings: any(named: "searchSettings"),
        group1Id: any(named: "group1Id"),
        group0Id: any(named: "group0Id"),
        network: any(named: "network"),
      ),
    ).thenAnswer((_) async => pools);

    expectLater(sut.stream, emitsInOrder([const DepositState.loading(), DepositState.success(pools)]));

    await sut.getBestPools(token0AddressOrId: "", token1AddressOrId: "", group0Id: null, group1Id: null);
  });

  test("When calling `getBestPools` and receiving an error, it should emit the error state", () async {
    when(
      () => yieldRepository.getSingleNetworkYield(
        blockedProtocolIds: any(named: "blockedProtocolIds"),
        token0Address: any(named: "token0Address"),
        token1Address: any(named: "token1Address"),
        searchSettings: any(named: "searchSettings"),
        group0Id: any(named: "group0Id"),
        group1Id: any(named: "group1Id"),
        network: any(named: "network"),
      ),
    ).thenThrow(Exception());

    expectLater(sut.stream, emitsInOrder([const DepositState.loading(), const DepositState.error()]));

    await sut.getBestPools(token0AddressOrId: "", token1AddressOrId: "", group0Id: null, group1Id: null);
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

  test("When calling `selectYield` with a non-empty yield it should get the pool sqrtPriceX96", () async {
    final selectedYield = YieldDto.fixture();

    await sut.selectYield(selectedYield);

    verify(() => poolService.getSqrtPriceX96(selectedYield)).called(1);
  });

  test("When calling `selectYield` but the yield is null, it should not get the pool sqrtPriceX96", () async {
    await sut.selectYield(null);

    verifyNever(() => uniswapV3PoolImpl.slot0());
  });

  test("When calling `getSelectedPoolSqrtPriceX96` it should set the latest pool sqrtPriceX96 to null", () async {
    expectLater(sut.latestPoolSqrtPriceX96, null);

    await sut.selectYield(YieldDto.fixture());
    await sut.getSelectedPoolSqrtPriceX96();
  });

  test("When calling `getSelectedPoolSqrtPriceX96` it should use the pool service to get it", () async {
    final yieldDto = YieldDto.fixture();
    await sut.selectYield(yieldDto);
    await sut.getSelectedPoolSqrtPriceX96();

    verify(() => poolService.getSqrtPriceX96(yieldDto)).called(1);
  });

  test(
    """"
  When calling `getSelectedPoolSqrtPriceX96` for a selected pool,
  but when the call to the contract completes, the selected pool
  is not the same as the one passed to the call, it shoul re-call
  `getSelectedPoolSqrtPriceX96` to get the correct pool sqrtPriceX96""",
    () async {
      final expectedYieldBsqrtPriceX96 = BigInt.from(326287637265372111);

      const yieldAPoolAddress = "0x3263782637263";
      const yieldBPoolAddress = "0xPoolAddressYieldB";

      final yieldA = YieldDto.fixture().copyWith(poolAddress: yieldAPoolAddress);
      final yieldB = YieldDto.fixture().copyWith(poolAddress: yieldBPoolAddress);

      when(() => poolService.getSqrtPriceX96(any())).thenAnswer((_) async {
        when(() => poolService.getSqrtPriceX96(any())).thenAnswer((_) async {
          return expectedYieldBsqrtPriceX96;
        });

        await sut.selectYield(yieldB);

        return poolSqrtPriceX96;
      });

      await sut.selectYield(yieldA); // assuming that select yield will call `getSelectedPoolSqrtPriceX96`

      verify(
        () => poolService.getSqrtPriceX96(yieldB),
      ).called(1); // 2 because of the check in the `getSelectedPoolSqrtPriceX96` that will re-call, and the selection

      expect(sut.latestPoolSqrtPriceX96, expectedYieldBsqrtPriceX96);
    },
  );

  test(
    """When calling `selectYield` it should first emit the selected yield latest sqrtPriceX96 from the DTO
      (without making a contract call)""",
    () {
      final sqrtPriceX96 = BigInt.from(27189);

      expectLater(sut.poolSqrtPriceX96Stream, emits(sqrtPriceX96));

      sut.selectYield(YieldDto.fixture().copyWith(latestSqrtPriceX96: sqrtPriceX96.toString()));

      expect(sut.latestPoolSqrtPriceX96, sqrtPriceX96);
    },
  );

  test(
    """When calling 'getSelectedPoolSqrtPriceX96' with `forceRefresh` true,
  it should get the sqrtPriceX96 again regardless of the cached value""",
    () async {
      final selectedYield = YieldDto.fixture();
      when(() => poolService.getSqrtPriceX96(any())).thenAnswer((_) async => poolSqrtPriceX96);

      await sut.selectYield(selectedYield);
      await sut.getSelectedPoolSqrtPriceX96(forceRefresh: true);

      verify(() => poolService.getSqrtPriceX96(selectedYield)).called(2);
    },
  );

  test(
    """When calling 'getSelectedPoolSqrtPriceX96' multiple times for the same
    pool within a minute, it should not get the sqrtPriceX96 again from the
    contract. Instead, it should use the cached value""",
    () async {
      final selectedYield = YieldDto.fixture();
      when(() => poolService.getSqrtPriceX96(any())).thenAnswer((_) async => poolSqrtPriceX96);

      await sut.selectYield(selectedYield);

      await sut.getSelectedPoolSqrtPriceX96();
      await sut.getSelectedPoolSqrtPriceX96();
      await sut.getSelectedPoolSqrtPriceX96();
      await sut.getSelectedPoolSqrtPriceX96();
      await sut.getSelectedPoolSqrtPriceX96();

      verify(() => poolService.getSqrtPriceX96(selectedYield)).called(1);
    },
  );

  test(
    """When calling 'getSelectedPoolSqrtPriceX96' multiple times for different
    pools in the same network, it should get the sqrtPriceX96 again for each
    one and emit it""",
    () async {
      final yieldA = YieldDto.fixture().copyWith(poolAddress: "0xPoolAddressYieldA");
      final yieldB = YieldDto.fixture().copyWith(poolAddress: "0xPoolAddressYieldB");
      final yieldC = YieldDto.fixture().copyWith(poolAddress: "0xPoolAddressYieldC");

      when(() => poolService.getSqrtPriceX96(any())).thenAnswer((_) async => poolSqrtPriceX96);

      await sut.selectYield(yieldA); // assuming that select yield will call `getSelectedPoolSqrtPriceX96`
      await sut.selectYield(yieldB);
      await sut.selectYield(yieldC);

      verify(() => poolService.getSqrtPriceX96(yieldA)).called(1);
      verify(() => poolService.getSqrtPriceX96(yieldB)).called(1);
      verify(() => poolService.getSqrtPriceX96(yieldC)).called(1);
    },
  );

  test(
    """When calling 'getSelectedPoolSqrtPriceX96' multiple times for different
    pools in other networks, it should get the sqrtPriceX96 again for each
    one and emit it""",
    () async {
      final yieldA = YieldDto.fixture().copyWith(
        poolAddress: "0xPoolAddressYieldA",
        chainId: AppNetworks.mainnet.chainId,
      );
      final yieldB = YieldDto.fixture().copyWith(
        poolAddress: "0xPoolAddressYieldB",
        chainId: AppNetworks.sepolia.chainId,
      );
      final yieldC = YieldDto.fixture().copyWith(
        poolAddress: "0xPoolAddressYieldC",
        chainId: AppNetworks.unichain.chainId,
      );

      when(() => poolService.getSqrtPriceX96(any())).thenAnswer((_) async => poolSqrtPriceX96);

      await sut.selectYield(yieldA); // assuming that select yield will call `getSelectedPoolSqrtPriceX96`
      await sut.selectYield(yieldB);
      await sut.selectYield(yieldC);

      verify(() => poolService.getSqrtPriceX96(yieldA)).called(1);
      verify(() => poolService.getSqrtPriceX96(yieldB)).called(1);
      verify(() => poolService.getSqrtPriceX96(yieldC)).called(1);
    },
  );

  test(
    """When calling 'getSelectedPoolSqrtPriceX96' multiple times for the same
    pool address but in other networks, it should get the sqrtPriceX96 again for each
    one and emit it""",
    () async {
      const poolAddress = "0xPoolAddress";
      final yieldA = YieldDto.fixture().copyWith(poolAddress: poolAddress, chainId: AppNetworks.mainnet.chainId);
      final yieldB = YieldDto.fixture().copyWith(poolAddress: poolAddress, chainId: AppNetworks.sepolia.chainId);
      final yieldC = YieldDto.fixture().copyWith(poolAddress: poolAddress, chainId: AppNetworks.unichain.chainId);

      when(() => poolService.getSqrtPriceX96(any())).thenAnswer((_) async => poolSqrtPriceX96);

      await sut.selectYield(yieldA); // assuming that select yield will call `getSelectedPoolSqrtPriceX96`
      await sut.selectYield(yieldB);
      await sut.selectYield(yieldC);

      verify(() => poolService.getSqrtPriceX96(yieldA)).called(1);
      verify(() => poolService.getSqrtPriceX96(yieldB)).called(1);
      verify(() => poolService.getSqrtPriceX96(yieldC)).called(1);
    },
  );

  test(
    """When calling 'getSelectedPoolSqrtPriceX96', it should use the zup singleton cache
    with a expiration of half a minute (-1 second to not cause race conditions)""",
    () async {
      final selectedYield = YieldDto.fixture();

      zupSingletonCache = ZupSingletonCacheMock();
      sut = DepositCubit(yieldRepository, zupSingletonCache, wallet, cache, appCubit, zupAnalytics, poolService);
      when(() => poolService.getSqrtPriceX96(any())).thenAnswer((_) async => poolSqrtPriceX96);
      when(() => zupSingletonCache.clear()).thenAnswer((_) async => {});
      when(
        () => zupSingletonCache.run<BigInt>(
          any(),
          key: any(named: "key"),
          expiration: any(named: "expiration"),
          ignoreCache: any(named: "ignoreCache"),
        ),
      ).thenAnswer((_) async => poolSqrtPriceX96);

      await sut.selectYield(selectedYield);
      await sut.getSelectedPoolSqrtPriceX96();

      verify(
        () => zupSingletonCache.run<BigInt>(
          any(),
          key: "sqrtPrice-${selectedYield.poolAddress}-${selectedYield.network.name}",
          expiration: const Duration(seconds: 30 - 1),
          ignoreCache: false,
        ),
      ).called(1);
    },
  );

  test(
    """When calling `getSelectedPoolSqrtPriceX96`
  it should emit the pool sqrtPriceX96 got from
  the contract, after emitting the one
  from the yield call""",
    () async {
      final newExpectedSqrtPriceX96 = BigInt.from(97866745634534392);
      final latestsqrtPriceX96 = BigInt.from(27189);

      when(() => poolService.getSqrtPriceX96(any())).thenAnswer((_) async => newExpectedSqrtPriceX96);

      expectLater(sut.poolSqrtPriceX96Stream, emitsInOrder([latestsqrtPriceX96, newExpectedSqrtPriceX96]));

      await sut.selectYield(
        YieldDto.fixture().copyWith(latestSqrtPriceX96: latestsqrtPriceX96.toString()),
      ); // assuming that select yield will call `getSelectedPoolSqrtPriceX96`
    },
  );

  test("When calling `getSelectedPoolSqrtPriceX96` it should save the pool sqrtPriceX96 in the cubit", () async {
    final expectedPoolSqrtPriceX96 = BigInt.from(97866745634534392);

    when(() => poolService.getSqrtPriceX96(any())).thenAnswer((_) async => expectedPoolSqrtPriceX96);

    await sut.selectYield(YieldDto.fixture()); // assuming that select yield will call `getSelectedPoolSqrtPriceX96`

    expect(sut.latestPoolSqrtPriceX96, expectedPoolSqrtPriceX96);
  });

  test("When calling `getSelectedPoolSqrtPriceX96` it should save the same sqrtPriceX96 as the emitted ", () async {
    final newWxpectedPoolSqrtPriceX96 = BigInt.from(97866745634534392);
    final yieldSqrtPriceX96 = BigInt.from(27189);

    when(() => poolService.getSqrtPriceX96(any())).thenAnswer((_) async => newWxpectedPoolSqrtPriceX96);

    expectLater(sut.poolSqrtPriceX96Stream, emitsInOrder([yieldSqrtPriceX96, newWxpectedPoolSqrtPriceX96]));

    await sut.selectYield(
      YieldDto.fixture().copyWith(latestSqrtPriceX96: yieldSqrtPriceX96.toString()),
    ); // assuming that select yield will call `getSelectedPoolSqrtPriceX96`

    expect(sut.latestPoolSqrtPriceX96, newWxpectedPoolSqrtPriceX96);
  });

  test("when closing the cubit, it should close the pool sqrtPriceX96 stream", () async {
    await sut.selectYield(YieldDto.fixture());
    await sut.close();

    expect(() async => await sut.getSelectedPoolSqrtPriceX96(), throwsA(isA<StateError>()));
  });

  test("When closing the cubit, it should close the selected yield stream", () async {
    await sut.close();

    expect(() async => await sut.selectYield(YieldDto.fixture()), throwsA(isA<StateError>()));
  });

  test("When calling `getWalletTokenAmount` and there's no connected signer, it should return 0", () async {
    final tokenAmount = await sut.getWalletTokenAmount("", network: AppNetworks.sepolia);

    expect(tokenAmount, 0);
  });

  test(
    "When calling `getWalletTokenAmount` and there's a connected signer it should get the wallet token amount",
    () async {
      final signer = SignerMock();
      const tokenAddress = "0x0";
      const network = AppNetworks.sepolia;
      const expectedTokenBalance = 1243.542;

      when(
        () => wallet.nativeOrTokenBalance(tokenAddress, rpcUrl: any(named: "rpcUrl")),
      ).thenAnswer((_) async => 1243.542);
      when(() => wallet.signer).thenReturn(signer);
      when(() => signer.address).thenAnswer((_) async => "0x99E3CfADCD8Feecb5DdF91f88998cFfB3145F78c");

      final actualTokenBalance = await sut.getWalletTokenAmount(tokenAddress, network: network);

      expect(actualTokenBalance, expectedTokenBalance);
      verify(() => wallet.nativeOrTokenBalance(tokenAddress, rpcUrl: network.rpcUrl)).called(1);
    },
  );

  test(
    "When calling `getWalletTokenAmount` it should use zup singleton cache to return the cached value if the cache is not more than 10 minutes old",
    () async {
      const tokenAddress = "0x0";
      final signer = SignerMock();
      const network = AppNetworks.sepolia;
      const expectedTokenBalance = 1243.542;
      const notExpectedTokenBalance = 498361387.42;

      when(
        () => wallet.nativeOrTokenBalance(tokenAddress, rpcUrl: any(named: "rpcUrl")),
      ).thenAnswer((_) async => 1243.542);
      when(() => wallet.signer).thenReturn(signer);
      when(() => signer.address).thenAnswer((_) async => "0x99E3CfADCD8Feecb5DdF91f88998cFfB3145F78c");

      final actualTokenBalance1 = await sut.getWalletTokenAmount(tokenAddress, network: network);

      when(
        () => wallet.nativeOrTokenBalance(tokenAddress, rpcUrl: any(named: "rpcUrl")),
      ).thenAnswer((_) async => notExpectedTokenBalance);

      final actualTokenBalance2 = await sut.getWalletTokenAmount(tokenAddress, network: network);

      verify(() => wallet.nativeOrTokenBalance(tokenAddress, rpcUrl: network.rpcUrl)).called(1);

      expect(actualTokenBalance1, expectedTokenBalance);
      expect(actualTokenBalance2, expectedTokenBalance);
    },
  );

  test(
    "When calling `getWalletTokenAmount` it should use zup singleton cache with a 10 minutes expiration time",
    () async {
      const tokenAddress = "0x0";
      final signer = SignerMock();
      const network = AppNetworks.sepolia;
      const expectedTokenBalance = 1243.542;
      const notExpectedTokenBalance = 498361387.42;

      when(
        () => wallet.nativeOrTokenBalance(tokenAddress, rpcUrl: any(named: "rpcUrl")),
      ).thenAnswer((_) async => notExpectedTokenBalance);
      when(() => wallet.signer).thenReturn(signer);
      when(() => signer.address).thenAnswer((_) async => "0x99E3CfADCD8Feecb5DdF91f88998cFfB3145F78c");

      await sut.getWalletTokenAmount(tokenAddress, network: network);

      await withClock(Clock(() => DateTime.now().add(const Duration(minutes: 11))), () async {
        when(
          () => wallet.nativeOrTokenBalance(tokenAddress, rpcUrl: any(named: "rpcUrl")),
        ).thenAnswer((_) async => expectedTokenBalance);

        final actualTokenBalance2 = await sut.getWalletTokenAmount(tokenAddress, network: network);

        verify(
          () => wallet.nativeOrTokenBalance(tokenAddress, rpcUrl: network.rpcUrl),
        ).called(2); // it should call the method twice because the cache is expired

        expect(actualTokenBalance2, expectedTokenBalance);
      });
    },
  );

  test(
    "When calling `getWalletTokenAmount` and an error occurs getting the wallet balance, it should return 0",
    () async {
      final signer = SignerMock();
      const tokenAddress = "0x0";
      const network = AppNetworks.sepolia;

      when(() => wallet.tokenBalance(tokenAddress, rpcUrl: any(named: "rpcUrl"))).thenThrow(Exception());
      when(() => wallet.signer).thenReturn(signer);
      when(() => signer.address).thenAnswer((_) async => "0x99E3CfADCD8Feecb5DdF91f88998cFfB3145F78c");

      final actualTokenBalance = await sut.getWalletTokenAmount(tokenAddress, network: network);

      expect(actualTokenBalance, 0.0);
    },
  );

  test("When calling `saveDepositSettings` it should save the passed params in the cache", () async {
    when(() => cache.saveDepositSettings(any())).thenAnswer((_) async => () {});

    const slippage = Slippage.zeroPointOnePercent;
    const deadline = Duration(minutes: 5);

    final expectedDepositSettings = DepositSettingsDto(
      deadlineMinutes: deadline.inMinutes,
      maxSlippage: slippage.value.toDouble(),
    );

    await sut.saveDepositSettings(slippage, deadline);

    verify(() => cache.saveDepositSettings(expectedDepositSettings)).called(1);
  });

  test("When calling `depositSettings` it should get the deposit settings from the cache", () {
    const expectedDepositSettings = DepositSettingsDto(deadlineMinutes: 5, maxSlippage: 0.01);

    when(() => cache.getDepositSettings()).thenReturn(expectedDepositSettings);

    final actualDepositSettings = sut.depositSettings;

    expect(actualDepositSettings, expectedDepositSettings);
  });

  test("When calling 'poolSearchSettings' it should get the pool search settings from the cache", () {
    final expectedPoolSearchSettings = PoolSearchSettingsDto(minLiquidityUSD: 129816);

    when(() => cache.getPoolSearchSettings()).thenReturn(expectedPoolSearchSettings);
    final actualPoolSearchSettings = sut.poolSearchSettings;

    expect(actualPoolSearchSettings, expectedPoolSearchSettings);
  });

  test(
    """When calling 'getBestPools' with the param 'ignoreMinLiquidity' true,
  it should pass the minLiquidityUSD as 0 to the repository""",
    () async {
      when(() => cache.getPoolSearchSettings()).thenReturn(PoolSearchSettingsDto(minLiquidityUSD: 129816));

      when(
        () => yieldRepository.getSingleNetworkYield(
          blockedProtocolIds: any(named: "blockedProtocolIds"),
          token0Address: any(named: "token0Address"),
          token1Address: any(named: "token1Address"),
          group0Id: any(named: "group0Id"),
          group1Id: any(named: "group1Id"),
          network: any(named: "network"),
          searchSettings: any(named: "searchSettings"),
        ),
      ).thenAnswer((_) async => YieldsDto.fixture());

      await sut.getBestPools(
        token0AddressOrId: "0x",
        token1AddressOrId: "0x",
        group0Id: null,
        group1Id: null,
        ignoreMinLiquidity: true,
      );

      verify(
        () => yieldRepository.getSingleNetworkYield(
          blockedProtocolIds: any(named: "blockedProtocolIds"),
          token0Address: any(named: "token0Address"),
          token1Address: any(named: "token1Address"),
          group0Id: any(named: "group0Id"),
          group1Id: any(named: "group1Id"),
          network: any(named: "network"),
          searchSettings: PoolSearchSettingsDto.fixture().copyWith(minLiquidityUSD: 0),
        ),
      ).called(1);
    },
  );

  test(
    """When calling 'getBestPools' with the current network as all networks and the param
  'ignoreMinLiquidity' true, it should pass the minLiquidityUSD as 0 to the repository""",
    () async {
      when(() => appCubit.selectedNetwork).thenReturn(AppNetworks.allNetworks);
      when(() => cache.getPoolSearchSettings()).thenReturn(PoolSearchSettingsDto(minLiquidityUSD: 129816));
      when(
        () => yieldRepository.getAllNetworksYield(
          blockedProtocolIds: any(named: "blockedProtocolIds"),
          token0InternalId: any(named: "token0InternalId"),
          token1InternalId: any(named: "token1InternalId"),
          group0Id: any(named: "group0Id"),
          group1Id: any(named: "group1Id"),
          searchSettings: any(named: "searchSettings"),
        ),
      ).thenAnswer((_) async => YieldsDto.fixture());

      await sut.getBestPools(
        token0AddressOrId: "0x",
        token1AddressOrId: "0x",
        ignoreMinLiquidity: true,
        group0Id: null,
        group1Id: null,
      );

      verify(
        () => yieldRepository.getAllNetworksYield(
          blockedProtocolIds: any(named: "blockedProtocolIds"),
          token0InternalId: any(named: "token0InternalId"),
          token1InternalId: any(named: "token1InternalId"),
          group0Id: any(named: "group0Id"),
          group1Id: any(named: "group1Id"),
          searchSettings: PoolSearchSettingsDto.fixture().copyWith(minLiquidityUSD: 0),
        ),
      ).called(1);
    },
  );

  test(
    """When calling 'getBestPools' with the param 'ignoreMinLiquidity' false,
  it should pass the minLiquidityUSD as the saved value to the repository""",
    () async {
      const minLiquiditySaved = 129816;

      when(() => cache.getPoolSearchSettings()).thenReturn(PoolSearchSettingsDto(minLiquidityUSD: minLiquiditySaved));
      when(
        () => yieldRepository.getSingleNetworkYield(
          blockedProtocolIds: any(named: "blockedProtocolIds"),
          token0Address: any(named: "token0Address"),
          token1Address: any(named: "token1Address"),
          group0Id: any(named: "group0Id"),
          group1Id: any(named: "group1Id"),
          network: any(named: "network"),
          searchSettings: any(named: "searchSettings"),
        ),
      ).thenAnswer((_) async => YieldsDto.fixture());

      await sut.getBestPools(
        token0AddressOrId: "0x",
        token1AddressOrId: "0x",
        ignoreMinLiquidity: false,
        group0Id: null,
        group1Id: null,
      );

      verify(
        () => yieldRepository.getSingleNetworkYield(
          blockedProtocolIds: any(named: "blockedProtocolIds"),
          token0Address: any(named: "token0Address"),
          token1Address: any(named: "token1Address"),
          group0Id: any(named: "group0Id"),
          group1Id: any(named: "group1Id"),
          network: any(named: "network"),
          searchSettings: PoolSearchSettingsDto.fixture().copyWith(minLiquidityUSD: minLiquiditySaved),
        ),
      ).called(1);
    },
  );

  test("when calling `getBestPools` it should log the search on analytics with the correct events", () {
    const token0Address = "0x123";
    const token1Address = "0x456";
    const network = AppNetworks.sepolia;

    when(() => appCubit.selectedNetwork).thenReturn(network);

    sut.getBestPools(
      token0AddressOrId: token0Address,
      token1AddressOrId: token1Address,
      group0Id: null,
      group1Id: null,
    );

    verify(
      () => zupAnalytics.logSearch(
        token0: token0Address,
        token1: token1Address,
        network: network.label,
        group0: null,
        group1: null,
      ),
    ).called(1);
  });

  test(
    "When calling `getBestPools` and the network is all networks, it should call the endpoint to search in all networks",
    () async {
      const token0Address = "0x123";
      const token1Address = "0x456";

      when(() => appCubit.selectedNetwork).thenReturn(AppNetworks.allNetworks);

      await sut.getBestPools(
        token0AddressOrId: token0Address,
        token1AddressOrId: token1Address,
        group0Id: null,
        group1Id: null,
      );

      verify(
        () => yieldRepository.getAllNetworksYield(
          blockedProtocolIds: any(named: "blockedProtocolIds"),
          token0InternalId: token0Address,
          token1InternalId: token1Address,
          group0Id: any(named: "group0Id"),
          group1Id: any(named: "group1Id"),
          searchSettings: any(named: "searchSettings"),
        ),
      ).called(1);
    },
  );

  test(
    """When calling 'getBestPools' and all networks is the selected network,
  it should call the repository to get it passing the blocked protocol ids got
  from the cache""",
    () async {
      final cachedBlockedProtocolIds = ["0x1", "0x2", "ababa"];
      when(() => cache.blockedProtocolsIds).thenReturn(cachedBlockedProtocolIds);
      when(() => appCubit.selectedNetwork).thenReturn(AppNetworks.allNetworks);

      await sut.getBestPools(token0AddressOrId: "0x", token1AddressOrId: "0x", group0Id: null, group1Id: null);

      verify(
        () => yieldRepository.getAllNetworksYield(
          blockedProtocolIds: cachedBlockedProtocolIds,
          token0InternalId: any(named: "token0InternalId"),
          token1InternalId: any(named: "token1InternalId"),
          group0Id: any(named: "group0Id"),
          group1Id: any(named: "group1Id"),
          searchSettings: any(named: "searchSettings"),
        ),
      ).called(1);
    },
  );

  test(
    """When calling 'getBestPools' and all networks is not the selected network,
  it should call the repository to get it passing the blocked protocol ids got
  from the cache""",
    () async {
      final cachedBlockedProtocolIds = ["017628761", "asaas", "ababa"];
      when(() => cache.blockedProtocolsIds).thenReturn(cachedBlockedProtocolIds);
      when(() => appCubit.selectedNetwork).thenReturn(AppNetworks.sepolia);

      await sut.getBestPools(token0AddressOrId: "0x", token1AddressOrId: "0x", group0Id: null, group1Id: null);

      verify(
        () => yieldRepository.getSingleNetworkYield(
          blockedProtocolIds: cachedBlockedProtocolIds,
          network: any(named: "network"),
          token0Address: any(named: "token0Address"),
          token1Address: any(named: "token1Address"),
          group0Id: any(named: "group0Id"),
          group1Id: any(named: "group1Id"),
          searchSettings: any(named: "searchSettings"),
        ),
      ).called(1);
    },
  );
}
