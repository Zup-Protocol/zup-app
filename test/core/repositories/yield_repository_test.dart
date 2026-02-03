void main() {
  // late Dio dio;
  // late YieldRepository sut;

  // setUp(() {
  //   dio = DioMock();
  //   sut = YieldRepository(dio);
  // });

  // // test("When calling `getSingleNetworkYield` it should call the correct endpoint with the correct params", () async {
  // //   final yields = LiquidityPoolsSearchResultDto.fixture();

  // //   when(
  // //     () => dio.post(
  // //       any(),
  // //       queryParameters: any(named: "queryParameters"),
  // //       data: any(named: "data"),
  // //     ),
  // //   ).thenAnswer(
  // //     (_) async => Response(data: {"bestYields": yields.toJson()}, statusCode: 200, requestOptions: RequestOptions()),
  // //   );

  // //   const token0Address = "0x123";
  // //   const token1Address = "0x456";
  // //   const group0Id = "0x789";
  // //   const group1Id = "0xabc";
  // //   const network = AppNetworks.sepolia;
  // //   const minTvlUsd = 1213;
  // //   final searchSettings = PoolSearchSettingsDto.fixture().copyWith(minLiquidityUSD: minTvlUsd);
  // //   final blockedProtocolsIds = ["1", "2", "3"];

  // //   await sut.getSingleNetworkYield(
  // //     group0Id: group0Id,
  // //     group1Id: group1Id,
  // //     blockedProtocolIds: blockedProtocolsIds,
  // //     token0Address: token0Address,
  // //     token1Address: token1Address,

  // //     network: network,
  // //     searchSettings: searchSettings,
  // //   );

  // //   verify(
  // //     () => dio.post(
  // //       "/pools/search/${network.chainId}",
  // //       queryParameters: {
  // //         "token0Address": token0Address,
  // //         "token1Address": token1Address,
  // //         "group0Id": group0Id,
  // //         "group1Id": group1Id,
  // //       },
  // //       data: {
  // //         "filters": {"minimumTvlUsd": searchSettings.minLiquidityUSD, "blockedProtocols": blockedProtocolsIds},
  // //       },
  // //     ),
  // //   ).called(1);
  // // });

  // test("When calling `getYields` it should correctly parse the response", () async {
  //   final yields = LiquidityPoolsSearchResultDto.fixture();

  //   when(
  //     () => dio.post(
  //       any(),
  //       queryParameters: any(named: "queryParameters"),
  //       data: any(named: "data"),
  //     ),
  //   ).thenAnswer((_) async => Response(data: yields.toJson(), statusCode: 200, requestOptions: RequestOptions()));

  //   const token0Address = "0x123";
  //   const token1Address = "0x456";
  //   const network = AppNetworks.sepolia;

  //   final response = await sut.getSingleNetworkYield(
  //     group0Id: null,
  //     group1Id: null,
  //     blockedProtocolIds: [],
  //     token0Address: token0Address,
  //     token1Address: token1Address,
  //     network: network,
  //     searchSettings: PoolSearchSettingsDto.fixture().copyWith(minLiquidityUSD: 0),
  //   );

  //   expect(response, yields);
  // });

  // test("when calling 'getAllNetworksYield' it should call the correct endpoint with the correct params", () async {
  //   final yields = LiquidityPoolsSearchResultDto.fixture();

  //   when(
  //     () => dio.post(
  //       any(),
  //       queryParameters: any(named: "queryParameters"),
  //       data: any(named: "data"),
  //     ),
  //   ).thenAnswer(
  //     (_) async => Response(data: {"bestYields": yields.toJson()}, statusCode: 200, requestOptions: RequestOptions()),
  //   );

  //   const token0Id = "0x123";
  //   const token1Id = "0x456";
  //   const group0Id = "0x789";
  //   const group1Id = "0xabc";
  //   const minTvlUsd = 1213;
  //   final searchSettings = PoolSearchSettingsDto.fixture().copyWith(minLiquidityUSD: minTvlUsd);
  //   final blockedProtocolsIds = ["1", "2", "3"];

  //   await sut.getAllNetworksYield(
  //     group0Id: group0Id,
  //     group1Id: group1Id,
  //     blockedProtocolIds: blockedProtocolsIds,
  //     token0InternalId: token0Id,
  //     token1InternalId: token1Id,
  //     searchSettings: searchSettings,
  //     testnetMode: true,
  //   );

  //   verify(
  //     () => dio.post(
  //       "/pools/search/all",
  //       queryParameters: {"token0Id": token0Id, "token1Id": token1Id, "group0Id": group0Id, "group1Id": group1Id},
  //       data: {
  //         "filters": {"minimumTvlUsd": searchSettings.minLiquidityUSD, "blockedProtocols": blockedProtocolsIds},
  //         "config": {"testnetMode": true},
  //       },
  //     ),
  //   ).called(1);
  // });

  // test("when calling 'getAllNetworksYield' it should correctly parse the response", () async {
  //   final yields = LiquidityPoolsSearchResultDto.fixture();

  //   when(
  //     () => dio.post(
  //       any(),
  //       queryParameters: any(named: "queryParameters"),
  //       data: any(named: "data"),
  //     ),
  //   ).thenAnswer((_) async => Response(data: yields.toJson(), statusCode: 200, requestOptions: RequestOptions()));

  //   const token0Id = "0x123";
  //   const token1Id = "0x456";

  //   final response = await sut.getAllNetworksYield(
  //     group0Id: null,
  //     group1Id: null,
  //     blockedProtocolIds: [],
  //     token0InternalId: token0Id,
  //     token1InternalId: token1Id,
  //     searchSettings: PoolSearchSettingsDto.fixture().copyWith(minLiquidityUSD: 0),
  //     testnetMode: true,
  //   );

  //   expect(response, yields);
  // });
}
