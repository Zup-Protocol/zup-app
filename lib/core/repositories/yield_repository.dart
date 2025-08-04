import 'package:dio/dio.dart';
import 'package:zup_app/core/dtos/pool_search_settings_dto.dart';
import 'package:zup_app/core/dtos/yields_dto.dart';
import 'package:zup_app/core/enums/networks.dart';

class YieldRepository {
  YieldRepository(this._zupAPIDio);

  final Dio _zupAPIDio;

  Future<YieldsDto> getSingleNetworkYield({
    required String? token0Address,
    required String? token1Address,
    required String? group0Id,
    required String? group1Id,
    required AppNetworks network,
    required PoolSearchSettingsDto searchSettings,
    required List<String> blockedProtocolIds,
  }) async {
    final response = await _zupAPIDio.post("/pools/search/${network.chainId}", queryParameters: {
      if (token0Address != null) "token0Address": token0Address,
      if (token1Address != null) "token1Address": token1Address,
      if (group0Id != null) "group0Id": group0Id,
      if (group1Id != null) "group1Id": group1Id,
    }, data: {
      "filters": {
        "minTvlUsd": searchSettings.minLiquidityUSD,
        "blockedProtocols": blockedProtocolIds,
        "allowedPoolTypes": [
          if (searchSettings.allowV3Search) "V3",
          if (searchSettings.allowV4Search) "V4",
        ],
      }
    });

    return YieldsDto.fromJson(response.data);
  }

  Future<YieldsDto> getAllNetworksYield({
    required String? token0InternalId,
    required String? token1InternalId,
    required String? group0Id,
    required String? group1Id,
    required PoolSearchSettingsDto searchSettings,
    required List<String> blockedProtocolIds,
    bool testnetMode = false,
  }) async {
    final response = await _zupAPIDio.post("/pools/search/all", queryParameters: {
      if (token0InternalId != null) "token0Id": token0InternalId,
      if (token1InternalId != null) "token1Id": token1InternalId,
      if (group0Id != null) "group0Id": group0Id,
      if (group1Id != null) "group1Id": group1Id,
    }, data: {
      "filters": {
        "minTvlUsd": searchSettings.minLiquidityUSD,
        "testnetMode": testnetMode,
        "blockedProtocols": blockedProtocolIds,
        "allowedPoolTypes": [
          if (searchSettings.allowV3Search) "V3",
          if (searchSettings.allowV4Search) "V4",
        ],
      }
    });

    return YieldsDto.fromJson(response.data);
  }
}
