import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zup_app/app/app_cubit/app_cubit.dart';
import 'package:zup_app/app/create/yields/yields_cubit.dart';
import 'package:zup_app/core/app_cache.dart';
import 'package:zup_app/core/dtos/pool_search_filters_dto.dart';
import 'package:zup_app/core/dtos/pool_search_settings_dto.dart';
import 'package:zup_app/core/dtos/yields_dto.dart';
import 'package:zup_app/core/enums/networks.dart';
import 'package:zup_app/core/repositories/yield_repository.dart';
import 'package:zup_app/core/zup_analytics.dart';

import '../../../mocks.dart';

void main() {
  late YieldsCubit sut;
  late AppCubit appCubit;
  late AppCache appCache;
  late YieldRepository yieldRepository;
  late ZupAnalytics zupAnalytics;

  setUp(() {
    appCubit = AppCubitMock();
    appCache = AppCacheMock();
    yieldRepository = YieldRepositoryMock();
    zupAnalytics = ZupAnalyticsMock();

    registerFallbackValue(PoolSearchSettingsDto());
    registerFallbackValue(AppNetworks.mainnet);

    sut = YieldsCubit(appCubit, appCache, yieldRepository, zupAnalytics);

    when(() => appCubit.selectedNetwork).thenReturn(AppNetworks.mainnet);
    when(() => appCubit.isTestnetMode).thenReturn(false);
    when(() => appCache.blockedProtocolsIds).thenReturn([]);
    when(() => appCache.getPoolSearchSettings()).thenReturn(PoolSearchSettingsDto());
    when(
      () => zupAnalytics.logSearch(
        token0: any(named: "token0"),
        token1: any(named: "token1"),
        group0: any(named: "group0"),
        group1: any(named: "group1"),
        network: any(named: "network"),
      ),
    ).thenAnswer((_) async => ());
  });

  test("When calling 'fetchYields' it should first emit the loading state", () async {
    const token0AddressOrId = "token0AddressOrId";
    const token1AddressOrId = "token1AddressOrId";
    const group0Id = "group0Id";
    const group1Id = "group1Id";

    expectLater(sut.stream, emits(const YieldsState.loading()));

    await sut.fetchYields(
      token0AddressOrId: token0AddressOrId,
      token1AddressOrId: token1AddressOrId,
      group0Id: group0Id,
      group1Id: group1Id,
    );
  });

  test(
    """When calling 'fetchYields' it should use the analytics to log the
    search passing the ids and the network""",
    () async {
      const token0AddressOrId = "xabas1";
      const token1AddressOrId = "xabas2";
      const group0Id = "sabax1";
      const group1Id = "sabax2";
      const network = AppNetworks.sepolia;

      when(() => appCubit.selectedNetwork).thenReturn(network);

      await sut.fetchYields(
        token0AddressOrId: token0AddressOrId,
        token1AddressOrId: token1AddressOrId,
        group0Id: group0Id,
        group1Id: group1Id,
      );

      verify(
        () => zupAnalytics.logSearch(
          token0: token0AddressOrId,
          token1: token1AddressOrId,
          group0: group0Id,
          group1: group1Id,
          network: network.label,
        ),
      ).called(1);
    },
  );

  test(
    """When calling 'fetchYields' with all networks as selected
     network in app cubit, it should call the repository to get
     all networks yields passing the correct ids and cached
     user preferences for the search""",
    () async {
      final expectedPoolSearchSettings = PoolSearchSettingsDto(
        allowV3Search: true,
        allowV4Search: false,
        minLiquidityUSD: 12618291,
      );
      final expectedBlockedProtocolsIds = ["xasb12", "xasb13", "xasb14"];

      const expectedToken0AddressOrId = "xabas1";
      const expectedToken1AddressOrId = "xabas2";
      const expectedGroup0Id = "sabax1";
      const expectedGroup1Id = "sabax2";

      when(() => appCache.blockedProtocolsIds).thenReturn(expectedBlockedProtocolsIds);
      when(() => appCache.getPoolSearchSettings()).thenReturn(expectedPoolSearchSettings);
      when(() => appCubit.selectedNetwork).thenReturn(AppNetworks.allNetworks);

      await sut.fetchYields(
        token0AddressOrId: expectedToken0AddressOrId,
        token1AddressOrId: expectedToken1AddressOrId,
        group0Id: expectedGroup0Id,
        group1Id: expectedGroup1Id,
      );

      verify(
        () => yieldRepository.getAllNetworksYield(
          group0Id: expectedGroup0Id,
          group1Id: expectedGroup1Id,
          token0InternalId: expectedToken0AddressOrId,
          token1InternalId: expectedToken1AddressOrId,
          blockedProtocolIds: expectedBlockedProtocolsIds,
          searchSettings: expectedPoolSearchSettings,
          testnetMode: any(named: "testnetMode"),
        ),
      ).called(1);
    },
  );

  test(
    """When calling 'fetchYields' with a single network selected
     in app cubit, it should call the repository to get
     the selected network yields passing the correct ids and cached
     user preferences for the search""",
    () async {
      final expectedPoolSearchSettings = PoolSearchSettingsDto(
        allowV3Search: true,
        allowV4Search: false,
        minLiquidityUSD: 12618291,
      );
      final expectedBlockedProtocolsIds = ["xasb12", "xasb13", "xasb14"];
      const selectedNetwork = AppNetworks.mainnet;
      const expectedToken0AddressOrId = "xabas1";
      const expectedToken1AddressOrId = "xabas2";
      const expectedGroup0Id = "sabax1";
      const expectedGroup1Id = "sabax2";

      when(() => appCache.blockedProtocolsIds).thenReturn(expectedBlockedProtocolsIds);
      when(() => appCache.getPoolSearchSettings()).thenReturn(expectedPoolSearchSettings);
      when(() => appCubit.selectedNetwork).thenReturn(selectedNetwork);

      await sut.fetchYields(
        token0AddressOrId: expectedToken0AddressOrId,
        token1AddressOrId: expectedToken1AddressOrId,
        group0Id: expectedGroup0Id,
        group1Id: expectedGroup1Id,
      );

      verify(
        () => yieldRepository.getSingleNetworkYield(
          group0Id: expectedGroup0Id,
          group1Id: expectedGroup1Id,
          token0Address: expectedToken0AddressOrId,
          token1Address: expectedToken1AddressOrId,
          blockedProtocolIds: expectedBlockedProtocolsIds,
          searchSettings: expectedPoolSearchSettings,
          network: selectedNetwork,
        ),
      ).called(1);
    },
  );

  test(
    """When calling 'fetchYields' with all networks as selected
     network in app cubit and passing to ignore min liquidity,
     it should ignore the cached min liquidity preference
     and pass 0 to the repository""",
    () async {
      final savedPoolSearchSettings = PoolSearchSettingsDto(
        allowV3Search: true,
        allowV4Search: false,
        minLiquidityUSD: 12618291,
      );

      when(() => appCache.getPoolSearchSettings()).thenReturn(savedPoolSearchSettings);
      when(() => appCubit.selectedNetwork).thenReturn(AppNetworks.allNetworks);

      await sut.fetchYields(
        token0AddressOrId: "",
        token1AddressOrId: "",
        group0Id: "",
        group1Id: "",
        ignoreMinLiquidity: true,
      );

      verify(
        () => yieldRepository.getAllNetworksYield(
          group0Id: any(named: "group0Id"),
          group1Id: any(named: "group1Id"),
          token0InternalId: any(named: "token0InternalId"),
          token1InternalId: any(named: "token1InternalId"),
          blockedProtocolIds: any(named: "blockedProtocolIds"),
          searchSettings: savedPoolSearchSettings.copyWith(minLiquidityUSD: 0),
          testnetMode: any(named: "testnetMode"),
        ),
      ).called(1);
    },
  );

  test(
    """When calling 'fetchYields' with a single network selected
     in app cubit and passing to ignore min liquidity,
     it should ignore the cached min liquidity preference
     and pass 0 to the repository""",
    () async {
      final savedPoolSearchSettings = PoolSearchSettingsDto(
        allowV3Search: true,
        allowV4Search: false,
        minLiquidityUSD: 12618291,
      );

      when(() => appCache.getPoolSearchSettings()).thenReturn(savedPoolSearchSettings);
      when(() => appCubit.selectedNetwork).thenReturn(AppNetworks.mainnet);

      await sut.fetchYields(
        token0AddressOrId: "",
        token1AddressOrId: "",
        group0Id: "",
        group1Id: "",
        ignoreMinLiquidity: true,
      );

      verify(
        () => yieldRepository.getSingleNetworkYield(
          group0Id: any(named: "group0Id"),
          group1Id: any(named: "group1Id"),
          network: any(named: "network"),
          token0Address: any(named: "token0Address"),
          token1Address: any(named: "token1Address"),
          blockedProtocolIds: any(named: "blockedProtocolIds"),
          searchSettings: savedPoolSearchSettings.copyWith(minLiquidityUSD: 0),
        ),
      ).called(1);
    },
  );

  test(
    """When calling 'fetchYields' with testnet mode enabled
    in the app cubit, and `all networks`,
    it should pass it to the repository call""",
    () async {
      when(() => appCubit.selectedNetwork).thenReturn(AppNetworks.allNetworks);
      when(() => appCubit.isTestnetMode).thenReturn(true);

      await sut.fetchYields(
        token0AddressOrId: "",
        token1AddressOrId: "",
        group0Id: "",
        group1Id: "",
        ignoreMinLiquidity: true,
      );

      verify(
        () => yieldRepository.getAllNetworksYield(
          group0Id: any(named: "group0Id"),
          group1Id: any(named: "group1Id"),
          token0InternalId: any(named: "token0InternalId"),
          token1InternalId: any(named: "token1InternalId"),
          blockedProtocolIds: any(named: "blockedProtocolIds"),
          searchSettings: any(named: "searchSettings"),
          testnetMode: true,
        ),
      ).called(1);
    },
  );

  test(
    """When returning empty pools list for all networks search,
   it should emit empty state passing the returned filters applied""",
    () async {
      const expectedFilters = PoolSearchFiltersDto(
        allowedPoolTypes: ["xabasbab", "jajajajajajajajajaja"],
        blockedProtocols: ["chaves", "kiko"],
        minTvlUsd: 12618,
        testnetMode: true,
      );

      when(() => appCubit.selectedNetwork).thenReturn(AppNetworks.allNetworks);

      when(
        () => yieldRepository.getAllNetworksYield(
          token0InternalId: any(named: "token0InternalId"),
          token1InternalId: any(named: "token1InternalId"),
          group0Id: any(named: "group0Id"),
          group1Id: any(named: "group1Id"),
          searchSettings: any(named: "searchSettings"),
          blockedProtocolIds: any(named: "blockedProtocolIds"),
        ),
      ).thenAnswer((_) async => const YieldsDto(pools: [], filters: expectedFilters));

      await sut.fetchYields(
        token0AddressOrId: "token0AddressOrId",
        token1AddressOrId: "token1AddressOrId",
        group0Id: "group0Id",
        group1Id: "group1Id",
      );

      expect(sut.state, const YieldsState.noYields(filtersApplied: expectedFilters));
    },
  );

  test(
    """When returning empty pools list for single network search,
   it should emit empty state passing the returned filters applied""",
    () async {
      const expectedFilters = PoolSearchFiltersDto(
        allowedPoolTypes: ["xabasbab", "jajajajajajajajajaja"],
        blockedProtocols: ["chaves", "kiko"],
        minTvlUsd: 12618,
        testnetMode: true,
      );

      when(() => appCubit.selectedNetwork).thenReturn(AppNetworks.mainnet);

      when(
        () => yieldRepository.getSingleNetworkYield(
          network: any(named: "network"),
          token0Address: any(named: "token0Address"),
          token1Address: any(named: "token1Address"),
          group0Id: any(named: "group0Id"),
          group1Id: any(named: "group1Id"),
          searchSettings: any(named: "searchSettings"),
          blockedProtocolIds: any(named: "blockedProtocolIds"),
        ),
      ).thenAnswer((_) async => const YieldsDto(pools: [], filters: expectedFilters));

      await sut.fetchYields(
        token0AddressOrId: "token0AddressOrId",
        token1AddressOrId: "token1AddressOrId",
        group0Id: "group0Id",
        group1Id: "group1Id",
      );

      expect(sut.state, const YieldsState.noYields(filtersApplied: expectedFilters));
    },
  );

  test(
    """When returning a non empty pools list for a all networks
    yield search, it should emit the success state,passing the
    whole DTO to the state""",
    () async {
      final expectedYields = YieldsDto.fixture();

      when(() => appCubit.selectedNetwork).thenReturn(AppNetworks.allNetworks);

      when(
        () => yieldRepository.getAllNetworksYield(
          token0InternalId: any(named: "token0InternalId"),
          token1InternalId: any(named: "token1InternalId"),
          group0Id: any(named: "group0Id"),
          group1Id: any(named: "group1Id"),
          searchSettings: any(named: "searchSettings"),
          blockedProtocolIds: any(named: "blockedProtocolIds"),
          testnetMode: any(named: "testnetMode"),
        ),
      ).thenAnswer((_) async => expectedYields);

      await sut.fetchYields(
        token0AddressOrId: "token0AddressOrId",
        token1AddressOrId: "token1AddressOrId",
        group0Id: "group0Id",
        group1Id: "group1Id",
      );

      expect(sut.state, YieldsState.success(expectedYields));
    },
  );

  test(
    """When returning a non empty pools list for a single network
    yield search, it should emit the success state, passing the
    whole DTO to the state""",
    () async {
      final expectedYields = YieldsDto.fixture();

      when(() => appCubit.selectedNetwork).thenReturn(AppNetworks.mainnet);

      when(
        () => yieldRepository.getSingleNetworkYield(
          network: any(named: "network"),
          token0Address: any(named: "token0Address"),
          token1Address: any(named: "token1Address"),
          group0Id: any(named: "group0Id"),
          group1Id: any(named: "group1Id"),
          searchSettings: any(named: "searchSettings"),
          blockedProtocolIds: any(named: "blockedProtocolIds"),
        ),
      ).thenAnswer((_) async => expectedYields);

      await sut.fetchYields(
        token0AddressOrId: "token0AddressOrId",
        token1AddressOrId: "token1AddressOrId",
        group0Id: "group0Id",
        group1Id: "group1Id",
      );

      expect(sut.state, YieldsState.success(expectedYields));
    },
  );

  test(
    """When throwing an error while getting yields, it should emit
    the error state passing the error and the stack trace""",
    () async {
      const expectedErrorString = "xabas";
      const expectedErrorStackTraceString = "sabaxStackStace";

      when(() => appCubit.selectedNetwork).thenReturn(AppNetworks.mainnet);

      when(
        () => yieldRepository.getSingleNetworkYield(
          network: any(named: "network"),
          token0Address: any(named: "token0Address"),
          token1Address: any(named: "token1Address"),
          group0Id: any(named: "group0Id"),
          group1Id: any(named: "group1Id"),
          searchSettings: any(named: "searchSettings"),
          blockedProtocolIds: any(named: "blockedProtocolIds"),
        ),
      ).thenAnswer(
        (_) => Error.throwWithStackTrace(expectedErrorString, StackTrace.fromString(expectedErrorStackTraceString)),
      );

      await sut.fetchYields(
        token0AddressOrId: "token0AddressOrId",
        token1AddressOrId: "token1AddressOrId",
        group0Id: "group0Id",
        group1Id: "group1Id",
      );

      expect(sut.state, const YieldsState.error(expectedErrorString, expectedErrorStackTraceString));
    },
  );
}
