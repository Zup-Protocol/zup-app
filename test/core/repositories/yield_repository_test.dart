import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zup_app/core/dtos/pool_search_settings_dto.dart';
import 'package:zup_app/core/dtos/yields_dto.dart';
import 'package:zup_app/core/enums/networks.dart';
import 'package:zup_app/core/repositories/yield_repository.dart';

import '../../mocks.dart';

void main() {
  late Dio dio;
  late YieldRepository sut;

  setUp(() {
    dio = DioMock();
    sut = YieldRepository(dio);
  });

  test("When calling `getSingleNetworkYield` it should call the correct endpoint with the correct params", () async {
    final yields = YieldsDto.fixture();

    when(() => dio.post(any(), queryParameters: any(named: "queryParameters"), data: any(named: "data"))).thenAnswer(
      (_) async => Response(
        data: {"bestYields": yields.toJson()},
        statusCode: 200,
        requestOptions: RequestOptions(),
      ),
    );

    const token0Address = "0x123";
    const token1Address = "0x456";
    const network = AppNetworks.sepolia;
    const minTvlUsd = 1213;
    final searchSettings = PoolSearchSettingsDto.fixture().copyWith(minLiquidityUSD: minTvlUsd);

    await sut.getSingleNetworkYield(
      token0Address: token0Address,
      token1Address: token1Address,
      network: network,
      searchSettings: searchSettings,
    );

    verify(
      () => dio.post("/pools/search/${network.chainId}", queryParameters: {
        "token0Address": token0Address,
        "token1Address": token1Address
      }, data: {
        "filters": {
          "minTvlUsd": searchSettings.minLiquidityUSD,
          "allowedPoolTypes": [
            "V3",
            "V4",
          ],
        }
      }),
    ).called(1);
  });

  test("When the V3 Pool is disabled in the search settings, it should not be included in the request", () async {
    final yields = YieldsDto.fixture();

    when(() => dio.post(any(), queryParameters: any(named: "queryParameters"), data: any(named: "data"))).thenAnswer(
      (_) async => Response(
        data: {"bestYields": yields.toJson()},
        statusCode: 200,
        requestOptions: RequestOptions(),
      ),
    );

    const token0Address = "0x123";
    const token1Address = "0x456";
    const network = AppNetworks.sepolia;
    final searchSettings = PoolSearchSettingsDto.fixture().copyWith(allowV3Search: false);

    await sut.getSingleNetworkYield(
      token0Address: token0Address,
      token1Address: token1Address,
      network: network,
      searchSettings: searchSettings,
    );

    verify(
      () => dio.post("/pools/search/${network.chainId}", queryParameters: {
        "token0Address": token0Address,
        "token1Address": token1Address
      }, data: {
        "filters": {
          "minTvlUsd": searchSettings.minLiquidityUSD,
          "allowedPoolTypes": [
            "V4",
          ],
        }
      }),
    ).called(1);
  });

  test("When the V4 Pool is disabled in the search settings, it should not be included in the request", () async {
    final yields = YieldsDto.fixture();

    when(() => dio.post(any(), queryParameters: any(named: "queryParameters"), data: any(named: "data"))).thenAnswer(
      (_) async => Response(
        data: {"bestYields": yields.toJson()},
        statusCode: 200,
        requestOptions: RequestOptions(),
      ),
    );

    const token0Address = "0x123";
    const token1Address = "0x456";
    const network = AppNetworks.sepolia;
    final searchSettings = PoolSearchSettingsDto.fixture().copyWith(allowV4Search: false);

    await sut.getSingleNetworkYield(
      token0Address: token0Address,
      token1Address: token1Address,
      network: network,
      searchSettings: searchSettings,
    );

    verify(
      () => dio.post("/pools/search/${network.chainId}", queryParameters: {
        "token0Address": token0Address,
        "token1Address": token1Address
      }, data: {
        "filters": {
          "minTvlUsd": searchSettings.minLiquidityUSD,
          "allowedPoolTypes": ["V3"],
        }
      }),
    ).called(1);
  });

  test("When calling `getYields` it should correctly parse the response", () async {
    final yields = YieldsDto.fixture();

    when(() => dio.post(any(), queryParameters: any(named: "queryParameters"), data: any(named: "data"))).thenAnswer(
      (_) async => Response(
        data: yields.toJson(),
        statusCode: 200,
        requestOptions: RequestOptions(),
      ),
    );

    const token0Address = "0x123";
    const token1Address = "0x456";
    const network = AppNetworks.sepolia;

    final response = await sut.getSingleNetworkYield(
      token0Address: token0Address,
      token1Address: token1Address,
      network: network,
      searchSettings: PoolSearchSettingsDto.fixture().copyWith(minLiquidityUSD: 0),
    );

    expect(response, yields);
  });

  test("when calling 'getAllNetworksYield' it should call the correct endpoint with the correct params", () async {
    final yields = YieldsDto.fixture();

    when(() => dio.post(any(), queryParameters: any(named: "queryParameters"), data: any(named: "data"))).thenAnswer(
      (_) async => Response(
        data: {"bestYields": yields.toJson()},
        statusCode: 200,
        requestOptions: RequestOptions(),
      ),
    );

    const token0Id = "0x123";
    const token1Id = "0x456";
    const minTvlUsd = 1213;
    final searchSettings = PoolSearchSettingsDto.fixture().copyWith(minLiquidityUSD: minTvlUsd);

    await sut.getAllNetworksYield(
      token0InternalId: token0Id,
      token1InternalId: token1Id,
      searchSettings: searchSettings,
      testnetMode: true,
    );

    verify(
      () => dio.post("/pools/search/all", queryParameters: {
        "token0Id": token0Id,
        "token1Id": token1Id,
      }, data: {
        "filters": {
          "testnetMode": true,
          "minTvlUsd": searchSettings.minLiquidityUSD,
          "allowedPoolTypes": [
            "V3",
            "V4",
          ],
        }
      }),
    ).called(1);
  });

  test(
      "when calling 'getAllNetworksYield' and the search settings has the v4 pool disallowed, it should not be included in the params",
      () async {
    final yields = YieldsDto.fixture();

    when(() => dio.post(any(), queryParameters: any(named: "queryParameters"), data: any(named: "data"))).thenAnswer(
      (_) async => Response(
        data: {"bestYields": yields.toJson()},
        statusCode: 200,
        requestOptions: RequestOptions(),
      ),
    );

    const token0Id = "0x123";
    const token1Id = "0x456";
    const minTvlUsd = 1213;
    final searchSettings = PoolSearchSettingsDto.fixture().copyWith(minLiquidityUSD: minTvlUsd, allowV4Search: false);

    await sut.getAllNetworksYield(
      token0InternalId: token0Id,
      token1InternalId: token1Id,
      searchSettings: searchSettings,
      testnetMode: true,
    );

    verify(
      () => dio.post("/pools/search/all", queryParameters: {
        "token0Id": token0Id,
        "token1Id": token1Id,
      }, data: {
        "filters": {
          "testnetMode": true,
          "minTvlUsd": searchSettings.minLiquidityUSD,
          "allowedPoolTypes": [
            "V3",
          ],
        }
      }),
    ).called(1);
  });

  test(
      "when calling 'getAllNetworksYield' and the search settings has the v3 pool disallowed, it should not be included in the params",
      () async {
    final yields = YieldsDto.fixture();

    when(() => dio.post(any(), queryParameters: any(named: "queryParameters"), data: any(named: "data"))).thenAnswer(
      (_) async => Response(
        data: {"bestYields": yields.toJson()},
        statusCode: 200,
        requestOptions: RequestOptions(),
      ),
    );

    const token0Id = "0x123";
    const token1Id = "0x456";
    const minTvlUsd = 1213;
    final searchSettings = PoolSearchSettingsDto.fixture().copyWith(minLiquidityUSD: minTvlUsd, allowV3Search: false);

    await sut.getAllNetworksYield(
      token0InternalId: token0Id,
      token1InternalId: token1Id,
      searchSettings: searchSettings,
      testnetMode: true,
    );

    verify(
      () => dio.post("/pools/search/all", queryParameters: {
        "token0Id": token0Id,
        "token1Id": token1Id,
      }, data: {
        "filters": {
          "testnetMode": true,
          "minTvlUsd": searchSettings.minLiquidityUSD,
          "allowedPoolTypes": [
            "V4",
          ],
        }
      }),
    ).called(1);
  });

  test("when calling 'getAllNetworksYield' it should correctly parse the response", () async {
    final yields = YieldsDto.fixture();

    when(() => dio.post(any(), queryParameters: any(named: "queryParameters"), data: any(named: "data"))).thenAnswer(
      (_) async => Response(
        data: yields.toJson(),
        statusCode: 200,
        requestOptions: RequestOptions(),
      ),
    );

    const token0Id = "0x123";
    const token1Id = "0x456";

    final response = await sut.getAllNetworksYield(
      token0InternalId: token0Id,
      token1InternalId: token1Id,
      searchSettings: PoolSearchSettingsDto.fixture().copyWith(minLiquidityUSD: 0),
      testnetMode: true,
    );

    expect(response, yields);
  });
}
