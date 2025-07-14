import 'package:dio/dio.dart';
import 'package:zup_app/core/dtos/pool_search_settings_dto.dart';
import 'package:zup_app/core/dtos/yields_dto.dart';
import 'package:zup_app/core/enums/networks.dart';

class YieldRepository {
  YieldRepository(this._zupAPIDio);

  final Dio _zupAPIDio;

  Future<YieldsDto> getSingleNetworkYield({
    required String token0Address,
    required String token1Address,
    required AppNetworks network,
    required PoolSearchSettingsDto searchSettings,
  }) async {
    final response = await _zupAPIDio.post("/pools/search/${network.chainId}", queryParameters: {
      "token0Address": token0Address,
      "token1Address": token1Address,
    }, data: {
      "filters": {
        "minTvlUsd": searchSettings.minLiquidityUSD,
        "allowedPoolTypes": [
          if (searchSettings.allowV3Search) "V3",
          if (searchSettings.allowV4Search) "V4",
        ],
      }
    });

    return YieldsDto.fromJson(response.data);
  }

  Future<YieldsDto> getAllNetworksYield({
    required String token0InternalId,
    required String token1InternalId,
    required PoolSearchSettingsDto searchSettings,
    bool testnetMode = false,
  }) async {
    final response = await _zupAPIDio.post("/pools/search/all", queryParameters: {
      "token0Id": token0InternalId,
      "token1Id": token1InternalId,
    }, data: {
      "filters": {
        "minTvlUsd": searchSettings.minLiquidityUSD,
        "testnetMode": testnetMode,
        "allowedPoolTypes": [
          if (searchSettings.allowV3Search) "V3",
          if (searchSettings.allowV4Search) "V4",
        ],
      }
    });

    return YieldsDto.fromJson(response.data);
  }
}
